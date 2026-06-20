/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef JSON_UTF8_REMAP_H
#define JSON_UTF8_REMAP_H

#include <ace/types.h>

typedef struct tCodeRemap {
	ULONG ulCodepoint;
	UBYTE ubFontCode;
} tCodeRemap;

char remapChar(const tCodeRemap *pRemapCodes, ULONG ulCodepoint);

#endif // JSON_UTF8_REMAP_H
