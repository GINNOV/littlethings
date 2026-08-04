#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Amiga/Tools/build-support/adflib/tests/test_update_workflow.py --case stable-upgrade

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import Final

REPOSITORY_ROOT: Final = Path(__file__).resolve().parents[5]
COORDINATOR: Final = Path(__file__).resolve().parents[1] / "stable_update_coordinator.py"
WORKFLOW: Final = REPOSITORY_ROOT / ".github/workflows/adflib-update.yml"
FAILURE_CASES: Final = {
    "matrix-failure", "runner-loss", "stale-owned-ref", "stale-unowned-ref", "spoofed-owner-marker",
    "missing-lease", "mismatched-lease", "expired-run-durable-lease", "actions-bot-write",
    "actions-pr-setting-enabled", "app-installation-mismatch", "app-master-push-denied", "app-merge-denied",
    "app-extra-permission", "unowned-stable-branch", "unowned-stable-pr", "stable-lease-loss",
    "merged-cleanup", "closed-preserved", "stable-reserved-resume", "stable-branch-bound-resume",
    "stable-bootstrap-rollback", "refresh-loss-after-lease", "refresh-loss-after-branch",
    "refresh-loss-after-pr-marker", "refresh-invalid-observation", "closed-cleanup", "orphan-lease-cleanup",
    "orphan-branch-fail", "orphan-pr-fail", "superseded-release", "non-default-fixture-ref",
}
EXTRA_CASES: Final = {
    "newer", "noop", "dry", "current", "pr-initial", "pr-refresh", "pr-supersede", "incompatible",
    "lease-conflict", "ref-create-failure", "validation-fail", "candidate-substitution", "license-pending",
    "draft", "prerelease",
}


def parsed_workflow() -> dict[str, object]:
    ruby = "document=YAML.safe_load(File.read(ARGV[0]), aliases: true); document['on']=document.delete(true) if document.key?(true); puts JSON.generate(document)"
    result = subprocess.run(["ruby", "-ryaml", "-rjson", "-e", ruby, str(WORKFLOW)], check=False, capture_output=True, text=True)
    if result.returncode != 0:
        raise AssertionError(result.stderr)
    value = json.loads(result.stdout)
    if not isinstance(value, dict):
        raise TypeError("workflow_root_not_mapping")
    return value


def mapping(value: object) -> dict[str, object]:
    if not isinstance(value, dict) or not all(isinstance(key, str) for key in value):
        raise AssertionError("workflow_node_not_mapping")
    return value


def needs(job: dict[str, object]) -> set[str]:
    value = job.get("needs", [])
    if isinstance(value, str):
        return {value}
    if not isinstance(value, list) or not all(isinstance(item, str) for item in value):
        raise AssertionError("workflow_needs_invalid")
    return set(value)


