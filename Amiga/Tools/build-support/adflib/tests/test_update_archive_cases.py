#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest test_update_archive_cases.py

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from updater_fixture import UpdaterFixture

ARCHIVE_CASES = (
    "archive-dotdot",
    "archive-absolute",
    "archive-symlink",
    "archive-hardlink",
    "archive-device",
    "archive-duplicate",
    "archive-case-collision",
    "archive-member-limit",
    "archive-size-limit",
    "archive-expansion-limit",
)


def run_archive_case(case: str) -> bool:
    fixture = UpdaterFixture({"source.c": b"int current;\n"}, {"source.c": b"int candidate;\n"})
    try:
        before = fixture.manifest.read_bytes()
        fixture.responses[f"/adflib/ADFlib/archive/{fixture.candidate_commit}.tar.gz"] = (
            200,
            fixture.hostile_archive(fixture.candidate_commit, case),
            "application/gzip",
        )
        result = fixture.run()
        payload = json.loads(result.stdout)
        return result.returncode == 2 and payload["code"].startswith("archive_") and fixture.manifest.read_bytes() == before
    finally:
        fixture.close()


class UpdaterArchiveFailureTests(unittest.TestCase):
    def test_hostile_archive_cases_fail_before_manifest_mutation(self) -> None:
        # Given: every hostile archive class required by the updater contract.
        # When: each archive is served to the real updater CLI.
        # Then: stable diagnostics fail closed before the manifest changes.
        for case in ARCHIVE_CASES:
            with self.subTest(case=case):
                self.assertTrue(run_archive_case(case))


if __name__ == "__main__":
    unittest.main()
