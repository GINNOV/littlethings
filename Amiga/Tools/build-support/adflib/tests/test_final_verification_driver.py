#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 test_final_verification_driver.py --case lifecycle-replay

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest
import uuid
from pathlib import Path

TESTS = Path(__file__).resolve().parent
sys.path.insert(0, str(TESTS))

from final_verification_catalog import PROBE_LANE as CANONICAL_PROBE_LANE
from final_verification_coordinator import (
    LANES,
    build_lane_argv,
    sanitized_environment,
)
from final_verification_supervisor import (
    ProtocolError,
    credential_item_reference,
    reviewer_argv,
    sealed_digest,
    verify_sealed_digest,
)

FAILURE_CASES = frozenset(
    {
        "peer-credential-unavailable",
        "reviewer-non-openai-network",
        "reviewer-github-credential",
        "signing-fd-leak",
        "missing-required-scenario",
        "candidate-adapter-forged-success",
        "candidate-adapter-command-suppression",
        "candidate-adapter-artifact-substitution",
        "sibling-state-path-access",
        "stale-control-counter",
        "copied-supervisor-binary",
        "install-symlink-ancestor",
        "install-symlink-final",
        "install-writable-parent",
        "install-nondirectory-ancestor",
        "install-nonregular-final",
        "install-final-swap",
        "launcher-final-swap",
        "same-uid-ptrace",
        "same-uid-core-dump",
        "same-uid-memory-read",
        "substitute-python",
        "substitute-python-stdlib",
        "substitute-codex",
        "substitute-node-modules",
        "substitute-op",
        "op-provider-failure",
        "op-output-leak",
        "signing-capability-leak",
        "substitute-git",
        "substitute-sandbox-tool",
        "self-test-before-credential",
        "wait-ready-failure-cleanup",
        "credential-open-after-ready",
        "signal-before-bootstrap",
        "early-child-death",
    }
)


