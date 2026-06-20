#include "gamestates/game/worldmap.h"
#include <ace/managers/log.h>
#include <ace/managers/blit.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/utils/extview.h>
#include "map.h"
#include "mapjson.h"
#include "gamestates/game/team.h"
#include "gamestates/game/building.h"
#include "gamestates/game/turret.h"
#include "gamestates/game/control.h"

#define BUFFER_FRONT 0
#define BUFFER_BACK 1
#define PENDING_QUEUE_MAX 255

static UBYTE s_pBufferTiles[MAP_MAX_SIZE][MAP_MAX_SIZE] = {0};

static tTileCoord s_pTilesToRedraw[2][PENDING_QUEUE_MAX] = {{{0, 0}}};
static UBYTE s_ubPendingTiles[2];
static UBYTE s_ubBufIdx;

tBitMap *g_pMapTileset;
static tBitMap *s_pBuffers[2];

void worldMapSwapBuffers(void) {
	s_ubBufIdx = !s_ubBufIdx;
}

UBYTE worldMapIsWall(UBYTE ubMapTile) {
	return (
		ubMapTile == MAP_LOGIC_WALL    ||
		ubMapTile == MAP_LOGIC_SENTRY0 ||
		ubMapTile == MAP_LOGIC_SENTRY1 ||
		ubMapTile == MAP_LOGIC_SENTRY2 ||
		0
	);
}

static UBYTE worldMapIsRoadFriend(UBYTE ubMapTile) {
	return (
		ubMapTile == MAP_LOGIC_ROAD     ||
		// ubMapTile == MAP_LOGIC_SPAWN0   ||
		// ubMapTile == MAP_LOGIC_SPAWN1   ||
		// ubMapTile == MAP_LOGIC_SPAWN2   ||
		// ubMapTile == MAP_LOGIC_CAPTURE0 ||
		// ubMapTile == MAP_LOGIC_CAPTURE1 ||
		// ubMapTile == MAP_LOGIC_CAPTURE2 ||
		// ubMapTile == MAP_LOGIC_SPAWN2   ||
		// ubMapTile == MAP_LOGIC_SPAWN2   ||
		// ubMapTile == MAP_LOGIC_GATE1    ||
		// ubMapTile == MAP_LOGIC_GATE2    ||
		// ubMapTile == MAP_LOGIC_FLAG1    ||
		// ubMapTile == MAP_LOGIC_FLAG2    ||
		0
	);
}

static UBYTE worldMapCheckWater(UBYTE ubX, UBYTE ubY) {
	UBYTE ubOut;
	if(ubX && g_sMap.pData[ubX-1][ubY].ubIdx == MAP_LOGIC_WATER) {
		if(ubY && g_sMap.pData[ubX][ubY-1].ubIdx == MAP_LOGIC_WATER)
			ubOut = 1;
		else if(ubY < g_sMap.fubHeight-1 && g_sMap.pData[ubX][ubY+1].ubIdx == MAP_LOGIC_WATER)
			ubOut = 2;
		else
			ubOut = 5 + (ubY & 1);
	}
	else if(ubX < g_sMap.fubWidth-1 && g_sMap.pData[ubX+1][ubY].ubIdx == MAP_LOGIC_WATER) {
		if(ubY && g_sMap.pData[ubX][ubY-1].ubIdx == MAP_LOGIC_WATER)
			ubOut = 3;
		else if(ubY < g_sMap.fubHeight-1 && g_sMap.pData[ubX][ubY+1].ubIdx == MAP_LOGIC_WATER)
			ubOut = 4;
		else
			ubOut = 7 + (ubY & 1);
	}
	else if(ubY && g_sMap.pData[ubX][ubY-1].ubIdx == MAP_LOGIC_WATER)
		ubOut = 9 + (ubX & 1);
	else if(ubY < g_sMap.fubHeight-1 && g_sMap.pData[ubX][ubY+1].ubIdx == MAP_LOGIC_WATER)
		ubOut = 11 + (ubX & 1);
	else
		ubOut = 0;
	return ubOut;
}

static UBYTE worldMapCheckNeighbours(UBYTE ubX, UBYTE ubY, UBYTE (*checkFn)(UBYTE)) {
	UBYTE ubOut;
	const UBYTE ubE = 8;
	const UBYTE ubW = 4;
	const UBYTE ubS = 2;
	const UBYTE ubN = 1;

	ubOut = 0;
	if(ubX && checkFn(g_sMap.pData[ubX+1][ubY].ubIdx))
		ubOut |= ubE;
	if(ubX-1 < g_sMap.fubWidth && checkFn(g_sMap.pData[ubX-1][ubY].ubIdx))
		ubOut |= ubW;
	if(ubY && checkFn(g_sMap.pData[ubX][ubY-1].ubIdx))
		ubOut |= ubN;
	if(ubY-1 < g_sMap.fubHeight && checkFn(g_sMap.pData[ubX][ubY+1].ubIdx))
		ubOut |= ubS;
	return ubOut;
}

