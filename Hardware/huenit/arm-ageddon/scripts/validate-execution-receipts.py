#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, read_json, require_mapping, require_string, sha256_file
from validate_evidence_support import validate_document


@dataclass(frozen=True, slots=True)
class SupervisedRuntime:
    launch: tuple[Path, str]
    exit_receipt: tuple[Path, str]
    trace: tuple[Path, str]
    observation: tuple[Path, str]
    pre_exec_child: dict[str, JsonValue]
    post_exec_child: dict[str, JsonValue]
    observed_executable: Path
    observed_executable_sha256: str


def require_int(value: JsonValue | None, label: str) -> int:
    if not isinstance(value, int) or isinstance(value, bool):
        raise EvidenceError("invalid-integer", label)
    return value


def receipt_reference(value: JsonValue | None, label: str) -> tuple[Path, str]:
    reference = require_mapping(value, label)
    path = Path(require_string(reference.get("path"), f"{label}.path")).resolve(strict=True)
    digest = require_string(reference.get("sha256"), f"{label}.sha256")
    if sha256_file(path) != digest:
        raise EvidenceError("live-io-hash-mismatch", str(path))
    return path, digest


def validate_live_io(receipt: dict[str, JsonValue], runtime: SupervisedRuntime) -> None:
    if receipt.get("liveIOObservation") is None:
        raise EvidenceError("missing-live-io-observation", "execution receipt")
    observation_path, observation_hash = receipt_reference(receipt.get("liveIOObservation"), "liveIOObservation")
    observation = require_mapping(read_json(observation_path), "live I/O observation")
    if observation.get("kind") != "live-io-observation":
        raise EvidenceError("forged-live-io-observation", str(observation_path))
    sources = observation.get("sourceReceipts")
    if not isinstance(sources, list) or len(sources) != 2:
        raise EvidenceError("missing-live-io-source", str(observation_path))
    launch_path, launch_hash = receipt_reference(sources[0], "launch receipt")
    exit_path, exit_hash = receipt_reference(sources[1], "exit receipt")
    launch = require_mapping(read_json(launch_path), "launch receipt")
    exit_receipt = require_mapping(read_json(exit_path), "exit receipt")
    process = require_mapping(observation.get("process"), "observed process")
    if launch.get("kind") != "process-launch" or launch.get("child") != runtime.pre_exec_child:
        raise EvidenceError("live-io-process-mismatch", str(observation_path))
    intended_command = Path(require_string(launch.get("intendedExecutable"), "intended executable"))
    intended_hash = require_string(launch.get("intendedExecutableSHA256"), "intended executable hash")
    try:
        intended_executable = intended_command.resolve(strict=True)
    except OSError as error:
        raise EvidenceError("live-io-command-mismatch", str(launch_path)) from error
    if intended_executable != Path(require_string(launch.get("executable"), "executable")).resolve(strict=True) or sha256_file(intended_executable) != intended_hash:
        raise EvidenceError("live-io-binary-mismatch", str(launch_path))
    exit_post_exec = require_mapping(exit_receipt.get("postExecChild"), "post-exec child")
    if exit_post_exec != runtime.post_exec_child or process != runtime.post_exec_child:
        raise EvidenceError("live-io-process-mismatch", str(observation_path))
    observed_executable = runtime.observed_executable.resolve(strict=True)
    if observation.get("executable") != str(observed_executable) or observation.get("executableSHA256") != runtime.observed_executable_sha256 or exit_receipt.get("observedExecutable") != str(observed_executable) or exit_receipt.get("observedExecutableSHA256") != runtime.observed_executable_sha256 or sha256_file(observed_executable) != runtime.observed_executable_sha256:
        raise EvidenceError("live-io-binary-mismatch", str(observation_path))
    exit_launch = require_mapping(exit_receipt.get("launchReceipt"), "exit launch receipt")
    if exit_launch.get("path") != str(launch_path) or exit_launch.get("sha256") != launch_hash:
        raise EvidenceError("live-io-process-mismatch", str(exit_path))
    trace_path, trace_hash = receipt_reference(observation.get("trace"), "live I/O trace")
    trace = require_mapping(read_json(trace_path), "live I/O trace")
    if trace.get("kind") != "live-io-trace" or trace.get("process") != runtime.post_exec_child or trace.get("executableSHA256") != observation.get("executableSHA256"):
        raise EvidenceError("forged-live-io-observation", str(trace_path))
    if require_int(trace.get("sampleCount"), "sampleCount") < 1:
        raise EvidenceError("empty-live-io-observation", str(trace_path))
    observation_start = require_int(observation.get("observationStartMonotonicNs"), "observation start")
    observation_end = require_int(observation.get("observationEndMonotonicNs"), "observation end")
    if observation_start != require_int(trace.get("observationStartMonotonicNs"), "trace start") or observation_end != require_int(trace.get("observationEndMonotonicNs"), "trace end"):
        raise EvidenceError("live-io-window-mismatch", str(observation_path))
    receipt_start = require_int(receipt.get("startMonotonicNs"), "receipt start")
    receipt_end = require_int(receipt.get("endMonotonicNs"), "receipt end")
    if observation_start > receipt_start or observation_end < receipt_end or receipt_start > receipt_end:
        raise EvidenceError("live-io-window-mismatch", str(observation_path))
    events = trace.get("events")
    if not isinstance(events, list):
        raise EvidenceError("forged-live-io-observation", str(trace_path))
    device_opens = 0
    serial_writes = 0
    for raw_event in events:
        event = require_mapping(raw_event, "live I/O event")
        event_time = require_int(event.get("monotonicNs"), "event time")
        if not observation_start <= event_time <= observation_end:
            raise EvidenceError("live-io-window-mismatch", str(trace_path))
        kind = event.get("kind")
        device_opens += kind == "device-open"
        serial_writes += kind == "serial-write"
    if observation.get("deviceOpenCount") != device_opens or observation.get("serialWriteCount") != serial_writes:
        raise EvidenceError("live-io-counter-mismatch", str(observation_path))
    if receipt.get("deviceOpenCount") != device_opens or receipt.get("serialWriteCount") != serial_writes:
        raise EvidenceError("live-io-counter-mismatch", "execution receipt")
    observed_runtime = ((launch_path, launch_hash), (exit_path, exit_hash), (trace_path, trace_hash), (observation_path, observation_hash))
    expected_runtime = (runtime.launch, runtime.exit_receipt, runtime.trace, runtime.observation)
    if observed_runtime != expected_runtime:
        raise EvidenceError("producer-origin-mismatch", str(observation_path))


def validate_receipt(path: Path, schema: Path, runtime: SupervisedRuntime | None = None) -> None:
    if runtime is None:
        raise EvidenceError("missing-producer-origin-proof", "receipt requires supervisor-held runtime state")
    receipt = require_mapping(read_json(path.resolve(strict=True)), "execution receipt")
    validate_document(schema, receipt)
    validate_live_io(receipt, runtime)


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate task execution receipts and bound live-I/O observations.")
    parser.add_argument("receipts", nargs="+", type=Path)
    parser.add_argument("--schema", default=Path("Tests/ReviewSchemas/execution-receipt.schema.json"), type=Path)
    args = parser.parse_args()
    try:
        for path in args.receipts:
            validate_receipt(path, args.schema)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "missing-live-io-observation"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: execution receipts and live-I/O observations validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
