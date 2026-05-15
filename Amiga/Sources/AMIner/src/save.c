/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "save.h"
#include <string.h>
#include <ace/managers/log.h>

void saveTagGet(tFile *pFile, char *szTagRead) {
	fileRead(pFile, szTagRead, sizeof(SAVE_TAG_ACCOUNTING) - 1);
	szTagRead[sizeof(SAVE_TAG_ACCOUNTING) - 1] = '\0';
}

UBYTE saveTagIs(const char *szTagRead, const char *szTagRef) {
	if(memcmp(szTagRead, szTagRef, sizeof(SAVE_TAG_ACCOUNTING) - 1)) {
		logWrite(
			"ERR: Save tag mismatch, got %s, expected %s\n", szTagRead, szTagRef
		);
		return 0;
	}

	return 1;
}

UBYTE saveReadTag(tFile *pFile, const char *szTag) {
	char szTagRead[5] = {'\0'};
	fileRead(pFile, szTagRead, sizeof(szTagRead) - 1);
	return saveTagIs(szTagRead, szTag);
}

void saveWriteTag(tFile *pFile, const char *szTag) {
	fileWrite(pFile, szTag, strlen(szTag));
}
