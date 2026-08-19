#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from evidence_common import EvidenceError, JsonValue, read_json, require_mapping, require_string, sha256_file
from validate_evidence_support import validate_document


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


def validate_live_io(receipt: dict[str, JsonValue]) -> None:
    if receipt.get("liveIOObservation") is None:
        raise EvidenceError("missing-live-io-observation", "execution receipt")
    observation_path, _ = receipt_reference(receipt.get("liveIOObservation"), "liveIOObservation")
    observation = require_mapping(read_json(observation_path), "live I/O observation")
    if observation.get("kind") != "live-io-observation":
        raise EvidenceError("forged-live-io-observation", str(observation_path))
    sources = observation.get("sourceReceipts")
    if not isinstance(sources, list) or len(sources) != 2:
        raise EvidenceError("missing-live-io-source", str(observation_path))
    launch_path, launch_hash = receipt_reference(sources[0], "launch receipt")
    exit_path, _ = receipt_reference(sources[1], "exit receipt")
    launch = require_mapping(read_json(launch_path), "launch receipt")
    exit_receipt = require_mapping(read_json(exit_path), "exit receipt")
    process = require_mapping(observation.get("process"), "observed process")
    if launch.get("kind") != "process-launch" or launch.get("child") != process:
        raise EvidenceError("live-io-process-mismatch", str(observation_path))
    if observation.get("executable") != launch.get("executable") or observation.get("executableSHA256") != launch.get("executableSHA256"):
        raise EvidenceError("live-io-binary-mismatch", str(observation_path))
    exit_launch = require_mapping(exit_receipt.get("launchReceipt"), "exit launch receipt")
    if exit_launch.get("path") != str(launch_path) or exit_launch.get("sha256") != launch_hash:
        raise EvidenceError("live-io-process-mismatch", str(exit_path))
    trace_path, _ = receipt_reference(observation.get("trace"), "live I/O trace")
    trace = require_mapping(read_json(trace_path), "live I/O trace")
    if trace.get("kind") != "live-io-trace" or trace.get("process") != process or trace.get("executableSHA256") != observation.get("executableSHA256"):
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


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate task execution receipts and bound live-I/O observations.")
    parser.add_argument("receipts", nargs="+", type=Path)
    parser.add_argument("--schema", default=Path("Tests/ReviewSchemas/execution-receipt.schema.json"), type=Path)
    args = parser.parse_args()
    try:
        for path in args.receipts:
            receipt = require_mapping(read_json(path.resolve(strict=True)), "execution receipt")
            validate_document(args.schema, receipt)
            validate_live_io(receipt)
    except (EvidenceError, OSError) as error:
        code = error.code if isinstance(error, EvidenceError) else "missing-live-io-observation"
        print(f"ERROR[{code}]: {error}", file=sys.stderr)
        return 2
    print("PASS: execution receipts and live-I/O observations validated")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
