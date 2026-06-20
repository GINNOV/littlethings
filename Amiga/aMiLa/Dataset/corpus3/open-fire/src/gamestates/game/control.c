#include "gamestates/game/control.h"
#include <ace/macros.h>
#include <ace/managers/blit.h>
#include "map.h"
#include "gamestates/game/turret.h"
#include "gamestates/game/game.h"
#include "gamestates/game/console.h"

#define CONTROL_POINT_LIFE 250 /* 15s */
#define CONTROL_POINT_LIFE_RED   0
#define CONTROL_POINT_LIFE_NEUTRAL (CONTROL_POINT_LIFE)
#define CONTROL_POINT_LIFE_BLUE   (CONTROL_POINT_LIFE*2)
#define CONTROL_TAKEOVER_TILE_DISTANCE 2

tControlPoint *g_pControlPoints;
static UBYTE s_ubControlPointCount;
static UBYTE s_ubControlPointMaxCount;
static UWORD s_uwFrameCounter;
static UBYTE s_ubAllocSpawnCount;
static UBYTE s_ubAllocTurretCount;

void controlManagerCreate(UBYTE ubPointCount) {
	logBlockBegin(
		"controlManagerCreate(ubPointCount: %"PRI_FUBYTE")", ubPointCount
	);
	s_ubControlPointMaxCount = ubPointCount;
	g_pControlPoints = memAllocFastClear(sizeof(tControlPoint) * ubPointCount);
	s_ubControlPointCount = 0;
	s_uwFrameCounter = 0;
	logBlockEnd("controlManagerCreate()");
}

void controlManagerDestroy(void) {
	logBlockBegin("controlManagerDestroy()");
	for(FUBYTE i = 0; i < s_ubControlPointCount; ++i) {
		tControlPoint *pPoint = &g_pControlPoints[i];
		if(pPoint->fubSpawnCount) {
			memFree(pPoint->pSpawns, pPoint->fubSpawnCount * sizeof(FUBYTE));
		}
		if(pPoint->fubTurretCount) {
			memFree(pPoint->pTurrets, pPoint->fubTurretCount * sizeof(UWORD));
		}
	}
	memFree(g_pControlPoints, sizeof(tControlPoint) * s_ubControlPointMaxCount);
	logBlockEnd("controlManagerDestroy()");
}

static UBYTE ** controlPolygonMaskCreate(
	tControlPoint *pPoint, FUBYTE fubPolyPtCnt, tUbCoordYX *pPolyPts,
	FUBYTE *pX1, FUBYTE *pY1, FUBYTE *pX2, FUBYTE *pY2
) {
	logBlockBegin(
		"controlPolygonMaskCreate(pPoint: %p, fubPolyPtCnt: %"PRI_FUBYTE", "
		"pPolyPts: %p, pX1: %p, pY1: %p, pX2: %p, pY2: %p)",
		pPoint, fubPolyPtCnt, pPolyPts, pX1, pY1, pX2, pY2
	);
	UBYTE **pMask;
	pMask = memAllocFast(g_sMap.fubWidth * sizeof(UBYTE*));
	for(FUBYTE x = 0; x != g_sMap.fubWidth; ++x)
		pMask[x] = memAllocFastClear(sizeof(UBYTE) * g_sMap.fubHeight);

	*pX1 = 0xFF; *pY1 = 0xFF; *pX2 = 0; *pY2 = 0;
	for(FUBYTE i = 1; i < fubPolyPtCnt; ++i) {
		FUBYTE x1 = pPolyPts[i-1].sUbCoord.ubX;
		FUBYTE y1 = pPolyPts[i-1].sUbCoord.ubY;
		FUBYTE x2 = pPolyPts[i].sUbCoord.ubX;
		FUBYTE y2 = pPolyPts[i].sUbCoord.ubY;

		FUBYTE fubStartX = MIN(x1, x2);
		FUBYTE fubEndX = MAX(x1, x2);

		// Only horizontal lines
		// TODO: remove this restriction
		if(y1 == y2) {
			// Plot on mask
			for(FUBYTE fubLineX = fubStartX; fubLineX <= fubEndX; ++fubLineX)
				pMask[fubLineX][y1] = 1;
		}

		// Polygon bounds
		*pX1 = MIN(*pX1, fubStartX);
		*pX2 = MAX(*pX2, fubEndX);
		*pY1 = MIN(*pY1, y1);
		*pY2 = MAX(*pY2, y1);
	}
	logWrite(
		"Bounds: %"PRI_FUBYTE",%"PRI_FUBYTE" ; %"PRI_FUBYTE",%"PRI_FUBYTE"\n",
		*pX1, *pY1, *pX2, *pY2
	);
	logBlockEnd("controlPolygonMaskCreate");
	return pMask;
}

