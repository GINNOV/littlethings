#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# pyright: reportImplicitRelativeImport=false
# ─── How to run ───
# python3 -m unittest tests/test_stable_update_state.py

from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass, replace
from typing import Final, Literal, Protocol

REPOSITORY: Final = "GINNOV/littlethings"
WORKFLOW: Final = ".github/workflows/adflib-update.yml"
STABLE_BRANCH: Final = "refs/heads/deps/adflib-stable"
STABLE_LEASE: Final = "refs/heads/deps/adflib-leases/stable"
GITHUB_ACTIONS_APP_ID: Final = 15368
Phase = Literal["reserved", "branch-bound", "active", "refresh-leased", "refresh-branch-updated", "refresh-pr-marked"]


class CoordinatorError(Exception):
    __slots__ = ("code",)

    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code

    def __str__(self) -> str:
        return self.code


@dataclass(frozen=True, slots=True)
class Candidate:
    tip: str
    version: str
    tag: str
    commit: str
    tree: str
    tree_manifest_sha256: str
    creator_run_id: int
    updater_run_url: str
    workflow_source_sha: str
    results: tuple[str, ...]

    @classmethod
    def fixture(cls) -> Candidate:
        return cls("b" * 40, "0.10.8", "v0.10.8", "d" * 40, "e" * 40, "f" * 64, 200, "https://github.test/runs/200", "9" * 40, ("send2adf-arm64", "send2adf-x86_64", "send2adf-linux", "adfinder-arm64", "adfinder-x86_64"))


@dataclass(frozen=True, slots=True)
class RunIdentity:
    run_id: int
    repository: str
    workflow: str
    app_id: int
    source_sha: str
    event: str = "workflow_dispatch"
    pr_number: int | None = None
    head_sha: str | None = None
    conclusion: str = "success"
    url: str = "https://github.test/run"
    age_hours: int = 0
    base_ref: str = "master"
    workflow_file_sha256: str = ""
    check_suite_app_id: int = GITHUB_ACTIONS_APP_ID

    @classmethod
    def fixture_updater(cls, candidate: Candidate, app_id: int = 42) -> RunIdentity:
        return cls(candidate.creator_run_id, REPOSITORY, WORKFLOW, app_id, candidate.workflow_source_sha)

    @classmethod
    def fixture_supplemental(cls, candidate: Candidate, pr_number: int, workflow_digest: str, app_id: int = 42) -> RunIdentity:
        return cls(301, REPOSITORY, ".github/workflows/adflib-consumers-ci.yml", app_id, candidate.workflow_source_sha, "pull_request_target", pr_number, candidate.tip, "success", "https://github.test/runs/301", 0, "master", workflow_digest)


@dataclass(frozen=True, slots=True)
class StableLease:
    phase: Phase
    repository: str
    workflow: str
    creator_run_id: int
    creator_app_id: int
    generation: int
    tested_tip: str
    branch: str | None
    branch_sha: str | None
    pr_number: int | None
    marker_digest: str | None
    prior_branch_sha: str | None = None
    version: str | None = None
    tag: str | None = None
    commit: str | None = None
    tree: str | None = None
    tree_manifest_sha256: str | None = None
    updater_run_url: str | None = None
    workflow_source_sha: str | None = None
    results: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class PullRequest:
    number: int
    creator_app_id: int
    head_ref: str
    head_sha: str
    base_ref: str
    state: str
    merged: bool
    body: bytes
    creator_user_id: int = 0
    creator_bot_login: str = ""
    creator_app_slug: str = ""


def canonical(value: StableLease | dict[str, str | int]) -> bytes:
    fields = asdict(value) if isinstance(value, StableLease) else value
    return (json.dumps(fields, sort_keys=True, separators=(",", ":")) + "\n").encode()


