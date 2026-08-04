#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Amiga/Tools/build-support/adflib/tests/test_canary_workflow.py --case success

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import Final

if __package__:
    from .canary_incompatible_scenario import (
        CONSUMER_CONTRACT,
        incompatible_scenario_passed,
        run_incompatible_scenario,
    )
else:
    from canary_incompatible_scenario import (
        CONSUMER_CONTRACT,
        incompatible_scenario_passed,
        run_incompatible_scenario,
    )

REPOSITORY_ROOT: Final = Path(__file__).resolve().parents[5]
WORKFLOW: Final = REPOSITORY_ROOT / ".github/workflows/adflib-canary.yml"
COORDINATOR: Final = Path(__file__).resolve().parents[1] / "canary_coordinator.py"
CASES: Final = {"success", "incompatible-master", "upload-disabled", "non-default-fixture-ref"}


def workflow_contract(case: str) -> tuple[bool, str]:
    workflow = WORKFLOW.read_text(encoding="utf-8")
    if case == "success":
        required = (
            "schedule:",
            "workflow_dispatch:",
            "environment: adflib-verification",
            "uses: ./.github/workflows/adflib-consumers-ci.yml",
            "channel: canary",
            "candidate_ref: ${{ needs.preflight.outputs.trusted_sha }}",
            "compatibility_fixture: ${{ needs.preflight.outputs.compatibility_fixture }}",
            "upload_failure_logs: false",
            "version=0.0.0-canary",
            "tag=master",
        )
        missing = [token for token in required if token not in workflow]
        forbidden = re.search(
            r"permissions:\s*(?:write-all|[^\n]*write)|pull-requests:|git push|gh pr|/releases(?:/|\b)|create-release|curl[^\n]+-X\s+(?:POST|PATCH|PUT|DELETE)|secrets:\s+inherit",
            workflow,
        )
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            (root / "repository.json").write_text(json.dumps({"default_branch": "master"}), encoding="utf-8")
            (root / "environment.json").write_text(
                json.dumps(
                    {
                        "name": "adflib-verification",
                        "protection_rules": [
                            {
                                "type": "required_reviewers",
                                "reviewers": [{"type": "Team", "reviewer": {"slug": "maintainers"}}],
                            }
                        ],
                    }
                ),
                encoding="utf-8",
            )
            (root / "actions.json").write_text(
                json.dumps({"can_approve_pull_request_reviews": False, "default_workflow_permissions": "read"}),
                encoding="utf-8",
            )
            (root / "variable.json").write_text(
                json.dumps({"name": "ADFLIB_AUTOMATION_APPROVER_TEAM", "value": "maintainers"}),
                encoding="utf-8",
            )
            preflight = subprocess.run(
                [
                    sys.executable,
                    str(COORDINATOR),
                    "preflight",
                    "--repository",
                    str(root / "repository.json"),
                    "--environment",
                    str(root / "environment.json"),
                    "--actions",
                    str(root / "actions.json"),
                    "--variable",
                    str(root / "variable.json"),
                ],
                env={**os.environ, "EXPECTED_APPROVER_TEAM": "maintainers"},
                check=False,
                capture_output=True,
                text=True,
            )
        return not missing and forbidden is None and preflight.returncode == 0, f"missing={missing}; forbidden={forbidden}; {preflight.stderr}"
    if case == "incompatible-master":
        scenario = run_incompatible_scenario()
        return incompatible_scenario_passed(scenario), scenario.detail
    if case == "upload-disabled":
        artifact_api = re.search(r"actions/(?:upload|download)-artifact|/artifacts(?:\?|\b)|actions/artifacts", workflow)
        disabled = workflow.count("upload_failure_logs: false") == 1
        return artifact_api is None and disabled, "canary caller must have no artifact API operation"
    if case == "non-default-fixture-ref":
        with tempfile.TemporaryDirectory() as temporary:
            environment = {
                **os.environ,
                "EVENT_NAME": "workflow_dispatch",
                "EVENT_SHA": "a" * 40,
                "TRUSTED_SHA": "b" * 40,
                "WORKFLOW_REF": f"GINNOV/littlethings/.github/workflows/adflib-canary.yml@{'a' * 40}",
                "WORKFLOW_SHA": "a" * 40,
                "FIXTURE": "incompatible-master",
                "VERIFICATION_NONCE": "123e4567-e89b-42d3-a456-426614174000",
                "OUTPUT_FILE": str(Path(temporary) / "output"),
            }
            result = subprocess.run(
                [sys.executable, str(COORDINATOR), "authorize"],
                env=environment,
                check=False,
                capture_output=True,
                text=True,
            )
        return result.returncode == 2 and "non_default_fixture_ref" in result.stderr, result.stderr
    return False, "unknown case"


class CanaryWorkflowTests(unittest.TestCase):
    def test_workflow_contract_cases(self) -> None:
        # Given: the complete local canary orchestration surface.
        for case in sorted(CASES):
            with self.subTest(case=case):
                # When: each required success or failure scenario is simulated.
                passed, detail = workflow_contract(case)
                # Then: the scenario proves its binary observable.
                self.assertTrue(passed, detail)

    def test_incompatible_case_rejects_removed_red_propagation(self) -> None:
        # Given: Todo 7's real helper with only the incompatible red branch mutated to success.
        source = CONSUMER_CONTRACT.read_text(encoding="utf-8")
        red_branch = (
            '    if fixture == "incompatible-master" and channel == "canary":\n'
            '        raise ContractError("adflib_compatibility_fixture: incompatible-master")\n'
        )
        self.assertEqual(source.count(red_branch), 1)
        with tempfile.TemporaryDirectory() as temporary:
            mutant = Path(temporary) / "consumer_workflow_contract.py"
            mutant.write_text(source.replace(red_branch, red_branch.splitlines(keepends=True)[0] + "        return\n"), encoding="utf-8")
            # When: the same coordinator-to-route-to-preflight scenario uses that mutant.
            scenario = run_incompatible_scenario(mutant)
        # Then: terminal success is rejected by the canary acceptance predicate.
        self.assertEqual(scenario.terminal_state, "success")
        self.assertFalse(incompatible_scenario_passed(scenario))


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", choices=sorted(CASES))
    arguments = parser.parse_args()
    if arguments.case is None:
        suite = unittest.defaultTestLoader.loadTestsFromTestCase(CanaryWorkflowTests)
        return 0 if unittest.TextTestRunner().run(suite).wasSuccessful() else 1
    passed, detail = workflow_contract(arguments.case)
    if not passed:
        print(detail, file=sys.stderr)
        return 1
    print(f"canary_case_verified:{arguments.case} {detail if arguments.case == 'incompatible-master' else ''}".rstrip())
    return 0


if __name__ == "__main__":
    sys.exit(main())
