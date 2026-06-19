#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYGROUND_DIR="$(cd "$ROOT_DIR/../AmigaPlayground" && pwd)"
REPO_AMILA_DIR="$(cd "$ROOT_DIR/.." && pwd)"
DEBUG_DIR="$ROOT_DIR/evaluation_debug"
REPORT_JSON="$DEBUG_DIR/model_quality_run_report.json"
SCORECARD_MD="$DEBUG_DIR/model_quality_scorecard.md"
LADDER_JSON="$DEBUG_DIR/asm_eval_ladder_summary.json"
VAMIGA_NOTES="$REPO_AMILA_DIR/vamiga.md"

RUN_LADDER=1
RUN_XCTEST=1
RUN_VAMIGA=0
MLX_URL="${MLX_URL:-http://localhost:1234}"

usage() {
  cat <<'EOF'
Usage: evaluate_model_quality.sh [options]

Runs the four-part Amiga model quality audit:
  1. Corpus / golden-source validators
  2. Raw model eval ladder (if MLX server is reachable)
  3. Integrated XCTest battery (xcodebuild)
  4. Optional vAmiga runtime smokes via XCTest + validate_emulator_runtime.py

vAmiga prerequisites are documented in ../vamiga.md. The runtime validator
already probes RetroShell on ports 8081 and 8080 to match vAmiga 4.2.x and
4.4+. App-side ini patching uses VAmigaServerConfigPatcher in AmigaPlayground.

Options:
  --no-ladder     Skip eval_ladder.py even if MLX is up
  --no-xctest     Skip AmigaPlayground XCTest battery
  --vamiga        Run focused blitter BOB vAmiga XCTest smoke
  --mlx-url URL   MLX OpenAI-compatible base URL (default: http://localhost:1234)
  -h, --help      Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-ladder) RUN_LADDER=0 ;;
    --no-xctest) RUN_XCTEST=0 ;;
    --vamiga) RUN_VAMIGA=1 ;;
    --mlx-url) MLX_URL="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

mkdir -p "$DEBUG_DIR"
python3 - <<'PY' "$REPORT_JSON"
import json, sys
from datetime import datetime, timezone
path = sys.argv[1]
payload = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "validators": {},
    "xctest": {},
    "vamiga": {"results": [], "notes": "../vamiga.md"},
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
PY

log() { printf '%s\n' "$*"; }

run_validator() {
  local name="$1"
  shift
  log "==> $name"
  if "$@"; then
    python3 - <<'PY' "$REPORT_JSON" "$name" "pass"
import json, sys
path, name, status = sys.argv[1:4]
with open(path, encoding="utf-8") as handle:
    report = json.load(handle)
report.setdefault("validators", {})[name] = status
with open(path, "w", encoding="utf-8") as handle:
    json.dump(report, handle, indent=2)
PY
  else
    python3 - <<'PY' "$REPORT_JSON" "$name" "fail"
import json, sys
path, name, status = sys.argv[1:4]
with open(path, encoding="utf-8") as handle:
    report = json.load(handle)
report.setdefault("validators", {})[name] = status
with open(path, "w", encoding="utf-8") as handle:
    json.dump(report, handle, indent=2)
PY
    return 1
  fi
}

resolve_rom_dir() {
  local candidate
  for candidate in \
    "${AMIGA_SMOKE_ROM_DIR:-}" \
    "$HOME/Desktop/Quarantine_Miga/roms" \
    "$HOME/Documents/FS-UAE/Kickstarts"; do
    if [[ -n "$candidate" && -d "$candidate" ]]; then
      printf '%s' "$candidate"
      return 0
    fi
  done
  return 1
}

patch_run_report() {
  python3 - <<'PY' "$REPORT_JSON" "$1" "$2"
import json, sys
path, key, value = sys.argv[1:4]
with open(path, encoding="utf-8") as handle:
    report = json.load(handle)
report.setdefault("xctest", {})[key] = value
with open(path, "w", encoding="utf-8") as handle:
    json.dump(report, handle, indent=2)
PY
}

append_vamiga_result() {
  python3 - <<'PY' "$REPORT_JSON" "$1" "$2" "$3"
import json, sys
path, family, success, summary = sys.argv[1:5]
with open(path, encoding="utf-8") as handle:
    report = json.load(handle)
report.setdefault("vamiga", {}).setdefault("results", []).append(
    {"family": family, "success": success == "true", "summary": summary}
)
with open(path, "w", encoding="utf-8") as handle:
    json.dump(report, handle, indent=2)
PY
}

log "Amiga model quality audit"
log "Root: $ROOT_DIR"
log "vAmiga notes: $VAMIGA_NOTES"

run_validator "validate_complex_benchmark_corpus" \
  python3 "$ROOT_DIR/validate_complex_benchmark_corpus.py"
run_validator "validate_complex_golden_sources" \
  python3 "$ROOT_DIR/validate_complex_golden_sources.py"
