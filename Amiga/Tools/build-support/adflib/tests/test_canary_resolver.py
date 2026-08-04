#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Amiga/Tools/build-support/adflib/tests/test_canary_resolver.py

from __future__ import annotations

import base64
import gzip
import hashlib
import io
import json
import subprocess
import sys
import tarfile
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import ClassVar, Final

RESOLVER: Final = Path(__file__).resolve().parents[1] / "canary_resolver.py"
MANIFEST: Final = Path(__file__).resolve().parents[1] / "ADFlibDependency.cmake"


def git_sha(kind: str, content: bytes) -> str:
    return hashlib.sha1(f"{kind} {len(content)}\0".encode() + content).hexdigest()


def fixture_payloads() -> tuple[str, str, dict[str, bytes]]:
    content = b"cmake_minimum_required(VERSION 3.16)\n"
    blob_sha = git_sha("blob", content)
    tree_sha = git_sha("tree", b"100644 CMakeLists.txt\0" + bytes.fromhex(blob_sha))
    commit = "a" * 40
    archive_stream = io.BytesIO()
    with (
        gzip.GzipFile(fileobj=archive_stream, mode="wb", mtime=0) as compressed,
        tarfile.open(fileobj=compressed, mode="w") as archive,
    ):
        root = tarfile.TarInfo(f"ADFlib-{commit}")
        root.type = tarfile.DIRTYPE
        archive.addfile(root)
        member = tarfile.TarInfo(f"ADFlib-{commit}/CMakeLists.txt")
        member.size = len(content)
        archive.addfile(member, io.BytesIO(content))
    tree = {
        "sha": tree_sha,
        "tree": [{"mode": "100644", "path": "CMakeLists.txt", "sha": blob_sha, "type": "blob"}],
        "truncated": False,
    }
    payloads = {
        "/repos/adflib/ADFlib/branches/master": json.dumps({"name": "master", "commit": {"sha": commit}}).encode(),
        f"/repos/adflib/ADFlib/git/commits/{commit}": json.dumps({"sha": commit, "tree": {"sha": tree_sha}}).encode(),
        f"/repos/adflib/ADFlib/git/trees/{tree_sha}?recursive=1": json.dumps(tree).encode(),
        f"/archive/{commit}.tar.gz": archive_stream.getvalue(),
    }
    return commit, tree_sha, payloads


def symlink_fixture_payloads() -> tuple[str, str, dict[str, bytes]]:
    target_content = b"installation instructions\n"
    target_sha = git_sha("blob", target_content)
    link_content = b"INSTALL.md"
    link_sha = git_sha("blob", link_content)
    tree_content = (
        b"120000 INSTALL\0"
        + bytes.fromhex(link_sha)
        + b"100644 INSTALL.md\0"
        + bytes.fromhex(target_sha)
    )
    tree_sha = git_sha("tree", tree_content)
    commit = "b" * 40
    archive_stream = io.BytesIO()
    with (
        gzip.GzipFile(fileobj=archive_stream, mode="wb", mtime=0) as compressed,
        tarfile.open(fileobj=compressed, mode="w") as archive,
    ):
        root = tarfile.TarInfo(f"ADFlib-{commit}")
        root.type = tarfile.DIRTYPE
        archive.addfile(root)
        target = tarfile.TarInfo(f"ADFlib-{commit}/INSTALL.md")
        target.size = len(target_content)
        archive.addfile(target, io.BytesIO(target_content))
        link = tarfile.TarInfo(f"ADFlib-{commit}/INSTALL")
        link.type = tarfile.SYMTYPE
        link.linkname = "INSTALL.md"
        archive.addfile(link)
    tree = {
        "sha": tree_sha,
        "tree": [
            {"mode": "120000", "path": "INSTALL", "sha": link_sha, "type": "blob"},
            {"mode": "100644", "path": "INSTALL.md", "sha": target_sha, "type": "blob"},
        ],
        "truncated": False,
    }
    payloads = {
        "/repos/adflib/ADFlib/branches/master": json.dumps({"name": "master", "commit": {"sha": commit}}).encode(),
        f"/repos/adflib/ADFlib/git/commits/{commit}": json.dumps({"sha": commit, "tree": {"sha": tree_sha}}).encode(),
        f"/repos/adflib/ADFlib/git/trees/{tree_sha}?recursive=1": json.dumps(tree).encode(),
        f"/repos/adflib/ADFlib/git/blobs/{link_sha}": json.dumps(
            {"content": base64.b64encode(link_content).decode(), "encoding": "base64", "sha": link_sha}
        ).encode(),
        f"/archive/{commit}.tar.gz": archive_stream.getvalue(),
    }
    return commit, tree_sha, payloads


