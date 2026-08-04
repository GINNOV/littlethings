#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# pyright: reportImplicitRelativeImport=false
# ─── How to run ───
# python3 stable_update_coordinator.py fixture stable-upgrade --transcript /tmp/adflib-update.json

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass, replace
from pathlib import Path
from typing import Final

from stable_update_state import (
    STABLE_BRANCH,
    STABLE_LEASE,
    Candidate,
    CoordinatorError,
    FakeGitHub,
    RunIdentity,
    cleanup_validation_pair,
    create_validation_pair,
    promote_candidate,
    reconcile_stable,
    reconcile_validation,
    recover_owned,
)

HEX40: Final = re.compile(r"[0-9a-f]{40}")
MODES: Final = {"production", "fixture-noop", "fixture-upgrade", "fixture-failure", "recover-owned"}
RECOVERY_ACTIONS: Final = {"cleanup-merged", "cleanup-closed", "cleanup-orphan"}


class FixtureError(Exception):
    pass


@dataclass(frozen=True, slots=True)
class Scenario:
    release: str
    initial: str
    fault: str


@dataclass(frozen=True, slots=True)
class Transcript:
    scenario: str
    outcome: str
    tested_tip: str
    stable_branch_sha: str
    stable_lease_phase: str
    consumer_legs: int
    pull_requests: int
    validation_refs: int
    validation_leases: int
    unowned_preserved: bool
    mutations: tuple[str, ...]


def validate_dispatch(mode: str, recovery_action: str, observed_lease_sha: str, observed_ref_sha: str, observed_pr_head_sha: str, observed_pr_number: str) -> None:
    if mode not in MODES:
        raise CoordinatorError("mode_invalid")
    values = (recovery_action, observed_lease_sha, observed_ref_sha, observed_pr_head_sha, observed_pr_number)
    if mode != "recover-owned":
        if any(values):
            raise CoordinatorError("recovery_input_forbidden")
        return
    if recovery_action not in RECOVERY_ACTIONS or HEX40.fullmatch(observed_lease_sha) is None:
        raise CoordinatorError("recovery_identity_invalid")
    absent = (observed_ref_sha, observed_pr_head_sha, observed_pr_number) == ("absent", "absent", "absent")
    if recovery_action == "cleanup-orphan" and not absent:
        raise CoordinatorError("recovery_absence_required")
    if recovery_action != "cleanup-orphan" and (
        HEX40.fullmatch(observed_ref_sha) is None
        or HEX40.fullmatch(observed_pr_head_sha) is None
        or not observed_pr_number.isdecimal()
    ):
        raise CoordinatorError("recovery_live_identity_required")


def load_scenario(path: Path, name: str) -> Scenario:
    raw = json.loads(path.read_text(encoding="utf-8"))
    fields = raw.get(name) if isinstance(raw, dict) else None
    if not isinstance(fields, dict):
        raise FixtureError(f"fixture_unknown:{name}")
    return Scenario(str(fields.get("release")), str(fields.get("initial")), str(fields.get("fault")))


def _blocked_fault(fault: str) -> bool:
    return fault in {
        "settings-denied", "auth-denied", "actions-write", "app-permission",
        "stale-unowned", "spoofed-marker", "missing-lease", "mismatched-lease",
        "unowned-branch", "unowned-pr", "orphan-branch", "orphan-pr",
    }