class StableUpdateWorkflowTests(unittest.TestCase):
    def test_stable_upgrade_promotes_only_the_five_leg_tested_tip(self) -> None:
        # Given: a newer stable candidate and an initially empty owned namespace.
        with tempfile.TemporaryDirectory() as temporary:
            transcript = Path(temporary) / "transcript.json"
            # When: the local fake-API scenario runs through the coordinator CLI.
            result = subprocess.run(
                [sys.executable, str(COORDINATOR), "fixture", "stable-upgrade", "--transcript", str(transcript)],
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: the exact validated tip becomes the only branch and PR head.
            self.assertEqual(result.returncode, 0, result.stderr)
            payload = json.loads(transcript.read_text(encoding="utf-8"))
            self.assertEqual(payload["consumer_legs"], 5)
            self.assertEqual(payload["stable_branch_sha"], payload["tested_tip"])
            self.assertEqual(payload["pull_requests"], 1)

    def test_workflow_routes_candidate_through_reusable_matrix_before_promotion(self) -> None:
        # Given: the updater is parsed as a YAML document rather than inspected as implementation text.
        workflow = parsed_workflow()
        triggers = mapping(workflow.get("on"))
        dispatch = mapping(triggers.get("workflow_dispatch"))
        inputs = mapping(dispatch.get("inputs"))
        jobs = mapping(workflow.get("jobs"))
        # When: triggers, closed inputs, permissions, reusable edges, and the promotion DAG are evaluated.
        self.assertIn("schedule", triggers)
        mode = mapping(inputs.get("mode"))
        self.assertEqual(mode.get("type"), "choice")
        self.assertEqual(mode.get("options"), ["production", "fixture-noop", "fixture-upgrade", "fixture-failure", "recover-owned"])
        self.assertEqual(mapping(inputs.get("recovery_action")).get("default"), "")
        self.assertEqual(mapping(workflow.get("permissions")), {"contents": "read"})
        validate = mapping(jobs.get("validate"))
        self.assertEqual(validate.get("uses"), "./.github/workflows/adflib-consumers-ci.yml")
        self.assertEqual(mapping(validate.get("permissions")), {"contents": "read"})
        expected_needs = {
            "validation-ref": {"preflight", "candidate", "reconcile"},
            "validate": {"preflight", "candidate", "validation-ref"},
            "cleanup": {"preflight", "candidate", "validation-ref", "validate"},
            "snapshot-pr-runs": {"preflight", "candidate", "validate", "cleanup"},
            "promote": {"preflight", "candidate", "validate", "cleanup", "snapshot-pr-runs"},
            "supplemental-pr-run": {"preflight", "candidate", "snapshot-pr-runs", "promote"},
        }
        for job_name, dependencies in expected_needs.items():
            self.assertEqual(needs(mapping(jobs.get(job_name))), dependencies)
        # Then: every App-token mutation node is protected, read-only at the job token layer, and digest-gated.
        for job_name in ("reconcile", "validation-ref", "cleanup", "promote", "supplemental-pr-run", "recover-owned"):
            job = mapping(jobs.get(job_name))
            self.assertEqual(job.get("environment"), "adflib-verification")
            self.assertEqual(mapping(job.get("permissions")), {"contents": "read"})
            condition = job.get("if")
            if not isinstance(condition, str):
                self.fail(f"{job_name}: mutation condition is not a string")
            self.assertIn("needs.preflight.outputs.authority_digest", condition)

    def test_orphan_recovery_requires_observed_branch_and_pr_absence(self) -> None:
        # Given: an owner requests orphan cleanup but observes a concrete branch SHA.
        command = [
            sys.executable,
            str(COORDINATOR),
            "validate-dispatch",
            "--mode",
            "recover-owned",
            "--recovery-action",
            "cleanup-orphan",
            "--observed-lease-sha",
            "c" * 40,
            "--observed-ref-sha",
            "a" * 40,
            "--observed-pr-head-sha",
            "absent",
            "--observed-pr-number",
            "absent",
        ]
        # When: exact-observation dispatch inputs cross the coordinator boundary.
        result = subprocess.run(command, check=False, capture_output=True, text=True)
        # Then: recovery is rejected before any mutation because the branch is not absent.
        self.assertEqual(result.returncode, 2)
        self.assertIn("recovery_absence_required", result.stderr)


class FixtureScenarioTest(unittest.TestCase):
    scenario: str

    def __init__(self, methodName: str = "test_fixture_scenario_preserves_transactional_contract", scenario: str = "stable-upgrade") -> None:
        super().__init__(methodName)
        self.scenario = scenario

    def test_fixture_scenario_preserves_transactional_contract(self) -> None:
        # Given: a committed fake GitHub API scenario selected through the public CLI.
        with tempfile.TemporaryDirectory() as temporary:
            transcript = Path(temporary) / "transcript.json"
            # When: the coordinator reconciles, validates, cleans up, and conditionally promotes it.
            result = subprocess.run(
                [sys.executable, str(COORDINATOR), "fixture", self.scenario, "--transcript", str(transcript)],
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: no ephemeral ownership proof survives and promotion is bound to five-leg success.
            self.assertEqual(result.returncode, 0, result.stderr)
            payload = json.loads(transcript.read_text(encoding="utf-8"))
            self.assertEqual(payload["validation_refs"], 0)
            self.assertEqual(payload["validation_leases"], 0)
            if payload["outcome"] in {"promoted", "refreshed"}:
                self.assertEqual(payload["consumer_legs"], 5)
                self.assertEqual(payload["stable_branch_sha"], payload["tested_tip"])
                self.assertEqual(payload["stable_lease_phase"], "active")
            if self.scenario in {"matrix-failure", "incompatible", "validation-fail", "candidate-substitution"}:
                self.assertEqual(payload["pull_requests"], 0)
                self.assertTrue(any(event.startswith("delete:refs/heads/deps/adflib-validation/") for event in payload["mutations"]))
            if self.scenario in {"stale-unowned-ref", "spoofed-owner-marker", "missing-lease", "mismatched-lease", "unowned-stable-branch", "unowned-stable-pr", "orphan-branch-fail", "orphan-pr-fail"}:
                self.assertTrue(payload["unowned_preserved"])
            if self.scenario in {"actions-bot-write", "actions-pr-setting-enabled", "app-installation-mismatch", "app-master-push-denied", "app-merge-denied", "app-extra-permission", "non-default-fixture-ref", "license-pending"}:
                self.assertEqual(payload["mutations"], [])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", default="all")
    arguments = parser.parse_args()
    suite = unittest.TestSuite()
    if arguments.case == "all":
        suite.addTest(StableUpdateWorkflowTests("test_stable_upgrade_promotes_only_the_five_leg_tested_tip"))
        suite.addTest(StableUpdateWorkflowTests("test_workflow_routes_candidate_through_reusable_matrix_before_promotion"))
        suite.addTest(StableUpdateWorkflowTests("test_orphan_recovery_requires_observed_branch_and_pr_absence"))
        for scenario in sorted(FAILURE_CASES | EXTRA_CASES):
            suite.addTest(FixtureScenarioTest(scenario=scenario))
    if arguments.case == "stable-upgrade":
        suite.addTest(StableUpdateWorkflowTests("test_stable_upgrade_promotes_only_the_five_leg_tested_tip"))
        suite.addTest(StableUpdateWorkflowTests("test_workflow_routes_candidate_through_reusable_matrix_before_promotion"))
        suite.addTest(StableUpdateWorkflowTests("test_orphan_recovery_requires_observed_branch_and_pr_absence"))
    if arguments.case in FAILURE_CASES | EXTRA_CASES and arguments.case != "stable-upgrade":
        suite.addTest(FixtureScenarioTest(scenario=arguments.case))
    if suite.countTestCases() == 0:
        print(f"unknown case: {arguments.case}", file=sys.stderr)
        return 2
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
