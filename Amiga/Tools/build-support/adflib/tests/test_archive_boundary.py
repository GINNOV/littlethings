#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest test_archive_boundary.py

from __future__ import annotations

import io
import sys
import tarfile
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from archive_boundary import (
    ApprovedSymlink,
    ArchiveError,
    ExtractionLimits,
    ExtractionPolicy,
    extract_archive,
)
from stage_adflib import safe_extract as stage_safe_extract


class HostileArchiveBoundaryTests(unittest.TestCase):
    def make_archive(self, root: Path, members: list[tuple[tarfile.TarInfo, bytes]]) -> Path:
        archive = root / "fixture.tar.gz"
        with tarfile.open(archive, "w:gz") as stream:
            for info, content in members:
                stream.addfile(info, io.BytesIO(content) if info.isfile() else None)
        return archive

    def regular(self, name: str, content: bytes) -> tuple[tarfile.TarInfo, bytes]:
        info = tarfile.TarInfo(name)
        info.size = len(content)
        info.mode = 0o644
        return info, content

    def assert_rejected(self, members: list[tuple[tarfile.TarInfo, bytes]], code: str) -> None:
        # Given: one hostile member is inside an otherwise private archive.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            archive = self.make_archive(root, members)
            destination = root / "extract"
            # When: extraction crosses the shared archive boundary.
            with self.assertRaises(ArchiveError) as raised:
                extract_archive(archive, destination, ExtractionPolicy("ADFlib-a"))
            # Then: the stable diagnostic is returned and the private root is removed.
            self.assertEqual(raised.exception.code, code)
            self.assertFalse(destination.exists())

    def test_extracts_regular_member_when_archive_is_valid(self) -> None:
        # Given: a small commit-rooted archive contains one ordinary file.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            archive = self.make_archive(root, [self.regular("ADFlib-a/src/file.c", b"content\n")])
            destination = root / "extract"
            # When: the archive is extracted.
            extract_archive(archive, destination, ExtractionPolicy("ADFlib-a"))
            # Then: only the normalized relative file is materialized.
            self.assertEqual((destination / "src/file.c").read_bytes(), b"content\n")

    def test_stage_wrapper_accepts_descriptor_private_empty_root(self) -> None:
        # Given: Todo 1 has already created its private empty extraction root.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            archive = self.make_archive(root, [self.regular("ADFlib-a/file", b"content\n")])
            destination = root / "extract"
            destination.mkdir(mode=0o700)
            # When: the legacy staging wrapper delegates to the shared extractor.
            stage_safe_extract(archive, destination, "a", {})
            # Then: the existing cold-connected staging contract is preserved.
            self.assertEqual((destination / "file").read_bytes(), b"content\n")

    def test_rejects_parent_path(self) -> None:
        self.assert_rejected([self.regular("ADFlib-a/../escape", b"x")], "archive_parent_path")

    def test_rejects_absolute_path(self) -> None:
        self.assert_rejected([self.regular("/ADFlib-a/escape", b"x")], "archive_absolute_path")

    def test_rejects_duplicate_normalized_path(self) -> None:
        self.assert_rejected(
            [self.regular("ADFlib-a/file", b"x"), self.regular("ADFlib-a/./file", b"y")],
            "archive_duplicate_path",
        )

    def test_rejects_casefold_collision(self) -> None:
        self.assert_rejected(
            [self.regular("ADFlib-a/README", b"x"), self.regular("ADFlib-a/readme", b"y")],
            "archive_casefold_collision",
        )

    def test_rejects_symbolic_link(self) -> None:
        link = tarfile.TarInfo("ADFlib-a/link")
        link.type = tarfile.SYMTYPE
        link.linkname = "file"
        self.assert_rejected([(link, b"")], "archive_link_rejected")

    def test_materializes_exact_approved_symbolic_link_as_regular_file(self) -> None:
        # Given: a symbolic link and target exactly match a reviewed materialization rule.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            link = tarfile.TarInfo("ADFlib-a/README")
            link.type = tarfile.SYMTYPE
            link.linkname = "README.md"
            archive = self.make_archive(
                root,
                [self.regular("ADFlib-a/README.md", b"readme\n"), (link, b"")],
            )
            destination = root / "extract"
            # When: extraction receives the exact approved link contract.
            extract_archive(
                archive,
                destination,
                ExtractionPolicy(
                    "ADFlib-a",
                    approved_symlinks=(ApprovedSymlink("README", "README.md"),),
                ),
            )
            # Then: the link is emitted as a no-follow regular-file copy.
            self.assertEqual((destination / "README").read_bytes(), b"readme\n")
            self.assertFalse((destination / "README").is_symlink())

    def test_rejects_hard_link(self) -> None:
        link = tarfile.TarInfo("ADFlib-a/link")
        link.type = tarfile.LNKTYPE
        link.linkname = "ADFlib-a/file"
        self.assert_rejected([(link, b"")], "archive_link_rejected")

    def test_rejects_device(self) -> None:
        device = tarfile.TarInfo("ADFlib-a/device")
        device.type = tarfile.CHRTYPE
        self.assert_rejected([(device, b"")], "archive_unsupported_type")

    def test_rejects_member_limit(self) -> None:
        # Given: the configured member budget is smaller than the archive.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            archive = self.make_archive(
                root,
                [self.regular("ADFlib-a/one", b"1"), self.regular("ADFlib-a/two", b"2")],
            )
            destination = root / "extract"
            # When: extraction reaches the second member.
            with self.assertRaises(ArchiveError) as raised:
                extract_archive(archive, destination, ExtractionPolicy("ADFlib-a", ExtractionLimits(members=1)))
            # Then: it rejects and removes the private root.
            self.assertEqual(raised.exception.code, "archive_member_limit")
            self.assertFalse(destination.exists())

    def test_rejects_per_member_size_limit(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            archive = self.make_archive(root, [self.regular("ADFlib-a/file", b"12")])
            with self.assertRaises(ArchiveError) as raised:
                extract_archive(
                    archive,
                    root / "extract",
                    ExtractionPolicy("ADFlib-a", ExtractionLimits(member_bytes=1)),
                )
            self.assertEqual(raised.exception.code, "archive_member_size_limit")

    def test_rejects_total_size_limit(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            archive = self.make_archive(
                root,
                [self.regular("ADFlib-a/one", b"1"), self.regular("ADFlib-a/two", b"2")],
            )
            with self.assertRaises(ArchiveError) as raised:
                extract_archive(
                    archive,
                    root / "extract",
                    ExtractionPolicy("ADFlib-a", ExtractionLimits(total_bytes=1)),
                )
            self.assertEqual(raised.exception.code, "archive_total_size_limit")

    def test_rejects_expansion_limit(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            self.make_archive(root, [self.regular("ADFlib-a/file", b"0" * 10_000)])
            with self.assertRaises(ArchiveError) as raised:
                extract_archive(
                    root / "fixture.tar.gz",
                    root / "extract",
                    ExtractionPolicy("ADFlib-a", ExtractionLimits(expansion_ratio=1)),
                )
            self.assertEqual(raised.exception.code, "archive_expansion_limit")


if __name__ == "__main__":
    unittest.main()
