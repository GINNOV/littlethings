#ifndef GUARD_IMPSBRU_CROSS_H
#define GUARD_IMPSBRU_CROSS_H

#include <ace/utils/bitmap.h>

#include "config.h"

extern tBitMap *g_pCrossBitMapAtlas[CROSS_ATLAS_SIZE];
extern tBitMap *g_pCrossBitMapMaskAtlas[CROSS_ATLAS_SIZE];

UBYTE getCrossSideState(
	UBYTE ubCrossData,
	UBYTE ubCrossSide
);

UBYTE getOppositeCrossSide(
	UBYTE ubCrossSide
);

void createCrossAtlas();

void createCrossAtlasFile(
	UBYTE ubAtlasIndex,
	char *szBitMapFilePath,
	char *szBitMapMaskFilePath
);

void destroyCrossAtlas();

void drawCross(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossData
);

void drawCrossCenter(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossData
);

void drawCrossDepthMiddle(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossData
);

void drawCrossDepthTop(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossData
);

void undrawCross(
	UWORD uwX,
	UWORD uwY
);

void drawCrossSide(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubCrossData,
	UBYTE ubCrossSide
);

void drawDestinationPoint(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubDestinationPointSide
);

void undrawDestinationPoint(
	UWORD uwX,
	UWORD uwY
);

void drawCrossAtlasIndex(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubAtlasIndex
);

#endif
