#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 -m unittest test_redirect_policy.py

from __future__ import annotations

import sys
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import ClassVar

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from stage_adflib import RedirectContract, StageError, download


class RedirectHandler(BaseHTTPRequestHandler):
    requests: ClassVar[list[str]] = []

    def do_GET(self) -> None:
        self.requests.append(self.path)
        if self.path == "/api":
            self.send_response(302)
            self.send_header("Location", "/final")
            self.end_headers()
            self.wfile.write(b"redirect-body-must-not-be-consumed")
            return
        if self.path == "/archive":
            self.send_response(302)
            self.send_header("Location", f"http://127.0.0.1:{self.server.server_port}/payload")
            self.end_headers()
            return
        if self.path == "/multi":
            self.send_response(302)
            self.send_header("Location", f"http://127.0.0.1:{self.server.server_port}/middle")
            self.end_headers()
            return
        if self.path == "/middle":
            self.send_response(302)
            self.send_header("Location", f"http://127.0.0.1:{self.server.server_port}/payload")
            self.end_headers()
            return
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"final")

    def log_message(self, format: str, *args: object) -> None:
        return


class RedirectPolicyTests(unittest.TestCase):
    def run_server(self) -> tuple[ThreadingHTTPServer, threading.Thread]:
        RedirectHandler.requests = []
        server = ThreadingHTTPServer(("127.0.0.1", 0), RedirectHandler)
        thread = threading.Thread(target=server.serve_forever)
        thread.start()
        return server, thread

    def test_api_download_rejects_redirect_without_following_it(self) -> None:
        # Given: an API endpoint responds with a redirect and a body.
        RedirectHandler.requests = []
        server = ThreadingHTTPServer(("127.0.0.1", 0), RedirectHandler)
        thread = threading.Thread(target=server.serve_forever)
        thread.start()
        try:
            with tempfile.TemporaryDirectory() as temporary_directory:
                destination = Path(temporary_directory) / "response"
                # When: the staging downloader requests the API response.
                with self.assertRaises(StageError) as raised:
                    download(f"http://127.0.0.1:{server.server_port}/api", destination)
                # Then: it rejects before following or writing any body.
                self.assertIn("api_redirect_rejected", str(raised.exception))
                self.assertEqual(RedirectHandler.requests, ["/api"])
                self.assertFalse(destination.exists())
        finally:
            server.shutdown()
            thread.join()
            server.server_close()

    def test_archive_download_accepts_exactly_one_expected_redirect(self) -> None:
        # Given: the archive endpoint redirects once to the exact immutable destination.
        server, thread = self.run_server()
        source = f"http://127.0.0.1:{server.server_port}/archive"
        destination_url = f"http://127.0.0.1:{server.server_port}/payload"
        try:
            with tempfile.TemporaryDirectory() as temporary_directory:
                destination = Path(temporary_directory) / "archive"
                # When: the downloader uses the exact redirect contract.
                final_url = download(source, destination, RedirectContract(source, destination_url))
                # Then: it observes one hop and writes only the final response.
                self.assertEqual(final_url, destination_url)
                self.assertEqual(RedirectHandler.requests, ["/archive", "/payload"])
                self.assertEqual(destination.read_bytes(), b"final")
        finally:
            server.shutdown()
            thread.join()
            server.server_close()

    def test_archive_download_rejects_missing_redirect(self) -> None:
        # Given: the archive source returns a payload directly instead of the required hop.
        server, thread = self.run_server()
        source = f"http://127.0.0.1:{server.server_port}/payload"
        destination_url = f"http://127.0.0.1:{server.server_port}/other"
        try:
            with tempfile.TemporaryDirectory() as temporary_directory:
                destination = Path(temporary_directory) / "archive"
                # When: the downloader requires the exact one-hop redirect contract.
                with self.assertRaises(StageError) as raised:
                    download(source, destination, RedirectContract(source, destination_url))
                # Then: it rejects without accepting or writing the direct response body.
                self.assertIn("archive_redirect_missing", str(raised.exception))
                self.assertEqual(RedirectHandler.requests, ["/payload"])
                self.assertFalse(destination.exists())
        finally:
            server.shutdown()
            thread.join()
            server.server_close()

    def test_archive_download_rejects_second_redirect(self) -> None:
        # Given: the first expected archive destination redirects again.
        server, thread = self.run_server()
        source = f"http://127.0.0.1:{server.server_port}/multi"
        destination_url = f"http://127.0.0.1:{server.server_port}/middle"
        try:
            with tempfile.TemporaryDirectory() as temporary_directory:
                destination = Path(temporary_directory) / "archive"
                # When: the downloader observes the second redirect.
                with self.assertRaises(StageError) as raised:
                    download(source, destination, RedirectContract(source, destination_url))
                # Then: it rejects the chain without requesting the payload.
                self.assertIn("archive_redirect_chain_rejected", str(raised.exception))
                self.assertEqual(RedirectHandler.requests, ["/multi", "/middle"])
                self.assertFalse(destination.exists())
        finally:
            server.shutdown()
            thread.join()
            server.server_close()

    def test_archive_download_rejects_wrong_source_or_destination(self) -> None:
        # Given: the observed archive redirect differs from the exact contract.
        server, thread = self.run_server()
        source = f"http://127.0.0.1:{server.server_port}/archive"
        wrong_destination = f"http://127.0.0.1:{server.server_port}/other"
        try:
            with tempfile.TemporaryDirectory() as temporary_directory:
                destination = Path(temporary_directory) / "archive"
                # When: the downloader compares the observed hop.
                with self.assertRaises(StageError) as raised:
                    download(source, destination, RedirectContract(source + "?changed", wrong_destination))
                # Then: it rejects before following the redirect or writing its body.
                self.assertIn("archive_redirect_rejected", str(raised.exception))
                self.assertEqual(RedirectHandler.requests, ["/archive"])
                self.assertFalse(destination.exists())
        finally:
            server.shutdown()
            thread.join()
            server.server_close()

    def test_archive_download_rejects_scheme_port_and_userinfo_changes(self) -> None:
        # Given: redirect contracts vary scheme, port, or userinfo from the observed location.
        server, thread = self.run_server()
        source = f"http://127.0.0.1:{server.server_port}/archive"
        changed_destinations = (
            f"https://127.0.0.1:{server.server_port}/payload",
            f"http://127.0.0.1:{server.server_port + 1}/payload",
            f"http://user@127.0.0.1:{server.server_port}/payload",
        )
        try:
            for changed_destination in changed_destinations:
                with self.subTest(destination=changed_destination), tempfile.TemporaryDirectory() as temporary_directory:
                    RedirectHandler.requests = []
                    destination = Path(temporary_directory) / "archive"
                    # When: the downloader compares the exact redirect destination.
                    with self.assertRaises(StageError) as raised:
                        download(source, destination, RedirectContract(source, changed_destination))
                    # Then: it rejects without following or creating a file.
                    self.assertIn("archive_redirect_rejected", str(raised.exception))
                    self.assertEqual(RedirectHandler.requests, ["/archive"])
                    self.assertFalse(destination.exists())
        finally:
            server.shutdown()
            thread.join()
            server.server_close()


if __name__ == "__main__":
    unittest.main()
