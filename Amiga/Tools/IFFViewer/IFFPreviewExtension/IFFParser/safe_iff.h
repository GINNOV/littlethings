#pragma once

#include <CoreGraphics/CoreGraphics.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

CGImageRef _Nullable iff_createSafeImageFromData(
    const uint8_t * _Nonnull data,
    size_t length,
    bool withAlpha
) CF_RETURNS_RETAINED;
