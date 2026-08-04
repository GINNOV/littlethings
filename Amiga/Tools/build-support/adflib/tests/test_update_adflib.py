#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest test_update_adflib.py

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from test_update_archive_cases import ARCHIVE_CASES, run_archive_case
from updater_fixture import FixtureHandler, UpdaterFixture

NOTICE = b"/* SPDX-License-Identifier: GPL-2.0-or-later */\n"


class StableUpdaterIntegrationTests(unittest.TestCase):
    def fixture(self, candidate: bytes = NOTICE + b"int candidate;\n") -> UpdaterFixture:
        fixture = UpdaterFixture({"source.c": NOTICE + b"int current;\n"}, {"source.c": candidate})
        self.addCleanup(fixture.close)
        return fixture

    def test_dry_run_reports_upgrade_without_changing_manifest(self) -> None:
        # Given: a newer stable release changes code but preserves approved notices.
        fixture = self.fixture()
        before = fixture.manifest.read_bytes()
        # When: the updater runs in dry-run mode through its CLI.
        result = fixture.run("--dry-run")
        # Then: JSON reports all new identity fields and no file changes.
        self.assertEqual(result.returncode, 0, result.stderr)
        payload = json.loads(result.stdout)
        self.assertTrue(payload["changed"])
        self.assertEqual(payload["status"], "dry_run")
        self.assertEqual(payload["new"]["version"], "0.10.8")
        self.assertEqual(len(payload["archive_sha256"]), 64)
        self.assertEqual(fixture.manifest.read_bytes(), before)

    def test_check_reports_available_with_exit_one_and_no_mutation(self) -> None:
        # Given: a newer approved stable release and an unchanged manifest.
        fixture = self.fixture()
        before = fixture.manifest.read_bytes()
        # When: check mode evaluates the candidate.
        result = fixture.run("--check")
        # Then: availability is machine-visible through exit one and JSON only.
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual(json.loads(result.stdout)["status"], "update_available")
        self.assertEqual(fixture.manifest.read_bytes(), before)

    def test_update_changes_exactly_six_manifest_fields(self) -> None:
        # Given: an approved code-only stable upgrade and its original manifest lines.
        fixture = self.fixture()
        before = fixture.manifest.read_text(encoding="utf-8").splitlines()
        # When: update mode writes the candidate identity.
        result = fixture.run()
        # Then: exactly the six stable identity assignments differ.
        self.assertEqual(result.returncode, 0, result.stderr)
        after = fixture.manifest.read_text(encoding="utf-8").splitlines()
        changed = [old for old, new in zip(before, after, strict=True) if old != new]
        self.assertEqual(len(changed), 6)
        self.assertEqual(
            {line.split(" ", 1)[0] for line in changed},
            {
                "set(ADFLIB_VERSION",
                "set(ADFLIB_TAG",
                "set(ADFLIB_COMMIT",
                "set(ADFLIB_TREE_SHA",
                "set(ADFLIB_ARCHIVE_URL",
                "set(ADFLIB_TREE_MANIFEST_SHA256",
            },
        )
        self.assertEqual(json.loads(result.stdout)["status"], "updated")

    def test_current_release_is_noop(self) -> None:
        # Given: latest resolves to the exact current tag, commit, and tree.
        fixture = self.fixture()
        fixture.release["tag_name"] = "v0.10.7"
        fixture.release["target_commitish"] = fixture.current_commit
        fixture.responses["/repos/adflib/ADFlib/releases/latest"] = fixture.json_response(fixture.release)
        fixture.responses["/repos/adflib/ADFlib/git/ref/tags/v0.10.7"] = fixture.json_response(
            {"ref": "refs/tags/v0.10.7", "object": {"type": "commit", "sha": fixture.current_commit}}
        )
        fixture.responses[f"/repos/adflib/ADFlib/git/commits/{fixture.current_commit}"] = fixture.json_response(
            {"sha": fixture.current_commit, "tree": {"sha": fixture.current_tree}}
        )
        _, _, entries = fixture.tree(fixture.current_files)
        fixture.responses[f"/repos/adflib/ADFlib/git/trees/{fixture.current_tree}?recursive=1"] = fixture.json_response(
            {"sha": fixture.current_tree, "truncated": False, "tree": entries}
        )
        # When: check mode evaluates the exact current release.
        result = fixture.run("--check")
        # Then: it exits zero, reports current, and never downloads an archive.
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout)["status"], "current")
        self.assertFalse(any("/archive/" in path for path in FixtureHandler.requests))

    def test_draft_and_prerelease_are_ignored(self) -> None:
        # Given: GitHub marks latest as unstable in each supported way.
        for field in ("draft", "prerelease"):
            with self.subTest(field=field):
                fixture = self.fixture()
                fixture.release[field] = True
                fixture.responses["/repos/adflib/ADFlib/releases/latest"] = fixture.json_response(fixture.release)
                # When: stable selection runs.
                result = fixture.run("--check")
                # Then: unstable data is ignored without a manifest change.
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(json.loads(result.stdout)["status"], "no_stable_candidate")

    def test_older_release_is_rejected(self) -> None:
        # Given: latest claims an older stable semantic version.
        fixture = self.fixture()
        fixture.release["tag_name"] = "v0.10.6"
        fixture.responses["/repos/adflib/ADFlib/releases/latest"] = fixture.json_response(fixture.release)
        fixture.responses["/repos/adflib/ADFlib/git/ref/tags/v0.10.6"] = fixture.json_response(
            {"ref": "refs/tags/v0.10.6", "object": {"type": "commit", "sha": fixture.candidate_commit}}
        )
        # When: the updater compares versions.
        result = fixture.run()
        # Then: downgrade fails closed.
        self.assertEqual(result.returncode, 2)
        self.assertEqual(json.loads(result.stdout)["code"], "release_downgrade")

    def test_malformed_release_and_tag_commit_mismatch_are_rejected(self) -> None:
        # Given: malformed JSON or a release SHA different from its resolved tag.
        fixture = self.fixture()
        fixture.responses["/repos/adflib/ADFlib/releases/latest"] = (200, b"{", "application/json")
        malformed = fixture.run()
        fixture.responses["/repos/adflib/ADFlib/releases/latest"] = fixture.json_response(fixture.release)
        fixture.release["target_commitish"] = "c" * 40
        fixture.responses["/repos/adflib/ADFlib/releases/latest"] = fixture.json_response(fixture.release)
        mismatch = fixture.run()
        # When/Then: each boundary failure exits two with stable diagnostics.
        self.assertEqual(json.loads(malformed.stdout)["code"], "release_json_invalid")
        self.assertEqual(json.loads(mismatch.stdout)["code"], "tag_commit_mismatch")

    def test_truncated_tree_and_equal_version_retag_are_rejected(self) -> None:
        # Given: one truncated tree response and one moving equal-version tag.
        fixture = self.fixture()
        tree_path = f"/repos/adflib/ADFlib/git/trees/{fixture.candidate_tree}?recursive=1"
        fixture.responses[tree_path] = fixture.json_response(
            {"sha": fixture.candidate_tree, "truncated": True, "tree": []}
        )
        truncated = fixture.run()
        fixture.responses[tree_path] = fixture.json_response(
            {"sha": fixture.candidate_tree, "truncated": False, "tree": fixture.tree(fixture.candidate_files)[2]}
        )
        fixture.release["tag_name"] = "v0.10.7"
        fixture.responses["/repos/adflib/ADFlib/releases/latest"] = fixture.json_response(fixture.release)
        fixture.responses["/repos/adflib/ADFlib/git/ref/tags/v0.10.7"] = fixture.json_response(
            {"ref": "refs/tags/v0.10.7", "object": {"type": "commit", "sha": fixture.candidate_commit}}
        )
        retagged = fixture.run()
        # When/Then: both immutable identity violations fail closed.
        self.assertEqual(json.loads(truncated.stdout)["code"], "git_tree_truncated")
        self.assertEqual(json.loads(retagged.stdout)["code"], "release_retagged")

    def test_annotated_tag_is_peeled_and_cycle_is_rejected(self) -> None:
        # Given: latest first resolves through one annotated tag object.
        fixture = self.fixture()
        tag_object = "d" * 40
        ref_path = "/repos/adflib/ADFlib/git/ref/tags/v0.10.8"
        object_path = f"/repos/adflib/ADFlib/git/tags/{tag_object}"
        fixture.responses[ref_path] = fixture.json_response(
            {"ref": "refs/tags/v0.10.8", "object": {"type": "tag", "sha": tag_object}}
        )
        fixture.responses[object_path] = fixture.json_response(
            {"sha": tag_object, "object": {"type": "commit", "sha": fixture.candidate_commit}}
        )
        # When: the updater peels the annotated object.
        peeled = fixture.run("--dry-run")
        # Then: the commit candidate proceeds, while a self-cycle fails closed.
        self.assertEqual(peeled.returncode, 0, peeled.stderr)
        fixture.responses[object_path] = fixture.json_response(
            {"sha": tag_object, "object": {"type": "tag", "sha": tag_object}}
        )
        cyclic = fixture.run()
        self.assertEqual(json.loads(cyclic.stdout)["code"], "tag_cycle")

    def test_changed_late_or_ambiguous_license_requires_review(self) -> None:
        # Given: changed legal text appears late or outside a parseable comment.
        candidates = (
            b"int x;\n" * 1_100 + b"/* SPDX-License-Identifier: MIT */\n",
            b'const char *notice = "SPDX-License-Identifier: MIT";\n',
        )
        # When: each candidate crosses the complete legal inventory boundary.
        for candidate in candidates:
            with self.subTest(candidate=candidate[-20:]):
                fixture = self.fixture(candidate)
                result = fixture.run()
                # Then: exit three writes only the evidence review report.
                self.assertEqual(result.returncode, 3, result.stderr)
                payload = json.loads(result.stdout)
                self.assertEqual(payload["status"], "license_review_required")
                self.assertTrue(fixture.evidence.joinpath(payload["report"].split("/")[-1]).is_file())

    def test_added_removed_changed_and_dedicated_rename_require_review(self) -> None:
        # Given: each legal multiset mutation class is represented by a candidate.
        scenarios = (
            ({"source.c": NOTICE}, {"source.c": NOTICE + b"/* Copyright 2026 Added */\n"}),
            ({"source.c": NOTICE}, {"source.c": b"int no_notice;\n"}),
            ({"source.c": NOTICE}, {"source.c": b"/* SPDX-License-Identifier: MIT */\n"}),
            ({"LICENSE": b"terms\n"}, {"COPYING": b"terms\n"}),
        )
        # When: each candidate is evaluated through the updater.
        for current, candidate in scenarios:
            with self.subTest(candidate=tuple(candidate)):
                fixture = UpdaterFixture(current, candidate)
                self.addCleanup(fixture.close)
                result = fixture.run()
                # Then: every addition, removal, change, or dedicated rename exits three.
                self.assertEqual(result.returncode, 3, result.stderr)

    def test_candidate_wide_java_notice_and_binary_classification_reach_report(self) -> None:
        # Given: an unfamiliar candidate adds Main.java legal text and an unrelated binary.
        current = {"source.c": NOTICE + b"int current;\n"}
        candidate = {
            "source.c": NOTICE + b"int current;\n",
            "Main.java": b"// SPDX-License-Identifier: MIT\nclass Main {}\n",
            "icon.bin": b"\x89PNG\r\n\x1a\n\x00binary",
        }
        fixture = UpdaterFixture(current, candidate)
        self.addCleanup(fixture.close)
        # When: the updater builds its candidate-wide legal report.
        result = fixture.run()
        report = json.loads(Path(json.loads(result.stdout)["report"]).read_text(encoding="utf-8"))
        classifications = {item["path"]: item for item in report["classifications"]}
        # Then: Java triggers review and the binary skip carries an explicit reason.
        self.assertEqual(result.returncode, 3, result.stderr)
        self.assertIn("Main.java", {record["path"] for record in report["records"]})
        self.assertEqual(classifications["icon.bin"]["kind"], "binary_skipped")
        self.assertEqual(classifications["icon.bin"]["reason"], "known_binary_signature")

    def test_exact_approval_entry_and_postmerge_receipt_allow_changed_inventory(self) -> None:
        # Given: a changed notice first produces a fail-closed review report.
        fixture = self.fixture(b"/* SPDX-License-Identifier: MIT */\n")
        first = fixture.run()
        report = json.loads(Path(json.loads(first.stdout)["report"]).read_text(encoding="utf-8"))
        corresponding_digest = hashlib.sha256(
            json.dumps(report["corresponding_source"], sort_keys=True, separators=(",", ":")).encode()
        ).hexdigest()
        projection = {
            "schema_version": 1,
            "approval_pr_number": 42,
            "reviewer_login": "legal-reviewer",
            "reviewer_user_id": 1234,
            "approved_at": "2026-08-03T12:00:00Z",
            "candidate_commit": fixture.candidate_commit,
            "license_inventory_sha256": report["license_inventory_sha256"],
            "corresponding_source_sha256": corresponding_digest,
        }
        entry = {**projection, "entry_digest": hashlib.sha256(json.dumps(projection, sort_keys=True, separators=(",", ":")).encode()).hexdigest()}
        ledger = json.loads(fixture.ledger.read_text(encoding="utf-8"))
        ledger["approvals"] = [entry]
        fixture.ledger.write_text(json.dumps(ledger), encoding="utf-8")
        receipt = fixture.root / "postmerge-receipt.json"
        receipt.write_text(
            json.dumps(
                {
                    "schema_version": 1,
                    "merge_commit": "c" * 40,
                    "approved_ledger_sha256": hashlib.sha256(fixture.ledger.read_bytes()).hexdigest(),
                    "approval_entry_digest": entry["entry_digest"],
                    "candidate_commit": fixture.candidate_commit,
                    "license_inventory_sha256": report["license_inventory_sha256"],
                    "corresponding_source_sha256": corresponding_digest,
                    "tree_contains_ledger": True,
                }
            ),
            encoding="utf-8",
        )
        # When: the updater receives that exact external receipt.
        approved = fixture.run("--approval-receipt", str(receipt), "--dry-run")
        # Then: only the exact candidate and inventory are permitted.
        self.assertEqual(approved.returncode, 0, approved.stderr)
        self.assertEqual(json.loads(approved.stdout)["status"], "dry_run")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case")
    arguments, remaining = parser.parse_known_args()
    if arguments.case is not None:
        if arguments.case == "tag-commit-mismatch":
            return 0 if unittest.TextTestRunner().run(StableUpdaterIntegrationTests("test_malformed_release_and_tag_commit_mismatch_are_rejected")).wasSuccessful() else 1
        if arguments.case in ARCHIVE_CASES:
            return 0 if run_archive_case(arguments.case) else 1
        return 1
    unittest.main(argv=[sys.argv[0], *remaining])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
