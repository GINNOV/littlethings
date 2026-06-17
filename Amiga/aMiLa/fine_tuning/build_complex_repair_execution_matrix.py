#!/usr/bin/env python3
"""Build and optionally execute test commands for complex Amiga repair proofs."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any

from build_complex_repair_proofs import (
    DEFAULT_OUTPUT as DEFAULT_PROOFS,
    build_repair_proofs,
    validate_repair_proofs,
)
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


DEFAULT_OUTPUT = Path(__file__).with_name("complex_amiga_repair_execution_matrix.jsonl")
REPO_ROOT = Path(__file__).resolve().parents[2]
SWIFT_PACKAGE_PATH = REPO_ROOT / "aMiLa" / "AmigaPlayground"
TEST_TARGET = "AmigaPlaygroundTests"

REQUIRED_MATRIX_KEYS = {
    "schema_version",
    "corpus_id",
    "execution_id",
    "record_type",
    "proof_id",
    "example_id",
    "family_id",
    "failure_kind",
    "before_repair_execution",
    "after_repair_execution",
    "command_plan",
    "training_use",
}


def swift_filter(test_name: str) -> str:
    return f"{TEST_TARGET}/{test_name}"


def swift_command(test_names: list[str]) -> list[str]:
    filters = "|".join(swift_filter(name) for name in test_names)
    return ["swift", "test", "--package-path", str(SWIFT_PACKAGE_PATH), "--filter", filters]


def unique_ordered(values: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        result.append(value)
    return result


def build_execution_matrix(corpus: dict[str, Any], proofs: list[dict[str, Any]]) -> list[dict[str, Any]]:
    matrix: list[dict[str, Any]] = []
    for proof in proofs:
        before = proof["before_repair_gate_evidence"]
        after = proof["after_repair_gate_evidence"]
        diagnostic_test = before["diagnostic_proof_test"]
        negative_test = before["negative_proof_test"]
        source_test = after["source_proof_test"]
        promotion_test = after["emulator_artifact_promotion_test"]
        family_tests = unique_ordered(after["family_proof_tests"])
        fast_tests = unique_ordered([diagnostic_test, source_test])
        full_non_promotion_tests = [test for test in family_tests if test != promotion_test]

        matrix.append(
            {
                "schema_version": 1,
                "corpus_id": proof["corpus_id"],
                "execution_id": f"{proof['proof_id']}::execution",
                "record_type": "repair_execution_matrix",
                "proof_id": proof["proof_id"],
                "example_id": proof["example_id"],
                "source_record_id": proof["source_record_id"],
                "family_id": proof["family_id"],
                "family_title": proof["family_title"],
                "failure_kind": proof["failure_kind"],
                "before_repair_execution": {
                    "purpose": "prove_broken_variant_is_rejected_before_repair",
                    "expected_failure_kind": before["expected_failure_kind"],
                    "expected_diagnostic": before["expected_diagnostic"],
                    "diagnostic_proof_test": diagnostic_test,
                    "diagnostic_swift_filter": swift_filter(diagnostic_test),
                    "runtime_negative_test": negative_test,
                    "runtime_negative_swift_filter": swift_filter(negative_test),
                    "expected_test_result": "pass_when_negative_diagnostic_is_observed",
                },
                "after_repair_execution": {
                    "purpose": "prove_repaired_artifact_passes_owned_family_gates",
                    "source_proof_test": source_test,
                    "emulator_artifact_promotion_test": promotion_test,
                    "family_proof_tests": family_tests,
                    "required_gates": after["required_gates"],
                    "accepted_repair_outcome": after["accepted_repair_outcome"],
                },
                "command_plan": {
                    "fast_tests": fast_tests,
                    "fast_command": swift_command(fast_tests),
                    "full_non_promotion_tests": full_non_promotion_tests,
                    "full_non_promotion_command": swift_command(full_non_promotion_tests),
                    "promotion_test": promotion_test,
                    "promotion_command": swift_command([promotion_test]),
                    "promotion_is_opt_in": True,
                    "promotion_note": "The promotion command may skip unless the family-specific vAmiga smoke environment is enabled.",
                },
                "training_use": {
                    "negative_sample": proof["training_use"]["negative_sample"],
                    "positive_sample": proof["training_use"]["positive_sample"],
                    "preference_order": proof["training_use"]["preference_order"],
                    "adapter_tags": proof["training_use"]["adapter_tags"],
                },
            }
        )
    return matrix


def validate_execution_matrix(corpus: dict[str, Any], matrix: list[dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    execution_ids = [row.get("execution_id", "") for row in matrix]
    if len(set(execution_ids)) != len(execution_ids):
        failures.append("repair execution ids must be unique")

    expected_count = sum(len(family["repair_seeds"]) for family in corpus["benchmark_families"])
    if len(matrix) != expected_count:
        failures.append(f"expected {expected_count} repair execution rows, found {len(matrix)}")

    required_gates = corpus["required_gates"]
    for row in matrix:
        execution_id = row.get("execution_id")
        missing = REQUIRED_MATRIX_KEYS - set(row.keys())
        for key in sorted(missing):
            failures.append(f"{execution_id}: missing required key '{key}'")

        if row.get("record_type") != "repair_execution_matrix":
            failures.append(f"{execution_id}: record_type must be repair_execution_matrix")

        before = row.get("before_repair_execution")
        if not isinstance(before, dict):
            failures.append(f"{execution_id}: before_repair_execution must be an object")
        else:
            if not before.get("diagnostic_proof_test") or not before.get("diagnostic_swift_filter"):
                failures.append(f"{execution_id}: before-repair execution needs a diagnostic test and filter")
            if not before.get("runtime_negative_test") or not before.get("runtime_negative_swift_filter"):
                failures.append(f"{execution_id}: before-repair execution needs a runtime negative test and filter")
            if before.get("expected_test_result") != "pass_when_negative_diagnostic_is_observed":
                failures.append(f"{execution_id}: before-repair test must pass by observing the diagnostic")
            if not before.get("expected_diagnostic"):
                failures.append(f"{execution_id}: before-repair execution needs expected diagnostic")

        after = row.get("after_repair_execution")
        if not isinstance(after, dict):
            failures.append(f"{execution_id}: after_repair_execution must be an object")
        else:
            if after.get("required_gates") != required_gates:
                failures.append(f"{execution_id}: after-repair gates do not match corpus")
            if after.get("accepted_repair_outcome") != "passes_all_required_gates":
                failures.append(f"{execution_id}: after-repair result must require all gates")
            tests = after.get("family_proof_tests")
            if not isinstance(tests, list) or len(tests) < 2:
                failures.append(f"{execution_id}: after-repair execution needs family proof tests")
            if after.get("source_proof_test") not in (tests or []):
                failures.append(f"{execution_id}: source proof test must be in family proof tests")
            if after.get("emulator_artifact_promotion_test") not in (tests or []):
                failures.append(f"{execution_id}: promotion proof test must be in family proof tests")
            before = row.get("before_repair_execution")
            if isinstance(before, dict) and before.get("diagnostic_proof_test") not in (tests or []):
                failures.append(f"{execution_id}: diagnostic proof test must be in family proof tests")

        command_plan = row.get("command_plan")
        if not isinstance(command_plan, dict):
            failures.append(f"{execution_id}: command_plan must be an object")
        else:
            fast_tests = command_plan.get("fast_tests")
            fast_command = command_plan.get("fast_command")
            full_tests = command_plan.get("full_non_promotion_tests")
            full_command = command_plan.get("full_non_promotion_command")
            if not isinstance(fast_tests, list) or len(fast_tests) != 2:
                failures.append(f"{execution_id}: fast command must cover negative and source proof tests")
            if not isinstance(full_tests, list) or not full_tests:
                failures.append(f"{execution_id}: full non-promotion command must cover family tests")
            if not is_swift_test_command(fast_command):
                failures.append(f"{execution_id}: malformed fast swift command")
            if not is_swift_test_command(full_command):
                failures.append(f"{execution_id}: malformed full swift command")
            if command_plan.get("promotion_is_opt_in") is not True:
                failures.append(f"{execution_id}: promotion test must be marked opt-in")

        training_use = row.get("training_use")
        if not isinstance(training_use, dict):
            failures.append(f"{execution_id}: training_use must be an object")
        elif training_use.get("preference_order") != ["passes_all_gates", "compiles_only", "plausible_but_unverified"]:
            failures.append(f"{execution_id}: training preference order is invalid")

    return failures


def is_swift_test_command(command: Any) -> bool:
    return (
        isinstance(command, list)
        and len(command) == 6
        and command[0] == "swift"
        and command[1] == "test"
        and command[2] == "--package-path"
        and command[4] == "--filter"
    )


def matrix_to_jsonl(matrix: list[dict[str, Any]]) -> str:
    return "\n".join(json.dumps(row, sort_keys=True) for row in matrix) + "\n"


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    return [json.loads(line) for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]


def load_inputs(args: argparse.Namespace) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    corpus = json.loads(Path(args.corpus).read_text(encoding="utf-8"))
    corpus_failures = validate_corpus(corpus)
    if corpus_failures:
        raise ValueError("\n".join(corpus_failures))

    records_path = Path(args.records)
    if records_path.exists():
        records = load_jsonl(records_path)
    else:
        records = build_records(corpus)
    record_failures = validate_records(corpus, records)
    if record_failures:
        raise ValueError("\n".join(record_failures))

    examples_path = Path(args.examples)
    if examples_path.exists():
        examples = load_jsonl(examples_path)
    else:
        examples = build_repair_examples(corpus, records)
    example_failures = validate_repair_examples(corpus, examples)
    if example_failures:
        raise ValueError("\n".join(example_failures))

    proofs_path = Path(args.proofs)
    if proofs_path.exists():
        proofs = load_jsonl(proofs_path)
    else:
        proofs = build_repair_proofs(corpus, examples)
    proof_failures = validate_repair_proofs(corpus, proofs)
    if proof_failures:
        raise ValueError("\n".join(proof_failures))

    return corpus, proofs


def execute_matrix(matrix: list[dict[str, Any]], mode: str, dry_run: bool) -> int:
    if mode == "none":
        return 0

    if mode == "fast":
        tests = unique_ordered(test for row in matrix for test in row["command_plan"]["fast_tests"])
    elif mode == "full-non-promotion":
        tests = unique_ordered(test for row in matrix for test in row["command_plan"]["full_non_promotion_tests"])
    else:
        raise ValueError(f"unsupported execute mode: {mode}")

    command = swift_command(tests)
    print(" ".join(command))
    if dry_run:
        return 0
    return subprocess.run(command, cwd=REPO_ROOT).returncode


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(DEFAULT_CORPUS))
    parser.add_argument("--records", default=str(DEFAULT_RECORDS))
    parser.add_argument("--examples", default=str(DEFAULT_EXAMPLES))
    parser.add_argument("--proofs", default=str(DEFAULT_PROOFS))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--check", action="store_true", help="Fail if the output file is missing or stale.")
    parser.add_argument(
        "--execute",
        choices=["none", "fast", "full-non-promotion"],
        default="none",
        help="Run generated Swift test commands after validating the matrix.",
    )
    parser.add_argument("--dry-run", action="store_true", help="Print execution command without running it.")
    args = parser.parse_args()

    try:
        corpus, proofs = load_inputs(args)
        matrix = build_execution_matrix(corpus, proofs)
        failures = validate_execution_matrix(corpus, matrix)
    except ValueError as error:
        print(str(error), file=sys.stderr)
        return 1

    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    output_path = Path(args.output)
    jsonl = matrix_to_jsonl(matrix)
    if args.check:
        if not output_path.exists():
            print(f"{output_path}: missing generated repair execution matrix", file=sys.stderr)
            return 1
        existing = output_path.read_text(encoding="utf-8")
        if existing != jsonl:
            print(f"{output_path}: generated repair execution matrix is stale", file=sys.stderr)
            return 1
    else:
        output_path.write_text(jsonl, encoding="utf-8")

    print(f"Validated {len(matrix)} complex Amiga repair execution rows from {len(corpus['benchmark_families'])} families.")
    return execute_matrix(matrix, args.execute, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
