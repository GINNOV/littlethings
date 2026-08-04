from __future__ import annotations

import json
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import TypeAlias

JsonValue: TypeAlias = str | int | bool | None | list["JsonValue"] | dict[str, "JsonValue"]


@dataclass(frozen=True, slots=True)
class ReleaseGitHubError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


def github_request(url: str, token: str, method: str = "GET", payload: bytes | None = None, content_type: str = "application/vnd.github+json") -> JsonValue:
    request = urllib.request.Request(url, data=payload, method=method, headers={"Accept": "application/vnd.github+json", "Authorization": f"Bearer {token}", "Content-Type": content_type, "User-Agent": "littlethings-send2adf-release/1"})
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            raw = response.read()
    except urllib.error.HTTPError as error:
        raise ReleaseGitHubError(f"GitHub API rejected {method}: {error.code}") from error
    return json.loads(raw) if raw else None


def github_optional(url: str, token: str) -> JsonValue:
    request = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json", "Authorization": f"Bearer {token}", "User-Agent": "littlethings-send2adf-release/1"})
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise ReleaseGitHubError(f"GitHub API rejected GET: {error.code}") from error


def github_bytes(url: str, token: str) -> bytes:
    request = urllib.request.Request(url, headers={"Accept": "application/octet-stream", "Authorization": f"Bearer {token}", "User-Agent": "littlethings-send2adf-release/1"})
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        raise ReleaseGitHubError(f"GitHub API rejected artifact download: {error.code}") from error


def settings(environment_path: Path, rulesets_path: Path, team: str) -> None:
    environment = json.loads(environment_path.read_text(encoding="utf-8"))
    rulesets = json.loads(rulesets_path.read_text(encoding="utf-8"))
    reviewers = [reviewer for rule in environment.get("protection_rules", []) for reviewer in rule.get("reviewers", [])]
    if not any(item.get("type") == "Team" and item.get("reviewer", {}).get("slug") == team for item in reviewers):
        raise ReleaseGitHubError("release environment approver team mismatch")
    if environment.get("deployment_branch_policy", {}).get("protected_branches") is not True:
        raise ReleaseGitHubError("release environment branch policy mismatch")
    active_names = {item.get("name") for item in rulesets if item.get("enforcement") == "active"}
    if "send2adf-release-tags" not in active_names or "send2adf-release-leases" not in active_names:
        raise ReleaseGitHubError("release rulesets are not enforced")
