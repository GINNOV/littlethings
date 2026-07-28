#include "safe_iff.h"

#include <CoreFoundation/CoreFoundation.h>
#include <limits.h>
#include <stdlib.h>
#include <string.h>

enum { IFF_MAX_DIMENSION = 32768, IFF_MAX_PIXELS = 100000000 };

typedef struct { const uint8_t *data; size_t size; } Chunk;
typedef struct {
    uint32_t formType;
    Chunk bmhd, cmap, body, camg;
} IFFChunks;

static uint16_t read_u16be(const uint8_t *p) {
    return (uint16_t)(((uint16_t)p[0] << 8) | p[1]);
}

static uint32_t read_u32be(const uint8_t *p) {
    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) |
           ((uint32_t)p[2] << 8) | p[3];
}

static bool checked_multiply(size_t a, size_t b, size_t *result) {
    if (a != 0 && b > SIZE_MAX / a) return false;
    *result = a * b;
    return true;
}

static bool parse_chunks(const uint8_t *data, size_t length, IFFChunks *chunks) {
    if (!data || !chunks || length < 12 || memcmp(data, "FORM", 4) != 0) return false;
    uint32_t declaredSize = read_u32be(data + 4);
    if (declaredSize < 4 || (size_t)declaredSize > length - 8) return false;
    uint32_t formType = read_u32be(data + 8);
    if (formType != 'ILBM' && formType != 'PBM ') return false;

    memset(chunks, 0, sizeof(*chunks));
    chunks->formType = formType;
    size_t formEnd = 8 + (size_t)declaredSize;
    size_t offset = 12;
    while (offset < formEnd) {
        if (formEnd - offset < 8) return false;
        uint32_t identifier = read_u32be(data + offset);
        size_t chunkSize = read_u32be(data + offset + 4);
        offset += 8;
        if (chunkSize > formEnd - offset) return false;
        Chunk chunk = { data + offset, chunkSize };
        switch (identifier) {
            case 'BMHD': chunks->bmhd = chunk; break;
            case 'CMAP': chunks->cmap = chunk; break;
            case 'BODY': chunks->body = chunk; break;
            case 'CAMG': chunks->camg = chunk; break;
            default: break;
        }
        size_t padded = chunkSize + (chunkSize & 1);
        if (padded > formEnd - offset) return false;
        offset += padded;
    }
    return offset == formEnd;
}

static bool unpack_byterun(const uint8_t **source, const uint8_t *sourceEnd,
                           uint8_t *destination, size_t destinationLength) {
    size_t written = 0;
    while (written < destinationLength) {
        if (*source >= sourceEnd) return false;
        int8_t control = (int8_t)*(*source)++;
        if (control >= 0) {
            size_t count = (size_t)control + 1;
            if (count > destinationLength - written ||
                (size_t)(sourceEnd - *source) < count) return false;
            memcpy(destination + written, *source, count);
            *source += count;
            written += count;
        } else if (control != INT8_MIN) {
            size_t count = (size_t)(1 - control);
            if (*source >= sourceEnd || count > destinationLength - written) return false;
            memset(destination + written, *(*source)++, count);
            written += count;
        }
    }
    return true;
}

static bool decode_indices(const IFFChunks *chunks, size_t width, size_t height,
                           uint8_t depth, uint8_t masking, uint8_t compression,
                           uint8_t *indices) {
    const uint8_t *source = chunks->body.data;
    const uint8_t *sourceEnd = source + chunks->body.size;
    size_t rowBytes = ((width + 15) / 16) * 2;
    if (chunks->formType == 'PBM ') {
        size_t pixelCount;
        if (!checked_multiply(width, height, &pixelCount)) return false;
        if (compression == 0) {
            if (chunks->body.size < pixelCount) return false;
            memcpy(indices, source, pixelCount);
            return true;
        }
        return unpack_byterun(&source, sourceEnd, indices, pixelCount);
    }

    size_t planeCount = depth + (masking == 1 ? 1 : 0);
    size_t rowStorage;
    if (!checked_multiply(rowBytes, planeCount, &rowStorage)) return false;
    uint8_t *planes = malloc(rowStorage);
    if (!planes) return false;
    for (size_t y = 0; y < height; y++) {
        for (size_t plane = 0; plane < planeCount; plane++) {
            uint8_t *destination = planes + plane * rowBytes;
            if (compression == 0) {
                if ((size_t)(sourceEnd - source) < rowBytes) {
                    free(planes);
                    return false;
                }
                memcpy(destination, source, rowBytes);
                source += rowBytes;
            } else if (!unpack_byterun(&source, sourceEnd, destination, rowBytes)) {
                free(planes);
                return false;
            }
        }
        for (size_t x = 0; x < width; x++) {
            uint8_t value = 0;
            for (uint8_t plane = 0; plane < depth; plane++) {
                value |= ((planes[plane * rowBytes + x / 8] >> (7 - x % 8)) & 1) << plane;
            }
            indices[y * width + x] = value;
        }
    }
    free(planes);
    return true;
}

