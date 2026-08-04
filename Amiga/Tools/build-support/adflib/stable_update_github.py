#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# pyright: reportImplicitRelativeImport=false
# ─── How to run ───
# python3 stable_update_github.py promote --candidate candidate.json --app-id 1

from __future__ import annotations

import argparse
import base64
import hashlib
import json
import os
import socket
import subprocess
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

from stable_update_state import (
    Candidate,
    CoordinatorError,
    MutationAPI,
    PullRequest,
    RunIdentity,
    attest_supplemental,
    cleanup_validation_pair,
    create_validation_pair,
    mark_supplemental_ready,
    promote_candidate,
    reconcile_stable,
    reconcile_validation,
    recover_owned,
)


class GitHubAPI(MutationAPI):
    def __init__(self, repository: str, worktree: Path, socket_path: str, app_id: int) -> None:
        self.repository = repository; self.worktree = worktree; self.socket_path = socket_path; self.app_id = app_id
        self.remote = f"https://github.com/{repository}.git"
        self.git_env = {**os.environ, "ADFLIB_ASKPASS_SOCKET": socket_path, "GIT_ASKPASS": str(worktree / "Amiga/Tools/build-support/adflib/adflib_git_askpass.py"), "GIT_TERMINAL_PROMPT": "0"}

    def _token(self) -> bytearray:
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
            connection.connect(self.socket_path); connection.sendall(b"password\n"); return bytearray(connection.recv(16384))

    def _request(self, method: str, endpoint: str, payload: dict[str, str | int | bool] | None = None, *, repository_endpoint: bool = True):
        token = self._token()
        try:
            data = None if payload is None else json.dumps(payload, separators=(",", ":")).encode()
            prefix = f"https://api.github.com/repos/{self.repository}" if repository_endpoint else "https://api.github.com"
            request = urllib.request.Request(f"{prefix}{endpoint}", data=data, method=method, headers={"Accept": "application/vnd.github+json", "Authorization": f"Bearer {token.decode()}", "User-Agent": "littlethings-adflib-updater/2"})
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            raise CoordinatorError(f"github_api_{error.code}") from error
        finally:
            for index in range(len(token)): token[index] = 0

    def _git(self, *arguments: str, input_bytes: bytes | None = None) -> str:
        result = subprocess.run(["git", "-C", str(self.worktree), *arguments], input=input_bytes, env=self.git_env, check=False, capture_output=True)
        if result.returncode != 0: raise CoordinatorError("git_operation_failed")
        return result.stdout.decode().strip()

    def get_ref(self, ref: str) -> str | None:
        result = subprocess.run(["git", "-C", str(self.worktree), "ls-remote", self.remote, ref], env=self.git_env, check=True, capture_output=True, text=True).stdout.strip()
        return result.split()[0] if result else None

    def get_lease(self, sha: str) -> bytes:
        self._git("fetch", "--no-tags", self.remote, sha)
        if self._git("show", "-s", "--format=%T", sha) != self._git("hash-object", "-t", "tree", "/dev/null"): raise CoordinatorError("lease_tree_not_empty")
        return (self._git("show", "-s", "--format=%B", sha) + "\n").encode()

    def write_lease(self, ref: str, descriptor: bytes, old_sha: str | None) -> str:
        tree = self._git("hash-object", "-t", "tree", "/dev/null"); command = ["commit-tree", tree]
        if old_sha is not None: command += ["-p", old_sha]
        sha = self._git(*command, input_bytes=descriptor)
        if old_sha is None: self._git("push", self.remote, f"{sha}:{ref}")
        else: self._git("push", f"--force-with-lease={ref}:{old_sha}", self.remote, f"{sha}:{ref}")
        return sha

    def list_refs(self, prefix: str) -> tuple[tuple[str, str], ...]:
        output = self._git("ls-remote", self.remote, f"{prefix}*")
        return tuple((ref, sha) for sha, ref in (line.split() for line in output.splitlines()))

    def create_ref(self, ref: str, sha: str, descriptor: bytes | None = None) -> None:
        if descriptor is not None: raise CoordinatorError("descriptor_requires_write_lease")
        self._git("push", self.remote, f"{sha}:{ref}")

    def cas_ref(self, ref: str, old_sha: str, new_sha: str, descriptor: bytes | None = None) -> None:
        if descriptor is not None: raise CoordinatorError("descriptor_requires_write_lease")
        self._git("push", f"--force-with-lease={ref}:{old_sha}", self.remote, f"{new_sha}:{ref}")

    def delete_ref(self, ref: str, old_sha: str) -> None:
        self._git("push", f"--force-with-lease={ref}:{old_sha}", self.remote, f":{ref}")

    def run(self, run_id: int) -> RunIdentity:
        value = self._request("GET", f"/actions/runs/{run_id}"); suite = self._request("GET", f"/check-suites/{value['check_suite_id']}")
        if suite["app"]["id"] != 15368: raise CoordinatorError("run_check_suite_app_mismatch")
        pull_numbers = tuple(item["number"] for item in value.get("pull_requests", ()))
        pr = self.pull(pull_numbers[0]) if len(pull_numbers) == 1 else None
        if value["event"] == "pull_request_target" and pr is None: raise CoordinatorError("run_pr_binding_missing")
        workflow_path = value["path"].split("@", 1)[0].removeprefix("/")
        content = self._request("GET", f"/contents/{workflow_path}?ref={value['head_sha']}")
        workflow_bytes = base64.b64decode(content["content"], validate=True)
        created = __import__("datetime").datetime.fromisoformat(value["created_at"].replace("Z", "+00:00")); now = __import__("datetime").datetime.now(__import__("datetime").timezone.utc)
        return RunIdentity(run_id, value["repository"]["full_name"], workflow_path, self.app_id, value["head_sha"], value["event"], pr.number if pr else None, pr.head_sha if pr else None, value.get("conclusion") or "pending", value["html_url"], int((now-created).total_seconds()//3600), pr.base_ref if pr else "master", hashlib.sha256(workflow_bytes).hexdigest(), suite["app"]["id"])

    def pull(self, number: int) -> PullRequest:
        value = self._request("GET", f"/pulls/{number}")
        issue = self._request("GET", f"/issues/{number}")
        installation = self._request("GET", "/installation", repository_endpoint=False)
        app = issue.get("performed_via_github_app")
        if not isinstance(app, dict) or app.get("id") != self.app_id or installation.get("app_id") != self.app_id or installation.get("app_slug") != app.get("slug"):
            raise CoordinatorError("pr_creator_app_event_mismatch")
        login = issue["user"]["login"]
        if login != f"{app['slug']}[bot]" or issue["user"]["id"] == app["id"] or issue.get("pull_request", {}).get("url", "").rsplit("/", 1)[-1] != str(number):
            raise CoordinatorError("pr_creator_bot_identity_mismatch")
        return PullRequest(number, app["id"], value["head"]["ref"], value["head"]["sha"], value["base"]["ref"], value["state"], value["merged"], value.get("body", "").encode(), issue["user"]["id"], login, app["slug"])

    def pulls_for_branch(self) -> tuple[PullRequest, ...]:
        values = self._request("GET", f"/pulls?state=all&head={urllib.parse.quote(self.repository.split('/')[0]+':deps/adflib-stable')}")
        return tuple(self.pull(value["number"]) for value in values)

    def create_pull(self, candidate: Candidate, app_id: int) -> PullRequest:
        value = self._request("POST", "/pulls", {"title": f"deps(adflib): update shared ADFlib to v{candidate.version}", "head": "deps/adflib-stable", "base": "master", "body": "adflib-stable-pr/v1 bootstrap"})
        return self.pull(value["number"])

    def update_pull(self, number: int, body: bytes, expected_head: str) -> PullRequest:
        current = self.pull(number)
        if current.head_sha != expected_head: raise CoordinatorError("pr_head_changed_before_update")
        self._request("PATCH", f"/pulls/{number}", {"body": body.decode()})
        return self.pull(number)

    def workflow_runs(self) -> tuple[RunIdentity, ...]:
        values = self._request("GET", "/actions/workflows/adflib-consumers-ci.yml/runs?event=pull_request_target&per_page=100")
        return tuple(self.run(value["id"]) for value in values["workflow_runs"])


def load_candidate(path: Path) -> Candidate:
    value = json.loads(path.read_text(encoding="utf-8")); value["results"] = tuple(value["results"]); return Candidate(**value)


def main() -> int:
    parser = argparse.ArgumentParser(); parser.add_argument("command", choices=("promote", "validation-create", "validation-cleanup", "reconcile", "recover", "supplemental")); parser.add_argument("--candidate", type=Path); parser.add_argument("--repository", required=True); parser.add_argument("--worktree", type=Path, required=True); parser.add_argument("--socket", required=True); parser.add_argument("--app-id", type=int, required=True); parser.add_argument("--nonce", default=""); parser.add_argument("--lease-ref", default=""); parser.add_argument("--validation-ref", default=""); parser.add_argument("--action", default=""); parser.add_argument("--observed-lease", default=""); parser.add_argument("--observed-branch", default="absent"); parser.add_argument("--observed-pr", default="absent"); parser.add_argument("--observed-pr-head", default="absent"); parser.add_argument("--pre-run-ids", default=""); arguments = parser.parse_args()
    try:
        api = GitHubAPI(arguments.repository, arguments.worktree, arguments.socket, arguments.app_id); candidate = load_candidate(arguments.candidate) if arguments.candidate else None
        if arguments.command == "promote" and candidate: promote_candidate(api, candidate, arguments.app_id)
        elif arguments.command == "validation-create" and candidate: print(json.dumps(create_validation_pair(api, candidate, arguments.app_id, arguments.nonce)))
        elif arguments.command == "validation-cleanup" and candidate: cleanup_validation_pair(api, arguments.lease_ref, arguments.validation_ref, candidate.tip)
        elif arguments.command == "reconcile":
            reconcile_validation(api, arguments.app_id)
            reconcile_stable(api, arguments.app_id)
        elif arguments.command == "recover": recover_owned(api, arguments.action, arguments.observed_lease, None if arguments.observed_branch == "absent" else arguments.observed_branch, None if arguments.observed_pr == "absent" else int(arguments.observed_pr), None if arguments.observed_pr_head == "absent" else arguments.observed_pr_head, arguments.app_id)
        elif arguments.command == "supplemental" and candidate:
            pr = api.pulls_for_branch()[0]; run = attest_supplemental(api, candidate, pr.number, frozenset(int(item) for item in arguments.pre_run_ids.split(",") if item), arguments.app_id); mark_supplemental_ready(api, candidate, pr.number, run, arguments.app_id)
        else: raise CoordinatorError("command_arguments_invalid")
    except (CoordinatorError, OSError, json.JSONDecodeError) as error:
        print(error, file=__import__("sys").stderr); return 2
    return 0


if __name__ == "__main__": raise SystemExit(main())
