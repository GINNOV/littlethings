#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["cryptography>=45"]
# ///
# ─── How to run ───
# python3 test_final_verification_broker.py

from __future__ import annotations

import hashlib
import json
import os
import socket
import subprocess
import sys
import tempfile
import unittest
import uuid
from pathlib import Path

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

TESTS = Path(__file__).resolve().parent
BROKER = TESTS / "final_verification_broker.py"


class BrokerTests(unittest.TestCase):
    def test_supervisor_cli_runs_complete_authenticated_local_lifecycle(self) -> None:
        # Given: a real two-parent merge, private attempt root, and anonymous mock-provider pipe.
        sodium = Path("/opt/homebrew/Cellar/libsodium/1.0.22/lib/libsodium.26.dylib")
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            root = Path(temporary)
            repository = root / "repo"
            evidence = root / "evidence"
            repository.mkdir()
            evidence.mkdir(mode=0o700)
            for command in (
                ("init", "-q"), ("config", "user.name", "fixture"),
                ("config", "user.email", "fixture@example.invalid"),
            ):
                subprocess.run(["/usr/bin/git", "-C", str(repository), *command], check=True)
            tracked = repository / "tracked"
            tracked.write_text("base\n", encoding="utf-8")
            subprocess.run(["/usr/bin/git", "-C", str(repository), "add", "tracked"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "commit", "-qm", "base"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "branch", "-M", "master"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "checkout", "-qb", "reviewed"], check=True)
            tracked.write_text("reviewed\n", encoding="utf-8")
            subprocess.run(["/usr/bin/git", "-C", str(repository), "commit", "-qam", "reviewed"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "checkout", "-q", "master"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "merge", "--no-ff", "-qm", "merge", "reviewed"], check=True)
            final_sha = subprocess.run(["/usr/bin/git", "-C", str(repository), "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
            attempt = str(uuid.uuid4())
            read_fd, write_fd = os.pipe()
            os.write(write_fd, b"mock-token-never-logged\n403\n")
            os.close(write_fd)
            provider = os.dup(read_fd)
            os.dup2(provider, 3)
            supervisor = TESTS / "final_verification_supervisor.py"
            source_sha = hashlib.sha256(supervisor.read_bytes()).hexdigest()
            base = [sys.executable, str(supervisor)]
            # When: start, readiness, replay, credential load, status, revocation, finalize, and cleanup run via the CLI.
            started = subprocess.run(
                [*base, "start", "--adapter", str(TESTS / "final_verification_coordinator.py"),
                 "--repo-root", str(repository), "--evidence-dir", str(evidence), "--state", str(evidence / "state.json"),
                 "--attempt-id", attempt, "--final-sha", final_sha, "--orchestrator-pid", str(os.getpid()),
                 "--bootstrap-receipt", str(evidence / "bootstrap.json"), "--local-test-sodium", str(sodium),
                 "--local-test-sodium-sha256", hashlib.sha256(sodium.read_bytes()).hexdigest()],
                check=False, capture_output=True, text=True, pass_fds=(3,),
            )
            os.close(3)
            os.close(provider)
            if read_fd != 3:
                os.close(read_fd)
            self.assertEqual(started.returncode, 0, started.stderr)
            bootstrap = json.loads(started.stdout)
            common = ["--repo-root", str(repository), "--evidence-dir", str(evidence), "--state", str(evidence / "state.json"),
                      "--attempt-id", attempt, "--launcher-pid", str(bootstrap["launcher_pid"]),
                      "--supervisor-pid", str(bootstrap["supervisor_pid"]), "--orchestrator-pid", str(os.getpid()),
                      "--expected-supervisor-sha256", source_sha]
            ready = subprocess.run([*base, "wait-ready", *common, "--counter", "1"], check=False, capture_output=True, text=True)
            replay = subprocess.run([*base, "status", *common, "--counter", "1"], check=False, capture_output=True, text=True)
            loaded = subprocess.run([*base, "credential-open", *common, "--counter", "2", "--provider", "mock",
                                     "--item-reference", "op://GI Business/local/credential"], check=False, capture_output=True, text=True)
            status_result = subprocess.run([*base, "status", *common, "--counter", "3"], check=False, capture_output=True, text=True)
            revoked = subprocess.run([*base, "status", *common, "--counter", "4", "--mock-revoke"], check=False, capture_output=True, text=True)
            finalized = subprocess.run([*base, "finalize", *common, "--counter", "5"], check=False, capture_output=True, text=True)
            cleaned = subprocess.run([*base, "cleanup", "--repo-root", str(repository), "--evidence-dir", str(evidence),
                                      "--state", str(evidence / "state.json"), "--attempt-id", attempt,
                                      "--expected-supervisor-sha256", source_sha], check=False, capture_output=True, text=True)
            # Then: counters/signatures and state transitions hold, replay fails, lanes/probes exist, and no token is emitted.
            self.assertEqual(ready.returncode, 0, ready.stderr)
            self.assertEqual(replay.returncode, 2)
            self.assertEqual(loaded.returncode, 0, loaded.stderr)
            self.assertEqual(status_result.returncode, 0, status_result.stderr)
            self.assertEqual(revoked.returncode, 0, revoked.stderr)
            self.assertEqual(finalized.returncode, 0, finalized.stderr)
            self.assertEqual(cleaned.returncode, 0, cleaned.stderr)
            outputs = "".join(result.stdout + result.stderr for result in (started, ready, replay, loaded, status_result, revoked, finalized, cleaned))
            self.assertNotIn("mock-token-never-logged", outputs)
            self.assertTrue((evidence / "final-receipt.json").is_file())
            self.assertTrue((evidence / "compliance.json").is_file())
            self.assertTrue((evidence / "probes" / "offline-rebuild" / "probe-offline-rebuild.json").is_file())
            abort_evidence = root / "abort-evidence"
            abort_evidence.mkdir(mode=0o700)
            abort_attempt = str(uuid.uuid4())
            abort_read, abort_write = os.pipe()
            os.write(abort_write, b"unused-token-never-logged\n403\n")
            os.close(abort_write)
            abort_provider = os.dup(abort_read)
            os.dup2(abort_provider, 3)
            abort_started = subprocess.run(
                [*base, "start", "--adapter", str(TESTS / "final_verification_coordinator.py"),
                 "--repo-root", str(repository), "--evidence-dir", str(abort_evidence),
                 "--state", str(abort_evidence / "state.json"), "--attempt-id", abort_attempt,
                 "--final-sha", final_sha, "--orchestrator-pid", str(os.getpid()),
                 "--bootstrap-receipt", str(abort_evidence / "bootstrap.json"),
                 "--local-test-sodium", str(sodium),
                 "--local-test-sodium-sha256", hashlib.sha256(sodium.read_bytes()).hexdigest()],
                check=False, capture_output=True, text=True, pass_fds=(3,),
            )
            os.close(3)
            os.close(abort_provider)
            if abort_read != 3:
                os.close(abort_read)
            self.assertEqual(abort_started.returncode, 0, abort_started.stderr)
            abort_bootstrap = json.loads(abort_started.stdout)
            abort_common = ["--repo-root", str(repository), "--evidence-dir", str(abort_evidence),
                            "--state", str(abort_evidence / "state.json"), "--attempt-id", abort_attempt,
                            "--launcher-pid", str(abort_bootstrap["launcher_pid"]),
                            "--supervisor-pid", str(abort_bootstrap["supervisor_pid"]),
                            "--orchestrator-pid", str(os.getpid()), "--expected-supervisor-sha256", source_sha]
            abort_ready = subprocess.run([*base, "wait-ready", *abort_common, "--counter", "1"],
                                         check=False, capture_output=True, text=True)
            aborted = subprocess.run([*base, "abort", *abort_common, "--counter", "2"],
                                     check=False, capture_output=True, text=True)
            abort_cleaned = subprocess.run(
                [*base, "cleanup", "--repo-root", str(repository), "--evidence-dir", str(abort_evidence),
                 "--state", str(abort_evidence / "state.json"), "--attempt-id", abort_attempt,
                 "--expected-supervisor-sha256", source_sha], check=False, capture_output=True, text=True,
            )
            self.assertEqual(abort_ready.returncode, 0, abort_ready.stderr)
            self.assertEqual(aborted.returncode, 0, aborted.stderr)
            self.assertEqual(abort_cleaned.returncode, 0, abort_cleaned.stderr)
            self.assertTrue(json.loads(aborted.stdout)["credential_zeroized"])
            self.assertNotIn("unused-token-never-logged", abort_started.stdout + abort_started.stderr + aborted.stdout + aborted.stderr)
            production_evidence = root / "production-evidence"
            production_evidence.mkdir(mode=0o700)
            production_attempt = str(uuid.uuid4())
            production = subprocess.run(
                [*base, "start", "--adapter", str(TESTS / "final_verification_coordinator.py"),
                 "--repo-root", str(repository), "--evidence-dir", str(production_evidence),
                 "--state", str(production_evidence / "state.json"), "--attempt-id", production_attempt,
                 "--final-sha", final_sha, "--orchestrator-pid", str(os.getpid()),
                 "--bootstrap-receipt", str(production_evidence / "bootstrap.json")],
                check=False, capture_output=True, text=True,
            )
            self.assertEqual(production.returncode, 2)
            self.assertIn("stage11b_native_broker_required", production.stderr)
            self.assertFalse((production_evidence / "state.json").exists())
            self.assertFalse((production_evidence / "bootstrap.json").exists())

    def test_reviewer_sandbox_denies_supervisor_private_input(self) -> None:
        # Given: a private supervisor input and an enforceable macOS reviewer profile.
        if sys.platform != "darwin":
            self.skipTest("macOS sandbox scenario")
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            secret = Path(temporary) / "supervisor-secret"
            secret.write_text("must-not-read\n", encoding="utf-8")
            profile = f'(version 1) (deny default) (allow process*) (allow file-read* (literal "{sys.executable}"))'
            # When: an isolated reviewer process attempts to read the supervisor-only file.
            result = subprocess.run(
                ["/usr/bin/sandbox-exec", "-p", profile, sys.executable, "-c", f'open("{secret}").read()'],
                check=False, capture_output=True, text=True,
                env={"LANG": "C", "LC_ALL": "C"},
            )
            # Then: kernel sandbox enforcement rejects the read and no secret reaches stdout.
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn("must-not-read", result.stdout)

    def test_resident_broker_authenticates_lifecycle_and_zeroizes_mock_credential(self) -> None:
        # Given: an anonymous mock-provider pipe, private anchor, and exact libsodium identity.
        sodium = Path("/opt/homebrew/Cellar/libsodium/1.0.22/lib/libsodium.26.dylib")
        self.assertTrue(sodium.is_file())
        read_fd, write_fd = os.pipe()
        secret = "github_pat_never_exposed"
        os.write(write_fd, secret.encode() + b"\n403\n")
        os.close(write_fd)
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            anchor = Path(temporary)
            anchor.chmod(0o700)
            control = anchor / "control.sock"
            attempt = str(uuid.uuid4())
            provider = os.dup(read_fd)
            os.dup2(provider, 3)
            process = subprocess.Popen(
                [sys.executable, str(BROKER), "--socket", str(control), "--attempt-id", attempt,
                 "--orchestrator-pid", str(os.getppid()), "--sodium", str(sodium),
                 "--sodium-sha256", hashlib.sha256(sodium.read_bytes()).hexdigest()],
                pass_fds=(3,), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                env={"LANG": "C", "LC_ALL": "C"},
            )
            os.close(3)
            os.close(provider)
            assert process.stdout is not None
            ready = json.loads(process.stdout.readline())
            public_key = Ed25519PublicKey.from_public_bytes(bytes.fromhex(ready["public_key"]))
            process_surface = subprocess.run(
                ["/bin/ps", "eww", "-p", str(process.pid), "-o", "command="],
                check=False, capture_output=True, text=True,
            ).stdout
            self.assertNotIn(secret, process_surface)
            self.assertNotIn("CODEX_HOME", process_surface)
            attacker_code = (
                "import json,socket,sys;"
                "s=socket.socket(socket.AF_UNIX);s.connect(sys.argv[1]);"
                "s.sendall((json.dumps({'attempt_id':sys.argv[2],'counter':1,'operation':'status'})+'\\n').encode());"
                "print(s.makefile('r').readline(),end='')"
            )
            attacker = subprocess.run(
                [sys.executable, "-c", attacker_code, str(control), attempt],
                check=False, capture_output=True, text=True,
            )
            attacker_response = json.loads(attacker.stdout)
            self.assertEqual(attacker_response["error"], "control_peer_parent_mismatch")

            def request(operation: str, counter: int) -> dict[str, str | int | bool]:
                client = socket.socket(socket.AF_UNIX)
                client.connect(str(control))
                client.sendall((json.dumps({"attempt_id": attempt, "counter": counter, "operation": operation}) + "\n").encode())
                response = json.loads(client.makefile("r", encoding="utf-8").readline())
                client.close()
                return response

            # When: the authenticated orchestrator advances, replays, loads, revokes, and finalizes.
            first = request("wait-ready", 1)
            replay = request("status", 1)
            loaded = request("credential-open", 2)
            revoked = request("revoke", 3)
            finalized = request("finalize", 4)
            process.wait(timeout=5)
            assert process.stderr is not None
            broker_stderr = process.stderr.read()
            process.stdout.close()
            process.stderr.close()
            # Then: signatures/counters bind responses, replay fails, and no response/process surface contains the token.
            for response in (first, loaded, revoked, finalized):
                signature = bytes.fromhex(str(response.pop("signature")))
                public_key.verify(signature, json.dumps(response, sort_keys=True, separators=(",", ":")).encode())
            self.assertEqual(replay["error"], "control_counter_mismatch")
            self.assertTrue(revoked["dispatch_token_revoked"])
            self.assertTrue(finalized["credential_zeroized"])
            self.assertNotIn(secret, json.dumps((ready, first, replay, loaded, revoked, finalized)))
            self.assertEqual(process.returncode, 0)
            self.assertEqual(broker_stderr, "")
            self.assertFalse(control.exists())


if __name__ == "__main__":
    unittest.main()
