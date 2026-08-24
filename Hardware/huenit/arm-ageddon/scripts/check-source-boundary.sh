#!/bin/sh

set -eu

project_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
package_file="$project_root/Package.swift"
project_file="$project_root/Armageddon.xcodeproj/project.pbxproj"
fixture_file="$project_root/Tests/Fixtures/invalid-external-package-reference.txt"

fail() {
    printf 'ERROR[%s]: %s\n' "$1" "$2" >&2
    exit 1
}

if [ "${1:-}" = "--check-fixture" ]; then
    [ "$#" -eq 2 ] || fail usage "--check-fixture requires one path"
    candidate=$(CDPATH= cd -- "$(dirname -- "$2")" && pwd -P)/$(basename -- "$2")
    [ "$candidate" = "$fixture_file" ] || fail fixture-path "only the checked-in invalid fixture is accepted"
    if grep -Eq 'https?://|\.package[[:space:]]*\(' "$candidate"; then
        fail external-package-reference "untrusted fixture contains a forbidden external package reference"
    fi
    fail invalid-fixture "fixture did not contain the expected forbidden reference"
fi

[ "$#" -eq 0 ] || fail usage "unexpected arguments"
[ -f "$package_file" ] || fail package-missing "Package.swift is required"
[ -f "$project_file" ] || fail project-missing "Armageddon.xcodeproj is required"

grep -Eq 'swift-tools-version:[[:space:]]*6\.2' "$package_file" || fail tools-version "Swift tools 6.2 is required"
grep -Eq '\.library\(name: "ArmageddonCore"' "$package_file" || fail core-product "ArmageddonCore must be exported"
grep -Eq 'name: "ArmageddonMotionBoundary"' "$package_file" || fail boundary-target "motion boundary target is missing"

products=$(awk '/products: \[/{inside=1} /targets: \[/{inside=0} inside' "$package_file")
printf '%s\n' "$products" | grep -q 'ArmageddonMotionBoundary' && fail boundary-product "motion boundary must not be exported"
if grep -Eq 'https?://' "$package_file"; then
    fail external-package-reference "remote URLs in Package.swift are forbidden"
fi
if grep -Eq '\.package[[:space:]]*\([^)]*url[[:space:]]*:' "$package_file"; then
    fail external-package-reference "remote package url: is forbidden"
fi

grep -q 'XCLocalSwiftPackageReference' "$project_file" || fail local-package "Xcode must use a local package reference"
grep -q 'productName = ArmageddonCore' "$project_file" || fail core-link "app must link ArmageddonCore"
grep -q 'XCRemoteSwiftPackageReference' "$project_file" && fail external-package-reference "remote Xcode package references are forbidden"
grep -q 'Sources/ArmageddonCore' "$project_file" && fail duplicate-core-membership "Xcode must not compile package sources directly"
grep -q 'invalid-external-package-reference' "$package_file" "$project_file" && fail fixture-membership "invalid fixture entered a build graph"

if find "$project_root/Sources" -type f \( -name '*.py' -o -name '*.mlmodel' -o -name '*.mlpackage' -o -name '*.tflite' -o -name '*.onnx' \) | grep -q .; then
    fail external-artifact "Python or model artifacts are forbidden in Task 1 sources"
fi

printf 'PASS: canonical source and package boundaries are intact\n'
