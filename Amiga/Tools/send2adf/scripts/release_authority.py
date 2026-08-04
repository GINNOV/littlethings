#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/scripts/release_authority.py authorize <authority.json>

from __future__ import annotations

import argparse
import json
import re
import socket
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final, Literal, TypeAlias

if __package__:
    from .release_github import ReleaseGitHubError, settings
    from .release_transaction import TransactionError
else:
    from release_github import ReleaseGitHubError, settings
    from release_transaction import TransactionError

HEX_40: Final = re.compile(r"^[0-9a-f]{40}$")
HEX_64: Final = re.compile(r"^[0-9a-f]{64}$")
TAG: Final = re.compile(r"^send2adf-v([0-9]+\.[0-9]+\.[0-9]+)$")
Mode: TypeAlias = Literal["validate", "publish", "recover-owned"]
JsonValue: TypeAlias = str | int | bool | None | list["JsonValue"] | dict[str, "JsonValue"]


@dataclass(frozen=True, slots=True)
class AuthorityError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def require_string(payload: dict[str, JsonValue], field: str) -> str:
    value = payload.get(field)
    if not isinstance(value, str) or not value:
        raise AuthorityError(f"invalid authority field: {field}")
    return value


def require_bool(payload: dict[str, JsonValue], field: str) -> bool:
    value = payload.get(field)
    if not isinstance(value, bool):
        raise AuthorityError(f"invalid authority field: {field}")
    return value


def authorize(payload: dict[str, JsonValue]) -> None:
    mode = require_string(payload, "mode")
    if mode not in {"validate", "publish", "recover-owned"}:
        raise AuthorityError("invalid release mode")
    tag = require_string(payload, "tag")
    matched_tag = TAG.fullmatch(tag)
    expected_sha = require_string(payload, "expected_sha")
    if matched_tag is None or HEX_40.fullmatch(expected_sha) is None:
        raise AuthorityError("noncanonical release identity")
    if matched_tag.group(1) != require_string(payload, "cmake_version"):
        raise AuthorityError("tag version does not match CMake project")
    recovery_fields = {"observed_lease_sha", "observed_release_id", "observed_inventory_sha256"}
    present_recovery = recovery_fields.intersection(payload)
    if mode == "recover-owned":
        if present_recovery != recovery_fields:
            raise AuthorityError("recovery observation is incomplete")
        lease_sha = require_string(payload, "observed_lease_sha")
        release_id = payload.get("observed_release_id")
        inventory = payload.get("observed_inventory_sha256")
        if HEX_40.fullmatch(lease_sha) is None:
            raise AuthorityError("invalid recovery lease SHA")
        if release_id != "absent" and (not isinstance(release_id, int) or isinstance(release_id, bool) or release_id <= 0):
            raise AuthorityError("invalid recovery release ID")
        if inventory != "absent" and (not isinstance(inventory, str) or HEX_64.fullmatch(inventory) is None):
            raise AuthorityError("invalid recovery inventory")
    elif present_recovery:
        raise AuthorityError("recovery-only fields are forbidden")
    for field in ("environment_approved", "tag_ruleset_enforced", "checks_verified", "tree_clean", "tests_passed", "license_approved"):
        if not require_bool(payload, field):
            raise AuthorityError(f"release authority denied: {field}")
    if require_bool(payload, "adflib_canary"):
        raise AuthorityError("canary release denied")
    check_app = payload.get("check_app_id")
    if not isinstance(check_app, int) or isinstance(check_app, bool) or check_app != payload.get("expected_check_app_id"):
        raise AuthorityError("required checks have wrong App identity")
    tag_sha = require_string(payload, "tag_sha")
    tag_kind = require_string(payload, "tag_kind")
    if tag_kind not in {"commit", "annotated"} or tag_sha != expected_sha:
        raise AuthorityError("tag target mismatch")
    if mode == "validate":
        if require_string(payload, "workflow_sha") != expected_sha or require_string(payload, "ref_sha") != expected_sha:
            raise AuthorityError("validation workflow identity mismatch")
    elif mode == "publish" and (require_string(payload, "ref") != "refs/heads/master" or require_string(payload, "master_sha") != expected_sha):
        raise AuthorityError("publication is not bound to current master")


def socket_token(socket_path: str) -> str:
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(socket_path)
        connection.sendall(b"password\n")
        token = connection.recv(16384).decode()
    if not token:
        raise AuthorityError("release App token is absent")
    return token


def publish_release(arguments: argparse.Namespace) -> None:
    from Tools.send2adf.scripts.release_api import GitHubReleaseApi
    from Tools.send2adf.scripts.release_transaction import (
        RecoveryObservation,
        ReleaseIdentity,
        execute_release,
    )

    token = socket_token(arguments.socket)
    identity = ReleaseIdentity(
        arguments.repository, arguments.workflow, int(arguments.run_id), arguments.tag,
        arguments.target_sha, int(arguments.app_id),
    )
    observation = None
    if arguments.mode == "recover-owned":
        release_id = None if arguments.observed_release_id == "absent" else int(arguments.observed_release_id)
        inventory = None if arguments.observed_inventory_sha256 == "absent" else arguments.observed_inventory_sha256
        observation = RecoveryObservation(arguments.observed_lease_sha, release_id, inventory)
    files = {path.name: path.read_bytes() for path in arguments.directory.iterdir() if path.is_file()}
    result = execute_release(GitHubReleaseApi(arguments.repository, token), identity, arguments.mode, files, observation)
    print(f"release_transaction:{result}")


def main() -> int:
    from Tools.send2adf.scripts.release_simulation import SimulationError, simulate

    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    authorize_parser = commands.add_parser("authorize")
    authorize_parser.add_argument("input")
    simulate_parser = commands.add_parser("simulate")
    simulate_parser.add_argument("name")
    settings_parser = commands.add_parser("settings")
    settings_parser.add_argument("environment", type=Path)
    settings_parser.add_argument("rulesets", type=Path)
    settings_parser.add_argument("team")
    publish_parser = commands.add_parser("publish")
    publish_parser.add_argument("directory", type=Path)
    for name in ("repository", "workflow", "socket", "tag", "target-sha", "app-id", "run-id", "mode", "observed-lease-sha", "observed-release-id", "observed-inventory-sha256"):
        publish_parser.add_argument(f"--{name}", required=True)
    arguments = parser.parse_args()
    try:
        if arguments.command == "authorize":
            value: JsonValue = json.loads(Path(arguments.input).read_text(encoding="utf-8"))
            if not isinstance(value, dict):
                raise AuthorityError("authority input must be an object")
            authorize(value)
            print("release_authorized")
        elif arguments.command == "simulate":
            print(simulate(arguments.name))
        elif arguments.command == "settings":
            settings(arguments.environment, arguments.rulesets, arguments.team)
        else:
            publish_release(arguments)
    except (AuthorityError, ReleaseGitHubError, SimulationError, TransactionError, json.JSONDecodeError, OSError, ValueError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