class FinalVerificationTests(unittest.TestCase):
    def test_darwin_rebind_detects_concurrent_replace_chmod_and_link(self) -> None:
        # Given: a verified Python copy and deterministic post-hash/pre-rebind barrier in the real launcher.
        if sys.platform != "darwin":
            self.skipTest("Darwin rebind scenario")
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            root = Path(temporary)
            python_copy = root / "python"
            supervisor = root / "supervisor.py"
            supervisor.write_bytes((TESTS / "final_verification_supervisor.py").read_bytes())
            supervisor.chmod(0o555)
            pinned_python = Path(sys.executable).resolve(strict=True)
            expected_python = hashlib.sha256(pinned_python.read_bytes()).hexdigest()
            supervisor_digest = hashlib.sha256(supervisor.read_bytes()).hexdigest()
            for mutation in ("replace", "chmod", "link"):
                with self.subTest(mutation=mutation):
                    python_copy.unlink(missing_ok=True)
                    shutil.copyfile(pinned_python, python_copy)
                    python_copy.chmod(0o555)
                    ready_read, ready_write = os.pipe()
                    release_read, release_write = os.pipe()
                    launcher = root / f"launcher-{mutation}"
                    q_python = f'-DFINAL_VERIFY_PYTHON="{python_copy}"'
                    q_digest = f'-DFINAL_VERIFY_PYTHON_SHA256="{expected_python}"'
                    subprocess.run(
                        ["cc", "-std=c11", "-Wall", "-Wextra", "-Werror", "-DFINAL_VERIFY_TEST_BUILD",
                         f"-DFINAL_VERIFY_TEST_REBIND_READY_FD={ready_write}",
                         f"-DFINAL_VERIFY_TEST_REBIND_RELEASE_FD={release_read}", q_python, q_digest,
                         str(TESTS / "final_verification_launcher.c"), "-framework", "Security", "-framework",
                         "CoreFoundation", "-o", str(launcher)], check=True,
                    )
                    process = subprocess.Popen(
                        [str(launcher), "--supervisor", str(supervisor), "--expected-sha256", supervisor_digest,
                         "--", "self-test", "--mode", "isolated-test", "--expected-protocol",
                         "send2adf-final-verification/v1", "--expected-sha256", supervisor_digest],
                        pass_fds=(ready_write, release_read), stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
                    )
                    os.close(ready_write)
                    os.close(release_read)
                    self.assertEqual(os.read(ready_read, 1), b"R")
                    # When: a sibling changes path identity or mode after the first verified hash.
                    if mutation == "chmod":
                        python_copy.chmod(0o755)
                    else:
                        replacement = root / f"replacement-{mutation}"
                        shutil.copyfile(Path("/bin/echo"), replacement)
                        replacement.chmod(0o555)
                        if mutation == "link":
                            python_copy.unlink()
                            python_copy.symlink_to(replacement)
                        else:
                            replacement.replace(python_copy)
                    os.write(release_write, b"C")
                    os.close(release_write)
                    os.close(ready_read)
                    _, stderr = process.communicate(timeout=5)
                    # Then: descriptor-relative rebind rejects before the substituted executable runs.
                    self.assertEqual(process.returncode, 2, stderr)
                    self.assertIn("python_rebind_failed", stderr)
    def test_coordinator_and_driver_share_exact_probe_catalog(self) -> None:
        # Given: the single protocol-owned probe catalog.
        from run_final_verification import PROBE_LANE as driver_probe_lane

        # When: the coordinator catalogs the offline rebuild invocation.
        attempt = str(uuid.uuid4())
        argv = build_lane_argv(Path("/repo"), Path("/evidence"), Path("/state"), attempt,
                               CANONICAL_PROBE_LANE["offline-rebuild"], "offline-rebuild")
        # Then: both consumers use manual-qa and the passing probe remains explicit.
        self.assertIs(driver_probe_lane, CANONICAL_PROBE_LANE)
        self.assertEqual(argv[argv.index("--lane") + 1], "manual-qa")
        self.assertEqual(argv[-2:], ("--probe", "offline-rebuild"))
    def test_native_launcher_executes_only_verified_open_bytes(self) -> None:
        # Given: a strict test build of the native launcher and an immutable supervisor fixture.
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            root = Path(temporary)
            launcher = root / "launcher"
            supervisor = root / "supervisor.py"
            supervisor.write_bytes((TESTS / "final_verification_supervisor.py").read_bytes())
            supervisor.chmod(0o555)
            pinned_python = Path(sys.executable).resolve(strict=True)
            python_define = f'-DFINAL_VERIFY_PYTHON="{pinned_python}"'
            python_digest_define = f'-DFINAL_VERIFY_PYTHON_SHA256="{hashlib.sha256(pinned_python.read_bytes()).hexdigest()}"'
            compile_result = subprocess.run(
                ["cc", "-std=c11", "-Wall", "-Wextra", "-Werror", "-DFINAL_VERIFY_TEST_BUILD", python_define, python_digest_define,
                 str(TESTS / "final_verification_launcher.c"), "-framework", "Security", "-framework", "CoreFoundation", "-o", str(launcher)],
                check=False, capture_output=True, text=True,
            )
            self.assertEqual(compile_result.returncode, 0, compile_result.stderr)
            digest = hashlib.sha256(supervisor.read_bytes()).hexdigest()
            invocation = [str(launcher), "--supervisor", str(supervisor), "--expected-sha256", digest, "--", "self-test",
                          "--mode", "isolated-test", "--expected-protocol", "send2adf-final-verification/v1", "--expected-sha256", digest]
            # When: the launcher executes the verified descriptor, then sees a symlink and substituted digest.
            accepted = subprocess.run(invocation, check=False, capture_output=True, text=True)
            supervisor.unlink()
            supervisor.symlink_to(TESTS / "final_verification_supervisor.py")
            symlinked = subprocess.run(invocation, check=False, capture_output=True, text=True)
            supervisor.unlink()
            supervisor.write_text("raise SystemExit(0)\n", encoding="utf-8")
            supervisor.chmod(0o555)
            substituted = subprocess.run(invocation, check=False, capture_output=True, text=True)
            # Then: exact open bytes run once and both replacement classes fail before Python executes them.
            self.assertEqual(accepted.returncode, 0, accepted.stderr)
            self.assertIn('"credential_retrieved": false', accepted.stdout)
            self.assertEqual(symlinked.returncode, 2)
            self.assertEqual(substituted.returncode, 2)

    def test_signal_before_bootstrap_terminates_owned_child(self) -> None:
        # Given: a native start process whose verified child has not created a bootstrap receipt.
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            root = Path(temporary)
            launcher = root / "launcher"
            supervisor = root / "slow-supervisor.py"
            evidence = root / "evidence"
            evidence.mkdir(mode=0o700)
            supervisor.write_text("import time\ntime.sleep(60)\n", encoding="utf-8")
            supervisor.chmod(0o555)
            pinned_python = Path(sys.executable).resolve(strict=True)
            python_define = f'-DFINAL_VERIFY_PYTHON="{pinned_python}"'
            python_digest_define = f'-DFINAL_VERIFY_PYTHON_SHA256="{hashlib.sha256(pinned_python.read_bytes()).hexdigest()}"'
            subprocess.run(["cc", "-std=c11", "-Wall", "-Wextra", "-Werror", "-DFINAL_VERIFY_TEST_BUILD", python_define, python_digest_define,
                            str(TESTS / "final_verification_launcher.c"), "-framework", "Security", "-framework", "CoreFoundation", "-o", str(launcher)], check=True)
            digest = hashlib.sha256(supervisor.read_bytes()).hexdigest()
            process = subprocess.Popen(
                [str(launcher), "--supervisor", str(supervisor), "--expected-sha256", digest, "--", "start",
                 "--evidence-dir", str(evidence)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
            )
            coordinator_log = evidence / "coordinator.log"
            child_running = False
            for _ in range(1_000):
                child_observation = subprocess.run(
                    ["/bin/ps", "-axo", "pid=,ppid="],
                    check=False, capture_output=True, text=True,
                )
                child_running = any(
                    len(fields := line.split()) == 2 and fields[1] == str(process.pid)
                    for line in child_observation.stdout.splitlines()
                )
                if coordinator_log.exists() and child_running:
                    break
                if process.poll() is not None:
                    break
            self.assertTrue(child_running)
            # When: the orchestrator sends TERM before any bootstrap receipt exists.
            process.terminate()
            _, stderr = process.communicate(timeout=5)
            # Then: the launcher forwards TERM, reaps the child, retains mode-0600 log evidence, and returns failure.
            self.assertEqual(process.returncode, 2, stderr)
            self.assertIn("supervisor_terminated_before_receipt", stderr)
            self.assertFalse((evidence / "bootstrap.json").exists())
            self.assertEqual(stat.S_IMODE(coordinator_log.stat().st_mode), 0o600)
    def test_isolated_lanes(self) -> None:
        # Given: four supervisor-created lane snapshots and evidence roots.
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            attempt = str(uuid.uuid4())
            argv_sets = []
            for lane in LANES:
                state = root / "lane-state" / lane / "state.json"
                evidence = root / "lanes" / lane
                state.parent.mkdir(parents=True)
                state.write_text("{}\n", encoding="utf-8")
                argv_sets.append(build_lane_argv(root, evidence, state, attempt, lane, None))
            # When: the untrusted adapter catalogs each driver invocation.
            state_paths = {argv[argv.index("--state") + 1] for argv in argv_sets}
            evidence_paths = {argv[argv.index("--evidence-dir") + 1] for argv in argv_sets}
            # Then: no lane receives the master or another lane's path.
            self.assertEqual(len(state_paths), 4)
            self.assertEqual(len(evidence_paths), 4)
            self.assertTrue(all("lane-state" in path for path in state_paths))

    def test_real_driver_submits_over_private_capability(self) -> None:
        # Given: a real clean Git worktree, immutable scope assignment, private evidence root, and anonymous capability.
        with tempfile.TemporaryDirectory(dir=TESTS) as temporary:
            root = Path(temporary)
            repository = root / "repo"
            evidence = root / "evidence"
            repository.mkdir()
            evidence.mkdir(mode=0o700)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "init", "-q"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "config", "user.name", "fixture"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "config", "user.email", "fixture@example.invalid"], check=True)
            tracked = repository / "tracked.txt"
            tracked.write_text("base\n", encoding="utf-8")
            subprocess.run(["/usr/bin/git", "-C", str(repository), "add", "tracked.txt"], check=True)
            subprocess.run(["/usr/bin/git", "-C", str(repository), "commit", "-qm", "base"], check=True)
            base = subprocess.run(["/usr/bin/git", "-C", str(repository), "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
            tracked.write_text("final\n", encoding="utf-8")
            subprocess.run(["/usr/bin/git", "-C", str(repository), "commit", "-qam", "final"], check=True)
            final = subprocess.run(["/usr/bin/git", "-C", str(repository), "rev-parse", "HEAD"], check=True, capture_output=True, text=True).stdout.strip()
            attempt = str(uuid.uuid4())
            state = root / "state.json"
            state.write_text(json.dumps({"attempt_id": attempt, "base_sha": base, "capability_id": "1" * 32,
                                         "final_sha": final, "lane": "scope", "protocol": "send2adf-final-verification/v1",
                                         "public_fingerprint": "2" * 64}) + "\n", encoding="utf-8")
            state.chmod(0o444)
            parent, child = __import__("socket").socketpair()
            parent_descriptor = os.dup(parent.fileno())
            os.dup2(child.fileno(), 3)

            # When: the driver runs through its actual CLI and submits readiness over only inherited FD 3.
            process = subprocess.run(
                [sys.executable, str(TESTS / "run_final_verification.py"), "--repo-root", str(repository),
                 "--evidence-dir", str(evidence), "--state", str(state), "--attempt-id", attempt, "--lane", "scope"],
                check=False, capture_output=True, text=True, pass_fds=(3,),
            )
            child.close()
            parent.close()
            parent = __import__("socket").socket(fileno=parent_descriptor)
            parent.settimeout(1)
            submission = parent.recv(4096)
            parent.close()
            # Then: exclusive JSON/Markdown exist, stay untrusted, and bind exact final SHA/capability.
            self.assertEqual(process.returncode, 0, process.stderr)
            report = json.loads((evidence / "scope.json").read_text(encoding="utf-8"))
            self.assertEqual(report["status"], "untrusted_submission")
            self.assertEqual(report["final_sha"], final)
            self.assertIn(b'"event": "evidence-ready"', submission)
            self.assertEqual(stat.S_IMODE((evidence / "scope.json").stat().st_mode), 0o600)

            # Given: the same clean final SHA assigned to the canonical manual-qa offline rebuild probe.
            offline_evidence = root / "offline-evidence"
            offline_evidence.mkdir(mode=0o700)
            state.chmod(0o644)
            state.write_text(json.dumps({"attempt_id": attempt, "base_sha": base, "capability_id": "3" * 32,
                                         "final_sha": final, "lane": "manual-qa", "protocol": "send2adf-final-verification/v1",
                                         "public_fingerprint": "4" * 64}) + "\n", encoding="utf-8")
            state.chmod(0o444)
            parent, child = __import__("socket").socketpair()
            parent_descriptor = os.dup(parent.fileno())
            os.dup2(child.fileno(), 3)
            # When: the real driver executes the allowlisted passing probe through FD 3.
            offline = subprocess.run(
                [sys.executable, str(TESTS / "run_final_verification.py"), "--repo-root", str(repository),
                 "--evidence-dir", str(offline_evidence), "--state", str(state), "--attempt-id", attempt,
                 "--lane", "manual-qa", "--probe", "offline-rebuild"],
                check=False, capture_output=True, text=True, pass_fds=(3,),
            )
            child.close()
            parent.close()
            parent = __import__("socket").socket(fileno=parent_descriptor)
            parent.settimeout(1)
            offline_submission = parent.recv(4096)
            parent.close()
            # Then: it exits zero and creates only separately named probe evidence.
            self.assertEqual(offline.returncode, 0, offline.stderr)
            self.assertTrue((offline_evidence / "probe-offline-rebuild.json").is_file())
            self.assertIn(b"probe-offline-rebuild", offline_submission)

    def test_coordinated_seal_replacement(self) -> None:
        # Given: an externally anchored digest of the original state bytes.
        original = b'{"attempt":"one"}\n'
        anchor = sealed_digest(original, "state", "1" * 40)
        # When: candidate state and its repository-side seal are replaced together.
        replacement = b'{"attempt":"two"}\n'
        # Then: the retained external anchor rejects both coordinated bytes.
        with self.assertRaisesRegex(ProtocolError, "external_anchor_digest_mismatch"):
            verify_sealed_digest(replacement, anchor, "state", "1" * 40)

    def test_signing_agent_replacement(self) -> None:
        # Given: a seal bound to one capability identity.
        payload = b"lane evidence\n"
        seal = sealed_digest(payload, "capability-a", "2" * 40)
        # When/Then: replay under a substituted capability fails closed.
        with self.assertRaisesRegex(ProtocolError, "external_anchor_context_mismatch"):
            verify_sealed_digest(payload, seal, "capability-b", "2" * 40)

    def test_same_uid_signing_discovery(self) -> None:
        # Given: the environment visible to candidate descendants.
        environment = sanitized_environment(dict(os.environ), role="lane")
        # When: all values and names are inspected.
        serialized = json.dumps(environment, sort_keys=True)
        # Then: no signing or lifecycle capability is reconnectable by pathname.
        self.assertNotIn("SIGN", serialized.upper())
        self.assertNotIn("CONTROL_SOCKET", serialized.upper())

    def test_same_uid_control_spoof(self) -> None:
        # Given: the exact supervisor common lifecycle contract.
        supervisor = TESTS / "final_verification_supervisor.py"
        result = subprocess.run(
            [sys.executable, str(supervisor), "status", "--attempt-id", str(uuid.uuid4())],
            check=False,
            capture_output=True,
            text=True,
        )
        # When/Then: a sibling lacking authenticated PID/state/counter fields is rejected.
        self.assertEqual(result.returncode, 2)
        self.assertIn("required", result.stderr)

    def test_lifecycle_replay(self) -> None:
        # Given: a sealed state expecting counter 4.
        from final_verification_supervisor import consume_counter

        # When/Then: stale, duplicate, and skipped counters cannot advance it.
        for received in (3, 3, 5):
            with self.subTest(received=received), self.assertRaisesRegex(
                ProtocolError, "control_counter_mismatch"
            ):
                consume_counter(4, received)
        self.assertEqual(consume_counter(4, 4), 5)

    def test_reviewer_invocation_and_credentials_are_closed(self) -> None:
        # Given: supervisor-owned absolute Codex and schema paths.
        argv = reviewer_argv(Path("/trusted/codex"), Path("/trusted/reviewer.schema.json"))
        environment = sanitized_environment(
            {"GITHUB_TOKEN": "secret", "ACTIONS_RUNTIME_TOKEN": "secret", "RUNNER_TEMP": "/secret", "LANG": "C"},
            role="reviewer",
        )
        # When: reviewer launch surfaces are serialized for attestation.
        command = " ".join(argv)
        # Then: strict rule/config isolation is explicit and GitHub authority is absent.
        self.assertIn("--ignore-rules", argv)
        self.assertIn("--strict-config", argv)
        self.assertIn("--sandbox read-only", command)
        self.assertEqual(environment, {"LANG": "C"})
        self.assertEqual(credential_item_reference("op://GI Business/final-verification/credential"), "op://GI Business/final-verification/credential")
        with self.assertRaisesRegex(ProtocolError, "credential_item_reference_invalid"):
            credential_item_reference("op://Personal/final-verification/credential")

    def test_failure_case(self) -> None:
        cases = (SELECTED_CASE,) if SELECTED_CASE is not None else tuple(sorted(FAILURE_CASES))
        # Given: each named attack mutates a concrete process, filesystem, environment, credential, or protocol surface.
        for case in cases:
            with self.subTest(case=case):
                # When: the adversarial condition reaches its owning boundary.
                result = subprocess.run(
                    [sys.executable, str(TESTS / "final_verification_attack_runner.py"), "--case", case],
                    check=False, capture_output=True, text=True,
                )
                # Then: the production boundary emits a case-bound rejection observation.
                self.assertEqual(result.returncode, 0, result.stderr)
                observation = json.loads(result.stdout)
                self.assertEqual(observation["case"], case)
                self.assertFalse(observation["accepted"])


SELECTED_CASE: str | None = None


def suite_for_case(case: str) -> unittest.TestSuite:
    global SELECTED_CASE
    SELECTED_CASE = case
    methods = {
        "isolated-lanes": "test_isolated_lanes",
        "coordinated-seal-replacement": "test_coordinated_seal_replacement",
        "signing-agent-replacement": "test_signing_agent_replacement",
        "same-uid-signing-discovery": "test_same_uid_signing_discovery",
        "same-uid-control-spoof": "test_same_uid_control_spoof",
        "lifecycle-replay": "test_lifecycle_replay",
    }
    method = methods.get(case)
    if method is None and case in FAILURE_CASES:
        method = "test_failure_case"
    if method is None:
        raise SystemExit(f"unknown case: {case}")
    return unittest.TestSuite([FinalVerificationTests(method)])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", choices=sorted(FAILURE_CASES | {
        "isolated-lanes",
        "coordinated-seal-replacement",
        "signing-agent-replacement",
        "same-uid-signing-discovery",
        "same-uid-control-spoof",
        "lifecycle-replay",
    }))
    arguments = parser.parse_args()
    suite = suite_for_case(arguments.case) if arguments.case else unittest.defaultTestLoader.loadTestsFromTestCase(FinalVerificationTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(main())