static void controlPolygonMaskDestroy(UBYTE **pMask) {
	for(FUBYTE x = 0; x != g_sMap.fubWidth; ++x) {
		memFree(pMask[x], sizeof(UBYTE) * g_sMap.fubHeight);
	}
	memFree(pMask, g_sMap.fubWidth * sizeof(UBYTE*));
}

static void increaseSpawnCount(
	UNUSED_ARG tControlPoint *pPoint, UNUSED_ARG FUBYTE fubSpawnIdx
) {
	++s_ubAllocSpawnCount;
}

static void increaseTurretCount(
	UNUSED_ARG tControlPoint *pPoint, UNUSED_ARG FUBYTE fubTurretIdx
) {
	++s_ubAllocTurretCount;
}

static void addSpawn(tControlPoint *pPoint, FUBYTE fubSpawnIdx) {
	pPoint->pSpawns[pPoint->fubSpawnCount++] = fubSpawnIdx;
}

static void addTurret(tControlPoint *pPoint, FUBYTE fubTurretIdx) {
	pPoint->pTurrets[pPoint->fubTurretCount++] = fubTurretIdx;
}

static void controlMaskIterateSpawns(
	UBYTE **pMask, tControlPoint *pPoint,
	FUBYTE fubX1, FUBYTE fubY1, FUBYTE fubX2, FUBYTE fubY2,
	void (*onFound)(tControlPoint *pPoint, FUBYTE fubSpawnIdx)
) {
	for(FUBYTE i = 0; i < g_ubSpawnCount; ++i) {
		FUBYTE fubX = g_pSpawns[i].ubTileX;
		FUBYTE fubY = g_pSpawns[i].ubTileY;
		if(fubX < fubX1 || fubX > fubX2)
			continue;
		FUBYTE isInPoly = 0;
		for(FUBYTE y = fubY1; y <= fubY2; ++y) {
			FUBYTE isEdgeProcessed = 0;
			if(!isInPoly && pMask[fubX][y]) {
				isInPoly = 1;
				isEdgeProcessed = 1;
			}

			if(y == fubY && isInPoly) {
				onFound(pPoint, i);
				break;
			}

			if(isInPoly && pMask[fubX][y] && !isEdgeProcessed) {
				isInPoly = 0;
			}
		}
	}
}

static void controlMaskIterateTurrets(
	UBYTE **pMask, tControlPoint *pPoint,
	FUBYTE fubX1, FUBYTE fubY1, FUBYTE fubX2, FUBYTE fubY2,
	void (*onFound)(tControlPoint *pPoint, FUBYTE fubTurretIdx)
) {
	for(FUBYTE i = 0; i < g_uwTurretCount; ++i) {
		FUBYTE fubX = g_pTurrets[i].uwCenterX >> MAP_TILE_SIZE;
		FUBYTE fubY = g_pTurrets[i].uwCenterY >> MAP_TILE_SIZE;
		if(fubX < fubX1 || fubX > fubX2)
			continue;
		FUBYTE isInPoly = 0;
		for(FUBYTE y = fubY1; y <= fubY2; ++y) {
			FUBYTE isProcessed = 0;
			if(!isInPoly && pMask[fubX][y]) {
				isInPoly = 1;
				isProcessed = 1;
			}

			if(y == fubY && isInPoly) {
				onFound(pPoint, i);
				break;
			}

			if(isInPoly && pMask[fubX][y] && !isProcessed) {
				isInPoly = 0;
			}
		}
	}
}

