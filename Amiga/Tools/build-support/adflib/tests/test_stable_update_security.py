#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# pyright: reportImplicitRelativeImport=false
# ─── How to run ───
# python3 -m unittest -v test_stable_update_security.py

from __future__ import annotations

import base64
import copy
import json
import os
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from dataclasses import replace
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import ClassVar

ADFLIB = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ADFLIB))

from stable_update_github import GitHubAPI
from stable_update_policy import (
    PolicyError,
    policy_payload_sha256,
    validate_policy_snapshot,
)
from stable_update_settings import CollectionError, SettingsAPI, collect_snapshot
from stable_update_state import (
    Candidate,
    CoordinatorError,
    FakeGitHub,
    RunIdentity,
    attest_supplemental,
    promote_candidate,
)


class SchemaGitHubAPI(GitHubAPI):
    documents: dict[tuple[str, str], object]

    def _request(self, method: str, endpoint: str, payload: dict[str, str | int | bool] | None = None, *, repository_endpoint: bool = True):
        return self.documents[(method, endpoint)]


def policy_fixture() -> tuple[dict[str, object], dict[str, object]]:
    policy: dict[str, object] = {
        "schema": "adflib-automation-policy/v1",
        "repository": "GINNOV/littlethings",
        "receipt": {"signer": "gi-business-adflib-authority", "signature": "fixture-signed-receipt", "payload_sha256": "pending"},
        "approver_team": "adflib-automation-approvers",
        "environment": "adflib-verification",
        "codeowners": {"paths": ["/.github/workflows/adflib-update.yml", "/Amiga/Tools/build-support/adflib/"], "owner": "@GINNOV/adflib-automation-approvers", "blob_sha": "c" * 40},
        "app": {"id": 42, "installation_id": 700, "slug": "adflib-automation", "permissions": {"actions": "read", "contents": "write", "pull_requests": "write"}},
        "merge_settings": {"allow_auto_merge": False, "allow_merge_commit": True, "allow_rebase_merge": False, "allow_squash_merge": True, "delete_branch_on_merge": False},
    }
    receipt_policy = policy["receipt"]
    assert isinstance(receipt_policy, dict)
    receipt_policy["payload_sha256"] = policy_payload_sha256(policy)
    snapshot: dict[str, object] = {
        "repository": "GINNOV/littlethings",
        "default_branch": "master",
        "trusted_master_sha": "9" * 40,
        "merge_settings": policy["merge_settings"],
        "actions_can_approve_pull_requests": False,
        "approver_team": "adflib-automation-approvers",
        "environment": {"name": "adflib-verification", "reviewers": ["adflib-automation-approvers"], "prevent_self_review": True},
        "codeowners": policy["codeowners"],
        "branch_ruleset": {"target": "master", "push_actors": [], "required_approvals": 1, "dismiss_stale_reviews": True, "require_most_recent_approval": True},
        "namespace_ruleset": {"patterns": ["deps/adflib-stable", "deps/adflib-leases/*", "deps/adflib-validation/*"], "push_actors": [{"type": "Integration", "id": 42}]},
        "release_ruleset": {"pattern": "refs/tags/v*", "update_allowed": False, "delete_allowed": False},
        "app": {"id": 42, "installation_id": 700, "slug": "adflib-automation", "permissions": {"actions": "read", "contents": "write", "pull_requests": "write"}, "merge_permission": False},
        "receipt": {"signer": "gi-business-adflib-authority", "payload_sha256": "pending", "verified": True},
    }
    receipt = snapshot["receipt"]
    assert isinstance(receipt, dict)
    receipt["payload_sha256"] = policy_payload_sha256(policy)
    return policy, snapshot


