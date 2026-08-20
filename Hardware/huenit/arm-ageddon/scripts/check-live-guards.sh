#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
camera_scheme="$project_root/Armageddon.xcodeproj/xcshareddata/xcschemes/LiveCameraAcceptance.xcscheme"
arm_scheme="$project_root/Armageddon.xcodeproj/xcshareddata/xcschemes/LiveArmAcceptance.xcscheme"

[ -s "$camera_scheme" ] || { printf '%s\n' 'ERROR[missing-live-camera-scheme]' >&2; exit 1; }
[ -s "$arm_scheme" ] || { printf '%s\n' 'ERROR[missing-live-arm-scheme]' >&2; exit 1; }
grep -q 'ARMAGEDDON_LIVE_CAMERA' "$camera_scheme" || { printf '%s\n' 'ERROR[camera-guard-missing]' >&2; exit 1; }
grep -q 'ARMAGEDDON_LIVE_ARM' "$arm_scheme" || { printf '%s\n' 'ERROR[arm-guard-missing]' >&2; exit 1; }
if grep -Eq 'ARMAGEDDON_OPERATOR_PRESENT|ARMAGEDDON_OPERATOR_CONFIRMATION' "$arm_scheme"; then
    printf '%s\n' 'ERROR[scheme-sets-operator-presence]: operator presence must be supplied outside the scheme' >&2
    exit 1
fi
arm_source="$project_root/Sources/ArmageddonMotionBoundary"
if rg -n 'writeLine\([^\n]*G28' "$arm_source" >/dev/null 2>&1; then
    printf '%s\n' 'ERROR[forbidden-g28-write]: live guard source writes a forbidden G28 command' >&2
    exit 1
fi
grep -q 'uppercased().contains("G28")' "$arm_source/Arm/HuenitArm.swift" || {
    printf '%s\n' 'ERROR[g28-refusal-missing]: arm boundary must retain its case-insensitive G28 refusal' >&2
    exit 1
}
if grep -Eq 'LiveCameraAcceptance|LiveArmAcceptance' "$project_root/Armageddon.xcodeproj/xcshareddata/xcschemes/ArmageddonApp.xcscheme"; then
    printf '%s\n' 'ERROR[live-scheme-in-ordinary-scheme]' >&2
    exit 1
fi
printf '%s\n' 'PASS: live acceptance schemes are separately named and operator-gated'
