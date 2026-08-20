#!/usr/bin/env python3

from __future__ import annotations

import os
import subprocess
import sys
import time
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, exclusive_json, exclusive_write, sha256_file
from final_gate_support import absolute_new_directory, archive_sha256, artifact_record, ensure_private_directory, existing_absolute, path_under, parser_for, read_bound_receipt, validate_review_receipts, verify_clean_commit, write_source_manifest
from final_gate_validation import validate_task_modes


def begin(gate: str, args: argparse.Namespace) -> None:
    root = absolute_new_directory(args.isolated_root, "isolated-root")
    ensure_private_directory(root / "runtime", "runtime")
    for name, value in (("fixedUserHome", args.fixed_user_home), ("applicationSupport", args.application_support_root), ("caches", args.cache_root), ("tempRoot", args.temp_root)):
        ensure_private_directory(path_under(root, value, name), name)
    for fifo in (args.observation_gate, args.scope_gate):
        if fifo is not None:
            fifo_path = path_under(root, fifo, "gate fifo")
            fifo_path.parent.resolve(strict=True)
            os.mkfifo(fifo_path, 0o600)
    source_manifest_path = path_under(root, args.source_manifest, "source manifest")
    if source_manifest_path.parent != root:
        raise EvidenceError("manifest-path", "source manifest must be a direct child of isolated-root")
    project_root = Path.cwd().resolve()
    write_source_manifest(source_manifest_path, project_root, args.commit)
    if args.sandbox_template is not None:
        template = existing_absolute(args.sandbox_template, "sandbox template")
        if args.sandbox_output is None:
            raise EvidenceError("missing-sandbox-output", gate)
        sandbox_output = path_under(root, args.sandbox_output, "sandbox output")
        exclusive_write(sandbox_output, template.read_bytes())
    paths = {name: str(path_under(root, value, name).resolve()) for name, value in (("fixedUserHome", args.fixed_user_home), ("applicationSupport", args.application_support_root), ("caches", args.cache_root), ("tempRoot", args.temp_root))}
    context = {
        "schemaVersion": 1,
        "kind": f"{gate}-begin",
        "runID": args.run_id,
        "childNonce": args.child_nonce,
        "commitSHA": args.commit,
        "expectedArchiveSHA256": args.expected_archive_sha256,
        "sourceManifestSHA256": sha256_file(source_manifest_path),
        "isolatedRoot": str(root),
        "paths": paths,
        "createdMonotonicNs": time.monotonic_ns(),
    }
    if args.gui_lease_receipt is not None:
        lease = existing_absolute(args.gui_lease_receipt, "gui lease")
        context["guiLease"] = {"path": str(lease), "sha256": sha256_file(lease)}
    exclusive_json(root / "runtime-paths.json", {"schemaVersion": 1, "paths": paths, "sourceManifestSHA256": sha256_file(source_manifest_path)})
    exclusive_json(root / "context.json", context)
    print(root)


