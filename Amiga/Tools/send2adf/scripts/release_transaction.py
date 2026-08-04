from __future__ import annotations

import hashlib
import json
from dataclasses import asdict, dataclass
from typing import Protocol


@dataclass(frozen=True, slots=True)
class ReleaseIdentity:
    repository: str
    workflow: str
    run_id: int
    tag: str
    target_sha: str
    app_id: int

    def canonical(self) -> str:
        return json.dumps(asdict(self), sort_keys=True, separators=(",", ":"))


@dataclass(frozen=True, slots=True)
class Lease:
    sha: str
    identity: ReleaseIdentity
    phase: str
    release_id: int | None
    inventory_sha256: str | None
    generation: int
    producer_run_id: int


@dataclass(frozen=True, slots=True)
class Asset:
    asset_id: int
    name: str
    content: bytes


@dataclass(frozen=True, slots=True)
class Release:
    release_id: int
    identity: ReleaseIdentity
    draft: bool
    assets: tuple[Asset, ...]


@dataclass(frozen=True, slots=True)
class RecoveryObservation:
    lease_sha: str
    release_id: int | None
    inventory_sha256: str | None


@dataclass(frozen=True, slots=True)
class TransactionError(Exception):
    message: str

    def __str__(self) -> str:
        return self.message


class ReleaseApi(Protocol):
    def read_lease(self, tag: str) -> Lease | None: ...
    def reserve(self, identity: ReleaseIdentity) -> Lease: ...
    def transfer(self, expected: Lease, identity: ReleaseIdentity) -> Lease: ...
    def bind_draft(self, expected: Lease, release_id: int) -> Lease: ...
    def bind_inventory(self, expected: Lease, inventory_sha256: str) -> Lease: ...
    def delete_reserved(self, expected: Lease) -> None: ...
    def prior_run_terminal(self, run_id: int) -> bool: ...
    def releases_for_tag(self, tag: str) -> tuple[Release, ...]: ...
    def read_release(self, release_id: int) -> Release | None: ...
    def create_draft(self, identity: ReleaseIdentity) -> Release: ...
    def delete_asset(self, release_id: int, asset_id: int) -> None: ...
    def upload_asset(self, release_id: int, name: str, content: bytes) -> None: ...
    def publish(self, release_id: int) -> None: ...


def inventory_digest(files: dict[str, bytes]) -> str:
    records = b"".join(
        f"{name}\t{len(content)}\t{hashlib.sha256(content).hexdigest()}\n".encode()
        for name, content in sorted(files.items(), key=lambda item: item[0].encode())
    )
    return hashlib.sha256(records).hexdigest()


def _producer_identity(actual: ReleaseIdentity, lease: Lease) -> bool:
    prior = lease.identity
    return (
        actual.repository == prior.repository
        and actual.workflow == prior.workflow
        and actual.run_id == lease.producer_run_id
        and actual.tag == prior.tag
        and actual.target_sha == prior.target_sha
        and actual.app_id == prior.app_id
    )


def _owned(release: Release, lease: Lease) -> bool:
    return _producer_identity(release.identity, lease) and release.release_id == lease.release_id


def _verify_assets(release: Release, files: dict[str, bytes]) -> bool:
    actual = {asset.name: asset.content for asset in release.assets}
    return actual == files


def _reconcile(api: ReleaseApi, lease: Lease, release: Release, files: dict[str, bytes]) -> Release:
    actual = {asset.name: asset for asset in release.assets}
    if len(actual) != len(release.assets):
        raise TransactionError("owned draft has duplicate asset names")
    for name, asset in actual.items():
        expected = files.get(name)
        if expected is None or expected != asset.content:
            api.delete_asset(release.release_id, asset.asset_id)
    for name, content in files.items():
        asset = actual.get(name)
        if asset is None or asset.content != content:
            api.upload_asset(release.release_id, name, content)
    observed = api.read_release(release.release_id)
    if observed is None or not observed.draft or not _owned(observed, lease) or not _verify_assets(observed, files):
        raise TransactionError("owned draft asset readback mismatch")
    return observed


