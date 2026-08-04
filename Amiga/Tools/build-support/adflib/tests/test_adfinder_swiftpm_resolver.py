#!/usr/bin/env python3

from __future__ import annotations

import json
import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[5]
RESOLVER = REPOSITORY_ROOT / "Amiga/Tools/ADFinder/distribution/resolve_swift_packages.py"
LOCKFILE = REPOSITORY_ROOT / (
    "Amiga/Tools/ADFinder/ADFinder.xcodeproj/project.xcworkspace/"
    "xcshareddata/swiftpm/Package.resolved"
)


class ADFinderSwiftPackageResolverTests(unittest.TestCase):
    def test_machine_readable_path_is_the_only_stdout_line(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary = Path(temporary_directory)
            tools = temporary / "bin"
            tools.mkdir()
            revision = json.loads(LOCKFILE.read_text(encoding="utf-8"))["pins"][0]["state"]["revision"]
            xcodebuild = tools / "xcodebuild"
            xcodebuild.write_text(
                "#!/bin/sh\n"
                "printf '%s\\n' 'xcode package diagnostic'\n"
                "while [ \"$#\" -gt 0 ]; do\n"
                "  if [ \"$1\" = '-clonedSourcePackagesDirPath' ]; then shift; root=$1; fi\n"
                "  shift\n"
                "done\n"
                "mkdir -p \"$root/checkouts/Sparkle\"\n"
                "printf '%s\\n' fixture > \"$root/checkouts/Sparkle/source.txt\"\n",
                encoding="utf-8",
            )
            git = tools / "git"
            git.write_text(
                "#!/bin/sh\n"
                f"if [ \"$3\" = 'rev-parse' ]; then printf '%s\\n' '{revision}'; fi\n",
                encoding="utf-8",
            )
            xcodebuild.chmod(xcodebuild.stat().st_mode | stat.S_IXUSR)
            git.chmod(git.stat().st_mode | stat.S_IXUSR)
            environment = os.environ.copy()
            environment["PATH"] = f"{tools}{os.pathsep}{environment['PATH']}"

            result = subprocess.run(
                [
                    "python3",
                    str(RESOLVER),
                    "--project",
                    str(LOCKFILE.parents[3]),
                    "--artifacts",
                    str(temporary / "artifacts"),
                    "--print-source-packages-path",
                ],
                check=False,
                capture_output=True,
                text=True,
                env=environment,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(len(result.stdout.splitlines()), 1, result.stdout)
            self.assertTrue(result.stdout.rstrip().endswith("/SourcePackages"), result.stdout)
            self.assertIn("xcode package diagnostic", result.stderr)


if __name__ == "__main__":
    unittest.main()
