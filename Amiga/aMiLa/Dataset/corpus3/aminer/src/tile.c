/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "tile.h"
#include <ace/managers/viewport/tilebuffer.h>
#include <ace/managers/rand.h>
#include <comm/comm.h>
#include "game.h"
#include "core.h"
#include "hud.h"
#include "mineral.h"
#include "defs.h"
#include "plan.h"
#include "save.h"
#include "base.h"
#include "msg.h"

#define ROWS_PER_PLAN_MAX 20
// #define TILE_QUEST_DEBUG_PLACEMENT

//----------------------------------------------------------------- PRIVATE VARS

static const UBYTE s_pRowSpawnPattern[] = {5, 3, 7, 1, 4, 6, 8, 2, 9, 10};

static UBYTE s_ubPrisonerX;
static UBYTE s_ubNextRowPatternPos;
static UWORD s_uwPlanFillPatternLength;
static tUbCoordYX s_pPlanFillPattern[DEFS_MINE_DIGGABLE_WIDTH * ROWS_PER_PLAN_MAX];

//------------------------------------------------------------------ PUBLIC VARS

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Woverride-init"
const tTileDef g_pTileDefs[TILE_COUNT] = {
	[0 ... TILE_COUNT - 1] = {.ubSlots = 0, .ubMineral = MINERAL_TYPE_COUNT},
	[TILE_SILVER_1] = {.ubSlots = 1, .ubMineral = MINERAL_TYPE_SILVER},
	[TILE_SILVER_2] = {.ubSlots = 2, .ubMineral = MINERAL_TYPE_SILVER},
	[TILE_SILVER_3] = {.ubSlots = 3, .ubMineral = MINERAL_TYPE_SILVER},
	[TILE_GOLD_1] = {.ubSlots = 1, .ubMineral = MINERAL_TYPE_GOLD},
	[TILE_GOLD_2] = {.ubSlots = 2, .ubMineral = MINERAL_TYPE_GOLD},
	[TILE_GOLD_3] = {.ubSlots = 3, .ubMineral = MINERAL_TYPE_GOLD},
	[TILE_EMERALD_1] = {.ubSlots = 1, .ubMineral = MINERAL_TYPE_EMERALD},
	[TILE_EMERALD_2] = {.ubSlots = 2, .ubMineral = MINERAL_TYPE_EMERALD},
	[TILE_EMERALD_3] = {.ubSlots = 3, .ubMineral = MINERAL_TYPE_EMERALD},
	[TILE_RUBY_1] = {.ubSlots = 1, .ubMineral = MINERAL_TYPE_RUBY},
	[TILE_RUBY_2] = {.ubSlots = 2, .ubMineral = MINERAL_TYPE_RUBY},
	[TILE_RUBY_3] = {.ubSlots = 3, .ubMineral = MINERAL_TYPE_RUBY},
	[TILE_MOONSTONE_1] = {.ubSlots = 1, .ubMineral = MINERAL_TYPE_MOONSTONE},
	[TILE_MOONSTONE_2] = {.ubSlots = 2, .ubMineral = MINERAL_TYPE_MOONSTONE},
	[TILE_MOONSTONE_3] = {.ubSlots = 3, .ubMineral = MINERAL_TYPE_MOONSTONE},
	[TILE_COAL_1] = {.ubSlots = 1, .ubMineral = MINERAL_TYPE_COAL},
	[TILE_COAL_2] = {.ubSlots = 2, .ubMineral = MINERAL_TYPE_COAL},
	[TILE_COAL_3] = {.ubSlots = 3, .ubMineral = MINERAL_TYPE_COAL}
};
#pragma GCC diagnostic pop

const tTile g_pMineralToFirstTile[MINERAL_TYPE_COUNT] = {
	[MINERAL_TYPE_SILVER] = TILE_SILVER_1,
	[MINERAL_TYPE_GOLD] = TILE_GOLD_1,
	[MINERAL_TYPE_EMERALD] = TILE_EMERALD_1,
	[MINERAL_TYPE_RUBY] = TILE_RUBY_1,
	[MINERAL_TYPE_MOONSTONE] = TILE_MOONSTONE_1,
	[MINERAL_TYPE_COAL] = TILE_COAL_1,
};

//------------------------------------------------------------------ PRIVATE FNS

static UWORD chanceTrapezoid(
	UWORD uwCurr, UWORD uwStart, UWORD uwPeakStart, UWORD uwPeakEnd, UWORD uwEnd,
	UWORD uwMin, UWORD uwMax
) {
	if(uwStart < uwCurr && uwCurr < uwPeakStart) {
		// Ascending ramp
		return uwMin + ((uwMax - uwMin) * (uwCurr - uwStart)) / (uwPeakStart - uwStart);
	}
	if(uwPeakStart <= uwCurr && uwCurr <= uwPeakEnd) {
		// Peak
		return uwMax;
	}
	if(uwPeakEnd < uwCurr && uwCurr < uwEnd) {
		// Descending ramp
		return uwMax - ((uwMax - uwMin) * (uwCurr - uwPeakEnd)) / (uwEnd - uwPeakEnd);
	}
	// Out of range
	return uwMin;
}

static void tileSetBaseTiles(const tBase *pBase, UWORD uwLevel, UBYTE isReplacing) {
	UBYTE **pTiles = g_pMainBuffer->pTileData;
	for(UWORD y = 0; y <= TILE_ROW_BASE_DIRT+1; ++y) {
		for(UWORD x = 1; x < 1 + 10; ++x) {
			if(!isReplacing || tileIsSolid(x, uwLevel + y)) {
				pTiles[x][uwLevel + y] = pBase->pTilePattern[y * 10 + x - 1];
			}
		}
	}
}

