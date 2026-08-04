from __future__ import annotations

import json
import urllib.parse
from dataclasses import asdict

from .release_github import JsonValue, github_bytes, github_optional, github_request
from .release_transaction import (
    Asset,
    Lease,
    Release,
    ReleaseIdentity,
    TransactionError,
)

OWNER_OPEN = "<send2adf-release-owner>"
OWNER_CLOSE = "</send2adf-release-owner>"


class GitHubReleaseApi:
    def __init__(self, repository: str, token: str) -> None:
        self._api = f"https://api.github.com/repos/{repository}"
        self._uploads = f"https://uploads.github.com/repos/{repository}"
        self._token = token

    @staticmethod
    def _lease_name(tag: str) -> str:
        return f"releases/send2adf-leases/{tag}"

    def _descriptor(self, sha: str) -> dict[str, JsonValue]:
        value = github_request(f"{self._api}/git/commits/{sha}", self._token)
        message = value.get("message") if isinstance(value, dict) else None
        if not isinstance(message, str):
            raise TransactionError("release lease commit is invalid")
        parsed: JsonValue = json.loads(message)
        if not isinstance(parsed, dict):
            raise TransactionError("release lease descriptor is invalid")
        return parsed

    @staticmethod
    def _identity(value: dict[str, JsonValue]) -> ReleaseIdentity:
        repository = value.get("repository"); workflow = value.get("workflow")
        run_id = value.get("run_id"); tag = value.get("tag")
        target_sha = value.get("target_sha"); app_id = value.get("app_id")
        if not isinstance(repository, str) or not isinstance(workflow, str) or not isinstance(run_id, int) or isinstance(run_id, bool) or not isinstance(tag, str) or not isinstance(target_sha, str) or not isinstance(app_id, int) or isinstance(app_id, bool):
            raise TransactionError("release identity is invalid")
        return ReleaseIdentity(repository, workflow, run_id, tag, target_sha, app_id)

    def read_lease(self, tag: str) -> Lease | None:
        value = github_optional(f"{self._api}/git/ref/heads/{self._lease_name(tag)}", self._token)
        if value is None:
            return None
        item = value.get("object") if isinstance(value, dict) else None
        sha = item.get("sha") if isinstance(item, dict) else None
        if not isinstance(sha, str):
            raise TransactionError("release lease ref is invalid")
        descriptor = self._descriptor(sha)
        release_id = descriptor.get("release_id")
        inventory = descriptor.get("inventory_sha256")
        generation = descriptor.get("generation")
        producer_run_id = descriptor.get("producer_run_id")
        phase = descriptor.get("phase")
        if release_id is not None and not isinstance(release_id, int):
            raise TransactionError("release lease ID is invalid")
        if inventory is not None and not isinstance(inventory, str):
            raise TransactionError("release lease inventory is invalid")
        if not isinstance(generation, int) or not isinstance(producer_run_id, int) or isinstance(producer_run_id, bool) or producer_run_id <= 0 or not isinstance(phase, str):
            raise TransactionError("release lease phase is invalid")
        return Lease(sha, self._identity(descriptor), phase, release_id, inventory, generation, producer_run_id)

    def _commit(self, lease: Lease, identity: ReleaseIdentity, phase: str, release_id: int | None, inventory: str | None) -> Lease:
        descriptor = {**asdict(identity), "phase": phase, "release_id": release_id, "inventory_sha256": inventory, "generation": lease.generation + 1, "producer_run_id": lease.producer_run_id}
        tree = github_request(f"{self._api}/git/trees", self._token, "POST", b'{"tree":[]}')
        if not isinstance(tree, dict) or not isinstance(tree.get("sha"), str):
            raise TransactionError("release lease tree creation failed")
        payload = json.dumps({"message": json.dumps(descriptor, sort_keys=True, separators=(",", ":")), "tree": tree["sha"], "parents": [lease.sha]}, separators=(",", ":")).encode()
        commit = github_request(f"{self._api}/git/commits", self._token, "POST", payload)
        if not isinstance(commit, dict) or not isinstance(commit.get("sha"), str):
            raise TransactionError("release lease commit creation failed")
        github_request(f"{self._api}/git/refs/heads/{self._lease_name(identity.tag)}", self._token, "PATCH", json.dumps({"sha": commit["sha"], "force": False}, separators=(",", ":")).encode())
        observed = self.read_lease(identity.tag)
        if observed is None or observed.sha != commit["sha"]:
            raise TransactionError("release lease CAS readback mismatch")
        return observed

    def reserve(self, identity: ReleaseIdentity) -> Lease:
        descriptor = {**asdict(identity), "phase": "reserved", "release_id": None, "inventory_sha256": None, "generation": 1, "producer_run_id": identity.run_id}
        tree = github_request(f"{self._api}/git/trees", self._token, "POST", b'{"tree":[]}')
        if not isinstance(tree, dict) or not isinstance(tree.get("sha"), str):
            raise TransactionError("release lease tree creation failed")
        payload = json.dumps({"message": json.dumps(descriptor, sort_keys=True, separators=(",", ":")), "tree": tree["sha"], "parents": []}, separators=(",", ":")).encode()
        commit = github_request(f"{self._api}/git/commits", self._token, "POST", payload)
        if not isinstance(commit, dict) or not isinstance(commit.get("sha"), str):
            raise TransactionError("reserved lease commit creation failed")
        github_request(f"{self._api}/git/refs", self._token, "POST", json.dumps({"ref": f"refs/heads/{self._lease_name(identity.tag)}", "sha": commit["sha"]}, separators=(",", ":")).encode())
        observed = self.read_lease(identity.tag)
        if observed is None:
            raise TransactionError("reserved lease readback failed")
        return observed

    def transfer(self, expected: Lease, identity: ReleaseIdentity) -> Lease:
        return self._commit(expected, identity, expected.phase, expected.release_id, expected.inventory_sha256)

    def bind_draft(self, expected: Lease, release_id: int) -> Lease:
        return self._commit(expected, expected.identity, "draft-bound-uninventoried", release_id, None)

    def bind_inventory(self, expected: Lease, inventory_sha256: str) -> Lease:
        return self._commit(expected, expected.identity, "inventory-bound", expected.release_id, inventory_sha256)

    def delete_reserved(self, expected: Lease) -> None:
        if self.read_lease(expected.identity.tag) != expected or expected.phase != "reserved":
            raise TransactionError("reserved lease cleanup CAS lost")
        github_request(f"{self._api}/git/refs/heads/{self._lease_name(expected.identity.tag)}", self._token, "DELETE")

    def prior_run_terminal(self, run_id: int) -> bool:
        value = github_request(f"{self._api}/actions/runs/{run_id}", self._token)
        return isinstance(value, dict) and value.get("status") == "completed"

    @staticmethod
    def _marker(body: str) -> ReleaseIdentity:
        start = body.find(OWNER_OPEN)
        end = body.find(OWNER_CLOSE, start + len(OWNER_OPEN))
        if start < 0 or end < 0:
            raise TransactionError("release ownership marker is absent")
        value: JsonValue = json.loads(body[start + len(OWNER_OPEN):end])
        if not isinstance(value, dict):
            raise TransactionError("release ownership marker is invalid")
        return GitHubReleaseApi._identity(value)

    def _release(self, value: object) -> Release:
        if not isinstance(value, dict) or not isinstance(value.get("id"), int) or not isinstance(value.get("body"), str):
            raise TransactionError("release response is invalid")
        identity = self._marker(value["body"])
        assets_value = github_request(f"{self._api}/releases/{value['id']}/assets?per_page=100", self._token)
        if not isinstance(assets_value, list):
            raise TransactionError("release asset inventory is invalid")
        assets: list[Asset] = []
        for item in assets_value:
            asset_id = item.get("id") if isinstance(item, dict) else None
            name = item.get("name") if isinstance(item, dict) else None
            url = item.get("url") if isinstance(item, dict) else None
            if not isinstance(asset_id, int) or isinstance(asset_id, bool) or not isinstance(name, str) or not isinstance(url, str):
                raise TransactionError("release asset is invalid")
            content = github_bytes(url, self._token)
            assets.append(Asset(asset_id, name, content))
        return Release(value["id"], identity, value.get("draft") is True, tuple(assets))

    def releases_for_tag(self, tag: str) -> tuple[Release, ...]:
        value = github_request(f"{self._api}/releases?per_page=100", self._token)
        if not isinstance(value, list):
            raise TransactionError("release list is invalid")
        return tuple(self._release(item) for item in value if isinstance(item, dict) and item.get("tag_name") == tag)

    def read_release(self, release_id: int) -> Release | None:
        value = github_optional(f"{self._api}/releases/{release_id}", self._token)
        return None if value is None else self._release(value)

    def create_draft(self, identity: ReleaseIdentity) -> Release:
        body = f"{OWNER_OPEN}{identity.canonical()}{OWNER_CLOSE}"
        payload = json.dumps({"tag_name": identity.tag, "target_commitish": identity.target_sha, "name": identity.tag, "body": body, "draft": True, "prerelease": False}, separators=(",", ":")).encode()
        return self._release(github_request(f"{self._api}/releases", self._token, "POST", payload))

    def delete_asset(self, release_id: int, asset_id: int) -> None:
        github_request(f"{self._api}/releases/assets/{asset_id}", self._token, "DELETE")

    def upload_asset(self, release_id: int, name: str, content: bytes) -> None:
        url = f"{self._uploads}/releases/{release_id}/assets?name={urllib.parse.quote(name)}"
        github_request(url, self._token, "POST", content, "application/octet-stream")

    def publish(self, release_id: int) -> None:
        github_request(f"{self._api}/releases/{release_id}", self._token, "PATCH", b'{"draft":false}')
