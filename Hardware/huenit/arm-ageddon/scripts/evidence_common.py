from __future__ import annotations

import hashlib
import json
import os
import subprocess
from collections.abc import Mapping, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import NewType

JsonScalar = str | int | float | bool | None
JsonValue = JsonScalar | list["JsonValue"] | dict[str, "JsonValue"]
Sha256 = NewType("Sha256", str)


@dataclass(frozen=True, slots=True)
class EvidenceError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


def sha256_bytes(data: bytes) -> Sha256:
    return Sha256(hashlib.sha256(data).hexdigest())


def sha256_file(path: Path) -> Sha256:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return Sha256(digest.hexdigest())


def sha256_tree(root: Path) -> Sha256:
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            raise EvidenceError("symlink-entry", str(path))
        if path.is_file():
            relative = path.relative_to(root).as_posix().encode()
            digest.update(relative + b"\0" + str(path.stat().st_size).encode() + b"\0" + sha256_file(path).encode() + b"\n")
    return Sha256(digest.hexdigest())


def canonical_json(value: JsonValue) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n").encode()


def read_json(path: Path) -> JsonValue:
    try:
        value: JsonValue = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as error:
        raise EvidenceError("invalid-json", f"{path}: {error}") from error
    return value


def require_mapping(value: JsonValue, label: str) -> dict[str, JsonValue]:
    if not isinstance(value, dict):
        raise EvidenceError("invalid-shape", f"{label} must be an object")
    return value


def require_string(value: JsonValue | None, label: str) -> str:
    if not isinstance(value, str) or not value:
        raise EvidenceError("invalid-string", f"{label} must be a nonempty string")
    return value


def reject_forbidden_outcomes(value: JsonValue) -> None:
    if isinstance(value, str):
        if value.strip().upper() in {"SKIP", "SKIPPED", "NOT_APPLICABLE", "NOT APPLICABLE"}:
            raise EvidenceError("forbidden-outcome", value)
        return
    if isinstance(value, list):
        for item in value:
            reject_forbidden_outcomes(item)
        return
    if isinstance(value, dict):
        for item in value.values():
            reject_forbidden_outcomes(item)


def canonical_existing(path: Path, label: str) -> Path:
    if not path.is_absolute():
        raise EvidenceError("relative-path", f"{label} must be absolute")
    try:
        resolved = path.resolve(strict=True)
    except OSError as error:
        raise EvidenceError("missing-path", f"{label}: {path}") from error
    if path.is_symlink():
        raise EvidenceError("symlink-path", f"{label}: {path}")
    return resolved


def output_under(root: Path, output: Path) -> Path:
    resolved_root = canonical_existing(root, "root")
    if not resolved_root.is_dir():
        raise EvidenceError("invalid-root", f"not a directory: {root}")
    if not output.is_absolute():
        raise EvidenceError("relative-path", "output must be absolute")
    parent = output.parent.resolve(strict=True)
    try:
        parent.relative_to(resolved_root)
    except ValueError as error:
        raise EvidenceError("path-escape", f"output escapes root: {output}") from error
    if output.parent.is_symlink():
        raise EvidenceError("symlink-path", f"output parent is a symlink: {output.parent}")
    return parent / output.name


def exclusive_write(path: Path, data: bytes) -> None:
    flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
    try:
        descriptor = os.open(path, flags, 0o600)
    except FileExistsError as error:
        raise EvidenceError("output-exists", str(path)) from error
    with os.fdopen(descriptor, "wb", closefd=True) as stream:
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())
    directory_fd = os.open(path.parent, os.O_RDONLY)
    try:
        os.fsync(directory_fd)
    finally:
        os.close(directory_fd)


def exclusive_json(path: Path, value: JsonValue) -> None:
    exclusive_write(path, canonical_json(value))


def fsync_parent(path: Path) -> None:
    directory_fd = os.open(path.parent, os.O_RDONLY)
    try:
        os.fsync(directory_fd)
    finally:
        os.close(directory_fd)


def process_identity(pid: int) -> dict[str, JsonValue]:
    result = subprocess.run(["ps", "-p", str(pid), "-o", "lstart=", "-o", "comm="], check=False, capture_output=True, text=True)
    if result.returncode != 0 or not result.stdout.strip():
        raise EvidenceError("missing-process", f"pid {pid}")
    return {"pid": pid, "birthAndCommand": result.stdout.strip()}


def clean_environment(source: Mapping[str, str], allowlist: Sequence[str]) -> dict[str, str]:
    allowed = {name: source[name] for name in allowlist if name in source}
    allowed["PATH"] = source.get("PATH", "/usr/bin:/bin")
    allowed["LANG"] = source.get("LANG", "C.UTF-8")
    allowed["LC_ALL"] = "C"
    return allowed


def executable_hash(argv0: str, environment: Mapping[str, str]) -> tuple[Path, Sha256]:
    candidate = Path(argv0)
    if candidate.parent != Path("."):
        resolved = canonical_existing(candidate.absolute(), "executable")
    else:
        result = subprocess.run(["/usr/bin/which", argv0], env=environment, check=False, capture_output=True, text=True)
        if result.returncode != 0:
            raise EvidenceError("missing-executable", argv0)
        resolved = canonical_existing(Path(result.stdout.strip()), "executable")
    return resolved, sha256_file(resolved)
