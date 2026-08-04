#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest tests/test_release_resolver.py

from __future__ import annotations

import hashlib
import json
import re
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Final

from stage_adflib import StageError, parse_tree_response

VERSION_PATTERN: Final = re.compile(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)")
HEX40: Final = re.compile(r"[0-9a-f]{40}")


@dataclass(frozen=True, slots=True)
class ResolverError(Exception):
    code: str
    detail: str

    def __str__(self) -> str:
        return f"{self.code}: {self.detail}"


@dataclass(frozen=True, slots=True, order=True)
class Version:
    major: int
    minor: int
    patch: int


@dataclass(frozen=True, slots=True)
class ReleaseCandidate:
    version: Version
    version_text: str
    tag: str
    commit: str
    tree_sha: str
    url: str
    tree_manifest_sha256: str


def parse_version(tag: str) -> Version:
    match = VERSION_PATTERN.fullmatch(tag)
    if match is None:
        raise ResolverError("release_version_invalid", tag)
    return Version(*(int(component) for component in match.groups()))


class NoRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, file_pointer, code: int, message: str, headers, new_url: str) -> None:
        return None


def _request(api_base: str, endpoint: str) -> bytes:
    url = f"{api_base.rstrip('/')}{endpoint}"
    request = urllib.request.Request(url, headers={"Accept": "application/vnd.github+json", "User-Agent": "littlethings-adflib-updater/1"})
    try:
        with urllib.request.build_opener(NoRedirectHandler()).open(request, timeout=60) as response:
            return response.read()
    except urllib.error.HTTPError as error:
        location = error.headers.get("Location", "")
        error.close()
        if error.code in {301, 302, 303, 307, 308}:
            raise ResolverError("api_redirect_rejected", location) from None
        raise ResolverError("api_request_failed", f"{error.code} {endpoint}") from error
    except urllib.error.URLError as error:
        raise ResolverError("api_request_failed", str(error.reason)) from error


def _decode(payload: bytes, code: str):
    try:
        return json.loads(payload)
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        raise ResolverError(code, str(error)) from error


def _release(api_base: str) -> tuple[str, Version, str] | None:
    payload = _decode(_request(api_base, "/repos/adflib/ADFlib/releases/latest"), "release_json_invalid")
    if not isinstance(payload, dict):
        raise ResolverError("release_json_invalid", "release must be an object")
    draft = payload.get("draft")
    prerelease = payload.get("prerelease")
    tag = payload.get("tag_name")
    target = payload.get("target_commitish")
    if not isinstance(draft, bool) or not isinstance(prerelease, bool) or not isinstance(tag, str) or not isinstance(target, str):
        raise ResolverError("release_json_invalid", "release fields have wrong types")
    if draft or prerelease:
        return None
    return tag, parse_version(tag), target


def _tag_commit(api_base: str, tag: str) -> str:
    encoded_tag = urllib.parse.quote(tag, safe="")
    payload = _decode(
        _request(api_base, f"/repos/adflib/ADFlib/git/ref/tags/{encoded_tag}"),
        "tag_ref_json_invalid",
    )
    if not isinstance(payload, dict):
        raise ResolverError("tag_ref_json_invalid", "tag ref must be an object")
    ref = payload.get("ref")
    target = payload.get("object")
    if ref != f"refs/tags/{tag}" or not isinstance(target, dict):
        raise ResolverError("tag_ref_mismatch", tag)
    seen: set[str] = set()
    for hop in range(6):
        kind = target.get("type")
        sha = target.get("sha")
        if not isinstance(kind, str) or not isinstance(sha, str) or HEX40.fullmatch(sha) is None:
            raise ResolverError("tag_object_invalid", tag)
        if kind == "commit":
            return sha
        if kind != "tag":
            raise ResolverError("tag_terminal_not_commit", kind)
        if hop == 5:
            raise ResolverError("tag_peel_limit", tag)
        if sha in seen:
            raise ResolverError("tag_cycle", sha)
        seen.add(sha)
        payload = _decode(
            _request(api_base, f"/repos/adflib/ADFlib/git/tags/{sha}"),
            "tag_object_json_invalid",
        )
        if not isinstance(payload, dict) or payload.get("sha") != sha or not isinstance(payload.get("object"), dict):
            raise ResolverError("tag_object_mismatch", sha)
        target = payload["object"]
    raise ResolverError("tag_peel_limit", tag)


def _commit_tree(api_base: str, commit: str) -> str:
    payload = _decode(
        _request(api_base, f"/repos/adflib/ADFlib/git/commits/{commit}"),
        "commit_json_invalid",
    )
    if not isinstance(payload, dict) or payload.get("sha") != commit or not isinstance(payload.get("tree"), dict):
        raise ResolverError("commit_response_mismatch", commit)
    tree_sha = payload["tree"].get("sha")
    if not isinstance(tree_sha, str) or HEX40.fullmatch(tree_sha) is None:
        raise ResolverError("commit_tree_invalid", commit)
    return tree_sha


def _tree_manifest(api_base: str, tree_sha: str, response_root: Path | None) -> str:
    payload = _request(api_base, f"/repos/adflib/ADFlib/git/trees/{tree_sha}?recursive=1")
    temporary_parent = response_root
    with tempfile.NamedTemporaryFile(dir=temporary_parent, suffix=".json") as stream:
        stream.write(payload)
        stream.flush()
        try:
            entries = parse_tree_response(Path(stream.name), tree_sha)
        except (StageError, json.JSONDecodeError) as error:
            code = error.code if isinstance(error, StageError) else "git_tree_json_invalid"
            raise ResolverError(code, str(error)) from error
    canonical = b"".join(entry.row() for entry in sorted(entries, key=lambda entry: entry.row()))
    return hashlib.sha256(canonical).hexdigest()


def resolve_release(api_base: str, response_root: Path | None = None) -> ReleaseCandidate | None:
    release = _release(api_base)
    if release is None:
        return None
    tag, version, target = release
    commit = _tag_commit(api_base, tag)
    if HEX40.fullmatch(target) is not None and target != commit:
        raise ResolverError("tag_commit_mismatch", f"{target} != {commit}")
    tree_sha = _commit_tree(api_base, commit)
    tree_manifest = _tree_manifest(api_base, tree_sha, response_root)
    return ReleaseCandidate(
        version,
        f"{version.major}.{version.minor}.{version.patch}",
        tag,
        commit,
        tree_sha,
        f"https://github.com/adflib/ADFlib/archive/{commit}.tar.gz",
        tree_manifest,
    )
