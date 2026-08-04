#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 consumer_workflow_contract.py resolve ADFlibDependency.cmake

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from typing import Final

HEX_40: Final = re.compile(r"[0-9a-f]{40}")
HEX_64: Final = re.compile(r"[0-9a-f]{64}")
LOWERCASE_UUID_V4: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")
MANIFEST_LINE: Final = re.compile(r'^set\((ADFLIB_[A-Z0-9_]+) "([^"]+)"\)$')
IDENTITY_KEYS: Final = {
    "ADFLIB_OWNER_REPO": "effective_owner_repo",
    "ADFLIB_VERSION": "effective_version",
    "ADFLIB_TAG": "effective_tag",
    "ADFLIB_COMMIT": "effective_commit",
    "ADFLIB_TREE_SHA": "effective_tree_sha",
    "ADFLIB_ARCHIVE_URL": "effective_url",
    "ADFLIB_TREE_MANIFEST_SHA256": "effective_tree_manifest_sha256",
    "ADFLIB_TRANSPORT_SHA256": "transport_sha256",
}


@dataclass(frozen=True, slots=True)
class ContractError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


def required_environment(name: str) -> str:
    value = os.environ.get(name, "")
    if not value:
        raise ContractError(f"missing_environment:{name}")
    return value


def manifest_identity(path: Path) -> dict[str, str]:
    parsed: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        match = MANIFEST_LINE.fullmatch(line)
        if match is not None and match.group(1) in IDENTITY_KEYS:
            parsed[IDENTITY_KEYS[match.group(1)]] = match.group(2)
    missing = set(IDENTITY_KEYS.values()) - parsed.keys()
    if missing:
        raise ContractError(f"manifest_identity_incomplete:{','.join(sorted(missing))}")
    validate_identity(parsed)
    return parsed


def validate_identity(identity: dict[str, str]) -> None:
    for key in ("effective_commit", "effective_tree_sha"):
        if HEX_40.fullmatch(identity.get(key, "")) is None:
            raise ContractError(f"invalid_identity:{key}")
    for key in ("effective_tree_manifest_sha256", "transport_sha256"):
        if HEX_64.fullmatch(identity.get(key, "")) is None:
            raise ContractError(f"invalid_identity:{key}")
    if identity["effective_commit"] not in identity["effective_url"]:
        raise ContractError("commit_addressed_url_required")


def route_candidate() -> tuple[str, bool, str]:
    event_name = required_environment("EVENT_NAME")
    event_sha = required_environment("EVENT_SHA")
    if HEX_40.fullmatch(event_sha) is None:
        raise ContractError("candidate_sha_invalid")
    if event_name == "pull_request_target":
        if required_environment("PR_HEAD_REPOSITORY") != required_environment("EVENT_REPOSITORY"):
            raise ContractError("fork_pr_rejected")
        candidate_sha = required_environment("PR_HEAD_SHA")
        if HEX_40.fullmatch(candidate_sha) is None:
            raise ContractError("candidate_sha_invalid")
        return candidate_sha, True, "ref"
    if event_name in {"push", "workflow_dispatch"}:
        fixture = os.environ.get("FIXTURE", "") or "none"
        if fixture not in {"none", "repository-mismatch"}:
            raise ContractError("fixture_invalid")
        if fixture != "none":
            trusted_sha = required_environment("TRUSTED_SHA")
            workflow_ref = required_environment("WORKFLOW_REF")
            if event_name != "workflow_dispatch" or event_sha != trusted_sha or not workflow_ref.endswith(f"@{trusted_sha}"):
                raise ContractError("non_default_fixture_ref")
            raise ContractError("repository_mismatch_fixture")
        return event_sha, True, "ref"
    if event_name == "workflow_call":
        candidate_ref = os.environ.get("CANDIDATE_REF", "")
        bundle = os.environ.get("CANDIDATE_BUNDLE_ARTIFACT", "")
        if bool(candidate_ref) == bool(bundle):
            raise ContractError("exactly_one_candidate_transport_required")
        if candidate_ref:
            if HEX_40.fullmatch(candidate_ref) is None:
                raise ContractError("immutable_candidate_ref_required")
            return candidate_ref, os.environ.get("CHANNEL") != "canary", "ref"
        candidate_commit = required_environment("CANDIDATE_BUNDLE_COMMIT")
        if HEX_40.fullmatch(candidate_commit) is None:
            raise ContractError("bundle_candidate_commit_invalid")
        if not required_environment("CANDIDATE_BUNDLE_RUN_ID").isdigit():
            raise ContractError("bundle_run_id_invalid")
        if not required_environment("CANDIDATE_BUNDLE_ARTIFACT_ID").isdigit():
            raise ContractError("bundle_artifact_id_invalid")
        if HEX_64.fullmatch(required_environment("CANDIDATE_BUNDLE_SHA256")) is None:
            raise ContractError("bundle_digest_invalid")
        return candidate_commit, False, "bundle"
    raise ContractError("event_rejected")


