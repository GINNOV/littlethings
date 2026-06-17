#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_AMILA_DIR="$(cd "$ROOT_DIR/.." && pwd)"
mkdir -p "$ROOT_DIR/.build/codex-cache/clang" "$ROOT_DIR/.build/codex-cache/swiftpm"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$ROOT_DIR/.build/codex-cache/clang}"
export SWIFTPM_CUSTOM_CACHE_PATH="${SWIFTPM_CUSTOM_CACHE_PATH:-$ROOT_DIR/.build/codex-cache/swiftpm}"

run_filter() {
  local filter="$1"
  swift test --disable-sandbox --package-path "$ROOT_DIR" --filter "$filter"
}

python3 "$REPO_AMILA_DIR/fine_tuning/validate_complex_benchmark_corpus.py"
python3 "$REPO_AMILA_DIR/fine_tuning/build_complex_benchmark_records.py" --check
python3 "$REPO_AMILA_DIR/fine_tuning/build_complex_repair_loop_examples.py" --check
python3 "$REPO_AMILA_DIR/fine_tuning/build_complex_repair_proofs.py" --check
python3 "$REPO_AMILA_DIR/fine_tuning/build_complex_repair_execution_matrix.py" --check
python3 "$REPO_AMILA_DIR/fine_tuning/build_complex_repair_mutation_runs.py" --check
python3 "$REPO_AMILA_DIR/fine_tuning/validate_complex_repair_verifier_transcripts.py"
python3 "$REPO_AMILA_DIR/fine_tuning/validate_complex_golden_sources.py"
python3 "$REPO_AMILA_DIR/fine_tuning/validate_complex_goal_completion.py"
python3 "$REPO_AMILA_DIR/fine_tuning/build_complex_repair_execution_matrix.py" --check --execute fast

run_filter "AmigaPlaygroundTests/testComplexIntuitionWindowToolFollowUpChainPreservesModelAndCompiles|AmigaPlaygroundTests/testComplexIntuitionWindowToolCompilesAndGeneratesBootableADF|AmigaPlaygroundTests/testComplexCleanTakeoverRestoreFollowUpChainPreservesModelAndCompiles|AmigaPlaygroundTests/testComplexCleanTakeoverRestoreCompilesAndGeneratesBootableADF|AmigaPlaygroundTests/testComplexBlitterBOBFollowUpChainCompiles|AmigaPlaygroundTests/testComplexCopperRuntimeRasterCompilesAndGeneratesBootableADF|AmigaPlaygroundTests/testComplexCopperRuntimeRasterFollowUpChainPreservesModelAndCompiles|AmigaPlaygroundTests/testComplexMouseSpriteMultiplexCompilesAndGeneratesBootableADF|AmigaPlaygroundTests/testComplexMouseSpriteMultiplexFollowUpChainPreservesModelAndCompiles|AmigaPlaygroundTests/testComplexMODPlayerControlsCompilesAndGeneratesBootableADF|AmigaPlaygroundTests/testComplexMODPlayerControlsCorpusFollowUpChainPreservesModelAndCompiles|AmigaPlaygroundTests/testComplexDoubleBufferedBitplaneCompilesAndGeneratesBootableADF|AmigaPlaygroundTests/testAssistantPromptTemplateComplexBlitterBOBCollisionCompiles|AmigaPlaygroundTests/testAssistantPromptTemplateComplexBlitterBOBCollisionGeneratesBootableADF"
run_filter "AmigaPlaygroundTests/testAssistantPromptRouterReplaysDoubleBufferedSpriteCopperFollowUpsWithoutFallback|AmigaPlaygroundTests/testComplexBlitterBOBFollowUpChainPreservesModelAndPassesSemanticGate|AmigaPlaygroundTests/testComplexBlitterBOBFollowUpChainCompiles"
run_filter "AmigaPlaygroundTests.testComplexAmigaBenchmarkRepairExecutionMatrixBindsProofsToSwiftTests|AmigaPlaygroundTests.testComplexAmigaRepairMutationRunsFailBeforeAndPassAfter|AmigaPlaygroundTests.testComplexAmigaRepairMutationVerifierTranscriptsMatchCurrentVerifierOutput|AmigaPlaygroundTests.testComplexAmigaGoldenSourcesMatchCurrentVerifiedOutputs"

if [[ "${AMIGA_RUN_VAMIGA_SMOKE:-0}" == "1" ]]; then
  AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE=1 swift test --package-path "$ROOT_DIR" --filter "AmigaPlaygroundTests.testDefaultPromptLibraryPromptsRunInVAmigaWhenEnabled"
fi

if [[ "${AMIGA_RUN_VAMIGA_SENTINEL_SMOKE:-0}" == "1" ]]; then
  run_filter "AmigaPlaygroundTests.testVAmigaRuntimeSmokeHandcraftedSentinelWhenEnabled"
fi

if [[ "${AMIGA_RUN_COMPLEX_VAMIGA_SMOKE:-0}" == "1" ]]; then
  export AMIGA_RUN_COMPLEX_INTUITION_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_CLEAN_TAKEOVER_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_BLITTER_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_COPPER_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_COPPER_FOLLOWUP_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_MOUSE_SPRITE_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_MOUSE_SPRITE_FOLLOWUP_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_MOD_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_MOD_FOLLOWUP_VAMIGA_SMOKE=1
  export AMIGA_RUN_COMPLEX_DOUBLE_BUFFER_VAMIGA_SMOKE=1
  run_filter "AmigaPlaygroundTests.testComplex.*StandaloneVAmigaRuntimeEvidenceWhenEnabled"
fi
