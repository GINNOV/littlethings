#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 canary_resolver.py resolve --artifacts /tmp/adflib-canary --output /tmp/canary-output

from __future__ import annotations

import argparse
import base64
import binascii
import hashlib
import json
import re
import shutil
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final, TypeAlias, assert_never

from stage_adflib import (
    RedirectContract,
    StageError,
    SymlinkPolicy,
    download,
    git_object_sha,
    parse_tree_response,
    safe_extract,
    sha256_file,
    verify_commit_response,
    verify_materialized_source,
    verify_tree_manifest_digest,
)

HEX_40: Final = re.compile(r"[0-9a-f]{40}")
OWNER_REPO: Final = "adflib/ADFlib"
JsonScalar: TypeAlias = str | int | float | bool | None
JsonValue: TypeAlias = JsonScalar | list["JsonValue"] | dict[str, "JsonValue"]


@dataclass(frozen=True, slots=True)
class CanaryError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


def decode_object(path: Path, code: str) -> dict[str, JsonValue]:
    try:
        payload = json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        raise CanaryError(code, str(error)) from error
    if not isinstance(payload, dict):
        raise CanaryError(code, "expected object")
    return payload


def resolve_branch(api_base: str, destination: Path) -> str:
    download(f"{api_base.rstrip('/')}/repos/{OWNER_REPO}/branches/master", destination)
    payload = decode_object(destination, "branch_response_invalid")
    commit = payload.get("commit")
    if payload.get("name") != "master" or not isinstance(commit, dict):
        raise CanaryError("branch_response_invalid", "master branch fields differ")
    sha = commit.get("sha")
    if not isinstance(sha, str) or HEX_40.fullmatch(sha) is None:
        raise CanaryError("branch_response_invalid", "commit SHA must be lowercase 40-hex")
    return sha


def commit_tree(path: Path, commit: str) -> str:
    payload = decode_object(path, "commit_response_invalid")
    tree = payload.get("tree")
    tree_sha = tree.get("sha") if isinstance(tree, dict) else None
    if not isinstance(tree_sha, str) or HEX_40.fullmatch(tree_sha) is None:
        raise CanaryError("commit_response_invalid", "tree SHA must be lowercase 40-hex")
    verify_commit_response(path, commit, tree_sha)
    return tree_sha


def symlink_policies(api_base: str, tree_response: Path, artifacts: Path) -> dict[str, SymlinkPolicy]:
    payload = decode_object(tree_response, "tree_response_invalid")
    raw_entries = payload.get("tree")
    if not isinstance(raw_entries, list):
        raise CanaryError("tree_response_invalid", "tree must be an array")
    regular_targets: dict[str, str] = {}
    links: list[tuple[str, str]] = []
    for raw_entry in raw_entries:
        if not isinstance(raw_entry, dict):
            raise CanaryError("tree_response_invalid", "entry must be an object")
        path = raw_entry.get("path")
        mode = raw_entry.get("mode")
        kind = raw_entry.get("type")
        sha = raw_entry.get("sha")
        if not all(isinstance(value, str) for value in (path, mode, kind, sha)):
            raise CanaryError("tree_response_invalid", "entry fields must be strings")
        if mode in {"100644", "100755"} and kind == "blob":
            regular_targets[path] = sha
        if mode == "120000" and kind == "blob":
            links.append((path, sha))
    policies: dict[str, SymlinkPolicy] = {}
    for path, blob_sha in links:
        blob_response = artifacts / f"symlink-{blob_sha}.json"
        download(f"{api_base.rstrip('/')}/repos/{OWNER_REPO}/git/blobs/{blob_sha}", blob_response)
        blob = decode_object(blob_response, "symlink_blob_invalid")
        encoded = blob.get("content")
        if blob.get("sha") != blob_sha or blob.get("encoding") != "base64" or not isinstance(encoded, str):
            raise CanaryError("symlink_blob_invalid", path)
        try:
            content = base64.b64decode(encoded.replace("\n", ""), validate=True)
            target = content.decode("utf-8")
        except (binascii.Error, UnicodeDecodeError) as error:
            raise CanaryError("symlink_blob_invalid", path) from error
        if git_object_sha("blob", content) != blob_sha:
            raise CanaryError("symlink_blob_digest_mismatch", path)
        normalized = PurePosixPath(target)
        if normalized.is_absolute() or ".." in normalized.parts or not normalized.parts or str(normalized) != target:
            raise CanaryError("symlink_target_rejected", path)
        target_sha = regular_targets.get(target)
        if target_sha is None:
            raise CanaryError("symlink_target_missing", target)
        policies[path] = SymlinkPolicy(path, "120000", blob_sha, target, target_sha)
    return policies


