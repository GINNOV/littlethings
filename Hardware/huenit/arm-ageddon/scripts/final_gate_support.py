from __future__ import annotations

import argparse
import json
import os
import subprocess
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, canonical_existing, exclusive_json, fsync_parent, read_json, reject_forbidden_outcomes, sha256_bytes, sha256_file, sha256_tree


def absolute_new_directory(path: Path, label: str) -> Path:
    if not path.is_absolute() or path.is_symlink():
        raise EvidenceError("invalid-root", f"{label} must be an absent absolute directory")
    path.parent.resolve(strict=True)
    try:
        path.mkdir(mode=0o700)
    except FileExistsError as error:
        raise EvidenceError("root-exists", str(path)) from error
    if not path.is_dir() or path.is_symlink() or (path.stat().st_mode & 0o777) != 0o700:
        raise EvidenceError("invalid-root", str(path))
    fsync_parent(path)
    return path


def existing_absolute(path: Path, label: str) -> Path:
    if not path.is_absolute() or path.is_symlink():
        raise EvidenceError("invalid-path", f"{label}: {path}")
    return path.resolve(strict=True)


def path_under(root: Path, path: Path, label: str, require_existing: bool = False) -> Path:
    root_resolved = existing_absolute(root, "isolated-root")
    if not path.is_absolute() or path.is_symlink():
        raise EvidenceError("invalid-path", f"{label}: {path}")
    parent = path.parent.resolve(strict=True)
    try:
        parent.relative_to(root_resolved)
    except ValueError as error:
        raise EvidenceError("path-escape", f"{label}: {path}") from error
    candidate = parent / path.name
    if candidate.exists() and candidate.is_symlink():
        raise EvidenceError("symlink-path", f"{label}: {path}")
    if require_existing:
        return canonical_existing(candidate, label)
    return candidate


def ensure_private_directory(path: Path, label: str) -> Path:
    if not path.is_absolute() or path.is_symlink():
        raise EvidenceError("invalid-path", f"{label}: {path}")
    if path.exists():
        if not path.is_dir() or path.is_symlink() or (path.stat().st_mode & 0o777) != 0o700:
            raise EvidenceError("invalid-directory", f"{label}: {path}")
        return path.resolve(strict=True)
    path.parent.resolve(strict=True)
    path.mkdir(mode=0o700)
    fsync_parent(path)
    return path.resolve(strict=True)


def render_sandbox_profile(template: Path, qa_root: Path) -> bytes:
    text = template.read_text(encoding="utf-8")
    token = '(param "ARMAGEDDON_QA_ROOT")'
    if token not in text:
        raise EvidenceError("sandbox-template-param", str(template))
    quoted = json.dumps(str(qa_root.resolve(strict=True)))
    rendered = text.replace(token, quoted)
    if "(param " in rendered:
        raise EvidenceError("unresolved-sandbox-param", str(template))
    return rendered.encode("utf-8")


