#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Amiga/Tools/build-support/adflib/tests/test_documented_commands.py

from __future__ import annotations

import argparse
import hashlib
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from typing import Final
from urllib.parse import unquote, urlparse

REPOSITORY_ROOT: Final = Path(__file__).resolve().parents[5]
SUPPORT_TESTS: Final = Path(__file__).resolve().parent
SENSITIVE_DOCUMENTS: Final = (
    REPOSITORY_ROOT / "Amiga/Tools/send2adf/README.md",
    REPOSITORY_ROOT / "Amiga/Tools/send2adf/docs/build_adflib.md",
    REPOSITORY_ROOT / "Amiga/Tools/send2adf/docs/learned_lesson.md",
    REPOSITORY_ROOT / "Amiga/Tools/send2adf/docs/releasing.md",
    REPOSITORY_ROOT / "Amiga/Tools/ADFinder/readme.md",
    REPOSITORY_ROOT / "Amiga/Tools/ADFinder/distribution/docs/build_adflib.md",
    REPOSITORY_ROOT / "Amiga/Tools/ADFinder/distribution/docs/README_build_and_package.md",
    REPOSITORY_ROOT / "content/amiga/adfinder_learnmore.md",
)
FORBIDDEN_ACTIVE_TEXT: Final = (
    "file2adf",
    "/usr/local/adflib",
    "git clone https://github.com/adflib/ADFlib",
    "ADFinder-1.2.5_1239.dmg",
    "send2adf.zip",
    "ADFlib/tree/v0.10.2",
)
PUBLIC_PREFIXES: Final = (
    "layouts/",
    "docs/",
    "content/",
    "static/",
    "Amiga/Tools/releases/",
)
ADFinder_PUBLIC_POLICY_FILES: Final = (
    "layouts/amiga/list.html",
    "docs/amiga/index.html",
    "docs/amiga/adfinder_learnmore.html",
    "docs/amiga/index.xml",
    "docs/index.xml",
    "content/amiga/adfinder_learnmore.md",
    "Amiga/Tools/ADFinder/readme.md",
)
SEND2ADF_PUBLIC_POLICY_FILES: Final = (
    "layouts/amiga/list.html",
    "docs/amiga/index.html",
    "Amiga/Tools/send2adf/README.md",
)
CASE_COMMANDS: Final = {
    "bad-hash": [sys.executable, str(REPOSITORY_ROOT / "Amiga/Tools/send2adf/tests/test_build_contract.py"), "--case", "bad-hash"],
    "consumer-incompatible-canary": [sys.executable, str(SUPPORT_TESTS / "test_canary_workflow.py"), "--case", "incompatible-master"],
    "manifest-rollback": [sys.executable, str(SUPPORT_TESTS / "test_update_workflow.py"), "--case", "stable-bootstrap-rollback"],
    "supervisor-missing": [sys.executable, str(SUPPORT_TESTS / "test_final_verification_driver.py"), "--case", "copied-supervisor-binary"],
    "supervisor-digest-mismatch": [sys.executable, str(SUPPORT_TESTS / "test_final_verification_driver.py"), "--case", "install-final-swap"],
}


def run_case(case: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        CASE_COMMANDS[case],
        cwd=REPOSITORY_ROOT,
        check=False,
        capture_output=True,
        text=True,
    )


def audit_public_binary_targets(
    urls: list[str], repository_root: Path
) -> tuple[list[str], set[str]]:
    failures: list[str] = []
    compliant_targets: set[str] = set()
    for url in urls:
        match = re.search(
            r"/GINNOV/littlethings/(?:raw|blob)/master/(.+)$",
            urlparse(url).path,
        )
        if match is None:
            failures.append(f"unverifiable:{url}")
            continue
        relative = unquote(match.group(1))
        target = repository_root / relative
        if not target.is_file():
            failures.append(f"missing:{relative}")
            continue
        inventory = target.parent / "SHA256SUMS"
        inventory_text = (
            inventory.read_text(encoding="utf-8") if inventory.is_file() else ""
        )
        checksum = hashlib.sha256(target.read_bytes()).hexdigest()
        checksum_recorded = re.search(
            rf"^{checksum}\s+\*?{re.escape(target.name)}$",
            inventory_text,
            flags=re.MULTILINE,
        )
        source_assets = tuple(target.parent.glob("*source*.tar.gz")) + tuple(
            target.parent.glob("*source*.zip")
        )
        if checksum_recorded is None or not any(
            source.is_file() and source.stat().st_size > 0 for source in source_assets
        ):
            failures.append(f"noncompliant:{relative}")
            continue
        compliant_targets.add(relative)
    return failures, compliant_targets


