#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/tests/test_release_pipeline.py --case local-success

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path
from typing import Final

sys.path.insert(0, str(Path(__file__).resolve().parents[3]))

from Tools.send2adf.scripts.package_release import (
    adflib_source_name,
    adflib_transport_name,
    parse_manifest,
)
from Tools.send2adf.scripts.release_archive import (
    ArchiveEntry,
    read_archive_entries,
    write_tar_gz,
)
from Tools.send2adf.tests.artifact_receipt_cases import run_receipt_cases
from Tools.send2adf.tests.release_stateful_fake import run_stateful_case

SEND2ADF_ROOT: Final = Path(__file__).resolve().parents[1]
AMIGA_ROOT: Final = SEND2ADF_ROOT.parents[1]
REPOSITORY_ROOT: Final = AMIGA_ROOT.parent
PACKAGE: Final = SEND2ADF_ROOT / "scripts/package_release.py"
VERIFY: Final = SEND2ADF_ROOT / "scripts/verify_release.py"
AUTHORITY: Final = SEND2ADF_ROOT / "scripts/release_authority.py"
VALID_LEGAL: Final = SEND2ADF_ROOT / "tests/fixtures/package-licenses-valid"
ADFLIB_ARTIFACTS: Final = AMIGA_ROOT / ".artifacts/adflib"
SHA: Final = "84969d0bfe90d54d5f1fe5387ea64560a1e88f22"
VERSION: Final = "1.5.0"
EPOCH: Final = "1785765600"
ALTERNATE_MANIFEST: Final = SEND2ADF_ROOT / "tests/fixtures/package-licenses-manifest-0.10.8/ADFlibDependency.cmake"


