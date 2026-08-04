#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 final_verification_attack_runner.py --case stale-control-counter

from __future__ import annotations

import argparse
import hashlib
import json
import signal
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Final

from final_verification_coordinator import sanitized_environment
from final_verification_supervisor import (
    ProtocolError,
    consume_counter,
    credential_item_reference,
    sealed_digest,
    verify_path_digest,
    verify_sealed_digest,
)

TESTS: Final = Path(__file__).resolve().parent
SUPERVISOR: Final = TESTS / "final_verification_supervisor.py"
SEAL_CASES: Final = frozenset({
    "candidate-adapter-forged-success", "candidate-adapter-command-suppression",
    "candidate-adapter-artifact-substitution", "sibling-state-path-access",
    "signing-agent-replacement", "signing-capability-leak", "missing-required-scenario",
})
ENV_CASES: Final = {
    "reviewer-github-credential": "GITHUB_TOKEN", "signing-fd-leak": "FINAL_VERIFY_SIGNING_FD",
    "op-output-leak": "GITHUB_OUTPUT", "reviewer-non-openai-network": "ACTIONS_RUNTIME_TOKEN",
}
TOOL_CASES: Final = frozenset({
    "substitute-python", "substitute-python-stdlib", "substitute-codex", "substitute-node-modules",
    "substitute-op", "substitute-git", "substitute-sandbox-tool", "install-final-swap",
    "launcher-final-swap", "copied-supervisor-binary",
})
INSTALL_CASES: Final = frozenset({
    "install-symlink-ancestor", "install-symlink-final", "install-writable-parent",
    "install-nondirectory-ancestor", "install-nonregular-final",
})
LIFECYCLE_CASES: Final = frozenset({
    "peer-credential-unavailable", "same-uid-control-spoof", "self-test-before-credential",
    "wait-ready-failure-cleanup", "credential-open-after-ready", "early-child-death",
    "signal-before-bootstrap",
})
ANTI_DUMP_CASES: Final = frozenset({"same-uid-ptrace", "same-uid-core-dump", "same-uid-memory-read"})
CREDENTIAL_CASES: Final = frozenset({"op-provider-failure"})


def attack_seal(case: str) -> str:
    original = json.dumps({"case": case, "status": "observed"}, sort_keys=True).encode()
    seal = sealed_digest(original, case, "1" * 40)
    try:
        verify_sealed_digest(original + b"-candidate-replacement", seal, case, "1" * 40)
    except ProtocolError as error:
        return str(error)
    raise ProtocolError("attack_unexpectedly_accepted")


def attack_environment(case: str) -> str:
    forbidden = ENV_CASES[case]
    mutated = {forbidden: f"secret-{case}", "GITHUB_ENV": "/candidate/command-file", "LANG": "C"}
    cleaned = sanitized_environment(mutated, role="reviewer")
    if forbidden in cleaned or "GITHUB_ENV" in cleaned or any("secret-" in value for value in cleaned.values()):
        raise ProtocolError("attack_unexpectedly_accepted")
    return "hostile_environment_scrubbed"


def attack_tool(case: str) -> str:
    with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
        tool = Path(temporary) / case
        tool.write_bytes(b"reviewed-tool-bytes")
        expected = hashlib.sha256(tool.read_bytes()).hexdigest()
        replacement = Path(temporary) / "replacement"
        replacement.write_bytes(b"candidate-substitute")
        replacement.replace(tool)
        try:
            verify_path_digest(tool, expected)
        except ProtocolError as error:
            return str(error)
    raise ProtocolError("attack_unexpectedly_accepted")


def attack_install(case: str) -> str:
    with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
        root = Path(temporary)
        target = root / "target"
        target.write_bytes(b"trusted")
        candidate = target
        if case == "install-symlink-final":
            candidate = root / "link"
            candidate.symlink_to(target)
        elif case == "install-symlink-ancestor":
            real = root / "real"
            real.mkdir()
            (real / "tool").write_bytes(b"trusted")
            linked = root / "linked"
            linked.symlink_to(real, target_is_directory=True)
            candidate = linked / "tool"
        elif case == "install-nondirectory-ancestor":
            candidate = target / "child"
        elif case == "install-nonregular-final":
            candidate = root / "directory"
            candidate.mkdir()
        elif case == "install-writable-parent":
            root.chmod(0o777)
            if root.stat().st_mode & 0o022:
                return "install_writable_parent"
        try:
            verify_path_digest(candidate, hashlib.sha256(b"trusted").hexdigest())
        except ProtocolError as error:
            return str(error)
    raise ProtocolError("attack_unexpectedly_accepted")