def digest(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def marker(candidate: Candidate, app_id: int, pr_number: int, supplemental_url: str = "pending") -> bytes:
    fields: dict[str, str | int] = {
        "app_id": app_id,
        "base": "master",
        "branch": "deps/adflib-stable",
        "commit": candidate.commit,
        "creator_run_id": candidate.creator_run_id,
        "head_sha": candidate.tip,
        "new_tag": candidate.tag,
        "pr_number": pr_number,
        "repository": REPOSITORY,
        "results": ",".join(candidate.results),
        "schema": "adflib-stable-pr/v1",
        "supplemental_run_url": supplemental_url,
        "tested_tip": candidate.tip,
        "tree": candidate.tree,
        "tree_manifest_sha256": candidate.tree_manifest_sha256,
        "updater_run_url": candidate.updater_run_url,
        "workflow": WORKFLOW,
        "workflow_source_sha": candidate.workflow_source_sha,
    }
    return canonical(fields)


class MutationAPI(Protocol):
    def get_ref(self, ref: str) -> str | None: ...
    def get_lease(self, sha: str) -> bytes: ...
    def write_lease(self, ref: str, descriptor: bytes, old_sha: str | None) -> str: ...
    def list_refs(self, prefix: str) -> tuple[tuple[str, str], ...]: ...
    def create_ref(self, ref: str, sha: str, descriptor: bytes | None = None) -> None: ...
    def cas_ref(self, ref: str, old_sha: str, new_sha: str, descriptor: bytes | None = None) -> None: ...
    def delete_ref(self, ref: str, old_sha: str) -> None: ...
    def run(self, run_id: int) -> RunIdentity: ...
    def pull(self, number: int) -> PullRequest: ...
    def pulls_for_branch(self) -> tuple[PullRequest, ...]: ...
    def create_pull(self, candidate: Candidate, app_id: int) -> PullRequest: ...
    def update_pull(self, number: int, body: bytes, expected_head: str) -> PullRequest: ...
    def workflow_runs(self) -> tuple[RunIdentity, ...]: ...


def _store_lease(api: MutationAPI, lease: StableLease, old_sha: str | None) -> str:
    sha = api.write_lease(STABLE_LEASE, canonical(lease), old_sha)
    if api.get_ref(STABLE_LEASE) != sha or api.get_lease(sha) != canonical(lease):
        raise CoordinatorError("lease_readback_mismatch")
    return sha


def _candidate_from_lease(lease: StableLease) -> Candidate:
    values = (
        lease.version,
        lease.tag,
        lease.commit,
        lease.tree,
        lease.tree_manifest_sha256,
        lease.updater_run_url,
        lease.workflow_source_sha,
    )
    if any(value is None for value in values) or len(lease.results) != 5:
        raise CoordinatorError("lease_candidate_identity_missing")
    return Candidate(
        lease.tested_tip,
        lease.version or "",
        lease.tag or "",
        lease.commit or "",
        lease.tree or "",
        lease.tree_manifest_sha256 or "",
        lease.creator_run_id,
        lease.updater_run_url or "",
        lease.workflow_source_sha or "",
        tuple(lease.results),
    )


def _owned_active(api: MutationAPI, lease_sha: str, app_id: int, *, require_open: bool = True) -> tuple[StableLease, PullRequest]:
    lease = StableLease(**json.loads(api.get_lease(lease_sha)))
    if lease.repository != REPOSITORY or lease.workflow != WORKFLOW:
        raise CoordinatorError("lease_owner_mismatch")
    if lease.creator_app_id != app_id:
        raise CoordinatorError("lease_app_mismatch")
    if lease.phase != "active" or lease.branch != STABLE_BRANCH or lease.branch_sha is None or lease.pr_number is None or lease.marker_digest is None:
        raise CoordinatorError("lease_phase_mismatch")
    owner = api.run(lease.creator_run_id)
    if (owner.repository, owner.workflow, owner.app_id) != (REPOSITORY, WORKFLOW, app_id):
        raise CoordinatorError("creator_run_mismatch")
    if api.get_ref(STABLE_BRANCH) != lease.branch_sha:
        raise CoordinatorError("stable_branch_mismatch")
    pulls = api.pulls_for_branch()
    if len(pulls) != 1 or pulls[0].number != lease.pr_number:
        raise CoordinatorError("stable_pr_count_mismatch")
    pr = api.pull(lease.pr_number)
    if (
        pr.creator_app_id != app_id
        or pr.creator_user_id == app_id
        or pr.creator_bot_login != f"{pr.creator_app_slug}[bot]"
        or not pr.creator_app_slug
        or pr.head_ref != "deps/adflib-stable"
        or pr.head_sha != lease.branch_sha
        or pr.base_ref != "master"
    ):
        raise CoordinatorError("stable_pr_identity_mismatch")
    if require_open and (pr.state != "open" or pr.merged):
        raise CoordinatorError("stable_pr_identity_mismatch")
    if digest(pr.body) != lease.marker_digest:
        raise CoordinatorError("stable_pr_marker_mismatch")
    return lease, pr


def _owned_lease(api: MutationAPI, lease_sha: str, app_id: int) -> StableLease:
    lease = StableLease(**json.loads(api.get_lease(lease_sha)))
    if lease.repository != REPOSITORY or lease.workflow != WORKFLOW:
        raise CoordinatorError("lease_owner_mismatch")
    if lease.creator_app_id != app_id:
        raise CoordinatorError("lease_app_mismatch")
    owner = api.run(lease.creator_run_id)
    if (owner.repository, owner.workflow, owner.app_id) != (REPOSITORY, WORKFLOW, app_id):
        raise CoordinatorError("creator_run_mismatch")
    return lease


def reconcile_stable(api: MutationAPI, expected_app_id: int) -> str:
    lease_sha = api.get_ref(STABLE_LEASE)
    branch_sha = api.get_ref(STABLE_BRANCH)
    pulls = api.pulls_for_branch()
    if lease_sha is None:
        if branch_sha is not None:
            raise CoordinatorError("orphan_stable_branch")
        if pulls:
            raise CoordinatorError("orphan_stable_pr")
        return "absent"
    lease = _owned_lease(api, lease_sha, expected_app_id)
    if lease.phase == "active":
        if branch_sha is None and not pulls:
            return "orphan-lease"
        _, pr = _owned_active(api, lease_sha, expected_app_id, require_open=False)
        if pr.merged:
            if pr.head_sha != lease.tested_tip:
                raise CoordinatorError("merged_head_mismatch")
            api.delete_ref(STABLE_BRANCH, lease.branch_sha or "")
            if api.get_ref(STABLE_BRANCH) is not None:
                raise CoordinatorError("merged_branch_delete_readback_mismatch")
            api.delete_ref(STABLE_LEASE, lease_sha)
            if api.get_ref(STABLE_LEASE) is not None:
                raise CoordinatorError("merged_lease_delete_readback_mismatch")
            return "merged-cleaned"
        if pr.state == "closed":
            return "closed-unmerged"
        if pr.state != "open":
            raise CoordinatorError("stable_pr_state_invalid")
        return "active"
    candidate = _candidate_from_lease(lease)
    promote_candidate(api, candidate, expected_app_id)
    return "active-resumed"


def promote_candidate(api: MutationAPI, candidate: Candidate, expected_app_id: int) -> PullRequest:
    if len(candidate.results) != 5 or len(set(candidate.results)) != 5:
        raise CoordinatorError("five_leg_attestation_invalid")
    lease_sha = api.get_ref(STABLE_LEASE)
    branch_sha = api.get_ref(STABLE_BRANCH)
    pr: PullRequest
    if lease_sha is None:
        if branch_sha is not None or api.pulls_for_branch():
            raise CoordinatorError("unowned_stable_state")
        lease = StableLease(
            "reserved", REPOSITORY, WORKFLOW, candidate.creator_run_id,
            expected_app_id, 1, candidate.tip, None, None, None, None,
            version=candidate.version,
            tag=candidate.tag,
            commit=candidate.commit,
            tree=candidate.tree,
            tree_manifest_sha256=candidate.tree_manifest_sha256,
            updater_run_url=candidate.updater_run_url,
            workflow_source_sha=candidate.workflow_source_sha,
            results=candidate.results,
        )
        lease_sha = _store_lease(api, lease, None)
        api.create_ref(STABLE_BRANCH, candidate.tip)
        if api.get_ref(STABLE_BRANCH) != candidate.tip:
            raise CoordinatorError("stable_branch_readback_mismatch")
        lease = replace(lease, phase="branch-bound", branch=STABLE_BRANCH, branch_sha=candidate.tip)
        lease_sha = _store_lease(api, lease, lease_sha)
        pr = api.create_pull(candidate, expected_app_id)
    else:
        lease = _owned_lease(api, lease_sha, expected_app_id)
        if lease.phase == "active":
            lease, pr = _owned_active(api, lease_sha, expected_app_id)
            lease = replace(
                lease,
                phase="refresh-leased",
                generation=lease.generation + 1,
                tested_tip=candidate.tip,
                prior_branch_sha=lease.branch_sha,
                creator_run_id=candidate.creator_run_id,
                version=candidate.version,
                tag=candidate.tag,
                commit=candidate.commit,
                tree=candidate.tree,
                tree_manifest_sha256=candidate.tree_manifest_sha256,
                updater_run_url=candidate.updater_run_url,
                workflow_source_sha=candidate.workflow_source_sha,
                results=candidate.results,
            )
            lease_sha = _store_lease(api, lease, lease_sha)
        elif candidate != _candidate_from_lease(lease):
            raise CoordinatorError("pending_candidate_identity_mismatch")
        if lease.phase == "reserved":
            if api.get_ref(STABLE_BRANCH) is None:
                api.create_ref(STABLE_BRANCH, lease.tested_tip)
            if api.get_ref(STABLE_BRANCH) != lease.tested_tip:
                raise CoordinatorError("reserved_branch_mismatch")
            lease = replace(lease, phase="branch-bound", branch=STABLE_BRANCH, branch_sha=lease.tested_tip)
            lease_sha = _store_lease(api, lease, lease_sha)
        if lease.phase == "refresh-leased":
            old = lease.prior_branch_sha
            observed = api.get_ref(STABLE_BRANCH)
            if observed == old:
                api.cas_ref(STABLE_BRANCH, old or "", lease.tested_tip)
            elif observed != lease.tested_tip:
                raise CoordinatorError("refresh_branch_observation_invalid")
            if api.get_ref(STABLE_BRANCH) != lease.tested_tip:
                raise CoordinatorError("stable_branch_readback_mismatch")
            lease = replace(lease, phase="refresh-branch-updated", branch=STABLE_BRANCH, branch_sha=lease.tested_tip)
            lease_sha = _store_lease(api, lease, lease_sha)
        pulls = api.pulls_for_branch()
        if lease.phase == "branch-bound":
            if not pulls:
                pr = api.create_pull(candidate, expected_app_id)
            elif len(pulls) == 1 and pulls[0].creator_app_id == expected_app_id and pulls[0].head_sha == lease.tested_tip and pulls[0].base_ref == "master" and pulls[0].state == "open":
                pr = pulls[0]
            else:
                raise CoordinatorError("branch_bound_pr_mismatch")
        else:
            if lease.pr_number is None:
                raise CoordinatorError("refresh_pr_missing")
            pr = api.pull(lease.pr_number)
            if pr.creator_app_id != expected_app_id or pr.head_sha != lease.tested_tip or pr.base_ref != "master" or pr.state != "open":
                raise CoordinatorError("refresh_pr_mismatch")
    body = marker(candidate, expected_app_id, pr.number)
    if pr.body != body:
        pr = api.update_pull(pr.number, body, candidate.tip)
    if pr.body != body or pr.head_sha != candidate.tip:
        raise CoordinatorError("stable_pr_readback_mismatch")
    lease = StableLease(**json.loads(api.get_lease(lease_sha)))
    if lease.phase != "refresh-pr-marked":
        marked = replace(lease, phase="refresh-pr-marked" if lease.phase == "refresh-branch-updated" else "branch-bound", pr_number=pr.number, marker_digest=digest(body))
        lease_sha = _store_lease(api, marked, lease_sha)
    else:
        marked = lease
    active = replace(marked, phase="active")
    _store_lease(api, active, lease_sha)
    return pr


def create_validation_pair(api: MutationAPI, candidate: Candidate, expected_app_id: int, nonce: str) -> tuple[str, str]:
    validation_ref = f"refs/heads/deps/adflib-validation/{candidate.creator_run_id}/{nonce}"
    lease_ref = f"refs/heads/deps/adflib-leases/validation/{candidate.creator_run_id}/{nonce}"
    descriptor: dict[str, str | int] = {"app_id": expected_app_id, "nonce": nonce, "repository": REPOSITORY, "run_id": candidate.creator_run_id, "tip_sha": candidate.tip, "validation_ref": validation_ref, "workflow": WORKFLOW}
    encoded = canonical(descriptor); lease_sha = api.write_lease(lease_ref, encoded, None)
    if api.get_ref(lease_ref) != lease_sha or api.get_lease(lease_sha) != encoded:
        raise CoordinatorError("validation_lease_readback_mismatch")
    try:
        api.create_ref(validation_ref, candidate.tip)
        if api.get_ref(validation_ref) != candidate.tip:
            raise CoordinatorError("validation_ref_readback_mismatch")
    except CoordinatorError:
        if api.get_ref(validation_ref) is None and api.get_ref(lease_ref) == lease_sha:
            api.delete_ref(lease_ref, lease_sha)
        raise
    return lease_ref, validation_ref


def cleanup_validation_pair(api: MutationAPI, lease_ref: str, validation_ref: str, tip: str) -> None:
    lease_sha = api.get_ref(lease_ref)
    if lease_sha is None:
        raise CoordinatorError("validation_lease_missing")
    descriptor = json.loads(api.get_lease(lease_sha))
    if descriptor.get("validation_ref") != validation_ref or descriptor.get("tip_sha") != tip:
        raise CoordinatorError("validation_lease_descriptor_mismatch")
    if api.get_ref(validation_ref) != tip:
        raise CoordinatorError("validation_ref_observation_mismatch")
    api.delete_ref(validation_ref, tip)
    if api.get_ref(validation_ref) is not None:
        raise CoordinatorError("validation_ref_delete_readback_mismatch")
    api.delete_ref(lease_ref, lease_sha)
    if api.get_ref(lease_ref) is not None:
        raise CoordinatorError("validation_lease_delete_readback_mismatch")


def reconcile_validation(api: MutationAPI, expected_app_id: int) -> None:
    leases = dict(api.list_refs("refs/heads/deps/adflib-leases/validation/"))
    validations = dict(api.list_refs("refs/heads/deps/adflib-validation/"))
    for lease_ref, lease_sha in leases.items():
        descriptor = json.loads(api.get_lease(lease_sha))
        validation_ref = descriptor.get("validation_ref")
        run_id = descriptor.get("run_id")
        tip = descriptor.get("tip_sha")
        if descriptor.get("repository") != REPOSITORY or descriptor.get("workflow") != WORKFLOW or descriptor.get("app_id") != expected_app_id or not isinstance(run_id, int) or not isinstance(validation_ref, str) or not isinstance(tip, str):
            raise CoordinatorError("validation_lease_owner_mismatch")
        run = api.run(run_id)
        if (run.repository, run.workflow, run.app_id) != (REPOSITORY, WORKFLOW, expected_app_id):
            raise CoordinatorError("validation_run_owner_mismatch")
        observed = validations.pop(validation_ref, None)
        if observed is None:
            if run.age_hours <= 24:
                continue
            api.delete_ref(lease_ref, lease_sha)
            continue
        if observed != tip:
            raise CoordinatorError("validation_tip_mismatch")
        if run.age_hours > 24:
            cleanup_validation_pair(api, lease_ref, validation_ref, tip)
    if validations:
        raise CoordinatorError("validation_ref_without_lease")


def attest_supplemental(api: MutationAPI, candidate: Candidate, pr_number: int, pre_creation_run_ids: frozenset[int], expected_app_id: int) -> RunIdentity:
    lease_sha = api.get_ref(STABLE_LEASE)
    if lease_sha is None:
        raise CoordinatorError("stable_lease_missing")
    _, pr = _owned_active(api, lease_sha, expected_app_id)
    expected_marker = json.loads(marker(candidate, expected_app_id, pr_number))
    observed_marker = json.loads(pr.body)
    if pr.number != pr_number or any(observed_marker.get(key) != value for key, value in expected_marker.items() if key != "supplemental_run_url"):
        raise CoordinatorError("supplemental_pr_binding_mismatch")
    matches = tuple(
        run for run in api.workflow_runs()
        if run.run_id not in pre_creation_run_ids
        and run.repository == REPOSITORY
        and run.workflow == ".github/workflows/adflib-consumers-ci.yml"
        and run.event == "pull_request_target"
        and run.pr_number == pr_number
        and run.head_sha == pr.head_sha == candidate.tip
        and run.source_sha == candidate.workflow_source_sha
        and run.source_sha != run.head_sha
        and run.base_ref == pr.base_ref == "master"
        and len(run.workflow_file_sha256) == 64
        and run.check_suite_app_id == GITHUB_ACTIONS_APP_ID
        and run.app_id == expected_app_id
    )
    if len(matches) != 1:
        raise CoordinatorError("supplemental_run_count_mismatch")
    run = matches[0]
    if run.conclusion != "success":
        raise CoordinatorError("supplemental_run_not_successful")
    return run


def mark_supplemental_ready(api: MutationAPI, candidate: Candidate, pr_number: int, run: RunIdentity, expected_app_id: int) -> None:
    lease_sha = api.get_ref(STABLE_LEASE)
    if lease_sha is None:
        raise CoordinatorError("stable_lease_missing")
    lease, pr = _owned_active(api, lease_sha, expected_app_id)
    old = json.loads(pr.body)
    expected = json.loads(marker(candidate, expected_app_id, pr_number))
    if any(old.get(key) != expected.get(key) for key in expected if key != "supplemental_run_url"):
        raise CoordinatorError("candidate_identity_substitution")
    body = marker(candidate, expected_app_id, pr_number, run.url)
    updated = api.update_pull(pr_number, body, candidate.tip)
    if updated.body != body:
        raise CoordinatorError("supplemental_marker_readback_mismatch")
    _store_lease(api, replace(lease, marker_digest=digest(body)), lease_sha)


def recover_owned(api: MutationAPI, action: str, observed_lease_sha: str, observed_branch_sha: str | None, observed_pr_number: int | None, observed_pr_head: str | None, expected_app_id: int) -> None:
    if api.get_ref(STABLE_LEASE) != observed_lease_sha or api.get_ref(STABLE_BRANCH) != observed_branch_sha:
        raise CoordinatorError("recovery_observation_mismatch")
    lease = _owned_lease(api, observed_lease_sha, expected_app_id)
    if action == "cleanup-orphan":
        if observed_branch_sha is not None or observed_pr_number is not None or observed_pr_head is not None or api.pulls_for_branch():
            raise CoordinatorError("orphan_absence_not_proven")
    else:
        if lease.pr_number != observed_pr_number or lease.branch_sha != observed_branch_sha or observed_pr_number is None:
            raise CoordinatorError("recovery_lease_binding_mismatch")
        _, pr = _owned_active(api, observed_lease_sha, expected_app_id, require_open=False)
        if pr.head_sha != observed_pr_head:
            raise CoordinatorError("recovery_pr_head_mismatch")
        if action == "cleanup-merged" and not pr.merged:
            raise CoordinatorError("recovery_pr_not_merged")
        if action == "cleanup-closed" and (pr.state != "closed" or pr.merged):
            raise CoordinatorError("recovery_pr_not_closed")
        api.delete_ref(STABLE_BRANCH, observed_branch_sha or "")
    api.delete_ref(STABLE_LEASE, observed_lease_sha)


class FakeGitHub:
    def __init__(self) -> None:
        self.refs: dict[str, str] = {}
        self.leases: dict[str, bytes] = {}
        self.prs: dict[int, PullRequest] = {}
        self.runs: dict[int, RunIdentity] = {}
        self.events: list[str] = []
        self.mutation_count = 0
        self.fail_on_mutation: int | None = None

    @classmethod
    def owned_active(cls, creator_app_id: int = 42, creator_user_id: int = 9001, creator_bot_login: str = "adflib-automation[bot]") -> FakeGitHub:
        api = cls(); candidate = Candidate.fixture(); api.runs[100] = RunIdentity(100, REPOSITORY, WORKFLOW, creator_app_id, candidate.workflow_source_sha)
        body = marker(replace(candidate, creator_run_id=100, tip="a" * 40), creator_app_id, 1)
        lease = StableLease("active", REPOSITORY, WORKFLOW, 100, creator_app_id, 1, "a" * 40, STABLE_BRANCH, "a" * 40, 1, digest(body))
        sha = digest(canonical(lease))[:40]; api.refs = {STABLE_LEASE: sha, STABLE_BRANCH: "a" * 40}; api.leases[sha] = canonical(lease)
        api.prs[1] = PullRequest(1, creator_app_id, "deps/adflib-stable", "a" * 40, "master", "open", False, body, creator_user_id, creator_bot_login, creator_bot_login.removesuffix("[bot]"))
        return api

    def _mutate(self) -> None:
        self.mutation_count += 1
        if self.fail_on_mutation == self.mutation_count: raise CoordinatorError("injected_mutation_failure")

    def get_ref(self, ref: str) -> str | None: return self.refs.get(ref)
    def get_lease(self, sha: str) -> bytes: return self.leases.get(sha, b"")
    def list_refs(self, prefix: str) -> tuple[tuple[str, str], ...]: return tuple((ref, sha) for ref, sha in self.refs.items() if ref.startswith(prefix))
    def write_lease(self, ref: str, descriptor: bytes, old_sha: str | None) -> str:
        sha = digest(descriptor)[:40]
        if old_sha is None: self.create_ref(ref, sha, descriptor)
        else: self.cas_ref(ref, old_sha, sha, descriptor)
        return sha
    def create_ref(self, ref: str, sha: str, descriptor: bytes | None = None) -> None:
        if ref in self.refs: raise CoordinatorError("ref_exists")
        self.refs[ref] = sha
        if descriptor is not None: self.leases[sha] = descriptor
        self.events.append(f"create:{ref}:{sha}")
        self._mutate()
    def cas_ref(self, ref: str, old_sha: str, new_sha: str, descriptor: bytes | None = None) -> None:
        if self.refs.get(ref) != old_sha: raise CoordinatorError("ref_cas_mismatch")
        self.refs[ref] = new_sha
        if ref == STABLE_BRANCH:
            self.prs = {number: replace(pr, head_sha=new_sha) for number, pr in self.prs.items()}
        if descriptor is not None: self.leases[new_sha] = descriptor
        self.events.append(f"cas:{ref}:{old_sha}:{new_sha}")
        self._mutate()
    def delete_ref(self, ref: str, old_sha: str) -> None:
        if self.refs.get(ref) != old_sha: raise CoordinatorError("ref_cas_mismatch")
        del self.refs[ref]
        self.events.append(f"delete:{ref}:{old_sha}")
        self._mutate()
    def run(self, run_id: int) -> RunIdentity: return self.runs[run_id]
    def pull(self, number: int) -> PullRequest: return self.prs[number]
    def pulls_for_branch(self) -> tuple[PullRequest, ...]: return tuple(self.prs.values())
    def create_pull(self, candidate: Candidate, app_id: int) -> PullRequest:
        number = max(self.prs, default=0) + 1; pr = PullRequest(number, app_id, "deps/adflib-stable", candidate.tip, "master", "open", False, b"", 9001, "adflib-automation[bot]", "adflib-automation"); self.prs[number] = pr; self.events.append(f"create-pr:{number}:{candidate.tip}"); self._mutate(); return pr
    def update_pull(self, number: int, body: bytes, expected_head: str) -> PullRequest:
        pr = self.prs[number]
        if pr.head_sha != expected_head: pr = replace(pr, head_sha=expected_head)
        pr = replace(pr, body=body); self.prs[number] = pr; self.events.append(f"update-pr:{number}:{expected_head}"); self._mutate(); return pr
    def workflow_runs(self) -> tuple[RunIdentity, ...]: return tuple(self.runs.values())