void controlAddPoint(
	char *szName, FUBYTE fubCaptureTileX, FUBYTE fubCaptureTileY,
	FUBYTE fubPolyPtCnt, tUbCoordYX *pPolyPts
) {
	logBlockBegin(
		"controlAddPoint(szName: %s, fubCaptureTileX: %"PRI_FUBYTE", "
		"fubCaptureTileY: %"PRI_FUBYTE", fubPolyPtCnt: %"PRI_FUBYTE", pPolyPts: %p)",
		szName, fubCaptureTileX, fubCaptureTileY, fubPolyPtCnt, pPolyPts
	);
	if(s_ubControlPointCount >= s_ubControlPointMaxCount) {
		logWrite("ERR: No more room for control point %s\n", szName);
		return;
	}
	tControlPoint *pPoint = &g_pControlPoints[s_ubControlPointCount];
	memcpy(pPoint->szName, szName, MIN(CONTROL_NAME_MAX, strlen(szName)));
	pPoint->fubTileX = fubCaptureTileX;
	pPoint->fubTileY = fubCaptureTileY;

	// Plot polygon on mask
	FUBYTE fubPolyX1, fubPolyY1, fubPolyX2, fubPolyY2;
	UBYTE **pMask = controlPolygonMaskCreate(
		pPoint, fubPolyPtCnt, pPolyPts, &fubPolyX1, &fubPolyY1, &fubPolyX2, &fubPolyY2
	);

	// Count & add spawns
	s_ubAllocSpawnCount = 0;
	pPoint->fubSpawnCount = 0;
	controlMaskIterateSpawns(pMask, pPoint, fubPolyX1, fubPolyY1, fubPolyX2, fubPolyY2, increaseSpawnCount);
	if(s_ubAllocSpawnCount) {
		pPoint->pSpawns = memAllocFast(s_ubAllocSpawnCount * sizeof(FUBYTE));
		controlMaskIterateSpawns(pMask, pPoint, fubPolyX1, fubPolyY1, fubPolyX2, fubPolyY2, addSpawn);
	}

	// Count & add turrets
	s_ubAllocTurretCount = 0;
	pPoint->fubTurretCount = 0;
	controlMaskIterateTurrets(pMask, pPoint, fubPolyX1, fubPolyY1, fubPolyX2, fubPolyY2, increaseTurretCount);
	if(s_ubAllocTurretCount) {
		pPoint->pTurrets = memAllocFast(s_ubAllocTurretCount * sizeof(UWORD));
		controlMaskIterateTurrets(pMask, pPoint, fubPolyX1, fubPolyY1, fubPolyX2, fubPolyY2, addTurret);
	}

	// Determine team
	if(pPoint->fubSpawnCount)
		pPoint->fubTeam = g_pSpawns[pPoint->pSpawns[0]].ubTeam;
	else if(pPoint->fubTurretCount)
		pPoint->fubTeam = g_pTurrets[pPoint->pTurrets[0]].ubTeam;
	else
		pPoint->fubTeam = TEAM_NONE;

	if(pPoint->fubTeam == TEAM_BLUE)
		pPoint->fuwLife = CONTROL_POINT_LIFE_BLUE;
	else if(pPoint->fubTeam == TEAM_RED)
		pPoint->fuwLife = CONTROL_POINT_LIFE_RED;
	else
		pPoint->fuwLife = CONTROL_POINT_LIFE_NEUTRAL;

	pPoint->fubDestTeam = pPoint->fubTeam;
	pPoint->fubBrownCount = 0;
	pPoint->fubGreenCount = 0;

	// Free polygon mask
	controlPolygonMaskDestroy(pMask);
	++s_ubControlPointCount;
	logWrite(
		"Spawns: %"PRI_FUBYTE", turrets: %"PRI_FUBYTE"\n",
		pPoint->fubSpawnCount, pPoint->fubTurretCount
	);
	logBlockEnd("controlAddPoint()");
}

