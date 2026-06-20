#ifndef GUARD_IMPSBRU_CUBE_H
#define GUARD_IMPSBRU_CUBE_H

#include <ace/utils/bitmap.h>

#include "config.h"

extern UBYTE g_pCubeCrossSideAdjust[CROSS_SIDE_COUNT][CROSS_SIDE_COUNT][2];
extern tBitMap *g_pCubeBitMapMaskAtlas[CUBE_ATLAS_SIZE];
extern tBitMap *g_pCubeMapDepthMask;
extern tBitMap *g_pCubeDepthMask;

void createCubeAtlas();
void destroyCubeAtlas();

UBYTE getCubeDepth(
	UBYTE ubCrossSide,
	UBYTE ubCrossSideAdjustRotation
);

void drawCube(
	UWORD uwX,
	UWORD uwY
);

void cacheCubeBacground(
	UWORD uwX,
	UWORD uwY
);

void undrawCube(
	UWORD uwX,
	UWORD uwY
);

void drawCubeAtlasIndex(
	UWORD uwX,
	UWORD uwY,
	UBYTE ubAtlasIndex
);

#endif
