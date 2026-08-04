#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest test_release_resolver.py

from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from release_resolver import ResolverError, Version, parse_version


class StrictVersionTests(unittest.TestCase):
    def test_parses_strict_three_component_release_tag(self) -> None:
        # Given: a canonical ADFlib stable tag.
        # When: the release version is parsed.
        version = parse_version("v0.10.8")
        # Then: numeric comparison components are returned.
        self.assertEqual(version, Version(0, 10, 8))

    def test_rejects_malformed_or_prerelease_tag(self) -> None:
        # Given: tags outside strict vMAJOR.MINOR.PATCH syntax.
        malformed = ("0.10.8", "v0.10", "v0.10.8-rc1", "v01.10.8", "v0.10.08")
        # When/Then: every malformed tag is rejected at the boundary.
        for tag in malformed:
            with self.subTest(tag=tag), self.assertRaises(ResolverError) as raised:
                parse_version(tag)
            self.assertEqual(raised.exception.code, "release_version_invalid")


if __name__ == "__main__":
    unittest.main()