def settings_documents(policy: dict[str, object]) -> dict[str, object]:
    policy_bytes = (json.dumps(policy, sort_keys=True, separators=(",", ":")) + "\n").encode()
    team = "adflib-automation-approvers"
    owner = f"@GINNOV/{team}"
    codeowners = f"/.github/workflows/adflib-update.yml {owner}\n/Amiga/Tools/build-support/adflib/ {owner}\n".encode()
    merge_settings = policy["merge_settings"]
    assert isinstance(merge_settings, dict)
    return {
        "/repos/GINNOV/littlethings": {"full_name": "GINNOV/littlethings", "default_branch": "master", **merge_settings},
        "/repos/GINNOV/littlethings/git/ref/heads/master": {"ref": "refs/heads/master", "object": {"type": "commit", "sha": "9" * 40}},
        "/repos/GINNOV/littlethings/actions/permissions/workflow": {"can_approve_pull_request_reviews": False},
        f"/orgs/GINNOV/teams/{team}": {"slug": team},
        "/repos/GINNOV/littlethings/environments/adflib-verification": {"name": "adflib-verification", "protection_rules": [{"type": "required_reviewers", "prevent_self_review": True, "reviewers": [{"type": "Team", "reviewer": {"slug": team}}]}]},
        f"/repos/GINNOV/littlethings/contents/.github/adflib-automation-policy.json?ref={'9' * 40}": {"encoding": "base64", "content": base64.b64encode(policy_bytes).decode(), "sha": "d" * 40},
        f"/repos/GINNOV/littlethings/contents/.github/CODEOWNERS?ref={'9' * 40}": {"encoding": "base64", "content": base64.b64encode(codeowners).decode(), "sha": "c" * 40},
        "/repos/GINNOV/littlethings/rulesets?includes_parents=true": [{"id": 1, "name": "ADFlib master protection"}, {"id": 2, "name": "ADFlib automation namespaces"}, {"id": 3, "name": "ADFlib release tags immutable"}],
        "/repos/GINNOV/littlethings/rulesets/1": {"id": 1, "name": "ADFlib master protection", "target": "branch", "enforcement": "active", "bypass_actors": [], "conditions": {"ref_name": {"include": ["~DEFAULT_BRANCH"], "exclude": []}}, "rules": [{"type": "pull_request", "parameters": {"required_approving_review_count": 1, "dismiss_stale_reviews_on_push": True, "require_last_push_approval": True}}]},
        "/repos/GINNOV/littlethings/rulesets/2": {"id": 2, "name": "ADFlib automation namespaces", "target": "branch", "enforcement": "active", "bypass_actors": [{"actor_id": 42, "actor_type": "Integration", "bypass_mode": "always"}], "conditions": {"ref_name": {"include": ["refs/heads/deps/adflib-stable", "refs/heads/deps/adflib-leases/**", "refs/heads/deps/adflib-validation/**"], "exclude": []}}, "rules": [{"type": "creation"}, {"type": "update"}, {"type": "deletion"}]},
        "/repos/GINNOV/littlethings/rulesets/3": {"id": 3, "name": "ADFlib release tags immutable", "target": "tag", "enforcement": "active", "bypass_actors": [], "conditions": {"ref_name": {"include": ["refs/tags/v*"], "exclude": []}}, "rules": [{"type": "update"}, {"type": "deletion"}]},
        "/orgs/GINNOV/installations?per_page=100": {"installations": [{"id": 700, "app_id": 42, "app_slug": "adflib-automation", "permissions": {"actions": "read", "contents": "write", "pull_requests": "write"}}]},
        "/user/installations/700/repositories?per_page=100": {"repositories": [{"full_name": "GINNOV/littlethings"}]},
        f"/repos/GINNOV/littlethings/commits/{'9' * 40}": {"commit": {"verification": {"verified": True}}},
    }