static void controlCapturePoint(tControlPoint *pPoint, FUBYTE fubTeam) {
	if(pPoint->fubTeam == fubTeam)
		return;
	char szLog[50];
	FUBYTE fubColor;
	if(fubTeam == TEAM_BLUE) {
		sprintf(szLog, "Control point %s is now BLUE", pPoint->szName);
		fubColor = CONSOLE_COLOR_BLUE;
	}
	else if(fubTeam == TEAM_RED) {
		sprintf(szLog, "Control point %s is now RED", pPoint->szName);
		fubColor = CONSOLE_COLOR_RED;
	}
	else {
		sprintf(szLog, "Control point %s is now NEUTRAL", pPoint->szName);
		fubColor = CONSOLE_COLOR_GENERAL;
	}
	consoleWrite(szLog, fubColor);

	pPoint->fubTeam = fubTeam;
	for(FUBYTE i = 0; i < pPoint->fubSpawnCount; ++i) {
		spawnCapture(pPoint->pSpawns[i], fubTeam);
	}
	for(FUBYTE i = 0; i < pPoint->fubTurretCount; ++i) {
		turretCapture(pPoint->pTurrets[i], fubTeam);
	}
}

// 50 spawns per team
// ticket drop each 5s, so 250s of game (4min)
// max drop speed: each
// 5 control points in total
// starting: 2xR, 2xB, 1xN - no loss
void controlSim(void) {
	FUBYTE fubControlledByRed = 0;
	FUBYTE fubControlledByBlue = 0;
	for(FUBYTE i = 0; i < s_ubControlPointCount; ++i) {
		tControlPoint *pPoint = &g_pControlPoints[i];
		FBYTE fbCaptureDir;

		// Determine destination team
		if(pPoint->fubBrownCount == pPoint->fubGreenCount) {
			if(
				!pPoint->fubBrownCount && pPoint->fubTeam == TEAM_NONE &&
				pPoint->fuwLife != CONTROL_POINT_LIFE_NEUTRAL
			) {
				// Abandoned neutral point
				fbCaptureDir = SGN(CONTROL_POINT_LIFE_NEUTRAL - pPoint->fuwLife);
			}
			else {
				fbCaptureDir = 0;
			}
		}
		else {
			if(pPoint->fubBrownCount > pPoint->fubGreenCount) {
				// red taking over blue
				fbCaptureDir = -1;
				if(pPoint->fuwLife > CONTROL_POINT_LIFE_NEUTRAL) {
					pPoint->fubDestTeam = TEAM_NONE;
				}
				else {
					pPoint->fubDestTeam = TEAM_RED;
				}
			}
			else {
				// blue taking over red
				fbCaptureDir = 1;
				if(pPoint->fuwLife < CONTROL_POINT_LIFE_NEUTRAL) {
					pPoint->fubDestTeam = TEAM_NONE;
				}
				else {
					pPoint->fubDestTeam = TEAM_BLUE;
				}
			}
		}
		// Process takeover
		pPoint->fuwLife = CLAMP(
			pPoint->fuwLife+fbCaptureDir,
			CONTROL_POINT_LIFE_RED,	CONTROL_POINT_LIFE_BLUE
		);

		if(pPoint->fuwLife == CONTROL_POINT_LIFE_RED) {
			controlCapturePoint(pPoint, TEAM_RED);
		}
		else if(pPoint->fuwLife == CONTROL_POINT_LIFE_BLUE) {
			controlCapturePoint(pPoint, TEAM_BLUE);
		}
		else if(pPoint->fuwLife == CONTROL_POINT_LIFE_NEUTRAL) {
			controlCapturePoint(pPoint, TEAM_NONE);
		}

		// Calc domination ratio for bleed
		if(pPoint->fubTeam == TEAM_BLUE) {
			++fubControlledByBlue;
		}
		else if(pPoint->fubTeam == TEAM_RED) {
			++fubControlledByRed;
		}

		// Reset for next counting during player process
		pPoint->fubBrownCount = 0;
		pPoint->fubGreenCount = 0;
	}

	// Do some bleeding
	if(s_uwFrameCounter >= 50*5) {
		s_uwFrameCounter -= 50*5;
		FUBYTE fubDelta = (ABS(fubControlledByRed - fubControlledByBlue)+1) >> 1;
		if(fubControlledByRed > fubControlledByBlue) {
			g_pTeams[TEAM_BLUE].uwTicketsLeft = MAX(0, g_pTeams[TEAM_BLUE].uwTicketsLeft - fubDelta);
		}
		else if(fubControlledByRed < fubControlledByBlue) {
			g_pTeams[TEAM_RED].uwTicketsLeft = MAX(0, g_pTeams[TEAM_RED].uwTicketsLeft - fubDelta);
		}
	}
	else {
		++s_uwFrameCounter;
	}
}