run_validator "validate_complex_goal_completion" \
  python3 "$ROOT_DIR/validate_complex_goal_completion.py"
python3 "$ROOT_DIR/build_complex_repair_execution_matrix.py" >/dev/null

if [[ "$RUN_LADDER" == "1" ]]; then
  if curl -fsS -o /dev/null "$MLX_URL/v1/models" 2>/dev/null; then
    log "==> eval_ladder (MLX reachable at $MLX_URL)"
    uv run python "$ROOT_DIR/eval_ladder.py" \
      --base-url "$MLX_URL" \
      --model default_model \
      --adapter adapters_asm \
      --ladder asm_capability_ladder.yaml \
      --package-adf \
      --output "$LADDER_JSON"
  else
    log "Skipping eval_ladder: MLX server not reachable at $MLX_URL"
    patch_run_report "eval_ladder" "skipped: MLX unreachable"
  fi
else
  patch_run_report "eval_ladder" "skipped: --no-ladder"
fi

if [[ "$RUN_XCTEST" == "1" ]]; then
  log "==> integrated XCTest battery (xcodebuild)"
  XCTEST_FILTER=(
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testAssistantPromptTemplateGoal2BenchmarkPromptsCompile
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testAssistantPromptTemplateGoal2BenchmarkPromptsPassSemanticGate
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testAssistantPromptTemplateGoal2BenchmarkPromptsGenerateBootableADFs
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexBlitterBOBFollowUpChainPreservesModelAndPassesSemanticGate
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexBlitterBOBFollowUpChainCompiles
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexCopperRuntimeRasterFollowUpChainPreservesModelAndCompiles
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexMouseSpriteMultiplexFollowUpChainPreservesModelAndCompiles
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexMODPlayerControlsCorpusFollowUpChainPreservesModelAndCompiles
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexIntuitionWindowToolFollowUpChainPreservesModelAndCompiles
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexCleanTakeoverRestoreFollowUpChainPreservesModelAndCompiles
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexBlitterBOBRejectedFollowUpsDoNotRouteToFreeFormMutation
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexCopperRuntimeRasterRejectedFollowUpsDoNotRouteToFreeFormMutation
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexMouseSpriteMultiplexRejectedFollowUpsDoNotRouteToFreeFormMutation
    -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexIntuitionWindowToolRejectedFollowUpsDoNotPatchSource
  )
  if (
    cd "$PLAYGROUND_DIR"
    xcodebuild test -scheme AmigaPlayground -destination 'platform=macOS' "${XCTEST_FILTER[@]}"
  ); then
    patch_run_report "integrated_battery" "pass"
  else
    patch_run_report "integrated_battery" "fail"
    exit 1
  fi
else
  patch_run_report "integrated_battery" "skipped: --no-xctest"
fi

if [[ "$RUN_VAMIGA" == "1" ]]; then
  log "==> vAmiga runtime smoke (see $VAMIGA_NOTES)"
  if ! command -v /Applications/vAmiga.app/Contents/MacOS/vAmiga >/dev/null 2>&1; then
    log "Skipping vAmiga: app not installed"
    patch_run_report "vamiga" "skipped: app missing"
  else
    ROM_DIR="$(resolve_rom_dir || true)"
    if [[ -z "$ROM_DIR" ]]; then
      log "Skipping vAmiga: no A500-compatible ROM directory found"
      patch_run_report "vamiga" "skipped: ROM dir missing"
    else
      echo "$ROM_DIR" > /private/tmp/AMIGA_SMOKE_ROM_DIR
      touch /private/tmp/AMIGA_RUN_COMPLEX_BLITTER_VAMIGA_SMOKE
      /usr/bin/osascript -e 'tell application id "dirkwhoffmann.vAmiga" to quit' >/dev/null 2>&1 || true
      /usr/bin/pkill -x vAmiga >/dev/null 2>&1 || true
      sleep 1
      if (
        cd "$PLAYGROUND_DIR"
        xcodebuild test -scheme AmigaPlayground -destination 'platform=macOS' \
          -only-testing:AmigaPlaygroundTests/AmigaPlaygroundTests/testComplexBlitterBOBStandaloneVAmigaRuntimeEvidenceWhenEnabled
      ); then
        append_vamiga_result "blitter_bob_collision_bounds" "true" "xcodebuild smoke passed"
        patch_run_report "vamiga" "pass (blitter BOB)"
      else
        append_vamiga_result "blitter_bob_collision_bounds" "false" "see validate_emulator_runtime.py manifest + $VAMIGA_NOTES"
        patch_run_report "vamiga" "fail (blitter BOB)"
      fi
    fi
  fi
else
  patch_run_report "vamiga" "skipped: pass --vamiga to enable"
fi

python3 "$ROOT_DIR/generate_model_quality_scorecard.py" \
  --ladder "$LADDER_JSON" \
  --run-report "$REPORT_JSON" \
  --output "$SCORECARD_MD"

log "Scorecard: $SCORECARD_MD"
log "Run report: $REPORT_JSON"