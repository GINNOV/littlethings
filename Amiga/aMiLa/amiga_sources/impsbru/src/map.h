#ifndef GUARD_IMPSBRU_MAP_H
#define GUARD_IMPSBRU_MAP_H

#include <ace/types.h>

#include "config.h"

extern UBYTE g_pMapData[MAP_WIDTH][MAP_HEIGHT];
extern UBYTE g_ubMapStartPointX;
extern UBYTE g_ubMapStartPointY;
extern UBYTE g_ubMapStartPointCrossSide;
extern UBYTE g_ubMapFinishPointX;
extern UBYTE g_ubMapFinishPointY;
extern UBYTE g_ubMapFinishPointCrossSide;
extern BYTE g_pMapCursorShifts[2][CROSS_SIDE_COUNT][2];

UWORD getMapCrossX(
	UBYTE ubCrossXIndex
);

UWORD getMapCrossY(
	UBYTE ubCrossXIndex,
	UBYTE ubCrossYIndex
);

BYTE getMapShiftX(
	UBYTE ubMapCursorX,
	UBYTE ubCrossSide
);

BYTE getMapShiftY(
	UBYTE ubMapCursorX,
	UBYTE ubCrossSide
);

UBYTE getRowParity(
	UBYTE ubMapCursorX
);

UBYTE getMapNeighborX(
	UBYTE ubMapCursorX,
	UBYTE ubCrossSide
);

UBYTE getMapNeighborY(
	UBYTE ubMapCursorX,
	UBYTE ubMapCursorY,
	UBYTE ubCrossSide
);

UBYTE getMapNeighborXRestrictive(
	UBYTE ubMapCursorX,
	UBYTE ubCrossSide
);

UBYTE getMapNeighborYRestrictive(
	UBYTE ubMapCursorX,
	UBYTE ubMapCursorY,
	UBYTE ubCrossSide
);

UBYTE isMapEmpty();

void drawMap();
void undrawMap();

void drawMapCross(
	UBYTE ubCrossXIndex,
	UBYTE ubCrossYIndex
);

void undrawMapCross(
	UBYTE ubCrossXIndex,
	UBYTE ubCrossYIndex
);

void drawMapStartPoint();
void undrawMapStartPoint();
void drawMapFinishPoint();
void undrawMapFinishPoint();

UBYTE saveMapToFile(
	char *szFilePath
);

UBYTE loadMapFromFile(
	char *szFilePath
);

#endif