static UBYTE tileProgress(
	UBYTE ubProgressStart, UBYTE ubProgressEnd,
	UWORD uwElementCurr, UWORD uwElementCount
) {
	 UBYTE ubProgress = (
		ubProgressStart +
		((ubProgressEnd - ubProgressStart) * uwElementCurr) / uwElementCount
	);
	return ubProgress;
}

static void tileGenerateTerrain(
	UBYTE isCoalOnly, tGameMode eGameMode, UBYTE ubProgressMin, UBYTE ubProgressMax
) {
	UWORD uwEndX = g_pMainBuffer->uTileBounds.uwX;
	UWORD uwEndY = g_pMainBuffer->uTileBounds.uwY;
	if(eGameMode == GAME_MODE_CHALLENGE) {
		uwEndY = TILE_ROW_CHALLENGE_FINISH + 20; // generate a bit more to accomodate scroll
	}

	UBYTE **pTiles = g_pMainBuffer->pTileData;

	for(UWORD uwX = 1; uwX < uwEndX; ++uwX) {
		UBYTE ubProgress = tileProgress(ubProgressMin, ubProgressMax, uwX, uwEndX);
		commProgress(ubProgress, g_pMsgs[MSG_LOADING_GEN_TERRAIN]);
		for(UWORD uwY = TILE_ROW_BASE_DIRT + 2; uwY < uwEndY; ++uwY) {
			// 2000 is max
			UWORD uwWhat = (randUw(&g_sRand) * 1000) / 65535;
			UWORD uwChanceAir = 50;
			UWORD uwChanceRock, uwChanceSilver, uwChanceGold, uwChanceEmerald, uwChanceRuby, uwChanceMoonstone, uwChanceMagma;
			if(eGameMode == GAME_MODE_CHALLENGE) {
				uwChanceRock = 75;
				uwChanceSilver = chanceTrapezoid(
					uwY, TILE_ROW_BASE_DIRT, TILE_ROW_BASE_DIRT+5,
					TILE_ROW_CHALLENGE_CHECKPOINT_2, TILE_ROW_CHALLENGE_CHECKPOINT_2 + 5,
					5, 200
				);
				uwChanceGold = chanceTrapezoid(
					uwY, TILE_ROW_CHALLENGE_CHECKPOINT_2 - 5, TILE_ROW_CHALLENGE_CHECKPOINT_2 + 5,
					TILE_ROW_CHALLENGE_FINISH - 5, TILE_ROW_CHALLENGE_FINISH + 5,
					2, 200
				);
				uwChanceEmerald = 0;
				uwChanceRuby = 0;
				uwChanceMoonstone = 10;
				uwChanceMagma = 10;
			}
			else if(eGameMode == GAME_MODE_DEADLINE) {
				uwChanceSilver = 75;
				uwChanceGold = (uwY > 60) ? 75 : 0;
				uwChanceEmerald = (uwY > 200) ? 75 : 0;
				uwChanceRuby = (uwY > 175) ? 75 : 0;
				uwChanceMoonstone = (uwY > 400) ? 75 : 0;
				uwChanceRock = CLAMP(uwY * 500 / 2000, 0, 500);
				uwChanceMagma = chanceTrapezoid(uwY, 50, 900, 1000, 1100, 0, 75);
			}
			else {
				uwChanceGold = 0;
				uwChanceEmerald = 0;
				uwChanceRuby = 0;
				uwChanceMoonstone = 0;
				uwChanceSilver = 0;
				uwChanceRock = CLAMP(uwY * 500 / 2000, 0, 500);
				uwChanceMagma = chanceTrapezoid(uwY, 50, 900, 1000, 1100, 0, 75);
			}

			UWORD uwChance;
			if(uwWhat < (uwChance = uwChanceRock)) {
				pTiles[uwX][uwY] = randUwMinMax(&g_sRand, TILE_STONE_1, TILE_STONE_4);
			}
			else if(uwWhat < (uwChance += uwChanceMagma)) {
				pTiles[uwX][uwY] = randUwMinMax(&g_sRand, TILE_MAGMA_1, TILE_MAGMA_2);
			}
			else if(
				uwWhat < (uwChance += uwChanceAir) &&
				tileIsSolid(uwX - 1, uwY) && tileIsSolid(uwX, uwY - 1)
			) {
				pTiles[uwX][uwY] = TILE_CAVE_BG_1;
			}
			else if(uwWhat < (uwChance += uwChanceSilver)) {
				pTiles[uwX][uwY] = (
					isCoalOnly
						? randUwMinMax(&g_sRand, TILE_COAL_1, TILE_COAL_3)
						: randUwMinMax(&g_sRand, TILE_SILVER_1, TILE_SILVER_3)
				);
			}
			else if(uwWhat < (uwChance += uwChanceGold)) {
				pTiles[uwX][uwY] = (
					isCoalOnly
						? randUwMinMax(&g_sRand, TILE_COAL_1, TILE_COAL_3)
						: randUwMinMax(&g_sRand, TILE_GOLD_1, TILE_GOLD_3)
				);
			}
			else if(uwWhat < (uwChance += uwChanceEmerald)) {
				pTiles[uwX][uwY] = (
					isCoalOnly
						? randUwMinMax(&g_sRand, TILE_COAL_1, TILE_COAL_3)
						: randUwMinMax(&g_sRand, TILE_EMERALD_1, TILE_EMERALD_3)
				);
			}
			else if(uwWhat < (uwChance += uwChanceRuby)) {
				pTiles[uwX][uwY] = (
					isCoalOnly
						? randUwMinMax(&g_sRand, TILE_COAL_1, TILE_COAL_3)
						: randUwMinMax(&g_sRand, TILE_RUBY_1, TILE_RUBY_3)
				);
			}
			else if(uwWhat < (uwChance += uwChanceMoonstone)) {
				pTiles[uwX][uwY] = (
					isCoalOnly
						? randUwMinMax(&g_sRand, TILE_COAL_1, TILE_COAL_3)
						: randUwMinMax(&g_sRand, TILE_MOONSTONE_1, TILE_MOONSTONE_3)
				);
			}
			else {
				pTiles[uwX][uwY] = TILE_DIRT_1 + ((uwX & 1) ^ (uwY & 1));
			}
			// For quick tests
			// g_pMainBuffer->pTileData[2][uwY] = TILE_CAVE_BG_1;
		}
	}
}

