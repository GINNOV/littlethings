#ifndef GUARD_OF_GAMESTATES_GAME_BUILDING_H
#define GUARD_OF_GAMESTATES_GAME_BUILDING_H

#include "gamestates/game/turret.h"

#define BUILDING_IDX_INVALID 0

#define BUILDING_TYPE_WALL   0
#define BUILDING_TYPE_AMMO   1
#define BUILDING_TYPE_FUEL   2
#define BUILDING_TYPE_FLAG   3
#define BUILDING_TYPE_TURRET 4

#define BUILDING_DAMAGED   1
#define BUILDING_DESTROYED 0

#define BUILDING_MAX_COUNT 256

typedef struct {
	UBYTE ubType;
	UBYTE ubHp;
	UWORD uwTurretIdx;
} tBuilding;

typedef struct {
	tBuilding pBuildings[BUILDING_MAX_COUNT];
	UBYTE ubLastIdx;
} tBuildingManager;

void buildingManagerReset(void);

UBYTE buildingAdd(UBYTE ubX, UBYTE ubY, UBYTE ubType, UBYTE ubTeam);

UBYTE buildingDamage(UBYTE ubIdx, UBYTE ubDamage);

tBuilding *buildingGet(UBYTE ubIdx);

#endif // GUARD_OF_GAMESTATES_GAME_BUILDING_H
