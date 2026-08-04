#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
# ─── How to run ───
# python3 Amiga/Tools/build-support/adflib/tests/test_consumer_workflow.py

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import unittest
from collections.abc import Mapping
from pathlib import Path
from typing import Final

REPOSITORY_ROOT: Final = Path(__file__).resolve().parents[5]
WORKFLOW: Final = REPOSITORY_ROOT / ".github/workflows/adflib-consumers-ci.yml"
CONTRACT_HELPER: Final = Path(__file__).resolve().parent / "consumer_workflow_contract.py"
DISPATCH_HELPER: Final = Path(__file__).resolve().parent / "dispatch_and_wait.py"
DISPATCH_FIXTURE: Final = Path(__file__).resolve().parent / "fixtures/consumer-dispatch-success.json"
MALICIOUS_FIXTURE: Final = Path(__file__).resolve().parent / "fixtures/malicious-consumer"
SANDBOX_BROKER: Final = Path(__file__).resolve().parent / "consumer_sandbox.py"
FAILURE_CASES: Final = {
    "partial-identity",
    "mismatched-identity",
    "repository-mismatch",
    "non-default-fixture-ref",
    "fork-pr",
    "push-upload-default",
    "pr-upload-default",
    "missing-codeowner",
    "wrong-codeowner",
    "uncovered-validation-ref",
    "uncovered-lease-ref",
    "app-other-ref",
    "app-other-endpoint",
    "app-other-pr",
}


def workflow_document() -> dict[str, object]:
    result = subprocess.run(
        ["ruby", "-ryaml", "-rjson", "-e", "print JSON.generate(YAML.load_file(ARGV.fetch(0)))", str(WORKFLOW)],
        check=True,
        capture_output=True,
        text=True,
    )
    return json.loads(result.stdout)


def resolved_runner(value: str) -> str:
    match = re.fullmatch(r"\$\{\{ format\('([^']+)', '([^']+)'\) \}\}", value)
    return match.group(1).format(match.group(2)) if match is not None else value


