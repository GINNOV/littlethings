#include <CoreGraphics/CoreGraphics.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "../IFFPreviewExtension/IFFParser/safe_iff.h"

static void put_u16be(uint8_t *p, uint16_t value) {
    p[0] = (uint8_t)(value >> 8);
    p[1] = (uint8_t)value;
}

static void put_u32be(uint8_t *p, uint32_t value) {
    p[0] = (uint8_t)(value >> 24);
    p[1] = (uint8_t)(value >> 16);
    p[2] = (uint8_t)(value >> 8);
    p[3] = (uint8_t)value;
}

static size_t make_valid_ilbm(uint8_t *data, size_t capacity) {
    const size_t length = 64;
    if (capacity < length) return 0;
    memset(data, 0, length);

    memcpy(data, "FORM", 4);
    put_u32be(data + 4, 56);
    memcpy(data + 8, "ILBM", 4);

    memcpy(data + 12, "BMHD", 4);
    put_u32be(data + 16, 20);
    put_u16be(data + 20, 1);
    put_u16be(data + 22, 1);
    data[28] = 1;
    data[30] = 0;
    data[34] = 1;
    data[35] = 1;

    memcpy(data + 40, "CMAP", 4);
    put_u32be(data + 44, 6);
    data[51] = 255;

    memcpy(data + 54, "BODY", 4);
    put_u32be(data + 58, 2);
    data[62] = 0x80;
    return length;
}

static int expect_rejected(const uint8_t *data, size_t length, const char *name) {
    CGImageRef image = iff_createSafeImageFromData(data, length, true);
    if (image) {
        CGImageRelease(image);
        fprintf(stderr, "FAIL: malformed input accepted: %s\n", name);
        return 1;
    }
    return 0;
}

int main(void) {
    int failures = 0;
    uint8_t valid[64];
    size_t valid_length = make_valid_ilbm(valid, sizeof(valid));
    CGImageRef image = iff_createSafeImageFromData(valid, valid_length, true);
    if (!image || CGImageGetWidth(image) != 1 || CGImageGetHeight(image) != 1) {
        fprintf(stderr, "FAIL: valid 1x1 ILBM did not decode\n");
        failures++;
    }
    if (image) CGImageRelease(image);

    failures += expect_rejected(valid, 4, "truncated FORM header");

    uint8_t oversized_chunk[20] = {
        'F','O','R','M', 0,0,0,12, 'I','L','B','M',
        'B','M','H','D', 0xff,0xff,0xff,0xff
    };
    failures += expect_rejected(oversized_chunk, sizeof(oversized_chunk), "oversized chunk");

    uint8_t truncated_body[64];
    memcpy(truncated_body, valid, sizeof(valid));
    put_u32be(truncated_body + 58, 1);
    failures += expect_rejected(truncated_body, 63, "truncated uncompressed BODY");

    uint8_t excessive_palette[64];
    memcpy(excessive_palette, valid, sizeof(valid));
    put_u32be(excessive_palette + 44, 769);
    failures += expect_rejected(excessive_palette, sizeof(excessive_palette), "palette over 256 colors");

    if (failures == 0) {
        puts("PASS: valid input decoded and malformed inputs were rejected");
    }
    return failures == 0 ? 0 : 1;
}
