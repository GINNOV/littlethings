#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_SYSTEM=/dev/null
export GIT_OPTIONAL_LOCKS=0
repo_root=$(/usr/bin/git -C "$project_root" rev-parse --show-toplevel)
repo_ceiling=$(CDPATH= cd -- "$repo_root/.." && pwd -P)
export GIT_CEILING_DIRECTORIES="$repo_ceiling"
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: qa-task.sh <1-33> <happy|failure>'
    exit 0
fi
if [ "$#" -ne 2 ]; then
    printf '%s\n' 'Usage: qa-task.sh <1-33> <happy|failure>' >&2
    exit 2
fi
case "$1" in 2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33) ;; *) printf '%s\n' 'ERROR[unsupported-task]: task manifest has not landed yet' >&2; exit 2 ;; esac
case "$2" in happy|failure) ;; *) printf '%s\n' 'ERROR[unknown-mode]' >&2; exit 2 ;; esac

for variable in $(env | awk -F= '$1 ~ /^(ARMAGEDDON_LIVE_|ARMAGEDDON_OPERATOR_|HUENIT_LIVE_|ARMAGEDDON_(CAMERA|SERIAL|DEVICE)_|HUENIT_(CAM|ARM)_)/ { print $1 }'); do
    unset "$variable"
done
unset ARMAGEDDON_OPERATOR_PRESENT ARMAGEDDON_OPERATOR_CONFIRMATION ARMAGEDDON_DEVICE_OVERRIDE ARMAGEDDON_SERIAL_PORT_OVERRIDE

if [ -n "${ARMAGEDDON_TASK_ROOT:-}" ]; then
    task_root=$ARMAGEDDON_TASK_ROOT
else
    attempt=$("$project_root/scripts/current-evidence-dir.sh")
    parent=$(uuidgen | tr '[:upper:]' '[:lower:]')
    nonce=$(uuidgen | tr '[:upper:]' '[:lower:]')
    mkdir -m 700 "$attempt/runs"
    mkdir -m 700 "$attempt/runs/$parent"
    mkdir -m 700 "$attempt/runs/$parent/task-$1"
    mkdir -m 700 "$attempt/runs/$parent/task-$1/$nonce"
    task_root=$attempt/runs/$parent/task-$1/$nonce
fi

cd "$project_root"
export SWIFTPM_CUSTOM_CACHES_DIR="$task_root/swiftpm-caches"

extract_named_screenshots() {
    result="$1"
    dest="$2"
    export_dir=$(mktemp -d /private/tmp/armageddon-xcresult-attachments.XXXXXX)
    xcrun xcresulttool export attachments --path "$result" --output-path "$export_dir" >/dev/null
    python3 - "$export_dir" "$dest" <<'PY'
import json, re, shutil, sys
from pathlib import Path
src, dest = Path(sys.argv[1]), Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)
copied = 0
manifest = src / "manifest.json"
suffix = re.compile(r"_\d+_[0-9A-Fa-f-]{8,}$")

def canonical_name(raw: str) -> str:
    stem = Path(raw).stem
    stem = suffix.sub("", stem)
    return f"{stem}.png"

def walk(node):
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from walk(value)
    elif isinstance(node, list):
        for value in node:
            yield from walk(value)

if manifest.is_file():
    payload = json.loads(manifest.read_text())
    for node in walk(payload):
        exported = node.get("exportedFileName") or node.get("exportedFilePath") or node.get("path")
        suggested = (
            node.get("suggestedHumanReadableName")
            or node.get("suggestedName")
            or node.get("name")
            or exported
        )
        if not exported or not suggested:
            continue
        file = Path(exported) if Path(exported).is_absolute() else src / exported
        if not file.is_file() or file.suffix.lower() != ".png":
            continue
        shutil.copy2(file, dest / canonical_name(suggested))
        copied += 1
if copied == 0:
    for file in src.rglob("*.png"):
        shutil.copy2(file, dest / canonical_name(file.name))
PY
}

