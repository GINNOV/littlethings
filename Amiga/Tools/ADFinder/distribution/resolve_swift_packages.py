#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 resolve_swift_packages.py --project ../ADFinder.xcodeproj --artifacts /absolute/cache --print-source-packages-path

from __future__ import annotations

import argparse
import hashlib
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final


SPARKLE_LOCATION: Final = "https://github.com/sparkle-project/Sparkle.git"


@dataclass(frozen=True, slots=True)
class ResolutionError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


@dataclass(frozen=True, slots=True)
class SparklePin:
    revision: str
    version: str


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def parse_pin(lockfile: Path) -> SparklePin:
    payload = json.loads(lockfile.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or payload.get("version") != 3:
        raise ResolutionError("swiftpm_lock_invalid", str(lockfile))
    pins = payload.get("pins")
    if not isinstance(pins, list) or len(pins) != 1:
        raise ResolutionError("swiftpm_lock_invalid", "expected exactly one package pin")
    pin = pins[0]
    if not isinstance(pin, dict) or pin.get("identity") != "sparkle" or pin.get("location") != SPARKLE_LOCATION:
        raise ResolutionError("sparkle_identity_mismatch", str(pin))
    state = pin.get("state")
    if not isinstance(state, dict):
        raise ResolutionError("sparkle_state_invalid", str(state))
    revision = state.get("revision")
    version = state.get("version")
    if not isinstance(revision, str) or len(revision) != 40 or not isinstance(version, str):
        raise ResolutionError("sparkle_state_invalid", str(state))
    return SparklePin(revision, version)


def build_inventory(root: Path) -> bytes:
    rows: list[str] = []
    for path in sorted(root.rglob("*"), key=lambda item: item.relative_to(root).as_posix().encode()):
        if path.is_file() and "/.git/" not in f"/{path.relative_to(root).as_posix()}/":
            relative = path.relative_to(root).as_posix()
            rows.append(f"{relative}\t{path.stat().st_mode & 0o777:o}\t{path.stat().st_size}\t{sha256_file(path)}")
    return ("\n".join(rows) + "\n").encode()


def run(arguments: argparse.Namespace) -> int:
    project = arguments.project.resolve()
    lockfile = project / "project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    pin = parse_pin(lockfile)
    lock_digest = sha256_file(lockfile)
    source_packages = arguments.artifacts.resolve() / lock_digest / "SourcePackages"
    source_packages.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        [
            "xcodebuild",
            "-resolvePackageDependencies",
            "-project",
            str(project),
            "-scheme",
            "ADFinder",
            "-derivedDataPath",
            str(source_packages.parent / "DerivedData"),
            "-clonedSourcePackagesDirPath",
            str(source_packages),
        ],
        check=True,
    )
    checkout = source_packages / "checkouts/Sparkle"
    head = subprocess.run(
        ["git", "-C", str(checkout), "rev-parse", "HEAD"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if head != pin.revision:
        raise ResolutionError("sparkle_revision_mismatch", f"expected={pin.revision} actual={head}")
    subprocess.run(["git", "-C", str(checkout), "fsck", "--full"], check=True, capture_output=True)
    (source_packages.parent / "Package.resolved").write_bytes(lockfile.read_bytes())
    (source_packages.parent / "closure-inventory.tsv").write_bytes(build_inventory(source_packages))
    metadata = {
        "schema": "adfinder-swiftpm-closure/v1",
        "package_resolved_sha256": lock_digest,
        "sparkle_revision": pin.revision,
        "sparkle_version": pin.version,
        "inventory_sha256": sha256_file(source_packages.parent / "closure-inventory.tsv"),
    }
    (source_packages.parent / "closure.json").write_text(
        json.dumps(metadata, separators=(",", ":"), sort_keys=True) + "\n",
        encoding="utf-8",
    )
    if arguments.print_source_packages_path:
        print(source_packages)
    else:
        print(f"swiftpm_closure_ok revision={pin.revision} inventory={metadata['inventory_sha256']}")
    return 0


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser()
    result.add_argument("--project", required=True, type=Path)
    result.add_argument("--artifacts", required=True, type=Path)
    result.add_argument("--print-source-packages-path", action="store_true")
    return result


def main() -> int:
    try:
        return run(parser().parse_args())
    except (ResolutionError, OSError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