def reusable_identity() -> dict[str, str]:
    identity = {
        key.lower(): required_environment(key)
        for key in (
            "EFFECTIVE_OWNER_REPO",
            "EFFECTIVE_VERSION",
            "EFFECTIVE_TAG",
            "EFFECTIVE_COMMIT",
            "EFFECTIVE_TREE_SHA",
            "EFFECTIVE_URL",
            "EFFECTIVE_TREE_MANIFEST_SHA256",
            "TRANSPORT_SHA256",
        )
    }
    validate_identity(identity)
    return identity


def validated_compatibility_fixture(event_name: str, channel: str, transport: str) -> str:
    compatibility_fixture = os.environ.get("COMPATIBILITY_FIXTURE", "") or "none"
    if compatibility_fixture not in {"none", "incompatible-master"}:
        raise ContractError("compatibility_fixture_invalid")
    if compatibility_fixture != "none":
        trusted_sha = required_environment("TRUSTED_SHA")
        if event_name != "workflow_call" or channel != "canary":
            raise ContractError("compatibility_fixture_canary_bundle_required")
        if not required_environment("WORKFLOW_REF").endswith(f"@{trusted_sha}"):
            raise ContractError("compatibility_fixture_trusted_caller_required")
        if transport == "ref" and required_environment("CANDIDATE_REF") != trusted_sha:
            raise ContractError("compatibility_fixture_ref_identity_mismatch")
    return compatibility_fixture


def write_outputs(path: Path, values: dict[str, str]) -> None:
    with path.open("a", encoding="utf-8") as output:
        for key, value in values.items():
            if "\n" in value or "\r" in value:
                raise ContractError(f"command_file_value_rejected:{key}")
            output.write(f"{key}={value}\n")


def resolve(manifest: Path) -> None:
    candidate_sha, upload_default, transport = route_candidate()
    event_name = required_environment("EVENT_NAME")
    identity = reusable_identity() if event_name == "workflow_call" else manifest_identity(manifest)
    channel = required_environment("CHANNEL") if event_name == "workflow_call" else "stable"
    if channel not in {"stable", "canary"}:
        raise ContractError("channel_invalid")
    compatibility_fixture = validated_compatibility_fixture(event_name, channel, transport)
    verification_nonce = required_environment("VERIFICATION_NONCE") if event_name == "workflow_call" else ""
    if verification_nonce and LOWERCASE_UUID_V4.fullmatch(verification_nonce) is None:
        raise ContractError("verification_nonce_invalid")
    upload = upload_default
    if event_name == "workflow_call" and channel != "canary":
        upload = required_environment("UPLOAD_FAILURE_LOGS").lower() == "true"
    values = {
        "candidate_sha": candidate_sha,
        "candidate_transport": transport,
        "channel": channel,
        **identity,
        "upload_failure_logs": str(upload).lower(),
        "identity_json": json.dumps(identity, sort_keys=True, separators=(",", ":")),
        "verification_nonce": verification_nonce,
        "compatibility_fixture": compatibility_fixture,
    }
    write_outputs(Path(required_environment("OUTPUT_FILE")), values)


def route() -> None:
    candidate_sha, upload, transport = route_candidate()
    event_name = required_environment("EVENT_NAME")
    channel = required_environment("CHANNEL") if event_name == "workflow_call" else "stable"
    compatibility_fixture = validated_compatibility_fixture(event_name, channel, transport)
    write_outputs(
        Path(required_environment("OUTPUT_FILE")),
        {
            "candidate_sha": candidate_sha,
            "candidate_transport": transport,
            "compatibility_fixture": compatibility_fixture,
            "upload_failure_logs": str(upload).lower(),
        },
    )


def verify_artifact_metadata(path: Path) -> None:
    payload = json.loads(path.read_text(encoding="utf-8"))
    artifacts = payload.get("artifacts") if isinstance(payload, dict) else None
    if not isinstance(artifacts, list):
        raise ContractError("artifact_metadata_invalid")
    expected_id = int(required_environment("CANDIDATE_BUNDLE_ARTIFACT_ID"))
    expected_name = required_environment("CANDIDATE_BUNDLE_ARTIFACT")
    matches = [
        artifact
        for artifact in artifacts
        if isinstance(artifact, dict)
        and artifact.get("id") == expected_id
        and artifact.get("name") == expected_name
        and artifact.get("expired") is False
    ]
    if len(matches) != 1:
        raise ContractError(f"bundle_artifact_metadata_match_count:{len(matches)}")


