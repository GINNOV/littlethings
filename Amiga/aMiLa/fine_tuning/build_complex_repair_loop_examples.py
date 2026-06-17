#!/usr/bin/env python3
"""Build deterministic repair-loop examples from the complex Amiga benchmark records."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from build_complex_benchmark_records import (
    DEFAULT_OUTPUT as DEFAULT_RECORDS,
    build_records,
    validate_records,
)
from validate_complex_benchmark_corpus import DEFAULT_CORPUS, validate_corpus


DEFAULT_OUTPUT = Path(__file__).with_name("complex_amiga_repair_loop_examples.jsonl")

REQUIRED_REPAIR_EXAMPLE_KEYS = {
    "schema_version",
    "corpus_id",
    "example_id",
    "record_type",
    "family_id",
    "failure_kind",
    "domain_tags",
    "broken_variant",
    "diagnostic_evidence",
    "repair_attempt",
    "post_repair_verification",
    "training_labels",
}


def records_by_id(records: list[dict[str, Any]]) -> dict[str, dict[str, Any]]:
    return {record["record_id"]: record for record in records}


def build_repair_examples(corpus: dict[str, Any], records: list[dict[str, Any]]) -> list[dict[str, Any]]:
    by_id = records_by_id(records)
    examples: list[dict[str, Any]] = []
    for family in corpus["benchmark_families"]:
        family_id = family["id"]
        proof = family["executable_proof"]
        contract = proof["runtime_evidence_contract"]
        for seed in family["repair_seeds"]:
            record_id = f"{family_id}::repair_{seed['failure_kind']}"
            repair_record = by_id[record_id]
            repair_contract = repair_record["repair_attempt_contract"]
            example = {
                "schema_version": 1,
                "corpus_id": corpus["corpus_id"],
                "example_id": f"{record_id}::repair_loop",
                "record_type": "repair_loop_example",
                "family_id": family_id,
                "family_title": family["title"],
                "failure_kind": seed["failure_kind"],
                "domain_tags": family["domain_tags"],
                "source_record_id": record_id,
                "broken_variant": {
                    "strategy": seed["broken_variant_strategy"],
                    "expected_diagnostic": seed["expected_diagnostic"],
                    "diagnostic_proof_test": seed["diagnostic_proof_test"],
                    "must_fail_before_repair": True,
                },
                "diagnostic_evidence": {
                    "expected_failure_kind": seed["failure_kind"],
                    "expected_diagnostic": seed["expected_diagnostic"],
                    "diagnostic_proof_test": seed["diagnostic_proof_test"],
                    "negative_proof_test": contract["negative_proof_test"],
                    "family_proof_tests": proof["proof_tests"],
                    "failure_is_verified_repair_seed": seed["failure_kind"] in proof["verified_repair_seeds"],
                },
                "repair_attempt": {
                    "target_repair": seed["target_repair"],
                    "allowed_change": repair_contract["repair_scope"]["allowed_change"],
                    "forbidden_changes": repair_contract["repair_scope"]["forbidden_changes"],
                    "model_instruction": (
                        "Apply the smallest source/model patch that clears the expected diagnostic, "
                        "then rerun the full family verifier stack."
                    ),
                },
                "post_repair_verification": {
                    "required_gates": corpus["required_gates"],
                    "runtime_evidence_contract": contract,
                    "source_proof_test": contract["source_proof_test"],
                    "emulator_artifact_promotion_test": contract.get("emulator_artifact_promotion_test"),
                    "family_proof_tests": proof["proof_tests"],
                    "accepted_repair_outcome": "passes_all_required_gates",
                },
                "training_labels": {
                    "negative_sample": "broken_variant_before_repair",
                    "positive_sample": "narrow_repair_after_verification",
                    "preference_order": ["passes_all_gates", "compiles_only", "plausible_but_unverified"],
                    "adapter_tags": family["domain_tags"],
                },
            }
            examples.append(example)
    return examples


def validate_repair_examples(corpus: dict[str, Any], examples: list[dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    example_ids = [example.get("example_id", "") for example in examples]
    if len(set(example_ids)) != len(example_ids):
        failures.append("repair-loop example ids must be unique")

    expected_count = sum(len(family["repair_seeds"]) for family in corpus["benchmark_families"])
    if len(examples) != expected_count:
        failures.append(f"expected {expected_count} repair-loop examples, found {len(examples)}")

    required_gates = corpus["required_gates"]
    for example in examples:
        example_id = example.get("example_id")
        missing = REQUIRED_REPAIR_EXAMPLE_KEYS - set(example.keys())
        for key in sorted(missing):
            failures.append(f"{example_id}: missing required key '{key}'")

        if example.get("record_type") != "repair_loop_example":
            failures.append(f"{example_id}: record_type must be repair_loop_example")

        broken = example.get("broken_variant")
        if not isinstance(broken, dict):
            failures.append(f"{example_id}: broken_variant must be an object")
        else:
            if broken.get("must_fail_before_repair") is not True:
                failures.append(f"{example_id}: broken variant must fail before repair")
            if not broken.get("strategy") or not broken.get("expected_diagnostic") or not broken.get("diagnostic_proof_test"):
                failures.append(f"{example_id}: broken variant needs strategy, diagnostic, and diagnostic proof test")

        diagnostic = example.get("diagnostic_evidence")
        if not isinstance(diagnostic, dict):
            failures.append(f"{example_id}: diagnostic_evidence must be an object")
        else:
            if diagnostic.get("failure_is_verified_repair_seed") is not True:
                failures.append(f"{example_id}: diagnostic must map to a verified repair seed")
            if not diagnostic.get("negative_proof_test"):
                failures.append(f"{example_id}: diagnostic must name a negative proof test")
            diagnostic_test = diagnostic.get("diagnostic_proof_test")
            if not diagnostic_test:
                failures.append(f"{example_id}: diagnostic must name a repair-seed diagnostic proof test")
            proof_tests = diagnostic.get("family_proof_tests")
            if not isinstance(proof_tests, list) or not proof_tests:
                failures.append(f"{example_id}: diagnostic must include family proof tests")
            elif diagnostic_test not in proof_tests:
                failures.append(f"{example_id}: diagnostic proof test must be listed in family proof tests")

        repair = example.get("repair_attempt")
        if not isinstance(repair, dict):
            failures.append(f"{example_id}: repair_attempt must be an object")
        else:
            if repair.get("allowed_change") != "narrow_patch_only":
                failures.append(f"{example_id}: repair attempt must be narrow_patch_only")
            forbidden = repair.get("forbidden_changes")
            if not isinstance(forbidden, list) or len(forbidden) < 3:
                failures.append(f"{example_id}: repair attempt must forbid broad rewrites")
            if not repair.get("target_repair"):
                failures.append(f"{example_id}: repair attempt needs a target repair")

        verification = example.get("post_repair_verification")
        if not isinstance(verification, dict):
            failures.append(f"{example_id}: post_repair_verification must be an object")
        else:
            if verification.get("required_gates") != required_gates:
                failures.append(f"{example_id}: post-repair required gates do not match corpus")
            if verification.get("accepted_repair_outcome") != "passes_all_required_gates":
                failures.append(f"{example_id}: accepted repair outcome must require all gates")
            if not isinstance(verification.get("runtime_evidence_contract"), dict):
                failures.append(f"{example_id}: post-repair verification needs runtime evidence contract")
            if not verification.get("source_proof_test"):
                failures.append(f"{example_id}: post-repair verification needs source proof test")
            if not verification.get("emulator_artifact_promotion_test"):
                failures.append(f"{example_id}: post-repair verification needs emulator promotion test")

        labels = example.get("training_labels")
        if not isinstance(labels, dict):
            failures.append(f"{example_id}: training_labels must be an object")
        else:
            if labels.get("preference_order") != ["passes_all_gates", "compiles_only", "plausible_but_unverified"]:
                failures.append(f"{example_id}: training preference order is invalid")
            tags = labels.get("adapter_tags")
            if not isinstance(tags, list) or not tags:
                failures.append(f"{example_id}: training labels need adapter tags")

    return failures


def examples_to_jsonl(examples: list[dict[str, Any]]) -> str:
    return "\n".join(json.dumps(example, sort_keys=True) for example in examples) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(DEFAULT_CORPUS))
    parser.add_argument("--records", default=str(DEFAULT_RECORDS))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--check", action="store_true", help="Fail if the output file is missing or stale.")
    args = parser.parse_args()

    corpus_path = Path(args.corpus)
    records_path = Path(args.records)
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

    examples = build_repair_examples(corpus, records)
    example_failures = validate_repair_examples(corpus, examples)
    if example_failures:
        for failure in example_failures:
            print(failure, file=sys.stderr)
        return 1

    output_path = Path(args.output)
    jsonl = examples_to_jsonl(examples)
    if args.check:
        if not output_path.exists():
            print(f"{output_path}: missing generated repair-loop examples; run build_complex_repair_loop_examples.py", file=sys.stderr)
            return 1
        existing = output_path.read_text(encoding="utf-8")
        if existing != jsonl:
            print(f"{output_path}: generated repair-loop examples are stale", file=sys.stderr)
            return 1
    else:
        output_path.write_text(jsonl, encoding="utf-8")

    print(f"Validated {len(examples)} complex Amiga repair-loop examples from {len(corpus['benchmark_families'])} families.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
