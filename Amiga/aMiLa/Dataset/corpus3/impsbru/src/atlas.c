#include "atlas.h"

void createAtlasFile(tBitMap *pBitMapAtlas[], UBYTE ubAtlasIndex, char *szBitMapFilePath) {
	pBitMapAtlas[ubAtlasIndex] = bitmapCreateFromFile(szBitMapFilePath, 0);
}

void destroyAtlasFiles(tBitMap *pBitMapAtlas[], UBYTE ubAtlasCount) {
	UBYTE ubAtlasIndex = ubAtlasCount;
	while (ubAtlasIndex--) {
		bitmapDestroy(pBitMapAtlas[ubAtlasIndex]);
	}
}

void createAtlasFileWithMask(tBitMap *pBitMapAtlas[], tBitMap *pBitMapMaskAtlas[], UBYTE ubAtlasIndex, char *szBitMapFilePath, char *szBitMapMaskFilePath) {
	pBitMapAtlas[ubAtlasIndex] = bitmapCreateFromFile(szBitMapFilePath, 0);
	pBitMapMaskAtlas[ubAtlasIndex] = bitmapCreateFromFile(szBitMapMaskFilePath, 0);
}

void destroyAtlasFilesWithMask(tBitMap *pBitMapAtlas[], tBitMap *pBitMapMaskAtlas[], UBYTE ubAtlasCount) {
	UBYTE ubAtlasIndex = ubAtlasCount;
	while (ubAtlasIndex--) {
		if (pBitMapAtlas[ubAtlasIndex]) {
			bitmapDestroy(pBitMapAtlas[ubAtlasIndex]);
		}

		if (pBitMapMaskAtlas[ubAtlasIndex]) {
			bitmapDestroy(pBitMapMaskAtlas[ubAtlasIndex]);
		}
	}
}
