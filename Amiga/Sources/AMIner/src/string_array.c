/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "string_array.h"
#include <stdarg.h>
#include <ace/managers/memory.h>
#include <ace/managers/log.h>

//------------------------------------------------------------------ PRIVATE FNS

static void stringDestroy(char *szString) {
	memFree(szString, strlen(szString) + 1);
}

static char **stringArrayCreate(UWORD uwCount) {
	logBlockBegin("stringArrayCreate(uwCount: %hu)", uwCount);
	char **pArray = 0;
	if(uwCount) {
		pArray = memAllocFast((uwCount + 1) * sizeof(char*));
		for(UWORD i = 0; i < uwCount; ++i) {
			pArray[i] = STRING_ARRAY_EMPTY_POS;
		}
	}
	pArray[uwCount] = STRING_ARRAY_TERMINATOR;
	logBlockEnd("stringArrayCreate()");
	return pArray;
}

//------------------------------------------------------------------- PUBLIC FNS

char **stringArrayCreateFromFd(tFile *pFile) {
	UWORD uwCount;
	fileRead(pFile, &uwCount, sizeof(uwCount));

	char **pArray = stringArrayCreate(uwCount);
	for(UWORD i = 0; i < uwCount; ++i) {
		UBYTE ubStringLength;
		fileRead(pFile, &ubStringLength, sizeof(ubStringLength));
		pArray[i] = memAllocFast(ubStringLength + 1);
		fileRead(pFile, pArray[i], ubStringLength);
		pArray[i][ubStringLength] = '\0';
	}
	fileClose(pFile);

	return pArray;
}

void stringArrayDestroy(char **pArray) {
	logBlockBegin("stringArrayDestroy(pArray: %p)", pArray);
	UWORD uwCount;
	for(uwCount = 0; pArray[uwCount] != STRING_ARRAY_TERMINATOR; ++uwCount) {
		if(pArray[uwCount] != STRING_ARRAY_EMPTY_POS) {
			logWrite(
				"Freeing string %hhu (0x%p): '%s'\n",
				uwCount, pArray[uwCount], pArray[uwCount]
			);
			stringDestroy(pArray[uwCount]);
		}
	}
	// Free string pointers + terminator
	memFree(pArray, sizeof(char*) * (uwCount + 1));
	logBlockEnd("stringArrayDestroy()");
}

UWORD stringArrayGetCount(const char * const *pArray) {
	UWORD uwCount;
	for(uwCount = 0; pArray[uwCount] != STRING_ARRAY_TERMINATOR; ++uwCount) { }
	return uwCount;
}