static void worldMapDrawTile(UBYTE ubX, UBYTE ubY) {
	blitCopyAligned(
		g_pMapTileset, 0, s_pBufferTiles[ubX][ubY] << MAP_TILE_SIZE,
		s_pBuffers[s_ubBufIdx], ubX << MAP_TILE_SIZE, ubY << MAP_TILE_SIZE,
		MAP_FULL_TILE, MAP_FULL_TILE
	);
}

static void worldMapInitFromLogic(void) {
	logBlockBegin("worldMapInitFromLogic()");
	// 2nd data pass - generate additional logic
	for(UBYTE x = g_sMap.fubWidth; x--;) {
		for(UBYTE y = g_sMap.fubHeight; y--;) {
			UBYTE ubTileIdx = g_sMap.pData[x][y].ubIdx;
			switch(ubTileIdx) {
				case MAP_LOGIC_WATER:
					s_pBufferTiles[x][y] = worldMapTileWater();
					break;
				case MAP_LOGIC_SPAWN0:
					spawnAdd(x, y, TEAM_NONE);
					s_pBufferTiles[x][y] = worldMapTileSpawn(TEAM_NONE, 0);
					break;
				case MAP_LOGIC_SPAWN1:
					spawnAdd(x, y, TEAM_BLUE);
					s_pBufferTiles[x][y] = worldMapTileSpawn(TEAM_BLUE, 0);
					break;
				case MAP_LOGIC_SPAWN2:
					spawnAdd(x, y, TEAM_RED);
					s_pBufferTiles[x][y] = worldMapTileSpawn(TEAM_RED, 0);
					break;
				case MAP_LOGIC_ROAD:
					s_pBufferTiles[x][y] = worldMapTileRoad(x, y);
					break;
				case MAP_LOGIC_WALL_VERTICAL:
					g_sMap.pData[x][y].ubIdx = MAP_LOGIC_WALL;
				case MAP_LOGIC_WALL:
					g_sMap.pData[x][y].ubBuilding = buildingAdd(x, y, BUILDING_TYPE_WALL, TEAM_NONE);
					s_pBufferTiles[x][y] = worldMapTileWall(x, y);
					break;
				case MAP_LOGIC_FLAG1:
				case MAP_LOGIC_FLAG2:
					g_sMap.pData[x][y].ubBuilding = buildingAdd(
						x, y,
						BUILDING_TYPE_FLAG,
						ubTileIdx == MAP_LOGIC_FLAG1 ? TEAM_BLUE : TEAM_RED
					);
					break;
				case MAP_LOGIC_SENTRY0:
				case MAP_LOGIC_SENTRY1:
				case MAP_LOGIC_SENTRY2:
					// Change logic type so that projectiles will threat turret walls
					// in same way as any other
					g_sMap.pData[x][y].ubIdx = MAP_LOGIC_WALL;
					g_sMap.pData[x][y].ubBuilding = buildingAdd(
						x, y,
						BUILDING_TYPE_TURRET,
						ubTileIdx == MAP_LOGIC_SENTRY0? TEAM_NONE
							: ubTileIdx == MAP_LOGIC_SENTRY1? TEAM_BLUE
							:TEAM_RED
					);
					s_pBufferTiles[x][y] = worldMapTileTurret();
					break;
				case MAP_LOGIC_CAPTURE0:
					s_pBufferTiles[x][y] = worldMapTileCapture(TEAM_NONE);
					break;
				case MAP_LOGIC_CAPTURE1:
					s_pBufferTiles[x][y] = worldMapTileCapture(TEAM_BLUE);
					break;
				case MAP_LOGIC_CAPTURE2:
					s_pBufferTiles[x][y] = worldMapTileCapture(TEAM_RED);
					break;
				case MAP_LOGIC_DIRT:
				default:
					s_pBufferTiles[x][y] = worldMapTileDirt(x, y);
			}
			// Draw immediately
			s_ubBufIdx = BUFFER_FRONT;
			worldMapDrawTile(x,y);
			s_ubBufIdx = BUFFER_BACK;
			worldMapDrawTile(x,y);
		}
	}
	logBlockEnd("worldMapInitFromLogic()");
}

