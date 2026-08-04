#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# imported by test_update_adflib.py

from __future__ import annotations

import hashlib
import io
import json
import subprocess
import sys
import tarfile
import tempfile
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import ClassVar

SUPPORT = Path(__file__).resolve().parent.parent
UPDATER = SUPPORT / "update_adflib.py"
sys.path.insert(0, str(SUPPORT))
from license_inventory import build_inventory
from stage_adflib import git_object_sha


class FixtureHandler(BaseHTTPRequestHandler):
    responses: ClassVar[dict[str, tuple[int, bytes, str]]] = {}
    requests: ClassVar[list[str]] = []

    def do_GET(self) -> None:
        self.requests.append(self.path)
        status, body, content_type = self.responses.get(self.path, (404, b"missing", "text/plain"))
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, format: str, *args) -> None:
        return


class UpdaterFixture:
    current_commit = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    candidate_commit = "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"

    def __init__(self, current: dict[str, bytes], candidate: dict[str, bytes]) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.root = Path(self.temporary.name)
        self.support = self.root / "adflib"
        self.support.mkdir()
        self.manifest = self.support / "ADFlibDependency.cmake"
        self.ledger = self.support / "ADFlibLicenseApprovals.json"
        self.evidence = self.root / "evidence"
        self.patch = self.support / "patches/0001.patch"
        self.patch.parent.mkdir()
        self.patch.write_bytes(b"patch\n")
        self.current_files = current
        self.candidate_files = candidate
        self.current_tree, self.current_manifest_digest, _current_entries = self.tree(current)
        self.candidate_tree, self.candidate_manifest_digest, candidate_entries = self.tree(candidate)
        self.current_archive = self.archive(self.current_commit, current)
        self.candidate_archive = self.archive(self.candidate_commit, candidate)
        self.release = {
            "draft": False,
            "prerelease": False,
            "tag_name": "v0.10.8",
            "target_commitish": self.candidate_commit,
        }
        self.responses = {
            "/repos/adflib/ADFlib/releases/latest": self.json_response(self.release),
            "/repos/adflib/ADFlib/git/ref/tags/v0.10.8": self.json_response(
                {"ref": "refs/tags/v0.10.8", "object": {"type": "commit", "sha": self.candidate_commit}}
            ),
            f"/repos/adflib/ADFlib/git/commits/{self.candidate_commit}": self.json_response(
                {"sha": self.candidate_commit, "tree": {"sha": self.candidate_tree}}
            ),
            f"/repos/adflib/ADFlib/git/trees/{self.candidate_tree}?recursive=1": self.json_response(
                {"sha": self.candidate_tree, "truncated": False, "tree": candidate_entries}
            ),
            f"/adflib/ADFlib/archive/{self.current_commit}.tar.gz": (200, self.current_archive, "application/gzip"),
            f"/adflib/ADFlib/archive/{self.candidate_commit}.tar.gz": (200, self.candidate_archive, "application/gzip"),
        }
        self.write_manifest()
        self.write_ledger(current)
        FixtureHandler.responses = self.responses
        FixtureHandler.requests = []
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), FixtureHandler)
        self.thread = threading.Thread(target=self.server.serve_forever)
        self.thread.start()

    @staticmethod
    def json_response(payload) -> tuple[int, bytes, str]:
        return 200, json.dumps(payload, separators=(",", ":")).encode(), "application/json"

    @staticmethod
    def tree(files: dict[str, bytes]) -> tuple[str, str, list[dict[str, str | int]]]:
        entries: list[dict[str, str | int]] = []
        tree_parts: list[bytes] = []
        for name, content in sorted(files.items()):
            blob = git_object_sha("blob", content)
            entries.append({"path": name, "mode": "100644", "type": "blob", "sha": blob, "size": len(content)})
            tree_parts.append(f"100644 {name}\0".encode() + bytes.fromhex(blob))
        tree_sha = git_object_sha("tree", b"".join(tree_parts))
        rows = b"".join(f"100644\tblob\t{entry['sha']}\t{entry['path']}\n".encode() for entry in entries)
        return tree_sha, hashlib.sha256(rows).hexdigest(), entries

    @staticmethod
    def archive(commit: str, files: dict[str, bytes]) -> bytes:
        output = io.BytesIO()
        with tarfile.open(fileobj=output, mode="w:gz") as archive:
            for name, content in files.items():
                info = tarfile.TarInfo(f"ADFlib-{commit}/{name}")
                info.size = len(content)
                info.mode = 0o644
                archive.addfile(info, io.BytesIO(content))
        return output.getvalue()

    @staticmethod
    def hostile_archive(commit: str, case: str) -> bytes:
        output = io.BytesIO()
        with tarfile.open(fileobj=output, mode="w:gz") as archive:
            def regular(name: str, content: bytes) -> None:
                info = tarfile.TarInfo(name)
                info.size = len(content)
                archive.addfile(info, io.BytesIO(content))

            root = f"ADFlib-{commit}"
            if case == "archive-dotdot":
                regular(f"{root}/../escape", b"x")
            elif case == "archive-absolute":
                regular(f"/{root}/escape", b"x")
            elif case in {"archive-symlink", "archive-hardlink"}:
                info = tarfile.TarInfo(f"{root}/link")
                info.type = tarfile.SYMTYPE if case == "archive-symlink" else tarfile.LNKTYPE
                info.linkname = "target"
                archive.addfile(info)
            elif case == "archive-device":
                info = tarfile.TarInfo(f"{root}/device")
                info.type = tarfile.CHRTYPE
                archive.addfile(info)
            elif case == "archive-duplicate":
                regular(f"{root}/file", b"x")
                regular(f"{root}/file", b"y")
            elif case == "archive-case-collision":
                regular(f"{root}/README", b"x")
                regular(f"{root}/readme", b"y")
            elif case == "archive-member-limit":
                for index in range(20_001):
                    regular(f"{root}/f{index}", b"")
            elif case == "archive-size-limit":
                regular(f"{root}/large", b"0" * (32 * 1024 * 1024 + 1))
            elif case == "archive-expansion-limit":
                regular(f"{root}/expanded", b"0" * (1024 * 1024))
            else:
                raise RuntimeError(case)
        return output.getvalue()

    def write_manifest(self) -> None:
        fields = {
            "ADFLIB_OWNER_REPO": "adflib/ADFlib",
            "ADFLIB_VERSION": "0.10.7",
            "ADFLIB_TAG": "v0.10.7",
            "ADFLIB_COMMIT": self.current_commit,
            "ADFLIB_TREE_SHA": self.current_tree,
            "ADFLIB_ARCHIVE_URL": f"https://github.com/adflib/ADFlib/archive/{self.current_commit}.tar.gz",
            "ADFLIB_TREE_MANIFEST_SHA256": self.current_manifest_digest,
            "ADFLIB_PATCH_SHA256": hashlib.sha256(self.patch.read_bytes()).hexdigest(),
        }
        self.manifest.write_text("".join(f'set({key} "{value}")\n' for key, value in fields.items()), encoding="utf-8")

    def inventory_digest(self, files: dict[str, bytes]) -> str:
        source = self.root / "inventory"
        if source.exists():
            for child in source.iterdir():
                child.unlink()
        else:
            source.mkdir()
        for name, content in files.items():
            (source / name).write_bytes(content)
        return build_inventory(source).digest

    def write_ledger(self, current: dict[str, bytes]) -> None:
        baseline = {
            "version": "0.10.7",
            "tag": "v0.10.7",
            "commit": self.current_commit,
            "tree_sha": self.current_tree,
            "tree_manifest_sha256": self.current_manifest_digest,
            "license_inventory_sha256": self.inventory_digest(current),
            "status": "approved",
        }
        self.ledger.write_text(json.dumps({"schema_version": 1, "baseline": baseline, "approvals": []}), encoding="utf-8")

    def run(self, *extra: str) -> subprocess.CompletedProcess[str]:
        base = f"http://127.0.0.1:{self.server.server_port}"
        return subprocess.run(
            [
                sys.executable,
                str(UPDATER),
                "--manifest",
                str(self.manifest),
                "--ledger",
                str(self.ledger),
                "--evidence-dir",
                str(self.evidence),
                "--repository-root",
                str(self.root),
                "--api-base",
                base,
                "--archive-base",
                base,
                *extra,
            ],
            check=False,
            capture_output=True,
            text=True,
        )

    def close(self) -> None:
        self.server.shutdown()
        self.thread.join()
        self.server.server_close()
        self.temporary.cleanup()
