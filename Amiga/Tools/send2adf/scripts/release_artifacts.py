#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/scripts/release_artifacts.py --help

from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
import re
import sys
import zipfile
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Final

if __package__:
    from .release_github import ReleaseGitHubError, github_bytes, github_request
else:
    from release_github import ReleaseGitHubError, github_bytes, github_request

HEX: Final = re.compile(r"^[0-9a-f]{64}$")
SERVICE_DIGEST: Final = re.compile(r"^sha256:[0-9a-f]{64}$")
KINDS: Final = ("source", "macos-arm64", "macos-x86_64", "linux-x86_64")


@dataclass(frozen=True, slots=True)
class ArtifactReceipt:
    kind: str
    artifact_id: int
    artifact_name: str
    service_digest: str
    archive_sha256: str
    filename: str
    target_sha: str
    producer_run_id: int
    producer_job: str


@dataclass(frozen=True, slots=True)
class ReceiptError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def canonical_receipts(receipts: tuple[ArtifactReceipt, ...]) -> bytes:
    values = [asdict(item) for item in sorted(receipts, key=lambda item: item.kind)]
    return json.dumps(values, sort_keys=True, separators=(",", ":")).encode()


def parse_receipt(value: object) -> ArtifactReceipt:
    if not isinstance(value, dict):
        raise ReceiptError("artifact receipt is not an object")
    kind = value.get("kind"); artifact_id = value.get("artifact_id")
    artifact_name = value.get("artifact_name"); service_digest = value.get("service_digest")
    archive_sha256 = value.get("archive_sha256"); filename = value.get("filename")
    target_sha = value.get("target_sha"); producer_run_id = value.get("producer_run_id")
    producer_job = value.get("producer_job")
    if not isinstance(kind, str) or not isinstance(artifact_id, int) or isinstance(artifact_id, bool) or not isinstance(artifact_name, str) or not isinstance(service_digest, str) or not isinstance(archive_sha256, str) or not isinstance(filename, str) or not isinstance(target_sha, str) or not isinstance(producer_run_id, int) or isinstance(producer_run_id, bool) or not isinstance(producer_job, str):
        raise ReceiptError("artifact receipt fields are invalid")
    receipt = ArtifactReceipt(kind, artifact_id, artifact_name, service_digest, archive_sha256, filename, target_sha, producer_run_id, producer_job)
    if receipt.kind not in KINDS or receipt.artifact_id <= 0 or not receipt.producer_job:
        raise ReceiptError("artifact receipt identity is invalid")
    if receipt.artifact_name != f"send2adf-{receipt.kind}-{receipt.producer_run_id}":
        raise ReceiptError("artifact receipt name is not exact")
    if SERVICE_DIGEST.fullmatch(receipt.service_digest) is None or HEX.fullmatch(receipt.archive_sha256) is None or re.fullmatch(r"[0-9a-f]{40}", receipt.target_sha) is None:
        raise ReceiptError("artifact receipt digest is invalid")
    if Path(receipt.filename).name != receipt.filename or not receipt.filename.endswith(".tar.gz"):
        raise ReceiptError("artifact receipt filename is invalid")
    return receipt


def validate_matrix(receipts: tuple[ArtifactReceipt, ...]) -> None:
    by_kind = {item.kind: item for item in receipts}
    if tuple(sorted(by_kind)) != tuple(sorted(KINDS)) or len(by_kind) != len(receipts):
        raise ReceiptError("aggregate receipt kind matrix is incomplete")
    source_match = re.fullmatch(r"send2adf-([0-9]+\.[0-9]+\.[0-9]+)-source\.tar\.gz", by_kind["source"].filename)
    if source_match is None:
        raise ReceiptError("source receipt filename is not canonical")
    version = source_match.group(1)
    expected = {kind: f"send2adf-{version}-{kind}.tar.gz" for kind in KINDS if kind != "source"}
    if any(by_kind[kind].filename != filename for kind, filename in expected.items()):
        raise ReceiptError("triplet receipt filename is not exact")
    if by_kind["source"].producer_job != "source-archive" or any(by_kind[kind].producer_job != kind for kind in expected):
        raise ReceiptError("artifact producer job binding mismatch")