def finalize(gate: str, args: argparse.Namespace) -> None:
    root = existing_absolute(args.isolated_root, "isolated-root")
    index = root / "index.json"
    if index.exists():
        raise EvidenceError("index-exists", str(index))
    source_manifest = path_under(root, args.source_manifest, "source-manifest", True)
    context = existing_absolute(root / "context.json", "context")
    validate_context(context, gate, args.run_id, args.child_nonce, args.commit, args.expected_archive_sha256, source_manifest, root)
    required: list[Path | None] = []
    if gate == "manual-fixture":
        required.extend([args.scenario, args.xcresult, args.tested_app, args.build_receipt, args.runtime_paths, args.screenshots, args.observer_report, args.xctest_launch_receipt, args.ready_receipt, args.hold_receipt, args.release_receipt, args.xctest_exit_receipt])
    else:
        required.extend([args.release_app, args.build_receipt, args.runtime_paths, args.app_launch_receipt, args.app_ready_receipt, args.gate_release_receipt, args.app_exit_receipt, args.requirements, args.filesystem_events, args.pre_manifests, args.post_manifests, args.sandbox_events, args.sandbox_profile, args.barrier_receipts, args.stopped_receipts, args.fsevents_ready, args.sandbox_ready, args.static_network_audit, args.bundle_manifest, args.signature_receipt, args.entitlements])
    resolved_required: list[Path] = []
    for value in required:
        if value is None:
            raise EvidenceError("missing-final-artifact", gate)
        allow_source_input = gate == "manual-fixture" and value == args.scenario or gate == "scope" and value == args.requirements
        resolved = existing_absolute(Path.cwd() / value, gate) if allow_source_input and not value.is_absolute() else path_under(root, value, gate, True)
        if resolved.is_dir():
            if not any(resolved.iterdir()):
                raise EvidenceError("empty-final-artifact", str(resolved))
        elif resolved.stat().st_size == 0:
            raise EvidenceError("empty-final-artifact", str(resolved))
        resolved_required.append(resolved)

    if gate == "manual-fixture":
        scenario = resolved_required[0]
        if scenario.suffix not in {".yaml", ".yml"}:
            raise EvidenceError("invalid-scenario", str(scenario))
        scenario_text = scenario.read_text(encoding="utf-8").upper()
        if any(token in scenario_text.split() for token in ("SKIP", "SKIPPED", "NOT_APPLICABLE")):
            raise EvidenceError("forbidden-scenario-outcome", str(scenario))

    def receipt(path: Path | None, label: str) -> dict[str, JsonValue]:
        if path is None:
            raise EvidenceError("missing-receipt", label)
        resolved = path_under(root, path, label, True)
        return read_bound_receipt(resolved, label, args.run_id, args.child_nonce, args.commit, args.expected_archive_sha256, sha256_file(source_manifest))

    build = receipt(args.build_receipt, "build-receipt")
    if build.get("actualExit", build.get("exitStatus", build.get("status"))) not in (0, "0", "PASS"):
        raise EvidenceError("build-failed", str(args.build_receipt))
    extra_paths: list[Path] = []
    if gate == "manual-fixture":
        launch = receipt(args.xctest_launch_receipt, "xctest-launch-receipt")
        ready = receipt(args.ready_receipt, "ready-receipt")
        hold = receipt(args.hold_receipt, "hold-receipt")
        release = receipt(args.release_receipt, "release-receipt")
        exit_receipt = receipt(args.xctest_exit_receipt, "xctest-exit-receipt")
        if not launch or not ready or not hold or not release or not exit_receipt:
            raise EvidenceError("incomplete-manual-receipts", str(root))
        if args.require_post_journey_test_hold and not any(key in hold for key in ("waitStartMonotonicNs", "waitStart", "holdWaitStart")):
            raise EvidenceError("missing-post-journey-hold", str(args.hold_receipt))
        if exit_receipt.get("exitStatus", exit_receipt.get("actualExit", 0)) not in (0, "0", "PASS"):
            raise EvidenceError("xctest-failed", str(args.xctest_exit_receipt))
    else:
        for path, label in ((args.app_launch_receipt, "app-launch-receipt"), (args.app_ready_receipt, "app-ready-receipt"), (args.gate_release_receipt, "gate-release-receipt"), (args.app_exit_receipt, "app-exit-receipt")):
            receipt(path, label)
        for option, label in ((args.probe_build_receipts, "probe-build"), (args.probe_launch_receipts, "probe-launch"), (args.probe_exit_receipts, "probe-exit"), (args.stopped_receipts, "stopped")):
            if option is None:
                raise EvidenceError("missing-scope-receipt", label)
            for item in option.split(","):
                path = path_under(root, Path(item), label, True)
                receipt(path, label)
                extra_paths.append(path)
        network = receipt(args.static_network_audit, "static-network-audit")
        if network.get("outcome") not in (None, "PASS"):
            raise EvidenceError("network-audit-failed", str(args.static_network_audit))
        entitlements = path_under(root, args.entitlements, "entitlements", True)
        if any(token in entitlements.read_text(encoding="utf-8") for token in ("com.apple.security.app-sandbox", "com.apple.security.device.usb", "serial", "microphone")):
            raise EvidenceError("sandbox-entitlement-present", str(args.entitlements))
        app = path_under(root, args.release_app, "release-app", True)
        app_record = build.get("app")
        if not isinstance(app_record, dict) or app_record.get("path") != str(app):
            raise EvidenceError("build-app-mismatch", str(args.build_receipt))
        if app_record.get("sha256") != artifact_record(app, "release-app")["sha256"]:
            raise EvidenceError("build-app-hash-mismatch", str(app))

    artifacts = [artifact_record(source_manifest, "source-manifest"), artifact_record(context, "context")]
    artifacts.extend(artifact_record(value, gate) for value in resolved_required)
    artifacts.extend(artifact_record(value, "scope receipt") for value in extra_paths if value not in resolved_required)
    exclusive_json(
        index,
        {
            "schemaVersion": 1,
            "gate": gate,
            "runID": args.run_id,
            "childNonce": args.child_nonce,
            "commitSHA": args.commit,
            "expectedArchiveSHA256": args.expected_archive_sha256,
            "sourceManifestSHA256": sha256_file(source_manifest),
            "outcome": "PASS",
            "artifacts": artifacts,
        },
    )
    print(index)