def write_source_manifest(path: Path, project_root: Path, commit: str) -> None:
    environment = {
        **os.environ,
        "GIT_CONFIG_NOSYSTEM": "1",
        "GIT_CONFIG_GLOBAL": "/dev/null",
        "GIT_CONFIG_SYSTEM": "/dev/null",
        "GIT_OPTIONAL_LOCKS": "0",
    }
    result = subprocess.run(
        ["/usr/bin/git", "-C", str(project_root), "ls-files", "-s", "--", "."],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    if result.returncode != 0:
        raise EvidenceError("source-manifest", result.stderr.strip())
    entries: list[JsonValue] = []
    for line in result.stdout.splitlines():
        mode, object_id, stage, name = line.split(maxsplit=3)
        entries.append({"mode": mode, "object": object_id, "stage": int(stage), "path": name})
    exclusive_json(path, {"schemaVersion": 1, "commitSHA": commit, "projectRoot": str(project_root), "entries": entries})


def archive_sha256(project_root: Path, commit: str) -> str:
    repo_root_text = subprocess.run(
        ["/usr/bin/git", "-C", str(project_root), "rev-parse", "--show-toplevel"],
        check=False,
        capture_output=True,
        text=True,
        env={**os.environ, "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null", "GIT_OPTIONAL_LOCKS": "0"},
    )
    if repo_root_text.returncode != 0:
        raise EvidenceError("repo-root", repo_root_text.stderr.strip())
    repo_root = Path(repo_root_text.stdout.strip()).resolve(strict=True)
    relative = project_root.resolve(strict=True).relative_to(repo_root).as_posix()
    result = subprocess.run(
        ["/usr/bin/git", "-C", str(repo_root), "archive", "--format=tar", commit, relative],
        check=False,
        capture_output=True,
        env={**os.environ, "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": "/dev/null", "GIT_CONFIG_SYSTEM": "/dev/null", "GIT_OPTIONAL_LOCKS": "0"},
    )
    if result.returncode != 0:
        raise EvidenceError("archive", result.stderr.decode(errors="replace"))
    return str(sha256_bytes(result.stdout))


def artifact_record(path: Path, label: str) -> dict[str, JsonValue]:
    resolved = canonical_existing(path, label)
    if resolved.is_dir():
        digest = sha256_tree(resolved)
        kind = "directory"
    else:
        digest = sha256_file(resolved)
        kind = "file"
    return {"path": str(resolved), "kind": kind, "sha256": digest}


def read_bound_receipt(path: Path, label: str, run_id: str, child_nonce: str, commit: str, archive: str, source_manifest_hash: str) -> dict[str, JsonValue]:
    resolved = canonical_existing(path, label)
    try:
        value = json.loads(resolved.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise EvidenceError("invalid-receipt", f"{label}: {error}") from error
    if not isinstance(value, dict):
        raise EvidenceError("invalid-receipt", label)
    reject_forbidden_outcomes(value)
    for key in ("runID", "parentRunID"):
        if key in value and value[key] != run_id:
            raise EvidenceError("run-mismatch", label)
    if "childNonce" in value and value["childNonce"] != child_nonce:
        raise EvidenceError("nonce-mismatch", label)
    for key in ("commitSHA", "finalCommit"):
        if key in value and value[key] != commit:
            raise EvidenceError("commit-mismatch", label)
    if "expectedArchiveSHA256" in value and value["expectedArchiveSHA256"] != archive:
        raise EvidenceError("archive-mismatch", label)
    for key in ("sourceManifestSHA256", "sourceManifestHash"):
        if key in value and value[key] != source_manifest_hash:
            raise EvidenceError("source-manifest-mismatch", label)
    return value


def validate_context(context: Path, gate: str, run_id: str, child_nonce: str, commit: str, archive: str, source_manifest: Path, root: Path) -> dict[str, JsonValue]:
    value = read_bound_receipt(context, "context", run_id, child_nonce, commit, archive, sha256_file(source_manifest))
    if value.get("kind") != f"{gate}-begin" or value.get("isolatedRoot") != str(root.resolve(strict=True)):
        raise EvidenceError("context-mismatch", str(context))
    if value.get("sourceManifestSHA256") != sha256_file(source_manifest):
        raise EvidenceError("source-manifest-mismatch", str(context))
    return value


def validate_review_receipts(receipts: list[Path], commit: str) -> list[dict[str, JsonValue]]:
    if len(receipts) != 4 or len({path.resolve() for path in receipts}) != 4:
        raise EvidenceError("review-lanes-required", "exactly four distinct receipts are required")
    values: list[dict[str, JsonValue]] = []
    skills: set[str] = set()
    for path in receipts:
        value = read_bound_receipt(path, "review receipt", "", "", commit, "", "")
        transcript_value = value.get("transcript")
        if not isinstance(transcript_value, str):
            raise EvidenceError("review-transcript", str(path))
        transcript = canonical_existing(Path(transcript_value), "review transcript")
        lines = [line.strip() for line in transcript.read_text(encoding="utf-8").splitlines() if line.strip()]
        if not lines or lines[-1] != "VERDICT: PASS" or value.get("verdict") != "PASS":
            raise EvidenceError("review-verdict", str(path))
        if value.get("transcriptSHA256") != sha256_file(transcript) or value.get("skillSHA256") in skills:
            raise EvidenceError("review-integrity", str(path))
        skill = value.get("skillSHA256")
        if not isinstance(skill, str):
            raise EvidenceError("review-skill", str(path))
        skills.add(skill)
        values.append(value)
    return values


def verify_clean_commit(project_root: Path, expected: str) -> None:
    environment = {
        **os.environ,
        "GIT_CONFIG_NOSYSTEM": "1",
        "GIT_CONFIG_GLOBAL": "/dev/null",
        "GIT_CONFIG_SYSTEM": "/dev/null",
        "GIT_OPTIONAL_LOCKS": "0",
    }
    actual = subprocess.run(
        ["/usr/bin/git", "-C", str(project_root), "rev-parse", "HEAD"],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    if actual.returncode != 0 or actual.stdout.strip() != expected:
        raise EvidenceError("commit-mismatch", actual.stdout.strip())
    status = subprocess.run(
        ["/usr/bin/git", "-C", str(project_root), "status", "--porcelain=v2", "--untracked-files=all", "--", "."],
        check=False,
        capture_output=True,
        text=True,
        env=environment,
    )
    if status.returncode != 0:
        raise EvidenceError("git-status", status.stderr.strip())
    if status.stdout:
        raise EvidenceError("source-dirty", "final gates require a byte-empty project-scoped status")


def parser_for(gate: str, phase: str | None) -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--run-id", required=True)
    parser.add_argument("--child-nonce", required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--expected-archive-sha256", required=True)
    parser.add_argument("--source-manifest", required=True, type=Path)
    parser.add_argument("--isolated-root", required=True, type=Path)
    parser.add_argument("--gui-lease-receipt", type=Path)
    if gate == "compliance":
        parser.add_argument("--evidence-root", required=True, type=Path)
        parser.add_argument("--build-root", required=True, type=Path)
        parser.add_argument("--task-1-index", required=True, type=Path)
        parser.add_argument("--task-1-release", required=True, type=Path)
        parser.add_argument("--task-1-schema", required=True, type=Path)
        parser.add_argument("--process-receipt", required=True, type=Path)
        parser.add_argument("--scrub-live-hardware-env", action="store_true")
        parser.add_argument("--exclude-live-schemes", required=True)
        parser.add_argument("--poisoned-env", required=True, type=Path)
        parser.add_argument("--task-mode-manifest", type=Path)
        parser.add_argument("--review-receipts")
        for option in ("require-task-1-provenance-chain", "require-external-build-paths", "require-clean-worktree-after-each-mode", "require-scrubbed-live-environment", "reject-live-test-identifiers", "require-zero-device-opens-writes", "require-xcresult", "require-screenshots", "require-runtime-traces", "verify-sha256", "fresh-after-child-start", "immutable-index"):
            parser.add_argument(f"--{option}", action="store_true")
        parser.add_argument("--require-task-modes", type=int)
    elif gate == "quality":
        parser.add_argument("--base", required=True)
        parser.add_argument("--review-receipts")
    elif phase == "begin":
        parser.add_argument("--fixed-user-home", required=True, type=Path)
        parser.add_argument("--application-support-root", required=True, type=Path)
        parser.add_argument("--cache-root", required=True, type=Path)
        parser.add_argument("--temp-root", required=True, type=Path)
        parser.add_argument("--fixture-root", required=True, type=Path)
        parser.add_argument("--observation-gate", type=Path)
        parser.add_argument("--scope-gate", type=Path)
        parser.add_argument("--preference-suite")
        parser.add_argument("--sandbox-template", type=Path)
        parser.add_argument("--sandbox-output", type=Path)
        parser.add_argument("--runtime-tracer-product")
        parser.add_argument("--sandbox-log-product")
    else:
        parser.add_argument("--scenario", required=gate == "manual-fixture", type=Path)
        for option in ("xcresult", "tested-app", "release-app", "build-receipt", "runtime-paths", "xctest-launch-receipt", "ready-receipt", "hold-receipt", "release-receipt", "xctest-exit-receipt", "screenshots", "observer-report", "app-launch-receipt", "app-ready-receipt", "gate-release-receipt", "app-exit-receipt", "requirements", "filesystem-events", "pre-manifests", "post-manifests", "sandbox-events", "sandbox-profile", "barrier-receipts", "fsevents-ready", "sandbox-ready", "static-network-audit", "bundle-manifest", "signature-receipt", "entitlements"):
            parser.add_argument(f"--{option}", type=Path)
        for option in ("probe-build-receipts", "probe-launch-receipts", "probe-exit-receipts", "stopped-receipts"):
            parser.add_argument(f"--{option}")
        for option in ("require-no-bootstrap-gate", "require-post-journey-test-hold", "fresh-after-child-start", "verify-process-birth", "verify-app-hashes", "verify-process-and-binary", "verify-source-tree", "verify-sha256", "require-ready-flush-stop-barriers", "reject-dropped-events", "require-monotonic-event-ids"):
            parser.add_argument(f"--{option}", action="store_true")
    return parser
