#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--broker", type=Path, required=True)
    parser.add_argument("--socket", type=Path, required=True)
    parser.add_argument("--attempt-id", required=True)
    parser.add_argument("--orchestrator-pid", type=int, required=True)
    parser.add_argument("--sodium", type=Path, required=True)
    parser.add_argument("--sodium-sha256", required=True)
    arguments = parser.parse_args()
    broker = subprocess.Popen(
        [sys.executable, str(arguments.broker), "--socket", str(arguments.socket),
         "--attempt-id", arguments.attempt_id, "--orchestrator-pid", str(arguments.orchestrator_pid),
         "--sodium", str(arguments.sodium), "--sodium-sha256", arguments.sodium_sha256],
        pass_fds=(3,), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
        env={"LANG": "C", "LC_ALL": "C"},
    )
    assert broker.stdout is not None
    ready_line = broker.stdout.readline()
    if not ready_line:
        assert broker.stderr is not None
        error = broker.stderr.read()
        broker.wait()
        print(error or "broker_readiness_missing", file=sys.stderr, end="")
        return 2
    ready = json.loads(ready_line)
    print(json.dumps({**ready, "launcher_pid": __import__("os").getpid(), "supervisor_pid": broker.pid}, sort_keys=True), flush=True)
    broker.stdout.close()
    assert broker.stderr is not None
    error = broker.stderr.read()
    result = broker.wait()
    if error:
        print(error, file=sys.stderr, end="")
    return result


if __name__ == "__main__":
    sys.exit(main())
