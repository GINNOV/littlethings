#include "gamestates/game/building.h"

#include <ace/managers/log.h>

#define BUILDING_IDX_FIRST 1
#define BUILDING_IDX_LAST  255

// Building HPs
#define BUILDING_HP_WALL       100
#define BUILDING_HP_AMMO       30
#define BUILDING_HP_FUEL       30
#define BUILDING_HP_FLAG       50
#define BUILDING_HP_TURRET     100
#define BUILDING_HP_TURRET_MIN 50

static tBuildingManager s_sBuildingManager;

static const UBYTE s_pBuildingHps[5] = {
	BUILDING_HP_WALL,
	BUILDING_HP_AMMO,
	BUILDING_HP_FUEL,
	BUILDING_HP_FLAG,
	BUILDING_HP_TURRET
};

void buildingManagerReset(void) {
	UBYTE ubIdx;
	s_sBuildingManager.ubLastIdx = BUILDING_IDX_LAST;

	for(ubIdx = BUILDING_IDX_FIRST; ubIdx != BUILDING_IDX_LAST; ++ubIdx) {
		s_sBuildingManager.pBuildings[ubIdx].ubHp = 0;
	}
}

tBuilding *buildingGet(UBYTE ubIdx) {
	return &s_sBuildingManager.pBuildings[ubIdx];
}

UBYTE buildingAdd(UBYTE ubX, UBYTE ubY, UBYTE ubType, UBYTE ubTeam) {
	UBYTE ubIdx;

	logBlockBegin(
		"buildingAdd(ubX: %hhu, ubY: %hhu, ubType: %hhu, ubTeam: %hhu)",
		ubX, ubY, ubType, ubTeam
	);
	if(s_sBuildingManager.ubLastIdx == BUILDING_IDX_LAST)
		ubIdx = BUILDING_IDX_FIRST;
	else
		ubIdx = s_sBuildingManager.ubLastIdx+1;
	while(ubIdx != s_sBuildingManager.ubLastIdx) {
		if(!s_sBuildingManager.pBuildings[ubIdx].ubHp) {
			// Setup building
			s_sBuildingManager.pBuildings[ubIdx].ubHp = s_pBuildingHps[ubType];
			s_sBuildingManager.pBuildings[ubIdx].ubType = ubType;
			if(ubType == BUILDING_TYPE_TURRET)
				s_sBuildingManager.pBuildings[ubIdx].uwTurretIdx = turretAdd(
					ubX, ubY,	ubTeam
				);
			else
				s_sBuildingManager.pBuildings[ubIdx].uwTurretIdx = TURRET_INVALID;
			s_sBuildingManager.ubLastIdx = ubIdx;
			logBlockEnd("buildingAdd()");
			return ubIdx;
		}

		if(ubIdx == BUILDING_IDX_LAST)
			ubIdx = BUILDING_IDX_FIRST; // Will be incremented by loop
		else
			++ubIdx;
	}
	logWrite("No free space for buildings!\n");
	logBlockEnd("buildingAdd()");

	return BUILDING_IDX_INVALID;
}

UBYTE buildingDamage(UBYTE ubIdx, UBYTE ubDamage) {
	tBuilding *pBuilding = &s_sBuildingManager.pBuildings[ubIdx];
	if(pBuilding->ubHp <= ubDamage) {
		pBuilding->ubHp = 0;
		if(pBuilding->uwTurretIdx != TURRET_INVALID) {
			turretDestroy(pBuilding->uwTurretIdx);
			pBuilding->uwTurretIdx = TURRET_INVALID; // TODO: not needed?
		}
		// TODO spawn flag
		return BUILDING_DESTROYED;
	}
	pBuilding->ubHp -= ubDamage;
	if(pBuilding->uwTurretIdx != TURRET_INVALID && pBuilding->ubHp <= BUILDING_HP_TURRET_MIN) {
		turretDestroy(pBuilding->uwTurretIdx);
		pBuilding->uwTurretIdx = TURRET_INVALID;
	}
	return BUILDING_DAMAGED;
}
