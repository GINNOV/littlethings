#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# pyright: reportImplicitRelativeImport=false
# ─── How to run ───
# python3 -m unittest test_stable_update_state.py

from __future__ import annotations

import os
import stat
import subprocess
import sys
import tempfile
import time
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from dataclasses import replace

from stable_update_state import (
    STABLE_BRANCH,
    STABLE_LEASE,
    Candidate,
    CoordinatorError,
    FakeGitHub,
    RunIdentity,
    attest_supplemental,
    create_validation_pair,
    digest,
    mark_supplemental_ready,
    promote_candidate,
    reconcile_validation,
    recover_owned,
)


class StableUpdateStateTests(unittest.TestCase):
    def test_refresh_rejects_foreign_lease_before_mutation(self) -> None:
        # Given: a branch and PR exist behind a lease created by a foreign workflow run.
        api = FakeGitHub.owned_active(creator_app_id=7)
        candidate = Candidate.fixture()
        before = api.mutation_count
        # When: the production coordinator authenticates refresh ownership.
        with self.assertRaisesRegex(CoordinatorError, "lease_app_mismatch"):
            promote_candidate(api, candidate, expected_app_id=42)
        # Then: no lease, branch, or PR mutation occurs.
        self.assertEqual(api.mutation_count, before)

    def test_bootstrap_and_refresh_resume_after_every_mutation_boundary(self) -> None:
        # Given: each possible post-mutation runner-loss boundary in a fresh bootstrap.
        baseline = FakeGitHub(); candidate = Candidate.fixture(); baseline.runs[200] = RunIdentity(200, "GINNOV/littlethings", ".github/workflows/adflib-update.yml", 42, candidate.workflow_source_sha)
        promote_candidate(baseline, candidate, 42)
        mutation_boundaries = baseline.mutation_count
        for boundary in range(1, mutation_boundaries + 1):
            with self.subTest(boundary=boundary):
                api = FakeGitHub(); api.runs[200] = baseline.runs[200]; api.fail_on_mutation = boundary
                # When: mutation succeeds but the runner dies before its readback, then a new run reconciles.
                with self.assertRaisesRegex(CoordinatorError, "injected_mutation_failure"):
                    promote_candidate(api, candidate, 42)
                api.fail_on_mutation = None
                pr = promote_candidate(api, candidate, 42)
                # Then: only the unique next transition runs and exact active ownership is restored.
                self.assertEqual(api.get_ref(STABLE_BRANCH), candidate.tip)
                self.assertEqual(pr.head_sha, candidate.tip)
                self.assertEqual(digest(pr.body), __import__("json").loads(api.get_lease(api.get_ref(STABLE_LEASE) or ""))["marker_digest"])

    def test_validation_runner_loss_is_recovered_from_lease_only_and_owned_pair(self) -> None:
        # Given: an authenticated old run and failures after each validation creation mutation.
        candidate = Candidate.fixture()
        for boundary in (1, 2):
            with self.subTest(boundary=boundary):
                api = FakeGitHub(); api.runs[200] = RunIdentity(200, "GINNOV/littlethings", ".github/workflows/adflib-update.yml", 42, candidate.workflow_source_sha, age_hours=25); api.fail_on_mutation = boundary
                # When: runner loss leaves a durable lease-only or lease/ref pair and reconciliation starts.
                with self.assertRaises(CoordinatorError):
                    create_validation_pair(api, candidate, 42, "nonce")
                api.fail_on_mutation = None
                reconcile_validation(api, 42)
                # Then: exact owned validation refs and leases are absent after CAS cleanup.
                self.assertEqual(api.list_refs("refs/heads/deps/adflib-validation/"), ())
                self.assertEqual(api.list_refs("refs/heads/deps/adflib-leases/validation/"), ())

    def test_supplemental_attestation_rejects_duplicate_and_candidate_substitution(self) -> None:
        # Given: an owned active PR and two otherwise matching supplemental PR-context runs.
        api = FakeGitHub.owned_active(); candidate = Candidate.fixture(); api.runs[200] = RunIdentity(200, "GINNOV/littlethings", ".github/workflows/adflib-update.yml", 42, candidate.workflow_source_sha)
        pr = promote_candidate(api, candidate, 42)
        run = RunIdentity.fixture_supplemental(candidate, pr.number, "1" * 64)
        api.runs[301] = run; api.runs[302] = replace(run, run_id=302)
        # When: exact supplemental correlation sees a duplicate.
        with self.assertRaisesRegex(CoordinatorError, "supplemental_run_count_mismatch"):
            attest_supplemental(api, candidate, pr.number, frozenset({100, 200}), 42)
        # Then: substituting candidate identity cannot produce a ready marker either.
        del api.runs[302]
        attested = attest_supplemental(api, candidate, pr.number, frozenset({100, 200}), 42)
        with self.assertRaisesRegex(CoordinatorError, "candidate_identity_substitution"):
            mark_supplemental_ready(api, replace(candidate, commit="0" * 40), pr.number, attested, 42)

    def test_orphan_recovery_proves_pr_absence_before_deleting_lease(self) -> None:
        # Given: an owned orphan lease but a surviving PR for the stable branch.
        api = FakeGitHub.owned_active(); lease_sha = api.get_ref(STABLE_LEASE); api.refs.pop(STABLE_BRANCH)
        # When: owner-approved orphan cleanup compares all live observations.
        with self.assertRaisesRegex(CoordinatorError, "orphan_absence_not_proven"):
            recover_owned(api, "cleanup-orphan", lease_sha or "", None, None, None, 42)
        # Then: the durable lease remains untouched.
        self.assertEqual(api.get_ref(STABLE_LEASE), lease_sha)

    def test_workflow_uses_memory_broker_without_token_in_git_argv(self) -> None:
        # Given: the protected updater workflow and its git credential transport.
        workflow = Path(__file__).resolve().parents[5] / ".github/workflows/adflib-update.yml"
        text = workflow.read_text(encoding="utf-8")
        adapter = (Path(__file__).resolve().parents[1] / "stable_update_github.py").read_text(encoding="utf-8")
        # When: every remote mutation command and credential handoff are inspected.
        exposed = "x-access-token:${APP_TOKEN}"
        # Then: no token-bearing URL exists and the reviewed memory broker owns askpass delivery.
        self.assertNotIn(exposed, text)
        self.assertIn("adflib_credential_broker.py", text)
        self.assertIn("adflib_git_askpass.py", adapter)

    def test_real_git_bundle_and_ref_cas_bind_exact_candidate(self) -> None:
        # Given: a real local git repository with a base and manifest-only candidate commit.
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary); repository = root / "repo"; bundle = root / "candidate.bundle"
            subprocess.run(["git", "init", "-q", str(repository)], check=True)
            subprocess.run(["git", "-C", str(repository), "config", "user.name", "fixture"], check=True)
            subprocess.run(["git", "-C", str(repository), "config", "user.email", "fixture@example.invalid"], check=True)
            manifest = repository / "manifest"; manifest.write_text("old\n", encoding="utf-8")
            subprocess.run(["git", "-C", str(repository), "add", "manifest"], check=True); subprocess.run(["git", "-C", str(repository), "commit", "-qm", "base"], check=True)
            manifest.write_text("new\n", encoding="utf-8"); subprocess.run(["git", "-C", str(repository), "commit", "-qam", "candidate"], check=True)
            tip = subprocess.run(["git", "-C", str(repository), "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
            # When: the exact candidate ref is bundled and the stable ref moves by old-SHA CAS.
            subprocess.run(["git", "-C", str(repository), "update-ref", "refs/heads/candidate", tip], check=True)
            subprocess.run(["git", "-C", str(repository), "bundle", "create", str(bundle), "refs/heads/candidate"], check=True)
            subprocess.run(["git", "-C", str(repository), "update-ref", "refs/heads/deps/adflib-stable", tip, "0" * 40], check=True)
            # Then: bundle and ref surfaces resolve the identical tested SHA.
            head = subprocess.run(["git", "bundle", "list-heads", str(bundle)], check=True, capture_output=True, text=True).stdout.split()[0]
            stable = subprocess.run(["git", "-C", str(repository), "rev-parse", "refs/heads/deps/adflib-stable"], check=True, capture_output=True, text=True).stdout.strip()
            self.assertEqual((head, stable), (tip, tip))

    def test_memory_broker_keeps_token_out_of_child_argv_and_environment(self) -> None:
        # Given: a short-lived token supplied only through the broker's anonymous stdin pipe.
        with tempfile.TemporaryDirectory() as temporary:
            socket_path = Path(temporary) / "token.sock"; secret = b"fixture-secret-never-record"
            broker = Path(__file__).resolve().parents[1] / "adflib_credential_broker.py"; askpass = broker.with_name("adflib_git_askpass.py")
            process = subprocess.Popen([sys.executable, str(broker), str(socket_path)], stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env={"PATH": os.environ.get("PATH", "")})
            self.addCleanup(lambda: process.poll() is None and process.terminate())
            assert process.stdin is not None
            process.stdin.write(secret); process.stdin.close()
            for _ in range(100):
                if socket_path.exists(): break
                time.sleep(0.01)
            # When: process state is inspected and askpass requests the password capability.
            process_state = subprocess.run(["ps", "eww", "-p", str(process.pid)], check=True, capture_output=True).stdout
            result = subprocess.run([sys.executable, str(askpass), "Password:"], env={"ADFLIB_ASKPASS_SOCKET": str(socket_path)}, check=True, capture_output=True)
            # Then: only the private socket transports the secret and process metadata cannot reveal it.
            self.assertNotIn(secret, process_state)
            self.assertEqual(result.stdout, secret)
            self.assertEqual(stat.S_IMODE(socket_path.stat().st_mode), 0o600)
            process.terminate(); process.wait(timeout=5)


if __name__ == "__main__":
    unittest.main()
