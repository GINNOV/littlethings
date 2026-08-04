from __future__ import annotations

from dataclasses import replace

from Tools.send2adf.scripts.release_transaction import (
    Asset,
    Lease,
    RecoveryObservation,
    Release,
    ReleaseIdentity,
    TransactionError,
    execute_release,
    inventory_digest,
)

BOUNDARIES = (
    "reserve", "lease-readback", "draft-create", "draft-bind-cas",
    "asset-delete", "asset-upload", "asset-readback", "inventory-bind-cas",
    "publish", "publish-readback", "reserved-cleanup", "lease-transfer-cas", "prior-run-readback",
    "draft-inventory-readback",
)


class InjectedCrash(RuntimeError):
    pass


class StatefulReleaseApi:
    def __init__(self, fail_after: str | None = None) -> None:
        self.lease: Lease | None = None
        self.releases: dict[int, Release] = {}
        self.terminal_runs: set[int] = {7}
        self.events: list[str] = []
        self.fail_after = fail_after
        self._next_sha = 1
        self._next_release = 40
        self._next_asset = 100

    def _event(self, name: str) -> None:
        self.events.append(name)
        if self.fail_after == name:
            raise InjectedCrash(f"injected failure after {name}")

    def _sha(self) -> str:
        value = f"{self._next_sha:040x}"
        self._next_sha += 1
        return value

    def read_lease(self, tag: str) -> Lease | None:
        value = self.lease if self.lease is not None and self.lease.identity.tag == tag else None
        if self.events and self.events[-1] in {"reserve", "draft-bind-cas", "inventory-bind-cas", "lease-transfer-cas"}:
            self._event("lease-readback")
        return value

    def reserve(self, identity: ReleaseIdentity) -> Lease:
        if self.lease is not None:
            raise TransactionError("lease exists")
        self.lease = Lease(self._sha(), identity, "reserved", None, None, 1, identity.run_id)
        self._event("reserve")
        return self.lease

    def _cas(self, expected: Lease, value: Lease, event: str) -> Lease:
        if self.lease != expected:
            raise TransactionError("lease CAS lost")
        self.lease = value
        self._event(event)
        return value

    def transfer(self, expected: Lease, identity: ReleaseIdentity) -> Lease:
        return self._cas(expected, replace(expected, sha=self._sha(), identity=identity, generation=expected.generation + 1), "lease-transfer-cas")

    def bind_draft(self, expected: Lease, release_id: int) -> Lease:
        value = replace(expected, sha=self._sha(), phase="draft-bound-uninventoried", release_id=release_id, inventory_sha256=None, generation=expected.generation + 1)
        return self._cas(expected, value, "draft-bind-cas")

    def bind_inventory(self, expected: Lease, inventory_sha256: str) -> Lease:
        value = replace(expected, sha=self._sha(), phase="inventory-bound", inventory_sha256=inventory_sha256, generation=expected.generation + 1)
        return self._cas(expected, value, "inventory-bind-cas")

    def delete_reserved(self, expected: Lease) -> None:
        if self.lease != expected or expected.phase != "reserved":
            raise TransactionError("reserved cleanup CAS lost")
        self.lease = None
        self._event("reserved-cleanup")

    def prior_run_terminal(self, run_id: int) -> bool:
        self._event("prior-run-readback")
        return run_id in self.terminal_runs

    def releases_for_tag(self, tag: str) -> tuple[Release, ...]:
        self._event("draft-inventory-readback")
        return tuple(item for item in self.releases.values() if item.identity.tag == tag)

    def read_release(self, release_id: int) -> Release | None:
        value = self.releases.get(release_id)
        if self.events:
            if self.events[-1] in {"asset-delete", "asset-upload"}:
                self._event("asset-readback")
            elif self.events[-1] == "publish":
                self._event("publish-readback")
        return value

    def create_draft(self, identity: ReleaseIdentity) -> Release:
        self._next_release += 1
        value = Release(self._next_release, identity, True, ())
        self.releases[value.release_id] = value
        self._event("draft-create")
        return value

    def delete_asset(self, release_id: int, asset_id: int) -> None:
        release = self.releases[release_id]
        self.releases[release_id] = replace(release, assets=tuple(item for item in release.assets if item.asset_id != asset_id))
        self._event("asset-delete")

    def upload_asset(self, release_id: int, name: str, content: bytes) -> None:
        release = self.releases[release_id]
        self._next_asset += 1
        self.releases[release_id] = replace(release, assets=(*release.assets, Asset(self._next_asset, name, content)))
        self._event("asset-upload")

    def publish(self, release_id: int) -> None:
        self.releases[release_id] = replace(self.releases[release_id], draft=False)
        self._event("publish")