void worldMapCreate(tBitMap *pFront, tBitMap *pBack) {
	logBlockBegin("worldMapCreate()");
	s_ubPendingTiles[BUFFER_BACK] = 0;
	s_ubPendingTiles[BUFFER_FRONT] = 0;

	s_pBuffers[BUFFER_FRONT] = pFront;
	s_pBuffers[BUFFER_BACK] = pBack;
	s_ubBufIdx = BUFFER_BACK;

	tJson *pMapJson = jsonCreate(g_sMap.szPath);
	UWORD uwTokPts = jsonGetDom(pMapJson, "controlPoints");
	UWORD uwControlPointCount = pMapJson->pTokens[uwTokPts].size;

	buildingManagerReset();
	controlManagerCreate(uwControlPointCount);
	spawnManagerCreate(g_sMap.fubSpawnCount);
	turretListCreate(g_sMap.fubWidth, g_sMap.fubHeight);
	worldMapInitFromLogic();

	// Read remaining JSON data
	mapJsonReadControlPoints(pMapJson);
	jsonDestroy(pMapJson);

	logBlockEnd("worldMapCreate()");
}

void worldMapDestroy(void) {
	logBlockBegin("worldMapDestroy()");
	controlManagerDestroy();
	spawnManagerDestroy();
	turretListDestroy();
	logBlockEnd("worldMapDestroy()");
}

void worldMapRequestUpdateTile(UBYTE ubTileX, UBYTE ubTileY) {
	// TODO when scrolling trick: omit if not on buffer
	// TODO when scrolling trick: omit if not yet drawn on redraw margin
	++s_ubPendingTiles[BUFFER_BACK];
	s_pTilesToRedraw[BUFFER_BACK][s_ubPendingTiles[BUFFER_BACK]].ubX = ubTileX;
	s_pTilesToRedraw[BUFFER_BACK][s_ubPendingTiles[BUFFER_BACK]].ubY = ubTileY;
	++s_ubPendingTiles[BUFFER_FRONT];
	s_pTilesToRedraw[BUFFER_FRONT][s_ubPendingTiles[BUFFER_FRONT]].ubX = ubTileX;
	s_pTilesToRedraw[BUFFER_FRONT][s_ubPendingTiles[BUFFER_FRONT]].ubY = ubTileY;
}

/**
 * @todo Redraw proper tile type.
 */
void worldMapUpdateTiles(void) {
	if(s_ubPendingTiles[s_ubBufIdx]) {
		UBYTE ubTileX = s_pTilesToRedraw[s_ubBufIdx][s_ubPendingTiles[s_ubBufIdx]].ubX;
		UBYTE ubTileY = s_pTilesToRedraw[s_ubBufIdx][s_ubPendingTiles[s_ubBufIdx]].ubY;
		worldMapDrawTile(ubTileX, ubTileY);
		--s_ubPendingTiles[s_ubBufIdx];
	}
}

void worldMapSetTile(UBYTE ubX, UBYTE ubY, UBYTE ubLogicTileIdx) {
	s_pBufferTiles[ubX][ubY] = ubLogicTileIdx;
	worldMapRequestUpdateTile(ubX, ubY);
}

void worldMapTrySetTile(UBYTE ubX, UBYTE ubY, UBYTE ubLogicTileIdx) {
	if(s_pBufferTiles[ubX][ubY] != ubLogicTileIdx) {
		worldMapSetTile(ubX, ubY, ubLogicTileIdx);
	}
}

UBYTE worldMapTileWater(void) {
	return MAP_TILE_WATER;
}

UBYTE worldMapTileDirt(UBYTE ubX, UBYTE ubY) {
	return MAP_TILE_DIRT + worldMapCheckWater(ubX, ubY);
}

UBYTE worldMapTileRoad(UBYTE ubX, UBYTE ubY) {
	return MAP_TILE_ROAD + worldMapCheckNeighbours(
		ubX, ubY, worldMapIsRoadFriend
	);
}

UBYTE worldMapTileSpawn(UBYTE ubTeam, UBYTE ubIsActive) {
	UBYTE ubTileIdx = MAP_TILE_SPAWN_BLUE + ubTeam;
	if(ubIsActive) {
		ubTileIdx += 3;
	}
	return ubTileIdx;
}

UBYTE worldMapTileWall(UBYTE ubX, UBYTE ubY) {
	return MAP_TILE_WALL + worldMapCheckNeighbours(
		ubX, ubY, worldMapIsWall
	);
}

UBYTE worldMapTileTurret(void) {
	return MAP_TILE_WALL;
}

UBYTE worldMapTileCapture(UBYTE ubTeam) {
	return MAP_TILE_CAPTURE_BLUE + ubTeam;
}
