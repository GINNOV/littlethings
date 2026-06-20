#ifndef GUARD_GAMESTATE_ARCADE_TILE_H
#define GUARD_GAMESTATE_ARCADE_TILE_H

#include "config.h"

#include "ACE:utils/memory.h"
#include "ACE:managers/log.h"
#include "ACE:managers/rand.h"

#include "gamestates/arcade/arcade.h"
#include "gamestates/arcade/logic.h"

/* Types */
#define TILE_TYPES 25
#define TILE_VARIANTS (TILE_TYPES * 4)

typedef struct {
	UBYTE ubCount;
	UBYTE pLogicData[9];
} tTile;

typedef struct {
	UBYTE *pTileIdx;
	UWORD uwPos;
	UWORD uwLength;
} tTileList;

/* Globals */
extern tTile g_pTileDefs[TILE_VARIANTS];
extern tTileList g_sTileList;

/* Functions */
void tileStackCreate(void);

void tileStackDestroy(void);

UBYTE tileIsPlaceable(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN tTile *pTile
);

void tilePlace(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN tTile *pTile
);

void tileRotate(void);

#endif