def write_outputs(path: Path, values: dict[str, str]) -> None:
    with path.open("a", encoding="utf-8") as output:
        for key, value in values.items():
            if "\n" in value or "\r" in value:
                raise CanaryError("command_file_value_rejected", key)
            output.write(f"{key}={value}\n")


def resolve(arguments: argparse.Namespace) -> None:
    artifacts: Path = arguments.artifacts
    artifacts.mkdir(parents=True, exist_ok=False)
    branch_response = artifacts / "master-branch.json"
    commit = resolve_branch(arguments.api_base, branch_response)
    commit_response = artifacts / "commit.json"
    download(f"{arguments.api_base.rstrip('/')}/repos/{OWNER_REPO}/git/commits/{commit}", commit_response)
    tree_sha = commit_tree(commit_response, commit)
    tree_response = artifacts / "tree.json"
    download(f"{arguments.api_base.rstrip('/')}/repos/{OWNER_REPO}/git/trees/{tree_sha}?recursive=1", tree_response)
    policies = symlink_policies(arguments.api_base, tree_response, artifacts)
    entries = parse_tree_response(tree_response, tree_sha, policies)
    canonical_rows = b"".join(entry.row() for entry in sorted(entries, key=lambda entry: entry.row()))
    tree_manifest_sha256 = hashlib.sha256(canonical_rows).hexdigest()
    verify_tree_manifest_digest(entries, tree_manifest_sha256)
    identity_url = f"https://github.com/{OWNER_REPO}/archive/{commit}.tar.gz"
    archive = artifacts / "transport.tar.gz"
    requested_archive = f"{arguments.archive_base.rstrip('/')}/{commit}.tar.gz"
    if arguments.archive_base == f"https://github.com/{OWNER_REPO}/archive":
        transport_url = f"https://codeload.github.com/{OWNER_REPO}/tar.gz/{commit}"
        download(requested_archive, archive, RedirectContract(requested_archive, transport_url))
    else:
        transport_url = download(requested_archive, archive)
    source = Path(tempfile.mkdtemp(prefix="canary-source-", dir=artifacts))
    try:
        safe_extract(archive, source, commit, policies)
        verify_materialized_source(source, entries, policies)
    finally:
        shutil.rmtree(source)
    identity = {
        "channel": "canary",
        "owner_repo": OWNER_REPO,
        "version": "0.0.0-canary",
        "tag": "master",
        "commit": commit,
        "tree_sha": tree_sha,
        "url": identity_url,
        "tree_manifest_sha256": tree_manifest_sha256,
    }
    transport_sha256 = sha256_file(archive)
    (artifacts / "canary-identity.json").write_text(json.dumps(identity, separators=(",", ":")) + "\n", encoding="utf-8")
    (artifacts / "canary-transport.json").write_text(
        json.dumps({"transport_url": transport_url, "transport_sha256": transport_sha256}, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    outputs = {f"effective_{key}": value for key, value in identity.items() if key != "channel"}
    outputs.update({"channel": "canary", "transport_sha256": transport_sha256})
    write_outputs(arguments.output, outputs)


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    subcommands = result.add_subparsers(dest="command", required=True)
    resolve_parser = subcommands.add_parser("resolve")
    resolve_parser.add_argument("--api-base", default="https://api.github.com")
    resolve_parser.add_argument("--archive-base", default=f"https://github.com/{OWNER_REPO}/archive")
    resolve_parser.add_argument("--artifacts", type=Path, required=True)
    resolve_parser.add_argument("--output", type=Path, required=True)
    return result


def main() -> int:
    try:
        arguments = parser().parse_args()
        match arguments.command:
            case "resolve":
                resolve(arguments)
            case unreachable:
                assert_never(unreachable)
    except (CanaryError, StageError, OSError) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