run_swift_task() {
    task="$1"
    mode="$2"
    filter="$3"
    transcript="$task_root/camera-ml-app.txt"
    build_root="$task_root/build"
    swift test --disable-sandbox --parallel --scratch-path "$build_root" --filter "$filter" >"$transcript" 2>&1
    [ -s "$transcript" ] || { printf '%s\n' "ERROR[empty-task-$task-transcript]" >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":%s,"mode":"%s","filter":"%s","transcript":"%s","transcriptSha256":"%s","outcome":"PASS"}\n' \
        "$task" "$mode" "$filter" "$transcript" "$transcript_sha256" >"$task_root/camera-ml-app.json"
    printf 'PASS task=%s mode=%s root=%s\n' "$task" "$mode" "$task_root"
    exit 0
}

if [ "$1" = "2" ]; then
    exec python3 scripts/qa_task_runner.py "$1" "$2" "$task_root"
fi

if [ "$1" = "5" ]; then
    run_swift_task 5 "$2" DeviceCapabilityTests
fi

if [ "$1" = "6" ]; then
    run_swift_task 6 "$2" AppStateRestorationTests
fi

if [ "$1" = "7" ]; then
    if [ "$2" = "happy" ]; then
        run_swift_task 7 "$2" HuenitArmPortTests
    else
        run_swift_task 7 "$2" forbiddenG28WritesNothing
    fi
fi

if [ "$1" = "8" ]; then
    run_swift_task 8 "$2" EmergencyStopTests
fi

if [ "$1" = "9" ]; then
    transcript="$task_root/camera-ml-app.txt"
    validation_root=$(mktemp -d "${TMPDIR:-/tmp}/armageddon-task9.XXXXXX")
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    (
        cd "$validation_root"
        swift test --disable-sandbox --filter ManualArmControlTests
    ) >"$transcript" 2>&1
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":9,"mode":"%s","filter":"ManualArmControlTests","validationRoot":"%s","transcript":"%s","transcriptSha256":"%s","outcome":"PASS"}\n' \
        "$2" "$validation_root" "$transcript" "$transcript_sha256" >"$task_root/camera-ml-app.json"
    printf 'PASS task=9 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "10" ]; then
    transcript="$task_root/camera-ml-app.txt"
    validation_root=$(mktemp -d "${TMPDIR:-/tmp}/armageddon-task10.XXXXXX")
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    (
        cd "$validation_root"
        if [ "$2" = "happy" ]; then
            swift test --disable-sandbox --filter requestThenSelect
        else
            swift test --disable-sandbox --filter unplugAndRecover
        fi
    ) >"$transcript" 2>&1
    if [ "$2" = "failure" ]; then
        result="$task_root/camera-ml-app.xcresult"
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp -destination 'platform=macOS' \
            -parallel-testing-enabled NO \
            -derivedDataPath "$task_root/build" -resultBundlePath "$result" test \
            -only-testing:ArmageddonUITests/AppShellUITests/testCameraDisconnectCancelsWorkAndOffersRescan >>"$transcript" 2>&1
        [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-10-xcresult]' >&2; exit 1; }
    fi
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":10,"mode":"%s","filter":"%s","validationRoot":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "requestThenSelect|unplugAndRecover" "$validation_root" "$transcript" "$transcript_sha256" "${result:-}" >"$task_root/camera-ml-app.json"
    printf 'PASS task=10 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "4" ]; then
    run_swift_task 4 "$2" LocalArtifactStorageTests
fi

if [ "$1" = "11" ]; then
    transcript="$task_root/camera-ml-app.txt"
    validation_root=$(mktemp -d "${TMPDIR:-/tmp}/armageddon-task11.XXXXXX")
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    if [ "$2" = "happy" ]; then
        filter='sixtySeconds'
        filter_target='CapturePipelinePerformanceTests/sixtySeconds'
    else
        filter='stopCancelsSourceGeneration'
        filter_target='NativeCaptureSessionTests/stopCancelsSourceGeneration'
    fi
    (
        cd "$validation_root"
        swift test --disable-sandbox --filter "$filter_target"
    ) >"$transcript" 2>&1
    probe="$task_root/probe.json"
    (
        cd "$validation_root"
        swift run --disable-sandbox --quiet CaptureQAProbe "$2"
    ) >"$probe" 2>>"$transcript"
    probe_json=$(tr -d '\n' <"$probe")
    printf '%s\n' "CAPTURE_QA_PROBE=$probe_json" >>"$transcript"
    result="$task_root/camera-ml-app.xcresult"
    GIT_CEILING_DIRECTORIES="$repo_ceiling" xcodebuild -quiet -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -configuration Debug -destination 'platform=macOS' \
        -derivedDataPath "$task_root/build" -resultBundlePath "$result" build-for-testing >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-11-xcresult]' >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":11,"mode":"%s","filter":"%s","probe":%s,"transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter_target" "$probe_json" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=11 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "12" ]; then
    transcript="$task_root/camera-ml-app.txt"
    validation_root=$(mktemp -d "${TMPDIR:-/tmp}/armageddon-task12.XXXXXX")
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    if [ "$2" = "happy" ]; then
        filter_target='DetectorContractTests/letterboxedMirrored'
    else
        filter_target='DetectorContractTests/multiArrayContract'
    fi
    (
        cd "$validation_root"
        swift test --disable-sandbox --filter "$filter_target"
    ) >"$transcript" 2>&1
    probe="$task_root/probe.json"
    (
        cd "$validation_root"
        swift run --disable-sandbox --quiet DetectorQAProbe "$2"
    ) >"$probe" 2>>"$transcript"
    probe_json=$(tr -d '\n' <"$probe")
    printf '%s\n' "DETECTOR_QA_PROBE=$probe_json" >>"$transcript"
    result="$task_root/camera-ml-app.xcresult"
    GIT_CEILING_DIRECTORIES="$repo_ceiling" xcodebuild -quiet -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -configuration Debug -destination 'platform=macOS' \
        -derivedDataPath "$task_root/build" -resultBundlePath "$result" build-for-testing >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-12-xcresult]' >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":12,"mode":"%s","filter":"%s","probe":%s,"transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter_target" "$probe_json" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=12 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "13" ]; then
    transcript="$task_root/camera-ml-app.txt"
    fixture_dir="$task_root/generated-fixture"
    mkdir -m 700 "$fixture_dir"
    generated_manifest="$fixture_dir/fixture.armmodel.json"
    probe="$task_root/probe.json"
    validation_root=$(mktemp -d /private/tmp/armageddon-task13.XXXXXX)
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    if [ "$2" = "happy" ]; then
        filter_target='ModelRegistryTests/activateRollback'
    else
        filter_target='ModelRegistryTests/corruptedV3KeepsPreviousActive'
    fi
    (
        cd "$validation_root"
        swift run --disable-sandbox --quiet --scratch-path "$task_root/build" ModelFixtureGenerator --output "$generated_manifest"
        swift run --disable-sandbox --quiet --scratch-path "$task_root/build" ModelRegistryQAProbe --manifest "$generated_manifest" --root "$task_root/registry" --mode "$2" >"$probe"
        swift test --disable-sandbox --filter "$filter_target"
    ) >"$transcript" 2>&1
    result="$task_root/camera-ml-app.xcresult"
    GIT_CEILING_DIRECTORIES="$repo_ceiling" xcodebuild -quiet -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -configuration Debug -destination 'platform=macOS' \
        -derivedDataPath "$task_root/build-xcode" -resultBundlePath "$result" build-for-testing >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-13-xcresult]' >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    generated_sha256=$(shasum -a 256 "$generated_manifest" | awk '{print $1}')
    probe_json=$(tr -d '\n' <"$probe")
    printf '{"task":13,"mode":"%s","filter":"%s","probe":%s,"generatedManifest":"%s","generatedManifestSha256":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter_target" "$probe_json" "$generated_manifest" "$generated_sha256" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=13 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "14" ]; then
    transcript="$task_root/camera-ml-app.txt"
    probe="$task_root/probe.json"
    validation_root=$(mktemp -d /private/tmp/armageddon-task14.XXXXXX)
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    if [ "$2" = "happy" ]; then
        filter_target='VisionInferenceIntegrationTests/constantModel'
    else
        filter_target='VisionInferenceIntegrationTests/unloadMidRequest'
    fi
    (
        cd "$validation_root"
        swift run --disable-sandbox --quiet --scratch-path "$task_root/build-swift" VisionInferenceQAProbe \
            "$validation_root/Tests/ArmageddonCoreTests/Fixtures/constant-detector.mlmodel" "$2" >"$probe"
        swift test --disable-sandbox --filter "$filter_target"
        swift test --disable-sandbox --filter VisionInferenceSchedulerTests/tenThousandFramesKeepQueueDepthOne
    ) >"$transcript" 2>&1
    result="$task_root/camera-ml-app.xcresult"
    GIT_CEILING_DIRECTORIES="$repo_ceiling" xcodebuild -quiet -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -configuration Debug -destination 'platform=macOS' \
        -derivedDataPath "$task_root/build-xcode" -resultBundlePath "$result" build-for-testing >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-14-xcresult]' >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    probe_json=$(tr -d '\n' <"$probe")
    printf '{"task":14,"mode":"%s","filter":"%s","probe":%s,"transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter_target" "$probe_json" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=14 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "15" ]; then
    transcript="$task_root/camera-ml-app.txt"
    probe="$task_root/probe.json"
    validation_root=$(mktemp -d /private/tmp/armageddon-task15.XXXXXX)
    rsync -a --exclude '.git' --exclude '.build' "$project_root/" "$validation_root/"
    if [ "$2" = "happy" ]; then
        filter_target='PerformanceTelemetryTests/sixtySecondsAtThirtyFPS'
    else
        filter_target='PerformanceTelemetryTests/slowInferenceGate'
    fi
    (
        cd "$validation_root"
        swift run --disable-sandbox --quiet --scratch-path "$task_root/build-swift" PerformanceTelemetryQAProbe "$2" >"$probe"
        swift test --disable-sandbox --filter "$filter_target"
    ) >"$transcript" 2>&1
    result="$task_root/camera-ml-app.xcresult"
    GIT_CEILING_DIRECTORIES="$repo_ceiling" xcodebuild -quiet -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -configuration Debug -destination 'platform=macOS' \
        -derivedDataPath "$task_root/build-xcode" -resultBundlePath "$result" build-for-testing >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-15-xcresult]' >&2; exit 1; }
    probe_json=$(tr -d '\n' <"$probe")
    printf '%s\n' "PERFORMANCE_TELEMETRY_QA_PROBE=$probe_json" >>"$transcript"
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":15,"mode":"%s","filter":"%s","probe":%s,"transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter_target" "$probe_json" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=15 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "16" ]; then
    transcript="$task_root/camera-ml-app.txt"
    result="$task_root/camera-ml-app.xcresult"
    mkdir -m 700 "$task_root/screenshots"
    if [ "$2" = "happy" ]; then
        filter='-only-testing:ArmageddonUITests/AppShellUITests/testLiveWorkspaceSelectsPausesCapturesAndOpensManualDrawer -only-testing:ArmageddonUITests/AppShellUITests/testLiveWorkspaceOverlayCoordinatesAtSupportedWindowSizes -only-testing:ArmageddonUITests/AppShellUITests/testModelFailureAndNoDeviceStatesOfferRecovery'
        expected='live-workspace-core-flow'
    else
        filter='-only-testing:ArmageddonUITests/AppShellUITests/testCameraDisconnectCancelsWorkAndOffersRescan'
        expected='live-workspace-disconnected'
    fi
    ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
    TEST_RUNNER_ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -destination 'platform=macOS' -derivedDataPath "$task_root/build" -resultBundlePath "$result" test $filter >"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-16-xcresult]' >&2; exit 1; }
    extract_named_screenshots "$result" "$task_root/screenshots"
    [ -s "$task_root/screenshots/$expected.png" ] || { printf '%s\n' "ERROR[missing-task-16-screenshot]" >&2; exit 1; }
    if [ "$2" = "happy" ]; then
        for size in 1100x720 1280x800 1440x900; do
            [ -s "$task_root/screenshots/live-overlay-$size.png" ] || {
                printf '%s\n' "ERROR[missing-task-16-overlay-screenshot]: $size" >&2
                exit 1
            }
        done
    fi
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":16,"mode":"%s","filter":"%s","screenshot":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter" "$task_root/screenshots/$expected.png" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=16 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "17" ]; then
    run_swift_task 17 "$2" CaptureSessionTests
