#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 test_build_contract.py --case identity --binary ../build/ci/send2adf --manifest ../../build-support/adflib/ADFlibDependency.cmake

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

MANIFEST_PATTERN = re.compile(r'^set\((ADFLIB_[A-Z0-9_]+) "([^"]*)"\)$')


def manifest_fields(path: Path) -> dict[str, str]:
    fields: dict[str, str] = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        match = MANIFEST_PATTERN.fullmatch(line)
        if match is not None:
            fields[match.group(1)] = match.group(2)
    return fields


def identity_case(binary: Path, manifest: Path) -> int:
    fields = manifest_fields(manifest)
    expected = {
        "channel": "canary" if fields["ADFLIB_VERSION"] == "0.0.0-canary" else "stable",
        "owner_repo": fields["ADFLIB_OWNER_REPO"],
        "version": fields["ADFLIB_VERSION"],
        "tag": fields["ADFLIB_TAG"],
        "commit": fields["ADFLIB_COMMIT"],
        "tree_sha": fields["ADFLIB_TREE_SHA"],
        "url": fields["ADFLIB_ARCHIVE_URL"],
        "tree_manifest_sha256": fields["ADFLIB_TREE_MANIFEST_SHA256"],
    }
    expected_bytes = (json.dumps(expected, separators=(",", ":")) + "\n").encode()
    result = subprocess.run([binary, "--build-identity"], check=False, capture_output=True)
    if result.returncode != 0 or result.stdout != expected_bytes or result.stderr:
        print("build_identity_mismatch")
        return 1
    provenance = subprocess.run([binary, "--build-provenance"], check=False, capture_output=True)
    parsed_provenance = json.loads(provenance.stdout)
    if expected["channel"] == "canary":
        local_cache_sha256 = parsed_provenance.get("transport", {}).get("local_cache_sha256", "")
        if re.fullmatch(r"[0-9a-f]{64}", local_cache_sha256) is None:
            print("build_provenance_cache_digest_invalid")
            return 1
        expected_transport = {
            "transport_url": f"https://codeload.github.com/adflib/ADFlib/tar.gz/{fields['ADFLIB_COMMIT']}",
            "transport_sha256": fields["ADFLIB_EXPECTED_TRANSPORT_SHA256"],
            "local_cache_sha256": local_cache_sha256,
        }
    else:
        expected_transport = {
            "transport_url": fields["ADFLIB_TRANSPORT_URL"],
            "transport_sha256": fields["ADFLIB_TRANSPORT_SHA256"],
            "local_cache_sha256": fields["ADFLIB_LOCAL_CACHE_SHA256"],
        }
    expected_provenance = {"identity": expected, "transport": expected_transport}
    if provenance.returncode != 0 or parsed_provenance != expected_provenance or provenance.stderr:
        print("build_provenance_mismatch")
        return 1
    print("build_identity_ok")
    return 0