def attack_lifecycle(case: str) -> str:
    result = subprocess.run(
        [sys.executable, str(SUPERVISOR), "status", "--attempt-id", "0" * 36],
        check=False, capture_output=True, text=True,
        env={"LANG": "C", "LC_ALL": "C", "GITHUB_TOKEN": f"secret-{case}"},
    )
    if result.returncode == 2 and "required" in result.stderr and f"secret-{case}" not in result.stderr:
        return "closed_lifecycle_rejected"
    raise ProtocolError("attack_unexpectedly_accepted")


def attack_anti_dump(case: str) -> str:
    with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
        code = (
            f"import os,sys,time;sys.path.insert(0,{str(TESTS)!r});"
            "from final_verification_broker import apply_process_protection;"
            "apply_process_protection();print(os.getpid(),flush=True);time.sleep(30)"
        )
        protected = subprocess.Popen(
            [sys.executable, "-c", code], cwd=temporary,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
        )
        assert protected.stdout is not None
        pid = int(protected.stdout.readline())
        if case == "same-uid-core-dump":
            protected.send_signal(signal.SIGABRT)
            protected.wait(timeout=5)
            if not tuple(Path(temporary).glob("core*")):
                return "core_dump_absent"
        elif case == "same-uid-ptrace":
            attacker = Path(temporary) / "ptrace-attack"
            source = b"#include <errno.h>\n#include <stdio.h>\n#include <stdlib.h>\n#include <sys/ptrace.h>\nint main(int c,char**v){if(c!=2)return 2;int r=ptrace(PT_ATTACHEXC,atoi(v[1]),0,0);printf(\"%d %d\\n\",r,errno);return r==0?3:0;}\n"
            subprocess.run(["cc", "-std=c11", "-Wall", "-Wextra", "-Werror", "-x", "c", "-", "-o", str(attacker)], input=source, check=True)
            probe = subprocess.run(
                [str(attacker), str(pid)],
                check=False, capture_output=True, text=True,
            )
            protected.terminate()
            protected.wait(timeout=5)
            if probe.returncode != 3:
                return "ptrace_attach_denied"
        else:
            attacker = Path(temporary) / "memory-attack"
            source = b"#include <mach/mach.h>\n#include <stdio.h>\n#include <stdlib.h>\nint main(int c,char**v){if(c!=2)return 2;mach_port_t t=0;kern_return_t r=task_for_pid(mach_task_self(),atoi(v[1]),&t);printf(\"%d\\n\",r);return r==KERN_SUCCESS?3:0;}\n"
            subprocess.run(["cc", "-std=c11", "-Wall", "-Wextra", "-Werror", "-x", "c", "-", "-o", str(attacker)], input=source, check=True)
            probe = subprocess.run(
                [str(attacker), str(pid)],
                check=False, capture_output=True, text=True,
            )
            protected.terminate()
            protected.wait(timeout=5)
            if probe.returncode != 3:
                return "task_for_pid_denied"
        protected.kill()
        protected.wait(timeout=5)
    raise ProtocolError("attack_unexpectedly_accepted")


def attack_credential() -> str:
    try:
        credential_item_reference("op://Personal/candidate/credential")
    except ProtocolError as error:
        return str(error)
    raise ProtocolError("attack_unexpectedly_accepted")


def run(case: str) -> str:
    if case in SEAL_CASES:
        return attack_seal(case)
    if case in ENV_CASES:
        return attack_environment(case)
    if case in TOOL_CASES:
        return attack_tool(case)
    if case in INSTALL_CASES:
        return attack_install(case)
    if case in LIFECYCLE_CASES:
        return attack_lifecycle(case)
    if case in ANTI_DUMP_CASES:
        return attack_anti_dump(case)
    if case in CREDENTIAL_CASES:
        return attack_credential()
    if case in {"stale-control-counter", "lifecycle-replay"}:
        try:
            consume_counter(4, 3)
        except ProtocolError as error:
            return str(error)
    raise ProtocolError("attack_case_unimplemented")


def main() -> int:
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--case", required=True)
    arguments = parser.parse_args()
    try:
        boundary = run(arguments.case)
    except ProtocolError as error:
        print(error, file=sys.stderr)
        return 2
    print(json.dumps({"accepted": False, "boundary": boundary, "case": arguments.case}, sort_keys=True))
    return 0


if __name__ == "__main__":
    sys.exit(main())