def compliance_or_quality(gate: str, args: argparse.Namespace) -> None:
    root = absolute_new_directory(args.isolated_root, "isolated-root")
    project_root = Path.cwd().resolve()
    verify_clean_commit(project_root, args.commit)
    source_manifest = path_under(root, args.source_manifest, "source manifest")
    if source_manifest.parent != root:
        raise EvidenceError("manifest-path", "source manifest must be a direct child of isolated-root")
    write_source_manifest(source_manifest, project_root, args.commit)
    actual_archive = archive_sha256(project_root, args.commit)
    if actual_archive != args.expected_archive_sha256:
        raise EvidenceError("archive-mismatch", actual_archive)
    context = root / "context.json"
    exclusive_json(context, {"schemaVersion": 1, "kind": f"{gate}-begin", "runID": args.run_id, "childNonce": args.child_nonce, "commitSHA": args.commit, "expectedArchiveSHA256": args.expected_archive_sha256, "sourceManifestSHA256": sha256_file(source_manifest), "isolatedRoot": str(root), "createdMonotonicNs": time.monotonic_ns()})
    artifacts = [artifact_record(source_manifest, "source manifest"), artifact_record(context, "context")]
    if gate == "quality":
        if args.base == args.commit:
            raise EvidenceError("empty-review-range", "base and final commits are identical")
        if args.review_receipts is None:
            raise EvidenceError("review-lanes-required", "four independent review receipts are required")
        receipts = [Path(value) for value in args.review_receipts.split(",") if value]
        validate_review_receipts(receipts, args.commit)
        artifacts.extend(artifact_record(path, "review receipt") for path in receipts)
    else:
        if args.require_task_modes != 66:
            raise EvidenceError("task-modes-incomplete", "compliance requires --require-task-modes 66")
        task_receipts = validate_task_modes(args.evidence_root, args.require_task_modes)
        artifacts.extend(artifact_record(path, "task receipt") for path in task_receipts)
        if args.process_receipt is None or not args.process_receipt.exists():
            raise EvidenceError("missing-process-receipt", str(args.process_receipt))
        if args.poisoned_env is None or not args.poisoned_env.exists():
            raise EvidenceError("missing-poisoned-environment", str(args.poisoned_env))
        artifacts.extend([artifact_record(args.process_receipt, "process receipt"), artifact_record(args.poisoned_env, "poisoned environment")])
    exclusive_json(root / "index.json", {"schemaVersion": 1, "gate": gate, "runID": args.run_id, "childNonce": args.child_nonce, "commitSHA": args.commit, "expectedArchiveSHA256": args.expected_archive_sha256, "sourceManifestSHA256": sha256_file(source_manifest), "outcome": "PASS", "artifacts": artifacts})
    print(root / "index.json")


def main(argv: list[str]) -> int:
    if not argv:
        print("ERROR[usage]: gate is required", file=sys.stderr)
        return 2
    gate = argv[0]
    if gate not in {"compliance", "quality", "manual-fixture", "scope"}:
        print(f"ERROR[unknown-gate]: {gate}", file=sys.stderr)
        return 2
    phase: str | None = None
    remaining = argv[1:]
    if gate in {"manual-fixture", "scope"}:
        if not remaining or remaining[0] not in {"begin", "finalize"}:
            print("ERROR[usage]: begin or finalize is required", file=sys.stderr)
            return 2
        phase = remaining[0]
        remaining = remaining[1:]
    try:
        args = parser_for(gate, phase).parse_args(remaining)
        if gate in {"compliance", "quality"}:
            compliance_or_quality(gate, args)
        elif phase == "begin":
            begin(gate, args)
        else:
            finalize(gate, args)
    except (EvidenceError, OSError, subprocess.SubprocessError, ValueError) as error:
        code = error.code if isinstance(error, EvidenceError) else "final-gate-error"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
