/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "utf8_remap.h"
#include "utf8.h"
#include <ace/managers/log.h>
#include <ace/managers/system.h>
#include <ace/utils/disk_file.h>
#include "assets.h"

char remapChar(const tCodeRemap *pRemap, ULONG ulCodepoint) {
	if(ulCodepoint < 128) {
		return (char)ulCodepoint;
	}
	for(UWORD j = 0; pRemap[j].ulCodepoint != 0; ++j) {
		if(pRemap[j].ulCodepoint == ulCodepoint) {
			return pRemap[j].ubFontCode;
		}
	}
	return (char)ulCodepoint;
}

char *remapFile(
	const char *szFilePath, const tCodeRemap *pRemap,
	UWORD *pOutAllocSize, UWORD *pOutStringSize
) {
	systemUse();
	// Read whole file to plain buffer
	tFile *pFileContents = GET_SUBFILE(szFilePath);

	if(!pFileContents) {
		logWrite("ERR: Couldn't read contents of '%s'\n", szFilePath);
		systemUnuse();
		return 0;
	}

	UWORD uwRemainingChars = fileGetSize(pFileContents);
	UWORD uwFileContentsBufferSize = uwRemainingChars + 1;
	char *szFileContents = memAllocFast(uwFileContentsBufferSize);
	fileRead(pFileContents, szFileContents, uwFileContentsBufferSize);
	fileClose(pFileContents);
	systemUnuse();

	// Unicode takes more or same space than ascii - can convert in-place
	UWORD uwTextLength = 0;
	ULONG ulCodepoint;
	ULONG ulState = 0;
	UWORD uwReadPos = 0;
	UBYTE ubCharCode;
	while(uwRemainingChars--) {
		ubCharCode = szFileContents[uwReadPos++];
		if(decode(&ulState, &ulCodepoint, ubCharCode) != UTF8_ACCEPT) {
			continue;
		}

		if(pRemap) {
			ubCharCode = remapChar(pRemap, ulCodepoint);
		}
		else {
			ubCharCode = ulCodepoint;
		}

		szFileContents[uwTextLength++] = ubCharCode;
	}
	szFileContents[uwTextLength] = '\0';

	*pOutAllocSize = uwFileContentsBufferSize;
	if(pOutStringSize) {
		*pOutStringSize = uwTextLength;
	}
	return szFileContents;
}