class FixtureHandler(BaseHTTPRequestHandler):
    payloads: ClassVar[dict[str, bytes]] = {}
    requests: ClassVar[list[str]] = []

    def do_GET(self) -> None:
        type(self).requests.append(self.path)
        payload = type(self).payloads.get(self.path)
        if payload is None:
            self.send_error(404)
            return
        self.send_response(200)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format: str, *args: str | float | None) -> None:
        return


class CanaryResolverTests(unittest.TestCase):
    def test_resolves_master_once_and_verifies_archive_without_mutating_manifest(self) -> None:
        # Given: one upstream master snapshot served by a local HTTP fixture.
        commit, tree_sha, payloads = fixture_payloads()
        FixtureHandler.payloads = payloads
        FixtureHandler.requests = []
        before = hashlib.sha256(MANIFEST.read_bytes()).hexdigest()
        server = ThreadingHTTPServer(("127.0.0.1", 0), FixtureHandler)
        thread = threading.Thread(target=server.serve_forever)
        thread.start()
        try:
            with tempfile.TemporaryDirectory() as temporary:
                root = Path(temporary)
                base = f"http://127.0.0.1:{server.server_port}"
                (root / "outputs").touch()
                # When: the trusted canary resolver captures and verifies the candidate.
                result = subprocess.run(
                    [
                        sys.executable,
                        str(RESOLVER),
                        "resolve",
                        "--api-base",
                        base,
                        "--archive-base",
                        f"{base}/archive",
                        "--artifacts",
                        str(root / "artifacts"),
                        "--output",
                        str(root / "outputs"),
                    ],
                    check=False,
                    capture_output=True,
                    text=True,
                )
                # Then: one exact identity is emitted and production bytes remain unchanged.
                self.assertEqual(result.returncode, 0, result.stderr)
                identity = json.loads((root / "artifacts/canary-identity.json").read_text(encoding="utf-8"))
                outputs = dict(line.split("=", 1) for line in (root / "outputs").read_text(encoding="utf-8").splitlines())
                self.assertEqual(identity["channel"], "canary")
                self.assertEqual(identity["commit"], commit)
                self.assertEqual(identity["tree_sha"], tree_sha)
                self.assertEqual(outputs["effective_commit"], commit)
                self.assertEqual(len(outputs["effective_tree_manifest_sha256"]), 64)
                self.assertEqual(len(outputs["transport_sha256"]), 64)
                self.assertEqual(FixtureHandler.requests.count("/repos/adflib/ADFlib/branches/master"), 1)
                self.assertEqual(hashlib.sha256(MANIFEST.read_bytes()).hexdigest(), before)
        finally:
            server.shutdown()
            thread.join()
            server.server_close()

    def test_derives_safe_symlink_policy_from_captured_git_blob(self) -> None:
        # Given: the captured tree contains a relative symlink and its exact Git blob.
        commit, _, payloads = symlink_fixture_payloads()
        FixtureHandler.payloads = payloads
        FixtureHandler.requests = []
        server = ThreadingHTTPServer(("127.0.0.1", 0), FixtureHandler)
        thread = threading.Thread(target=server.serve_forever)
        thread.start()
        try:
            with tempfile.TemporaryDirectory() as temporary:
                base = f"http://127.0.0.1:{server.server_port}"
                # When: the resolver verifies the tree and archive through the shared boundary.
                result = subprocess.run(
                    [
                        sys.executable,
                        str(RESOLVER),
                        "resolve",
                        "--api-base",
                        base,
                        "--archive-base",
                        f"{base}/archive",
                        "--artifacts",
                        str(Path(temporary) / "artifacts"),
                        "--output",
                        str(Path(temporary) / "output"),
                    ],
                    check=False,
                    capture_output=True,
                    text=True,
                )
                # Then: the exact link blob is fetched once and the verified candidate succeeds.
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(
                    FixtureHandler.requests.count(f"/repos/adflib/ADFlib/git/blobs/{git_sha('blob', b'INSTALL.md')}"),
                    1,
                )
                self.assertIn(commit, (Path(temporary) / "artifacts/canary-identity.json").read_text(encoding="utf-8"))
        finally:
            server.shutdown()
            thread.join()
            server.server_close()


if __name__ == "__main__":
    unittest.main()
