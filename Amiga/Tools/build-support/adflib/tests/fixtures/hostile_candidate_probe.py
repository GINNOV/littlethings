#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# Executed only through consumer_sandbox.py

from __future__ import annotations

import json
import os
import socket
import subprocess
import sys
from pathlib import Path


def mutation_denied(root: Path) -> bool:
    try:
        os.chmod(root, 0o777)
        os.chmod(root / "sentinel", 0o666)
        with (root / "sentinel").open("a", encoding="utf-8") as stream:
            stream.write("mutated\n")
    except OSError:
        return True
    return False


def network_denied() -> bool:
    try:
        with socket.create_connection(("1.1.1.1", 53), timeout=1):
            return False
    except OSError:
        return True


def inherited_descriptors() -> list[int]:
    visible: list[int] = []
    for descriptor in range(3, 256):
        try:
            os.fstat(descriptor)
        except OSError:
            continue
        visible.append(descriptor)
    return visible


def main() -> int:
    trusted, source, cache, build = (Path(value) for value in sys.argv[1:5])
    forbidden_environment = [
        name
        for name in os.environ
        if name.startswith(("GITHUB_", "ACTIONS_", "RUNNER_"))
        or name in {"GIT_ASKPASS", "SSH_ASKPASS", "GH_TOKEN"}
    ]
    credential_helpers = subprocess.run(
        ["git", "config", "--global", "--get-all", "credential.helper"],
        check=False,
        capture_output=True,
        text=True,
    ).stdout.strip()
    checks = {
        "argv": all("secret" not in value for value in sys.argv),
        "artifact_cache_api": not any("URL" in name or "TOKEN" in name for name in forbidden_environment),
        "cache_mutation": mutation_denied(cache),
        "command_files": not any(name in os.environ for name in ("GITHUB_ENV", "GITHUB_OUTPUT", "GITHUB_PATH", "GITHUB_STEP_SUMMARY")),
        "credential_helpers": not credential_helpers,
        "environment": not forbidden_environment,
        "file_descriptors": not inherited_descriptors(),
        "network": network_denied(),
        "source_mutation": mutation_denied(source),
        "trusted_mutation": mutation_denied(trusted),
    }
    build.mkdir(parents=True, exist_ok=True)
    receipt = {
        "candidate_uid": os.getuid(),
        "checks": checks,
        "isolation_mode": os.environ.get("CONSUMER_ISOLATION_MODE", "missing"),
        "status": "all_denied" if all(checks.values()) else "probe_failed",
    }
    (build / "hostile-probe.json").write_text(json.dumps(receipt, sort_keys=True) + "\n", encoding="utf-8")
    return 0 if receipt["status"] == "all_denied" else 2


if __name__ == "__main__":
    sys.exit(main())