/**
 * @brief Places specified quest tile on given row.
 *
 * @param pTiles Tilemap.
 * @param uwY Depth to be placed on.
 * @param eTile Quest item's tile.
 * @return X position on row if placed, zero on failure.
 */
static UBYTE tileTryPlaceQuestItemInRow(UBYTE **pTiles, UWORD uwY, tTile eTile) {
	for(UBYTE i = 0; i < ARRAY_SIZE(s_pRowSpawnPattern); ++i) {
		UBYTE ubX = s_pRowSpawnPattern[s_ubNextRowPatternPos++];
		if(s_ubNextRowPatternPos >= ARRAY_SIZE(s_pRowSpawnPattern)) {
			s_ubNextRowPatternPos = 0;
		}
		if(ubX == 1 || ubX == 10) {
			continue;
		}
		if(pTiles[ubX][uwY] == TILE_DIRT_1 || pTiles[ubX][uwY] == TILE_DIRT_2) {
			pTiles[ubX][uwY] = eTile;
			return ubX;
		}
	}

	return 0;
}

static void tileGeneratePlanFillPattern(UWORD ubRowsPerPlan) {
	if(ubRowsPerPlan > ROWS_PER_PLAN_MAX) {
		logWrite(
			"ERR: too many rows per plan: %hu, expected max %hu",
			ubRowsPerPlan, ROWS_PER_PLAN_MAX
		);
	}

	UWORD uwPatternPos = 0;
	for(UBYTE ubX = 1; ubX < DEFS_MINE_DIGGABLE_WIDTH; ++ubX) {
		for(UBYTE ubY = 0; ubY < ubRowsPerPlan; ++ubY) {
			s_pPlanFillPattern[uwPatternPos++] = (tUbCoordYX){.ubX = ubX, .ubY = ubY};
		}
	}
	s_uwPlanFillPatternLength = uwPatternPos;

	// Shuffle pattern
	while (--uwPatternPos) {
		UWORD uwOtherPos = randUwMax(&g_sRand, uwPatternPos - 1);
		tUbCoordYX sTmp = {.uwYX = s_pPlanFillPattern[uwPatternPos].uwYX};
		s_pPlanFillPattern[uwPatternPos].uwYX = s_pPlanFillPattern[uwOtherPos].uwYX;
		s_pPlanFillPattern[uwOtherPos].uwYX = sTmp.uwYX;
	}
}

//------------------------------------------------------------------- PUBLIC FNS

UBYTE tileIsExcavated(UWORD uwX, UWORD uwY) {
	UBYTE ubTile = g_pMainBuffer->pTileData[uwX][uwY];
	return TILE_CAVE_BG_1 <= ubTile && ubTile <= TILE_CAVE_BG_STONE_6;
}

UBYTE tileIsSolid(UWORD uwX, UWORD uwY) {
	UBYTE ubTile = g_pMainBuffer->pTileData[uwX][uwY];
	return (
		(TILE_BASE_GROUND_1 <= ubTile && ubTile <= TILE_BASE_GROUND_9) ||
		ubTile >= TILE_DIRT_1
	);
}

UBYTE tileIsDrillable(UWORD uwX, UWORD uwY) {
	return g_pMainBuffer->pTileData[uwX][uwY] >= TILE_DIRT_1;
}

UBYTE tileIsHardToDrill(UWORD uwX, UWORD uwY) {
	return g_pMainBuffer->pTileData[uwX][uwY] >= TILE_STONE_1;
}

