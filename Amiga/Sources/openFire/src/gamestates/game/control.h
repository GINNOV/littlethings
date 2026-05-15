#ifndef GUARD_OF_GAMESTATES_GAME_CONTROL_H
#define GUARD_OF_GAMESTATES_GAME_CONTROL_H

#include <ace/types.h>
#include "gamestates/game/player.h"
#include "gamestates/game/team.h"

#define CONTROL_NAME_MAX 20

typedef struct _tControlPoint {
	FUBYTE fubTileX;
	FUBYTE fubTileY;

	FUBYTE fubTurretCount;
	FUBYTE fubSpawnCount;
	FUWORD *pTurrets;
	FUBYTE *pSpawns;
	FUBYTE fubGreenCount; ///< Nearby player count from green team.
	FUBYTE fubBrownCount; ///< Ditto, brown team.
	FUWORD fuwLife;       ///< Capture life
	FUBYTE fubTeam;       ///< Controlling team.
	FUBYTE fubDestTeam;   ///< Conquering team.
	char szName[CONTROL_NAME_MAX];
} tControlPoint;

void controlManagerCreate(UBYTE fubPointCount);

void controlManagerDestroy(void);

/**
 *  This function expects all logic tiles to be initialized - spawns & turrets too.
 */
void controlAddPoint(
	char *szName, FUBYTE fubCaptureTileX, FUBYTE fubCaptureTileY,
	FUBYTE fubPolyPtCnt, tUbCoordYX *pPolyPts
);

void controlSim(void);

void controlRedrawPoints(void);

tControlPoint *controlPointGetAt(FUBYTE fubTileX, FUBYTE fubTileY);

void controlIncreaseCounters(UWORD uwTileX, UWORD uwTileY, UBYTE ubTeam);

extern tControlPoint *g_pControlPoints;

#endif // GUARD_OF_GAMESTATES_GAME_CONTROL_H
