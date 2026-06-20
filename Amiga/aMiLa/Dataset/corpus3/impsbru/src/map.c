#include "map.h"

#include <ace/managers/blit.h>
#include <ace/managers/system.h>

#include "cross.h"
#include "cube.h"
#include "game.h"

UBYTE g_pMapData[MAP_WIDTH][MAP_HEIGHT] = {0};
UBYTE g_ubMapStartPointX = MAP_WIDTH;
UBYTE g_ubMapStartPointY = MAP_HEIGHT;
UBYTE g_ubMapStartPointCrossSide = 0;
UBYTE g_ubMapFinishPointX = MAP_WIDTH;
UBYTE g_ubMapFinishPointY = MAP_HEIGHT;
UBYTE g_ubMapFinishPointCrossSide = 0;
BYTE g_pMapCursorShifts[2][CROSS_SIDE_COUNT][2] = {
	{
   		{0, -1}, // N
   		{1, -1}, // NE
		{1, 0}, // SE
		{0, 1}, // S
		{-1, 0}, // SW
   		{-1, -1} // NW
	},
	{
		{0, -1}, // N
		{1, 0}, // NE
		{1, 1}, // SE
		{0, 1}, // S
		{-1, 1}, // SW
		{-1, 0} // NW
	}
};

UWORD getMapCrossX(UBYTE ubCrossXIndex) {
	return CROSS_X_SHIFT * ubCrossXIndex;
}

UWORD getMapCrossY(UBYTE ubCrossXIndex, UBYTE ubCrossYIndex) {
	return MAP_Y_OFFSET + ((ubCrossXIndex % 2) * CROSS_ODD_Y_SHIFT) + (CROSS_Y_SHIFT * ubCrossYIndex);
}

BYTE getMapShiftX(UBYTE ubMapCursorX, UBYTE ubCrossSide) {
	return g_pMapCursorShifts[getRowParity(ubMapCursorX)][ubCrossSide][0];
}

BYTE getMapShiftY(UBYTE ubMapCursorX, UBYTE ubCrossSide) {
	return g_pMapCursorShifts[getRowParity(ubMapCursorX)][ubCrossSide][1];
}

UBYTE getRowParity(UBYTE ubMapCursorX) {
	return ubMapCursorX & 1;
}

UBYTE getMapNeighborXRestrictive(UBYTE ubMapCursorX, UBYTE ubCrossSide) {
	BYTE bShiftX = getMapShiftX(ubMapCursorX, ubCrossSide);
	bShiftX += ubMapCursorX;
	if ((0 <= bShiftX) && (bShiftX < MAP_WIDTH)) {
		return bShiftX;
	}

	return MAP_WIDTH;
}

UBYTE getMapNeighborYRestrictive(UBYTE ubMapCursorX, UBYTE ubMapCursorY, UBYTE ubCrossSide) {
	BYTE bShiftY = getMapShiftY(ubMapCursorX, ubCrossSide);
	bShiftY += ubMapCursorY;
	if ((0 <= bShiftY) && (bShiftY < MAP_HEIGHT)) {
		return bShiftY;
	}

	return MAP_HEIGHT;
}

UBYTE getMapNeighborX(UBYTE ubMapCursorX, UBYTE ubCrossSide) {
	BYTE bShiftX = getMapShiftX(ubMapCursorX, ubCrossSide);
	if ((0 < bShiftX) && ((MAP_WIDTH - 1 - ubMapCursorX) < bShiftX)) {
		ubMapCursorX = MAP_WIDTH - 1;
	}
	else if ((bShiftX < 0) && (ubMapCursorX < -bShiftX)) {
		ubMapCursorX = 0;
	}
	else {
		ubMapCursorX += bShiftX;
	}

	return ubMapCursorX;
}

UBYTE getMapNeighborY(UBYTE ubMapCursorX, UBYTE ubMapCursorY, UBYTE ubCrossSide) {
	BYTE bShiftY = getMapShiftY(ubMapCursorX, ubCrossSide);
	if ((0 < bShiftY) && (MAP_HEIGHT - 1 - ubMapCursorY) < bShiftY) {
		ubMapCursorY = MAP_HEIGHT - 1;
	}
	else if ((bShiftY < 0) && (ubMapCursorY < -bShiftY)) {
		ubMapCursorY = 0;
	}
	else {
		ubMapCursorY += bShiftY;
	}

	return ubMapCursorY;
}