void tileReset(UBYTE isCoalOnly, tGameMode eGameMode) {
	logBlockBegin(
		"tileReset(isCoalOnly: %hhu, eGameMOde: %d)", isCoalOnly, eGameMode
	);
	UWORD uwEndX = g_pMainBuffer->uTileBounds.uwX;
	UWORD uwEndY = TILE_MINE_DEPTH;
	if(eGameMode == GAME_MODE_CHALLENGE) {
		uwEndY = TILE_ROW_CHALLENGE_FINISH + 20; // generate a bit more to accomodate scroll
	}

	UBYTE **pTiles = g_pMainBuffer->pTileData;
	s_ubPrisonerX = 0;

	// Generate terrain
	UBYTE ubProgressTerrainEnd = 30;
	tileGenerateTerrain(isCoalOnly, eGameMode, 0, ubProgressTerrainEnd);

	if(eGameMode == GAME_MODE_DEADLINE) {
		for(UWORD uwY = BASE_PATTERN_HEIGHT + 5; uwY < g_pMainBuffer->uTileBounds.uwY; uwY += 15) {
			if(!tileTryPlaceQuestItemInRow(pTiles, uwY, TILE_CRATE_1)) {
				pTiles[5][uwY] = TILE_CRATE_1;
			}
		}
	}

	tBaseId eBaseCount = (eGameMode == GAME_MODE_STORY) ? BASE_ID_COUNT : BASE_ID_GROUND + 1;
	// Generate bases
	UBYTE ubProgressBaseStart = ubProgressTerrainEnd;
	UBYTE ubProgressBaseEnd = 40;
	for(tBaseId eBaseId = 0; eBaseId < eBaseCount; ++eBaseId) {
		const tBase *pBase = baseGetById(eBaseId);
		if(pBase->uwTileDepth != BASE_TILE_DEPTH_VARIANT) {
			UBYTE ubProgress = tileProgress(ubProgressBaseStart, ubProgressBaseEnd, eBaseId, BASE_ID_COUNT_UNIQUE);
			commProgress(ubProgress, g_pMsgs[MSG_LOADING_GEN_BASES]);
			tileSetBaseTiles(pBase, pBase->uwTileDepth, 0);
		}
	}

	// Fill left invisible col with rocks
	for(UWORD y = 0; y < uwEndY; ++y) {
		pTiles[0][y] = TILE_DIRT_1;
	}
	commProgress(50, g_pMsgs[MSG_LOADING_FINISHING]);

	if(eGameMode == GAME_MODE_CHALLENGE) {
		for(UWORD x = 1; x < uwEndX; ++x) {
			pTiles[x][TILE_ROW_CHALLENGE_CHECKPOINT_1] = TILE_CHECKPOINT_1 + x - 1;
			pTiles[x][TILE_ROW_CHALLENGE_CHECKPOINT_2] = TILE_CHECKPOINT_1 + x - 1;
			pTiles[x][TILE_ROW_CHALLENGE_CHECKPOINT_3] = TILE_CHECKPOINT_1 + x - 1;
			pTiles[x][TILE_ROW_CHALLENGE_FINISH] = TILE_CHECKPOINT_1 + x - 1;
			pTiles[x][TILE_ROW_CHALLENGE_FINISH+1] = TILE_STONE_1 + (x & 1);
		}
		commProgress(90, g_pMsgs[MSG_LOADING_FINISHING]);
	}
	else if(eGameMode == GAME_MODE_DEADLINE) {
		for(UWORD x = 1; x < uwEndX; ++x) {
			pTiles[x][uwEndY - 2 ] = TILE_CHECKPOINT_1 + x - 1;
			pTiles[x][uwEndY - 2 +1] = TILE_STONE_1 + (x & 1);
		}
	}
	else if(eGameMode == GAME_MODE_STORY) {
		// Rock bottom
		for(UWORD x = 1; x < uwEndX; ++x) {
			pTiles[x][uwEndY - 1] = TILE_STONE_1 + (x & 3);
		}

		// Quest items: bones
		s_ubNextRowPatternPos = 0;
		for(UBYTE i = 0; i < DEFS_QUEST_DINO_BONE_COUNT; ++i) {
			tTile eTile = (i == 0) ? TILE_BONE_HEAD : TILE_BONE_1;
			if(!tileTryPlaceQuestItemInRow(pTiles, g_pDinoDepths[i], eTile)) {
				logWrite("ERR: Can't find place for dino bone #%hhu at row %hu\n", i + 1, g_pDinoDepths[i]);
				pTiles[5][g_pDinoDepths[i]] = eTile;
			}
		}

		// Quest items: gate fragments
#if defined(TILE_QUEST_DEBUG_PLACEMENT)
		pTiles[1][219] = TILE_GATE_1;
		pTiles[2][219] = TILE_GATE_2;
		pTiles[3][219] = TILE_GATE_1;
		pTiles[4][219] = TILE_GATE_2;
		pTiles[5][219] = TILE_GATE_1;
		pTiles[6][219] = TILE_GATE_2;
		pTiles[7][219] = TILE_GATE_1;
		pTiles[8][219] = TILE_GATE_2;
		pTiles[9][219] = TILE_GATE_1;
		pTiles[1][220] = TILE_GATE_2;
		pTiles[2][220] = TILE_GATE_1;
		pTiles[3][220] = TILE_GATE_2;
		pTiles[4][220] = TILE_GATE_1;
		pTiles[5][220] = TILE_GATE_2;
		pTiles[6][220] = TILE_GATE_1;
		pTiles[7][220] = TILE_GATE_2;
#else
		for(UBYTE i = 0; i < DEFS_QUEST_GATE_PART_COUNT; ++i) {
			tTile eTile = (i & 1) ? TILE_GATE_2 : TILE_GATE_1;
			if(!tileTryPlaceQuestItemInRow(pTiles, g_pGateDepths[i], eTile)) {
				logWrite("ERR: Can't find place for gate part #%hhu at row %hu\n", i + 1, g_pGateDepths[i]);
				pTiles[5][g_pGateDepths[i]] = eTile;
			}
		}
#endif

		// Quest tile: prisoner
		s_ubPrisonerX = tileTryPlaceQuestItemInRow(pTiles, g_uwPrisonerDepth, TILE_PRISONER_1);
		if(!s_ubPrisonerX) {
			logWrite("ERR: Can't find place for prisoner at row %hu\n", g_uwPrisonerDepth);
			s_ubPrisonerX = 5;
			pTiles[s_ubPrisonerX][g_uwPrisonerDepth] = TILE_PRISONER_1;
		}

		// Quest items: crates
		s_ubNextRowPatternPos = 0;
		for(UBYTE i = 0; i < DEFS_QUEST_CRATE_COUNT; ++i) {
			tTile eTile = TILE_CRATE_1;
			if(!tileTryPlaceQuestItemInRow(pTiles, g_pCrateDepths[i], eTile)) {
				logWrite("ERR: Can't find place for crate #%hhu at row %hu\n", i + 1, g_pCrateDepths[i]);
				pTiles[5][g_pCrateDepths[i]] = eTile;
			}
		}

		// Quest tile: capsule
		if(!tileTryPlaceQuestItemInRow(pTiles, g_uwCapsuleDepth, TILE_CAPSULE)) {
			logWrite("ERR: Can't find place for capsule at row %hu\n", g_uwCapsuleDepth);
			pTiles[5][g_uwCapsuleDepth] = TILE_CAPSULE;
		}

		commProgress(55, g_pMsgs[MSG_LOADING_FINISHING]);

		// Rows per plan
		UWORD uwPlannableRows = uwEndY - 2;
		uwPlannableRows -= BASE_ID_COUNT_UNIQUE * BASE_PATTERN_HEIGHT;
		UBYTE ubPlanCount = g_ubPlansPerAccolade * g_ubAccoladesInMainStory;
		UWORD uwPlannedRows = (uwPlannableRows * g_ubMinePercentForPlans) / 100;
		UBYTE ubRowsPerPlan = uwPlannedRows / ubPlanCount;
		logWrite("plannable rows: %hu, planned: %hu, rows per plan: %hhu\n", uwPlannableRows, uwPlannedRows, ubRowsPerPlan);

		tileGeneratePlanFillPattern(ubRowsPerPlan);
		commProgress(60, g_pMsgs[MSG_LOADING_FINISHING]);

		tBaseId eBaseId = 0;
		UWORD uwCurrentRow = 0;
		UWORD uwNextPatternPos = 0;
		UWORD uwCurrentPlannableRow = 0;
		UWORD pPlanSegmentRows[ROWS_PER_PLAN_MAX];
		UBYTE ubProgressPlanBegin = 60;
		UBYTE ubProgressPlanEnd = 80;
		for(UBYTE ubPlanIndex = 0; ubPlanIndex < ubPlanCount; ++ubPlanIndex) {
			UBYTE ubProgress = tileProgress(ubProgressPlanBegin, ubProgressPlanEnd, ubPlanIndex, ubPlanCount);
			commProgress(ubProgress, g_pMsgs[MSG_LOADING_FINISHING]);
			// Get mine rows for plan
			UWORD planLastPlannableRow  = (uwPlannedRows * (ubPlanIndex + 1)) / ubPlanCount;
			UBYTE ubPlanRowCount = 0;
			while(uwCurrentPlannableRow <= planLastPlannableRow) {
				if(eBaseId < BASE_ID_COUNT_UNIQUE && uwCurrentRow >= baseGetById(eBaseId)->uwTileDepth) {
					uwCurrentRow = baseGetById(eBaseId)->uwTileDepth + BASE_PATTERN_HEIGHT;
					++eBaseId;
				}
				pPlanSegmentRows[ubPlanRowCount++] = uwCurrentRow++;
				++uwCurrentPlannableRow;
			}

			const tPlan *pPlan = &planManagerGet()->pPlanSequence[ubPlanIndex];
			logWrite(
				"plan %hhu rows %hu..%hu minerals required: %hu\n",
				ubPlanIndex, pPlanSegmentRows[0], pPlanSegmentRows[ubPlanRowCount - 1],
				pPlan->uwTotalMineralsRequired
			);

			// Fill mine segment with minerals required for plan, merging some in the process
			ULONG ulPlacedMoney = 0;
			UWORD uwTotalMineralsRemaining = pPlan->uwTotalMineralsRequired;

			UWORD pMineralsRemaining[MINERAL_TYPE_COUNT];
			memcpy(pMineralsRemaining, pPlan->pMineralsRequired, sizeof(pMineralsRemaining));

			tMineralType pMineralsAllowed[MINERAL_TYPE_COUNT];
			UBYTE ubMineralsAllowedCount = planGetAllowedMineralsForIndex(ubPlanIndex, pMineralsAllowed);
			UBYTE ubPlacedStacks = 0;
			while(uwTotalMineralsRemaining > 0) {
				// pick mineral
				tMineralType ePlacedMineral = pMineralsAllowed[randUwMax(&g_sRand, ubMineralsAllowedCount - 1)];
				if(pMineralsRemaining[ePlacedMineral] > 0) {
					UWORD uwStartPatternPos = uwNextPatternPos;
					UBYTE isPlaced = 0;
					do {
						// pick next position from pattern
						tUbCoordYX sPlacePosition = s_pPlanFillPattern[uwNextPatternPos];
						if(++uwNextPatternPos >= s_uwPlanFillPatternLength) {
							uwNextPatternPos = 0;
						}

						if(sPlacePosition.ubY >= ubPlanRowCount) {
							continue;
						}

						// fill position with mineral
						tTile eExistingTile = pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]];
						if(eExistingTile == TILE_DIRT_1 || eExistingTile == TILE_DIRT_2) {
							UBYTE ubPlacedAmount = randUwMinMax(&g_sRand, 1, MIN(pMineralsRemaining[ePlacedMineral], 3));
							tTile eNewTile = g_pMineralToFirstTile[ePlacedMineral] + ubPlacedAmount - 1;
							pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]] = eNewTile;
							uwTotalMineralsRemaining -= ubPlacedAmount;
							pMineralsRemaining[ePlacedMineral] -= ubPlacedAmount;
							isPlaced = 1;
							++ubPlacedStacks;
							ulPlacedMoney += g_pMinerals[ePlacedMineral].ubReward * ubPlacedAmount;
							break;
						}
						else {
							tMineralType eExistingMineral = g_pTileDefs[eExistingTile].ubMineral;
							if (
								eExistingMineral != MINERAL_TYPE_COUNT &&
								pMineralsRemaining[eExistingMineral] > 0 &&
								g_pTileDefs[eExistingTile].ubSlots < 3
							) {
								UBYTE ubDelta = MIN(3 - g_pTileDefs[eExistingTile].ubSlots, pMineralsRemaining[eExistingMineral]);
								tTile eNewTile = eExistingTile + ubDelta - 1;
								pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]] = eNewTile;
								pMineralsRemaining[eExistingMineral] -= ubDelta;
								uwTotalMineralsRemaining -= ubDelta;
								isPlaced = 1;
								ulPlacedMoney += g_pMinerals[eExistingMineral].ubReward * ubDelta;
								break;
							}
						}
					} while(uwNextPatternPos != uwStartPatternPos);
					if(!isPlaced) {
						logWrite("ERR: Can't place all minerals on plan %hhu\n", ubPlanIndex);
						break;
					}
				}
			}
			logWrite("placed money: %lu/%lu, stacks: %hhu\n", ulPlacedMoney, pPlan->ulTargetSum, ubPlacedStacks);

			LONG lExtraMineralMoney = g_ulExtraPlanMoney;
			while(lExtraMineralMoney > 0) {
				// pick mineral
				UBYTE ePlacedMineral = pMineralsAllowed[randUwMax(&g_sRand, ubMineralsAllowedCount - 1)];
				UWORD uwStartPatternPos = uwNextPatternPos;
				UBYTE isPlaced = 0;
				do {
					// pick next position from pattern
					tUbCoordYX sPlacePosition = s_pPlanFillPattern[uwNextPatternPos];
					if(++uwNextPatternPos >= s_uwPlanFillPatternLength) {
						uwNextPatternPos = 0;
					}

					if(sPlacePosition.ubY >= ubPlanRowCount) {
						continue;
					}

					// fill position with mineral
					tTile eExistingTile = pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]];
					if(eExistingTile == TILE_DIRT_1 || eExistingTile == TILE_DIRT_2) {
						UBYTE ubMineralReward = g_pMinerals[ePlacedMineral].ubReward;
						UBYTE ubMaxAmount = MIN(((lExtraMineralMoney + ubMineralReward - 1) / ubMineralReward), 3);
						UBYTE ubPlacedAmount = randUwMinMax(&g_sRand, 1, ubMaxAmount);
						lExtraMineralMoney -= ubPlacedAmount * ubMineralReward;
						tTile eNewTile = g_pMineralToFirstTile[ePlacedMineral] + ubPlacedAmount - 1;
						pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]] = eNewTile;
						isPlaced = 1;
						break;
					}
				} while(uwNextPatternPos != uwStartPatternPos);
				if(!isPlaced) {
					logWrite("ERR: Couldn't place all extra minerals on plan %hhu, remaining money to place: %ld/%lu\n", ubPlanIndex, lExtraMineralMoney, g_ulExtraPlanMoney);
					break;
				}
			}
		}

		// Extra minerals after all plans
		UWORD pMineralsInFauxPlan[MINERAL_TYPE_COUNT] = {0};
		for(UBYTE ubPlanIndex = 0; ubPlanIndex < ubPlanCount; ++ubPlanIndex) {
			for(tMineralType eMineral = 0; eMineral < MINERAL_TYPE_COUNT; ++eMineral) {
				pMineralsInFauxPlan[eMineral] += planManagerGet()->pPlanSequence[ubPlanIndex].pMineralsRequired[eMineral];
			}
		}

		UWORD uwUnplannedRows = uwPlannableRows - uwPlannedRows;
		UBYTE ubProgressFauxPlanBegin = 80;
		UBYTE ubProgressFauxPlanEnd = 100;
		if(uwUnplannedRows > 0) {
			UBYTE ubFauxPlanCount = uwUnplannedRows / ubRowsPerPlan;
			UWORD uwTotalMineralsPerFauxPlan = 0;
			for(tMineralType eMineral = 0; eMineral < MINERAL_TYPE_COUNT; ++eMineral) {
				pMineralsInFauxPlan[eMineral] = ((pMineralsInFauxPlan[eMineral] * g_ubTrailingMineralCountPercent) / 100) / ubFauxPlanCount;
				uwTotalMineralsPerFauxPlan += pMineralsInFauxPlan[eMineral];
				logWrite("Mineral %d per faux plan: %hu\n", eMineral, pMineralsInFauxPlan[eMineral]);
			}
			tMineralType pMineralsAllowed[MINERAL_TYPE_COUNT];
			UBYTE ubMineralsAllowedCount = planGetAllowedMineralsForIndex(PLAN_COUNT_MAX, pMineralsAllowed);
			for(UBYTE ubFauxPlanIndex = 0; ubFauxPlanIndex < ubFauxPlanCount; ++ubFauxPlanIndex) {
				UBYTE ubProgress = tileProgress(ubProgressFauxPlanBegin, ubProgressFauxPlanEnd, ubFauxPlanIndex, ubFauxPlanCount);
				commProgress(ubProgress, g_pMsgs[MSG_LOADING_FINISHING]);
				// Get mine rows for faux-plan
				UWORD uwPlanLastFauxPlanRow = MIN(uwPlannedRows + (uwUnplannedRows * (ubFauxPlanIndex + 1)) / ubFauxPlanCount, uwEndY - 1);
				UBYTE ubPlanRowCount = 0;
				while(uwCurrentPlannableRow <= uwPlanLastFauxPlanRow) {
					if(eBaseId < BASE_ID_COUNT_UNIQUE && uwCurrentRow >= baseGetById(eBaseId)->uwTileDepth) {
						uwCurrentRow = baseGetById(eBaseId)->uwTileDepth + BASE_PATTERN_HEIGHT;
						++eBaseId;
					}
					pPlanSegmentRows[ubPlanRowCount++] = uwCurrentRow++;
					++uwCurrentPlannableRow;
				}

				logWrite(
					"Faux plan %hhu rows %hu..%hu (%hhu) minerals required: %hu\n",
					ubFauxPlanIndex, pPlanSegmentRows[0],
					pPlanSegmentRows[ubPlanRowCount - 1], ubPlanRowCount,
					uwTotalMineralsPerFauxPlan
				);

				// Fill mine segment with minerals required for faux-plan, merging some in the process
				UWORD uwTotalMineralsRemaining = uwTotalMineralsPerFauxPlan;
				UWORD pMineralsRemaining[MINERAL_TYPE_COUNT];
				memcpy(pMineralsRemaining, pMineralsInFauxPlan, sizeof(pMineralsRemaining));
				while(uwTotalMineralsRemaining > 0) {
					// pick mineral and count
					tMineralType ePlacedMineral = pMineralsAllowed[randUwMax(&g_sRand, ubMineralsAllowedCount - 1)];
					if(pMineralsRemaining[ePlacedMineral] > 0) {
						UWORD uwStartPatternPos = uwNextPatternPos;
						UBYTE isPlaced = 0;
						do {
							// pick next position from pattern
							tUbCoordYX sPlacePosition = s_pPlanFillPattern[uwNextPatternPos];
							if(++uwNextPatternPos >= s_uwPlanFillPatternLength) {
								uwNextPatternPos = 0;
							}

							if(sPlacePosition.ubY >= ubPlanRowCount) {
								continue;
							}

							// fill position with mineral
							tTile eExistingTile = pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]];
							if(eExistingTile == TILE_DIRT_1 || eExistingTile == TILE_DIRT_2) {
								UBYTE ubPlacedAmount = randUwMinMax(&g_sRand, 1, MIN(pMineralsRemaining[ePlacedMineral], 3));
								tTile eNewTile = g_pMineralToFirstTile[ePlacedMineral] + ubPlacedAmount - 1;
								pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]] = eNewTile;
								uwTotalMineralsRemaining -= ubPlacedAmount;
								pMineralsRemaining[ePlacedMineral] -= ubPlacedAmount;
								isPlaced = 1;
								break;
							}
							else {
								tMineralType eExistingMineral = g_pTileDefs[eExistingTile].ubMineral;
								if (
									eExistingMineral != MINERAL_TYPE_COUNT &&
									pMineralsRemaining[eExistingMineral] > 0 &&
									g_pTileDefs[eExistingTile].ubSlots < 3
								) {
									UBYTE ubDelta = MIN(3 - g_pTileDefs[eExistingTile].ubSlots, pMineralsRemaining[eExistingMineral]);
									tTile eNewTile = eExistingTile + ubDelta - 1;
									pTiles[sPlacePosition.ubX][pPlanSegmentRows[sPlacePosition.ubY]] = eNewTile;
									pMineralsRemaining[eExistingMineral] -= ubDelta;
									uwTotalMineralsRemaining -= ubDelta;
									isPlaced = 1;
									break;
								}
							}
						} while(uwNextPatternPos != uwStartPatternPos);
						if(!isPlaced) {
							logWrite("WARN: Can't place all minerals on faux plan %hhu", ubFauxPlanIndex);
							break;
						}
					}
				}
			}
		}
	}