def identity(run_id: int = 7) -> ReleaseIdentity:
    return ReleaseIdentity("owner/repo", ".github/workflows/send2adf-release.yml", run_id, "send2adf-v1.5.0", "8" * 40, 15368)


def files() -> dict[str, bytes]:
    return {
        "send2adf-1.5.0-macos-arm64.tar.gz": b"arm",
        "send2adf-1.5.0-macos-x86_64.tar.gz": b"intel",
        "send2adf-1.5.0-linux-x86_64.tar.gz": b"linux",
        "send2adf-1.5.0-source.tar.gz": b"source",
        "SHA256SUMS": b"checksums",
    }


def observation(api: StatefulReleaseApi) -> RecoveryObservation:
    if api.lease is None:
        raise AssertionError("fixture lease is absent")
    return RecoveryObservation(api.lease.sha, api.lease.release_id, api.lease.inventory_sha256)


def seed(api: StatefulReleaseApi, phase: str, *, drafts: int = 1, owned: bool = True, published: bool = False) -> None:
    prior = identity()
    api.lease = Lease(api._sha(), prior, "reserved", None, None, 1, prior.run_id)
    for index in range(drafts):
        release_identity = prior if owned else replace(prior, repository="foreign/repo")
        api._next_release += 1
        release = Release(api._next_release, release_identity, not published, ())
        api.releases[release.release_id] = release
        if index == 0 and phase != "reserved":
            lease = api.lease
            if lease is None:
                raise AssertionError("seed lease is absent")
            api.lease = replace(lease, phase=phase, release_id=release.release_id, generation=2)
    if phase == "inventory-bound" and api.lease is not None:
        assets = tuple(Asset(200 + index, name, content) for index, (name, content) in enumerate(files().items()))
        release_id = api.lease.release_id or 0
        api.releases[release_id] = replace(api.releases[release_id], assets=assets, draft=not published)
        api.lease = replace(api.lease, inventory_sha256=inventory_digest(files()), generation=3)


