#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest tests/test_license_inventory.py

from __future__ import annotations

import hashlib
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Final

DEDICATED_PREFIXES: Final = ("license", "copying", "notice", "copyright")
MAX_CLASSIFIED_BYTES: Final = 32 * 1024 * 1024
BINARY_SIGNATURES: Final = (
    b"\x7fELF",
    b"\x89PNG\r\n\x1a\n",
    b"\xff\xd8\xff",
    b"GIF87a",
    b"GIF89a",
    b"PK\x03\x04",
    b"\x1f\x8b",
    b"\xca\xfe\xba\xbe",
    b"\xcf\xfa\xed\xfe",
    b"\xfe\xed\xfa\xcf",
)
NON_UTF8_BOMS: Final = (b"\xff\xfe", b"\xfe\xff", b"\x00\x00\xfe\xff", b"\xff\xfe\x00\x00")
SIGNAL: Final = re.compile(
    rb"SPDX-License-Identifier|copyright|permission\s+is\s+hereby\s+granted|licensed?\s+under|"
    rb"redistribut(?:e|ion)|GNU\s+(?:General|Lesser)\s+Public\s+License",
    re.IGNORECASE,
)
BLOCK_COMMENT: Final = re.compile(rb"/\*.*?\*/", re.DOTALL)
LINE_COMMENT: Final = re.compile(rb"(?m)^[ \t]*(?://|#|;|--)[^\r\n]*(?:\r?\n|$)")


@dataclass(frozen=True, slots=True)
class NoticeRecord:
    path: str
    kind: str
    location: str
    sha256: str


@dataclass(frozen=True, slots=True)
class ClassificationRecord:
    path: str
    kind: str
    reason: str
    sha256: str


@dataclass(frozen=True, slots=True)
class LicenseInventory:
    digest: str
    records: tuple[NoticeRecord, ...]
    ambiguous_paths: tuple[str, ...]
    classifications: tuple[ClassificationRecord, ...]


@dataclass(frozen=True, slots=True)
class InventoryError(Exception):
    code: str
    path: str

    def __str__(self) -> str:
        return f"{self.code}: {self.path}"


def _normalized(content: bytes) -> bytes:
    lines = content.replace(b"\r\n", b"\n").replace(b"\r", b"\n").split(b"\n")
    return b"\n".join(line.rstrip() for line in lines).strip() + b"\n"


def _comment_spans(content: bytes) -> tuple[tuple[int, int], ...]:
    spans = [(match.start(), match.end()) for match in BLOCK_COMMENT.finditer(content)]
    line_spans = [(match.start(), match.end()) for match in LINE_COMMENT.finditer(content)]
    merged_lines: list[tuple[int, int]] = []
    for start, end in line_spans:
        if merged_lines and merged_lines[-1][1] == start:
            previous_start, _ = merged_lines.pop()
            merged_lines.append((previous_start, end))
        else:
            merged_lines.append((start, end))
    return tuple(sorted([*spans, *merged_lines]))


def _record(path: str, kind: str, location: str, content: bytes) -> NoticeRecord:
    return NoticeRecord(path, kind, location, hashlib.sha256(content).hexdigest())


def _classification(path: str, kind: str, reason: str, content: bytes) -> ClassificationRecord:
    return ClassificationRecord(path, kind, reason, hashlib.sha256(content).hexdigest())


def _source_records(path: str, content: bytes) -> tuple[tuple[NoticeRecord, bytes], ...]:
    spans = _comment_spans(content)
    signal_matches = tuple(SIGNAL.finditer(content))
    matching = tuple((start, end) for start, end in spans if SIGNAL.search(content[start:end]) is not None)
    ambiguous = any(not any(start <= match.start() < end for start, end in matching) for match in signal_matches)
    if b"/*" in content and content.rfind(b"/*") > content.rfind(b"*/") and SIGNAL.search(content[content.rfind(b"/*") :]):
        ambiguous = True
    if ambiguous:
        normalized = _normalized(content)
        return ((_record(path, "ambiguous_whole_file", "whole-file", normalized), normalized),)
    result: list[tuple[NoticeRecord, bytes]] = []
    for start, end in matching:
        normalized = _normalized(content[start:end])
        line = content.count(b"\n", 0, start) + 1
        result.append((_record(path, "comment_span", f"line:{line}", normalized), normalized))
    return tuple(result)


def build_inventory(root: Path) -> LicenseInventory:
    records_and_bytes: list[tuple[NoticeRecord, bytes]] = []
    classifications: list[ClassificationRecord] = []
    for path in sorted(root.rglob("*"), key=lambda candidate: candidate.relative_to(root).as_posix().encode()):
        if not path.is_file() or path.is_symlink():
            continue
        relative = path.relative_to(root).as_posix()
        if path.stat().st_size > MAX_CLASSIFIED_BYTES:
            raise InventoryError("license_file_size_limit", relative)
        content = path.read_bytes()
        name = path.name.casefold()
        if name.startswith(DEDICATED_PREFIXES):
            records_and_bytes.append((_record(relative, "dedicated_file", "whole-file", content), content))
            classifications.append(_classification(relative, "dedicated_file", "dedicated_basename", content))
            continue
        if content.startswith(NON_UTF8_BOMS):
            records_and_bytes.append((_record(relative, "ambiguous_whole_file", "whole-file", content), content))
            classifications.append(_classification(relative, "ambiguous_whole_file", "ambiguous_encoding", content))
            continue
        signal_present = SIGNAL.search(content) is not None
        binary_reason = ""
        if content.startswith(BINARY_SIGNATURES):
            binary_reason = "known_binary_signature"
        elif b"\0" in content:
            binary_reason = "nul_byte"
        if binary_reason:
            if signal_present:
                records_and_bytes.append((_record(relative, "ambiguous_whole_file", "whole-file", content), content))
                classifications.append(_classification(relative, "ambiguous_whole_file", "binary_legal_signal", content))
            else:
                classifications.append(_classification(relative, "binary_skipped", binary_reason, content))
            continue
        try:
            content.decode("utf-8", errors="strict")
        except UnicodeDecodeError:
            records_and_bytes.append((_record(relative, "ambiguous_whole_file", "whole-file", content), content))
            classifications.append(_classification(relative, "ambiguous_whole_file", "ambiguous_encoding", content))
            continue
        source_records = _source_records(relative, content)
        records_and_bytes.extend(source_records)
        if source_records and source_records[0][0].kind == "ambiguous_whole_file":
            classifications.append(_classification(relative, "ambiguous_whole_file", "unparsed_legal_signal", content))
        else:
            reason = "complete_comment_spans" if source_records else "no_legal_signal"
            classifications.append(_classification(relative, "text_scanned", reason, content))
    records = tuple(sorted((record for record, _ in records_and_bytes), key=lambda item: (item.path, item.location)))
    legal_items: list[bytes] = []
    for record, content in records_and_bytes:
        if record.kind == "comment_span":
            projection = {"kind": record.kind, "sha256": record.sha256, "bytes": content.hex()}
        else:
            projection = {"kind": record.kind, "path": record.path, "sha256": record.sha256, "bytes": content.hex()}
        legal_items.append(json.dumps(projection, sort_keys=True, separators=(",", ":")).encode())
    digest = hashlib.sha256(b"\n".join(sorted(legal_items))).hexdigest()
    ambiguous_paths = tuple(sorted(record.path for record in records if record.kind == "ambiguous_whole_file"))
    return LicenseInventory(digest, records, ambiguous_paths, tuple(classifications))
