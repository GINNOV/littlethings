#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 run_final_verification.py --repo-root "$PWD" --evidence-dir evidence --state state.json --attempt-id 00000000-0000-4000-8000-000000000000 --lane scope

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import socket
import stat
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Final

from final_verification_catalog import PROBE_LANE, Lane, Probe

PROTOCOL: Final = "send2adf-final-verification/v1"
ATTEMPT: Final = re.compile(r"[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}")
COMMIT: Final = re.compile(r"[0-9a-f]{40}")


@dataclass(frozen=True, slots=True)
class DriverError(Exception):
    code: str

    def __str__(self) -> str:
        return self.code


@dataclass(frozen=True, slots=True)
class Assignment:
    attempt_id: str
    base_sha: str
    final_sha: str
    lane: Lane
    capability_id: str
    public_fingerprint: str


def git(repo_root: Path, arguments: tuple[str, ...]) -> str:
    result = subprocess.run(
        ("/usr/bin/git", "-C", str(repo_root), *arguments),
        check=False,
        capture_output=True,
        text=True,
        env={"LANG": "C", "LC_ALL": "C", "PATH": "/usr/bin:/bin"},
    )
    if result.returncode != 0:
        raise DriverError(f"git_observation_failed:{result.returncode}")
    return result.stdout.strip()


def load_assignment(path: Path, attempt_id: str, lane: Lane) -> Assignment:
    if not path.is_absolute() or path.is_symlink():
        raise DriverError("assigned_state_path_untrusted")
    metadata = path.stat()
    if not stat.S_ISREG(metadata.st_mode) or metadata.st_mode & 0o222:
        raise DriverError("assigned_state_not_immutable")
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict) or payload.get("protocol") != PROTOCOL:
        raise DriverError("assigned_state_protocol_invalid")
    if payload.get("attempt_id") != attempt_id or payload.get("lane") != lane:
        raise DriverError("assigned_state_identity_mismatch")
    base_sha = str(payload.get("base_sha", ""))
    final_sha = str(payload.get("final_sha", ""))
    capability_id = str(payload.get("capability_id", ""))
    fingerprint = str(payload.get("public_fingerprint", ""))
    if COMMIT.fullmatch(base_sha) is None or COMMIT.fullmatch(final_sha) is None:
        raise DriverError("assigned_state_commit_invalid")
    if re.fullmatch(r"[0-9a-f]{32}", capability_id) is None or re.fullmatch(r"[0-9a-f]{64}", fingerprint) is None:
        raise DriverError("assigned_state_capability_invalid")
    return Assignment(attempt_id, base_sha, final_sha, lane, capability_id, fingerprint)


def require_capability() -> socket.socket:
    try:
        capability = socket.socket(fileno=3)
        capability.getpeername()
    except OSError as error:
        raise DriverError("lane_capability_unavailable") from error
    return capability


def inventory(repo_root: Path, assignment: Assignment) -> list[dict[str, str]]:
    changed = git(repo_root, ("diff", "--name-only", f"{assignment.base_sha}..{assignment.final_sha}"))
    records: list[dict[str, str]] = []
    for relative in filter(None, changed.splitlines()):
        candidate = repo_root / relative
        if candidate.is_file() and not candidate.is_symlink():
            records.append({"path": relative, "sha256": hashlib.sha256(candidate.read_bytes()).hexdigest()})
    return records


def require_head_and_clean(repo_root: Path, assignment: Assignment) -> None:
    if git(repo_root, ("rev-parse", "HEAD")) != assignment.final_sha:
        raise DriverError("lane_head_drift")
    dirty = git(repo_root, ("status", "--porcelain", "--untracked-files=all"))
    forbidden = [line for line in dirty.splitlines() if ".omo/" not in line and ".artifacts/" not in line]
    if forbidden:
        raise DriverError("lane_worktree_dirty")


def exclusive_write(parent: Path, name: str, payload: bytes) -> None:
    parent_fd = os.open(parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        descriptor = os.open(name, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=parent_fd)
        try:
            os.write(descriptor, payload)
            os.fsync(descriptor)
        finally:
            os.close(descriptor)
    except OSError as error:
        raise DriverError(f"evidence_exclusive_create_failed:{error.errno}") from error
    finally:
        os.close(parent_fd)


def run_lane(repo_root: Path, evidence: Path, assignment: Assignment, probe: Probe | None) -> int:
    capability = require_capability()
    with capability:
        require_head_and_clean(repo_root, assignment)
        files = inventory(repo_root, assignment)
        report = {
            "attempt_id": assignment.attempt_id,
            "capability_id": assignment.capability_id,
            "files": files,
            "final_sha": assignment.final_sha,
            "lane": assignment.lane,
            "probe": probe,
            "protocol": PROTOCOL,
            "status": "untrusted_submission",
        }
        stem = assignment.lane if probe is None else f"probe-{probe}"
        exclusive_write(evidence, f"{stem}.json", (json.dumps(report, indent=2, sort_keys=True) + "\n").encode())
        exclusive_write(evidence, f"{stem}.md", f"# {stem}\n\nUntrusted submission for supervisor verification.\n".encode())
        capability.sendall((json.dumps({"capability_id": assignment.capability_id, "event": "evidence-ready", "stem": stem}) + "\n").encode())
    return 0 if probe == "offline-rebuild" or probe is None else 3


def main() -> int:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--repo-root", type=Path, required=True)
    parser.add_argument("--evidence-dir", type=Path, required=True)
    parser.add_argument("--state", type=Path, required=True)
    parser.add_argument("--attempt-id", required=True)
    parser.add_argument("--lane", choices=("compliance", "quality", "manual-qa", "scope"), required=True)
    parser.add_argument("--probe", choices=tuple(PROBE_LANE))
    arguments = parser.parse_args()
    try:
        if ATTEMPT.fullmatch(arguments.attempt_id) is None:
            raise DriverError("attempt_id_invalid")
        if arguments.probe is not None and PROBE_LANE[arguments.probe] != arguments.lane:
            raise DriverError("probe_lane_mismatch")
        assignment = load_assignment(arguments.state, arguments.attempt_id, arguments.lane)
        return run_lane(arguments.repo_root.resolve(strict=True), arguments.evidence_dir.resolve(strict=True), assignment, arguments.probe)
    except (DriverError, OSError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
