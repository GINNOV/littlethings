#!/usr/bin/env python3

from __future__ import annotations

import unittest
from pathlib import Path


PROJECT = Path(__file__).resolve().parents[3] / "ADFinder/ADFinder.xcodeproj/project.pbxproj"
AMIGA_ROOT = Path(__file__).resolve().parents[4]
BUILD_SCRIPT = AMIGA_ROOT / "Tools/build-support/adflib/build-for-xcode.sh"
WORKFLOW_ROOT = AMIGA_ROOT.parent / ".github/workflows"


class ADFinderXcodeContractTests(unittest.TestCase):
    def test_adflib_build_phase_uses_requested_architecture_and_fails_fast(self) -> None:
        project = PROJECT.read_text(encoding="utf-8")

        self.assertNotIn("$(CURRENT_ARCH)", project)
        self.assertEqual(
            project.count('ADFLIB_BUILD_ROOT = "$(DERIVED_FILE_DIR)/adflib/$(CONFIGURATION)/$(ARCHS)";'),
            4,
        )
        self.assertIn(r'set -euo pipefail\narch=\"$ARCHS\"', project)
        self.assertIn(r'\"$CONFIGURATION\" \"$arch\"', project)

    def test_xcode_build_uses_the_provisioning_python_interpreter(self) -> None:
        build_script = BUILD_SCRIPT.read_text(encoding="utf-8")
        build_adfinder = (WORKFLOW_ROOT / "build-adfinder.yml").read_text(encoding="utf-8")
        consumer_ci = (WORKFLOW_ROOT / "adflib-consumers-ci.yml").read_text(encoding="utf-8")

        self.assertIn('PYTHON="${ADFLIB_PYTHON:?adflib_python_required}"', build_script)
        self.assertNotIn('python3 "$STAGER"', build_script)
        self.assertIn('ADFLIB_PYTHON="$(command -v python3)"', build_adfinder)
        self.assertIn('echo "ADFLIB_PYTHON=$ADFLIB_PYTHON" >> "$GITHUB_ENV"', build_adfinder)
        self.assertIn('ADFLIB_PYTHON="$(command -v python3)"', consumer_ci)
        self.assertIn('echo "ADFLIB_PYTHON=$ADFLIB_PYTHON" >> "$GITHUB_ENV"', consumer_ci)


if __name__ == "__main__":
    unittest.main()