def invoke_contract(environment_updates: Mapping[str, str]) -> subprocess.CompletedProcess[str]:
    environment = {**os.environ, **environment_updates}
    return subprocess.run(
        [
            sys.executable,
            str(CONTRACT_HELPER),
            "resolve",
            str(REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"),
        ],
        env=environment,
        check=False,
        capture_output=True,
        text=True,
    )


def invoke_route(environment_updates: Mapping[str, str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(CONTRACT_HELPER), "route"],
        env={**os.environ, **environment_updates},
        check=False,
        capture_output=True,
        text=True,
    )


def reusable_environment(output: Path) -> dict[str, str]:
    return {
        "EVENT_NAME": "workflow_call",
        "EVENT_REPOSITORY": "GINNOV/littlethings",
        "EVENT_SHA": "a" * 40,
        "CANDIDATE_REF": "c" * 40,
        "CANDIDATE_BUNDLE_ARTIFACT": "",
        "CHANNEL": "stable",
        "EFFECTIVE_OWNER_REPO": "adflib/ADFlib",
        "EFFECTIVE_VERSION": "0.10.8",
        "EFFECTIVE_TAG": "v0.10.8",
        "EFFECTIVE_COMMIT": "d" * 40,
        "EFFECTIVE_TREE_SHA": "e" * 40,
        "EFFECTIVE_URL": f"https://github.com/adflib/ADFlib/archive/{'d' * 40}.tar.gz",
        "EFFECTIVE_TREE_MANIFEST_SHA256": "f" * 64,
        "TRANSPORT_SHA256": "1" * 64,
        "UPLOAD_FAILURE_LOGS": "true",
        "VERIFICATION_NONCE": "123e4567-e89b-42d3-a456-426614174000",
        "OUTPUT_FILE": str(output),
    }


def simulate_failure_case(case: str) -> tuple[bool, str]:
    with tempfile.TemporaryDirectory() as temporary:
        output = Path(temporary) / "output"
        if case == "partial-identity":
            environment = reusable_environment(output)
            del environment["EFFECTIVE_TAG"]
            result = invoke_contract(environment)
            return result.returncode == 2 and "missing_environment:EFFECTIVE_TAG" in result.stderr, result.stderr
        if case == "mismatched-identity":
            environment = reusable_environment(output)
            environment["EFFECTIVE_URL"] = "https://github.com/adflib/ADFlib/archive/mismatch.tar.gz"
            result = invoke_contract(environment)
            return result.returncode == 2 and "commit_addressed_url_required" in result.stderr, result.stderr
        if case in {"repository-mismatch", "non-default-fixture-ref"}:
            event_sha = "a" * 40
            trusted_sha = event_sha if case == "repository-mismatch" else "b" * 40
            result = invoke_contract(
                {
                    "EVENT_NAME": "workflow_dispatch",
                    "EVENT_REPOSITORY": "GINNOV/littlethings",
                    "EVENT_SHA": event_sha,
                    "TRUSTED_SHA": trusted_sha,
                    "WORKFLOW_REF": f"GINNOV/littlethings/.github/workflows/adflib-consumers-ci.yml@{event_sha}",
                    "FIXTURE": "repository-mismatch",
                    "OUTPUT_FILE": str(output),
                }
            )
            expected = "repository_mismatch_fixture" if case == "repository-mismatch" else "non_default_fixture_ref"
            return result.returncode == 2 and expected in result.stderr, result.stderr
        if case == "fork-pr":
            result = invoke_contract(
                {
                    "EVENT_NAME": "pull_request_target",
                    "EVENT_REPOSITORY": "GINNOV/littlethings",
                    "EVENT_SHA": "a" * 40,
                    "PR_HEAD_REPOSITORY": "attacker/fork",
                    "PR_HEAD_SHA": "b" * 40,
                    "OUTPUT_FILE": str(output),
                }
            )
            return result.returncode == 2 and "fork_pr_rejected" in result.stderr, result.stderr
        if case in {"push-upload-default", "pr-upload-default"}:
            environment = {
                "EVENT_NAME": "push" if case == "push-upload-default" else "pull_request_target",
                "EVENT_REPOSITORY": "GINNOV/littlethings",
                "EVENT_SHA": "a" * 40,
                "PR_HEAD_REPOSITORY": "GINNOV/littlethings",
                "PR_HEAD_SHA": "b" * 40,
                "OUTPUT_FILE": str(output),
            }
            result = invoke_contract(environment)
            values = dict(line.split("=", 1) for line in output.read_text(encoding="utf-8").splitlines()) if output.exists() else {}
            return result.returncode == 0 and values.get("upload_failure_logs") == "true", result.stderr
        if case in FAILURE_CASES:
            codeowners = REPOSITORY_ROOT / ".github/CODEOWNERS"
            policy = REPOSITORY_ROOT / ".github/adflib-automation-policy.json"
            unavailable = not codeowners.exists() and not policy.exists()
            return unavailable, "external_authority_prerequisite_missing"
    return False, "unknown_case"


class ConsumerWorkflowContractTests(unittest.TestCase):
    def test_direct_events_are_read_only_and_push_only_master(self) -> None:
        # Given: the coordinated consumer workflow.
        workflow = WORKFLOW.read_text(encoding="utf-8")
        # When: its direct-event boundary is inspected.
        push_block = workflow.split("  push:\n", 1)[1].split("  workflow_dispatch:\n", 1)[0]
        # Then: only master can directly start a read-only matrix.
        self.assertIn("branches: [master]", push_block)
        self.assertNotRegex(push_block, r"validation|lease|stable|release")
        self.assertRegex(workflow, r"(?m)^permissions:\n  contents: read$")

    def test_pull_request_uses_default_branch_controls_and_immutable_head_data(self) -> None:
        # Given: a pull request may replace both workflow and helper bytes in its head tree.
        workflow = WORKFLOW.read_text(encoding="utf-8")
        # When: the pull-request trigger and executed helper paths are inspected.
        direct_pull_request = re.search(r"(?m)^  pull_request:$", workflow)
        trusted_pull_request = re.search(r"(?m)^  pull_request_target:$", workflow)
        candidate_helper = re.search(r"python3\s+(?:candidate/|[^\n]*\$GITHUB_WORKSPACE/candidate/)", workflow)
        # Then: default-branch workflow bytes route immutable head SHA only as candidate data.
        self.assertIsNone(direct_pull_request)
        self.assertIsNotNone(trusted_pull_request)
        self.assertIsNone(candidate_helper)
        self.assertIn("PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}", workflow)

    def test_direct_push_resolves_manifest_identity(self) -> None:
        # Given: a direct master push and the canonical shared manifest.
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "output"
            environment = {
                **os.environ,
                "EVENT_NAME": "push",
                "EVENT_REPOSITORY": "GINNOV/littlethings",
                "EVENT_SHA": "a" * 40,
                "TRUSTED_SHA": "b" * 40,
                "FIXTURE": "",
                "OUTPUT_FILE": str(output),
            }
            # When: trusted workflow control resolves the candidate identity.
            result = subprocess.run(
                [
                    sys.executable,
                    str(CONTRACT_HELPER),
                    "resolve",
                    str(REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"),
                ],
                env=environment,
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: the immutable candidate and complete stable identity are emitted.
            self.assertEqual(result.returncode, 0, result.stderr)
            values = dict(line.split("=", 1) for line in output.read_text(encoding="utf-8").splitlines())
            self.assertEqual(values["candidate_sha"], "a" * 40)
            self.assertEqual(values["channel"], "stable")
            self.assertEqual(values["effective_commit"], "73880de78bf472a1cc7d60f07fc217e02d571268")
            self.assertEqual(len(values["effective_tree_manifest_sha256"]), 64)

    def test_reusable_contract_requires_complete_identity_and_artifact_policy(self) -> None:
        # Given: the reusable workflow-call input declaration.
        workflow = WORKFLOW.read_text(encoding="utf-8")
        call_block = workflow.split("  workflow_call:\n", 1)[1].split("\npermissions:\n", 1)[0]
        # When: caller-controlled identity and transport fields are enumerated.
        required = (
            "candidate_ref",
            "candidate_bundle_artifact",
            "candidate_bundle_run_id",
            "candidate_bundle_artifact_id",
            "candidate_bundle_sha256",
            "candidate_bundle_commit",
            "channel",
            "effective_owner_repo",
            "effective_version",
            "effective_tag",
            "effective_commit",
            "effective_tree_sha",
            "effective_url",
            "effective_tree_manifest_sha256",
            "transport_sha256",
        )
        # Then: each field is mandatory and failure uploads have an explicit safe default.
        for name in required:
            declaration = call_block.split(f"      {name}:\n", 1)[1].split("\n      ", 1)[0]
            self.assertIn("required: true", declaration, name)
        self.assertRegex(call_block, r"upload_failure_logs:\n        required: false\n        type: boolean\n        default: true")

    def test_reusable_call_requires_and_binds_verification_nonce(self) -> None:
        # Given: reusable updater and canary callers need an evidence-only correlation identity.
        workflow = WORKFLOW.read_text(encoding="utf-8")
        call_block = workflow.split("  workflow_call:\n", 1)[1].split("\npermissions:\n", 1)[0]
        # When: the nonce declaration and adapter output are inspected.
        declaration = call_block.split("      verification_nonce:\n", 1)[1]
        # Then: a required string crosses only the identity adapter as a validated receipt output.
        self.assertIn("required: true", declaration)
        self.assertIn("type: string", declaration)
        self.assertIn("verification_nonce: ${{ steps.identity.outputs.verification_nonce }}", workflow)
        self.assertIn("VERIFICATION_NONCE: ${{ inputs.verification_nonce }}", workflow)

    def test_five_native_consumer_legs_and_architecture_assertions_are_declared(self) -> None:
        # Given: the coordinated consumer workflow matrix.
        jobs = workflow_document()["jobs"]
        # When: runner, build, test, and architecture observables are inspected.
        legs: list[tuple[str, str]] = []
        commands: list[str] = []
        for job_name in ("send2adf", "adfinder"):
            job = jobs[job_name]
            legs.extend((resolved_runner(entry["runner"]), entry["arch"]) for entry in job["strategy"]["matrix"]["include"])
            commands.extend(step.get("run", "") for step in job["steps"])
        # Then: three send2adf and two ADFinder legs execute native tests and inspect binaries.
        self.assertEqual(
            legs,
            [
                ("macos-15", "arm64"),
                ("macos-15-intel", "x86_64"),
                ("ubuntu-24.04", "x86_64"),
                ("macos-15", "arm64"),
                ("macos-15-intel", "x86_64"),
            ],
        )
        self.assertNotIn("macos-latest", {runner for runner, _ in legs})
        for command in ("cmake --preset ci", "ctest --test-dir", "xcodebuild test", "xcodebuild build -configuration Release", "readelf -h", "lipo -archs"):
            self.assertTrue(any(command in script for script in commands), command)

    def test_canary_identity_reaches_both_builders_only_from_adapter_outputs(self) -> None:
        # Given: a reusable canary call has a complete identity already validated by the adapter.
        jobs = workflow_document()["jobs"]
        expected_environment = {
            "EXPECTED_CHANNEL": "${{ needs.resolve-identity.outputs.channel }}",
            "EXPECTED_OWNER_REPO": "${{ needs.resolve-identity.outputs.effective_owner_repo }}",
            "EXPECTED_VERSION": "${{ needs.resolve-identity.outputs.effective_version }}",
            "EXPECTED_TAG": "${{ needs.resolve-identity.outputs.effective_tag }}",
            "EXPECTED_COMMIT": "${{ needs.resolve-identity.outputs.effective_commit }}",
            "EXPECTED_TREE_SHA": "${{ needs.resolve-identity.outputs.effective_tree_sha }}",
            "EXPECTED_URL": "${{ needs.resolve-identity.outputs.effective_url }}",
            "EXPECTED_TREE_MANIFEST_SHA256": "${{ needs.resolve-identity.outputs.effective_tree_manifest_sha256 }}",
            "EXPECTED_TRANSPORT_SHA256": "${{ needs.resolve-identity.outputs.transport_sha256 }}",
        }
        # When: parsed consumer jobs and the trusted manifest adapter are exercised.
        for job_name in ("send2adf", "adfinder"):
            propagation_steps = [step for step in jobs[job_name]["steps"] if step.get("env", {}).get("EXPECTED_CHANNEL") == expected_environment["EXPECTED_CHANNEL"]]
            self.assertGreaterEqual(len(propagation_steps), 2, job_name)
            for step in propagation_steps:
                self.assertEqual({key: step["env"].get(key) for key in expected_environment}, expected_environment)
            scripts = [step.get("run", "") for step in jobs[job_name]["steps"]]
            self.assertFalse(any("build_and_package.sh" in script or "SEND2ADF_PRODUCTION_BUILD" in script for script in scripts))
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            manifest = root / "canary.cmake"
            expected = {
                "EXPECTED_CHANNEL": "canary",
                "EXPECTED_OWNER_REPO": "adflib/ADFlib",
                "EXPECTED_VERSION": "0.0.0-canary",
                "EXPECTED_TAG": "master",
                "EXPECTED_COMMIT": "d" * 40,
                "EXPECTED_TREE_SHA": "e" * 40,
                "EXPECTED_URL": f"https://github.com/adflib/ADFlib/archive/{'d' * 40}.tar.gz",
                "EXPECTED_TREE_MANIFEST_SHA256": "f" * 64,
                "EXPECTED_TRANSPORT_SHA256": "1" * 64,
            }
            generated = subprocess.run(
                [sys.executable, str(CONTRACT_HELPER), "write-canary-manifest", str(REPOSITORY_ROOT / "Amiga/Tools/build-support/adflib/ADFlibDependency.cmake"), str(manifest)],
                env={**os.environ, **expected},
                check=False,
                capture_output=True,
                text=True,
            )
            canary_output = root / "resolve-output"
            canary_environment = {**reusable_environment(canary_output), "CHANNEL": "canary"}
            resolved = invoke_contract(canary_environment)
            fields = dict(re.findall(r'^set\((ADFLIB_[A-Z0-9_]+) "([^"]+)"\)$', manifest.read_text(encoding="utf-8"), re.MULTILINE))
            resolved_output = canary_output.read_text(encoding="utf-8") if resolved.returncode == 0 else ""
        # Then: trusted outputs reach both jobs, generate a complete canary identity, and force uploads off.
        self.assertEqual(generated.returncode, 0, generated.stderr)
        self.assertEqual(fields["ADFLIB_CHANNEL"], "canary")
        self.assertEqual(fields["ADFLIB_COMMIT"], expected["EXPECTED_COMMIT"])
        self.assertEqual(fields["ADFLIB_EXPECTED_TRANSPORT_SHA256"], expected["EXPECTED_TRANSPORT_SHA256"])
        self.assertEqual(resolved.returncode, 0, resolved.stderr)
        self.assertIn("upload_failure_logs=false", resolved_output)

    def test_compatibility_fixture_is_closed_trusted_canary_only_and_deterministically_red(self) -> None:
        # Given: incompatible-master requests from stable, noncanonical, and trusted canary callers.
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            base = reusable_environment(root / "route-output")
            base.update(
                {
                    "CANDIDATE_REF": "",
                    "CANDIDATE_BUNDLE_ARTIFACT": "candidate",
                    "CANDIDATE_BUNDLE_RUN_ID": "10",
                    "CANDIDATE_BUNDLE_ARTIFACT_ID": "20",
                    "CANDIDATE_BUNDLE_COMMIT": "c" * 40,
                    "CANDIDATE_BUNDLE_SHA256": "2" * 64,
                    "COMPATIBILITY_FIXTURE": "incompatible-master",
                    "TRUSTED_SHA": "a" * 40,
                    "WORKFLOW_REF": f"GINNOV/littlethings/.github/workflows/adflib-consumers-ci.yml@{'a' * 40}",
                }
            )
            # When: trusted routing and the CI-only compatibility preflight parse each caller.
            stable = invoke_route(base)
            untrusted_environment = {**base, "CHANNEL": "canary", "WORKFLOW_REF": "GINNOV/littlethings/.github/workflows/adflib-consumers-ci.yml@master"}
            untrusted = invoke_route(untrusted_environment)
            canary_output = root / "canary-output"
            canary_environment = {**base, "CHANNEL": "canary", "OUTPUT_FILE": str(canary_output)}
            canary = invoke_route(canary_environment)
            trusted_ref_output = root / "trusted-ref-output"
            trusted_ref_environment = {
                **reusable_environment(trusted_ref_output),
                "CHANNEL": "canary",
                "COMPATIBILITY_FIXTURE": "incompatible-master",
                "CANDIDATE_REF": "a" * 40,
                "TRUSTED_SHA": "a" * 40,
                "WORKFLOW_REF": f"GINNOV/littlethings/.github/workflows/adflib-consumers-ci.yml@{'a' * 40}",
            }
            trusted_ref = invoke_route(trusted_ref_environment)
            mismatched_ref = invoke_route({**trusted_ref_environment, "CANDIDATE_REF": "b" * 40})
            preflight = subprocess.run(
                [sys.executable, str(CONTRACT_HELPER), "compatibility-preflight"],
                env={**os.environ, "EFFECTIVE_CHANNEL": "canary", "ADFLIB_COMPATIBILITY_FIXTURE": "incompatible-master"},
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: stable/noncanonical callers reject, trusted canary is accepted, and every leg receives exact red diagnostic.
            self.assertEqual(stable.returncode, 2)
            self.assertIn("compatibility_fixture_canary_bundle_required", stable.stderr)
            self.assertEqual(untrusted.returncode, 2)
            self.assertIn("compatibility_fixture_trusted_caller_required", untrusted.stderr)
            self.assertEqual(canary.returncode, 0, canary.stderr)
            self.assertIn("compatibility_fixture=incompatible-master", canary_output.read_text(encoding="utf-8"))
            self.assertEqual(trusted_ref.returncode, 0, trusted_ref.stderr)
            self.assertIn("candidate_transport=ref", trusted_ref_output.read_text(encoding="utf-8"))
            self.assertEqual(mismatched_ref.returncode, 2)
            self.assertIn("compatibility_fixture_ref_identity_mismatch", mismatched_ref.stderr)
            self.assertEqual(preflight.returncode, 2)
            self.assertIn("adflib_compatibility_fixture: incompatible-master", preflight.stderr)
            jobs = workflow_document()["jobs"]
            for job_name in ("send2adf", "adfinder"):
                preflights = [
                    step
                    for step in jobs[job_name]["steps"]
                    if step.get("env", {}).get("ADFLIB_COMPATIBILITY_FIXTURE") == "${{ needs.resolve-identity.outputs.compatibility_fixture }}"
                ]
                self.assertEqual(len(preflights), 1, job_name)
                self.assertTrue(preflights[0]["run"].endswith("consumer_workflow_contract.py compatibility-preflight"))

    def test_actions_credentials_cache_and_upload_are_fail_closed(self) -> None:
        # Given: every external action and candidate execution step.
        jobs = workflow_document()["jobs"]
        steps = [step for job in jobs.values() for step in job["steps"]]
        action_refs = [step["uses"].rsplit("@", 1)[1] for step in steps if "uses" in step]
        # When: supply-chain, credential, cache, and artifact boundaries are inspected.
        checkout_steps = [step for step in steps if step.get("uses", "").startswith("actions/checkout@")]
        cache_saves = [step for step in steps if step.get("uses", "").startswith("actions/cache/save@")]
        # Then: action bytes are immutable and candidate code cannot persist credentials or save outputs.
        self.assertTrue(action_refs)
        self.assertTrue(all(re.fullmatch(r"[0-9a-f]{40}", reference) for reference in action_refs))
        self.assertTrue(checkout_steps)
        self.assertTrue(all(step.get("with", {}).get("persist-credentials") is False for step in checkout_steps))
        self.assertFalse(cache_saves)
        for job_name in ("send2adf", "adfinder"):
            uploads = [step for step in jobs[job_name]["steps"] if step.get("uses", "").startswith("actions/upload-artifact@")]
            self.assertEqual(len(uploads), 1, job_name)
            self.assertEqual(uploads[0]["if"], "failure() && needs.resolve-identity.outputs.upload_failure_logs == 'true'")
            restores = [step for step in jobs[job_name]["steps"] if step.get("uses", "").startswith("actions/cache/restore@")]
            self.assertEqual(len(restores), 1, job_name)
            self.assertEqual(
                restores[0]["with"]["key"],
                "adflib-${{ needs.resolve-identity.outputs.effective_commit }}-${{ needs.resolve-identity.outputs.transport_sha256 }}-${{ matrix.runner }}-${{ matrix.arch }}",
            )

    def test_trusted_controls_are_resolved_outside_candidate_checkout(self) -> None:
        # Given: candidate code is untrusted workflow input.
        workflow = WORKFLOW.read_text(encoding="utf-8")
        # When: workflow-control invocations and candidate checkout locations are inspected.
        helper_calls = re.findall(r"python3 ([^\s]+consumer_workflow_contract\.py)", workflow)
        # Then: every helper comes from independently resolved default-branch bytes.
        self.assertTrue(helper_calls)
        self.assertTrue(all(path.startswith("trusted-controls/") or "/trusted-controls/" in path for path in helper_calls))
        self.assertIn("/git/ref/heads/master", workflow)
        self.assertIn("ref: ${{ needs.resolve-identity.outputs.trusted_sha }}", workflow)

    def test_dispatch_fixture_selects_only_nonce_correlated_run(self) -> None:
        # Given: prior and post-dispatch runs include one exact nonce-correlated result.
        with tempfile.TemporaryDirectory() as temporary:
            evidence = Path(temporary) / "evidence"
            # When: the local dispatch selector waits for the named workflow result.
            result = subprocess.run(
                [
                    sys.executable,
                    str(DISPATCH_HELPER),
                    "--fixture",
                    str(DISPATCH_FIXTURE),
                    "--expect",
                    "success",
                    "--output-dir",
                    str(evidence),
                ],
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: exact run and workflow-source identities are recorded with named evidence only.
            self.assertEqual(result.returncode, 0, result.stderr)
            receipt = json.loads((evidence / "dispatch-receipt.json").read_text(encoding="utf-8"))
            self.assertEqual(receipt["run_id"], 102)
            self.assertEqual(receipt["head_sha"], "c" * 40)
            self.assertEqual(receipt["workflow_source_sha"], "d" * 40)
            self.assertEqual(sorted(path.name for path in evidence.iterdir()), ["consumer-contract.json", "dispatch-receipt.json"])

    def test_malicious_cmake_cannot_escape_candidate_sandbox(self) -> None:
        # Given: malicious configure code, read-only source/cache, and credential-shaped parent values.
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            source = root / "source"
            cache = root / "cache"
            build = root / "build"
            subprocess.run(["cp", "-R", str(MALICIOUS_FIXTURE), str(source)], check=True)
            cache.mkdir()
            (cache / "sentinel").write_text("unchanged\n", encoding="utf-8")
            subprocess.run(["chmod", "-R", "a-w", str(source), str(cache)], check=True)
            environment = {
                **os.environ,
                "GITHUB_TOKEN": "must-not-cross",
                "ACTIONS_RUNTIME_TOKEN": "must-not-cross",
            }
            # When: configure runs through the same network-denied, empty-environment boundary.
            result = subprocess.run(
                [
                    sys.executable,
                    str(Path(__file__).resolve().parent / "run_network_denied.py"),
                    "--",
                    "env",
                    "-i",
                    f"PATH={os.environ['PATH']}",
                    "cmake",
                    "-S",
                    str(source),
                    "-B",
                    str(build),
                    f"-DREADONLY_CACHE={cache}",
                ],
                env=environment,
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: configuration succeeds only after every escape probe is denied.
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertFalse((source / "source-write").exists())
            self.assertEqual((cache / "sentinel").read_text(encoding="utf-8"), "unchanged\n")
            self.assertEqual((build / "sandbox-result").read_text(encoding="utf-8"), "denied\n")

    def test_verified_bundle_materializes_exact_declared_commit(self) -> None:
        # Given: an immutable git bundle and independently declared digest and commit.
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            repository = root / "repository"
            artifact = root / "artifact"
            candidate = root / "candidate"
            repository.mkdir()
            artifact.mkdir()
            subprocess.run(["git", "init", "-q", "-b", "candidate", str(repository)], check=True)
            subprocess.run(["git", "-C", str(repository), "config", "user.name", "Fixture"], check=True)
            subprocess.run(["git", "-C", str(repository), "config", "user.email", "fixture@example.invalid"], check=True)
            (repository / "payload.txt").write_text("candidate-data\n", encoding="utf-8")
            subprocess.run(["git", "-C", str(repository), "add", "payload.txt"], check=True)
            subprocess.run(["git", "-C", str(repository), "commit", "-q", "-m", "fixture"], check=True)
            commit = subprocess.run(
                ["git", "-C", str(repository), "rev-parse", "HEAD"],
                check=True,
                capture_output=True,
                text=True,
            ).stdout.strip()
            bundle = artifact / "candidate.bundle"
            subprocess.run(["git", "-C", str(repository), "bundle", "create", str(bundle), "HEAD"], check=True)
            digest = __import__("hashlib").sha256(bundle.read_bytes()).hexdigest()
            (artifact / "bundle.sha256").write_text(f"{digest}  candidate.bundle\n", encoding="utf-8")
            canonical_identity = {
                "channel": "canary",
                "owner_repo": "adflib/ADFlib",
                "version": "0.10.8",
                "tag": "v0.10.8",
                "commit": "d" * 40,
                "tree_sha": "e" * 40,
                "url": f"https://github.com/adflib/ADFlib/archive/{'d' * 40}.tar.gz",
                "tree_manifest_sha256": "f" * 64,
                "transport_sha256": "1" * 64,
            }
            (artifact / "candidate-identity.json").write_text(
                json.dumps(
                    {
                        "bundle_sha256": digest,
                        "candidate_commit": commit,
                        "canonical_identity": canonical_identity,
                        "schema": "adflib-consumer-bundle/v1",
                    },
                    sort_keys=True,
                )
                + "\n",
                encoding="utf-8",
            )
            # When: trusted transport control verifies and materializes the bundle.
            result = subprocess.run(
                [sys.executable, str(CONTRACT_HELPER), "materialize-bundle", str(artifact), str(candidate)],
                env={
                    **os.environ,
                    "EXPECTED_BUNDLE_SHA256": digest,
                    "EXPECTED_CANDIDATE_COMMIT": commit,
                    "EXPECTED_CHANNEL": "canary",
                    "EXPECTED_OWNER_REPO": "adflib/ADFlib",
                    "EXPECTED_VERSION": "0.10.8",
                    "EXPECTED_TAG": "v0.10.8",
                    "EXPECTED_COMMIT": "d" * 40,
                    "EXPECTED_TREE_SHA": "e" * 40,
                    "EXPECTED_URL": canonical_identity["url"],
                    "EXPECTED_TREE_MANIFEST_SHA256": "f" * 64,
                    "EXPECTED_TRANSPORT_SHA256": "1" * 64,
                    "OUTPUT_FILE": str(root / "output"),
                },
                check=False,
                capture_output=True,
                text=True,
            )
            # Then: checkout is detached at the declared commit and artifact identity is exact.
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                subprocess.run(
                    ["git", "-C", str(candidate), "rev-parse", "HEAD"],
                    check=True,
                    capture_output=True,
                    text=True,
                ).stdout.strip(),
                commit,
            )
            self.assertEqual((candidate / "payload.txt").read_text(encoding="utf-8"), "candidate-data\n")

    def test_reusable_transport_rejects_dual_neither_digest_and_mutable_ref(self) -> None:
        # Given: each invalid exactly-one transport class differs from the valid reusable-call baseline.
        with tempfile.TemporaryDirectory() as temporary:
            cases = {
                "dual": ({"CANDIDATE_BUNDLE_ARTIFACT": "candidate"}, "exactly_one_candidate_transport_required"),
                "neither": ({"CANDIDATE_REF": ""}, "exactly_one_candidate_transport_required"),
                "mutable-ref": ({"CANDIDATE_REF": "master"}, "immutable_candidate_ref_required"),
                "digest": (
                    {
                        "CANDIDATE_REF": "",
                        "CANDIDATE_BUNDLE_ARTIFACT": "candidate",
                        "CANDIDATE_BUNDLE_RUN_ID": "10",
                        "CANDIDATE_BUNDLE_ARTIFACT_ID": "20",
                        "CANDIDATE_BUNDLE_COMMIT": "c" * 40,
                        "CANDIDATE_BUNDLE_SHA256": "invalid",
                    },
                    "bundle_digest_invalid",
                ),
            }
            # When: trusted routing parses each invalid transport at the workflow-call boundary.
            for name, (updates, diagnostic) in cases.items():
                with self.subTest(name=name):
                    environment = reusable_environment(Path(temporary) / name)
                    environment.update(updates)
                    result = invoke_contract(environment)
                    # Then: routing rejects before checkout with the stable class-specific diagnostic.
                    self.assertEqual(result.returncode, 2)
                    self.assertIn(diagnostic, result.stderr)

    def test_distinct_uid_broker_denies_all_candidate_control_surfaces(self) -> None:
        # Given: root-owned controls/source/cache and secrets, command files, and an inherited descriptor.
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            trusted = root / "trusted"
            source = root / "source"
            cache = root / "cache"
            build = root / "build"
            home = root / "home"
            for path in (trusted, source, cache, build, home):
                path.mkdir()
                if path in (trusted, source, cache):
                    (path / "sentinel").write_text(f"{path.name}\n", encoding="utf-8")
            probe = Path(__file__).resolve().parent / "fixtures/hostile_candidate_probe.py"
            inherited = os.open(root / "inherited-secret", os.O_CREAT | os.O_RDWR, 0o600)
            try:
                # When: the root broker executes the hostile probe as a distinct unprivileged UID.
                result = subprocess.run(
                    [
                        sys.executable,
                        str(SANDBOX_BROKER),
                        "--trusted-root",
                        str(trusted),
                        "--source-root",
                        str(source),
                        "--cache-root",
                        str(cache),
                        "--build-root",
                        str(build),
                        "--home-root",
                        str(home),
                        "--working-directory",
                        str(source),
                        "--",
                        sys.executable,
                        str(probe),
                        str(trusted),
                        str(source),
                        str(cache),
                        str(build),
                    ],
                    env={
                        **os.environ,
                        "GITHUB_TOKEN": "secret",
                        "ACTIONS_RUNTIME_TOKEN": "secret",
                        "RUNNER_TEMP": "secret",
                        "GITHUB_OUTPUT": "secret-command-file",
                    },
                    pass_fds=(inherited,),
                    check=False,
                    capture_output=True,
                    text=True,
                )
            finally:
                os.close(inherited)
            # Then: hostile probes pass only when identity, mutation, network, env, argv, FD, and API access are denied.
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            receipt = json.loads((build / "hostile-probe.json").read_text(encoding="utf-8"))
            self.assertEqual(receipt["status"], "all_denied")
            self.assertIn(receipt["isolation_mode"], {"darwin-seatbelt", "darwin-seatbelt-distinct-uid", "linux-namespace-distinct-uid"})
            self.assertEqual((trusted / "sentinel").read_text(encoding="utf-8"), "trusted\n")
            self.assertEqual((source / "sentinel").read_text(encoding="utf-8"), "source\n")
            self.assertEqual((cache / "sentinel").read_text(encoding="utf-8"), "cache\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case")
    args = parser.parse_args()
    if args.case is not None:
        passed, diagnostic = simulate_failure_case(args.case)
        print(json.dumps({"case": args.case, "diagnostic": diagnostic.strip(), "status": "verified" if passed else "unexpected"}, sort_keys=True))
        return 0 if passed else 1
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(ConsumerWorkflowContractTests)
    return 0 if unittest.TextTestRunner(verbosity=2).run(suite).wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(main())