def run_stateful_case(name: str) -> None:
    aliases = {"adoption": "prior-run-adoption", "foreign-draft": "unowned-draft", "stale-observation": "invalid-draft-bound-observation", "published-noop": "rerun-exact"}
    if name in aliases:
        run_stateful_case(aliases[name])
        return
    if name == "draft-publish":
        api = StatefulReleaseApi()
        result = execute_release(api, identity(), "publish", files())
        required = ("reserve", "draft-create", "draft-bind-cas", "asset-upload", "asset-readback", "inventory-bind-cas", "publish", "publish-readback")
        positions = [api.events.index(event) for event in required]
        if result != "published" or positions != sorted(positions):
            raise AssertionError("draft publication did not complete")
        return
    if name == "authorized-transfer-chain":
        api = StatefulReleaseApi("lease-transfer-cas")
        seed(api, "draft-bound-uninventoried")
        try:
            execute_release(api, identity(9), "recover-owned", files(), observation(api))
        except InjectedCrash:
            pass
        else:
            raise AssertionError("authorized transfer interruption was not injected")
        lease = api.lease
        if lease is None or lease.identity.run_id != 9 or lease.producer_run_id != 7:
            raise AssertionError("lease transfer did not retain the exact producer chain")
        release = api.releases[lease.release_id or 0]
        if release.identity.run_id != lease.producer_run_id:
            raise AssertionError("release marker is not bound to the immutable producer")
        api.fail_after = None
        api.terminal_runs.add(9)
        if execute_release(api, identity(10), "recover-owned", files(), observation(api)) != "published":
            raise AssertionError("authorized transfer chain did not recover")
        final_lease = api.lease
        if final_lease is None or final_lease.identity.run_id != 10 or final_lease.producer_run_id != 7:
            raise AssertionError("subsequent transfer changed the immutable producer")
        return
    if name in {"partial-upload", "runner-loss"}:
        for boundary in BOUNDARIES:
            api = StatefulReleaseApi(boundary)
            mode = "publish"
            observed = None
            if boundary in {"reserved-cleanup", "draft-inventory-readback"}:
                seed(api, "reserved", drafts=0)
                mode = "recover-owned"
                observed = observation(api)
            elif boundary in {"lease-transfer-cas", "prior-run-readback", "asset-delete"}:
                seed(api, "draft-bound-uninventoried")
                mode = "recover-owned"
                observed = observation(api)
                if boundary == "asset-delete" and api.lease is not None:
                    release = api.releases[api.lease.release_id or 0]
                    api.releases[release.release_id] = replace(release, assets=(Asset(999, "stale", b"stale"),))
            try:
                execute_release(api, identity(9), mode, files(), observed)
            except (InjectedCrash, TransactionError):
                if any(not item.draft and len(item.assets) != 5 for item in api.releases.values()):
                    raise AssertionError(f"partial release published after {boundary}")
                api.fail_after = None
                if api.lease is not None:
                    api.terminal_runs.add(api.lease.identity.run_id)
                    execute_release(api, identity(api.lease.identity.run_id + 1), "recover-owned", files(), observation(api))
                if any(item.draft or len(item.assets) != 5 for item in api.releases.values()):
                    raise AssertionError(f"boundary recovery did not converge after {boundary}")
        return
    api = StatefulReleaseApi()
    phase_cases = {
        "reserved-no-draft": ("reserved", 0), "reserved-one-draft": ("reserved", 1),
        "reserved-multiple-drafts": ("reserved", 2), "prior-run-adoption": ("reserved", 1),
        "expired-run-durable-lease": ("reserved", 1),
        "draft-bound-uninventoried-resume": ("draft-bound-uninventoried", 1),
        "inventory-bound-resume": ("inventory-bound", 1), "rerun-exact": ("inventory-bound", 1),
        "published-divergence": ("inventory-bound", 1), "unowned-asset": ("draft-bound-uninventoried", 1),
        "lease-transfer-loss": ("draft-bound-uninventoried", 1), "concurrent-rerun": ("draft-bound-uninventoried", 1),
        "invalid-prior-run": ("draft-bound-uninventoried", 1), "unowned-draft": ("reserved", 1),
        "invalid-reserved-observation": ("reserved", 0),
        "invalid-draft-bound-observation": ("draft-bound-uninventoried", 1),
        "invalid-inventory-bound-observation": ("inventory-bound", 1),
        "reserved-mismatched-run": ("reserved", 1),
        "published-noop-mismatched-run": ("inventory-bound", 1),
    }
    if name == "orphan-without-lease":
        try:
            execute_release(api, identity(9), "recover-owned", files(), RecoveryObservation("1" * 40, None, None))
        except TransactionError:
            return
        raise AssertionError("orphan recovery succeeded")
    phase, drafts = phase_cases[name]
    seed(api, phase, drafts=drafts, owned=name != "unowned-draft", published=name in {"rerun-exact", "published-divergence", "published-noop-mismatched-run"})
    if name == "invalid-prior-run":
        api.terminal_runs.clear()
    if name == "unowned-asset" and api.lease is not None:
        release = api.releases[api.lease.release_id or 0]
        api.releases[release.release_id] = replace(release, assets=(Asset(999, "foreign.bin", b"foreign"),))
    if name == "published-divergence" and api.lease is not None:
        release = api.releases[api.lease.release_id or 0]
        api.releases[release.release_id] = replace(release, assets=(*release.assets[:-1], replace(release.assets[-1], content=b"tampered")))
    if name in {"reserved-mismatched-run", "published-noop-mismatched-run"}:
        release = next(iter(api.releases.values()))
        api.releases[release.release_id] = replace(release, identity=replace(release.identity, run_id=666))
    observed = observation(api)
    if name == "concurrent-rerun":
        first_observation = observed
        execute_release(api, identity(9), "recover-owned", files(), first_observation)
        before = (api.lease, dict(api.releases), tuple(api.events))
        try:
            execute_release(api, identity(10), "recover-owned", files(), first_observation)
        except TransactionError:
            if (api.lease, api.releases, tuple(api.events)) != before:
                raise AssertionError("losing concurrent rerun mutated release state")
            return
        raise AssertionError("losing concurrent rerun succeeded")
    if name == "lease-transfer-loss":
        api.fail_after = "lease-transfer-cas"
    if name.startswith("invalid-") and name.endswith("-observation"):
        observed = replace(observed, lease_sha="f" * 40)
    should_fail = name in {
        "reserved-multiple-drafts", "published-divergence", "lease-transfer-loss",
        "invalid-prior-run", "unowned-draft", "invalid-reserved-observation",
        "invalid-draft-bound-observation", "invalid-inventory-bound-observation",
        "reserved-mismatched-run", "published-noop-mismatched-run",
    }
    state_before = (api.lease, dict(api.releases))
    try:
        result = execute_release(api, identity(9), "recover-owned", files(), observed)
    except (InjectedCrash, TransactionError):
        if should_fail:
            if name != "lease-transfer-loss" and (api.lease, api.releases) != state_before:
                raise AssertionError(f"failed recovery mutated state: {name}")
            return
        raise
    if should_fail:
        raise AssertionError(f"unsafe recovery succeeded: {name}")
    if name == "rerun-exact" and result != "published-noop":
        raise AssertionError("exact published release was not a no-op")
