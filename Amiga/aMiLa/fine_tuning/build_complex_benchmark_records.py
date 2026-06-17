#!/usr/bin/env python3
"""Build JSONL benchmark, negative, repair, and preference records from the complex Amiga corpus."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from validate_complex_benchmark_corpus import DEFAULT_CORPUS, validate_corpus


DEFAULT_OUTPUT = Path(__file__).with_name("complex_amiga_benchmark_records.jsonl")

SYSTEM_PROMPT = (
    "You are AntigravityAmiga, an execution-grounded Amiga 68000 code producer. "
    "Use a structured AmigaProgramModel, preserve multi-turn state, reject unsafe "
    "edits without mutation, and only claim success when semantic, compile, ADF, "
    "and runtime-observation gates are satisfied."
)


def normalized_id(value: str) -> str:
    return value.strip().lower().replace(" ", "_").replace("/", "_")


def make_base_record(corpus: dict[str, Any], family: dict[str, Any], record_type: str, suffix: str) -> dict[str, Any]:
    record = {
        "schema_version": 1,
        "corpus_id": corpus["corpus_id"],
        "record_id": f"{family['id']}::{suffix}",
        "family_id": family["id"],
        "family_title": family["title"],
        "record_type": record_type,
        "domain_tags": family["domain_tags"],
        "promotion_status": family["promotion_status"],
        "required_gates": corpus["required_gates"],
    }
    if "executable_proof" in family:
        record["executable_proof"] = family["executable_proof"]
    return record


def first_shot_record(corpus: dict[str, Any], family: dict[str, Any]) -> dict[str, Any]:
    record = make_base_record(corpus, family, "first_shot_benchmark", "first_shot")
    record.update(
        {
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": family["first_shot_prompt"]},
            ],
            "expected_structured_model": family["structured_model_requirements"],
            "expected_runtime_evidence": family["runtime_evidence"],
            "evaluation_contract": {
                "requires_generated_asm": True,
                "requires_semantic_verifier": True,
                "requires_vasm_compile": True,
                "requires_bootable_adf": True,
                "requires_runtime_evidence": True,
            },
        }
    )
    return record


def multi_turn_record(corpus: dict[str, Any], family: dict[str, Any]) -> dict[str, Any]:
    record = make_base_record(corpus, family, "multi_turn_preservation_chain", "multi_turn_chain")
    messages = [{"role": "system", "content": SYSTEM_PROMPT}, {"role": "user", "content": family["first_shot_prompt"]}]
    messages.extend({"role": "user", "content": follow_up} for follow_up in family["multi_turn_follow_ups"])
    record.update(
        {
            "messages": messages,
            "follow_up_count": len(family["multi_turn_follow_ups"]),
            "preservation_invariants": [
                "Every accepted follow-up preserves the embedded AmigaProgramModel identity.",
                "Existing controls, routines, state variables, and chip-data labels survive unless the follow-up explicitly changes them.",
                "The final artifact still passes source verification, semantic verification, VASM compile, ADF generation, and runtime evidence gates.",
            ],
            "expected_runtime_evidence": family["runtime_evidence"],
        }
    )
    return record


def rejected_turn_record(corpus: dict[str, Any], family: dict[str, Any], prompt: str, index: int) -> dict[str, Any]:
    record = make_base_record(corpus, family, "rejected_turn_no_mutation", f"reject_{index}_{normalized_id(prompt)[:48]}")
    record.update(
        {
            "setup_messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": family["first_shot_prompt"]},
            ],
            "rejected_prompt": prompt,
            "expected_outcome": "reject_without_source_or_model_mutation",
            "post_rejection_required_gates": corpus["required_gates"],
            "diagnostic_contract": [
                "The failure reason is specific enough to repair the request.",
                "The editor/source state before and after the rejected turn is byte-identical.",
                "The next compatible follow-up continues from the pre-rejection state.",
            ],
        }
    )
    return record


def repair_seed_record(corpus: dict[str, Any], family: dict[str, Any], seed: dict[str, Any]) -> dict[str, Any]:
    record = make_base_record(corpus, family, "repair_seed", f"repair_{seed['failure_kind']}")
    executable_proof = family.get("executable_proof", {})
    verified_repair_seeds = executable_proof.get("verified_repair_seeds", [])
    runtime_contract = executable_proof.get("runtime_evidence_contract")
    proof_tests = executable_proof.get("proof_tests", [])
    record.update(
        {
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {
                    "role": "user",
                    "content": (
                        "Repair this verified Amiga 68k family artifact without broad rewrites.\n\n"
                        f"Family: {family['title']}\n"
                        f"Original prompt: {family['first_shot_prompt']}\n"
                        f"Broken variant strategy: {seed['broken_variant_strategy']}\n"
                        f"Validator diagnostic: {seed['expected_diagnostic']}\n"
                        f"Required repair: {seed['target_repair']}"
                    ),
                },
            ],
            "failure_kind": seed["failure_kind"],
            "broken_variant_strategy": seed["broken_variant_strategy"],
            "expected_diagnostic": seed["expected_diagnostic"],
            "diagnostic_proof_test": seed["diagnostic_proof_test"],
            "target_repair": seed["target_repair"],
            "repair_constraints": [
                "Patch only the verified failure.",
                "Preserve the structured model identity and existing supported behavior.",
                "The repaired artifact must pass the full family gate set.",
            ],
            "repair_attempt_contract": {
                "broken_variant": {
                    "failure_kind": seed["failure_kind"],
                    "strategy": seed["broken_variant_strategy"],
                    "expected_diagnostic": seed["expected_diagnostic"],
                    "diagnostic_proof_test": seed["diagnostic_proof_test"],
                    "must_fail_before_repair": True,
                },
                "repair_scope": {
                    "target_repair": seed["target_repair"],
                    "allowed_change": "narrow_patch_only",
                    "forbidden_changes": [
                        "replace the whole program when a local patch can repair the verified failure",
                        "remove or rewrite the embedded AmigaProgramModel identity",
                        "drop existing controls, routines, data labels, or runtime evidence that are unrelated to the failure",
                    ],
                },
                "post_repair_verification": {
                    "required_gates": corpus["required_gates"],
                    "runtime_evidence_contract": runtime_contract,
                    "must_remain_in_verified_repair_seeds": seed["failure_kind"] in verified_repair_seeds,
                    "family_proof_tests": proof_tests,
                },
                "training_use": {
                    "negative_example": "broken variant must trigger the expected diagnostic before repair",
                    "positive_example": "repaired variant must preserve the family behavior and pass every required gate",
                    "preference_order": ["passes_all_gates", "compiles_only", "plausible_but_unverified"],
                },
            },
        }
    )
    return record


def preference_record(corpus: dict[str, Any], family: dict[str, Any]) -> dict[str, Any]:
    record = make_base_record(corpus, family, "preference_ranking", "preference")
    record.update(
        {
            "prompt": family["first_shot_prompt"],
            "ranking": [
                {
                    "label": "best",
                    "description": "Passes structured model, source verifier, semantic verifier, VASM compile, bootable ADF, runtime evidence, multi-turn preservation, rejected-turn no-mutation, and repair-loop checks.",
                },
                {
                    "label": "acceptable_intermediate",
                    "description": "Compiles and may generate an ADF, but lacks complete runtime evidence or multi-turn/rejection proof.",
                },
                {
                    "label": "reject",
                    "description": "Looks plausible but fails any owned-family source contract, semantic check, compile gate, ADF gate, runtime evidence gate, or mutates state after a rejected turn.",
                },
            ],
        }
    )
    return record


def build_records(corpus: dict[str, Any]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for family in corpus["benchmark_families"]:
        records.append(first_shot_record(corpus, family))
        records.append(multi_turn_record(corpus, family))
        for index, prompt in enumerate(family["rejected_turns"], start=1):
            records.append(rejected_turn_record(corpus, family, prompt, index))
        for seed in family["repair_seeds"]:
            records.append(repair_seed_record(corpus, family, seed))
        records.append(preference_record(corpus, family))
    return records


def validate_records(corpus: dict[str, Any], records: list[dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    record_ids = [record.get("record_id", "") for record in records]
    if len(set(record_ids)) != len(record_ids):
        failures.append("record ids must be unique")

    by_family: dict[str, list[dict[str, Any]]] = {}
    for record in records:
        by_family.setdefault(record.get("family_id", ""), []).append(record)
        if record.get("required_gates") != corpus["required_gates"]:
            failures.append(f"{record.get('record_id')}: required_gates do not match corpus")
        if not record.get("domain_tags"):
            failures.append(f"{record.get('record_id')}: missing domain_tags")
        executable_proof = record.get("executable_proof")
        if executable_proof is not None:
            if not isinstance(executable_proof, dict) or not executable_proof.get("template_id"):
                failures.append(f"{record.get('record_id')}: malformed executable_proof")
        if record.get("record_type") == "repair_seed":
            failures.extend(validate_repair_record(record, corpus))

    for family in corpus["benchmark_families"]:
        family_records = by_family.get(family["id"], [])
        expected_count = 1 + 1 + len(family["rejected_turns"]) + len(family["repair_seeds"]) + 1
        if len(family_records) != expected_count:
            failures.append(f"{family['id']}: expected {expected_count} records, found {len(family_records)}")

        type_counts: dict[str, int] = {}
        for record in family_records:
            type_counts[record["record_type"]] = type_counts.get(record["record_type"], 0) + 1
        expected_type_counts = {
            "first_shot_benchmark": 1,
            "multi_turn_preservation_chain": 1,
            "rejected_turn_no_mutation": len(family["rejected_turns"]),
            "repair_seed": len(family["repair_seeds"]),
            "preference_ranking": 1,
        }
        if type_counts != expected_type_counts:
            failures.append(f"{family['id']}: record type counts mismatch: {type_counts}")

    return failures


def validate_repair_record(record: dict[str, Any], corpus: dict[str, Any]) -> list[str]:
    record_id = record.get("record_id")
    failures: list[str] = []
    contract = record.get("repair_attempt_contract")
    if not isinstance(contract, dict):
        return [f"{record_id}: missing repair_attempt_contract"]

    broken_variant = contract.get("broken_variant")
    repair_scope = contract.get("repair_scope")
    post_repair = contract.get("post_repair_verification")
    training_use = contract.get("training_use")
    if not isinstance(broken_variant, dict):
        failures.append(f"{record_id}: malformed repair_attempt_contract.broken_variant")
    else:
        if broken_variant.get("failure_kind") != record.get("failure_kind"):
            failures.append(f"{record_id}: broken_variant failure_kind does not match record")
        if broken_variant.get("strategy") != record.get("broken_variant_strategy"):
            failures.append(f"{record_id}: broken_variant strategy does not match record")
        if broken_variant.get("expected_diagnostic") != record.get("expected_diagnostic"):
            failures.append(f"{record_id}: broken_variant expected_diagnostic does not match record")
        if broken_variant.get("must_fail_before_repair") is not True:
            failures.append(f"{record_id}: broken variant must require pre-repair failure")

    if not isinstance(repair_scope, dict):
        failures.append(f"{record_id}: malformed repair_attempt_contract.repair_scope")
    else:
        if repair_scope.get("target_repair") != record.get("target_repair"):
            failures.append(f"{record_id}: repair_scope target_repair does not match record")
        if repair_scope.get("allowed_change") != "narrow_patch_only":
            failures.append(f"{record_id}: repair_scope must require narrow_patch_only")
        forbidden = repair_scope.get("forbidden_changes")
        if not isinstance(forbidden, list) or len(forbidden) < 3:
            failures.append(f"{record_id}: repair_scope must list forbidden broad rewrites")

    if not isinstance(post_repair, dict):
        failures.append(f"{record_id}: malformed repair_attempt_contract.post_repair_verification")
    else:
        if post_repair.get("required_gates") != corpus["required_gates"]:
            failures.append(f"{record_id}: post-repair gates do not match corpus")
        if post_repair.get("must_remain_in_verified_repair_seeds") is not True:
            failures.append(f"{record_id}: repair seed is not declared as verified")
        if not isinstance(post_repair.get("runtime_evidence_contract"), dict):
            failures.append(f"{record_id}: post-repair verification must include runtime evidence contract")
        proof_tests = post_repair.get("family_proof_tests")
        if not isinstance(proof_tests, list) or not proof_tests:
            failures.append(f"{record_id}: post-repair verification must include family proof tests")

    if not isinstance(training_use, dict):
        failures.append(f"{record_id}: malformed repair_attempt_contract.training_use")
    else:
        preference_order = training_use.get("preference_order")
        if preference_order != ["passes_all_gates", "compiles_only", "plausible_but_unverified"]:
            failures.append(f"{record_id}: preference order must rank passes_all_gates first")

    return failures


def records_to_jsonl(records: list[dict[str, Any]]) -> str:
    return "\n".join(json.dumps(record, sort_keys=True) for record in records) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(DEFAULT_CORPUS))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--check", action="store_true", help="Fail if the output file is missing or stale.")
    args = parser.parse_args()

    corpus_path = Path(args.corpus)
    with corpus_path.open(encoding="utf-8") as handle:
        corpus = json.load(handle)

    corpus_failures = validate_corpus(corpus)
    if corpus_failures:
        for failure in corpus_failures:
            print(failure, file=sys.stderr)
        return 1

    records = build_records(corpus)
    record_failures = validate_records(corpus, records)
    if record_failures:
        for failure in record_failures:
            print(failure, file=sys.stderr)
        return 1

    output_path = Path(args.output)
    jsonl = records_to_jsonl(records)
    if args.check:
        if not output_path.exists():
            print(f"{output_path}: missing generated records; run build_complex_benchmark_records.py", file=sys.stderr)
            return 1
        existing = output_path.read_text(encoding="utf-8")
        if existing != jsonl:
            print(f"{output_path}: generated records are stale", file=sys.stderr)
            return 1
    else:
        output_path.write_text(jsonl, encoding="utf-8")

    print(f"Validated {len(records)} complex Amiga benchmark records from {len(corpus['benchmark_families'])} families.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
