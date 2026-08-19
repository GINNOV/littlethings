#!/usr/bin/env python3

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, clean_environment, exclusive_json, executable_hash, fsync_parent, output_under, process_identity, sha256_bytes, sha256_file, sha256_tree

ALLOWLIST = ("DEVELOPER_DIR", "HOME", "LANG", "PATH", "SDKROOT", "TMPDIR", "USER")


def main() -> int:
    parser = argparse.ArgumentParser(description="Own a build process and write an observed immutable receipt.")
    parser.add_argument("--root", required=True, type=Path)
    parser.add_argument("--receipt", required=True, type=Path)
    parser.add_argument("--stdout", required=True, type=Path)
    parser.add_argument("--stderr", required=True, type=Path)
    parser.add_argument("--app", type=Path)
    parser.add_argument("--adhoc-sign-entitlements", type=Path)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command:
        parser.error("a command after -- is required")
    try:
        root = args.root.resolve(strict=True)
        receipt = output_under(root, args.receipt)
        stdout_path = output_under(root, args.stdout)
        stderr_path = output_under(root, args.stderr)
        environment = clean_environment(os.environ, ALLOWLIST)
        home = root / "home"
        temporary = root / "tmp"
        os.mkdir(home, 0o700)
        os.mkdir(temporary, 0o700)
        environment["HOME"] = str(home)
        environment["TMPDIR"] = str(temporary)
        executable, executable_sha = executable_hash(command[0], environment)
        start = time.monotonic_ns()
        with stdout_path.open("xb") as stdout, stderr_path.open("xb") as stderr:
            child = subprocess.Popen(command, env=environment, stdout=stdout, stderr=stderr, start_new_session=True)
            child_identity = process_identity(child.pid)
            status = child.wait()
            stdout.flush()
            stderr.flush()
            os.fsync(stdout.fileno())
            os.fsync(stderr.fileno())
        fsync_parent(stdout_path)
        fsync_parent(stderr_path)
        app_record: JsonValue = None
        if args.adhoc_sign_entitlements is not None and args.app is None:
            raise EvidenceError("missing-app", "--adhoc-sign-entitlements requires --app")
        if args.app is not None:
            app = args.app.resolve(strict=True)
            if args.adhoc_sign_entitlements is not None:
                entitlements = args.adhoc_sign_entitlements.resolve(strict=True)
                sign = subprocess.run(["codesign", "--force", "--deep", "--sign", "-", "--entitlements", str(entitlements), str(app)], env=environment, check=False)
                if sign.returncode != 0:
                    raise EvidenceError("sign-failed", str(sign.returncode))
                verify = subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)], env=environment, check=False)
                if verify.returncode != 0:
                    raise EvidenceError("signature-invalid", str(verify.returncode))
            app_record = {"path": str(app), "sha256": sha256_file(app) if app.is_file() else sha256_tree(app), "entitlements": None if args.adhoc_sign_entitlements is None else {"path": str(entitlements), "sha256": sha256_file(entitlements)}}
        env_pairs = [f"{key}={environment[key]}" for key in sorted(environment)]
        value: JsonValue = {"schemaVersion": 1, "kind": "build", "argv": command, "environmentAllowlist": list(ALLOWLIST), "environment": {key: environment[key] for key in sorted(environment)}, "environmentSHA256": sha256_bytes("\0".join(env_pairs).encode()), "executable": str(executable), "executableSHA256": executable_sha, "supervisor": process_identity(os.getpid()), "child": child_identity, "startMonotonicNs": start, "endMonotonicNs": time.monotonic_ns(), "exitStatus": status, "stdout": {"path": str(stdout_path), "sha256": sha256_file(stdout_path)}, "stderr": {"path": str(stderr_path), "sha256": sha256_file(stderr_path)}, "app": app_record}
        exclusive_json(receipt, value)
        return status
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "io-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