def write_canary_manifest(source: Path, destination: Path) -> None:
    stable = manifest_identity(source)
    patch_match = re.search(r'^set\(ADFLIB_PATCH_SHA256 "([0-9a-f]{64})"\)$', source.read_text(encoding="utf-8"), re.MULTILINE)
    if patch_match is None:
        raise ContractError("trusted_patch_identity_missing")
    expected = expected_bundle_identity()
    if expected["channel"] != "canary":
        raise ContractError("canary_manifest_channel_required")
    if expected["owner_repo"] != stable["effective_owner_repo"]:
        raise ContractError("canary_owner_repo_mismatch")
    source_text = source.read_text(encoding="utf-8")
    allowlist_match = re.search(r'^set\(ADFLIB_SYMLINK_ALLOWLIST "([^"]*)"\)$', source_text, re.MULTILINE)
    if allowlist_match is None:
        raise ContractError("trusted_symlink_allowlist_missing")
    destination.write_text(
        "\n".join(
            (
                'set(ADFLIB_CHANNEL "canary")',
                f'set(ADFLIB_OWNER_REPO "{expected["owner_repo"]}")',
                f'set(ADFLIB_VERSION "{expected["version"]}")',
                f'set(ADFLIB_TAG "{expected["tag"]}")',
                f'set(ADFLIB_COMMIT "{expected["commit"]}")',
                f'set(ADFLIB_TREE_SHA "{expected["tree_sha"]}")',
                f'set(ADFLIB_ARCHIVE_URL "{expected["url"]}")',
                f'set(ADFLIB_TREE_MANIFEST_SHA256 "{expected["tree_manifest_sha256"]}")',
                f'set(ADFLIB_PATCH_SHA256 "{patch_match.group(1)}")',
                f'set(ADFLIB_EXPECTED_TRANSPORT_SHA256 "{expected["transport_sha256"]}")',
                f'set(ADFLIB_SYMLINK_ALLOWLIST_COMMIT "{expected["commit"]}")',
                f'set(ADFLIB_SYMLINK_ALLOWLIST_TREE_SHA "{expected["tree_sha"]}")',
                f'set(ADFLIB_SYMLINK_ALLOWLIST "{allowlist_match.group(1)}")',
                "",
            )
        ),
        encoding="utf-8",
    )


def compatibility_preflight() -> None:
    channel = required_environment("EFFECTIVE_CHANNEL")
    fixture = required_environment("ADFLIB_COMPATIBILITY_FIXTURE")
    if fixture == "none":
        return
    if fixture == "incompatible-master" and channel == "canary":
        raise ContractError("adflib_compatibility_fixture: incompatible-master")
    raise ContractError("compatibility_fixture_rejected")


def scrub_check() -> None:
    forbidden = ("GH_TOKEN", "GITHUB_TOKEN", "ACTIONS_RUNTIME_TOKEN", "ADFLIB_SETTINGS_READ_TOKEN")
    leaked = [name for name in forbidden if os.environ.get(name)]
    if leaked:
        raise ContractError(f"credential_environment_not_scrubbed:{','.join(leaked)}")


def compare_builder(path: Path) -> None:
    observed = json.loads(path.read_text(encoding="utf-8"))
    expected = {
        "channel": required_environment("EXPECTED_CHANNEL"),
        "owner_repo": required_environment("EXPECTED_OWNER_REPO"),
        "version": required_environment("EXPECTED_VERSION"),
        "tag": required_environment("EXPECTED_TAG"),
        "commit": required_environment("EXPECTED_COMMIT"),
        "tree_sha": required_environment("EXPECTED_TREE_SHA"),
        "url": required_environment("EXPECTED_URL"),
        "tree_manifest_sha256": required_environment("EXPECTED_TREE_MANIFEST_SHA256"),
    }
    if observed != expected:
        raise ContractError("builder_identity_mismatch")


def expected_bundle_identity() -> dict[str, str]:
    return {
        "channel": required_environment("EXPECTED_CHANNEL"),
        "owner_repo": required_environment("EXPECTED_OWNER_REPO"),
        "version": required_environment("EXPECTED_VERSION"),
        "tag": required_environment("EXPECTED_TAG"),
        "commit": required_environment("EXPECTED_COMMIT"),
        "tree_sha": required_environment("EXPECTED_TREE_SHA"),
        "url": required_environment("EXPECTED_URL"),
        "tree_manifest_sha256": required_environment("EXPECTED_TREE_MANIFEST_SHA256"),
        "transport_sha256": required_environment("EXPECTED_TRANSPORT_SHA256"),
    }