def seal_receipts(paths: list[Path], output: Path, repository: str, run_id: int, target_sha: str) -> None:
    receipts = tuple(parse_receipt(json.loads(path.read_text(encoding="utf-8"))) for path in paths)
    validate_matrix(receipts)
    if len({item.artifact_id for item in receipts}) != 4 or len({item.filename for item in receipts}) != 4:
        raise ReceiptError("aggregate receipt contains substituted artifacts")
    if any(item.producer_run_id != run_id or item.target_sha != target_sha for item in receipts):
        raise ReceiptError("aggregate receipt replay identity mismatch")
    binding = hashlib.sha256(canonical_receipts(receipts)).hexdigest()
    value = {"schema": "send2adf-artifact-matrix/v1", "repository": repository, "producer_run_id": run_id, "target_sha": target_sha, "binding_sha256": binding, "receipts": [asdict(item) for item in receipts]}
    output.write_text(json.dumps(value, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")


def load_aggregate(path: Path, repository: str, run_id: int, target_sha: str) -> tuple[ArtifactReceipt, ...]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict) or value.get("schema") != "send2adf-artifact-matrix/v1" or value.get("repository") != repository or value.get("producer_run_id") != run_id or value.get("target_sha") != target_sha:
        raise ReceiptError("aggregate receipt identity mismatch")
    raw = value.get("receipts")
    if not isinstance(raw, list):
        raise ReceiptError("aggregate receipt matrix is invalid")
    receipts = tuple(parse_receipt(item) for item in raw)
    if hashlib.sha256(canonical_receipts(receipts)).hexdigest() != value.get("binding_sha256"):
        raise ReceiptError("aggregate receipt binding mismatch")
    validate_matrix(receipts)
    if len({item.artifact_id for item in receipts}) != 4:
        raise ReceiptError("aggregate receipt artifact substitution detected")
    return receipts


def collect_exact(repository: str, aggregate: Path, output: Path, run_id: int, target_sha: str) -> None:
    token = os.environ.get("GH_TOKEN", "")
    if not token:
        raise ReceiptError("artifact read token is absent")
    receipts = load_aggregate(aggregate, repository, run_id, target_sha)
    output.mkdir(parents=True, exist_ok=False)
    for receipt in receipts:
        metadata = github_request(f"https://api.github.com/repos/{repository}/actions/artifacts/{receipt.artifact_id}", token)
        workflow_run = metadata.get("workflow_run") if isinstance(metadata, dict) else None
        if not isinstance(metadata, dict) or metadata.get("id") != receipt.artifact_id or metadata.get("name") != receipt.artifact_name or metadata.get("digest") != receipt.service_digest or metadata.get("expired") is not False or not isinstance(workflow_run, dict) or workflow_run.get("id") != run_id:
            raise ReceiptError("exact artifact metadata does not match sealed receipt")
        content = github_bytes(f"https://api.github.com/repos/{repository}/actions/artifacts/{receipt.artifact_id}/zip", token)
        if hashlib.sha256(content).hexdigest() != receipt.service_digest.removeprefix("sha256:"):
            raise ReceiptError("sealed service artifact digest mismatch")
        with zipfile.ZipFile(io.BytesIO(content)) as bundle:
            names = [name for name in bundle.namelist() if not name.endswith("/")]
            if names != [receipt.filename]:
                raise ReceiptError("exact artifact archive member mismatch")
            archive = bundle.read(receipt.filename)
        if hashlib.sha256(archive).hexdigest() != receipt.archive_sha256:
            raise ReceiptError("sealed archive SHA-256 mismatch")
        (output / receipt.filename).write_bytes(archive)


def main() -> int:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    receipt = commands.add_parser("receipt")
    for name in ("kind", "artifact-id", "artifact-name", "service-digest", "archive-sha256", "filename", "target-sha", "producer-run-id", "producer-job"):
        receipt.add_argument(f"--{name}", required=True)
    receipt.add_argument("output", type=Path)
    seal = commands.add_parser("seal")
    seal.add_argument("output", type=Path); seal.add_argument("repository"); seal.add_argument("run_id", type=int); seal.add_argument("target_sha"); seal.add_argument("receipts", nargs="+", type=Path)
    collect = commands.add_parser("collect")
    collect.add_argument("repository"); collect.add_argument("aggregate", type=Path); collect.add_argument("output", type=Path); collect.add_argument("run_id", type=int); collect.add_argument("target_sha")
    arguments = parser.parse_args()
    try:
        if arguments.command == "receipt":
            value = ArtifactReceipt(arguments.kind, int(arguments.artifact_id), arguments.artifact_name, arguments.service_digest, arguments.archive_sha256, arguments.filename, arguments.target_sha, int(arguments.producer_run_id), arguments.producer_job)
            arguments.output.write_text(json.dumps(asdict(parse_receipt(asdict(value))), sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
        elif arguments.command == "seal":
            seal_receipts(arguments.receipts, arguments.output, arguments.repository, arguments.run_id, arguments.target_sha)
        else:
            collect_exact(arguments.repository, arguments.aggregate, arguments.output, arguments.run_id, arguments.target_sha)
    except (ReceiptError, ReleaseGitHubError, json.JSONDecodeError, OSError, zipfile.BadZipFile) as error:
        print(error, file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
