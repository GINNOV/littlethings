#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 run_network_denied.py -- command arg ...

from __future__ import annotations

import argparse
import platform
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


def isolated_prefix() -> tuple[list[str], tempfile.TemporaryDirectory[str] | None]:
    system = platform.system()
    if system == "Darwin":
        sandbox = Path("/usr/bin/sandbox-exec")
        if not sandbox.is_file():
            raise RuntimeError("network_isolation_unavailable: sandbox-exec missing")
        temporary = tempfile.TemporaryDirectory(prefix="network-denied-")
        profile = Path(temporary.name) / "deny-network.sb"
        profile.write_text(
            "(version 1)\n(allow default)\n(deny network*)\n",
            encoding="utf-8",
        )
        return [str(sandbox), "-f", str(profile)], temporary
    if system == "Linux":
        unshare = shutil.which("unshare")
        if unshare is None:
            raise RuntimeError("network_isolation_unavailable: unshare missing")
        return [unshare, "-Urn"], None
    raise RuntimeError(f"network_isolation_unavailable: unsupported host {system}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", nargs=argparse.REMAINDER)
    arguments = parser.parse_args()
    command = arguments.command
    if command and command[0] == "--":
        command = command[1:]
    if not command:
        parser.error("command required after --")
    temporary: tempfile.TemporaryDirectory[str] | None = None
    try:
        prefix, temporary = isolated_prefix()
        probe = subprocess.run(
            [
                *prefix,
                sys.executable,
                "-c",
                "import socket; socket.create_connection(('1.1.1.1', 53), timeout=1)",
            ],
            check=False,
            capture_output=True,
            text=True,
        )
        if probe.returncode == 0:
            print("network_isolation_probe_failed: socket was not blocked", file=sys.stderr)
            return 2
        result = subprocess.run([*prefix, *command], check=False)
        return result.returncode
    except RuntimeError as error:
        print(error, file=sys.stderr)
        return 2
    finally:
        if temporary is not None:
            temporary.cleanup()


if __name__ == "__main__":
    raise SystemExit(main())
