#!/usr/bin/env python3

from __future__ import annotations

import unittest
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[3] / "ADFinder/ADFinder.xcodeproj/project.pbxproj"


class ADFinderXcodeContractTests(unittest.TestCase):
    def test_adflib_build_phase_uses_requested_architecture_and_fails_fast(self) -> None:
        project = PROJECT.read_text(encoding="utf-8")

        self.assertNotIn("$(CURRENT_ARCH)", project)
        self.assertIn('ADFLIB_BUILD_ROOT = "$(DERIVED_FILE_DIR)/adflib/$(CONFIGURATION)/$(ARCHS)";', project)
        self.assertIn(r'set -euo pipefail\narch=\"$ARCHS\"', project)
        self.assertIn(r'\"$CONFIGURATION\" \"$arch\"', project)


if __name__ == "__main__":
    unittest.main()
