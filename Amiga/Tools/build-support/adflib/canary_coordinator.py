#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# EVENT_NAME=schedule OUTPUT_FILE=/tmp/canary-output python3 canary_coordinator.py authorize

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Final, TypeAlias, assert_never

HEX_40: Final = re.compile(r"[0-9a-f]{40}")
UUID_V4: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")
FIXTURES: Final = {"none", "incompatible-master", "environment-denial"}
JsonScalar: TypeAlias = str | int | float | bool | None
JsonValue: TypeAlias = JsonScalar | list["JsonValue"] | dict[str, "JsonValue"]


@dataclass(frozen=True, slots=True)
class CoordinatorError(Exception):
    code: str
    detail: str = ""

    def __str__(self) -> str:
        return f"{self.code}:{self.detail}" if self.detail else self.code


def required_environment(name: str) -> str:
    value = os.environ.get(name, "")
    if not value:
        raise CoordinatorError("missing_environment", name)
    return value


def write_outputs(values: dict[str, str]) -> None:
    path = Path(required_environment("OUTPUT_FILE"))
    with path.open("a", encoding="utf-8") as output:
        for key, value in values.items():
            if "\n" in value or "\r" in value:
                raise CoordinatorError("command_file_value_rejected", key)
            output.write(f"{key}={value}\n")


def authorize() -> None:
    event_name = required_environment("EVENT_NAME")
    if event_name not in {"schedule", "workflow_dispatch"}:
        raise CoordinatorError("event_rejected", event_name)
    match event_name:
        case "schedule":
            fixture = "none"
            nonce = str(uuid.uuid4())
        case "workflow_dispatch":
            fixture = required_environment("FIXTURE")
            nonce = required_environment("VERIFICATION_NONCE")
            event_sha = required_environment("EVENT_SHA")
            trusted_sha = required_environment("TRUSTED_SHA")
            workflow_ref = required_environment("WORKFLOW_REF")
            workflow_sha = required_environment("WORKFLOW_SHA")
            if (
                HEX_40.fullmatch(event_sha) is None
                or event_sha != trusted_sha
                or workflow_sha != trusted_sha
                or "/.github/workflows/adflib-canary.yml@" not in workflow_ref
            ):
                raise CoordinatorError("non_default_fixture_ref")
        case unreachable:
            assert_never(unreachable)
    if fixture not in FIXTURES:
        raise CoordinatorError("fixture_invalid", fixture)
    if UUID_V4.fullmatch(nonce) is None:
        raise CoordinatorError("verification_nonce_invalid")
    compatibility_fixture = "incompatible-master" if fixture == "incompatible-master" else "none"
    write_outputs({"fixture": fixture, "compatibility_fixture": compatibility_fixture, "verification_nonce": nonce})


def load_object(path: Path, code: str) -> dict[str, JsonValue]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        raise CoordinatorError(code, str(error)) from error
    if not isinstance(payload, dict):
        raise CoordinatorError(code, "expected object")
    return payload


def preflight(arguments: argparse.Namespace) -> None:
    repository = load_object(arguments.repository, "repository_settings_invalid")
    environment = load_object(arguments.environment, "environment_settings_invalid")
    actions = load_object(arguments.actions, "actions_settings_invalid")
    variable = load_object(arguments.variable, "approver_variable_invalid")
    if repository.get("default_branch") != "master":
        raise CoordinatorError("default_branch_mismatch")
    if environment.get("name") != "adflib-verification":
        raise CoordinatorError("environment_name_mismatch")
    protection_rules = environment.get("protection_rules")
    expected_team = required_environment("EXPECTED_APPROVER_TEAM")
    if variable.get("name") != "ADFLIB_AUTOMATION_APPROVER_TEAM" or variable.get("value") != expected_team:
        raise CoordinatorError("approver_variable_mismatch")
    reviewer_rules = []
    if isinstance(protection_rules, list):
        reviewer_rules = [rule for rule in protection_rules if isinstance(rule, dict) and rule.get("type") == "required_reviewers"]
    reviewers = reviewer_rules[0].get("reviewers") if len(reviewer_rules) == 1 else None
    expected_reviewer = {"type": "Team", "reviewer": {"slug": expected_team}}
    observed_reviewers = []
    if isinstance(reviewers, list):
        observed_reviewers = [
            {"type": reviewer.get("type"), "reviewer": {"slug": nested.get("slug")}}
            for reviewer in reviewers
            if isinstance(reviewer, dict) and isinstance((nested := reviewer.get("reviewer")), dict)
        ]
    if observed_reviewers != [expected_reviewer]:
        raise CoordinatorError("approver_team_mismatch")
    if actions.get("default_workflow_permissions") != "read" or actions.get("can_approve_pull_request_reviews") is not False:
        raise CoordinatorError("actions_token_policy_mismatch")
    print("canary_preflight_verified")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    subcommands = result.add_subparsers(dest="command", required=True)
    subcommands.add_parser("authorize")
    preflight_parser = subcommands.add_parser("preflight")
    preflight_parser.add_argument("--repository", type=Path, required=True)
    preflight_parser.add_argument("--environment", type=Path, required=True)
    preflight_parser.add_argument("--actions", type=Path, required=True)
    preflight_parser.add_argument("--variable", type=Path, required=True)
    return result


def main() -> int:
    try:
        arguments = parser().parse_args()
        match arguments.command:
            case "authorize":
                authorize()
            case "preflight":
                preflight(arguments)
            case unreachable:
                assert_never(unreachable)
    except (CoordinatorError, OSError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
