#!/bin/sh

set -eu

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: verify-no-live-io-in-tests.sh [PATH...]'
    exit 0
fi

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
scan_root=${1:-"$project_root/Tests"}
forbidden='AVCaptureDevice\.requestAccess|AVCaptureDevice\.DiscoverySession|URLSession\.shared|IOServiceGetMatchingServices|SerialPort\.open|writeHardwareCommand'

if [ "$scan_root" = "$project_root/Tests" ]; then
    matches=$(find "$scan_root" -type f \( -name '*.swift' -o -name '*.py' -o -name '*.sh' \) ! -path "$project_root/Tests/Fixtures/*" ! -path '*/Live/*' -print0 | xargs -0 grep -En "$forbidden" || true)
else
    matches=$(grep -En "$forbidden" "$scan_root" || true)
fi

if [ -n "$matches" ]; then
    printf '%s\n' "$matches" >&2
    printf '%s\n' 'ERROR[forbidden-live-io]: test source names live camera, network, USB, serial, or hardware writes' >&2
    exit 1
fi

printf '%s\n' 'PASS: ordinary tests contain no live I/O symbols'
