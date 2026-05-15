#ifndef GUARD_OF_GAMESTATES_GAME_SPAWN_H
#define GUARD_OF_GAMESTATES_GAME_SPAWN_H

#include <ace/types.h>

#define SPAWN_BUSY_NOT 0
#define SPAWN_BUSY_SURFACING 1
#define SPAWN_BUSY_BUNKERING 2

#define SPAWN_INVALID 0xFF

typedef struct _tSpawn {
	UBYTE ubTileY;
	UBYTE ubTileX;
	UBYTE ubTeam;
	UBYTE ubBusy;
	UBYTE ubFrame;
	UBYTE ubVehicleType;
} tSpawn;

void spawnManagerCreate(FUBYTE fubMaxCount);

void spawnManagerDestroy(void);

UBYTE spawnAdd(UBYTE ubTileX, UBYTE ubTileY, UBYTE ubTeam);

void spawnCapture(UBYTE ubSpawnIdx, UBYTE ubTeam);

UBYTE spawnGetNearest(UBYTE ubTileX, UBYTE ubTileY, UBYTE ubTeam);

UBYTE spawnGetAt(UBYTE ubTileX, UBYTE ubTileY);

void spawnSetBusy(FUBYTE fubSpawnIdx, FUBYTE fubBusyType, FUBYTE fubVehicleType);

void spawnAnimate(UBYTE ubSpawnIdx);

void spawnSim(void);

UBYTE spawnIsCoveredByAnyPlayer(UBYTE ubSpawnIdx);

extern tSpawn *g_pSpawns;
extern UBYTE g_ubSpawnCount;

#endif // GUARD_OF_GAMESTATES_GAME_SPAWN_H
