#!/usr/bin/env python3
"""Validate tracked verifier transcripts for complex Amiga repair mutation runs."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from build_complex_repair_mutation_runs import DEFAULT_OUTPUT as DEFAULT_MUTATION_RUNS


DEFAULT_TRANSCRIPTS = Path(__file__).with_name("complex_amiga_repair_verifier_transcripts.jsonl")
TRANSCRIPT_SWIFT_TEST = "testComplexAmigaRepairMutationVerifierTranscriptsMatchCurrentVerifierOutput"

REQUIRED_KEYS = {
    "schema_version",
    "record_type",
    "mutation_run_id",
    "family_id",
    "failure_kind",
    "template_id",
    "swift_test",
    "source_identity",
    "before_repair",
    "after_repair",
    "training_use",
}


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def validate_transcripts(mutation_runs: list[dict[str, Any]], transcripts: list[dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    mutation_by_id = {row["mutation_run_id"]: row for row in mutation_runs}
    transcript_ids = [row.get("mutation_run_id") for row in transcripts]

    if len(transcripts) != len(mutation_runs):
        failures.append(f"expected {len(mutation_runs)} transcript rows, found {len(transcripts)}")
    if len(set(transcript_ids)) != len(transcript_ids):
        failures.append("transcript mutation_run_id values must be unique")

    for mutation_id in sorted(set(mutation_by_id) - set(transcript_ids)):
        failures.append(f"{mutation_id}: missing verifier transcript")
    for mutation_id in sorted(set(transcript_ids) - set(mutation_by_id)):
        failures.append(f"{mutation_id}: unknown verifier transcript")

    for row in transcripts:
        row_id = row.get("mutation_run_id", "<missing-id>")
        mutation = mutation_by_id.get(row_id)
        missing = REQUIRED_KEYS - set(row)
        for key in sorted(missing):
            failures.append(f"{row_id}: missing required key '{key}'")
        if mutation is None:
            continue

        if row.get("schema_version") != 1:
            failures.append(f"{row_id}: schema_version must be 1")
        if row.get("record_type") != "repair_mutation_verifier_transcript":
            failures.append(f"{row_id}: record_type must be repair_mutation_verifier_transcript")
        for key in ["family_id", "failure_kind", "template_id"]:
            if row.get(key) != mutation.get(key):
                failures.append(f"{row_id}: {key} does not match mutation run")
        if row.get("swift_test") != TRANSCRIPT_SWIFT_TEST:
            failures.append(f"{row_id}: swift_test must be {TRANSCRIPT_SWIFT_TEST}")

        source_identity = row.get("source_identity")
        if not isinstance(source_identity, dict):
            failures.append(f"{row_id}: source_identity must be an object")
        else:
            if source_identity.get("broken_model_id") != mutation.get("template_id"):
                failures.append(f"{row_id}: broken model id must preserve template id")
            if source_identity.get("repaired_model_id") != mutation.get("template_id"):
                failures.append(f"{row_id}: repaired model id must match template id")
            if source_identity.get("mutation_changed_source") is not True:
                failures.append(f"{row_id}: mutation must change source")
            if source_identity.get("template_identity_preserved") is not True:
                failures.append(f"{row_id}: template identity must be preserved")

        before = row.get("before_repair")
        mutation_before = mutation.get("before_repair_verification", {})
        if not isinstance(before, dict):
            failures.append(f"{row_id}: before_repair must be an object")
        else:
            expected_snippet = mutation_before.get("expected_failure_snippet")
            if before.get("status") != "failed_as_expected":
                failures.append(f"{row_id}: before repair must fail as expected")
            if before.get("verifier_channel") != mutation_before.get("verifier_channel"):
                failures.append(f"{row_id}: verifier channel drifted from mutation run")
            if before.get("expected_failure_snippet") != expected_snippet:
                failures.append(f"{row_id}: expected failure snippet drifted from mutation run")
            failures_list = before.get("failures")
            if not isinstance(failures_list, list) or not failures_list:
                failures.append(f"{row_id}: before repair must include at least one verifier failure")
            elif not all(isinstance(item, str) and item for item in failures_list):
                failures.append(f"{row_id}: before repair failures must be non-empty strings")
            matched_failure = before.get("matched_failure")
            if not isinstance(matched_failure, str) or not matched_failure:
                failures.append(f"{row_id}: before repair needs matched_failure")
            elif isinstance(expected_snippet, str) and expected_snippet not in matched_failure:
                failures.append(f"{row_id}: matched failure does not contain expected snippet")
            if before.get("failure_count") != len(failures_list or []):
                failures.append(f"{row_id}: before failure_count does not match failures array")

        after = row.get("after_repair")
        if not isinstance(after, dict):
            failures.append(f"{row_id}: after_repair must be an object")
        else:
            if after.get("status") != "passed":
                failures.append(f"{row_id}: after repair must pass")
            if after.get("failure_count") != 0:
                failures.append(f"{row_id}: after repair failure_count must be 0")
            if after.get("failures") != []:
                failures.append(f"{row_id}: after repair failures must be empty")

        training_use = row.get("training_use")
        if not isinstance(training_use, dict):
            failures.append(f"{row_id}: training_use must be an object")
        elif training_use.get("preference_signal") != "fail_before_pass_after_real_verifier_output":
            failures.append(f"{row_id}: transcript preference signal is invalid")

    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mutation-runs", default=str(DEFAULT_MUTATION_RUNS))
    parser.add_argument("--transcripts", default=str(DEFAULT_TRANSCRIPTS))
    args = parser.parse_args()

    mutation_path = Path(args.mutation_runs)
    transcript_path = Path(args.transcripts)
    if not mutation_path.exists():
        print(f"{mutation_path}: missing mutation-run artifact", file=sys.stderr)
        return 1
    if not transcript_path.exists():
        print(f"{transcript_path}: missing verifier transcript artifact", file=sys.stderr)
        return 1

    failures = validate_transcripts(load_jsonl(mutation_path), load_jsonl(transcript_path))
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    print(f"Validated {len(load_jsonl(transcript_path))} complex Amiga repair verifier transcripts.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
