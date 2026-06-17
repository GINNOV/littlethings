#!/usr/bin/env python3
"""Build deterministic before/after proof manifests for complex Amiga repair loops."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from build_complex_repair_loop_examples import (
    DEFAULT_OUTPUT as DEFAULT_EXAMPLES,
    build_repair_examples,
    validate_repair_examples,
)
from build_complex_benchmark_records import (
    DEFAULT_OUTPUT as DEFAULT_RECORDS,
    build_records,
    validate_records,
)
from validate_complex_benchmark_corpus import DEFAULT_CORPUS, validate_corpus


DEFAULT_OUTPUT = Path(__file__).with_name("complex_amiga_repair_proofs.jsonl")

REQUIRED_PROOF_KEYS = {
    "schema_version",
    "corpus_id",
    "proof_id",
    "record_type",
    "example_id",
    "family_id",
    "failure_kind",
    "before_repair_gate_evidence",
    "repair_patch_policy",
    "after_repair_gate_evidence",
    "gate_matrix",
    "quality_bar",
    "training_use",
}


def build_gate_matrix(example: dict[str, Any]) -> list[dict[str, Any]]:
    verification = example["post_repair_verification"]
    runtime_contract = verification["runtime_evidence_contract"]
    matrix: list[dict[str, Any]] = []
    for gate in verification["required_gates"]:
        if gate == "repair_loop":
            before_status = "fails_expected_diagnostic"
            before_evidence = example["broken_variant"]["expected_diagnostic"]
        elif gate == "runtime_evidence":
            before_status = "negative_runtime_contract"
            before_evidence = runtime_contract["negative_proof_test"]
        else:
            before_status = "not_accepted_as_repaired_output"
            before_evidence = "broken variant must not be promoted before repair"

        if gate == "runtime_evidence":
            after_evidence = runtime_contract["source_proof_test"]
        elif gate == "bootable_adf":
            after_evidence = verification["emulator_artifact_promotion_test"]
        elif gate == "repair_loop":
            after_evidence = "narrow repair clears expected diagnostic without broad rewrite"
        else:
            after_evidence = "family proof test suite"

        matrix.append(
            {
                "gate": gate,
                "before_repair": {
                    "status": before_status,
                    "evidence": before_evidence,
                },
                "after_repair": {
                    "status": "required_pass",
                    "evidence": after_evidence,
                },
            }
        )
    return matrix


def build_repair_proofs(corpus: dict[str, Any], examples: list[dict[str, Any]]) -> list[dict[str, Any]]:
    proofs: list[dict[str, Any]] = []
    for example in examples:
        verification = example["post_repair_verification"]
        runtime_contract = verification["runtime_evidence_contract"]
        proof = {
            "schema_version": 1,
            "corpus_id": example["corpus_id"],
            "proof_id": f"{example['example_id']}::proof",
            "record_type": "repair_loop_proof",
            "example_id": example["example_id"],
            "source_record_id": example["source_record_id"],
            "family_id": example["family_id"],
            "family_title": example["family_title"],
            "failure_kind": example["failure_kind"],
            "before_repair_gate_evidence": {
                "must_fail": True,
                "failed_phase": "broken_variant_validation",
                "expected_failure_kind": example["diagnostic_evidence"]["expected_failure_kind"],
                "expected_diagnostic": example["broken_variant"]["expected_diagnostic"],
                "diagnostic_proof_test": example["diagnostic_evidence"]["diagnostic_proof_test"],
                "negative_proof_test": example["diagnostic_evidence"]["negative_proof_test"],
                "failure_is_verified_repair_seed": example["diagnostic_evidence"]["failure_is_verified_repair_seed"],
            },
            "repair_patch_policy": {
                "target_repair": example["repair_attempt"]["target_repair"],
                "allowed_change": example["repair_attempt"]["allowed_change"],
                "forbidden_changes": example["repair_attempt"]["forbidden_changes"],
                "preserve_existing_behavior": True,
                "preserve_structured_model_identity": True,
            },
            "after_repair_gate_evidence": {
                "must_pass": True,
                "accepted_repair_outcome": verification["accepted_repair_outcome"],
                "required_gates": verification["required_gates"],
                "source_proof_test": verification["source_proof_test"],
                "emulator_artifact_promotion_test": verification["emulator_artifact_promotion_test"],
                "runtime_evidence_contract": runtime_contract,
                "family_proof_tests": verification["family_proof_tests"],
            },
            "gate_matrix": build_gate_matrix(example),
            "quality_bar": {
                "reject_broad_rewrite": True,
                "reject_compile_only_success": True,
                "reject_missing_runtime_evidence": True,
                "reject_state_loss_after_follow_up": True,
            },
            "training_use": {
                "negative_sample": "broken_variant_before_repair",
                "positive_sample": "verified_narrow_repair_after_all_gates",
                "preference_order": example["training_labels"]["preference_order"],
                "adapter_tags": example["training_labels"]["adapter_tags"],
            },
        }
        proofs.append(proof)
    return proofs


def validate_repair_proofs(corpus: dict[str, Any], proofs: list[dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    proof_ids = [proof.get("proof_id", "") for proof in proofs]
    if len(set(proof_ids)) != len(proof_ids):
        failures.append("repair proof ids must be unique")

    expected_count = sum(len(family["repair_seeds"]) for family in corpus["benchmark_families"])
    if len(proofs) != expected_count:
        failures.append(f"expected {expected_count} repair proofs, found {len(proofs)}")

    required_gates = corpus["required_gates"]
    required_gate_set = set(required_gates)
    for proof in proofs:
        proof_id = proof.get("proof_id")
        missing = REQUIRED_PROOF_KEYS - set(proof.keys())
        for key in sorted(missing):
            failures.append(f"{proof_id}: missing required key '{key}'")

        if proof.get("record_type") != "repair_loop_proof":
            failures.append(f"{proof_id}: record_type must be repair_loop_proof")

        before = proof.get("before_repair_gate_evidence")
        if not isinstance(before, dict):
            failures.append(f"{proof_id}: before_repair_gate_evidence must be an object")
        else:
            if before.get("must_fail") is not True:
                failures.append(f"{proof_id}: before-repair artifact must fail")
            if before.get("failure_is_verified_repair_seed") is not True:
                failures.append(f"{proof_id}: before-repair failure must be a verified seed")
            if not before.get("expected_diagnostic") or not before.get("negative_proof_test") or not before.get("diagnostic_proof_test"):
                failures.append(f"{proof_id}: before-repair proof needs diagnostic, diagnostic proof test, and negative test")

        patch_policy = proof.get("repair_patch_policy")
        if not isinstance(patch_policy, dict):
            failures.append(f"{proof_id}: repair_patch_policy must be an object")
        else:
            if patch_policy.get("allowed_change") != "narrow_patch_only":
                failures.append(f"{proof_id}: repair patch policy must be narrow_patch_only")
            if patch_policy.get("preserve_existing_behavior") is not True:
                failures.append(f"{proof_id}: repair must preserve existing behavior")
            if patch_policy.get("preserve_structured_model_identity") is not True:
                failures.append(f"{proof_id}: repair must preserve model identity")

        after = proof.get("after_repair_gate_evidence")
        if not isinstance(after, dict):
            failures.append(f"{proof_id}: after_repair_gate_evidence must be an object")
        else:
            if after.get("must_pass") is not True:
                failures.append(f"{proof_id}: repaired artifact must pass")
            if after.get("accepted_repair_outcome") != "passes_all_required_gates":
                failures.append(f"{proof_id}: repaired artifact must pass all required gates")
            if after.get("required_gates") != required_gates:
                failures.append(f"{proof_id}: post-repair gates do not match corpus")
            if not after.get("source_proof_test") or not after.get("emulator_artifact_promotion_test"):
                failures.append(f"{proof_id}: post-repair evidence needs source and emulator proof tests")
            if not isinstance(after.get("runtime_evidence_contract"), dict):
                failures.append(f"{proof_id}: post-repair evidence needs runtime contract")
            proof_tests = after.get("family_proof_tests")
            if isinstance(proof_tests, list) and isinstance(before, dict):
                diagnostic_test = before.get("diagnostic_proof_test")
                if diagnostic_test not in proof_tests:
                    failures.append(f"{proof_id}: diagnostic proof test must be listed in family proof tests")

        matrix = proof.get("gate_matrix")
        if not isinstance(matrix, list):
            failures.append(f"{proof_id}: gate_matrix must be a list")
        else:
            matrix_gates = [row.get("gate") for row in matrix if isinstance(row, dict)]
            if matrix_gates != required_gates:
                failures.append(f"{proof_id}: gate matrix must preserve required gate order")
            if set(matrix_gates) != required_gate_set:
                failures.append(f"{proof_id}: gate matrix must cover every required gate")
            for row in matrix:
                if not isinstance(row, dict):
                    failures.append(f"{proof_id}: gate matrix rows must be objects")
                    continue
                gate = row.get("gate")
                before_status = (row.get("before_repair") or {}).get("status")
                after_status = (row.get("after_repair") or {}).get("status")
                if gate == "repair_loop" and before_status != "fails_expected_diagnostic":
                    failures.append(f"{proof_id}: repair_loop gate must fail before repair")
                if after_status != "required_pass":
                    failures.append(f"{proof_id}: gate {gate} must pass after repair")

        quality_bar = proof.get("quality_bar")
        if not isinstance(quality_bar, dict) or not all(quality_bar.values()):
            failures.append(f"{proof_id}: quality bar must reject weak repair outcomes")

        training_use = proof.get("training_use")
        if not isinstance(training_use, dict):
            failures.append(f"{proof_id}: training_use must be an object")
        else:
            if training_use.get("preference_order") != ["passes_all_gates", "compiles_only", "plausible_but_unverified"]:
                failures.append(f"{proof_id}: training preference order is invalid")
            tags = training_use.get("adapter_tags")
            if not isinstance(tags, list) or not tags:
                failures.append(f"{proof_id}: training use needs adapter tags")

    return failures


def proofs_to_jsonl(proofs: list[dict[str, Any]]) -> str:
    return "\n".join(json.dumps(proof, sort_keys=True) for proof in proofs) + "\n"


def load_examples(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(DEFAULT_CORPUS))
    parser.add_argument("--records", default=str(DEFAULT_RECORDS))
    parser.add_argument("--examples", default=str(DEFAULT_EXAMPLES))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--check", action="store_true", help="Fail if the output file is missing or stale.")
    args = parser.parse_args()

    corpus_path = Path(args.corpus)
    records_path = Path(args.records)
    examples_path = Path(args.examples)
    corpus = json.loads(corpus_path.read_text(encoding="utf-8"))
    corpus_failures = validate_corpus(corpus)
    if corpus_failures:
        for failure in corpus_failures:
            print(failure, file=sys.stderr)
        return 1

    if records_path.exists():
        records = [json.loads(line) for line in records_path.read_text(encoding="utf-8").splitlines() if line.strip()]
    else:
        records = build_records(corpus)
    record_failures = validate_records(corpus, records)
    if record_failures:
        for failure in record_failures:
            print(failure, file=sys.stderr)
        return 1

    if examples_path.exists():
        examples = load_examples(examples_path)
    else:
        examples = build_repair_examples(corpus, records)
    example_failures = validate_repair_examples(corpus, examples)
    if example_failures:
        for failure in example_failures:
            print(failure, file=sys.stderr)
        return 1

    proofs = build_repair_proofs(corpus, examples)
    proof_failures = validate_repair_proofs(corpus, proofs)
    if proof_failures:
        for failure in proof_failures:
            print(failure, file=sys.stderr)
        return 1

    output_path = Path(args.output)
    jsonl = proofs_to_jsonl(proofs)
    if args.check:
        if not output_path.exists():
            print(f"{output_path}: missing generated repair proofs; run build_complex_repair_proofs.py", file=sys.stderr)
            return 1
        existing = output_path.read_text(encoding="utf-8")
        if existing != jsonl:
            print(f"{output_path}: generated repair proofs are stale", file=sys.stderr)
            return 1
    else:
        output_path.write_text(jsonl, encoding="utf-8")

    print(f"Validated {len(proofs)} complex Amiga repair proofs from {len(corpus['benchmark_families'])} families.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