static int pixel_aspect(const IFFChunks *chunks) {
    if (chunks->camg.size < 4) return 0;
    uint32_t mode = read_u32be(chunks->camg.data);
    int aspect = (mode & 0x8000 ? 1 : 0) + ((mode & 0x8020) == 0x8020 ? 1 : 0) +
                 (mode & 0x0008 ? 1 : 0) - (mode & 0x0004 ? 1 : 0);
    return aspect < -3 || aspect > 3 ? 0 : aspect;
}

CGImageRef iff_createSafeImageFromData(const uint8_t *data, size_t length, bool withAlpha) {
    IFFChunks chunks;
    if (!parse_chunks(data, length, &chunks) || chunks.bmhd.size < 20 ||
        chunks.cmap.size == 0 || chunks.body.size == 0 ||
        chunks.cmap.size % 3 != 0 || chunks.cmap.size / 3 > 256) return NULL;

    size_t width = read_u16be(chunks.bmhd.data);
    size_t height = read_u16be(chunks.bmhd.data + 2);
    uint8_t depth = chunks.bmhd.data[8];
    uint8_t masking = chunks.bmhd.data[9];
    uint8_t compression = chunks.bmhd.data[10];
    uint16_t transparent = read_u16be(chunks.bmhd.data + 12);
    if (width == 0 || height == 0 || width > IFF_MAX_DIMENSION ||
        height > IFF_MAX_DIMENSION || depth == 0 || depth > 8 ||
        masking > 2 || compression > 1) return NULL;

    size_t pixelCount;
    if (!checked_multiply(width, height, &pixelCount) || pixelCount > IFF_MAX_PIXELS) return NULL;
    uint8_t *indices = malloc(pixelCount);
    if (!indices || !decode_indices(&chunks, width, height, depth, masking, compression, indices)) {
        free(indices);
        return NULL;
    }

    uint8_t palette[256][4] = {{0}};
    size_t colorCount = chunks.cmap.size / 3;
    for (size_t i = 0; i < colorCount; i++) {
        palette[i][0] = chunks.cmap.data[i * 3];
        palette[i][1] = chunks.cmap.data[i * 3 + 1];
        palette[i][2] = chunks.cmap.data[i * 3 + 2];
        palette[i][3] = 255;
    }
    uint32_t mode = chunks.camg.size >= 4 ? read_u32be(chunks.camg.data) : 0;
    if ((mode & 0x0080) && depth == 6 && colorCount <= 32) {
        for (size_t i = 0; i < colorCount; i++) {
            palette[i + 32][0] = palette[i][0] / 2;
            palette[i + 32][1] = palette[i][1] / 2;
            palette[i + 32][2] = palette[i][2] / 2;
            palette[i + 32][3] = 255;
        }
        if (colorCount < 64) colorCount = 64;
    }

    int aspect = pixel_aspect(&chunks);
    size_t outputWidth = aspect < 0 ? width << -aspect : width;
    size_t outputHeight = aspect > 0 ? height << aspect : height;
    size_t outputPixels, outputBytes;
    if (!checked_multiply(outputWidth, outputHeight, &outputPixels) ||
        outputPixels > IFF_MAX_PIXELS || !checked_multiply(outputPixels, 4, &outputBytes)) {
        free(indices);
        return NULL;
    }
    uint8_t *rgba = malloc(outputBytes);
    if (!rgba) {
        free(indices);
        return NULL;
    }

    uint8_t held[3] = {0, 0, 0};
    bool ham = (mode & 0x0800) && depth >= 5;
    size_t scaleX = aspect < 0 ? (size_t)1 << -aspect : 1;
    size_t scaleY = aspect > 0 ? (size_t)1 << aspect : 1;
    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            uint8_t index = indices[y * width + x];
            uint8_t color[4] = {0, 0, 0, 255};
            if (ham) {
                uint8_t dataBits = depth - 2;
                uint8_t command = index >> dataBits;
                uint8_t value = index & ((1u << dataBits) - 1);
                uint8_t expanded = (uint8_t)((value * 255u) / ((1u << dataBits) - 1));
                if (command == 0 && value < colorCount) memcpy(held, palette[value], 3);
                else if (command == 1) held[2] = expanded;
                else if (command == 2) held[0] = expanded;
                else if (command == 3) held[1] = expanded;
                memcpy(color, held, 3);
            } else if (index < colorCount) {
                memcpy(color, palette[index], 4);
            }
            if (withAlpha && masking == 2 && index == transparent) color[3] = 0;
            for (size_t sy = 0; sy < scaleY; sy++) {
                for (size_t sx = 0; sx < scaleX; sx++) {
                    size_t outputIndex = ((y * scaleY + sy) * outputWidth + x * scaleX + sx) * 4;
                    memcpy(rgba + outputIndex, color, 4);
                }
            }
        }
    }
    free(indices);

    CFDataRef imageData = CFDataCreate(kCFAllocatorDefault, rgba, (CFIndex)outputBytes);
    free(rgba);
    if (!imageData) return NULL;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(imageData);
    CFRelease(imageData);
    if (!provider) return NULL;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    if (!colorSpace) {
        CGDataProviderRelease(provider);
        return NULL;
    }
    CGBitmapInfo bitmapInfo = withAlpha
        ? (kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault)
        : (kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault);
    CGImageRef image = CGImageCreate(outputWidth, outputHeight, 8, 32, outputWidth * 4,
                                     colorSpace, bitmapInfo, provider, NULL, false,
                                     kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    return image;
}
