#!/bin/bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "usage: $0 <verified-source-root> <output-root>" >&2
    exit 2
fi

SOURCE_ROOT="$(cd "$1" && pwd -P)"
OUTPUT_ROOT="$2"
SUPPORT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
TEMPORARY_ROOT="$(mktemp -d /tmp/adflib-xcode-identity.XXXXXX)"
trap 'rm -rf "$TEMPORARY_ROOT"' EXIT
ALTERNATE_ARTIFACTS="$TEMPORARY_ROOT/artifacts"
ALTERNATE_SOURCE="$ALTERNATE_ARTIFACTS/ADFlib-alternate-pristine"
ALTERNATE_MANIFEST="$TEMPORARY_ROOT/ADFlibDependency-0.10.8.cmake"
ALTERNATE_IDENTITY="$ALTERNATE_ARTIFACTS/adflib-identity.json"
ALTERNATE_TRANSPORT="$ALTERNATE_ARTIFACTS/adflib-transport.json"
WRONG_IDENTITY="$TEMPORARY_ROOT/wrong-identity.json"
IDENTITY_BACKUP="$TEMPORARY_ROOT/identity-backup.json"
TRANSPORT_BACKUP="$TEMPORARY_ROOT/transport-backup.json"

mkdir -p "$ALTERNATE_ARTIFACTS"
cp -R "$SOURCE_ROOT" "$ALTERNATE_SOURCE"
cp "$SUPPORT_ROOT/ADFlibDependency.cmake" "$ALTERNATE_MANIFEST"
cp "$SOURCE_ROOT/../adflib-identity.json" "$ALTERNATE_IDENTITY"
cp "$SOURCE_ROOT/../adflib-transport.json" "$ALTERNATE_TRANSPORT"
sed -i '' 's/set(ADFLIB_VERSION "[^"]*")/set(ADFLIB_VERSION "0.10.8")/; s/set(ADFLIB_TAG "[^"]*")/set(ADFLIB_TAG "v0.10.8")/' "$ALTERNATE_MANIFEST"
sed -i '' 's/"version":"[^"]*"/"version":"0.10.8"/; s/"tag":"[^"]*"/"tag":"v0.10.8"/' "$ALTERNATE_IDENTITY"

changed_fields="$({ diff -U0 "$SUPPORT_ROOT/ADFlibDependency.cmake" "$ALTERNATE_MANIFEST" || true; } | sed -n 's/^[-+]set(\(ADFLIB_[A-Z0-9_]*\) .*/\1/p' | sort -u)"
while IFS= read -r field; do
    case "$field" in
        ADFLIB_VERSION|ADFLIB_TAG|ADFLIB_COMMIT|ADFLIB_TREE_SHA|ADFLIB_ARCHIVE_URL|ADFLIB_TREE_MANIFEST_SHA256) ;;
        *) echo "alternate_manifest_changed_non_identity_field: $field" >&2; exit 2 ;;
    esac
done <<< "$changed_fields"
grep -qx 'ADFLIB_TAG' <<< "$changed_fields"
grep -qx 'ADFLIB_VERSION' <<< "$changed_fields"

status="$(ADFLIB_CANARY=ON ADFLIB_CANARY_CI=1 ADFLIB_TEST_MANIFEST_OVERRIDE="$ALTERNATE_MANIFEST" ADFLIB_TEST_IDENTITY_OVERRIDE="$ALTERNATE_IDENTITY" ADFLIB_VERIFIED_SOURCE_ROOT="$ALTERNATE_SOURCE" "$SUPPORT_ROOT/build-for-xcode.sh" "$ALTERNATE_SOURCE" "$OUTPUT_ROOT" Debug arm64)"
QUALIFIED_ROOT="$OUTPUT_ROOT/adflib/Debug/arm64"
grep -qx 'version=0.10.8' "$QUALIFIED_ROOT/adflib-build.stamp"
grep -qx 'tag=v0.10.8' "$QUALIFIED_ROOT/adflib-build.stamp"
grep -q 'version=0.10.8 tag=v0.10.8' <<< "$status"
grep '^adflib_stage_ok ' <<< "$status"
test "$(/usr/bin/plutil -extract canonical_identity.version raw -o - "$QUALIFIED_ROOT/adflib-provenance.json")" = "0.10.8"
test "$(/usr/bin/plutil -extract canonical_identity.tag raw -o - "$QUALIFIED_ROOT/adflib-provenance.json")" = "v0.10.8"

