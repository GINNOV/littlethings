#!/usr/bin/env python3
"""Validate the complex functional Amiga benchmark and repair corpus."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any


DEFAULT_CORPUS = Path(__file__).with_name("complex_amiga_benchmark_corpus.json")

REQUIRED_TOP_LEVEL_KEYS = {
    "schema_version",
    "corpus_id",
    "description",
    "required_family_count",
    "required_gates",
    "benchmark_families",
}

REQUIRED_FAMILY_KEYS = {
    "id",
    "title",
    "domain_tags",
    "promotion_status",
    "first_shot_prompt",
    "structured_model_requirements",
    "runtime_evidence",
    "multi_turn_follow_ups",
    "rejected_turns",
    "repair_seeds",
}

REQUIRED_REPAIR_SEED_KEYS = {
    "failure_kind",
    "broken_variant_strategy",
    "expected_diagnostic",
    "diagnostic_proof_test",
    "target_repair",
}

REQUIRED_EXECUTABLE_PROOF_KEYS = {
    "status",
    "template_id",
    "verified_gates",
    "proof_tests",
}

REQUIRED_RUNTIME_EVIDENCE_CONTRACT_KEYS = {
    "kind",
    "emulator_backend",
    "capture_expectation",
    "required_artifacts",
    "source_proof_test",
    "negative_proof_test",
}

REQUIRED_COMMON_RUNTIME_ARTIFACTS = {
    "bootable_adf",
    "raw_frame",
    "manifest_json",
}

RUNTIME_ARTIFACTS_BY_EXPECTATION = {
    "motion-plus-register-trace": {"frame_analysis_json"},
    "visible-frame-diff": {"frame_analysis_json"},
}

REQUIRED_GATES = {
    "structured_model",
    "generated_asm",
    "semantic_verifier",
    "vasm_compile",
    "bootable_adf",
    "runtime_evidence",
    "multi_turn_preservation",
    "rejected_turn_no_mutation",
    "repair_loop",
}

ALLOWED_PROMOTION_STATUSES = {
    "promoted_app_side",
    "candidate_unpromoted",
}

ALLOWED_EXECUTABLE_PROOF_STATUSES = {
    "initial_executable_seed",
    "complete_family_proof",
}


def non_empty_string(value: Any) -> bool:
    return isinstance(value, str) and bool(value.strip())


def non_empty_string_list(value: Any, minimum: int = 1) -> bool:
    return (
        isinstance(value, list)
        and len(value) >= minimum
        and all(non_empty_string(item) for item in value)
        and len(set(item.strip().casefold() for item in value)) == len(value)
    )


def add_missing_key_failures(prefix: str, value: dict[str, Any], required_keys: set[str], failures: list[str]) -> None:
    for key in sorted(required_keys - set(value.keys())):
        failures.append(f"{prefix}: missing required key '{key}'")


def validate_repair_seed(family_id: str, index: int, seed: Any) -> list[str]:
    prefix = f"{family_id}.repair_seeds[{index}]"
    failures: list[str] = []
    if not isinstance(seed, dict):
        return [f"{prefix}: must be an object"]

    add_missing_key_failures(prefix, seed, REQUIRED_REPAIR_SEED_KEYS, failures)
    for key in sorted(REQUIRED_REPAIR_SEED_KEYS & set(seed.keys())):
        if not non_empty_string(seed[key]):
            failures.append(f"{prefix}.{key}: must be a non-empty string")
    return failures


def validate_executable_proof(family_id: str, family: dict[str, Any], proof: Any, corpus_gates: set[str]) -> list[str]:
    prefix = f"{family_id}.executable_proof"
    failures: list[str] = []
    if not isinstance(proof, dict):
        return [f"{prefix}: must be an object"]

    add_missing_key_failures(prefix, proof, REQUIRED_EXECUTABLE_PROOF_KEYS, failures)

    status = proof.get("status")
    if status not in ALLOWED_EXECUTABLE_PROOF_STATUSES:
        failures.append(f"{prefix}.status: unsupported value {status!r}")

    if "template_id" in proof and not non_empty_string(proof["template_id"]):
        failures.append(f"{prefix}.template_id: must be a non-empty string")

    verified_gates = proof.get("verified_gates")
    if not non_empty_string_list(verified_gates, minimum=1):
        failures.append(f"{prefix}.verified_gates: must contain at least 1 unique non-empty string")
    else:
        verified_gate_set = set(verified_gates)
        unknown_gates = verified_gate_set - corpus_gates
        for gate in sorted(unknown_gates):
            failures.append(f"{prefix}.verified_gates: unknown gate '{gate}'")
        missing_gates = corpus_gates - verified_gate_set
        for gate in sorted(missing_gates):
            failures.append(f"{prefix}.verified_gates: missing required gate '{gate}'")

    if not non_empty_string_list(proof.get("proof_tests"), minimum=1):
        failures.append(f"{prefix}.proof_tests: must contain at least 1 unique non-empty string")
    else:
        proof_tests = set(proof.get("proof_tests", []))
        for seed in family.get("repair_seeds", []):
            if not isinstance(seed, dict):
                continue
            diagnostic_test = seed.get("diagnostic_proof_test")
            failure_kind = seed.get("failure_kind", "<missing-failure-kind>")
            if non_empty_string(diagnostic_test) and diagnostic_test not in proof_tests:
                failures.append(
                    f"{prefix}.proof_tests: diagnostic proof test {diagnostic_test!r} for repair seed {failure_kind!r} is not listed"
                )

    runtime_contract = proof.get("runtime_evidence_contract")
    if runtime_contract is not None:
        failures.extend(validate_runtime_evidence_contract(prefix, proof, runtime_contract))
    elif isinstance(verified_gates, list) and "runtime_evidence" in verified_gates:
        failures.append(f"{prefix}.runtime_evidence_contract: required when runtime_evidence is verified")

    verified_repair_seeds = proof.get("verified_repair_seeds")
    if not non_empty_string_list(verified_repair_seeds, minimum=1):
        failures.append(f"{prefix}.verified_repair_seeds: must contain unique non-empty strings")
    else:
        known_repair_seeds = {
            seed["failure_kind"]
            for seed in family.get("repair_seeds", [])
            if isinstance(seed, dict) and non_empty_string(seed.get("failure_kind"))
        }
        verified_seed_set = set(verified_repair_seeds)
        unknown_seeds = verified_seed_set - known_repair_seeds
        for seed in sorted(unknown_seeds):
            failures.append(f"{prefix}.verified_repair_seeds: unknown repair seed '{seed}'")
        missing_seeds = known_repair_seeds - verified_seed_set
        for seed in sorted(missing_seeds):
            failures.append(f"{prefix}.verified_repair_seeds: missing repair seed '{seed}'")

    if isinstance(verified_gates, list) and "repair_loop" in verified_gates and not verified_repair_seeds:
        failures.append(f"{prefix}.repair_loop: requires verified_repair_seeds")

    return failures


def validate_runtime_evidence_contract(prefix: str, proof: dict[str, Any], contract: Any) -> list[str]:
    contract_prefix = f"{prefix}.runtime_evidence_contract"
    failures: list[str] = []
    if not isinstance(contract, dict):
        return [f"{contract_prefix}: must be an object"]

    add_missing_key_failures(contract_prefix, contract, REQUIRED_RUNTIME_EVIDENCE_CONTRACT_KEYS, failures)
    for key in sorted((REQUIRED_RUNTIME_EVIDENCE_CONTRACT_KEYS - {"required_artifacts"}) & set(contract.keys())):
        if not non_empty_string(contract[key]):
            failures.append(f"{contract_prefix}.{key}: must be a non-empty string")

    artifacts = contract.get("required_artifacts")
    capture_expectation = contract.get("capture_expectation")
    required_artifacts = set(REQUIRED_COMMON_RUNTIME_ARTIFACTS)
    if isinstance(capture_expectation, str):
        required_artifacts.update(RUNTIME_ARTIFACTS_BY_EXPECTATION.get(capture_expectation, set()))

    if not non_empty_string_list(artifacts, minimum=len(required_artifacts)):
        failures.append(f"{contract_prefix}.required_artifacts: must contain unique non-empty artifact names")
    else:
        missing_artifacts = required_artifacts - set(artifacts)
        for artifact in sorted(missing_artifacts):
            failures.append(f"{contract_prefix}.required_artifacts: missing required artifact '{artifact}'")

    proof_tests = set(proof.get("proof_tests", []))
    for key in ["source_proof_test", "negative_proof_test"]:
        test_name = contract.get(key)
        if non_empty_string(test_name) and test_name not in proof_tests:
            failures.append(f"{contract_prefix}.{key}: {test_name!r} is not listed in proof_tests")

    promotion_test = contract.get("emulator_artifact_promotion_test")
    if promotion_test is not None and not non_empty_string(promotion_test):
        failures.append(f"{contract_prefix}.emulator_artifact_promotion_test: must be a non-empty string when present")

    return failures


def validate_family(family: Any) -> list[str]:
    failures: list[str] = []
    if not isinstance(family, dict):
        return ["benchmark_families entry must be an object"]

    family_id = family.get("id", "<missing-id>")
    prefix = f"family {family_id}"
    add_missing_key_failures(prefix, family, REQUIRED_FAMILY_KEYS, failures)

    for key in ["id", "title", "first_shot_prompt"]:
        if key in family and not non_empty_string(family[key]):
            failures.append(f"{prefix}.{key}: must be a non-empty string")

    status = family.get("promotion_status")
    if status not in ALLOWED_PROMOTION_STATUSES:
        failures.append(f"{prefix}.promotion_status: unsupported value {status!r}")

    list_requirements = [
        ("domain_tags", 2),
        ("structured_model_requirements", 3),
        ("runtime_evidence", 3),
        ("multi_turn_follow_ups", 3),
        ("rejected_turns", 3),
    ]
    for key, minimum in list_requirements:
        if key in family and not non_empty_string_list(family[key], minimum=minimum):
            failures.append(f"{prefix}.{key}: must contain at least {minimum} unique non-empty strings")

    repair_seeds = family.get("repair_seeds")
    if not isinstance(repair_seeds, list) or len(repair_seeds) < 2:
        failures.append(f"{prefix}.repair_seeds: must contain at least 2 repair seeds")
    elif len({seed.get("failure_kind", "").strip().casefold() for seed in repair_seeds if isinstance(seed, dict)}) != len(repair_seeds):
        failures.append(f"{prefix}.repair_seeds: failure_kind values must be unique")

    if isinstance(repair_seeds, list):
        for index, seed in enumerate(repair_seeds):
            failures.extend(validate_repair_seed(str(family_id), index, seed))

    return failures


def validate_corpus(corpus: Any) -> list[str]:
    failures: list[str] = []
    if not isinstance(corpus, dict):
        return ["corpus root must be an object"]

    add_missing_key_failures("corpus", corpus, REQUIRED_TOP_LEVEL_KEYS, failures)

    if corpus.get("schema_version") != 1:
        failures.append("corpus.schema_version: expected 1")

    if not non_empty_string(corpus.get("corpus_id")):
        failures.append("corpus.corpus_id: must be a non-empty string")

    required_gates = corpus.get("required_gates")
    if not isinstance(required_gates, list):
        failures.append("corpus.required_gates: must be a list")
    else:
        gate_set = set(required_gates)
        missing_gates = REQUIRED_GATES - gate_set
        extra_gates = gate_set - REQUIRED_GATES
        for gate in sorted(missing_gates):
            failures.append(f"corpus.required_gates: missing required gate '{gate}'")
        for gate in sorted(extra_gates):
            failures.append(f"corpus.required_gates: unknown gate '{gate}'")

    families = corpus.get("benchmark_families")
    count_limits = corpus.get("required_family_count", {})
    minimum = count_limits.get("minimum") if isinstance(count_limits, dict) else None
    maximum = count_limits.get("maximum") if isinstance(count_limits, dict) else None
    if not isinstance(families, list):
        failures.append("corpus.benchmark_families: must be a list")
        return failures

    if not isinstance(minimum, int) or not isinstance(maximum, int) or minimum < 1 or maximum < minimum:
        failures.append("corpus.required_family_count: expected integer minimum and maximum")
    elif not minimum <= len(families) <= maximum:
        failures.append(f"corpus.benchmark_families: expected {minimum}-{maximum} families, found {len(families)}")

    ids = [family.get("id", "") for family in families if isinstance(family, dict)]
    normalized_ids = [item.strip().casefold() for item in ids]
    if len(set(normalized_ids)) != len(ids):
        failures.append("corpus.benchmark_families: family ids must be unique")

    promoted_count = sum(1 for family in families if isinstance(family, dict) and family.get("promotion_status") == "promoted_app_side")
    if promoted_count < 2:
        failures.append("corpus.benchmark_families: expected at least 2 promoted_app_side families")

    for family in families:
        failures.extend(validate_family(family))
        if isinstance(family, dict) and "executable_proof" in family:
            failures.extend(validate_executable_proof(str(family.get("id", "<missing-id>")), family, family["executable_proof"], set(corpus["required_gates"])))

    return failures


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("corpus", nargs="?", default=str(DEFAULT_CORPUS))
    args = parser.parse_args()

    corpus_path = Path(args.corpus)
    with corpus_path.open(encoding="utf-8") as handle:
        corpus = json.load(handle)

    failures = validate_corpus(corpus)
    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    families = corpus["benchmark_families"]
    print(
        f"Validated {len(families)} complex Amiga benchmark families "
        f"with {len(corpus['required_gates'])} required gates."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
