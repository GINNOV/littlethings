#!/bin/bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
    echo "usage: build-for-xcode.sh <verified-source-root> <output-root> <configuration> <architecture>" >&2
    exit 2
fi

SOURCE_ROOT="$1"
OUTPUT_ROOT="$2"
CONFIGURATION="$3"
ARCHITECTURE="$4"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
MANIFEST="$SCRIPT_DIR/ADFlibDependency.cmake"
STAGER="$SCRIPT_DIR/stage_adflib.py"

case "${ADFLIB_CANARY:-OFF}" in
    OFF)
        if [[ -n "${ADFLIB_TEST_MANIFEST_OVERRIDE:-}" || -n "${ADFLIB_TEST_IDENTITY_OVERRIDE:-}" ]]; then
            echo "adflib_stable_override_rejected" >&2
            exit 2
        fi
        ;;
    ON)
        if [[ "${ADFLIB_CANARY_CI:-}" != 1 || -z "${ADFLIB_TEST_MANIFEST_OVERRIDE:-}" || ! -f "$ADFLIB_TEST_MANIFEST_OVERRIDE" ]]; then
            echo "adflib_canary_ci_manifest_required" >&2
            exit 2
        fi
        MANIFEST="$ADFLIB_TEST_MANIFEST_OVERRIDE"
        ;;
    *) echo "adflib_canary_mode_rejected" >&2; exit 2 ;;
esac

if [[ -z "${ADFLIB_VERIFIED_SOURCE_ROOT:-}" ]]; then
    echo "adflib_verified_source_root_required" >&2
    exit 2
fi
if [[ "$(cd "$ADFLIB_VERIFIED_SOURCE_ROOT" && pwd -P)" != "$(cd "$SOURCE_ROOT" && pwd -P)" ]]; then
    echo "adflib_verified_source_root_mismatch" >&2
    exit 2
fi

case "$ARCHITECTURE" in
    arm64|x86_64) ;;
    *) echo "adflib_architecture_rejected: $ARCHITECTURE" >&2; exit 2 ;;
esac
case "$CONFIGURATION" in
    Debug|Release) ;;
    *) echo "adflib_configuration_rejected: $CONFIGURATION" >&2; exit 2 ;;
esac

EXPECTED_ROOT="$(python3 "$STAGER" --manifest "$MANIFEST" --source-root "$SOURCE_ROOT" --print-source-root)"
if [[ "$EXPECTED_ROOT" != "$(cd "$SOURCE_ROOT" && pwd -P)" ]]; then
    echo "adflib_source_root_mismatch" >&2
    exit 2
fi

IDENTITY="$SOURCE_ROOT/../adflib-identity.json"
TRANSPORT="$SOURCE_ROOT/../adflib-transport.json"
if [[ ! -f "$IDENTITY" || ! -f "$TRANSPORT" ]]; then
    echo "adflib_verification_evidence_missing" >&2
    exit 2
fi
if [[ -n "${ADFLIB_TEST_IDENTITY_OVERRIDE:-}" ]] && ! cmp -s "$IDENTITY" "$ADFLIB_TEST_IDENTITY_OVERRIDE"; then
    echo "adflib_identity_mismatch" >&2
    exit 2
fi

manifest_value() {
    sed -n "s/^set($1 \"\([^\"]*\)\")$/\1/p" "$MANIFEST"
}
identity_value() {
    /usr/bin/plutil -extract "$1" raw -o - "$IDENTITY"
}
transport_value() {
    /usr/bin/plutil -extract "$1" raw -o - "$TRANSPORT"
}

MANIFEST_CHANNEL="$(manifest_value ADFLIB_CHANNEL)"
if [[ -z "$MANIFEST_CHANNEL" ]]; then
    MANIFEST_CHANNEL="stable"
fi
IDENTITY_CHANNEL="$(identity_value channel)"
IDENTITY_OWNER_REPO="$(identity_value owner_repo)"
IDENTITY_VERSION="$(identity_value version)"
IDENTITY_TAG="$(identity_value tag)"
IDENTITY_COMMIT="$(identity_value commit)"
IDENTITY_TREE_SHA="$(identity_value tree_sha)"
IDENTITY_URL="$(identity_value url)"
IDENTITY_TREE_MANIFEST_SHA256="$(identity_value tree_manifest_sha256)"
if [[ "$IDENTITY_CHANNEL" != "$MANIFEST_CHANNEL" || \
      "$IDENTITY_OWNER_REPO" != "$(manifest_value ADFLIB_OWNER_REPO)" || \
      "$IDENTITY_VERSION" != "$(manifest_value ADFLIB_VERSION)" || \
      "$IDENTITY_TAG" != "$(manifest_value ADFLIB_TAG)" || \
      "$IDENTITY_COMMIT" != "$(manifest_value ADFLIB_COMMIT)" || \
      "$IDENTITY_TREE_SHA" != "$(manifest_value ADFLIB_TREE_SHA)" || \
      "$IDENTITY_URL" != "$(manifest_value ADFLIB_ARCHIVE_URL)" || \
      "$IDENTITY_TREE_MANIFEST_SHA256" != "$(manifest_value ADFLIB_TREE_MANIFEST_SHA256)" ]]; then
    echo "adflib_identity_manifest_mismatch" >&2
    exit 2
