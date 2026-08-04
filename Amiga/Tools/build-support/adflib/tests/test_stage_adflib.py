#!/usr/bin/env python3
"""Behavior tests for the trusted ADFlib source staging boundary."""

from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
STAGER = HERE.parent / "stage_adflib.py"
FIXTURES = HERE / "fixtures"
REQUESTED_TREE = "9a10aa1da9aaf924055e153646ab4d845c7a59e2"


class TrustedTreeResponseTests(unittest.TestCase):
    """Exercise malformed GitHub tree responses through the staging CLI."""

    def run_fixture(self, fixture: str | Path, manifest: str | Path | None = None) -> subprocess.CompletedProcess[str]:
        """Run one response fixture against a real temporary source tree."""
        with tempfile.TemporaryDirectory() as temporary_directory:
            source = Path(temporary_directory) / "source"
            source.mkdir()
            fixture_path = Path(fixture)
            if not fixture_path.is_absolute():
                fixture_path = FIXTURES / fixture_path
            if fixture_path.name.startswith("tree-allowed-symlinks"):
                for name, content in {
                    "ChangeLog": b"changes\n",
                    "INSTALL": b"install\n",
                    "INSTALL.md": b"install\n",
                    "NEWS": b"changes\n",
                    "README": b"readme\n",
                    "README.md": b"readme\n",
                }.items():
                    (source / name).write_bytes(content)
            else:
                (source / "fixture.txt").write_bytes(b"fixture\n")
            command = [
                    sys.executable,
                    str(STAGER),
                    "--verify-tree-response",
                    str(fixture_path),
                    "--requested-tree",
                    REQUESTED_TREE,
                    "--source-root",
                    str(source),
                ]
            if manifest is not None:
                manifest_path = Path(manifest)
                if not manifest_path.is_absolute():
                    manifest_path = FIXTURES / manifest_path
                command.extend(["--manifest", str(manifest_path)])
            return subprocess.run(
                command,
                check=False,
                capture_output=True,
                text=True,
            )

    def run_policy_manifest_replacement(self, old: str, new: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as temporary_directory:
            manifest = Path(temporary_directory) / "manifest.cmake"
            original = (FIXTURES / "symlink-policy-valid.cmake").read_text(encoding="utf-8")
            manifest.write_text(original.replace(old, new), encoding="utf-8")
            return self.run_fixture("tree-allowed-symlinks.json", manifest)

    def run_policy_tree_replacement(self, old: str, new: str) -> subprocess.CompletedProcess[str]:
        with tempfile.TemporaryDirectory() as temporary_directory:
            tree = Path(temporary_directory) / "tree-allowed-symlinks-mutated.json"
            original = (FIXTURES / "tree-allowed-symlinks.json").read_text(encoding="utf-8")
            tree.write_text(original.replace(old, new), encoding="utf-8")
            return self.run_fixture(tree, "symlink-policy-valid.cmake")

    def test_rejects_truncated_tree_when_response_is_incomplete(self) -> None:
        # Given: GitHub marks a recursive tree response as truncated.
        # When: the trusted staging boundary parses that response.
        result = self.run_fixture("tree-truncated.json")
        # Then: it fails closed with a machine-consumable diagnostic.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_truncated", result.stderr)

    def test_rejects_submodule_when_tree_contains_gitlink(self) -> None:
        # Given: the recursive tree contains a Git submodule entry.
        # When: the trusted staging boundary parses that response.
        result = self.run_fixture("tree-submodule.json")
        # Then: it rejects the unsupported entry mode.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_submodule", result.stderr)

    def test_rejects_symlink_when_tree_contains_symlink_mode(self) -> None:
        # Given: the recursive tree contains a symbolic link.
        # When: the trusted staging boundary parses that response.
        result = self.run_fixture("tree-symlink.json")
        # Then: it rejects the link before inspecting source bytes.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_symlink", result.stderr)

    def test_rejects_unsupported_mode_when_tree_mode_is_not_regular(self) -> None:
        # Given: the recursive tree contains an unknown regular-file mode.
        # When: the trusted staging boundary parses that response.
        result = self.run_fixture("tree-unsupported-mode.json")
        # Then: it rejects the mode rather than silently normalizing it.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_unsupported_mode", result.stderr)

    def test_rejects_mismatch_when_response_sha_differs_from_request(self) -> None:
        # Given: GitHub returns a different tree object than was requested.
        # When: the trusted staging boundary parses that response.
        result = self.run_fixture("tree-mismatch.json")
        # Then: it rejects the response identity.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_response_mismatch", result.stderr)

    def test_accepts_complete_matching_regular_tree(self) -> None:
        # Given: the response and extracted regular-file bytes agree exactly.
        # When: the trusted staging boundary validates them.
        result = self.run_fixture("tree-valid.json", "tree-regular-valid.cmake")
        # Then: it reports a verified source tree.
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("source_tree_verified", result.stdout)

    def test_rejects_tree_manifest_digest_mismatch(self) -> None:
        # Given: the response rows are valid but their pinned canonical digest is wrong.
        # When: the trusted staging boundary verifies the response.
        result = self.run_fixture("tree-valid.json", "tree-regular-bad-digest.cmake")
        # Then: it rejects the mismatched canonical identity.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_manifest_mismatch", result.stderr)

    def test_accepts_exact_reviewed_symlinks_when_materialized_as_regular_files(self) -> None:
        # Given: each reviewed symlink and internal target matches the commit-bound policy.
        # When: the trusted staging boundary validates ordinary-file materialization.
        result = self.run_fixture("tree-allowed-symlinks.json", "symlink-policy-valid.cmake")
        # Then: it accepts the exact reviewed exception.
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("source_tree_verified", result.stdout)

    def test_rejects_changed_target_when_blob_still_names_reviewed_target(self) -> None:
        # Given: the policy target changes without the Git symlink blob changing.
        # When: the trusted staging boundary validates the exception.
        result = self.run_fixture("tree-allowed-symlinks.json", "symlink-policy-changed-target.cmake")
        # Then: it rejects the blob-to-target inconsistency.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlink_policy_blob_target_mismatch", result.stderr)

    def test_rejects_changed_symlink_path(self) -> None:
        # Given: an allowlisted symlink moves to an unreviewed path.
        # When: the trusted staging boundary parses the tree.
        result = self.run_policy_tree_replacement('"path":"INSTALL"', '"path":"INSTALL2"')
        # Then: it rejects the unreviewed symlink.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_symlink", result.stderr)

    def test_rejects_changed_symlink_mode(self) -> None:
        # Given: an allowlisted entry changes from the reviewed symlink mode.
        # When: the trusted staging boundary parses the tree.
        result = self.run_policy_tree_replacement('"mode":"120000"', '"mode":"120001"')
        # Then: it rejects the unsupported mode.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_unsupported_mode", result.stderr)

    def test_rejects_changed_symlink_blob(self) -> None:
        # Given: an allowlisted symlink blob differs from the reviewed hash.
        # When: the trusted staging boundary parses the tree.
        result = self.run_policy_tree_replacement(
            "13dc4196d21d2a4eb02a7432c46c31e3b0aa7596",
            "2222222222222222222222222222222222222222",
        )
        # Then: it rejects the policy mismatch.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_symlink_policy_mismatch", result.stderr)

    def test_rejects_absolute_symlink_target(self) -> None:
        # Given: a reviewed target is replaced by an absolute path.
        # When: the trusted staging boundary parses the policy.
        result = self.run_policy_manifest_replacement("INSTALL.md|7c32", "/INSTALL.md|7c32")
        # Then: it rejects the target before tree processing.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlink_policy_target_rejected", result.stderr)

    def test_rejects_escaping_symlink_target(self) -> None:
        # Given: a reviewed target is replaced by a parent-relative path.
        # When: the trusted staging boundary parses the policy.
        result = self.run_policy_manifest_replacement("INSTALL.md|7c32", "../INSTALL.md|7c32")
        # Then: it rejects the escaping target.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("symlink_policy_target_rejected", result.stderr)

    def test_rejects_policy_bound_to_future_commit(self) -> None:
        # Given: dependency commit changes without separately reviewing the allowlist.
        # When: the trusted staging boundary loads the policy.
        result = self.run_policy_manifest_replacement(
            'set(ADFLIB_COMMIT "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")',
            'set(ADFLIB_COMMIT "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb")',
        )
        # Then: it rejects the stale commit binding.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("manifest_invalid", result.stderr)

    def test_rejects_cyclic_symlink_target(self) -> None:
        # Given: a policy and tree consistently describe a self-referential symlink.
        with tempfile.TemporaryDirectory() as temporary_directory:
            temporary = Path(temporary_directory)
            manifest = temporary / "manifest.cmake"
            manifest_text = (FIXTURES / "symlink-policy-valid.cmake").read_text(encoding="utf-8")
            manifest_text = manifest_text.replace(
                "13dc4196d21d2a4eb02a7432c46c31e3b0aa7596|INSTALL.md|7c32f559819ea656fdf8fb45ff9c4c5a3e3c1355",
                "842bf0e100c828ab088c30e90dfdd6d585a34930|INSTALL|842bf0e100c828ab088c30e90dfdd6d585a34930",
            )
            manifest.write_text(manifest_text, encoding="utf-8")
            tree = temporary / "tree-allowed-symlinks-cycle.json"
            tree_text = (FIXTURES / "tree-allowed-symlinks.json").read_text(encoding="utf-8")
            tree.write_text(
                tree_text.replace(
                    "13dc4196d21d2a4eb02a7432c46c31e3b0aa7596",
                    "842bf0e100c828ab088c30e90dfdd6d585a34930",
                ),
                encoding="utf-8",
            )
            # When: the trusted staging boundary validates the exception.
            result = self.run_fixture(tree, manifest)
        # Then: it reports and rejects the cycle.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_tree_symlink_cycle", result.stderr)

    def test_rejects_commit_tree_linkage_mismatch(self) -> None:
        # Given: the commit API object links the requested commit to a different tree.
        # When: the trusted staging boundary verifies commit linkage.
        result = subprocess.run(
            [
                sys.executable,
                str(STAGER),
                "--verify-commit-response",
                str(FIXTURES / "commit-tree-mismatch.json"),
                "--requested-commit",
                "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
                "--requested-tree",
                REQUESTED_TREE,
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        # Then: it rejects the commit-to-tree identity mismatch.
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("git_commit_tree_mismatch", result.stderr)


def main() -> int:
    """Support unittest discovery and the plan's single-case QA interface."""
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", choices=["truncated", "submodule", "symlink", "unsupported", "mismatch"])
    arguments, remaining = parser.parse_known_args()
    if arguments.case is None:
        unittest.main(argv=[sys.argv[0], *remaining])
        return 0
    case_method = {
        "truncated": "test_rejects_truncated_tree_when_response_is_incomplete",
        "submodule": "test_rejects_submodule_when_tree_contains_gitlink",
        "symlink": "test_rejects_symlink_when_tree_contains_symlink_mode",
        "unsupported": "test_rejects_unsupported_mode_when_tree_mode_is_not_regular",
        "mismatch": "test_rejects_mismatch_when_response_sha_differs_from_request",
    }[arguments.case]
    result = unittest.TextTestRunner().run(TrustedTreeResponseTests(case_method))
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    raise SystemExit(main())