def execute_release(
    api: ReleaseApi,
    identity: ReleaseIdentity,
    mode: str,
    files: dict[str, bytes],
    observation: RecoveryObservation | None = None,
) -> str:
    if len(files) != 5 or "SHA256SUMS" not in files:
        raise TransactionError("publication inventory is incomplete")
    expected_inventory = inventory_digest(files)
    lease = api.read_lease(identity.tag)
    if mode == "publish":
        if lease is not None:
            raise TransactionError("release lease already exists; use exact owned recovery")
        lease = api.reserve(identity)
        if api.read_lease(identity.tag) != lease:
            raise TransactionError("reserved lease readback mismatch")
        try:
            release = api.create_draft(identity)
        except TransactionError:
            api.delete_reserved(lease)
            raise
        lease = api.bind_draft(lease, release.release_id)
    elif mode == "recover-owned":
        if lease is None or observation is None:
            raise TransactionError("recovery lease is absent")
        if observation != RecoveryObservation(lease.sha, lease.release_id, lease.inventory_sha256):
            raise TransactionError("recovery observations do not match durable lease")
        if lease.identity.target_sha != identity.target_sha or lease.identity.repository != identity.repository or lease.identity.workflow != identity.workflow or lease.identity.tag != identity.tag or lease.identity.app_id != identity.app_id:
            raise TransactionError("release lease identity mismatch")
        if not api.prior_run_terminal(lease.identity.run_id):
            raise TransactionError("prior release run is not terminal")
        release = api.read_release(lease.release_id) if lease.release_id is not None else None
        if lease.phase == "inventory-bound" and release is not None and not release.draft:
            if not _owned(release, lease) or lease.inventory_sha256 != expected_inventory or not _verify_assets(release, files):
                raise TransactionError("published release diverges from durable inventory")
            return "published-noop"
        if lease.phase == "reserved":
            candidates = api.releases_for_tag(identity.tag)
            owned = tuple(item for item in candidates if item.draft and _producer_identity(item.identity, lease))
            if not candidates:
                api.delete_reserved(lease)
                return "reserved-cleaned"
            if not owned:
                raise TransactionError("reserved lease has a foreign provisional draft")
            if len(owned) != 1:
                raise TransactionError("reserved lease has ambiguous provisional drafts")
            release = owned[0]
            lease = api.transfer(lease, identity)
            lease = api.bind_draft(lease, release.release_id)
        else:
            if release is None or not release.draft or not _owned(release, lease):
                raise TransactionError("recoverable owned draft is absent")
            if lease.phase == "inventory-bound" and (lease.inventory_sha256 != expected_inventory or not _verify_assets(release, files)):
                raise TransactionError("inventory-bound draft diverges before adoption")
            lease = api.transfer(lease, identity)
    else:
        raise TransactionError("unsupported release mode")
    if lease.phase == "draft-bound-uninventoried":
        release = api.read_release(lease.release_id or 0)
        if release is None or not release.draft or not _owned(release, lease):
            raise TransactionError("bound draft is absent")
        _reconcile(api, lease, release, files)
        lease = api.bind_inventory(lease, expected_inventory)
    if lease.phase != "inventory-bound" or lease.inventory_sha256 != expected_inventory:
        raise TransactionError("inventory-bound lease digest mismatch")
    release = api.read_release(lease.release_id or 0)
    if release is None or not release.draft or not _owned(release, lease) or not _verify_assets(release, files):
        raise TransactionError("inventory-bound draft readback mismatch")
    api.publish(release.release_id)
    published = api.read_release(release.release_id)
    if published is None or published.draft or not _owned(published, lease) or not _verify_assets(published, files):
        raise TransactionError("published release readback mismatch")
    return "published"
