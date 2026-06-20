#include "json.h"
#include <stdlib.h>
#include <ace/managers/log.h>
#include <ace/managers/memory.h>
#include <ace/utils/file.h>

tJson *jsonCreate(const char *szFilePath) {
	logBlockBegin("jsonCreate(szFilePath: %s)", szFilePath);
	tJson *pJson = memAllocFast(sizeof(tJson));

	// Read whole file to string
	tFile *pFile = fileOpen(szFilePath, "rb");
	if(!pFile) {
		logWrite("ERR: File doesn't exist: '%s'\n", szFilePath);
	}
	fileSeek(pFile, 0, FILE_SEEK_END);
	ULONG ulFileSize = fileGetPos(pFile);
	fileSeek(pFile, 0, FILE_SEEK_SET);

	pJson->szData = memAllocFast(ulFileSize+1);
	fileRead(pFile, pJson->szData, ulFileSize);
	pJson->szData[ulFileSize] = '\0';
	fileClose(pFile);

	jsmn_parser sJsonParser;
	jsmn_init(&sJsonParser);

	// Count tokens & alloc
	pJson->fwTokenCount = jsmn_parse(&sJsonParser, pJson->szData, ulFileSize+1, 0, 0);
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
		&sJsonParser, pJson->szData, ulFileSize+1, pJson->pTokens, pJson->fwTokenCount
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
			while(*c != ']') {
				if(*c < '0' || *c > '9') {
					return 0;
				}
				uwIdx = uwIdx*10 + (*c - '0');
				++c;
			}
			uwParentTok = jsonGetElementInArray(pJson, uwParentTok, uwIdx);
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
		}
		if(!uwParentTok) {
			return 0;
		}

	} while(*c != '\0');
	return uwParentTok;
}

ULONG jsonTokToUlong(const tJson *pJson, UWORD uwTok, LONG lBase) {
	return strtoul(pJson->szData + pJson->pTokens[uwTok].start, 0, lBase);
}

UWORD jsonTokStrCpy(
	const tJson *pJson, UWORD uwTok, char *pDst, UWORD uwMaxLength
) {
	UWORD uwTrueLength = pJson->pTokens[uwTok].end - pJson->pTokens[uwTok].start;
	if(uwMaxLength) {
		UWORD uwCpyLength = MIN(uwTrueLength, uwMaxLength-1);
		memcpy(pDst, pJson->szData + pJson->pTokens[uwTok].start, uwCpyLength);
		pDst[uwCpyLength] = '\0';
	}
	return uwTrueLength;
}

