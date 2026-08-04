#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# printf token | python3 adflib_credential_broker.py /tmp/adflib-token.sock

from __future__ import annotations

import argparse
import os
import signal
import socket
import sys
from pathlib import Path


def serve(socket_path: Path) -> int:
    token = bytearray(sys.stdin.buffer.read(16384))
    if not token or len(token) >= 16384 or b"\x00" in token:
        return 2
    stopping = False

    def stop(_signum: int, _frame) -> None:
        nonlocal stopping
        stopping = True

    signal.signal(signal.SIGTERM, stop)
    listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    listener.bind(str(socket_path)); os.chmod(socket_path, 0o600); listener.listen(4); listener.settimeout(0.2)
    try:
        while not stopping:
            try:
                connection, _ = listener.accept()
            except TimeoutError:
                continue
            with connection:
                if connection.recv(32) == b"password\n":
                    connection.sendall(token)
    finally:
        listener.close()
        for index in range(len(token)):
            token[index] = 0
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("socket", type=Path)
    arguments = parser.parse_args()
    return serve(arguments.socket)


if __name__ == "__main__":
    raise SystemExit(main())