void controlRedrawPoints(void) {
	for(FUBYTE i = 0; i < s_ubControlPointCount; ++i) {
		tControlPoint *pPoint = &g_pControlPoints[i];
		// Omit drawing if not visible
		if(!simpleBufferIsRectVisible(
			g_pWorldMainBfr,
			pPoint->fubTileX << MAP_TILE_SIZE, pPoint->fubTileY << MAP_TILE_SIZE,
			MAP_FULL_TILE, MAP_FULL_TILE
		)) {
			continue;
		}
		// TODO could be drawn only on fubTileLife change, but watch out for dblbuf
		UWORD uwX = pPoint->fubTileX << MAP_TILE_SIZE;
		UWORD uwY = pPoint->fubTileY << MAP_TILE_SIZE;
		FUWORD fuwTileProgress = ABS(CONTROL_POINT_LIFE_NEUTRAL - pPoint->fuwLife);
		if(pPoint->fubDestTeam == TEAM_NONE) {
			fuwTileProgress = CONTROL_POINT_LIFE - fuwTileProgress;
		}
		fuwTileProgress = (MAP_FULL_TILE * fuwTileProgress) / CONTROL_POINT_LIFE;
		FUWORD fuwAntiProgress = MAP_FULL_TILE - fuwTileProgress;

		if(fuwTileProgress != MAP_FULL_TILE) {
			blitCopyAligned(
				g_pMapTileset, 0,
				(MAP_TILE_CAPTURE_BLUE + pPoint->fubTeam) << MAP_TILE_SIZE,
				g_pWorldMainBfr->pBack, uwX, uwY,
				MAP_FULL_TILE, fuwAntiProgress
			);
		}
		if(fuwTileProgress) {
			blitCopyAligned(
				g_pMapTileset, 0,
				((MAP_TILE_CAPTURE_BLUE + pPoint->fubDestTeam) << MAP_TILE_SIZE) + fuwAntiProgress,
				g_pWorldMainBfr->pBack, uwX, uwY + fuwAntiProgress,
				MAP_FULL_TILE, fuwTileProgress
			);
		}
	}
}

tControlPoint *controlPointGetAt(FUBYTE fubTileX, FUBYTE fubTileY) {
	FUBYTE i; tControlPoint *pPoint;
	for(i = s_ubControlPointCount, pPoint = &g_pControlPoints[0]; i--; ++pPoint) {
		if(pPoint->fubTileX == fubTileX &&	pPoint->fubTileY == fubTileY) {
			return pPoint;
		}
	}
	return 0;
}

void controlIncreaseCounters(UWORD uwTileX, UWORD uwTileY, UBYTE ubTeam) {
	// Increase counters for control point domination
	for(FUBYTE i = s_ubControlPointCount; i--;) {
		// Calc distance
		// Increase vehicle count near control point for given team
		if(
			ABS(uwTileX - g_pControlPoints[i].fubTileX) <= CONTROL_TAKEOVER_TILE_DISTANCE &&
			ABS(uwTileY - g_pControlPoints[i].fubTileY) <= CONTROL_TAKEOVER_TILE_DISTANCE
		) {
			if(ubTeam == TEAM_BLUE) {
				++g_pControlPoints[i].fubGreenCount;
			}
			else {
				++g_pControlPoints[i].fubBrownCount;
			}
			return; // Player can't be in two bases at the same time
		}
	}
}
