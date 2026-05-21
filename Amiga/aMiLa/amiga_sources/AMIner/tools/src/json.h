/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef JSON_JSON_H
#define JSON_JSON_H

#define JSMN_STRICT       /* Strict JSON parsing */
// JSMN_PARENT_LINKS breaks things up!
// #define JSMN_PARENT_LINKS /* Speeds things up */
#include "jsmn.h"
#include "utf8_remap.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct tJson {
	char *szData;
	jsmntok_t *pTokens;
	uint16_t fwTokenCount;
} tJson;

tJson *jsonCreate(const char *szFilePath);

void jsonDestroy(tJson *pJson);

uint16_t jsonGetElementInArray(const tJson *pJson,uint16_t uwParentIdx,uint16_t uwIdx);

uint16_t jsonGetElementInStruct(
	const tJson *pJson,uint16_t uwParentIdx,const char *szElement
);

uint16_t jsonGetDom(const tJson *pJson,const char *szPattern);

uint32_t jsonTokToUlong(const tJson *pJson,uint16_t uwTok);

uint16_t jsonStrLen(const tJson *pJson, uint16_t uwTok);

uint16_t jsonTokStrCpy(
	const tJson *pJson, const tCodeRemap *pRemap, uint16_t uwTok, char *pDst,
	uint16_t uwMaxBytes
);

#ifdef __cplusplus
}
#endif

#endif // JSON_JSON_H
