/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "json.h"
#include <stdlib.h>
#include <ace/managers/log.h>
#include <ace/managers/memory.h>
#include <ace/managers/system.h>
#include <ace/utils/file.h>
#include "utf8.h"

tJson *jsonCreate(const char *szFilePath) {
	systemUse();
	logBlockBegin("jsonCreate(szFilePath: '%s')", szFilePath);

	// Open file and get its size
	tFile *pFile = fileOpen(szFilePath, "rb");
	if(!pFile) {
		logWrite("ERR: File doesn't exist\n");
		logBlockEnd("jsonCreate()");
		systemUnuse();
		return 0;
	}
	LONG lFileSize = fileGetSize(szFilePath);

	// Read whole file for json processing
	tJson *pJson = memAllocFast(sizeof(tJson));
	pJson->szData = memAllocFast(lFileSize+1);
	fileRead(pFile, pJson->szData, lFileSize);
	pJson->szData[lFileSize] = '\0';
	fileClose(pFile);
	systemUnuse();

	jsmn_parser sJsonParser;
	jsmn_init(&sJsonParser);

	// Count tokens & alloc
	pJson->fwTokenCount = jsmn_parse(&sJsonParser, pJson->szData, lFileSize+1, 0, 0);
	if(pJson->fwTokenCount < 0) {
		logWrite(
			"ERR: JSON during token counting: %"PRI_FWORD"\n", pJson->fwTokenCount
		);
		logBlockEnd("jsonCreate()");
		return 0;
	}
	pJson->pTokens = memAllocFast(pJson->fwTokenCount * sizeof(jsmntok_t));

	// Read tokens
	jsmn_init(&sJsonParser);
	FWORD fwResult = jsmn_parse(
		&sJsonParser, pJson->szData, lFileSize+1, pJson->pTokens, pJson->fwTokenCount
	);
	if(fwResult < 0) {
		logWrite("ERR: JSON during tokenize: %"PRI_FWORD"\n", fwResult);
		logBlockEnd("jsonCreate()");
		return 0;
	}

	logBlockEnd("jsonCreate()");
	return pJson;
}

void jsonDestroy(tJson *pJson) {
	memFree(pJson->pTokens, sizeof(jsmntok_t) * pJson->fwTokenCount);
	memFree(pJson->szData, strlen(pJson->szData) + 1);
	memFree(pJson, sizeof(tJson));
}

UWORD jsonGetElementInArray(
	const tJson *pJson, UWORD uwParentIdx, UWORD uwIdx
) {
	UWORD uwCurrIdx = 0;
	if(pJson->pTokens[uwParentIdx].type != JSMN_ARRAY) {
		return 0;
	}
	for(UWORD i = uwParentIdx+1; i < pJson->fwTokenCount; ++i) {
		if(pJson->pTokens[i].start > pJson->pTokens[uwParentIdx].end) {
			// We're outside of parent - nothing found
			return 0;
		}
		if(uwCurrIdx == uwIdx) {
			return i;
		}
		else {
			// Something else - skip it
			UWORD uwSkipPos = pJson->pTokens[i].end;
			while(pJson->pTokens[i+1].start < uwSkipPos) {
				++i;
			}
		}
		++uwCurrIdx;
	}
	// Unxepected end of JSON
	return 0;
}

UWORD jsonGetElementInStruct(
	const tJson *pJson, UWORD uwParentIdx, const char *szElement
) {
	for(UWORD i = uwParentIdx+1; i < pJson->fwTokenCount; ++i) {
		if(pJson->pTokens[i].start > pJson->pTokens[uwParentIdx].end) {
			// We're outside of parent - nothing found
			return 0;
		}
		const char *pNextElementName = pJson->szData + pJson->pTokens[i].start;
		if(
			!memcmp(pNextElementName, szElement, strlen(szElement)) &&
			pNextElementName[strlen(szElement)] == '"'
		) {
			// Found label - next is content
			return i+1;
		}
		else {
			// Something else - skip it
			UWORD uwSkipPos = pJson->pTokens[++i].end;
			while(pJson->pTokens[i+1].start < uwSkipPos) {
				++i;
			}
		}
	}
	// Unxepected end of JSON
	return 0;
}

UWORD jsonGetDom(const tJson *pJson, const char *szPattern) {
	// "first.second.third" or "first" or "first[1].third"
	UWORD uwParentTok = 0;
	const char *c = szPattern;
	do {
		if(*c == '[') {
			// Array element - read number
			UWORD uwIdx = 0;
			while(*(++c) != ']') {
				if(*c < '0' || *c > '9') {
					logWrite("ERR: Unexpected idx char: '%c'\n", *c);
					return 0;
				}
				uwIdx = uwIdx*10 + (*c - '0');
			}
			uwParentTok = jsonGetElementInArray(pJson, uwParentTok, uwIdx);
			++c;
			if(*c == '.') {
				++c;
			}
		}
		else {
			// Struct element - read name
			char szElementName[200];
			UWORD uwElementNameLength = 0;
			while(*c != '.' && *c != '[' && *c != '\0') {
				szElementName[uwElementNameLength] = *c;
				++uwElementNameLength;
				++c;
			}
			szElementName[uwElementNameLength] = '\0';
			uwParentTok = jsonGetElementInStruct(pJson, uwParentTok, szElementName);
			if(*c == '.') {
				++c;
			}
			if(!uwParentTok) {
				logWrite("Can't find: '%s'\n", szElementName);
			}
		}
		if(!uwParentTok) {
			return 0;
		}

	} while(*c != '\0');
	return uwParentTok;
}

ULONG jsonTokToUlong(const tJson *pJson, UWORD uwTok) {
	return strtoul(pJson->szData + pJson->pTokens[uwTok].start, 0, 10);
}

UWORD jsonStrLen(const tJson *pJson, UWORD uwTok) {
  ULONG ulCodepoint, ulState = 0;
	UWORD uwLength = 0;
	for(UWORD i = pJson->pTokens[uwTok].start; i < pJson->pTokens[uwTok].end; ++i) {
		UBYTE ubCharCode = (UBYTE)pJson->szData[i];
		if(decode(&ulState, &ulCodepoint, ubCharCode) != UTF8_ACCEPT) {
			continue;
		}
		++uwLength;
	}
	return uwLength;
}

UWORD jsonTokStrCpy(
	const tJson *pJson, const tCodeRemap *pRemap, UWORD uwTok, char *pDst,
	UWORD uwMaxBytes
) {
	UWORD uwLength = 0;
	ULONG ulCodepoint, ulState = 0;
	for(UWORD i = pJson->pTokens[uwTok].start; i < pJson->pTokens[uwTok].end; ++i) {
		UBYTE ubCharCode = (UBYTE)pJson->szData[i];
		if(decode(&ulState, &ulCodepoint, ubCharCode) != UTF8_ACCEPT) {
			continue;
		}

		if(pRemap) {
			// Remap if remap array has been passed
			pDst[uwLength] = remapChar(pRemap, ulCodepoint);
		}
		else {
			// By default, write codepoint truncated to byte
			pDst[uwLength] = ulCodepoint;
		}

		// Stop if max size has been reached
		if(++uwLength >= uwMaxBytes - 1) {
			break;
		}
	}
	pDst[uwLength] = '\0';
	return uwLength;
}
