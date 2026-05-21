/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _TILE_H_
#define _TILE_H_

#include <ace/types.h>
#include "vehicle.h"
#include "base.h"
#include "game.h"

#define TILE_SHIFT 5
#define TILE_SIZE (1 << TILE_SHIFT)

#define TILE_MINE_DEPTH (32768 / TILE_SIZE)

#define TILE_ROW_BASE_DIRT 8
#define TILE_ROW_CHALLENGE_CHECKPOINT_1 (TILE_ROW_BASE_DIRT + 15)
#define TILE_ROW_CHALLENGE_CHECKPOINT_2 (TILE_ROW_CHALLENGE_CHECKPOINT_1 + 15)
#define TILE_ROW_CHALLENGE_CHECKPOINT_3 (TILE_ROW_CHALLENGE_CHECKPOINT_2 + 20)
#define TILE_ROW_CHALLENGE_FINISH (TILE_ROW_CHALLENGE_CHECKPOINT_3 + 15)

typedef enum _tTile {
	TILE_BASE_BG_FIRST = 0, TILE_BASE_BG_LAST = 32,
	TILE_BASE_SHAFT,
	TILE_BASE_GROUND_1, TILE_BASE_GROUND_9 = TILE_BASE_GROUND_1 + 8,
	TILE_CAVE_BG_1,
	TILE_CAVE_BG_STONE_1, TILE_CAVE_BG_STONE_2, TILE_CAVE_BG_STONE_3,
	TILE_CAVE_BG_STONE_4, TILE_CAVE_BG_STONE_5, TILE_CAVE_BG_STONE_6,
	TILE_DIRT_1, TILE_DIRT_2,
	TILE_SILVER_1, TILE_SILVER_2, TILE_SILVER_3,
	TILE_GOLD_1, TILE_GOLD_2, TILE_GOLD_3,
	TILE_COAL_1, TILE_COAL_2, TILE_COAL_3,
	TILE_MAGMA_1, TILE_MAGMA_2,
	TILE_PRISONER_1, TILE_PRISONER_8 = TILE_PRISONER_1 + 7, TILE_CAPSULE,
	TILE_CHECKPOINT_1 = TILE_PRISONER_1, TILE_CHECKPOINT_10 = TILE_CHECKPOINT_1 + 9,
	TILE_STONE_1, TILE_STONE_2, TILE_STONE_3, TILE_STONE_4,
	TILE_EMERALD_1, TILE_EMERALD_2, TILE_EMERALD_3,
	TILE_RUBY_1, TILE_RUBY_2, TILE_RUBY_3,
	TILE_MOONSTONE_1, TILE_MOONSTONE_2, TILE_MOONSTONE_3,
	TILE_BONE_HEAD, TILE_BONE_1,
	TILE_CRATE_1,
	TILE_GATE_1, TILE_GATE_2,
	TILE_COUNT
} tTile;
// TODO sapphire, topaz

typedef struct _tTileDef {
	UBYTE ubMineral;
	UBYTE ubSlots;
} tTileDef;

UBYTE tileIsExcavated(UWORD uwX, UWORD uwY);

UBYTE tileIsSolid(UWORD uwX, UWORD uwY);

UBYTE tileIsDrillable(UWORD uwX, UWORD uwY);

UBYTE tileIsHardToDrill(UWORD uwX, UWORD uwY);

void tileReset(UBYTE isCoalOnly, tGameMode eGameMode);

void tileSave(tFile *pFile);

UBYTE tileLoad(tFile *pFile);

void tileExcavate(UWORD uwX, UWORD uwY);

void tileReplaceBaseWithVariant(tBaseId eBase, tBaseId eNewVariant);

tTile tileGetPrisoner(void);

void tileSetPrisoner(tTile eNewTile);

extern const tTileDef g_pTileDefs[TILE_COUNT];
extern const tTile g_pMineralToFirstTile[MINERAL_TYPE_COUNT];

#endif // _TILE_H_