def run(arguments: list[str], *, environment: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
    return subprocess.run(arguments, cwd=REPOSITORY_ROOT, env=environment, check=False, capture_output=True, text=True)


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def package_pair(output: Path, repository: Path) -> tuple[Path, Path]:
    empty_home = output / "empty-home"
    empty_cache = output / "empty-cache"
    empty_home.mkdir()
    empty_cache.mkdir()
    environment = {**os.environ, "HOME": str(empty_home), "XDG_CACHE_HOME": str(empty_cache), "PYTHONPYCACHEPREFIX": str(output / "pycache")}
    source = output / f"send2adf-{VERSION}-source.tar.gz"
    identity = parse_manifest(repository / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake")
    commit = identity["commit"]
    source_command = [
        sys.executable, str(PACKAGE), "source", "--repository-root", str(repository),
        "--adflib-source", str(ADFLIB_ARTIFACTS / f"ADFlib-{commit}-pristine"),
        "--adflib-transport", str(ADFLIB_ARTIFACTS / adflib_transport_name(identity)),
        "--output", str(source), "--version", VERSION, "--epoch", EPOCH,
    ]
    completed = run(source_command, environment=environment)
    if completed.returncode != 0:
        raise AssertionError(completed.stdout + completed.stderr)
    binary = output / f"send2adf-{VERSION}-macos-arm64.tar.gz"
    binary_command = [
        sys.executable, str(PACKAGE), "binary", "--repository-root", str(repository),
        "--binary", str(SEND2ADF_ROOT / "build/ci/send2adf"), "--source-archive", str(source),
        "--legal-root", str(VALID_LEGAL), "--output", str(binary), "--version", VERSION,
        "--target-sha", SHA, "--platform", "macos", "--architecture", "arm64", "--epoch", EPOCH,
        "--runner-image", "local-test", "--compiler-version", "AppleClang fixture",
        "--cmake-version", "4.4.2", "--source-artifact-id", "101",
        "--source-service-digest", "sha256:" + sha256(source),
    ]
    completed = run(binary_command, environment=environment)
    if completed.returncode != 0:
        raise AssertionError(completed.stdout + completed.stderr)
    return source, binary


def validate_disconnected_source_builds(source: Path, output: Path) -> None:
    extracted = output / "source-cross-contract"
    with tarfile.open(source, "r:gz") as archive:
        archive.extractall(extracted, filter="data")
    roots = [path for path in extracted.iterdir() if path.is_dir()]
    if len(roots) != 1:
        raise AssertionError("source archive does not have exactly one root")
    source_root = roots[0]
    manifest = source_root / "Tools/build-support/adflib/ADFlibDependency.cmake"
    manifest_values: dict[str, str] = {}
    for line in manifest.read_text(encoding="utf-8").splitlines():
        if line.startswith("set(ADFLIB_") and ' "' in line and line.endswith('")'):
            name, value = line[4:-2].split(' "', 1)
            manifest_values[name] = value
    adflib_source = source_root / f"ADFlib-{manifest_values['ADFLIB_TAG']}"
    network_denied = source_root / "Tools/build-support/adflib/tests/run_network_denied.py"
    for testing in ("ON", "OFF"):
        build = output / f"disconnected-build-testing-{testing.lower()}"
        configure = run([
            sys.executable, str(network_denied), "--", "cmake",
            "-S", str(source_root / "Tools/send2adf"), "-B", str(build),
            "-DFETCHCONTENT_FULLY_DISCONNECTED=ON",
            f"-DFETCHCONTENT_SOURCE_DIR_ADF={adflib_source}",
            f"-DBUILD_TESTING={testing}",
        ])
        if configure.returncode != 0:
            raise AssertionError(f"disconnected BUILD_TESTING={testing} configure failed\n{configure.stdout}{configure.stderr}")
        built = run([sys.executable, str(network_denied), "--", "cmake", "--build", str(build)])
        if built.returncode != 0 or not (build / "send2adf").is_file():
            raise AssertionError(f"disconnected BUILD_TESTING={testing} build failed\n{built.stdout}{built.stderr}")
        print(f"source_build_ok:BUILD_TESTING={testing}:network_denied")


def validate_manifest_driven_identity() -> None:
    canonical = AMIGA_ROOT / "Tools/build-support/adflib/ADFlibDependency.cmake"
    before = canonical.read_text(encoding="utf-8").splitlines()
    after = ALTERNATE_MANIFEST.read_text(encoding="utf-8").splitlines()
    changed = [old for old, new in zip(before, after, strict=True) if old != new]
    expected = {
        "set(ADFLIB_VERSION", "set(ADFLIB_TAG", "set(ADFLIB_COMMIT",
        "set(ADFLIB_TREE_SHA", "set(ADFLIB_ARCHIVE_URL", "set(ADFLIB_TREE_MANIFEST_SHA256",
    }
    if len(changed) != 6 or {line.split(" ", 1)[0] for line in changed} != expected:
        raise AssertionError("alternate ADFlib fixture is not an exact six-field manifest update")
    identity = parse_manifest(ALTERNATE_MANIFEST)
    if identity["version"] != "0.10.8" or identity["tag"] != "v0.10.8":
        raise AssertionError("alternate manifest effective identity mismatch")
    if adflib_source_name(identity) != "ADFlib-v0.10.8":
        raise AssertionError("alternate manifest source path mismatch")
    if adflib_transport_name(identity) != f"ADFlib-{identity['commit']}-transport.tar.gz":
        raise AssertionError("alternate manifest transport path mismatch")
    print("manifest_identity_ok:0.10.8:six-fields")


def verify_retained_release(retain: Path) -> None:
    source = retain / f"send2adf-{VERSION}-source.tar.gz"
    binary = retain / f"send2adf-{VERSION}-macos-arm64.tar.gz"
    verified = run([sys.executable, str(VERIFY), "--directory", str(retain), "--native-archive", binary.name])
    if verified.returncode != 0 or verified.stdout.strip() != "release_inventory_ok":
        raise AssertionError(verified.stdout + verified.stderr)
    with tempfile.TemporaryDirectory() as raw:
        drifted = Path(raw) / "release"
        shutil.copytree(retain, drifted)
        drifted_binary = drifted / binary.name
        entries = [
            ArchiveEntry(entry.name, b"drifted notice\n", entry.executable)
            if entry.name.endswith("/THIRD_PARTY_NOTICES.md") else entry
            for entry in read_archive_entries(drifted_binary)
        ]
        write_tar_gz(drifted_binary, entries, int(EPOCH))
        checksums = run([
            sys.executable, str(PACKAGE), "checksums", "--output", str(drifted / "SHA256SUMS"),
            str(drifted_binary), str(drifted / source.name),
        ])
        if checksums.returncode != 0:
            raise AssertionError(checksums.stdout + checksums.stderr)
        rejected = run([sys.executable, str(VERIFY), "--directory", str(drifted), "--native-archive", binary.name])
        if rejected.returncode == 0 or rejected.stderr.strip() != "third-party notice mismatch":
            raise AssertionError("independent verifier accepted retained archive drift")
    print(f"retained_release_ok:source_sha256={sha256(source)}:binary_sha256={sha256(binary)}")
    print("retained_drift_rejected:third-party notice mismatch")


def local_success(retain: Path | None = None) -> None:
    validate_manifest_driven_identity()
    with tempfile.TemporaryDirectory() as first_raw, tempfile.TemporaryDirectory() as second_raw:
        first = Path(first_raw)
        second = Path(second_raw)
        first_repository = first / "repository"
        second_repository = second / "repository"
        for repository in (first_repository, second_repository):
            (repository / "Amiga/Tools").mkdir(parents=True)
            shutil.copy2(REPOSITORY_ROOT / "LICENSE", repository / "LICENSE")
            ignored = shutil.ignore_patterns("build", ".omo", "__pycache__", "package-licenses-*")
            shutil.copytree(SEND2ADF_ROOT, repository / "Amiga/Tools/send2adf", ignore=ignored)
            shutil.copytree(AMIGA_ROOT / "Tools/build-support/adflib", repository / "Amiga/Tools/build-support/adflib", ignore=ignored)
        first_source, first_binary = package_pair(first, first_repository)
        second_source, second_binary = package_pair(second, second_repository)
        if first_source.read_bytes() != second_source.read_bytes() or first_binary.read_bytes() != second_binary.read_bytes():
            raise AssertionError("package passes are not byte-identical")
        checksums = first / "SHA256SUMS"
        completed = run([sys.executable, str(PACKAGE), "checksums", "--output", str(checksums), str(first_binary), str(first_source)])
        if completed.returncode != 0:
            raise AssertionError(completed.stdout + completed.stderr)
        completed = run([sys.executable, str(VERIFY), "--directory", str(first), "--native-archive", first_binary.name])
        if completed.returncode != 0 or "release_inventory_ok" not in completed.stdout:
            raise AssertionError(completed.stdout + completed.stderr)
        validate_disconnected_source_builds(first_source, first)
        if retain is not None:
            retained = retain.resolve()
            retained.mkdir(parents=True, exist_ok=False)
            for path in (first_source, first_binary, checksums):
                shutil.copy2(path, retained / path.name)
            verify_retained_release(retained)


def negative_case(case: str) -> None:
    payload = {
        "mode": "publish", "tag": "send2adf-v1.5.0", "expected_sha": SHA,
        "event": "workflow_dispatch", "ref": "refs/heads/master", "workflow_sha": SHA,
        "master_sha": SHA, "tag_sha": SHA, "tag_kind": "commit", "cmake_version": VERSION,
        "environment_approved": True, "tag_ruleset_enforced": True, "checks_verified": True,
        "check_app_id": 15368, "expected_check_app_id": 15368, "adflib_canary": False,
        "tree_clean": True, "tests_passed": True, "license_approved": True,
    }
    mutations = {
        "canary": ("adflib_canary", True), "moved-tag": ("tag_sha", "1" * 40),
        "annotated-tag-wrong-target": ("tag_kind", "annotated-wrong-target"),
        "wrong-check-app": ("check_app_id", 1), "environment-denied": ("environment_approved", False),
        "missing-copying": ("license_approved", False),
        "actions-bot-write": ("checks_verified", False),
        "actions-pr-setting-enabled": ("tag_ruleset_enforced", False),
        "app-master-push-denied": ("checks_verified", False),
        "app-merge-denied": ("checks_verified", False),
        "app-extra-permission": ("check_app_id", 1),
    }
    if case not in mutations:
        raise AssertionError(f"unnamed authority scenario: {case}")
    key, value = mutations[case]
    payload[key] = value
    with tempfile.TemporaryDirectory() as raw:
        input_path = Path(raw) / "authority.json"
        input_path.write_text(json.dumps(payload), encoding="utf-8")
        completed = run([sys.executable, str(AUTHORITY), "authorize", str(input_path)])
    if completed.returncode == 0:
        raise AssertionError(f"unsafe case was authorized: {case}")


def draft_publish() -> None:
    run_stateful_case("draft-publish")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--output", type=Path)
    arguments = parser.parse_args()
    case = arguments.case
    stateful_cases = {
        "partial-upload", "runner-loss", "rerun-exact", "published-divergence", "unowned-draft",
        "unowned-asset", "prior-run-adoption", "invalid-prior-run", "reserved-no-draft",
        "reserved-one-draft", "reserved-multiple-drafts", "draft-bound-uninventoried-resume",
        "inventory-bound-resume", "invalid-reserved-observation",
        "invalid-draft-bound-observation", "invalid-inventory-bound-observation",
        "expired-run-durable-lease", "orphan-without-lease", "lease-transfer-loss",
        "concurrent-rerun",
        "adoption", "foreign-draft", "stale-observation", "published-noop",
        "reserved-mismatched-run", "published-noop-mismatched-run",
        "authorized-transfer-chain",
    }
    if case == "local-success":
        local_success(arguments.output)
    elif case == "artifact-receipts":
        with tempfile.TemporaryDirectory() as raw:
            run_receipt_cases(Path(raw))
    elif case == "draft-publish":
        draft_publish()
    elif case in stateful_cases:
        run_stateful_case(case)
    else:
        negative_case(case)
    print(f"release_case_ok:{case}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