UBYTE isMapEmpty() {
	for (UBYTE ubX = 0; ubX < MAP_WIDTH; ++ubX) {
		for (UBYTE ubY = 0; ubY < MAP_HEIGHT; ++ubY) {
			if (g_pMapData[ubX][ubY]) {
				return 0;
			}
		}
	}

	return 1;
}

void drawMap() {
	for (UBYTE ubCrossXIndex = 0; ubCrossXIndex < MAP_WIDTH; ++ubCrossXIndex) {
		for (UBYTE ubCrossYIndex = 0; ubCrossYIndex < MAP_HEIGHT; ++ubCrossYIndex) {
			drawMapCross(ubCrossXIndex, ubCrossYIndex);
		}
	}

	drawMapStartPoint();
	drawMapFinishPoint();
}

void undrawMap() {
	blitRect(
		g_pBufferManager->pBack, 0, MAP_Y_OFFSET,
		MAP_WIDTH * CROSS_X_SHIFT, MAP_HEIGHT * CROSS_Y_SHIFT + CROSS_ODD_Y_SHIFT,
		0
	);
}

void drawMapCross(UBYTE ubCrossXIndex, UBYTE ubCrossYIndex) {
	drawCross(
		getMapCrossX(ubCrossXIndex),
		getMapCrossY(ubCrossXIndex, ubCrossYIndex),
		g_pMapData[ubCrossXIndex][ubCrossYIndex]
	);
}

void undrawMapCross(UBYTE ubCrossXIndex, UBYTE ubCrossYIndex) {
	undrawCross(
		getMapCrossX(ubCrossXIndex),
		getMapCrossY(ubCrossXIndex, ubCrossYIndex)
	);
}

void drawMapStartPoint() {
	if ((g_ubMapStartPointX != MAP_WIDTH) && (g_ubMapStartPointY != MAP_HEIGHT)) {
		UWORD uwX = getMapCrossX(g_ubMapStartPointX);
		UWORD uwY = getMapCrossY(g_ubMapStartPointX, g_ubMapStartPointY);

		drawCube(
			uwX + g_pCubeCrossSideAdjust[g_ubMapStartPointCrossSide][g_ubMapStartPointCrossSide][0],
			uwY + g_pCubeCrossSideAdjust[g_ubMapStartPointCrossSide][g_ubMapStartPointCrossSide][1]
		);

		if (g_ubMapStartPointCrossSide & 1) {
			drawCross(uwX, uwY, g_pMapData[g_ubMapStartPointX][g_ubMapStartPointY]);
		}
	}
}

void undrawMapStartPoint() {
	if ((g_ubMapStartPointX != MAP_WIDTH) && (g_ubMapStartPointY != MAP_HEIGHT)) {
		UWORD uwX = getMapCrossX(g_ubMapStartPointX);
		UWORD uwY = getMapCrossY(g_ubMapStartPointX, g_ubMapStartPointY);

		undrawCross(uwX, uwY);
		drawCross(uwX, uwY, g_pMapData[g_ubMapStartPointX][g_ubMapStartPointY]);
	}
}

void drawMapFinishPoint() {
	if ((g_ubMapFinishPointX != MAP_WIDTH) && (g_ubMapFinishPointY != MAP_HEIGHT) && g_pMapData[g_ubMapFinishPointX][g_ubMapFinishPointY] && !(g_ubMapFinishPointCrossSide & 1)) {
		drawDestinationPoint(
			getMapCrossX(g_ubMapFinishPointX),
			getMapCrossY(g_ubMapFinishPointX, g_ubMapFinishPointY),
			g_ubMapFinishPointCrossSide
		);
	}
}