fi

if [ "$1" = "18" ]; then
    transcript="$task_root/camera-ml-app.txt"
    recorded="$task_root/recorded-transcript.txt"
    probe="$task_root/camera-ml-app.json"
    printf '%s\n' 'identity=HUENIT_CAM' 'baud=115200' 'frame=0,10,20,30,40' >"$recorded"
    swift run --disable-sandbox --quiet --scratch-path "$task_root/build" HuenitCameraProbe \
        --transcript "$recorded" --output "$probe" >"$transcript" 2>&1
    swift test --disable-sandbox --parallel --scratch-path "$task_root/build-tests" --filter HuenitCameraTests >>"$transcript" 2>&1
    [ -s "$probe" ] || { printf '%s\n' 'ERROR[missing-task-18-probe]' >&2; exit 1; }
    printf 'PASS task=18 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "19" ]; then
    run_swift_task 19 "$2" HuenitCameraTests
fi

if [ "$1" = "20" ]; then
    run_swift_task 20 "$2" HuenitCameraTests
fi

if [ "$1" = "21" ]; then
    run_swift_task 21 "$2" DiagnosticsTests
fi

if [ "$1" = "22" ]; then
    transcript="$task_root/camera-ml-app.txt"
    result="$task_root/camera-ml-app.xcresult"
    mkdir -m 700 "$task_root/screenshots"
    ./scripts/check-accessibility-contract.sh >"$transcript" 2>&1
    if [ "$2" = "happy" ]; then
        filter='-only-testing:ArmageddonUITests/AppShellUITests/testModelsAndDiagnosticsWorkflowShowsBoundedLocalActions'
        expected='models-workspace-empty'
    else
        filter='-only-testing:ArmageddonUITests/AppShellUITests/testModelsWorkspaceEmptyStateRemainsSafe'
        expected='models-workspace-empty-safe'
    fi
    ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
    TEST_RUNNER_ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -destination 'platform=macOS' -parallel-testing-enabled NO \
        -derivedDataPath "$task_root/build" -resultBundlePath "$result" test $filter >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-22-xcresult]' >&2; exit 1; }
    extract_named_screenshots "$result" "$task_root/screenshots"
    [ -s "$task_root/screenshots/$expected.png" ] || { printf '%s\n' "ERROR[missing-task-22-screenshot]: $expected" >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":22,"mode":"%s","filter":"%s","screenshot":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter" "$task_root/screenshots/$expected.png" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=22 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "23" ]; then
    run_swift_task 23 "$2" PlanarCalibrationTests
