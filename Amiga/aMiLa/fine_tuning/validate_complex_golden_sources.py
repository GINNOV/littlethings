#!/usr/bin/env python3
"""Validate complex Amiga golden-source and follow-up replay-gap artifacts."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from validate_complex_benchmark_corpus import DEFAULT_CORPUS, validate_corpus


DEFAULT_GOLDEN = Path(__file__).with_name("complex_amiga_golden_sources.jsonl")
DEFAULT_GAPS = Path(__file__).with_name("complex_amiga_followup_replay_gaps.jsonl")

REQUIRED_GOLDEN_KEYS = {
    "schema_version",
    "record_type",
    "golden_id",
    "family_id",
    "family_title",
    "stage",
    "template_id",
    "domain_tags",
    "messages",
    "assistant_content",
    "source_metrics",
    "verification",
    "training_use",
}

REQUIRED_GAP_KEYS = {
    "schema_version",
    "record_type",
    "gap_id",
    "family_id",
    "family_title",
    "failed_follow_up",
    "failed_follow_up_index",
    "completed_follow_ups",
    "status",
    "reasons",
    "required_resolution",
}


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def non_empty_string(value: Any) -> bool:
    return isinstance(value, str) and bool(value.strip())


def validate_golden_sources(
    corpus: dict[str, Any],
    golden_rows: list[dict[str, Any]],
    gap_rows: list[dict[str, Any]],
) -> list[str]:
    failures: list[str] = []
    families = {family["id"]: family for family in corpus["benchmark_families"]}
    golden_ids = [row.get("golden_id") for row in golden_rows]
    gap_family_ids = {row.get("family_id") for row in gap_rows}

    if len(set(golden_ids)) != len(golden_ids):
        failures.append("golden source ids must be unique")
    if len({row.get("gap_id") for row in gap_rows}) != len(gap_rows):
        failures.append("follow-up replay gap ids must be unique")

    first_shot_families = {
        row.get("family_id")
        for row in golden_rows
        if row.get("stage") == "first_shot_verified_source"
    }
    missing_first_shot = set(families) - first_shot_families
    for family_id in sorted(missing_first_shot):
        failures.append(f"{family_id}: missing first-shot golden source")

    terminal_families = {
        row.get("family_id")
        for row in golden_rows
        if row.get("stage") == "multi_turn_terminal_source"
    }
    unresolved_terminal = set(families) - terminal_families
    for family_id in sorted(unresolved_terminal - gap_family_ids):
        failures.append(f"{family_id}: missing terminal golden source and missing follow-up replay gap")
    for family_id in sorted(terminal_families & gap_family_ids):
        failures.append(f"{family_id}: cannot have both terminal golden source and follow-up replay gap")

    for row in golden_rows:
        row_id = row.get("golden_id", "<missing-id>")
        missing = REQUIRED_GOLDEN_KEYS - set(row)
        for key in sorted(missing):
            failures.append(f"{row_id}: missing required key '{key}'")
        family = families.get(row.get("family_id"))
        if family is None:
            failures.append(f"{row_id}: unknown family id {row.get('family_id')!r}")
            continue
        if row.get("schema_version") != 1:
            failures.append(f"{row_id}: schema_version must be 1")
        if row.get("record_type") != "complex_amiga_golden_source":
            failures.append(f"{row_id}: record_type must be complex_amiga_golden_source")
        if row.get("family_title") != family["title"]:
            failures.append(f"{row_id}: family title drifted from corpus")
        if row.get("domain_tags") != family["domain_tags"]:
            failures.append(f"{row_id}: domain tags drifted from corpus")
        if row.get("stage") not in {"first_shot_verified_source", "multi_turn_terminal_source"}:
            failures.append(f"{row_id}: unsupported stage {row.get('stage')!r}")
        if not non_empty_string(row.get("assistant_content")):
            failures.append(f"{row_id}: assistant_content must contain source")
        messages = row.get("messages")
        if not isinstance(messages, list) or len(messages) < 2:
            failures.append(f"{row_id}: messages must contain system and user turns")
        elif row.get("stage") == "multi_turn_terminal_source":
            expected_turns = 2 + len(family["multi_turn_follow_ups"])
            if len(messages) != expected_turns:
                failures.append(f"{row_id}: terminal messages should include the full declared follow-up chain")

        metrics = row.get("source_metrics")
        if not isinstance(metrics, dict):
            failures.append(f"{row_id}: source_metrics must be an object")
        else:
            if not isinstance(metrics.get("line_count"), int) or metrics["line_count"] <= 0:
                failures.append(f"{row_id}: line_count must be positive")
            if not isinstance(metrics.get("byte_count"), int) or metrics["byte_count"] <= 0:
                failures.append(f"{row_id}: byte_count must be positive")

        verification = row.get("verification")
        if not isinstance(verification, dict):
            failures.append(f"{row_id}: verification must be an object")
        else:
            for gate in ["source_verifier", "semantic_verifier", "runtime_contract"]:
                gate_result = verification.get(gate)
                if not isinstance(gate_result, dict):
                    failures.append(f"{row_id}: missing {gate} result")
                    continue
                if gate_result.get("passed") is not True:
                    failures.append(f"{row_id}: {gate} must pass")
                if gate_result.get("failures") != []:
                    failures.append(f"{row_id}: {gate} failures must be empty")

        training_use = row.get("training_use")
        if not isinstance(training_use, dict):
            failures.append(f"{row_id}: training_use must be an object")
        elif training_use.get("distillation_target") != "structured_model_to_verified_asm":
            failures.append(f"{row_id}: distillation target is invalid")

    for row in gap_rows:
        row_id = row.get("gap_id", "<missing-gap-id>")
        missing = REQUIRED_GAP_KEYS - set(row)
        for key in sorted(missing):
            failures.append(f"{row_id}: missing required key '{key}'")
        family = families.get(row.get("family_id"))
        if family is None:
            failures.append(f"{row_id}: unknown family id {row.get('family_id')!r}")
            continue
        if row.get("schema_version") != 1:
            failures.append(f"{row_id}: schema_version must be 1")
        if row.get("record_type") != "complex_amiga_followup_replay_gap":
            failures.append(f"{row_id}: record_type must be complex_amiga_followup_replay_gap")
        index = row.get("failed_follow_up_index")
        follow_ups = family["multi_turn_follow_ups"]
        if not isinstance(index, int) or index < 1 or index > len(follow_ups):
            failures.append(f"{row_id}: failed_follow_up_index out of range")
        elif row.get("failed_follow_up") != follow_ups[index - 1]:
            failures.append(f"{row_id}: failed follow-up does not match corpus prompt at index")
        completed = row.get("completed_follow_ups")
        if not isinstance(completed, list):
            failures.append(f"{row_id}: completed_follow_ups must be a list")
        elif isinstance(index, int) and completed != follow_ups[: max(index - 1, 0)]:
            failures.append(f"{row_id}: completed follow-ups do not match corpus prefix")
        if row.get("status") not in {"not_recognized", "rejected"}:
            failures.append(f"{row_id}: unsupported gap status {row.get('status')!r}")
        if not isinstance(row.get("reasons"), list) or not row["reasons"]:
            failures.append(f"{row_id}: gap needs reasons")

    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(DEFAULT_CORPUS))
    parser.add_argument("--golden", default=str(DEFAULT_GOLDEN))
    parser.add_argument("--gaps", default=str(DEFAULT_GAPS))
    args = parser.parse_args()

    corpus = json.loads(Path(args.corpus).read_text(encoding="utf-8"))
    corpus_failures = validate_corpus(corpus)
    if corpus_failures:
        for failure in corpus_failures:
            print(failure, file=sys.stderr)
        return 1

    failures = validate_golden_sources(corpus, load_jsonl(Path(args.golden)), load_jsonl(Path(args.gaps)))
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    print(
        f"Validated {len(load_jsonl(Path(args.golden)))} complex Amiga golden sources "
        f"and {len(load_jsonl(Path(args.gaps)))} follow-up replay gaps."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