#if defined(GAME_DEBUG)
	// Log mine contents
	char szMineRow[50];
	for(UWORD uwY = 0; uwY < uwEndY; ++uwY) {
		char *pEnd = &szMineRow[0];
		pEnd += sprintf(pEnd, "%4hu: ", uwY);
		for(UWORD uwX = 1; uwX < uwEndX; ++uwX) {
			if(!tileIsSolid(uwX, uwY)) {
				pEnd += sprintf(pEnd, "   ");
			}
			else {
				char cKind = '?';
				char cCount = ' ';
				if(g_pTileDefs[pTiles[uwX][uwY]].ubSlots) {
					static const char pMineralToChar[MINERAL_TYPE_COUNT] = {
						[MINERAL_TYPE_SILVER] = 'S',
						[MINERAL_TYPE_GOLD] = 'G',
						[MINERAL_TYPE_EMERALD] = 'E',
						[MINERAL_TYPE_RUBY] = 'R',
						[MINERAL_TYPE_MOONSTONE] = 'M',
						[MINERAL_TYPE_COAL] = 'C',
					};
					cKind = pMineralToChar[g_pTileDefs[pTiles[uwX][uwY]].ubMineral];
					cCount = '0' + g_pTileDefs[pTiles[uwX][uwY]].ubSlots;
				}
				else if(TILE_STONE_1 <= pTiles[uwX][uwY] && pTiles[uwX][uwY] <= TILE_STONE_4) {
					cKind = 's';
					cCount = 's';
				}
				else if(TILE_MAGMA_1 <= pTiles[uwX][uwY] && pTiles[uwX][uwY] <= TILE_MAGMA_2) {
					cKind = 'm';
					cCount = 'm';
				}
				else if(TILE_BONE_HEAD <= pTiles[uwX][uwY] && pTiles[uwX][uwY] <= TILE_BONE_1) {
					cKind = 'd';
					cCount = 'd';
				}
				else if(pTiles[uwX][uwY] <= TILE_BASE_SHAFT) {
					cKind = ' ';
					cCount = ' ';
				}
				else if(TILE_BASE_GROUND_1 <= pTiles[uwX][uwY] && pTiles[uwX][uwY] <= TILE_BASE_GROUND_1) {
					cKind = 'X';
					cCount = 'X';
				}
				else if(TILE_DIRT_1 <= pTiles[uwX][uwY] && pTiles[uwX][uwY] <= TILE_DIRT_2) {
					cKind = '.';
					cCount = '.';
				}
				else if(TILE_GATE_1 <= pTiles[uwX][uwY] && pTiles[uwX][uwY] <= TILE_GATE_2) {
					cKind = 'g';
					cCount = 'g';
				}
				pEnd += sprintf(pEnd, "%c%c ", cKind, cCount);
			}
		}
		logWrite(szMineRow);
	}