def offline_rebuild_case(source: Path, pristine: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-offline-") as temporary_directory:
        build = Path(temporary_directory) / "build"
        configure = subprocess.run(
            [
                "cmake",
                "-S",
                str(source),
                "-B",
                str(build),
                "-DFETCHCONTENT_FULLY_DISCONNECTED=ON",
                f"-DFETCHCONTENT_SOURCE_DIR_ADF={pristine.resolve()}",
                "-DBUILD_TESTING=OFF",
            ],
            check=False,
        )
        if configure.returncode != 0:
            return configure.returncode
        result = subprocess.run(["cmake", "--build", str(build)], check=False)
        if result.returncode == 0:
            print("offline_rebuild_ok")
        return result.returncode


def bad_hash_case(source: Path) -> int:
    pristine_candidates = sorted((source / "build/ci/adflib-cache").glob("ADFlib-*-pristine"))
    if len(pristine_candidates) != 1:
        print("bad_hash_fixture_requires_connected_cache")
        return 1
    canonical = source.parent / "build-support/adflib/ADFlibDependency.cmake"
    with tempfile.TemporaryDirectory(prefix="send2adf-bad-hash-") as temporary_directory:
        temporary = Path(temporary_directory)
        manifest = temporary / "ADFlibDependency.cmake"
        manifest.write_text(
            canonical.read_text(encoding="utf-8").replace(
                'set(ADFLIB_TREE_MANIFEST_SHA256 "9bc3acc858277537ca04fc0933b8471bbe277927cb4923836e53b9fe1285dfd5")',
                'set(ADFLIB_TREE_MANIFEST_SHA256 "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")',
            ),
            encoding="utf-8",
        )
        result = subprocess.run(
            [
                "cmake",
                "-S",
                str(source),
                "-B",
                str(temporary / "build"),
                "-DSEND2ADF_TESTING=ON",
                f"-DADFLIB_MANIFEST_FILE={manifest}",
                "-DFETCHCONTENT_FULLY_DISCONNECTED=ON",
                f"-DFETCHCONTENT_SOURCE_DIR_ADF={pristine_candidates[0].resolve()}",
                "-DBUILD_TESTING=OFF",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        output = result.stdout + result.stderr
        if result.returncode == 0 or "source_tree_mismatch" not in output:
            print(output)
            return 1
    print("bad_hash_rejected")
    return 0


def production_guards_case(source: Path, pristine: Path) -> int:
    with tempfile.TemporaryDirectory(prefix="send2adf-production-guards-") as temporary_directory:
        temporary = Path(temporary_directory)
        common = [
            "-DFETCHCONTENT_FULLY_DISCONNECTED=ON",
            f"-DFETCHCONTENT_SOURCE_DIR_ADF={pristine.resolve()}",
            "-DBUILD_TESTING=OFF",
        ]
        testing_production = subprocess.run(
            [
                "cmake",
                "-S",
                str(source),
                "-B",
                str(temporary / "production-testing"),
                "-DSEND2ADF_PRODUCTION_BUILD=ON",
                "-DSEND2ADF_TESTING=ON",
                *common,
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if testing_production.returncode == 0 or "production_testing_mode_rejected" not in testing_production.stdout + testing_production.stderr:
            print("production_testing_guard_missing")
            return 1
        canonical = source.parent / "build-support/adflib/ADFlibDependency.cmake"
        manifest = temporary / "noncanonical.cmake"
        manifest.write_bytes(canonical.read_bytes())
        noncanonical_production = subprocess.run(
            [
                "cmake",
                "-S",
                str(source),
                "-B",
                str(temporary / "production-noncanonical"),
                "-DSEND2ADF_PRODUCTION_BUILD=ON",
                f"-DADFLIB_MANIFEST_FILE={manifest}",
                *common,
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if noncanonical_production.returncode == 0 or "noncanonical_adflib_manifest_rejected" not in noncanonical_production.stdout + noncanonical_production.stderr:
            print("production_manifest_guard_missing")
            return 1
        testing_build = temporary / "testing-install"
        configured = subprocess.run(
            [
                "cmake",
                "-S",
                str(source),
                "-B",
                str(testing_build),
                "-DSEND2ADF_TESTING=ON",
                *common,
            ],
            check=False,
        )
        if configured.returncode != 0:
            return configured.returncode
        installed = subprocess.run(
            ["cmake", "--install", str(testing_build), "--prefix", str(temporary / "install")],
            check=False,
            capture_output=True,
            text=True,
        )
        if installed.returncode == 0 or "install_from_testing_configuration_rejected" not in installed.stdout + installed.stderr:
            print("install_testing_guard_missing")
            return 1
    print("production_guards_ok")
    return 0


def warm_cache_provenance_case(source: Path, binary: Path, manifest: Path) -> int:
    fields = manifest_fields(manifest)
    expected_url = f"https://codeload.github.com/adflib/ADFlib/tar.gz/{fields['ADFLIB_COMMIT']}"
    network_denied = source.parent / "build-support/adflib/tests/run_network_denied.py"
    stager = source.parent / "build-support/adflib/stage_adflib.py"
    with tempfile.TemporaryDirectory(prefix="send2adf-warm-cache-") as temporary_directory:
        artifacts = Path(temporary_directory) / "artifacts"
        cold = subprocess.run(
            [
                sys.executable,
                str(stager),
                "--manifest",
                str(manifest),
                "--connected",
                "--artifacts",
                str(artifacts),
                "--print-source-root",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if cold.returncode != 0:
            print(cold.stdout + cold.stderr)
            return cold.returncode
        transport_record = artifacts / "adflib-transport.json"
        before = transport_record.read_bytes()
        before_payload = json.loads(before)
        if before_payload.get("transport_url") != expected_url:
            print("cold_transport_url_mismatch")
            return 1
        if fields.get("ADFLIB_CHANNEL", "stable") == "stable":
            expected_transport = {
                "transport_url": fields["ADFLIB_TRANSPORT_URL"],
                "transport_sha256": fields["ADFLIB_TRANSPORT_SHA256"],
                "local_cache_sha256": fields["ADFLIB_LOCAL_CACHE_SHA256"],
            }
            if before_payload != expected_transport:
                print("cold_transport_record_mismatch")
                return 1
        elif re.fullmatch(r"[0-9a-f]{64}", before_payload.get("local_cache_sha256", "")) is None:
            print("cold_cache_digest_invalid")
            return 1
        repeated = subprocess.run(
            [
                sys.executable,
                str(network_denied),
                "--",
                sys.executable,
                str(stager),
                "--manifest",
                str(manifest),
                "--connected",
                "--artifacts",
                str(artifacts),
                "--print-source-root",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if repeated.returncode != 0:
            print(repeated.stdout + repeated.stderr)
            return repeated.returncode
        after = transport_record.read_bytes()
        if after != before:
            print("warm_cache_transport_record_changed")
            return 1
        provenance = subprocess.run([binary, "--build-provenance"], check=False, capture_output=True)
        if provenance.returncode != 0 or provenance.stderr:
            print("warm_cache_provenance_command_failed")
            return 1
        if json.loads(provenance.stdout)["transport"] != json.loads(after):
            print("warm_cache_binary_provenance_mismatch")
            return 1
    print("warm_cache_provenance_ok")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True, choices=["identity", "offline-rebuild", "bad-hash", "production-guards", "warm-cache-provenance"])
    parser.add_argument("--binary", type=Path)
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--source", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--pristine", type=Path)
    arguments = parser.parse_args()
    if arguments.case == "identity":
        return identity_case(arguments.binary, arguments.manifest)
    if arguments.case == "offline-rebuild":
        return offline_rebuild_case(arguments.source, arguments.pristine)
    if arguments.case == "production-guards":
        return production_guards_case(arguments.source, arguments.pristine)
    if arguments.case == "warm-cache-provenance":
        return warm_cache_provenance_case(arguments.source, arguments.binary, arguments.manifest)
    return bad_hash_case(arguments.source)


if __name__ == "__main__":
    raise SystemExit(main())