cp "$ALTERNATE_IDENTITY" "$IDENTITY_BACKUP"
sed -i '' 's/"version":"0.10.8"/"version":"0.10.9"/' "$ALTERNATE_IDENTITY"
set +e
ADFLIB_CANARY=ON ADFLIB_CANARY_CI=1 ADFLIB_TEST_MANIFEST_OVERRIDE="$ALTERNATE_MANIFEST" ADFLIB_TEST_IDENTITY_OVERRIDE="$ALTERNATE_IDENTITY" ADFLIB_VERIFIED_SOURCE_ROOT="$ALTERNATE_SOURCE" "$SUPPORT_ROOT/build-for-xcode.sh" "$ALTERNATE_SOURCE" "$OUTPUT_ROOT/manifest-mismatch" Debug arm64 > "$TEMPORARY_ROOT/manifest-mismatch.log" 2>&1
manifest_result=$?
set -e
test "$manifest_result" -eq 2
grep -q 'adflib_identity_manifest_mismatch' "$TEMPORARY_ROOT/manifest-mismatch.log"
cp "$IDENTITY_BACKUP" "$ALTERNATE_IDENTITY"

cp "$ALTERNATE_TRANSPORT" "$TRANSPORT_BACKUP"
sed -i '' 's/"local_cache_sha256":"[^"]*"/"local_cache_sha256":"0000000000000000000000000000000000000000000000000000000000000000"/' "$ALTERNATE_TRANSPORT"
set +e
ADFLIB_CANARY=ON ADFLIB_CANARY_CI=1 ADFLIB_TEST_MANIFEST_OVERRIDE="$ALTERNATE_MANIFEST" ADFLIB_TEST_IDENTITY_OVERRIDE="$ALTERNATE_IDENTITY" ADFLIB_VERIFIED_SOURCE_ROOT="$ALTERNATE_SOURCE" "$SUPPORT_ROOT/build-for-xcode.sh" "$ALTERNATE_SOURCE" "$OUTPUT_ROOT/transport-mismatch" Debug arm64 > "$TEMPORARY_ROOT/transport-mismatch.log" 2>&1
transport_result=$?
set -e
test "$transport_result" -eq 2
grep -q 'adflib_transport_manifest_mismatch' "$TEMPORARY_ROOT/transport-mismatch.log"
cp "$TRANSPORT_BACKUP" "$ALTERNATE_TRANSPORT"

cp "$ALTERNATE_IDENTITY" "$WRONG_IDENTITY"
sed -i '' 's/"version":"0.10.8"/"version":"0.10.9"/' "$WRONG_IDENTITY"
set +e
ADFLIB_CANARY=ON ADFLIB_CANARY_CI=1 ADFLIB_TEST_MANIFEST_OVERRIDE="$ALTERNATE_MANIFEST" ADFLIB_TEST_IDENTITY_OVERRIDE="$WRONG_IDENTITY" ADFLIB_VERIFIED_SOURCE_ROOT="$ALTERNATE_SOURCE" "$SUPPORT_ROOT/build-for-xcode.sh" "$ALTERNATE_SOURCE" "$OUTPUT_ROOT/mismatch" Debug arm64 > "$TEMPORARY_ROOT/mismatch.log" 2>&1
result=$?
set -e
test "$result" -eq 2
grep -q 'adflib_identity_mismatch' "$TEMPORARY_ROOT/mismatch.log"

sed -i '' '1a\
set(ADFLIB_CHANNEL "canary")
' "$ALTERNATE_MANIFEST"
sed -i '' 's/set(ADFLIB_VERSION "[^"]*")/set(ADFLIB_VERSION "0.0.0-canary")/; s/set(ADFLIB_TAG "[^"]*")/set(ADFLIB_TAG "master")/' "$ALTERNATE_MANIFEST"
sed -i '' 's/"channel":"stable"/"channel":"canary"/; s/"version":"[^"]*"/"version":"0.0.0-canary"/; s/"tag":"[^"]*"/"tag":"master"/' "$ALTERNATE_IDENTITY"
canary_status="$(ADFLIB_CANARY=ON ADFLIB_CANARY_CI=1 ADFLIB_TEST_MANIFEST_OVERRIDE="$ALTERNATE_MANIFEST" ADFLIB_TEST_IDENTITY_OVERRIDE="$ALTERNATE_IDENTITY" ADFLIB_VERIFIED_SOURCE_ROOT="$ALTERNATE_SOURCE" "$SUPPORT_ROOT/build-for-xcode.sh" "$ALTERNATE_SOURCE" "$OUTPUT_ROOT/canary" Release arm64)"
CANARY_ROOT="$OUTPUT_ROOT/canary/adflib/Release/arm64"
grep -qx 'channel=canary' "$CANARY_ROOT/adflib-build.stamp"
grep -qx 'version=0.0.0-canary' "$CANARY_ROOT/adflib-build.stamp"
grep -qx 'tag=master' "$CANARY_ROOT/adflib-build.stamp"
grep -q 'channel=canary version=0.0.0-canary tag=master' <<< "$canary_status"
test "$(/usr/bin/plutil -extract canonical_identity.channel raw -o - "$CANARY_ROOT/adflib-provenance.json")" = "canary"
grep '^adflib_stage_ok ' <<< "$canary_status"
echo "alternate_identity_ok stable_version=0.10.8 stable_tag=v0.10.8 canary_version=0.0.0-canary canary_tag=master override_mismatch_rc=$result manifest_mismatch_rc=$manifest_result transport_mismatch_rc=$transport_result"
