#!/bin/bash

set -euo pipefail

VERSION="0.8.7"
ARCHIVE_SHA256="275c29ef47be9992f62a35fcc96f7ca05c06d2fd05c9298b8dee9f743f75b089"
ARCHIVE_URL="https://lib.openmpt.org/files/libopenmpt/src/libopenmpt-${VERSION}+release.autotools.tar.gz"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/audeluxe-libopenmpt.XXXXXX")"

cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

ARCHIVE_PATH="$WORK_DIR/libopenmpt.tar.gz"
/usr/bin/curl --fail --location --silent --show-error "$ARCHIVE_URL" --output "$ARCHIVE_PATH"

ACTUAL_SHA256="$(/usr/bin/shasum -a 256 "$ARCHIVE_PATH" | /usr/bin/awk '{print $1}')"
if [[ "$ACTUAL_SHA256" != "$ARCHIVE_SHA256" ]]; then
    echo "libopenmpt archive checksum mismatch" >&2
    exit 1
fi

/usr/bin/tar -xzf "$ARCHIVE_PATH" -C "$WORK_DIR"
SOURCE_DIR="$WORK_DIR/libopenmpt-${VERSION}+release.autotools"
BUILD_TRIPLE="$("$SOURCE_DIR/build-aux/config.guess")"
SDK_PATH="$(xcrun --sdk macosx --show-sdk-path)"

build_architecture() {
    local architecture="$1"
    local host_triple="$2"
    local build_dir="$WORK_DIR/build-$architecture"
    local prefix_dir="$WORK_DIR/prefix-$architecture"
    local configure_platform=(--build="$BUILD_TRIPLE")

    if [[ "$architecture" == "x86_64" ]]; then
        configure_platform+=(--host="$host_triple")
    fi

    /bin/mkdir -p "$build_dir"
    (
        cd "$build_dir"
        CC="$(xcrun --find clang)" \
        CXX="$(xcrun --find clang++)" \
        CFLAGS="-O2 -DNDEBUG -g0 -arch $architecture -mmacosx-version-min=14.0 -isysroot $SDK_PATH" \
        CXXFLAGS="-O2 -DNDEBUG -g0 -arch $architecture -mmacosx-version-min=14.0 -isysroot $SDK_PATH" \
        LDFLAGS="-arch $architecture -mmacosx-version-min=14.0 -isysroot $SDK_PATH" \
        "$SOURCE_DIR/configure" \
            "${configure_platform[@]}" \
            --prefix="$prefix_dir" \
            --disable-shared \
            --enable-static \
            --disable-openmpt123 \
            --disable-examples \
            --disable-tests \
            --without-flac \
            --without-mpg123 \
            --without-ogg \
            --without-portaudio \
            --without-portaudiocpp \
            --without-sndfile \
            --without-vorbis \
            --without-vorbisfile \
            --without-zlib
        /usr/bin/make -j"$(/usr/sbin/sysctl -n hw.logicalcpu)"
        /usr/bin/make install
    )
}

build_architecture "arm64" "aarch64-apple-darwin"
build_architecture "x86_64" "x86_64-apple-darwin"

/usr/bin/xcrun lipo -create \
    "$WORK_DIR/prefix-arm64/lib/libopenmpt.a" \
    "$WORK_DIR/prefix-x86_64/lib/libopenmpt.a" \
    -output "$SCRIPT_DIR/libopenmpt.a"

/bin/mkdir -p "$SCRIPT_DIR/include/libopenmpt"
/bin/cp "$WORK_DIR/prefix-arm64/include/libopenmpt/"*.h "$SCRIPT_DIR/include/libopenmpt/"
/bin/cp "$WORK_DIR/prefix-arm64/share/doc/libopenmpt/LICENSE" "$SCRIPT_DIR/LICENSE.libopenmpt"

echo "Built libopenmpt $VERSION for arm64 and x86_64."
