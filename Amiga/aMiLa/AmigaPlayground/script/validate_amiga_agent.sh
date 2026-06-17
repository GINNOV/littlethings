#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$ROOT_DIR/.build/codex-cache/clang" "$ROOT_DIR/.build/codex-cache/swiftpm"
export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$ROOT_DIR/.build/codex-cache/clang}"
export SWIFTPM_CUSTOM_CACHE_PATH="${SWIFTPM_CUSTOM_CACHE_PATH:-$ROOT_DIR/.build/codex-cache/swiftpm}"

run_filter() {
  local filter="$1"
  swift test --disable-sandbox --package-path "$ROOT_DIR" --filter "$filter"
}

run_filter "AmigaPlaygroundTests.testAmigaProgram"
run_filter "AmigaPlaygroundTests.testModelBacked"
run_filter "AmigaPlaygroundTests.testAssistantPromptRouter|AmigaPlaygroundTests.testAssistantSourceEditPlanner|AmigaPlaygroundTests.testAssistantReliabilityGatePolicy|AmigaPlaygroundTests.testAssistantStructuredPatchRejectionPresenter"
run_filter "AmigaPlaygroundTests.testDoubleBufferedBitplaneTemplate"
run_filter "AmigaPlaygroundTests.testAssistantPromptTemplate.*Compiles|AmigaPlaygroundTests.testAssistantPromptTemplateGoal2BenchmarkPromptsCompile|AmigaPlaygroundTests.testAssistantPromptTemplateBasicSamplesCompile"
run_filter "AmigaPlaygroundTests.testAssemblySemanticValidator"

if [[ "${AMIGA_RUN_VAMIGA_SMOKE:-0}" == "1" ]]; then
  AMIGA_RUN_DEFAULT_PROMPT_VAMIGA_SMOKE=1 swift test --package-path "$ROOT_DIR" --filter "AmigaPlaygroundTests.testDefaultPromptLibraryPromptsRunInVAmigaWhenEnabled"
fi
