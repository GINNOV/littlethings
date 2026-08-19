#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: qa-task.sh <1-33> <happy|failure>'
    exit 0
fi
if [ "$#" -ne 2 ]; then
    printf '%s\n' 'Usage: qa-task.sh <1-33> <happy|failure>' >&2
    exit 2
fi
case "$1" in 2|3|4|6|7|8) ;; *) printf '%s\n' 'ERROR[unsupported-task]: task manifest has not landed yet' >&2; exit 2 ;; esac
case "$2" in happy|failure) ;; *) printf '%s\n' 'ERROR[unknown-mode]' >&2; exit 2 ;; esac

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
if [ "$1" = "2" ]; then
    exec python3 scripts/qa_task_runner.py "$1" "$2" "$task_root"
fi

if [ "$1" = "6" ]; then
    transcript="$task_root/camera-ml-app.txt"
    swift test --build-path "$task_root/build" --filter AppStateRestorationTests >"$transcript" 2>&1
    printf 'PASS task=6 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "7" ]; then
    transcript="$task_root/camera-ml-app.txt"
    if [ "$2" = "happy" ]; then
        swift test --filter HuenitArmPortTests >"$transcript" 2>&1
    else
        swift test --filter forbiddenG28WritesNothing >"$transcript" 2>&1
    fi
    printf 'PASS task=7 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "8" ]; then
    transcript="$task_root/camera-ml-app.txt"
    swift test --filter EmergencyStopTests >"$transcript" 2>&1
    printf 'PASS task=8 mode=%s root=%s\n' "$2" "$task_root"
    exit 0
fi

if [ "$1" = "4" ]; then
    transcript="$task_root/camera-ml-app.txt"
    swift test --filter LocalArtifactStorageTests >"$transcript" 2>&1
    printf 'PASS task=4 mode=%s root=%s\n' "$2" "$task_root"
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
printf 'PASS task=3 mode=%s root=%s\n' "$2" "$task_root"