fi
TRANSPORT_URL="$(transport_value transport_url)"
TRANSPORT_SHA256="$(transport_value transport_sha256)"
LOCAL_CACHE_SHA256="$(transport_value local_cache_sha256)"
if [[ "$TRANSPORT_URL" != "$(manifest_value ADFLIB_TRANSPORT_URL)" || \
      "$TRANSPORT_SHA256" != "$(manifest_value ADFLIB_TRANSPORT_SHA256)" || \
      "$LOCAL_CACHE_SHA256" != "$(manifest_value ADFLIB_LOCAL_CACHE_SHA256)" ]]; then
    echo "adflib_transport_manifest_mismatch" >&2
    exit 2
fi

QUALIFIED_ROOT="$OUTPUT_ROOT/adflib/$CONFIGURATION/$ARCHITECTURE"
WORK_ROOT="$QUALIFIED_ROOT/work"
STAGED_SOURCE="$WORK_ROOT/source"
BUILD_ROOT="$WORK_ROOT/build"
rm -rf "$QUALIFIED_ROOT"
mkdir -p "$WORK_ROOT" "$QUALIFIED_ROOT/include"
python3 "$STAGER" --manifest "$MANIFEST" --source-root "$SOURCE_ROOT" --stage "$STAGED_SOURCE"

cmake -S "$STAGED_SOURCE" -B "$BUILD_ROOT" \
    -DCMAKE_BUILD_TYPE="$CONFIGURATION" \
    -DCMAKE_OSX_ARCHITECTURES="$ARCHITECTURE" \
    -DBUILD_SHARED_LIBS=OFF \
    -DADFLIB_ENABLE_TESTS=OFF \
    -DADFLIB_ENABLE_NATIVE_DEV=OFF
cmake --build "$BUILD_ROOT" --target adf --config "$CONFIGURATION"

cp "$BUILD_ROOT/src/libadf.a" "$QUALIFIED_ROOT/libadf.a"
find "$STAGED_SOURCE/src" -maxdepth 1 -type f -name '*.h' -exec cp {} "$QUALIFIED_ROOT/include/" \;
cp "$IDENTITY" "$QUALIFIED_ROOT/adflib-identity.json"
cp "$TRANSPORT" "$QUALIFIED_ROOT/adflib-transport.json"

BUILT_ARCH="$(lipo -archs "$QUALIFIED_ROOT/libadf.a")"
if [[ "$BUILT_ARCH" != "$ARCHITECTURE" ]]; then
    echo "adflib_architecture_mismatch: expected=$ARCHITECTURE actual=$BUILT_ARCH" >&2
    exit 2
fi

MANIFEST_SHA256="$(shasum -a 256 "$MANIFEST" | awk '{print $1}')"
IDENTITY_SHA256="$(shasum -a 256 "$IDENTITY" | awk '{print $1}')"
printf '{"schema":"adfinder-adflib-provenance/v1","canonical_identity":' > "$QUALIFIED_ROOT/adflib-provenance.json"
tr -d '\n' < "$IDENTITY" >> "$QUALIFIED_ROOT/adflib-provenance.json"
printf ',"manifest_sha256":"%s","transport":' "$MANIFEST_SHA256" >> "$QUALIFIED_ROOT/adflib-provenance.json"
tr -d '\n' < "$TRANSPORT" >> "$QUALIFIED_ROOT/adflib-provenance.json"
printf ',"license":{"adflib":"GPL-2.0-or-later","application":"MIT"}}\n' >> "$QUALIFIED_ROOT/adflib-provenance.json"
printf 'channel=%s\nversion=%s\ntag=%s\ncommit=%s\ntree_sha=%s\ntree_manifest_sha256=%s\ntransport_sha256=%s\nlocal_cache_sha256=%s\nidentity_sha256=%s\narchitecture=%s\nconfiguration=%s\nmanifest_sha256=%s\n' \
    "$IDENTITY_CHANNEL" "$IDENTITY_VERSION" "$IDENTITY_TAG" "$IDENTITY_COMMIT" "$IDENTITY_TREE_SHA" \
    "$IDENTITY_TREE_MANIFEST_SHA256" "$TRANSPORT_SHA256" "$LOCAL_CACHE_SHA256" "$IDENTITY_SHA256" \
    "$ARCHITECTURE" "$CONFIGURATION" "$MANIFEST_SHA256" > "$QUALIFIED_ROOT/adflib-build.stamp"
rm -rf "$WORK_ROOT"
echo "adflib_stage_ok channel=$IDENTITY_CHANNEL version=$IDENTITY_VERSION tag=$IDENTITY_TAG commit=$IDENTITY_COMMIT tree_sha=$IDENTITY_TREE_SHA tree_manifest_sha256=$IDENTITY_TREE_MANIFEST_SHA256 transport_sha256=$TRANSPORT_SHA256 local_cache_sha256=$LOCAL_CACHE_SHA256 identity_sha256=$IDENTITY_SHA256 architecture=$ARCHITECTURE configuration=$CONFIGURATION manifest_sha256=$MANIFEST_SHA256"