#endif

	logBlockEnd("tileReset()");
}

void tileSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_TILE);
	UBYTE **pTiles = g_pMainBuffer->pTileData;
	UWORD uwSizeX = g_pMainBuffer->uTileBounds.uwX;
	UWORD uwSizeY = g_pMainBuffer->uTileBounds.uwY;

	fileWrite(pFile, &uwSizeX, sizeof(uwSizeX));
	fileWrite(pFile, &uwSizeY, sizeof(uwSizeY));
	for(UWORD uwX = 1; uwX < uwSizeX; ++uwX) {
		fileWrite(pFile, &pTiles[uwX][0], sizeof(pTiles[0][0]) * uwSizeY);
	}
	fileWrite(pFile, &s_ubPrisonerX, sizeof(s_ubPrisonerX));
	saveWriteTag(pFile, SAVE_TAG_TILE_END);
}

UBYTE tileLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_TILE)) {
		return 0;
	}

	UBYTE **pTiles = g_pMainBuffer->pTileData;
	UWORD uwSizeX, uwSizeY;

	fileRead(pFile, &uwSizeX, sizeof(uwSizeX));
	fileRead(pFile, &uwSizeY, sizeof(uwSizeY));
	for(UWORD uwY = 0; uwY < uwSizeY; ++uwY) {
		pTiles[0][uwY] = TILE_DIRT_1;
	}
	for(UWORD uwX = 1; uwX < uwSizeX; ++uwX) {
		fileRead(pFile, &pTiles[uwX][0], sizeof(pTiles[0][0]) * uwSizeY);
	}
	fileRead(pFile, &s_ubPrisonerX, sizeof(s_ubPrisonerX));
	return saveReadTag(pFile, SAVE_TAG_TILE_END);
}