fi

if [ "$1" = "25" ]; then
    run_swift_task 25 "$2" SafetyPolicyTests
fi

if [ "$1" = "26" ]; then
    run_swift_task 26 "$2" TargetProposalTests
fi

if [ "$1" = "27" ]; then
    transcript="$task_root/camera-ml-app.txt"
    result="$task_root/camera-ml-app.xcresult"
    mkdir -m 700 "$task_root/screenshots"
    swift test --disable-sandbox --scratch-path "$task_root/package-build" --filter RunCoordinatorTests >"$transcript" 2>&1
    if [ "$2" = "happy" ]; then
        ui_filter='-only-testing:ArmageddonUITests/AppShellUITests/testCalibratedDryRunExecutesOneSupervisedMove'
        expected='runs-supervised-fixture-completed'
    else
        ui_filter='-only-testing:ArmageddonUITests/AppShellUITests/testRunsSurfaceShowsFailClosedDryRunPrerequisites'
        expected='runs-fail-closed-dry-run'
    fi
    ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
    TEST_RUNNER_ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -destination 'platform=macOS' -parallel-testing-enabled NO \
        -derivedDataPath "$task_root/xcode" -resultBundlePath "$result" test "$ui_filter" >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-27-xcresult]' >&2; exit 1; }
    extract_named_screenshots "$result" "$task_root/screenshots"
    [ -s "$task_root/screenshots/$expected.png" ] || { printf '%s\n' "ERROR[missing-task-27-screenshot]: $expected" >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    screenshot_sha256=$(shasum -a 256 "$task_root/screenshots/$expected.png" | awk '{print $1}')
    printf '{"task":27,"mode":"%s","swiftFilter":"RunCoordinatorTests","uiFilter":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","screenshot":"%s","screenshotSha256":"%s","outcome":"PASS"}\n' \
        "$2" "$ui_filter" "$transcript" "$transcript_sha256" "$result" "$task_root/screenshots/$expected.png" "$screenshot_sha256" >"$task_root/camera-ml-app.json"
    printf 'PASS task=27 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "28" ]; then
    run_swift_task 28 "$2" AppStateRestorationTests
fi

if [ "$1" = "29" ]; then
    transcript="$task_root/camera-ml-app.txt"
    result="$task_root/camera-ml-app.xcresult"
    mkdir -m 700 "$task_root/screenshots"
    ./scripts/check-accessibility-contract.sh >"$transcript" 2>&1
    if [ "$2" = "happy" ]; then
        filters='-only-testing:ArmageddonUITests/AppShellUITests/testSidebarAndKeyboardNavigationStopsAndCapturesAppearances -only-testing:ArmageddonUITests/AppShellUITests/testLiveWorkspaceSelectsPausesCapturesAndOpensManualDrawer'
        expected='app-shell-light-1280x800'
    else
        filters='-only-testing:ArmageddonUITests/AppShellUITests/testCameraDisconnectCancelsWorkAndOffersRescan'
        expected='live-workspace-disconnected'
    fi
    ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
    TEST_RUNNER_ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -destination 'platform=macOS' -derivedDataPath "$task_root/build" -resultBundlePath "$result" test $filters >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-29-xcresult]' >&2; exit 1; }
    extract_named_screenshots "$result" "$task_root/screenshots"
    [ -s "$task_root/screenshots/$expected.png" ] || { printf '%s\n' "ERROR[missing-task-29-screenshot]: $expected" >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":29,"mode":"%s","filter":"%s","screenshot":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filters" "$task_root/screenshots/$expected.png" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=29 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "30" ]; then
    transcript="$task_root/camera-ml-app.txt"
    result="$task_root/camera-ml-app.xcresult"
    mkdir -m 700 "$task_root/screenshots"
    first_build="$task_root/build-first"
    second_build="$task_root/build-second"
    probe_build="$task_root/probe-build"
    probe_warmup="$task_root/performance-probe-warmup.json"
    probe_measured="$task_root/performance-probe-measured.json"
    resource_warmup="$task_root/performance-resource-warmup.txt"
    resource_measured="$task_root/performance-resource-measured.txt"
    resource_receipt="$task_root/performance-resource.json"
    swift test --disable-sandbox --scratch-path "$first_build" >"$transcript" 2>&1
    swift test --disable-sandbox --scratch-path "$second_build" >>"$transcript" 2>&1
    swift build --disable-sandbox --quiet --scratch-path "$probe_build" --product PerformanceTelemetryQAProbe >>"$transcript" 2>&1
    performance_probe=$(find "$probe_build" -type f -path '*/debug/PerformanceTelemetryQAProbe' -perm -111 -print -quit)
    [ -n "$performance_probe" ] || { printf '%s\n' 'ERROR[missing-task-30-performance-probe]' >&2; exit 1; }
    /usr/bin/time -l "$performance_probe" "$2" >"$probe_warmup" 2>"$resource_warmup"
    /usr/bin/time -l "$performance_probe" "$2" >"$probe_measured" 2>"$resource_measured"
    warmup_rss=$(awk '$2 == "maximum" && $3 == "resident" && $4 == "set" { print $1; exit }' "$resource_warmup")
    measured_rss=$(awk '$2 == "maximum" && $3 == "resident" && $4 == "set" { print $1; exit }' "$resource_measured")
    [ -n "$warmup_rss" ] || { printf '%s\n' 'ERROR[missing-task-30-warmup-rss]' >&2; exit 1; }
    [ -n "$measured_rss" ] || { printf '%s\n' 'ERROR[missing-task-30-measured-rss]' >&2; exit 1; }
    rss_growth=$((measured_rss - warmup_rss))
    rss_growth_budget=33554432
    absolute_rss_budget=268435456
    rss_within_budget=true
    [ "$rss_growth" -le "$rss_growth_budget" ] || rss_within_budget=false
    [ "$measured_rss" -le "$absolute_rss_budget" ] || rss_within_budget=false
    [ "$rss_within_budget" = true ] || { printf '%s\n' 'ERROR[task-30-rss-budget]' >&2; exit 1; }
    if [ "$2" = "happy" ]; then
        jq -e '.simulatedDurationNanoseconds == 3600000000000 and .sampleCount == 108000 and .windowCapacity == 120 and .maximumQueueDepth <= 1 and .targetingAvailable == true' "$probe_measured" >/dev/null
    else
        jq -e '.simulatedDurationNanoseconds == 0 and .sampleCount == 1 and .windowCapacity == 120 and .health == "slow" and .targetingAvailable == false' "$probe_measured" >/dev/null
    fi
    printf '{"mode":"%s","warmupMaxRSSBytes":%s,"measuredMaxRSSBytes":%s,"rssGrowthBytes":%s,"rssGrowthBudgetBytes":%s,"absoluteMaxRSSBytes":%s,"rssWithinBudget":%s,"warmupProbe":"%s","measuredProbe":"%s"}\n' \
        "$2" "$warmup_rss" "$measured_rss" "$rss_growth" "$rss_growth_budget" "$absolute_rss_budget" "$rss_within_budget" "$probe_warmup" "$probe_measured" >"$resource_receipt"
    printf 'PERFORMANCE_PROBE_WARMUP=%s\n' "$(cat "$probe_warmup")" >>"$transcript"
    printf 'PERFORMANCE_PROBE_MEASURED=%s\n' "$(cat "$probe_measured")" >>"$transcript"
    printf 'PERFORMANCE_RESOURCE=%s\n' "$(cat "$resource_receipt")" >>"$transcript"
    if [ "$2" = "happy" ]; then
        filters='-only-testing:ArmageddonUITests/AppShellUITests/testSidebarAndKeyboardNavigationStopsAndCapturesAppearances -only-testing:ArmageddonUITests/AppShellUITests/testLiveWorkspaceSelectsPausesCapturesAndOpensManualDrawer -only-testing:ArmageddonUITests/AppShellUITests/testTask30CapturesCompleteAppearanceMatrix'
        expected='app-shell-light-1280x800'
    else
        filters='-only-testing:ArmageddonUITests/AppShellUITests/testCameraDisconnectCancelsWorkAndOffersRescan'
        expected='live-workspace-disconnected'
    fi
    ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
    TEST_RUNNER_ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -destination 'platform=macOS' -derivedDataPath "$task_root/xcode" -resultBundlePath "$result" test $filters >>"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-30-xcresult]' >&2; exit 1; }
    extract_named_screenshots "$result" "$task_root/screenshots"
    [ -s "$task_root/screenshots/$expected.png" ] || { printf '%s\n' "ERROR[missing-task-30-screenshot]: $expected" >&2; exit 1; }
    if [ "$2" = "happy" ]; then
        for appearance in light dark contrast; do
            for size in 1100x720 1280x800 1440x900 1728x1117; do
                [ -s "$task_root/screenshots/task30-$appearance-$size.png" ] || {
                    printf '%s\n' "ERROR[missing-task-30-matrix-screenshot]: task30-$appearance-$size" >&2
                    exit 1
                }
            done
        done
    fi
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    probe_sha256=$(shasum -a 256 "$probe_measured" | awk '{print $1}')
    resource_sha256=$(shasum -a 256 "$resource_receipt" | awk '{print $1}')
    printf '{"task":30,"mode":"%s","filters":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","screenshot":"%s","performanceProbe":"%s","performanceProbeSha256":"%s","resourceReceipt":"%s","resourceReceiptSha256":"%s","outcome":"PASS"}\n' \
        "$2" "$filters" "$transcript" "$transcript_sha256" "$result" "$task_root/screenshots/$expected.png" "$probe_measured" "$probe_sha256" "$resource_receipt" "$resource_sha256" >"$task_root/camera-ml-app.json"
    printf 'PASS task=30 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "31" ]; then
    transcript="$task_root/camera-ml-app.txt"
    release_root="$task_root/release"
    if ARMAGEDDON_DEVELOPER_IDENTITY= ARMAGEDDON_NOTARY_PROFILE= ./scripts/package-release.sh "$release_root" >"$transcript" 2>&1; then
        release_status=0
    else
        release_status=$?
    fi
    [ "$release_status" -eq 3 ] || { printf '%s\n' "ERROR[release-classification]: expected exit 3, got $release_status" >&2; exit 1; }
    classification="$release_root/release-classification.json"
    grep -q 'BLOCKED_MISSING_SIGNING_CREDENTIAL' "$classification" || { printf '%s\n' 'ERROR[release-classification]: missing credential classification' >&2; exit 1; }
    for artifact in entitlements.plist network-audit.json bundle-manifest.json sbom.json release-artifacts.sha256; do
        [ -s "$release_root/$artifact" ] || { printf '%s\n' "ERROR[release-artifact]: $artifact" >&2; exit 1; }
    done
    if [ "$2" = "failure" ]; then
        app=$(find "$release_root/DerivedData/Build/Products/Release/Armageddon.app" -type f -not -path '*/_CodeSignature/*' -print | LC_ALL=C sort | head -1)
        [ -n "$app" ] || { printf '%s\n' 'ERROR[tamper-fixture]: no bundle file' >&2; exit 1; }
        printf '%s\n' 'tamper' >>"$app"
        if codesign --verify --deep --strict "$release_root/DerivedData/Build/Products/Release/Armageddon.app" >"$task_root/tamper-verification.txt" 2>&1; then
            printf '%s\n' 'ERROR[tamper-verification]: modified bundle still verified' >&2
            exit 1
        fi
    fi
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":31,"mode":"%s","releaseRoot":"%s","classification":"BLOCKED_MISSING_SIGNING_CREDENTIAL","transcript":"%s","transcriptSha256":"%s","outcome":"PASS"}\n' \
        "$2" "$release_root" "$transcript" "$transcript_sha256" >"$task_root/camera-ml-app.json"
    printf 'PASS task=31 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "32" ]; then
    transcript="$task_root/camera-ml-app.txt"
    ./scripts/validate-docs.sh >"$transcript" 2>&1
    ./scripts/check-source-boundary.sh >>"$transcript" 2>&1
    [ -s "$transcript" ] || { printf '%s\n' 'ERROR[empty-task-32-transcript]' >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":32,"mode":"%s","transcript":"%s","transcriptSha256":"%s","outcome":"PASS"}\n' \
        "$2" "$transcript" "$transcript_sha256" >"$task_root/camera-ml-app.json"
    printf 'PASS task=32 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "33" ]; then
    transcript="$task_root/camera-ml-app.txt"
    ./scripts/check-live-guards.sh >"$transcript" 2>&1
    if env | awk -F= '$1 ~ /^(ARMAGEDDON_LIVE_|ARMAGEDDON_OPERATOR_|HUENIT_LIVE_|ARMAGEDDON_(CAMERA|SERIAL|DEVICE)_|HUENIT_(CAM|ARM)_)/ { found=1 } END { exit found ? 0 : 1 }'; then
        printf '%s\n' 'ERROR[live-environment-leak]: guarded variables survived the task wrapper' >&2
        exit 1
    fi
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":33,"mode":"%s","transcript":"%s","transcriptSha256":"%s","outcome":"NOT_RUN_OPERATOR_REQUIRED","hardwareUsed":false}\n' \
        "$2" "$transcript" "$transcript_sha256" >"$task_root/camera-ml-app.json"
    printf 'NOT_RUN_OPERATOR_REQUIRED task=33 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "24" ]; then
    transcript="$task_root/camera-ml-app.txt"
    result="$task_root/camera-ml-app.xcresult"
    mkdir -m 700 "$task_root/screenshots"
    if [ "$2" = "happy" ]; then
        filter='-only-testing:ArmageddonUITests/AppShellUITests/testCalibrationWizardValidEightPointProfile'
        expected='calibration-valid-profile'
    else
        filter='-only-testing:ArmageddonUITests/AppShellUITests/testCalibrationWizardRefusesHighErrorProfile'
        expected='calibration-high-error-refused'
    fi
    ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
    TEST_RUNNER_ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots" \
        xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp \
        -destination 'platform=macOS' -derivedDataPath "$task_root/build" -resultBundlePath "$result" test $filter >"$transcript" 2>&1
    [ -d "$result" ] || { printf '%s\n' 'ERROR[missing-task-24-xcresult]' >&2; exit 1; }
    extract_named_screenshots "$result" "$task_root/screenshots"
    [ -s "$task_root/screenshots/$expected.png" ] || { printf '%s\n' "ERROR[missing-task-24-screenshot]: $expected" >&2; exit 1; }
    transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
    printf '{"task":24,"mode":"%s","filter":"%s","screenshot":"%s","transcript":"%s","transcriptSha256":"%s","result":"%s","outcome":"PASS"}\n' \
        "$2" "$filter" "$task_root/screenshots/$expected.png" "$transcript" "$transcript_sha256" "$result" >"$task_root/camera-ml-app.json"
    printf 'PASS task=24 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

mkdir -m 700 "$task_root/screenshots"
export ARMAGEDDON_SCREENSHOT_DIR="$task_root/screenshots"
result="$task_root/camera-ml-app.xcresult"
transcript="$task_root/camera-ml-app.txt"
build_root="$task_root/build"
if [ "$2" = "happy" ]; then
    filters='-only-testing:ArmageddonUITests/AppShellUITests/testSidebarAndKeyboardNavigationStopsAndCapturesAppearances -only-testing:ArmageddonUITests/AppShellUITests/testShellFitsMinimumAndLargeWindowSizes'
else
    filters='-only-testing:ArmageddonUITests/AppShellUITests/testUnknownDestinationRecoversToLive'
fi

# Intentional word splitting expands the fixed XCTest filters above into arguments.
# shellcheck disable=SC2086
xcodebuild -project Armageddon.xcodeproj -scheme ArmageddonApp -destination 'platform=macOS' -derivedDataPath "$build_root" -resultBundlePath "$result" test $filters >"$transcript" 2>&1
attachments="$task_root/attachments"
xcrun xcresulttool export attachments --path "$result" --output-path "$attachments" >"$task_root/attachments.txt" 2>&1
python3 - "$attachments/manifest.json" "$attachments" "$task_root/screenshots" "$2" <<'PY'
import json
import shutil
import sys
from pathlib import Path

manifest_path, attachments_path, screenshots_path = map(Path, sys.argv[1:4])
mode = sys.argv[4]
expected = (
    [
        "app-shell-light-1100x720",
        "app-shell-light-1280x800",
        "app-shell-dark-1280x800",
        "app-shell-light-1440x900",
    ]
    if mode == "happy"
    else ["app-shell-recovered-1100x720"]
)
attachments = [
    attachment
    for test in json.loads(manifest_path.read_text())
    for attachment in test["attachments"]
]
for name in expected:
    matches = [
        attachment
        for attachment in attachments
        if attachment["suggestedHumanReadableName"].startswith(f"{name}_")
    ]
    if len(matches) != 1:
        raise SystemExit(f"ERROR[attachment-export]: expected one {name} attachment, found {len(matches)}")
    source = attachments_path / matches[0]["exportedFileName"]
    destination = screenshots_path / f"{name}.png"
    if not source.is_file() or source.stat().st_size == 0:
        raise SystemExit(f"ERROR[attachment-export]: missing image {source}")
    if destination.exists():
        raise SystemExit(f"ERROR[attachment-export]: destination already exists {destination}")
    shutil.copy2(source, destination)
PY
if [ "$2" = "happy" ]; then
    for name in app-shell-light-1100x720 app-shell-light-1280x800 app-shell-dark-1280x800 app-shell-light-1440x900; do
        [ -s "$task_root/screenshots/$name.png" ] || { printf 'ERROR[missing-screenshot]: %s\n' "$name" >&2; exit 1; }
    done
else
    [ -s "$task_root/screenshots/app-shell-recovered-1100x720.png" ] || { printf '%s\n' 'ERROR[missing-recovery-screenshot]' >&2; exit 1; }
fi
transcript_sha256=$(shasum -a 256 "$transcript" | awk '{print $1}')
printf '{"task":3,"mode":"%s","filter":"%s","transcript":"%s","transcriptSha256":"%s","screenshots":"%s","outcome":"PASS"}\n' \
    "$2" "$filters" "$transcript" "$transcript_sha256" "$task_root/screenshots" >"$task_root/camera-ml-app.json"
printf 'PASS task=3 mode=%s root=%s\n' "$2" "$task_root"
