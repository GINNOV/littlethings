from __future__ import annotations

import hashlib
import io
import json
import os
import zipfile
from dataclasses import asdict, replace
from pathlib import Path

from Tools.send2adf.scripts import release_artifacts
from Tools.send2adf.scripts.release_artifacts import (
    ArtifactReceipt,
    ReceiptError,
    collect_exact,
    load_aggregate,
    seal_receipts,
)
from Tools.send2adf.scripts.release_github import JsonValue


def _zip(filename: str, content: bytes) -> bytes:
    stream = io.BytesIO()
    with zipfile.ZipFile(stream, "w") as bundle:
        info = zipfile.ZipInfo(filename)
        info.date_time = (2026, 1, 1, 0, 0, 0)
        bundle.writestr(info, content)
    return stream.getvalue()


def run_receipt_cases(root: Path) -> None:
    run_id = 123
    target = "8" * 40
    version = "1.5.0"
    members = {
        "source": (f"send2adf-{version}-source.tar.gz", b"source"),
        "macos-arm64": (f"send2adf-{version}-macos-arm64.tar.gz", b"arm"),
        "macos-x86_64": (f"send2adf-{version}-macos-x86_64.tar.gz", b"intel"),
        "linux-x86_64": (f"send2adf-{version}-linux-x86_64.tar.gz", b"linux"),
    }
    bundles: dict[int, bytes] = {}
    receipts: list[ArtifactReceipt] = []
    paths: list[Path] = []
    for index, (kind, (filename, content)) in enumerate(members.items(), start=1):
        bundle = _zip(filename, content)
        bundles[index] = bundle
        producer_job = "source-archive" if kind == "source" else kind
        receipt = ArtifactReceipt(kind, index, f"send2adf-{kind}-{run_id}", f"sha256:{hashlib.sha256(bundle).hexdigest()}", hashlib.sha256(content).hexdigest(), filename, target, run_id, producer_job)
        receipts.append(receipt)
        path = root / f"{kind}.json"
        path.write_text(json.dumps(asdict(receipt)), encoding="utf-8")
        paths.append(path)
    aggregate = root / "matrix.json"
    seal_receipts(paths, aggregate, "owner/repo", run_id, target)
    requested: list[str] = []
    original_request = release_artifacts.github_request
    original_bytes = release_artifacts.github_bytes

    def metadata(url: str, token: str) -> JsonValue:
        requested.append(url)
        artifact_id = int(url.rsplit("/", 1)[1])
        receipt = receipts[artifact_id - 1]
        return {"id": artifact_id, "name": receipt.artifact_name, "digest": receipt.service_digest, "expired": False, "workflow_run": {"id": run_id}}

    def download(url: str, token: str) -> bytes:
        requested.append(url)
        return bundles[int(url.split("/artifacts/", 1)[1].split("/", 1)[0])]

    os.environ["GH_TOKEN"] = "fixture-token"
    release_artifacts.github_request = metadata
    release_artifacts.github_bytes = download
    try:
        collect_exact("owner/repo", aggregate, root / "collected", run_id, target)
    finally:
        release_artifacts.github_request = original_request
        release_artifacts.github_bytes = original_bytes
        os.environ.pop("GH_TOKEN", None)
    if len(requested) != 8 or any("/actions/runs/" in url for url in requested):
        raise AssertionError("collector did not use exact artifact IDs")
    for receipt in receipts:
        if (root / "collected" / receipt.filename).read_bytes() != members[receipt.kind][1]:
            raise AssertionError("collector bytes differ from sealed archive")
    invalid = root / "invalid.json"
    invalid.write_text(json.dumps(asdict(replace(receipts[0], artifact_name=receipts[0].artifact_name + "-prefix"))), encoding="utf-8")
    try:
        seal_receipts([invalid, *paths[1:]], root / "invalid-matrix.json", "owner/repo", run_id, target)
    except ReceiptError:
        pass
    else:
        raise AssertionError("artifact name-prefix substitution was accepted")
    duplicate = root / "duplicate.json"
    duplicate.write_text(json.dumps(asdict(replace(receipts[1], artifact_id=receipts[0].artifact_id))), encoding="utf-8")
    try:
        seal_receipts([paths[0], duplicate, *paths[2:]], root / "duplicate-matrix.json", "owner/repo", run_id, target)
    except ReceiptError:
        pass
    else:
        raise AssertionError("artifact ID substitution was accepted")
    try:
        seal_receipts(paths, root / "replay-matrix.json", "owner/repo", run_id + 1, target)
    except ReceiptError:
        pass
    else:
        raise AssertionError("artifact receipt replay was accepted")
    value = json.loads(aggregate.read_text(encoding="utf-8"))
    value["binding_sha256"] = "0" * 64
    aggregate.write_text(json.dumps(value), encoding="utf-8")
    try:
        load_aggregate(aggregate, "owner/repo", run_id, target)
    except ReceiptError:
        return
    raise AssertionError("aggregate receipt binding substitution was accepted")
