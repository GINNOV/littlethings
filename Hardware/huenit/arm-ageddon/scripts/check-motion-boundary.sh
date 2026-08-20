#!/bin/sh

set -eu

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    printf '%s\n' 'Usage: check-motion-boundary.sh'
    exit 0
fi
[ "$#" -eq 0 ] || { printf '%s\n' 'Usage: check-motion-boundary.sh' >&2; exit 2; }

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
scratch=${ARMAGEDDON_QA_BUILD_ROOT:?ARMAGEDDON_QA_BUILD_ROOT must name an external build root}
case "$scratch" in
    "$project_root"|"$project_root"/*) printf '%s\n' 'ERROR[project-build-root]: build root must be external' >&2; exit 2 ;;
esac
mkdir -p "$scratch/motion-boundary"
"$project_root/scripts/check-source-boundary.sh"
swift build --package-path "$project_root" --scratch-path "$scratch/motion-boundary/build" --target ArmageddonCore >/dev/null
module_dir=$(find "$scratch/motion-boundary/build" -type d -name Modules -print -quit)
[ -n "$module_dir" ] || { printf '%s\n' 'ERROR[module-missing]: ArmageddonCore module not found' >&2; exit 1; }
sdk=$(xcrun --sdk macosx --show-sdk-path)
set +e
xcrun swiftc -typecheck -sdk "$sdk" -target arm64-apple-macosx15.0 -I "$module_dir" "$project_root/Tests/Fixtures/ForbiddenMotionConsumer.swift" >"$scratch/motion-boundary/compiler.stdout" 2>"$scratch/motion-boundary/compiler.stderr"
status=$?
set -e
[ "$status" -ne 0 ] || { printf '%s\n' 'ERROR[raw-motion-exported]: forbidden consumer compiled' >&2; exit 1; }
grep -Eq 'cannot find.*SerialPort|cannot find.*MotionPermit' "$scratch/motion-boundary/compiler.stderr" || { printf '%s\n' 'ERROR[unnamed-compiler-denial]: expected raw symbols were not denied' >&2; exit 1; }
xcrun swift-symbolgraph-extract -module-name ArmageddonCore -sdk "$sdk" -I "$module_dir" -target arm64-apple-macosx15.0 -output-dir "$scratch/motion-boundary" -pretty-print
if grep -REn 'SerialPort|MotionPermit|sendRaw|writeHardwareCommand' "$scratch/motion-boundary"/*.symbols.json; then
    printf '%s\n' 'ERROR[forbidden-symbol]: exported symbol graph exposes raw motion' >&2
    exit 1
fi
production_sources=$(find "$project_root/Sources/ArmageddonMotionBoundary" -type f -name '*.swift' -print)
xcrun swiftc -typecheck -dump-ast -sdk "$sdk" -target arm64-apple-macosx15.0 -I "$module_dir" $production_sources >"$scratch/motion-boundary/production.ast" 2>"$scratch/motion-boundary/ast.stderr"
references=$(cat "$scratch/motion-boundary/production.ast" "$scratch/motion-boundary/ast.stderr" | rg -n 'declref_expr.*requestMotion' | rg -v 'ArmageddonMotionBoundary.swift' || true)
[ -z "$references" ] || { printf '%s\n' "$references" >&2; printf '%s\n' 'ERROR[unexpected-boundary-callsite]: facade call outside checked-in Safety/Execution allowlist' >&2; exit 1; }
printf '%s\n' 'PASS: motion boundary compiler, symbol graph, and call-site checks passed'
