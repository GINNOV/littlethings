#!/usr/bin/env python3
"""Build concrete fail-before/pass-after mutation-run contracts for repair seeds."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from build_complex_repair_execution_matrix import (
    DEFAULT_OUTPUT as DEFAULT_EXECUTION_MATRIX,
    build_execution_matrix,
    load_inputs,
    load_jsonl,
    validate_execution_matrix,
)


DEFAULT_OUTPUT = Path(__file__).with_name("complex_amiga_repair_mutation_runs.jsonl")
MUTATION_SWIFT_TEST = "testComplexAmigaRepairMutationRunsFailBeforeAndPassAfter"

REQUIRED_KEYS = {
    "schema_version",
    "corpus_id",
    "record_type",
    "mutation_run_id",
    "execution_id",
    "family_id",
    "failure_kind",
    "template_id",
    "broken_source_mutation",
    "before_repair_verification",
    "repair_application",
    "after_repair_verification",
    "training_use",
}

MUTATION_SPECS: dict[tuple[str, str], dict[str, Any]] = {
    ("mod_player_controls_complex", "missing_audio_dma_enable"): {
        "template_id": "mod-player-controls",
        "mutation_name": "remove_aud0_dma_enable",
        "verifier_channel": "runtime_evidence_contract",
        "expected_failure_snippet": "audio_dma_enable",
    },
    ("mod_player_controls_complex", "lost_follow_up_control"): {
        "template_id": "mod-player-controls",
        "mutation_name": "remove_stop_dispatch_marker",
        "verifier_channel": "source_verifier",
        "expected_failure_snippet": "Missing dispatch marker for Stop.",
    },
    ("double_buffered_bitplane_sprite_copper", "missing_front_back_pointer_swap"): {
        "template_id": "double-buffer-bitplane",
        "mutation_name": "misdirect_back_buffer_bpl1pt_write",
        "verifier_channel": "runtime_observation_contract",
        "expected_failure_snippet": "back_buffer_pointer_swap",
    },
    ("double_buffered_bitplane_sprite_copper", "missing_visible_frame_data"): {
        "template_id": "double-buffer-bitplane",
        "mutation_name": "remove_buffer_a_chip_data_label",
        "verifier_channel": "source_verifier",
        "expected_failure_snippet": "BufferA chip data",
    },
    ("blitter_bob_collision_bounds", "missing_blitter_wait"): {
        "template_id": "blitter-bob-collision-bounds",
        "mutation_name": "remove_post_bltsize_wait_loop",
        "verifier_channel": "semantic_verifier",
        "expected_failure_snippet": "missing blitter wait after BLTSIZE",
    },
    ("blitter_bob_collision_bounds", "unbounded_position_update"): {
        "template_id": "blitter-bob-collision-bounds",
        "mutation_name": "remove_right_edge_clamp_compare",
        "verifier_channel": "semantic_verifier",
        "expected_failure_snippet": "missing bounds clamp #288",
    },
    ("copper_runtime_raster_validation", "missing_copper_jump"): {
        "template_id": "bouncing-copper-bars",
        "mutation_name": "remove_copjmp1_activation",
        "verifier_channel": "runtime_evidence_contract",
        "expected_failure_snippet": "owned_copper_list_installed",
    },
    ("copper_runtime_raster_validation", "flat_runtime_frame"): {
        "template_id": "bouncing-copper-bars",
        "mutation_name": "flatten_model_and_copper_palette",
        "verifier_channel": "runtime_evidence_contract",
        "expected_failure_snippet": "model palette has fewer than two visible colors",
    },
    ("mouse_sprite_multiplex", "missing_sprite_pointer"): {
        "template_id": "mouse-sprite-multiplex",
        "mutation_name": "remove_spr1pt_pointer_write",
        "verifier_channel": "runtime_evidence_contract",
        "expected_failure_snippet": "spr1_pointer_write",
    },
    ("mouse_sprite_multiplex", "unpaced_sprite_update"): {
        "template_id": "mouse-sprite-multiplex",
        "mutation_name": "remove_vblank_wait_before_sprite_update",
        "verifier_channel": "runtime_evidence_contract",
        "expected_failure_snippet": "vblank_before_sprite_update",
    },
    ("intuition_window_tool", "unbalanced_library_close"): {
        "template_id": "intuition-window-tool",
        "mutation_name": "remove_closelibrary_cleanup",
        "verifier_channel": "source_proof",
        "expected_failure_snippet": "missing CloseLibrary(IntuitionBase) cleanup",
    },
    ("intuition_window_tool", "missing_close_window"): {
        "template_id": "intuition-window-tool",
        "mutation_name": "remove_closewindow_cleanup",
        "verifier_channel": "source_proof",
        "expected_failure_snippet": "missing CloseWindow(WindowPtr) cleanup",
    },
    ("clean_takeover_restore", "missing_dma_restore"): {
        "template_id": "clean-takeover",
        "mutation_name": "remove_dmacon_restore_sequence",
        "verifier_channel": "source_proof",
        "expected_failure_snippet": "missing DMA restore from OldDMACON",
    },
    ("clean_takeover_restore", "lost_emergency_restore"): {
        "template_id": "clean-takeover",
        "mutation_name": "reroute_restore_label_to_exit",
        "verifier_channel": "source_proof",
        "expected_failure_snippet": "mouse exit does not route through RestoreSystem path",
    },
}


def build_mutation_runs(corpus: dict[str, Any], execution_matrix: list[dict[str, Any]]) -> list[dict[str, Any]]:
    matrix_by_seed = {
        (row["family_id"], row["failure_kind"]): row
        for row in execution_matrix
    }
    rows: list[dict[str, Any]] = []
    for family in corpus["benchmark_families"]:
        proof = family["executable_proof"]
        runtime_contract = proof["runtime_evidence_contract"]
        for seed in family["repair_seeds"]:
            key = (family["id"], seed["failure_kind"])
            spec = MUTATION_SPECS[key]
            matrix_row = matrix_by_seed[key]
            rows.append(
                {
                    "schema_version": 1,
                    "corpus_id": corpus["corpus_id"],
                    "record_type": "repair_mutation_run",
                    "mutation_run_id": f"{matrix_row['proof_id']}::mutation-run",
                    "execution_id": matrix_row["execution_id"],
                    "proof_id": matrix_row["proof_id"],
                    "family_id": family["id"],
                    "family_title": family["title"],
                    "failure_kind": seed["failure_kind"],
                    "template_id": proof["template_id"],
                    "broken_source_mutation": {
                        "strategy": seed["broken_variant_strategy"],
                        "mutation_name": spec["mutation_name"],
                        "must_change_source": True,
                        "must_not_change_template_id": True,
                    },
                    "before_repair_verification": {
                        "must_fail": True,
                        "verifier_channel": spec["verifier_channel"],
                        "expected_failure_snippet": spec["expected_failure_snippet"],
                        "diagnostic_proof_test": seed["diagnostic_proof_test"],
                        "corpus_expected_diagnostic": seed["expected_diagnostic"],
                        "swift_test": MUTATION_SWIFT_TEST,
                    },
                    "repair_application": {
                        "strategy": "restore_minimal_verified_source_region_for_failure_kind",
                        "allowed_change": "narrow_patch_only",
                        "preserve_structured_model_identity": True,
                        "preserve_existing_non_conflicting_behavior": True,
                    },
                    "after_repair_verification": {
                        "must_pass": True,
                        "required_gates": corpus["required_gates"],
                        "runtime_evidence_contract": runtime_contract,
                        "source_proof_test": runtime_contract["source_proof_test"],
                        "swift_test": MUTATION_SWIFT_TEST,
                    },
                    "training_use": {
                        "negative_sample": "deterministically_mutated_source",
                        "positive_sample": "same_source_after_narrow_verified_repair",
                        "preference_order": [
                            "passes_fail_before_pass_after_mutation_run",
                            "passes_all_gates",
                            "compiles_only",
                            "plausible_but_unverified",
                        ],
                    },
                }
            )
    return rows


def validate_mutation_runs(corpus: dict[str, Any], rows: list[dict[str, Any]]) -> list[str]:
    failures: list[str] = []
    required_count = sum(len(family["repair_seeds"]) for family in corpus["benchmark_families"])
    ids = [row.get("mutation_run_id") for row in rows]
    if len(rows) != required_count:
        failures.append(f"expected {required_count} mutation-run rows, found {len(rows)}")
    if len(set(ids)) != len(ids):
        failures.append("mutation_run_id values must be unique")

    expected_keys = {
        (family["id"], seed["failure_kind"])
        for family in corpus["benchmark_families"]
        for seed in family["repair_seeds"]
    }
    actual_keys = {(row.get("family_id"), row.get("failure_kind")) for row in rows}
    for key in sorted(expected_keys - actual_keys):
        failures.append(f"{key[0]}::{key[1]}: missing mutation-run row")
    for key in sorted(actual_keys - expected_keys):
        failures.append(f"{key[0]}::{key[1]}: unknown mutation-run row")

    for row in rows:
        row_id = row.get("mutation_run_id", "<missing-id>")
        missing = REQUIRED_KEYS - set(row)
        for key in sorted(missing):
            failures.append(f"{row_id}: missing required key '{key}'")
        if row.get("record_type") != "repair_mutation_run":
            failures.append(f"{row_id}: record_type must be repair_mutation_run")
        if row.get("template_id") != MUTATION_SPECS[(row.get("family_id"), row.get("failure_kind"))]["template_id"]:
            failures.append(f"{row_id}: template id does not match mutation spec")

        before = row.get("before_repair_verification")
        if not isinstance(before, dict):
            failures.append(f"{row_id}: before_repair_verification must be an object")
        else:
            if before.get("must_fail") is not True:
                failures.append(f"{row_id}: before repair must fail")
            if before.get("swift_test") != MUTATION_SWIFT_TEST:
                failures.append(f"{row_id}: before repair must bind to {MUTATION_SWIFT_TEST}")
            if not before.get("expected_failure_snippet"):
                failures.append(f"{row_id}: before repair needs expected failure snippet")

        mutation = row.get("broken_source_mutation")
        if not isinstance(mutation, dict):
            failures.append(f"{row_id}: broken_source_mutation must be an object")
        else:
            if mutation.get("must_change_source") is not True:
                failures.append(f"{row_id}: mutation must change source")
            if mutation.get("must_not_change_template_id") is not True:
                failures.append(f"{row_id}: mutation must preserve template id")

        after = row.get("after_repair_verification")
        if not isinstance(after, dict):
            failures.append(f"{row_id}: after_repair_verification must be an object")
        else:
            if after.get("must_pass") is not True:
                failures.append(f"{row_id}: repaired source must pass")
            if after.get("required_gates") != corpus["required_gates"]:
                failures.append(f"{row_id}: after-repair gates must match corpus gates")
            if after.get("swift_test") != MUTATION_SWIFT_TEST:
                failures.append(f"{row_id}: after repair must bind to {MUTATION_SWIFT_TEST}")

        training_use = row.get("training_use")
        if not isinstance(training_use, dict):
            failures.append(f"{row_id}: training_use must be an object")
        else:
            preference_order = training_use.get("preference_order")
            if not isinstance(preference_order, list) or preference_order[0] != "passes_fail_before_pass_after_mutation_run":
                failures.append(f"{row_id}: mutation-run preference order must prioritize concrete before/after evidence")

    return failures


def rows_to_jsonl(rows: list[dict[str, Any]]) -> str:
    return "\n".join(json.dumps(row, sort_keys=True) for row in rows) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--corpus", default=str(Path(__file__).with_name("complex_amiga_benchmark_corpus.json")))
    parser.add_argument("--records", default=str(Path(__file__).with_name("complex_amiga_benchmark_records.jsonl")))
    parser.add_argument("--examples", default=str(Path(__file__).with_name("complex_amiga_repair_loop_examples.jsonl")))
    parser.add_argument("--proofs", default=str(Path(__file__).with_name("complex_amiga_repair_proofs.jsonl")))
    parser.add_argument("--execution-matrix", default=str(DEFAULT_EXECUTION_MATRIX))
    parser.add_argument("--output", default=str(DEFAULT_OUTPUT))
    parser.add_argument("--check", action="store_true", help="Fail if the generated mutation-run artifact is stale.")
    args = parser.parse_args()

    try:
        corpus, proofs = load_inputs(args)
        matrix_path = Path(args.execution_matrix)
        if matrix_path.exists():
            execution_matrix = load_jsonl(matrix_path)
        else:
            execution_matrix = build_execution_matrix(corpus, proofs)
        matrix_failures = validate_execution_matrix(corpus, execution_matrix)
        if matrix_failures:
            raise ValueError("\n".join(matrix_failures))
        rows = build_mutation_runs(corpus, execution_matrix)
        failures = validate_mutation_runs(corpus, rows)
    except (KeyError, ValueError) as error:
        print(str(error), file=sys.stderr)
        return 1

    if failures:
        for failure in failures:
            print(failure, file=sys.stderr)
        return 1

    output_path = Path(args.output)
    jsonl = rows_to_jsonl(rows)
    if args.check:
        if not output_path.exists():
            print(f"{output_path}: missing generated repair mutation runs", file=sys.stderr)
            return 1
        if output_path.read_text(encoding="utf-8") != jsonl:
            print(f"{output_path}: generated repair mutation runs are stale", file=sys.stderr)
            return 1
    else:
        output_path.write_text(jsonl, encoding="utf-8")

    print(f"Validated {len(rows)} concrete repair mutation runs from {len(corpus['benchmark_families'])} families.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