void tileExcavate(UWORD uwX, UWORD uwY) {
	UBYTE ubBg = TILE_CAVE_BG_1 + (randUw(&g_sRand) & 7);
	if(ubBg >= TILE_CAVE_BG_STONE_6) {
		// only 0..6 supported right now
		ubBg = TILE_CAVE_BG_1;
	};

	// up
	if(!tileIsSolid(uwX, uwY-1)) {
		tileBufferInvalidateTile(g_pMainBuffer, uwX, uwY-1);
	}

	// down
	if(!tileIsSolid(uwX, uwY+1)) {
		tileBufferInvalidateTile(g_pMainBuffer, uwX, uwY+1);
	}

	// right
	if(uwX < 10 && !tileIsSolid(uwX+1, uwY)) {
		tileBufferInvalidateTile(g_pMainBuffer, uwX+1, uwY);
	}

	// left
	if(!tileIsSolid(uwX-1, uwY)) {
		tileBufferInvalidateTile(g_pMainBuffer, uwX-1, uwY);
	}

	tileBufferSetTile(g_pMainBuffer, uwX, uwY, ubBg);
}

void tileReplaceBaseWithVariant(tBaseId eBase, tBaseId eNewVariant) {
	const tBase *pBase = baseGetById(eBase);
	const tBase *pBaseVariant = baseGetById(eNewVariant);
	if(pBaseVariant->uwTileDepth != BASE_TILE_DEPTH_VARIANT) {
		logWrite("ERR: eNewVariant %d is not a base variant\n", eNewVariant);
	}
	if(pBase->uwTileDepth == BASE_TILE_DEPTH_VARIANT) {
		logWrite("ERR: eBase %d is not a base non-variant\n", eNewVariant);
	}

	tileSetBaseTiles(pBaseVariant, pBase->uwTileDepth, 1);
}

tTile tileGetPrisoner(void) {
	return g_pMainBuffer->pTileData[s_ubPrisonerX][g_uwPrisonerDepth];
}

void tileSetPrisoner(tTile eNewTile) {
	if(eNewTile < TILE_PRISONER_1 || TILE_PRISONER_8 < eNewTile) {
		logWrite("ERR: eNewTile out of range: %d\n", eNewTile);
	}

	tTile ePrevTile = g_pMainBuffer->pTileData[s_ubPrisonerX][g_uwPrisonerDepth];
	if(ePrevTile < TILE_PRISONER_1 || TILE_PRISONER_8 < ePrevTile) {
		logWrite("ERR: prev tile out of range: %d\n", ePrevTile);
	}

	tileBufferSetTile(g_pMainBuffer, s_ubPrisonerX, g_uwPrisonerDepth, eNewTile);
}
