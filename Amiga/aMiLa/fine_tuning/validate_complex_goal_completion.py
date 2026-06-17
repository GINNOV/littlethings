#!/usr/bin/env python3
"""Audit the complex Amiga corpus against the full code-gym goal.

This validator is intentionally cross-artifact. The lower-level validators prove
individual files are well-formed; this one proves the assembled corpus still
matches the original execution-grounded benchmark objective.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from build_complex_benchmark_records import DEFAULT_OUTPUT as DEFAULT_RECORDS
from build_complex_repair_execution_matrix import DEFAULT_OUTPUT as DEFAULT_EXECUTION
from build_complex_repair_loop_examples import DEFAULT_OUTPUT as DEFAULT_REPAIR_EXAMPLES
from build_complex_repair_mutation_runs import DEFAULT_OUTPUT as DEFAULT_MUTATIONS
from build_complex_repair_proofs import DEFAULT_OUTPUT as DEFAULT_REPAIR_PROOFS
from validate_complex_benchmark_corpus import DEFAULT_CORPUS, REQUIRED_GATES, validate_corpus
from validate_complex_golden_sources import DEFAULT_GAPS, DEFAULT_GOLDEN, validate_golden_sources
from validate_complex_repair_verifier_transcripts import DEFAULT_TRANSCRIPTS


EXPECTED_FAMILY_IDS = {
    "mod_player_controls_complex",
    "double_buffered_bitplane_sprite_copper",
    "blitter_bob_collision_bounds",
    "copper_runtime_raster_validation",
    "mouse_sprite_multiplex",
    "intuition_window_tool",
    "clean_takeover_restore",
}

EXPECTED_FAMILY_TAGS = {
    "mod_player_controls_complex": {"audio", "paula", "controls"},
    "double_buffered_bitplane_sprite_copper": {"bitplane", "double-buffering", "sprite", "copper"},
    "blitter_bob_collision_bounds": {"blitter", "collision", "input"},
    "copper_runtime_raster_validation": {"copper", "raster", "runtime-frame"},
    "mouse_sprite_multiplex": {"sprite", "mouse", "multiplex"},
    "intuition_window_tool": {"intuition", "exec", "graphics"},
    "clean_takeover_restore": {"clean-takeover", "dma", "restore"},
}

REQUIRED_RECORD_TYPES = {
    "first_shot_benchmark",
    "multi_turn_preservation_chain",
    "rejected_turn_no_mutation",
    "repair_seed",
    "preference_ranking",
}

REQUIRED_TRAINING_PREFERENCE = ["passes_all_gates", "compiles_only", "plausible_but_unverified"]

REQUIRED_RUNTIME_ARTIFACTS = {
    "bootable_adf",
    "raw_frame",
    "manifest_json",
}

EVIDENCE_ARTIFACTS = {
    "adf_inspection_json",
    "boot_state_register_trace",
    "frame_analysis_json",
    "retroshell_transcript",
    "template_runtime_evidence_json",
}


def load_json(path: Path) -> dict[str, Any]:
    return json.loads(path.read_text(encoding="utf-8"))


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def by_family(rows: list[dict[str, Any]]) -> dict[str, list[dict[str, Any]]]:
    grouped: dict[str, list[dict[str, Any]]] = {}
    for row in rows:
        grouped.setdefault(str(row.get("family_id", "")), []).append(row)
    return grouped


def contains_ordered_subsequence(values: Any, expected: list[str]) -> bool:
    if not isinstance(values, list):
        return False
    cursor = 0
    for value in values:
        if cursor < len(expected) and value == expected[cursor]:
            cursor += 1
    return cursor == len(expected)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(DEFAULT_CORPUS))
    parser.add_argument("--records", default=str(DEFAULT_RECORDS))
    parser.add_argument("--repair-examples", default=str(DEFAULT_REPAIR_EXAMPLES))
    parser.add_argument("--repair-proofs", default=str(DEFAULT_REPAIR_PROOFS))
    parser.add_argument("--execution", default=str(DEFAULT_EXECUTION))
    parser.add_argument("--mutations", default=str(DEFAULT_MUTATIONS))
    parser.add_argument("--transcripts", default=str(DEFAULT_TRANSCRIPTS))
    parser.add_argument("--golden", default=str(DEFAULT_GOLDEN))
    parser.add_argument("--gaps", default=str(DEFAULT_GAPS))
    args = parser.parse_args()

    corpus = load_json(Path(args.corpus))
    records = load_jsonl(Path(args.records))
    repair_examples = load_jsonl(Path(args.repair_examples))
    repair_proofs = load_jsonl(Path(args.repair_proofs))
    execution_rows = load_jsonl(Path(args.execution))
    mutation_rows = load_jsonl(Path(args.mutations))
    transcript_rows = load_jsonl(Path(args.transcripts))
    golden_rows = load_jsonl(Path(args.golden))
    gap_rows = load_jsonl(Path(args.gaps))

    failures: list[str] = []
    failures.extend(validate_corpus(corpus))
    failures.extend(validate_golden_sources(corpus, golden_rows, gap_rows))

    families = corpus.get("benchmark_families", [])
    family_by_id = {family.get("id"): family for family in families if isinstance(family, dict)}
    family_ids = set(family_by_id)
    if family_ids != EXPECTED_FAMILY_IDS:
        failures.append(f"family set mismatch: expected {sorted(EXPECTED_FAMILY_IDS)}, found {sorted(family_ids)}")
    if not 5 <= len(families) <= 8:
        failures.append(f"expected 5-8 representative families, found {len(families)}")
    if set(corpus.get("required_gates", [])) != REQUIRED_GATES:
        failures.append("corpus required gates do not match the full code-gym gate set")

    records_by_family = by_family(records)
    examples_by_family = by_family(repair_examples)
    proofs_by_family = by_family(repair_proofs)
    execution_by_family = by_family(execution_rows)
    mutations_by_family = by_family(mutation_rows)
    golden_by_family = by_family(golden_rows)

    expected_repair_seed_total = 0
    for family_id, family in sorted(family_by_id.items()):
        if not isinstance(family_id, str):
            continue
        expected_tags = EXPECTED_FAMILY_TAGS.get(family_id, set())
        tags = set(family.get("domain_tags", []))
        missing_tags = expected_tags - tags
        for tag in sorted(missing_tags):
            failures.append(f"{family_id}: missing expected domain tag {tag!r}")

        follow_ups = family.get("multi_turn_follow_ups", [])
        rejected_turns = family.get("rejected_turns", [])
        repair_seeds = family.get("repair_seeds", [])
        expected_repair_seed_total += len(repair_seeds)
        if len(follow_ups) < 3:
            failures.append(f"{family_id}: needs at least 3 multi-turn follow-ups")
        if len(rejected_turns) < 3:
            failures.append(f"{family_id}: needs at least 3 rejected-turn no-mutation examples")
        if len(repair_seeds) < 2:
            failures.append(f"{family_id}: needs at least 2 repair seeds")

        proof = family.get("executable_proof", {})
        verified_gates = set(proof.get("verified_gates", []))
        missing_gates = REQUIRED_GATES - verified_gates
        for gate in sorted(missing_gates):
            failures.append(f"{family_id}: executable proof missing gate {gate!r}")
        proof_tests = proof.get("proof_tests", [])
        if not any("Compiles" in test for test in proof_tests):
            failures.append(f"{family_id}: proof tests must include a VASM compile proof")
        if not any("ADF" in test or "Bootable" in test for test in proof_tests):
            failures.append(f"{family_id}: proof tests must include a bootable ADF proof")

        runtime_contract = proof.get("runtime_evidence_contract")
        if not isinstance(runtime_contract, dict):
            failures.append(f"{family_id}: missing runtime evidence contract")
        else:
            artifacts = set(runtime_contract.get("required_artifacts", []))
            for artifact in sorted(REQUIRED_RUNTIME_ARTIFACTS - artifacts):
                failures.append(f"{family_id}: runtime contract missing required artifact {artifact!r}")
            if not artifacts & EVIDENCE_ARTIFACTS:
                failures.append(f"{family_id}: runtime contract lacks trace/screenshot/register evidence artifacts")
            for key in ["source_proof_test", "negative_proof_test", "emulator_artifact_promotion_test"]:
                if not runtime_contract.get(key):
                    failures.append(f"{family_id}: runtime contract missing {key}")

        family_records = records_by_family.get(family_id, [])
        record_types = {record.get("record_type") for record in family_records}
        missing_record_types = REQUIRED_RECORD_TYPES - record_types
        for record_type in sorted(missing_record_types):
            failures.append(f"{family_id}: missing benchmark record type {record_type!r}")
        if not any(record.get("record_type") == "preference_ranking" for record in family_records):
            failures.append(f"{family_id}: missing preference ranking record")
        if len([record for record in family_records if record.get("record_type") == "rejected_turn_no_mutation"]) != len(rejected_turns):
            failures.append(f"{family_id}: rejected-turn record count does not match corpus")
        if len([record for record in family_records if record.get("record_type") == "repair_seed"]) != len(repair_seeds):
            failures.append(f"{family_id}: repair-seed record count does not match corpus")

        if len(examples_by_family.get(family_id, [])) != len(repair_seeds):
            failures.append(f"{family_id}: repair example count does not match repair seed count")
        if len(proofs_by_family.get(family_id, [])) != len(repair_seeds):
            failures.append(f"{family_id}: repair proof count does not match repair seed count")
        if len(execution_by_family.get(family_id, [])) != len(repair_seeds):
            failures.append(f"{family_id}: repair execution count does not match repair seed count")
        if len(mutations_by_family.get(family_id, [])) != len(repair_seeds):
            failures.append(f"{family_id}: mutation-run count does not match repair seed count")

        stages = {row.get("stage") for row in golden_by_family.get(family_id, [])}
        if {"first_shot_verified_source", "multi_turn_terminal_source"} - stages:
            failures.append(f"{family_id}: needs first-shot and terminal multi-turn golden sources")

    if gap_rows:
        failures.append(f"expected zero unresolved follow-up replay gaps, found {len(gap_rows)}")

    for row in repair_proofs + execution_rows + mutation_rows:
        training = row.get("training_use", {})
        if not contains_ordered_subsequence(training.get("preference_order"), REQUIRED_TRAINING_PREFERENCE):
            failures.append(f"{row.get('proof_id') or row.get('execution_id') or row.get('mutation_run_id')}: invalid training preference order")

    if len(repair_examples) != expected_repair_seed_total:
        failures.append(f"expected {expected_repair_seed_total} repair examples, found {len(repair_examples)}")
    if len(repair_proofs) != expected_repair_seed_total:
        failures.append(f"expected {expected_repair_seed_total} repair proofs, found {len(repair_proofs)}")
    if len(execution_rows) != expected_repair_seed_total:
        failures.append(f"expected {expected_repair_seed_total} execution rows, found {len(execution_rows)}")
    if len(mutation_rows) != expected_repair_seed_total:
        failures.append(f"expected {expected_repair_seed_total} mutation rows, found {len(mutation_rows)}")
    if len(transcript_rows) != expected_repair_seed_total:
        failures.append(f"expected {expected_repair_seed_total} verifier transcripts, found {len(transcript_rows)}")

    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    print(
        "Complex Amiga goal audit passed: "
        f"{len(families)} families, {len(records)} records, "
        f"{len(golden_rows)} golden sources, {expected_repair_seed_total} repair seeds, "
        f"{len(gap_rows)} replay gaps."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
