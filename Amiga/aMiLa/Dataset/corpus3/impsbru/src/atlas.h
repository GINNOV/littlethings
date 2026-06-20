#ifndef GUARD_IMPSBRU_ATLAS_H
#define GUARD_IMPSBRU_ATLAS_H

#include <ace/utils/bitmap.h>

void createAtlasFile(
	tBitMap **pBitMapAtlas,
	UBYTE ubAtlasIndex,
	char *szBitMapFilePath
);

void destroyAtlasFiles(
	tBitMap **pBitMapAtlas,
	UBYTE ubAtlasCount
);

void createAtlasFileWithMask(
	tBitMap **pBitMapAtlas,
	tBitMap **pBitMapMaskAtlas,
	UBYTE ubAtlasIndex,
	char *szBitMapFilePath,
	char *szBitMapMaskFilePath
);

void destroyAtlasFilesWithMask(
	tBitMap **pBitMapAtlas,
	tBitMap **pBitMapMaskAtlas,
	UBYTE ubAtlasCount
);

#endif