def materialize_bundle(artifact: Path, destination: Path) -> None:
    expected_files = {"bundle.sha256", "candidate-identity.json", "candidate.bundle"}
    observed_files = {path.name for path in artifact.iterdir() if path.is_file() and not path.is_symlink()}
    if observed_files != expected_files or len(list(artifact.iterdir())) != len(expected_files):
        raise ContractError("bundle_artifact_file_set_mismatch")
    bundle = artifact / "candidate.bundle"
    digest = hashlib.sha256(bundle.read_bytes()).hexdigest()
    expected_digest = required_environment("EXPECTED_BUNDLE_SHA256")
    if HEX_64.fullmatch(expected_digest) is None or digest != expected_digest:
        raise ContractError("bundle_digest_mismatch")
    if (artifact / "bundle.sha256").read_text(encoding="utf-8") != f"{digest}  candidate.bundle\n":
        raise ContractError("bundle_digest_record_mismatch")
    candidate_commit = required_environment("EXPECTED_CANDIDATE_COMMIT")
    if HEX_40.fullmatch(candidate_commit) is None:
        raise ContractError("bundle_candidate_commit_invalid")
    identity = json.loads((artifact / "candidate-identity.json").read_text(encoding="utf-8"))
    expected_identity = {
        "bundle_sha256": digest,
        "candidate_commit": candidate_commit,
        "canonical_identity": expected_bundle_identity(),
        "schema": "adflib-consumer-bundle/v1",
    }
    if identity != expected_identity:
        raise ContractError("bundle_artifact_identity_mismatch")
    git_environment = {
        "GIT_CONFIG_NOSYSTEM": "1",
        "HOME": str(artifact),
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
    }
    with tempfile.TemporaryDirectory(prefix="bundle-verify-") as verify_root:
        subprocess.run(["git", "init", "--bare", "-q", verify_root], env=git_environment, check=True)
        verify = subprocess.run(
            ["git", "-C", verify_root, "bundle", "verify", str(bundle)],
            env=git_environment,
            check=False,
            capture_output=True,
            text=True,
        )
    if verify.returncode != 0:
        raise ContractError("git_bundle_verify_failed")
    heads = subprocess.run(
        ["git", "bundle", "list-heads", str(bundle)],
        cwd=artifact,
        env=git_environment,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.splitlines()
    if len(heads) != 1 or not heads[0].startswith(f"{candidate_commit} "):
        raise ContractError("bundle_declared_commit_mismatch")
    clone = subprocess.run(
        ["git", "clone", "--no-checkout", "--no-local", str(bundle), str(destination)],
        env=git_environment,
        check=False,
        capture_output=True,
        text=True,
    )
    if clone.returncode != 0:
        raise ContractError("bundle_clone_failed")
    checkout = subprocess.run(
        ["git", "-C", str(destination), "-c", "core.hooksPath=/dev/null", "checkout", "--detach", "--force", candidate_commit],
        env=git_environment,
        check=False,
        capture_output=True,
        text=True,
    )
    if checkout.returncode != 0:
        raise ContractError("bundle_checkout_failed")
    resolved = subprocess.run(
        ["git", "-C", str(destination), "rev-parse", "HEAD"],
        env=git_environment,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if resolved != candidate_commit:
        raise ContractError("bundle_checkout_commit_mismatch")
    write_outputs(Path(required_environment("OUTPUT_FILE")), {"candidate_sha": resolved})


def main() -> int:
    parser = argparse.ArgumentParser()
    subcommands = parser.add_subparsers(dest="command", required=True)
    resolve_parser = subcommands.add_parser("resolve")
    resolve_parser.add_argument("manifest", type=Path)
    compare_parser = subcommands.add_parser("compare-builder")
    compare_parser.add_argument("identity", type=Path)
    bundle_parser = subcommands.add_parser("materialize-bundle")
    bundle_parser.add_argument("artifact", type=Path)
    bundle_parser.add_argument("destination", type=Path)
    metadata_parser = subcommands.add_parser("verify-artifact-metadata")
    metadata_parser.add_argument("metadata", type=Path)
    canary_parser = subcommands.add_parser("write-canary-manifest")
    canary_parser.add_argument("source", type=Path)
    canary_parser.add_argument("destination", type=Path)
    subcommands.add_parser("compatibility-preflight")
    subcommands.add_parser("route")
    subcommands.add_parser("scrub-check")
    arguments = parser.parse_args()
    try:
        match arguments.command:
            case "resolve":
                resolve(arguments.manifest)
            case "route":
                route()
            case "compare-builder":
                compare_builder(arguments.identity)
            case "materialize-bundle":
                materialize_bundle(arguments.artifact, arguments.destination)
            case "verify-artifact-metadata":
                verify_artifact_metadata(arguments.metadata)
            case "write-canary-manifest":
                write_canary_manifest(arguments.source, arguments.destination)
            case "compatibility-preflight":
                compatibility_preflight()
            case "scrub-check":
                scrub_check()
    except (ContractError, OSError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
