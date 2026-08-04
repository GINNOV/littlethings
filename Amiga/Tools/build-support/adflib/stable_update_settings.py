#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# pyright: reportImplicitRelativeImport=false
# ─── How to run ───
# printf token | python3 stable_update_settings.py --repository GINNOV/littlethings --master SHA --policy policy.json --output snapshot.json

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Final

from stable_update_policy import (
    PolicyError,
    policy_payload_sha256,
    validate_policy_snapshot,
    verify_external_receipt,
)

API_VERSION: Final = "2022-11-28"


class CollectionError(Exception):
    pass


class SettingsAPI:
    def __init__(self, token: bytearray, base_url: str = "https://api.github.com") -> None:
        self.token = token
        self.base_url = base_url.rstrip("/")

    def get(self, endpoint: str) -> object:
        request = urllib.request.Request(
            f"{self.base_url}{endpoint}",
            headers={
                "Accept": "application/vnd.github+json",
                "Authorization": f"Bearer {self.token.decode()}",
                "User-Agent": "littlethings-adflib-settings/1",
                "X-GitHub-Api-Version": API_VERSION,
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            error.close()
            raise CollectionError(f"settings_endpoint_failed:{endpoint}") from error
        except (urllib.error.URLError, json.JSONDecodeError) as error:
            raise CollectionError(f"settings_endpoint_failed:{endpoint}") from error


def _mapping(value: object, code: str) -> dict[str, object]:
    if not isinstance(value, dict) or not all(isinstance(key, str) for key in value):
        raise CollectionError(code)
    return value


def _sequence(value: object, code: str) -> list[object]:
    if not isinstance(value, list):
        raise CollectionError(code)
    return value


def _content(document: object, code: str) -> tuple[bytes, str]:
    value = _mapping(document, code)
    encoded = value.get("content")
    sha = value.get("sha")
    if value.get("encoding") != "base64" or not isinstance(encoded, str) or not isinstance(sha, str):
        raise CollectionError(code)
    try:
        return base64.b64decode(encoded, validate=True), sha
    except ValueError as error:
        raise CollectionError(code) from error


def _ruleset(api: SettingsAPI, repository_path: str, summaries: list[object], name: str) -> dict[str, object]:
    matches = tuple(_mapping(item, "ruleset_summary_invalid") for item in summaries if isinstance(item, dict) and item.get("name") == name)
    if len(matches) != 1 or not isinstance(matches[0].get("id"), int):
        raise CollectionError(f"ruleset_missing:{name}")
    value = _mapping(api.get(f"{repository_path}/rulesets/{matches[0]['id']}"), "ruleset_invalid")
    if value.get("name") != name or value.get("enforcement") != "active":
        raise CollectionError(f"ruleset_inactive_or_renamed:{name}")
    return value


def _actors(ruleset: dict[str, object]) -> list[dict[str, object]]:
    actors: list[dict[str, object]] = []
    for raw in _sequence(ruleset.get("bypass_actors"), "ruleset_actors_invalid"):
        actor = _mapping(raw, "ruleset_actor_invalid")
        if actor.get("bypass_mode") != "always" or actor.get("actor_type") not in {"Integration", "Team", "User"} or not isinstance(actor.get("actor_id"), int):
            raise CollectionError("ruleset_actor_invalid")
        actors.append({"type": actor["actor_type"], "id": actor["actor_id"]})
    return actors


def _includes(ruleset: dict[str, object]) -> list[object]:
    conditions = _mapping(ruleset.get("conditions"), "ruleset_conditions_invalid")
    ref_name = _mapping(conditions.get("ref_name"), "ruleset_ref_condition_invalid")
    if ref_name.get("exclude") != []:
        raise CollectionError("ruleset_excludes_not_empty")
    return _sequence(ref_name.get("include"), "ruleset_includes_invalid")


def _rule(ruleset: dict[str, object], rule_type: str) -> dict[str, object]:
    matches = tuple(_mapping(item, "ruleset_rule_invalid") for item in _sequence(ruleset.get("rules"), "ruleset_rules_invalid") if isinstance(item, dict) and item.get("type") == rule_type)
    if len(matches) != 1:
        raise CollectionError(f"ruleset_rule_missing:{rule_type}")
    return matches[0]


def collect_snapshot(api: SettingsAPI, repository: str, policy_bytes: bytes, allowed_signers: Path, identity: str, fingerprint: str) -> tuple[dict[str, object], str]:
    if repository != "GINNOV/littlethings":
        raise CollectionError("collection_identity_invalid")
    policy = json.loads(policy_bytes)
    if not isinstance(policy, dict):
        raise CollectionError("policy_not_object")
    verify_external_receipt(policy, allowed_signers, identity, fingerprint)
    repository_path = f"/repos/{repository}"
    owner = repository.split("/", 1)[0]
    repo = _mapping(api.get(repository_path), "repository_settings_invalid")
    master_ref = _mapping(api.get(f"{repository_path}/git/ref/heads/master"), "master_ref_invalid")
    master = _mapping(master_ref.get("object"), "master_ref_invalid").get("sha")
    if not isinstance(master, str) or len(master) != 40:
        raise CollectionError("master_ref_invalid")
    actions = _mapping(api.get(f"{repository_path}/actions/permissions/workflow"), "actions_settings_invalid")
    team_slug = policy.get("approver_team")
    if not isinstance(team_slug, str):
        raise CollectionError("team_literal_invalid")
    team = _mapping(api.get(f"/orgs/{owner}/teams/{urllib.parse.quote(team_slug)}"), "team_invalid")
    environment_name = policy.get("environment")
    if not isinstance(environment_name, str):
        raise CollectionError("environment_literal_invalid")
    environment = _mapping(api.get(f"{repository_path}/environments/{urllib.parse.quote(environment_name)}"), "environment_invalid")
    policy_remote, _ = _content(api.get(f"{repository_path}/contents/.github/adflib-automation-policy.json?ref={master}"), "remote_policy_invalid")
    if policy_remote != policy_bytes:
        raise CollectionError("remote_policy_bytes_mismatch")
    codeowners_bytes, codeowners_sha = _content(api.get(f"{repository_path}/contents/.github/CODEOWNERS?ref={master}"), "codeowners_invalid")
    summaries = _sequence(api.get(f"{repository_path}/rulesets?includes_parents=true"), "ruleset_summaries_invalid")
    master_ruleset = _ruleset(api, repository_path, summaries, "ADFlib master protection")
    namespace_ruleset = _ruleset(api, repository_path, summaries, "ADFlib automation namespaces")
    release_ruleset = _ruleset(api, repository_path, summaries, "ADFlib release tags immutable")
    if master_ruleset.get("target") != "branch" or namespace_ruleset.get("target") != "branch" or release_ruleset.get("target") != "tag":
        raise CollectionError("ruleset_target_mismatch")
    installations = _mapping(api.get(f"/orgs/{owner}/installations?per_page=100"), "installations_invalid")
    app_policy = _mapping(policy.get("app"), "policy_app_invalid")
    app_id = app_policy.get("id")
    installation_id = app_policy.get("installation_id")
    installation_matches = tuple(_mapping(item, "installation_invalid") for item in _sequence(installations.get("installations"), "installations_invalid") if isinstance(item, dict) and item.get("id") == installation_id and item.get("app_id") == app_id)
    if len(installation_matches) != 1 or installation_matches[0].get("suspended_at") is not None:
        raise CollectionError("installation_identity_mismatch")
    installation = installation_matches[0]
    repositories = _mapping(api.get(f"/user/installations/{installation_id}/repositories?per_page=100"), "installation_repositories_invalid")
    repository_names = {item.get("full_name") for item in _sequence(repositories.get("repositories"), "installation_repositories_invalid") if isinstance(item, dict)}
    if repository not in repository_names:
        raise CollectionError("installation_repository_missing")
    commit = _mapping(api.get(f"{repository_path}/commits/{master}"), "master_commit_invalid")
    verification = _mapping(_mapping(commit.get("commit"), "master_commit_invalid").get("verification"), "master_verification_invalid")
    review = _mapping(_rule(master_ruleset, "pull_request").get("parameters"), "review_rule_invalid")
    required_types = {item.get("type") for item in _sequence(namespace_ruleset.get("rules"), "namespace_rules_invalid") if isinstance(item, dict)}
    release_types = {item.get("type") for item in _sequence(release_ruleset.get("rules"), "release_rules_invalid") if isinstance(item, dict)}
    reviewers: list[str] = []
    prevent_self_review = False
    for raw_rule in _sequence(environment.get("protection_rules"), "environment_rules_invalid"):
        env_rule = _mapping(raw_rule, "environment_rule_invalid")
        if env_rule.get("type") == "required_reviewers":
            prevent_self_review = env_rule.get("prevent_self_review") is True
            for raw_reviewer in _sequence(env_rule.get("reviewers"), "environment_reviewers_invalid"):
                reviewer = _mapping(raw_reviewer, "environment_reviewer_invalid")
                reviewer_identity = _mapping(reviewer.get("reviewer"), "environment_reviewer_invalid")
                reviewer_slug = reviewer_identity.get("slug")
                if reviewer.get("type") == "Team" and isinstance(reviewer_slug, str):
                    reviewers.append(reviewer_slug)
    expected_codeowners = f"/.github/workflows/adflib-update.yml @GINNOV/{team_slug}\n/Amiga/Tools/build-support/adflib/ @GINNOV/{team_slug}\n".encode()
    policy_codeowners = _mapping(policy.get("codeowners"), "policy_codeowners_invalid")
    if codeowners_bytes != expected_codeowners or codeowners_sha != policy_codeowners.get("blob_sha"):
        raise CollectionError("codeowners_bytes_or_sha_mismatch")
    merge_keys = ("allow_auto_merge", "allow_merge_commit", "allow_rebase_merge", "allow_squash_merge", "delete_branch_on_merge")
    snapshot: dict[str, object] = {
        "repository": repo.get("full_name"),
        "default_branch": repo.get("default_branch"),
        "trusted_master_sha": master,
        "merge_settings": {key: repo.get(key) for key in merge_keys},
        "actions_can_approve_pull_requests": actions.get("can_approve_pull_request_reviews"),
        "approver_team": team.get("slug"),
        "environment": {"name": environment.get("name"), "reviewers": sorted(reviewers), "prevent_self_review": prevent_self_review},
        "codeowners": policy_codeowners,
        "branch_ruleset": {"target": "master" if _includes(master_ruleset) in (["~DEFAULT_BRANCH"], ["refs/heads/master"]) else "invalid", "push_actors": _actors(master_ruleset), "required_approvals": review.get("required_approving_review_count"), "dismiss_stale_reviews": review.get("dismiss_stale_reviews_on_push"), "require_most_recent_approval": review.get("require_last_push_approval")},
        "namespace_ruleset": {"patterns": ["deps/adflib-stable", "deps/adflib-leases/*", "deps/adflib-validation/*"] if set(_includes(namespace_ruleset)) == {"refs/heads/deps/adflib-stable", "refs/heads/deps/adflib-leases/**", "refs/heads/deps/adflib-validation/**"} and required_types == {"creation", "update", "deletion"} else [], "push_actors": _actors(namespace_ruleset)},
        "release_ruleset": {"pattern": "refs/tags/v*" if _includes(release_ruleset) == ["refs/tags/v*"] else "invalid", "update_allowed": "update" not in release_types, "delete_allowed": "deletion" not in release_types},
        "app": {"id": installation.get("app_id"), "installation_id": installation.get("id"), "slug": installation.get("app_slug"), "permissions": installation.get("permissions"), "merge_permission": bool(_actors(master_ruleset)) or "administration" in _mapping(installation.get("permissions"), "installation_permissions_invalid")},
        "receipt": {"signer": identity, "payload_sha256": policy_payload_sha256(policy), "verified": verification.get("verified") is True},
    }
    validate_policy_snapshot(policy, snapshot)
    encoded = (json.dumps(snapshot, sort_keys=True, separators=(",", ":")) + "\n").encode()
    return snapshot, hashlib.sha256(encoded).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repository", required=True)
    parser.add_argument("--policy", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--allowed-signers", type=Path, required=True)
    parser.add_argument("--identity", required=True)
    parser.add_argument("--fingerprint", required=True)
    parser.add_argument("--base-url", default="https://api.github.com")
    arguments = parser.parse_args()
    token = bytearray(sys.stdin.buffer.read().rstrip(b"\r\n"))
    try:
        if not token:
            raise CollectionError("settings_token_missing")
        snapshot, digest = collect_snapshot(SettingsAPI(token, arguments.base_url), arguments.repository, arguments.policy.read_bytes(), arguments.allowed_signers, arguments.identity, arguments.fingerprint)
        arguments.output.write_text(json.dumps(snapshot, sort_keys=True, separators=(",", ":")) + "\n", encoding="utf-8")
        print(digest)
    except (CollectionError, PolicyError, OSError, json.JSONDecodeError) as error:
        print(error, file=sys.stderr)
        return 2
    finally:
        for index in range(len(token)):
            token[index] = 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