class DocumentedContractTests(unittest.TestCase):
    def test_tracked_public_surface_has_no_unavailable_release_claim(self) -> None:
        # Given: every tracked textual website, generated page, feed, and release asset name.
        tracked = subprocess.run(
            ["git", "ls-files", "-z"],
            cwd=REPOSITORY_ROOT,
            check=True,
            capture_output=True,
        ).stdout.decode().split("\0")
        public_paths = [
            path
            for path in tracked
            if path.startswith(PUBLIC_PREFIXES)
            or path in (
                "Amiga/Tools/ADFinder/readme.md",
                "Amiga/Tools/send2adf/README.md",
            )
        ]
        public_text: dict[str, str] = {}
        for relative in public_paths:
            try:
                public_text[relative] = (REPOSITORY_ROOT / relative).read_text(encoding="utf-8")
            except (FileNotFoundError, UnicodeDecodeError):
                continue
        joined = "\n".join(public_text.values())
        direct_binary_urls = re.findall(
            r"https?://[^\s\"'<>)]*(?:ADFinder|send2adf)[^\s\"'<>)]*\.(?:dmg|zip)",
            joined,
            flags=re.IGNORECASE,
        )
        gated_enclosure_urls = re.findall(
            r"<enclosure\b[^>]*\burl=[\"'](https?://[^\"']*(?:ADFinder|send2adf)[^\"']*\.(?:dmg|zip)[^\"']*)[\"'][^>]*>",
            joined,
            flags=re.IGNORECASE,
        )
        target_failures, compliant_targets = audit_public_binary_targets(
            direct_binary_urls, REPOSITORY_ROOT
        )
        active_version_claims = re.findall(
            r"ADFinder\s+1\.2\.\d+[^\n<]{0,100}(?:requires|supports|download|current)",
            joined,
            flags=re.IGNORECASE,
        )
        unpublished_gated_binaries = [
            path
            for path in public_paths
            if re.search(
                r"/(?:ADFinder|send2adf)[^/]*\.(?:dmg|zip)$",
                path,
                flags=re.IGNORECASE,
            )
            and (REPOSITORY_ROOT / path).exists()
            and path not in compliant_targets
        ]
        # When: the no-release policy is parsed semantically across source and generated output.
        policy_missing = [
            relative
            for relative in ADFinder_PUBLIC_POLICY_FILES
            if not re.search(
                r"(?:downloads?|release).{0,160}(?:paused|disabled|unavailable|pending|no replacement)",
                re.sub(r"\s+", " ", public_text.get(relative, "")),
                flags=re.IGNORECASE,
            )
        ]
        send2adf_policy_missing = [
            relative
            for relative in SEND2ADF_PUBLIC_POLICY_FILES
            if not re.search(
                r"(?:no supported public (?:send2adf )?binary|send2adf downloads?.{0,80}(?:paused|disabled|unavailable)|send2adf release.{0,80}(?:pending|blocked))",
                re.sub(r"\s+", " ", public_text.get(relative, "")),
                flags=re.IGNORECASE,
            )
        ]
        # Then: no unavailable release is linked or claimed and every public projection explains the gate.
        self.assertEqual(target_failures, [])
        self.assertTrue(set(gated_enclosure_urls).issubset(direct_binary_urls))
        self.assertEqual(active_version_claims, [])
        self.assertEqual(unpublished_gated_binaries, [])
        self.assertEqual(policy_missing, [])
        self.assertEqual(send2adf_policy_missing, [])

    def test_marked_fenced_commands_execute_from_repository_root(self) -> None:
        # Given: each consumer publishes a marked, fenced local command.
        documents = (
            REPOSITORY_ROOT / "Amiga/Tools/send2adf/README.md",
            REPOSITORY_ROOT / "Amiga/Tools/ADFinder/readme.md",
        )
        commands = []
        for document in documents:
            commands.extend(
                re.findall(
                    r"<!-- documented-command -->\s*```bash\n(.*?)\n```",
                    document.read_text(encoding="utf-8"),
                    flags=re.DOTALL,
                )
            )
        # When: the documentation checker executes the extracted commands verbatim.
        results = [
            subprocess.run(
                command,
                cwd=REPOSITORY_ROOT,
                shell=True,
                executable="/bin/bash",
                check=False,
                capture_output=True,
                text=True,
            )
            for command in commands
        ]
        # Then: both consumer commands exist and exit successfully.
        self.assertEqual(len(results), 2)
        self.assertEqual([result.returncode for result in results], [0, 0])

    def test_public_documentation_has_no_unshipped_download_or_legacy_dependency_path(self) -> None:
        # Given: every user-facing build, usage, and download document in both consumers.
        combined = "\n".join(path.read_text(encoding="utf-8") for path in SENSITIVE_DOCUMENTS)
        # When: retired commands, paths, identities, and unpublished asset names are audited.
        found = [token for token in FORBIDDEN_ACTIVE_TEXT if token in combined]
        # Then: no active documentation can route a user around the shared manifest contract.
        self.assertEqual(found, [])

    def test_compliant_public_binary_target_is_accepted(self) -> None:
        # Given: a future release URL with exact checksum and nonempty corresponding source.
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            relative = "Amiga/Tools/releases/send2adf-1.5.0.zip"
            binary = root / relative
            binary.parent.mkdir(parents=True)
            binary.write_bytes(b"verified send2adf release bytes")
            (binary.parent / "send2adf-1.5.0-source.tar.gz").write_bytes(
                b"complete corresponding source"
            )
            digest = hashlib.sha256(binary.read_bytes()).hexdigest()
            (binary.parent / "SHA256SUMS").write_text(
                f"{digest}  {binary.name}\n", encoding="utf-8"
            )
            url = f"https://github.com/GINNOV/littlethings/raw/master/{relative}"
            # When: the semantic target audit evaluates the candidate.
            failures, compliant = audit_public_binary_targets([url], root)
        # Then: compliant publication is allowed instead of frozen out by absence checks.
        self.assertEqual(failures, [])
        self.assertEqual(compliant, {relative})

    def test_migration_fixture_routes_both_consumers_and_preserves_manifest(self) -> None:
        # Given: the approved stable-upgrade fixture and immutable production manifest bytes.
        manifest = REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"
        before = hashlib.sha256(manifest.read_bytes()).digest()
        # When: the coordinator runs the complete local stable migration transaction.
        result = subprocess.run(
            [sys.executable, str(SUPPORT_TESTS / "test_update_workflow.py"), "--case", "stable-upgrade"],
            cwd=REPOSITORY_ROOT,
            check=False,
            capture_output=True,
            text=True,
        )
        # Then: five consumer legs pass and the isolated fixture does not mutate production bytes.
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(hashlib.sha256(manifest.read_bytes()).digest(), before)

    def test_recovery_commands_fail_closed_without_mutating_manifest(self) -> None:
        # Given: each documented dependency, canary, rollback, and supervisor failure.
        manifest = REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"
        before = hashlib.sha256(manifest.read_bytes()).digest()
        # When: the named local recovery scenarios execute through their real CLIs.
        for case in CASE_COMMANDS:
            with self.subTest(case=case):
                result = run_case(case)
                # Then: the expected rejection is recognized and production bytes stay unchanged.
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(hashlib.sha256(manifest.read_bytes()).digest(), before)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", choices=tuple(CASE_COMMANDS))
    arguments = parser.parse_args()
    if arguments.case is not None:
        result = run_case(arguments.case)
        sys.stdout.write(result.stdout)
        sys.stderr.write(result.stderr)
        return result.returncode
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(DocumentedContractTests)
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
