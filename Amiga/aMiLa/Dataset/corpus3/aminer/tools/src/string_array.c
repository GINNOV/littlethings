/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "string_array.h"
#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

//----------------------------------------------------------------- STRING ALLOC

static char *stringCreateFromTok(
	const tJson *pJson, const tCodeRemap *pRemap, uint16_t uwTokIdx
) {
	char *szDestination = 0;
	if(pJson->pTokens[uwTokIdx].type == JSMN_ARRAY) {
		uint16_t uwAllocSize = 0;
		for(uint16_t i = 0; i < pJson->pTokens[uwTokIdx].size; ++i) {
			uint16_t uwArrIdx = jsonGetElementInArray(pJson, uwTokIdx, i);
			uwAllocSize += jsonStrLen(pJson, uwArrIdx) + 1;
		}
		szDestination = malloc(uwAllocSize);
		uint16_t uwOffs = 0;
		for(uint16_t i = 0; i < pJson->pTokens[uwTokIdx].size; ++i) {
			uint16_t uwArrIdx = jsonGetElementInArray(pJson, uwTokIdx, i);
			uwOffs += jsonTokStrCpy(
				pJson, pRemap, uwArrIdx, &szDestination[uwOffs], uwAllocSize - uwOffs
			);
			szDestination[uwOffs++] = '\n';
		}
		szDestination[uwAllocSize - 1] = '\0';
	}
	else if(pJson->pTokens[uwTokIdx].type == JSMN_STRING) {
		uint16_t uwAllocSize = jsonStrLen(pJson, uwTokIdx) + 1;
		szDestination = malloc(uwAllocSize);
		jsonTokStrCpy(pJson, pRemap, uwTokIdx, szDestination, uwAllocSize);
	}
	else {
		printf("ERR: unknown json node type: %d\n", pJson->pTokens[uwTokIdx].type);
	}
	return szDestination;
}

static char *stringCreateFromDom(
	const tJson *pJson, const tCodeRemap *pRemap, const char *szDom
) {
	char *szDestination;
	uint16_t uwIdx = jsonGetDom(pJson, szDom);
	if(uwIdx == 0) {
		printf("ERR: %s not found\n", szDom);
		uint16_t uwDestinationLength = (uint16_t)(strlen(szDom) + 1);
		szDestination = malloc(uwDestinationLength);
		strcpy_s(szDestination, uwDestinationLength, szDom);
	}
	else {
		szDestination = stringCreateFromTok(pJson, pRemap, uwIdx);
	}
	return szDestination;
}

static void stringDestroy(char *szString) {
	free(szString);
}

//----------------------------------------------------------------- STRING ARRAY

static char **stringArrayCreate(uint16_t uwCount) {
	char **pArray = 0;
	if(uwCount) {
		pArray = malloc((uwCount + 1) * sizeof(char*));
		for(uint16_t i = 0; i < uwCount; ++i) {
			pArray[i] = STRING_ARRAY_EMPTY_POS;
		}
	}
	pArray[uwCount] = STRING_ARRAY_TERMINATOR;
	return pArray;
}

char **stringArrayCreateFromDom(
	tJson *pJson, const tCodeRemap *pRemap, const char *szDom
) {
	uint16_t uwTokArray = jsonGetDom(pJson, szDom);
	if(!uwTokArray) {
		printf("ERR: json not found: '%s'\n", szDom);
		return stringArrayCreate(0);
	}
	uint16_t uwCount = pJson->pTokens[uwTokArray].size;
	char **pArray = stringArrayCreate(uwCount);

	for(uint16_t i = 0; i < uwCount; ++i) {
		uint16_t uwTokElement = jsonGetElementInArray(pJson, uwTokArray, i);
		if(!uwTokElement) {
			printf("ERR: json array element not found: '%s'[%hhu]", szDom, i);
		}
		else {
			pArray[i] = stringCreateFromTok(pJson, pRemap, uwTokElement);
		}
	}
	return pArray;
}

char **stringArrayCreateFromDomElements(
	tJson *pJson, const tCodeRemap *pRemap, const char * const *pNames
) {
	uint16_t uwCount = stringArrayGetCount(pNames);
	char **pArray = stringArrayCreate(uwCount);
	for(uint16_t i = 0; i < uwCount; ++i) {
		const char *szDom = pNames[i];
		pArray[i] = stringCreateFromDom(pJson, pRemap, szDom);
	}
	return pArray;
}

void stringArrayDestroy(char **pArray) {
	uint16_t uwCount;
	for(uwCount = 0; pArray[uwCount] != STRING_ARRAY_TERMINATOR; ++uwCount) {
		if(pArray[uwCount] != STRING_ARRAY_EMPTY_POS) {
			stringDestroy(pArray[uwCount]);
		}
	}
	// Free string pointers + terminator
	free(pArray);
}

uint16_t stringArrayGetCount(const char * const *pArray) {
	uint16_t uwCount;
	for(uwCount = 0; pArray[uwCount] != STRING_ARRAY_TERMINATOR; ++uwCount) { }
	return uwCount;
}