void undrawMapFinishPoint() {
	if ((g_ubMapFinishPointX != MAP_WIDTH) && (g_ubMapFinishPointY != MAP_HEIGHT) && !(g_ubMapFinishPointCrossSide & 1)) {
		undrawDestinationPoint(
			getMapCrossX(g_ubMapFinishPointX),
			getMapCrossY(g_ubMapFinishPointX, g_ubMapFinishPointY)
		);

		if (g_pMapData[g_ubMapFinishPointX][g_ubMapFinishPointY]) {
			drawMapCross(g_ubMapFinishPointX, g_ubMapFinishPointY);
		}
	}
}

UBYTE saveMapToFile(char *szFilePath) {
	logBlockBegin("saveMapToFile(szFilePath: %s)", szFilePath);

	systemUse();

	tFile *pFile = fileOpen(szFilePath, "wb");
	if (!pFile) {
		systemUnuse();

		logWrite("ERROR: can't open file!\n");
		logBlockEnd("saveMapToFile()");

		return 0;
	}

	UBYTE ubMapWidth = MAP_WIDTH;
	UBYTE ubMapHeight = MAP_HEIGHT;
	fileWrite(pFile, &ubMapWidth, sizeof(ubMapWidth));
	fileWrite(pFile, &ubMapHeight, sizeof(ubMapHeight));
	fileWrite(pFile, &g_ubMapStartPointX, sizeof(g_ubMapStartPointX));
	fileWrite(pFile, &g_ubMapStartPointY, sizeof(g_ubMapStartPointY));
	fileWrite(pFile, &g_ubMapStartPointCrossSide, sizeof(g_ubMapStartPointCrossSide));
	fileWrite(pFile, &g_ubMapFinishPointX, sizeof(g_ubMapFinishPointX));
	fileWrite(pFile, &g_ubMapFinishPointY, sizeof(g_ubMapFinishPointY));
	fileWrite(pFile, &g_ubMapFinishPointCrossSide, sizeof(g_ubMapFinishPointCrossSide));

	fileWrite(pFile, g_pMapData, CROSS_BYTE_SIZE * MAP_WIDTH * MAP_HEIGHT);

	fileClose(pFile);

	systemUnuse();

	logBlockEnd("saveMapToFile()");

	return 1;
}

UBYTE loadMapFromFile(char *szFilePath) {
	logBlockBegin("loadMapFromFile(szFilePath: %s)", szFilePath);

	systemUse();

	tFile *pFile = fileOpen(szFilePath, "rb");
	if (!pFile) {
		systemUnuse();

		logWrite("ERROR: can't open file!\n");
		logBlockEnd("loadMapFromFile()");

		return 0;
	}

	UBYTE ubMapWidth;
	UBYTE ubMapHeight;
	fileRead(pFile, &ubMapWidth, sizeof(ubMapWidth));
	fileRead(pFile, &ubMapHeight, sizeof(ubMapHeight));

	if ((ubMapWidth != MAP_WIDTH) || (ubMapHeight != MAP_HEIGHT)) {
		systemUnuse();

		logWrite("ERROR: Map dimensions mismatch! Map: %ux%u Engine: %ux%u\n", ubMapWidth, ubMapHeight, MAP_WIDTH, MAP_HEIGHT);
		logBlockEnd("loadMapFromFile()");

		return 0;
	}

	fileRead(pFile, &g_ubMapStartPointX, sizeof(g_ubMapStartPointX));
	fileRead(pFile, &g_ubMapStartPointY, sizeof(g_ubMapStartPointY));
	fileRead(pFile, &g_ubMapStartPointCrossSide, sizeof(g_ubMapStartPointCrossSide));
	fileRead(pFile, &g_ubMapFinishPointX, sizeof(g_ubMapFinishPointX));
	fileRead(pFile, &g_ubMapFinishPointY, sizeof(g_ubMapFinishPointY));
	fileRead(pFile, &g_ubMapFinishPointCrossSide, sizeof(g_ubMapFinishPointCrossSide));

	fileRead(pFile, g_pMapData, CROSS_BYTE_SIZE * MAP_WIDTH * MAP_HEIGHT);

	fileClose(pFile);

	systemUnuse();

	logBlockEnd("loadMapFromFile()");

	return 1;
}