def sign_policy(policy: dict[str, object], root: Path) -> tuple[Path, str]:
    key = root / "authority"
    subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(key)], check=True)
    receipt = policy["receipt"]
    assert isinstance(receipt, dict)
    receipt["payload_sha256"] = policy_payload_sha256(policy)
    payload = {name: value for name, value in policy.items() if name != "receipt"}
    payload_path = root / "payload.json"
    payload_path.write_text(json.dumps(payload, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
    subprocess.run(["ssh-keygen", "-Y", "sign", "-n", "adflib-automation", "-f", str(key), str(payload_path)], check=True, capture_output=True)
    receipt["signature"] = base64.b64encode((root / "payload.json.sig").read_bytes()).decode()
    allowed_signers = root / "allowed_signers"
    allowed_signers.write_text(f"gi-business-adflib-authority {key.with_suffix('.pub').read_text(encoding='utf-8')}", encoding="utf-8")
    fingerprint_output = subprocess.run(["ssh-keygen", "-lf", str(allowed_signers)], check=True, capture_output=True, text=True).stdout
    return allowed_signers, fingerprint_output.split()[1]


class SettingsHandler(BaseHTTPRequestHandler):
    documents: ClassVar[dict[str, object]] = {}
    authorizations: ClassVar[list[str]] = []

    def do_GET(self) -> None:
        self.authorizations.append(self.headers.get("Authorization", ""))
        value = self.documents.get(self.path)
        if value is None:
            self.send_error(404)
            return
        encoded = json.dumps(value).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        _ = self.wfile.write(encoded)

    def log_message(self, format: str, *args: object) -> None:
        return


class StableUpdateSecurityTests(unittest.TestCase):
    def test_authenticated_http_collector_reuses_policy_validator_and_fails_closed(self) -> None:
        # Given: a local HTTP fixture serves documented repository, environment, ruleset, installation, content, commit, and Actions schemas.
        policy, _ = policy_fixture()
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        allowed_signers, fingerprint = sign_policy(policy, Path(temporary.name))
        policy_bytes = (json.dumps(policy, sort_keys=True, separators=(",", ":")) + "\n").encode()
        SettingsHandler.documents = settings_documents(policy)
        SettingsHandler.authorizations = []
        server = ThreadingHTTPServer(("127.0.0.1", 0), SettingsHandler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        address = server.server_address
        host, port = str(address[0]), int(address[1])
        api = SettingsAPI(bytearray(b"fixture-settings-token"), f"http://{host}:{port}")
        try:
            # When: the production collector normalizes the authenticated responses.
            snapshot, digest = collect_snapshot(api, "GINNOV/littlethings", policy_bytes, allowed_signers, "gi-business-adflib-authority", fingerprint)
            # Then: it emits a validated attestation and authenticates every endpoint request.
            self.assertEqual(len(digest), 64)
            self.assertEqual(snapshot["app"], {"id": 42, "installation_id": 700, "slug": "adflib-automation", "permissions": {"actions": "read", "contents": "write", "pull_requests": "write"}, "merge_permission": False})
            self.assertTrue(SettingsHandler.authorizations)
            self.assertEqual(set(SettingsHandler.authorizations), {"Bearer fixture-settings-token"})
            original = copy.deepcopy(SettingsHandler.documents)
            installation_path = "/orgs/GINNOV/installations?per_page=100"
            installations = copy.deepcopy(original[installation_path])
            assert isinstance(installations, dict)
            installation_values = installations["installations"]
            assert isinstance(installation_values, list) and isinstance(installation_values[0], dict)
            installation_values[0]["permissions"]["issues"] = "write"
            SettingsHandler.documents[installation_path] = installations
            with self.assertRaises((PolicyError, CollectionError)):
                collect_snapshot(api, "GINNOV/littlethings", policy_bytes, allowed_signers, "gi-business-adflib-authority", fingerprint)
            for missing_endpoint in original:
                SettingsHandler.documents = copy.deepcopy(original)
                del SettingsHandler.documents[missing_endpoint]
                with self.subTest(missing_endpoint=missing_endpoint), self.assertRaises((CollectionError, PolicyError)):
                    collect_snapshot(api, "GINNOV/littlethings", policy_bytes, allowed_signers, "gi-business-adflib-authority", fingerprint)
            SettingsHandler.documents = copy.deepcopy(original)
            repository = SettingsHandler.documents["/repos/GINNOV/littlethings"]
            assert isinstance(repository, dict)
            repository["default_branch"] = "develop"
            with self.assertRaises(PolicyError):
                collect_snapshot(api, "GINNOV/littlethings", policy_bytes, allowed_signers, "gi-business-adflib-authority", fingerprint)
            with self.assertRaisesRegex(PolicyError, "authority_fingerprint_mismatch"):
                collect_snapshot(api, "GINNOV/littlethings", policy_bytes, allowed_signers, "gi-business-adflib-authority", "SHA256:wrong")
            wrong_root = Path(temporary.name) / "wrong"
            wrong_root.mkdir()
            wrong_policy = copy.deepcopy(policy)
            wrong_signers, wrong_fingerprint = sign_policy(wrong_policy, wrong_root)
            with self.assertRaisesRegex(PolicyError, "policy_signature_verification_failed"):
                collect_snapshot(api, "GINNOV/littlethings", policy_bytes, wrong_signers, "gi-business-adflib-authority", wrong_fingerprint)
            changed_policy = copy.deepcopy(policy)
            changed_policy["approver_team"] = "substituted-team"
            changed_receipt = changed_policy["receipt"]
            assert isinstance(changed_receipt, dict)
            changed_receipt["payload_sha256"] = policy_payload_sha256(changed_policy)
            changed_bytes = (json.dumps(changed_policy, sort_keys=True, separators=(",", ":")) + "\n").encode()
            with self.assertRaisesRegex(PolicyError, "policy_signature_verification_failed"):
                collect_snapshot(api, "GINNOV/littlethings", changed_bytes, allowed_signers, "gi-business-adflib-authority", fingerprint)
            bad_signature = copy.deepcopy(policy)
            bad_receipt = bad_signature["receipt"]
            assert isinstance(bad_receipt, dict)
            bad_receipt["signature"] = base64.b64encode(b"not-an-ssh-signature").decode()
            bad_bytes = (json.dumps(bad_signature, sort_keys=True, separators=(",", ":")) + "\n").encode()
            with self.assertRaisesRegex(PolicyError, "policy_signature_verification_failed"):
                collect_snapshot(api, "GINNOV/littlethings", bad_bytes, allowed_signers, "gi-business-adflib-authority", fingerprint)
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)

    def test_production_adapter_reads_app_event_and_pr_target_schemas(self) -> None:
        # Given: real REST response shapes expose a bot user, performed App, installation, PR, run, check suite, and trusted workflow blob.
        api = SchemaGitHubAPI("GINNOV/littlethings", Path("."), "/unused", 42)
        documents: dict[tuple[str, str], object] = {
            ("GET", "/pulls/7"): {"user": {"id": 9001}, "head": {"ref": "deps/adflib-stable", "sha": "b" * 40}, "base": {"ref": "master"}, "state": "open", "merged": False, "body": "{}"},
            ("GET", "/issues/7"): {"user": {"id": 9001, "login": "adflib-automation[bot]"}, "performed_via_github_app": {"id": 42, "slug": "adflib-automation"}, "pull_request": {"url": "https://api.github.com/repos/GINNOV/littlethings/pulls/7"}},
            ("GET", "/installation"): {"id": 700, "app_id": 42, "app_slug": "adflib-automation"},
            ("GET", "/actions/runs/301"): {"id": 301, "repository": {"full_name": "GINNOV/littlethings"}, "path": ".github/workflows/adflib-consumers-ci.yml@master", "check_suite_id": 88, "head_sha": "9" * 40, "event": "pull_request_target", "pull_requests": [{"number": 7}], "conclusion": "success", "html_url": "https://github.test/runs/301", "created_at": "2026-08-03T00:00:00Z"},
            ("GET", "/check-suites/88"): {"app": {"id": 15368, "slug": "github-actions"}},
            ("GET", f"/contents/.github/workflows/adflib-consumers-ci.yml?ref={'9' * 40}"): {"encoding": "base64", "content": base64.b64encode(b"name: trusted\n").decode()},
        }
        api.documents = documents
        # When: production schema parsing resolves the PR and supplemental run.
        pr = api.pull(7)
        run = api.run(301)
        # Then: App ID never comes from user.id, and base workflow source differs from the fetched PR head.
        self.assertEqual((pr.creator_app_id, pr.creator_user_id), (42, 9001))
        self.assertEqual((run.source_sha, run.head_sha, run.check_suite_app_id), ("9" * 40, "b" * 40, 15368))
        issue = documents[("GET", "/issues/7")]
        assert isinstance(issue, dict)
        issue["performed_via_github_app"] = {"id": 9001, "slug": "adflib-automation"}
        with self.assertRaisesRegex(CoordinatorError, "pr_creator_app_event_mismatch"):
            api.pull(7)

    def test_missing_signed_policy_stops_before_settings_or_app_credentials(self) -> None:
        # Given: the owner-supplied signed policy is deliberately absent from this checkout.
        root = Path(__file__).resolve().parents[5]
        workflow = (root / ".github/workflows/adflib-update.yml").read_text(encoding="utf-8")
        self.assertFalse((root / ".github/adflib-automation-policy.json").exists())
        # When: the preflight step order is inspected.
        policy_gate = workflow.index("Require reviewed automation authority before loading settings credentials")
        settings_credential = workflow.index("secrets.ADFLIB_SETTINGS_READ_TOKEN")
        app_credential = workflow.index("ADFLIB_AUTOMATION_APP_PRIVATE_KEY")
        # Then: the missing-policy failure occurs before either protected credential surface.
        self.assertLess(policy_gate, settings_credential)
        self.assertLess(policy_gate, app_credential)
        self.assertNotRegex(workflow, r"(?m)^\s*SETTINGS_TOKEN:")
        self.assertNotRegex(workflow, r"curl[^\n]+ADFLIB_SETTINGS_READ_TOKEN|Authorization: Bearer \$SETTINGS")

    def test_settings_token_is_absent_from_collector_argv_and_environment(self) -> None:
        # Given: a settings token is held in the collector's open stdin while the process is observable.
        token = "settings-token-theft-probe-7c6a"
        collector = Path(__file__).resolve().parents[1] / "stable_update_settings.py"
        process = subprocess.Popen(
            [sys.executable, str(collector), "--repository", "GINNOV/littlethings", "--policy", "/missing-policy", "--output", "/missing-output", "--allowed-signers", "/missing-signers", "--identity", "gi-business-adflib-authority", "--fingerprint", "SHA256:missing", "--base-url", "http://127.0.0.1:1"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env={"PATH": os.environ.get("PATH", "/usr/bin:/bin")},
            close_fds=True,
        )
        assert process.stdin is not None
        process.stdin.write(token.encode())
        process.stdin.flush()
        time.sleep(0.1)
        # When: another local process inspects the collector command line and environment.
        observed = subprocess.run(["ps", "eww", "-p", str(process.pid)], check=True, capture_output=True, text=True).stdout
        # Then: the secret is present only on collector stdin, never argv or environment.
        self.assertNotIn(token, observed)
        proc = Path(f"/proc/{process.pid}")
        if proc.exists():
            self.assertNotIn(token.encode(), (proc / "cmdline").read_bytes())
            self.assertNotIn(token.encode(), (proc / "environ").read_bytes())
            self.assertEqual({entry.name for entry in (proc / "fd").iterdir()}, {"0", "1", "2"})
        process.stdin.close()
        process.wait(timeout=5)
        assert process.stdout is not None and process.stderr is not None
        process.stdout.close()
        process.stderr.close()

    def test_schema_only_cannot_unlock_any_mutation_job(self) -> None:
        # Given: the workflow has both a local schema gate and the authenticated settings attestation.
        root = Path(__file__).resolve().parents[5]
        workflow = (root / ".github/workflows/adflib-update.yml").read_text(encoding="utf-8")
        schema = workflow.index("stable_update_policy.py schema")
        collector = workflow.index("stable_update_settings.py")
        validation = workflow.index("stable_update_policy.py validate")
        # When: the authority output and every App-token mutation job condition are inspected.
        self.assertLess(schema, collector)
        self.assertLess(collector, validation)
        self.assertIn("authority_digest: ${{ steps.authority.outputs.authority_digest }}", workflow)
        mutation_section = workflow[workflow.index("  reconcile:") :]
        # Then: schema success alone cannot satisfy a mutation condition without the authenticated digest.
        self.assertGreaterEqual(mutation_section.count("needs.preflight.outputs.authority_digest != ''"), 6)

    def test_pr_creator_uses_app_event_identity_not_bot_user_id(self) -> None:
        # Given: GitHub reports distinct numeric identities for the App and its bot user.
        api = FakeGitHub.owned_active(creator_app_id=42, creator_user_id=9001, creator_bot_login="adflib-automation[bot]")
        candidate = Candidate.fixture()
        api.runs[candidate.creator_run_id] = RunIdentity.fixture_updater(candidate)
        # When: the owned PR is refreshed.
        promote_candidate(api, candidate, 42)
        # Then: the authoritative App event ID is accepted without equating it to user.id.
        self.assertEqual(api.prs[1].creator_app_id, 42)
        self.assertEqual(api.prs[1].creator_user_id, 9001)
        api.prs[1] = replace(api.prs[1], creator_app_id=9001)
        with self.assertRaisesRegex(CoordinatorError, "stable_pr_identity_mismatch"):
            promote_candidate(api, replace(candidate, tip="c" * 40), 42)

    def test_supplemental_binds_trusted_base_source_and_distinct_pr_head(self) -> None:
        # Given: pull_request_target runs trusted workflow bytes at the base SHA while building a distinct PR head.
        candidate = Candidate.fixture()
        api = FakeGitHub()
        api.runs[candidate.creator_run_id] = RunIdentity.fixture_updater(candidate)
        pr = promote_candidate(api, candidate, 42)
        api.runs[301] = RunIdentity.fixture_supplemental(candidate, pr.number, workflow_digest="1" * 64)
        # When: exact supplemental correlation is evaluated.
        run = attest_supplemental(api, candidate, pr.number, frozenset({100, 200}), 42)
        # Then: the base workflow SHA and candidate head remain distinct and bound to the PR readback.
        self.assertEqual(run.source_sha, candidate.workflow_source_sha)
        self.assertEqual(run.head_sha, candidate.tip)
        for changed in (
            replace(run, source_sha="8" * 40),
            replace(run, head_sha="7" * 40),
            replace(run, workflow_file_sha256=""),
        ):
            api.runs[301] = changed
            with self.assertRaisesRegex(CoordinatorError, "supplemental_run_count_mismatch"):
                attest_supplemental(api, candidate, pr.number, frozenset({100, 200}), 42)

    def test_policy_schema_passes_and_each_security_boundary_denial_fails(self) -> None:
        # Given: an authenticated settings snapshot exactly matching the reviewed policy literals.
        policy, snapshot = policy_fixture()
        validate_policy_snapshot(policy, snapshot)
        denials = (
            ("actions_can_approve_pull_requests", True),
            ("approver_team", "other-team"),
            ("default_branch", "develop"),
        )
        # When: each top-level authority invariant is independently changed.
        for key, value in denials:
            changed = copy.deepcopy(snapshot); changed[key] = value
            # Then: the production validator fails closed.
            with self.subTest(key=key), self.assertRaises(PolicyError):
                validate_policy_snapshot(policy, changed)
        nested_denials = (
            ("environment", "name", "other-environment"),
            ("environment", "reviewers", []),
            ("branch_ruleset", "target", "develop"),
            ("branch_ruleset", "push_actors", [{"type": "Team", "id": 42}]),
            ("branch_ruleset", "required_approvals", 0),
            ("branch_ruleset", "dismiss_stale_reviews", False),
            ("branch_ruleset", "require_most_recent_approval", False),
            ("namespace_ruleset", "patterns", ["deps/adflib-stable"]),
            ("namespace_ruleset", "push_actors", [{"type": "Integration", "id": 41}]),
            ("release_ruleset", "pattern", "refs/tags/test-*"),
            ("release_ruleset", "update_allowed", True),
            ("release_ruleset", "delete_allowed", True),
            ("app", "id", 41),
            ("app", "installation_id", 701),
            ("app", "slug", "other-app"),
            ("app", "permissions", {"actions": "read", "contents": "write", "pull_requests": "write", "issues": "write"}),
            ("app", "merge_permission", True),
            ("codeowners", "paths", ["/.github/workflows/adflib-update.yml"]),
            ("codeowners", "owner", "@GINNOV/other"),
            ("receipt", "verified", False),
        )
        for section, key, value in nested_denials:
            changed = copy.deepcopy(snapshot)
            value_section = changed[section]
            assert isinstance(value_section, dict)
            value_section[key] = value
            with self.subTest(section=section, key=key), self.assertRaises(PolicyError):
                validate_policy_snapshot(policy, changed)


if __name__ == "__main__":
    unittest.main()
