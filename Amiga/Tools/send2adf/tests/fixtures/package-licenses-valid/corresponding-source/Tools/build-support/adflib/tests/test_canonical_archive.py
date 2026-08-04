#!/usr/bin/env python3
from __future__ import annotations

import sys
import tarfile
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from stage_adflib import write_deterministic_archive

EXPECTED_FIXTURE_SHA256 = "31392acde9d00fea487124178b2cb9c66c77746c830d1f5fe84ca67df4fd97d8"


class CanonicalArchiveTests(unittest.TestCase):
    def make_source(self, parent: Path, directory_mode: int) -> Path:
        source = parent / f"source-{directory_mode:o}"
        nested = source / "nested"
        nested.mkdir(parents=True)
        source.chmod(directory_mode)
        nested.chmod(directory_mode)
        payload = nested / "payload.txt"
        payload.write_bytes(b"canonical fixture\n")
        payload.chmod(0o600)
        executable = source / "tool.sh"
        executable.write_bytes(b"#!/bin/sh\nexit 0\n")
        executable.chmod(0o700)
        return source

    def test_archive_bytes_ignore_host_directory_and_file_permissions(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary = Path(temporary_directory)
            restrictive = self.make_source(temporary, 0o700)
            permissive = self.make_source(temporary, 0o755)
            restrictive_archive = temporary / "restrictive.tar.gz"
            permissive_archive = temporary / "permissive.tar.gz"
            write_deterministic_archive(restrictive, restrictive_archive)
            write_deterministic_archive(permissive, permissive_archive)
            self.assertEqual(restrictive_archive.read_bytes(), permissive_archive.read_bytes())

    def test_archive_has_golden_bytes_and_canonical_members(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary = Path(temporary_directory)
            source = self.make_source(temporary, 0o700)
            archive = temporary / "fixture.tar.gz"
            digest = write_deterministic_archive(source, archive)
            self.assertEqual(digest, EXPECTED_FIXTURE_SHA256)
            self.assertEqual(archive.read_bytes()[:10], bytes.fromhex("1f8b08000000000002ff"))
            with tarfile.open(archive, "r:gz") as reader:
                members = reader.getmembers()
                self.assertEqual([member.name for member in members], ["nested", "nested/payload.txt", "tool.sh"])
                self.assertEqual([member.mode for member in members], [0o755, 0o644, 0o755])
                self.assertTrue(all(member.uid == 0 and member.gid == 0 and member.mtime == 0 for member in members))


if __name__ == "__main__":
    unittest.main()
