from __future__ import annotations

import gzip
import hashlib
import io
import json
import stat
import tarfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final, TypeAlias

JsonValue: TypeAlias = str | int | bool | None | list["JsonValue"] | dict[str, "JsonValue"]
JsonMap: TypeAlias = dict[str, JsonValue]
BLOCK_SIZE: Final = 1024 * 1024


@dataclass(frozen=True, slots=True)
class ArchiveError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


@dataclass(frozen=True, slots=True)
class ArchiveEntry:
    name: str
    content: bytes
    executable: bool = False


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(BLOCK_SIZE), b""):
            digest.update(block)
    return digest.hexdigest()


def canonical_json(value: JsonMap) -> bytes:
    return (json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False) + "\n").encode()


def file_entry(name: str, path: Path) -> ArchiveEntry:
    metadata = path.lstat()
    if not stat.S_ISREG(metadata.st_mode):
        raise ArchiveError(f"release input is not a regular file: {path}")
    return ArchiveEntry(name, path.read_bytes(), bool(metadata.st_mode & 0o111))


def tree_entries(root: Path, prefix: str, excluded_parts: frozenset[str]) -> list[ArchiveEntry]:
    entries: list[ArchiveEntry] = []
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        if any(part in excluded_parts for part in relative.parts):
            continue
        metadata = path.lstat()
        if stat.S_ISDIR(metadata.st_mode):
            continue
        if not stat.S_ISREG(metadata.st_mode):
            raise ArchiveError(f"release source contains unsupported file: {path}")
        name = (PurePosixPath(prefix) / PurePosixPath(*relative.parts)).as_posix()
        entries.append(ArchiveEntry(name, path.read_bytes(), bool(metadata.st_mode & 0o111)))
    return entries


def write_tar_gz(output: Path, entries: list[ArchiveEntry], epoch: int) -> None:
    names = [entry.name for entry in entries]
    if len(names) != len(set(names)):
        raise ArchiveError("release archive contains duplicate paths")
    output.parent.mkdir(parents=True, exist_ok=True)
    with (
        output.open("wb") as raw,
        gzip.GzipFile(filename="", mode="wb", fileobj=raw, compresslevel=9, mtime=epoch) as compressed,
        tarfile.open(fileobj=compressed, mode="w", format=tarfile.PAX_FORMAT) as archive,
    ):
        for entry in sorted(entries, key=lambda item: item.name.encode("utf-8")):
            path = PurePosixPath(entry.name)
            if path.is_absolute() or ".." in path.parts:
                raise ArchiveError(f"unsafe release path: {entry.name}")
            info = tarfile.TarInfo(entry.name)
            info.size = len(entry.content)
            info.mode = 0o755 if entry.executable else 0o644
            info.uid = 0
            info.gid = 0
            info.uname = ""
            info.gname = ""
            info.mtime = epoch
            archive.addfile(info, io.BytesIO(entry.content))


def read_archive_entries(archive_path: Path) -> list[ArchiveEntry]:
    entries: list[ArchiveEntry] = []
    try:
        with tarfile.open(archive_path, "r:gz") as archive:
            for member in archive.getmembers():
                path = PurePosixPath(member.name)
                if path.is_absolute() or ".." in path.parts or not member.isfile():
                    raise ArchiveError(f"unsupported archive member: {member.name}")
                stream = archive.extractfile(member)
                if stream is None:
                    raise ArchiveError(f"unreadable archive member: {member.name}")
                entries.append(ArchiveEntry(member.name, stream.read(), bool(member.mode & 0o111)))
    except (OSError, tarfile.TarError) as error:
        raise ArchiveError(f"cannot read release archive: {archive_path}") from error
    return entries
