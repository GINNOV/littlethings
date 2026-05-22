/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "json.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "utf8.h"

tJson *jsonCreate(const char *szFilePath) {
	// Open file and get its size
	FILE *pFile = fopen(szFilePath, "rb");
	if(!pFile) {
		printf("ERR: File doesn't exist\n");
		return 0;
	}
	fseek(pFile, 0, SEEK_END);
	int32_t lFileSize = ftell(pFile);
	fseek(pFile, 0, SEEK_SET);

	// Read whole file for json processing
	tJson *pJson = malloc(sizeof(tJson));
	pJson->szData = malloc(lFileSize+1);
	fread(pJson->szData, lFileSize, 1, pFile);
	pJson->szData[lFileSize] = '\0';
	fclose(pFile);

	jsmn_parser sJsonParser;
	jsmn_init(&sJsonParser);

	// Count tokens & alloc
	pJson->fwTokenCount = jsmn_parse(&sJsonParser, pJson->szData, lFileSize+1, 0, 0);
	if(pJson->fwTokenCount < 0) {
		printf(
			"ERR: JSON during token counting: %hd\n", pJson->fwTokenCount
		);
		return 0;
	}
	pJson->pTokens = malloc(pJson->fwTokenCount * sizeof(jsmntok_t));

	// Read tokens
	jsmn_init(&sJsonParser);
	int16_t fwResult = jsmn_parse(
		&sJsonParser, pJson->szData, lFileSize+1, pJson->pTokens, pJson->fwTokenCount
	);
	if(fwResult < 0) {
		printf("ERR: JSON during tokenize: %hd\n", fwResult);
		return 0;
	}

	return pJson;
}

void jsonDestroy(tJson *pJson) {
	free(pJson->pTokens);
	free(pJson->szData);
	free(pJson);
}

uint16_t jsonGetElementInArray(
	const tJson *pJson, uint16_t uwParentIdx, uint16_t uwIdx
) {
	uint16_t uwCurrIdx = 0;
	if(pJson->pTokens[uwParentIdx].type != JSMN_ARRAY) {
		return 0;
	}
	for(uint16_t i = uwParentIdx+1; i < pJson->fwTokenCount; ++i) {
		if(pJson->pTokens[i].start > pJson->pTokens[uwParentIdx].end) {
			// We're outside of parent - nothing found
			return 0;
		}
		if(uwCurrIdx == uwIdx) {
			return i;
		}
		else {
			// Something else - skip it
			uint16_t uwSkipPos = pJson->pTokens[i].end;
			while(pJson->pTokens[i+1].start < uwSkipPos) {
				++i;
			}
		}
		++uwCurrIdx;
	}
	// Unxepected end of JSON
	return 0;
}

uint16_t jsonGetElementInStruct(
	const tJson *pJson, uint16_t uwParentIdx, const char *szElement
) {
	uint8_t ubElementNameLength = (uint8_t)strlen(szElement);
	for(uint16_t i = uwParentIdx+1; i < pJson->fwTokenCount; ++i) {
		if(pJson->pTokens[i].start > pJson->pTokens[uwParentIdx].end) {
			// We're outside of parent - nothing found
			return 0;
		}
		const char *pNextElementName = pJson->szData + pJson->pTokens[i].start;
		if(
			!memcmp(pNextElementName, szElement, ubElementNameLength) &&
			pNextElementName[ubElementNameLength] == '"'
		) {
			// Found label - next is content
			return i+1;
		}
		else {
			// Something else - skip it
			uint16_t uwSkipPos = pJson->pTokens[++i].end;
			while(pJson->pTokens[i+1].start < uwSkipPos) {
				++i;
			}
		}
	}
	// Unxepected end of JSON
	return 0;
}

uint16_t jsonGetDom(const tJson *pJson, const char *szPattern) {
	// "first.second.third" or "first" or "first[1].third"
	uint16_t uwParentTok = 0;
	const char *c = szPattern;
	do {
		if(*c == '[') {
			// Array element - read number
			uint16_t uwIdx = 0;
			while(*(++c) != ']') {
				if(*c < '0' || *c > '9') {
					printf("ERR: Unexpected idx char: '%c'\n", *c);
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
			uint16_t uwElementNameLength = 0;
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
				printf("Can't find: '%s'\n", szElementName);
			}
		}
		if(!uwParentTok) {
			return 0;
		}

	} while(*c != '\0');
	return uwParentTok;
}

uint32_t jsonTokToUlong(const tJson *pJson, uint16_t uwTok) {
	return strtoul(pJson->szData + pJson->pTokens[uwTok].start, 0, 10);
}

uint16_t jsonStrLen(const tJson *pJson, uint16_t uwTok) {
  uint32_t ulCodepoint, ulState = 0;
	uint16_t uwLength = 0;
	for(uint16_t i = pJson->pTokens[uwTok].start; i < pJson->pTokens[uwTok].end; ++i) {
		uint8_t ubCharCode = (uint8_t)pJson->szData[i];
		if(decode(&ulState, &ulCodepoint, ubCharCode) != UTF8_ACCEPT) {
			continue;
		}
		++uwLength;
	}
	return uwLength;
}

uint16_t jsonTokStrCpy(
	const tJson *pJson, const tCodeRemap *pRemap, uint16_t uwTok, char *pDst,
	uint16_t uwMaxBytes
) {
	uint16_t uwLength = 0;
	uint32_t ulCodepoint, ulState = 0;
	uint8_t isIllegalChar = 0;
	for(uint16_t i = pJson->pTokens[uwTok].start; i < pJson->pTokens[uwTok].end; ++i) {
		uint8_t ubCharCode = (uint8_t)pJson->szData[i];
		if(decode(&ulState, &ulCodepoint, ubCharCode) != UTF8_ACCEPT) {
			continue;
		}

		if(pRemap) {
			// Remap if remap array has been passed
			char cRemap = remapChar(pRemap, ulCodepoint);
			if(cRemap == '\xFF') {
				isIllegalChar = 1;
			}
			pDst[uwLength] = cRemap;
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
	if(isIllegalChar) {
		printf("ERR: Illegal char on string '%s'\n", pDst);
		exit(EXIT_FAILURE);
	}
	return uwLength;
}
