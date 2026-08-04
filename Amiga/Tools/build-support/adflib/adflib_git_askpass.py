#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# GIT_ASKPASS=./adflib_git_askpass.py git ls-remote https://github.com/owner/repo.git

from __future__ import annotations

import os
import socket
import sys


def main() -> int:
    prompt = sys.argv[1] if len(sys.argv) == 2 else ""
    if "username" in prompt.lower():
        print("x-access-token")
        return 0
    socket_path = os.environ.get("ADFLIB_ASKPASS_SOCKET", "")
    if not socket_path:
        return 2
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as connection:
        connection.connect(socket_path)
        connection.sendall(b"password\n")
        token = connection.recv(16384)
    if not token or b"\x00" in token:
        return 2
    sys.stdout.buffer.write(token)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
