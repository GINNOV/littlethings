#ifndef GUARD_OF_JSON_H
#define GUARD_OF_JSON_H

#define JSMN_STRICT       /* Strict JSON parsing */
// JSMN_PARENT_LINKS breaks things up!
// #define JSMN_PARENT_LINKS /* Speeds things up */
#include "jsmn.h"
#include <ace/types.h>

typedef struct _tJson {
	char *szData;
	jsmntok_t *pTokens;
	FWORD fwTokenCount;
} tJson;

tJson *jsonCreate(const char *szFilePath);

void jsonDestroy(tJson *pJson);

UWORD jsonGetElementInArray(const tJson *pJson,UWORD uwParentIdx,UWORD uwIdx);

UWORD jsonGetElementInStruct(
	const tJson *pJson,UWORD uwParentIdx,const char *szElement
);

UWORD jsonGetDom(const tJson *pJson,const char *szPattern);

ULONG jsonTokToUlong(const tJson *pJson,UWORD uwTok,LONG lBase);

UWORD jsonTokStrCpy(
	const tJson *pJson,UWORD uwTok,char *pDst,UWORD uwMaxLength
);

#endif // GUARD_OF_JSON_H
