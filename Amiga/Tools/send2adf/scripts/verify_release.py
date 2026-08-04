#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Tools/send2adf/scripts/verify_release.py --directory <release-directory>

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final, TypeAlias

HEX_64: Final = re.compile(r"^[0-9a-f]{64}$")
JsonValue: TypeAlias = str | int | bool | None | list["JsonValue"] | dict[str, "JsonValue"]


@dataclass(frozen=True, slots=True)
class VerificationError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def extract(archive_path: Path, destination: Path) -> Path:
    try:
        with tarfile.open(archive_path, "r:gz") as archive:
            members = archive.getmembers()
            names = [member.name for member in members]
            if names != sorted(names, key=lambda name: name.encode("utf-8")) or len(names) != len(set(names)):
                raise VerificationError(f"archive order is not canonical: {archive_path.name}")
            roots: set[str] = set()
            mtimes: set[int] = set()
            for member in members:
                path = PurePosixPath(member.name)
                if path.is_absolute() or ".." in path.parts or not member.isfile():
                    raise VerificationError(f"unsupported archive member: {member.name}")
                if member.uid != 0 or member.gid != 0 or member.uname or member.gname:
                    raise VerificationError(f"archive ownership is not normalized: {member.name}")
                if member.mode not in {0o644, 0o755}:
                    raise VerificationError(f"archive mode is not normalized: {member.name}")
                roots.add(path.parts[0])
                mtimes.add(member.mtime)
            if len(roots) != 1 or len(mtimes) != 1:
                raise VerificationError(f"archive root or mtime is not normalized: {archive_path.name}")
            archive.extractall(destination, filter="data")
    except (OSError, tarfile.TarError) as error:
        raise VerificationError(f"unreadable archive: {archive_path.name}") from error
    return destination / next(iter(roots))


def read_checksums(directory: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for line in (directory / "SHA256SUMS").read_text(encoding="utf-8").splitlines():
        parts = line.split("  ", 1)
        if len(parts) != 2 or HEX_64.fullmatch(parts[0]) is None or Path(parts[1]).name != parts[1]:
            raise VerificationError("invalid SHA256SUMS record")
        if parts[1] in result:
            raise VerificationError("duplicate SHA256SUMS record")
        result[parts[1]] = parts[0]
    if list(result) != sorted(result, key=lambda name: name.encode("utf-8")):
        raise VerificationError("SHA256SUMS is not sorted")
    for name, expected in result.items():
        path = directory / name
        if not path.is_file() or sha256(path) != expected:
            raise VerificationError(f"checksum mismatch: {name}")
    return result


def require_map(value: JsonValue, field: str) -> dict[str, JsonValue]:
    if not isinstance(value, dict):
        raise VerificationError(f"invalid JSON object: {field}")
    return value


def verify_binary(directory: Path, archive_path: Path, source: Path, run_native: bool) -> None:
    with tempfile.TemporaryDirectory() as raw:
        staging = Path(raw)
        package_root = extract(archive_path, staging)
        source_root = extract(source, package_root)
        shutil.copyfile(source, package_root / source.name)
        corresponding = require_map(json.loads((package_root / "CORRESPONDING_SOURCE.json").read_text(encoding="utf-8")), "CORRESPONDING_SOURCE")
        archive = require_map(corresponding.get("source_archive"), "source_archive")
        if archive.get("name") != source.name or archive.get("sha256") != sha256(source):
            raise VerificationError("binary-to-source relationship mismatch")
        if corresponding.get("source_root") != source_root.name or archive.get("producer_job") != "source-archive":
            raise VerificationError("source producer identity mismatch")
        provenance = require_map(json.loads((package_root / "provenance.json").read_text(encoding="utf-8")), "provenance")
        source_artifact = require_map(provenance.get("source_artifact"), "source_artifact")
        if source_artifact.get("sha256") != sha256(source) or source_artifact.get("producer_job") != "source-archive":
            raise VerificationError("source artifact provenance mismatch")
        checker = directory.parents[3] / "Tools/send2adf/scripts/check_package_licenses.py"
        if not checker.is_file():
            checker = Path(__file__).resolve().with_name("check_package_licenses.py")
        completed = subprocess.run([sys.executable, str(checker), str(package_root)], check=False, capture_output=True, text=True)
        if completed.returncode != 0 or completed.stdout.strip() != "license_inventory_ok":
            raise VerificationError(completed.stdout + completed.stderr)
        executable = package_root / "send2adf"
        if run_native:
            help_result = subprocess.run([str(executable), "--help"], check=False, capture_output=True, text=True)
            if help_result.returncode != 0:
                raise VerificationError("native executable --help failed")
            file_result = subprocess.run(["file", str(executable)], check=False, capture_output=True, text=True)
            architecture = provenance.get("architecture")
            expected = "arm64" if architecture == "arm64" else "x86_64"
            aliases = (expected, "x86-64") if expected == "x86_64" else (expected, "aarch64")
            if file_result.returncode != 0 or not any(alias in file_result.stdout for alias in aliases):
                raise VerificationError("native executable architecture mismatch")


def verify(arguments: argparse.Namespace) -> None:
    directory = Path(arguments.directory).resolve()
    checksums = read_checksums(directory)
    sources = [directory / name for name in checksums if name.endswith("-source.tar.gz")]
    binaries = [directory / name for name in checksums if name.endswith(".tar.gz") and name not in {path.name for path in sources}]
    if len(sources) != 1 or not binaries:
        raise VerificationError("release inventory is incomplete")
    for binary in binaries:
        verify_binary(directory, binary, sources[0], binary.name == arguments.native_archive)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--directory", required=True)
    parser.add_argument("--native-archive", default="")
    arguments = parser.parse_args()
    try:
        verify(arguments)
    except (OSError, UnicodeError, json.JSONDecodeError, VerificationError) as error:
        print(error, file=sys.stderr)
        return 2
    print("release_inventory_ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
