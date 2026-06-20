/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef JSON_UTF8_REMAP_H
#define JSON_UTF8_REMAP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct tCodeRemap {
	uint32_t ulCodepoint;
	uint8_t ubFontCode;
} tCodeRemap;

char remapChar(const tCodeRemap *pRemapCodes, uint32_t ulCodepoint);

#ifdef __cplusplus
}
#endif

#endif // JSON_UTF8_REMAP_H