def execute_fixture(name: str, scenario: Scenario) -> Transcript:
    candidate = Candidate.fixture()
    api = FakeGitHub()
    api.runs[candidate.creator_run_id] = RunIdentity(candidate.creator_run_id, "GINNOV/littlethings", ".github/workflows/adflib-update.yml", 42, candidate.workflow_source_sha)
    outcome = "blocked"
    legs = 0
    unowned = _blocked_fault(scenario.fault)
    if scenario.release in {"current", "draft", "prerelease"}:
        outcome = "no-change"
    elif scenario.release == "license-pending" or _blocked_fault(scenario.fault):
        outcome = scenario.fault or "license-review-required"
    else:
        if scenario.initial in {"active", "refresh-leased", "refresh-branch-updated", "refresh-pr-marked", "merged", "closed"}:
            api = FakeGitHub.owned_active()
            api.runs[candidate.creator_run_id] = RunIdentity(candidate.creator_run_id, "GINNOV/littlethings", ".github/workflows/adflib-update.yml", 42, candidate.workflow_source_sha)
        if scenario.initial == "merged":
            api.prs[1] = replace(api.prs[1], state="closed", merged=True)
            outcome = reconcile_stable(api, 42)
        elif scenario.initial == "closed":
            api.prs[1] = replace(api.prs[1], state="closed")
            if scenario.fault == "recover":
                lease = api.get_ref(STABLE_LEASE) or ""
                recover_owned(api, "cleanup-closed", lease, api.get_ref(STABLE_BRANCH), 1, api.prs[1].head_sha, 42)
                outcome = "closed-cleaned"
            else:
                outcome = reconcile_stable(api, 42)
        elif scenario.initial == "orphan-lease":
            api = FakeGitHub.owned_active(); api.refs.pop(STABLE_BRANCH); api.prs.clear()
            lease = api.get_ref(STABLE_LEASE) or ""
            if scenario.fault == "recover":
                recover_owned(api, "cleanup-orphan", lease, None, None, None, 42); outcome = "orphan-lease-cleaned"
            else:
                outcome = reconcile_stable(api, 42)
        else:
            lease_ref, validation_ref = create_validation_pair(api, candidate, 42, "fixture")
            legs = 5
            if scenario.fault in {"matrix", "incompatible", "substitution"}:
                cleanup_validation_pair(api, lease_ref, validation_ref, candidate.tip)
                outcome = "validation-failed"
            else:
                cleanup_validation_pair(api, lease_ref, validation_ref, candidate.tip)
                if scenario.fault in {"lease-conflict", "stable-lease-loss", "invalid-observation"}:
                    outcome = scenario.fault
                else:
                    promote_candidate(api, candidate, 42)
                    outcome = "refreshed" if scenario.initial != "absent" else "promoted"
        reconcile_validation(api, 42)
    lease_sha = api.get_ref(STABLE_LEASE)
    phase = "absent"
    if lease_sha:
        phase = str(json.loads(api.get_lease(lease_sha)).get("phase", "unknown"))
    validation_refs = len(api.list_refs("refs/heads/deps/adflib-validation/"))
    validation_leases = len(api.list_refs("refs/heads/deps/adflib-leases/validation/"))
    return Transcript(name, outcome, candidate.tip, api.get_ref(STABLE_BRANCH) or "", phase, legs, len(api.prs), validation_refs, validation_leases, unowned, tuple(api.events))


def run_fixture(name: str, transcript_path: Path, fixtures: Path) -> int:
    transcript = execute_fixture(name, load_scenario(fixtures, name))
    transcript_path.write_text(json.dumps(asdict(transcript), sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    fixture = commands.add_parser("fixture")
    fixture.add_argument("scenario")
    fixture.add_argument("--transcript", type=Path, required=True)
    fixture.add_argument("--fixtures", type=Path, default=Path(__file__).parent / "tests/fixtures/adflib-update-api.json")
    dispatch = commands.add_parser("validate-dispatch")
    dispatch.add_argument("--mode", required=True)
    dispatch.add_argument("--recovery-action", default="")
    dispatch.add_argument("--observed-lease-sha", default="")
    dispatch.add_argument("--observed-ref-sha", default="")
    dispatch.add_argument("--observed-pr-head-sha", default="")
    dispatch.add_argument("--observed-pr-number", default="")
    arguments = parser.parse_args()
    try:
        if arguments.command == "fixture":
            return run_fixture(arguments.scenario, arguments.transcript, arguments.fixtures)
        validate_dispatch(arguments.mode, arguments.recovery_action, arguments.observed_lease_sha, arguments.observed_ref_sha, arguments.observed_pr_head_sha, arguments.observed_pr_number)
    except (CoordinatorError, FixtureError, OSError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
