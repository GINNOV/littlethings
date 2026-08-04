from __future__ import annotations

import hashlib
import tarfile
from dataclasses import dataclass
from pathlib import Path, PurePosixPath
from typing import Final

NOTICE_DIGESTS: Final = {
    "src/adflib.c": "fdbfd5e6d33a7a7c1abe3a3d762d73cfcaf97e6aeda47521ca1d0741d65561f3",
    "src/adf_version.h": "c46ae63854de4b498de569d284da0fa9a05426ac5daf4db3af9099a810396d55",
    "src/adf_limits.h": "92fd890fee7a1abdc50a865fb347c4b1c9835eff37be3006da8063faef831725",
}


@dataclass(frozen=True, slots=True)
class PackageMaterialError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


@dataclass(frozen=True, slots=True)
class SourceArchiveContract:
    archive: Path
    source_root: Path
    archive_root: str
    expected_paths: frozenset[str]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate_license_files(root: Path, source_root: Path, adflib_source_path: str) -> None:
    repository_license = Path(__file__).resolve().parents[4] / "LICENSE"
    if sha256(root / "LICENSE") != sha256(repository_license):
        raise PackageMaterialError("repository MIT license mismatch")
    bundled_gpl = Path(__file__).resolve().parents[1] / "licenses" / "GPL-2.0.txt"
    if sha256(root / "LICENSES" / "GPL-2.0.txt") != sha256(bundled_gpl):
        raise PackageMaterialError("GPL-2.0 license text mismatch")
    copying = root / "ADFlib" / "COPYING"
    if sha256(copying) != "20e50fe7aae3e56378ebf0417d9de904f55a0e61e4df315333e632a4d3555d95":
        raise PackageMaterialError("ADFlib COPYING mismatch")
    pristine_root = source_root / adflib_source_path
    if sha256(copying) != sha256(pristine_root / "COPYING"):
        raise PackageMaterialError("ADFlib COPYING is not pristine")
    notice_root = root / "ADFlib" / "source-notices"
    for relative, expected_digest in NOTICE_DIGESTS.items():
        notice = notice_root / relative
        if not notice.is_file():
            raise PackageMaterialError(f"missing: ADFlib/source-notices/{relative}")
        if sha256(notice) != expected_digest or sha256(notice) != sha256(pristine_root / relative):
            raise PackageMaterialError(f"ADFlib source notice mismatch: {relative}")


def validate_required_notices(root: Path) -> None:
    for relative in NOTICE_DIGESTS:
        if not (root / "ADFlib" / "source-notices" / relative).is_file():
            raise PackageMaterialError(f"missing: ADFlib/source-notices/{relative}")


def validate_source_archive(contract: SourceArchiveContract) -> None:
    if contract.archive.stat().st_size == 0:
        raise PackageMaterialError("corresponding source archive is empty")
    try:
        with tarfile.open(contract.archive, "r:*") as source:
            archived_paths: set[str] = set()
            for member in source.getmembers():
                member_path = PurePosixPath(member.name)
                if member_path.is_absolute() or ".." in member_path.parts:
                    raise PackageMaterialError(f"unsafe source archive member: {member.name}")
                if not member_path.parts or member_path.parts[0] != contract.archive_root:
                    raise PackageMaterialError(f"unexpected source archive root: {member.name}")
                relative = PurePosixPath(*member_path.parts[1:])
                if member.isdir() or not relative.parts:
                    continue
                if not member.isfile():
                    raise PackageMaterialError(f"unsupported source archive member: {member.name}")
                relative_text = relative.as_posix()
                if relative_text in archived_paths:
                    raise PackageMaterialError(f"duplicate source archive member: {relative_text}")
                archived_paths.add(relative_text)
                stream = source.extractfile(member)
                if stream is None or stream.read() != (contract.source_root / relative_text).read_bytes():
                    raise PackageMaterialError(f"source archive content mismatch: {relative_text}")
            if archived_paths != contract.expected_paths:
                raise PackageMaterialError("source archive inventory mismatch")
    except (OSError, tarfile.TarError) as error:
        raise PackageMaterialError("corresponding source archive is not inspectable") from error
