#ifndef GUARD_GAMESTATE_ARCADE_LOGIC_H
#define GUARD_GAMESTATE_ARCADE_LOGIC_H

#include <clib/exec_protos.h> // Amiga typedefs

#include "config.h"
#include "gamestates/arcade/tile.h"

/* Types */
#define LOGIC_VOID 0
#define LOGIC_GRASS 1
#define LOGIC_VILLAGE 2
#define LOGIC_ROAD 3
#define LOGIC_BONUS 4
#define LOGIC_SWAMP 5

#define LOGIC_TILE_DIRS 9

typedef struct {
	tCoord sTileCoord;
	UBYTE ubLogicDataIdx;
} tLogicListItem;

typedef struct {
	tLogicListItem *pItems;
	UWORD uwPos;
	UWORD uwLength;
	UBYTE ubClosed;
	UBYTE ubType;
	UBYTE ubPointAdd;
	UBYTE ubPointMult;
	UBYTE pVisitedLogicIdx[LOGIC_TILE_DIRS];
} tLogicList;

/* Globals */
extern tLogicList g_sLogicList;

/* Functions */
void logicListCreate(void);

void logicListDestroy(void);

void logicCountPoints(void);

void logicSumWalkerResults(void);

void logicAssignPoints(
	IN UBYTE *pPlayerPawnCounts
);

UBYTE logicIsStructureOccupied(
	UWORD uwTileX,
	UWORD uwTileY,
	UBYTE ubLogicDataId
);

void logicListMakeDistinct(void);

void logicWalkMakeStep(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN UBYTE ubLogicDataIdx
);

void logicWalkRoad(
	IN UWORD uwTileX,
	IN UWORD uwTileY, 
	IN UBYTE ubLogicDataIdx
);

void logicWalkVillage(
	IN UWORD uwTileX,
	IN UWORD uwTileY, 
	IN UBYTE ubLogicDataIdx
);

void logicWalkSwamp(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN UBYTE ubLogicDataIdx
);

#endif