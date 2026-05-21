/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "tile.h"
#include <mini_std/stdlib.h>
#include <ace/types.h>
#include <ace/generic/screen.h>
#include <ace/managers/blit.h>
#include <ace/managers/rand.h>
#include "assets.h"
#include "chaos_arena.h"
#include "display.h"
#include "sfx.h"

#define TILE_WIDTH (DISPLAY_WIDTH / MAP_TILE_SIZE)
#define TILE_HEIGHT (DISPLAY_HEIGHT / MAP_TILE_SIZE)
#define SPAWNS_MAX 30
#define CRUMBLES_MAX 10
#define CRUMBLE_COOLDOWN 1
#define CRUMBLE_ADD_COOLDOWN 15
#define TILE_QUEUE_SIZE (CRUMBLES_MAX * 2)

typedef enum tTile {
	TILE_VOID,
	TILE_FLOOR1_C8, // crumble state, 8: max crumble, 1: min
	TILE_FLOOR1_C7,
	TILE_FLOOR1_C6,
	TILE_FLOOR1_C5,
	TILE_FLOOR1_C4,
	TILE_FLOOR1_C3,
	TILE_FLOOR1_C2,
	TILE_FLOOR1_C1,
	TILE_FLOOR1,
	TILE_COUNT
} tTile;

typedef struct tCrumble {
	tTile *pTile;
	UBYTE ubTileX;
	UBYTE ubTileY;
	UBYTE ubCooldown;
} tCrumble;

typedef struct tTileDrawQueueEntry {
	UWORD uwX;
	UWORD uwY;
	UWORD uwTileOffset;
	UWORD uwTileOffsetAbove;
	UWORD uwTileOffsetBelow;
	UBYTE ubDrawCount;
} tTileDrawQueueEntry;

typedef struct tTileCrumbleOrderEntry {
	tUbCoordYX sPos;
	UWORD uwSortOrder;
} tTileCrumbleOrderEntry;

static tTile s_pTilesSourceXy[TILE_WIDTH][TILE_HEIGHT];
static tTile s_pTilesXy[TILE_WIDTH][TILE_HEIGHT];
static tCrumble s_pCrumbleList[CRUMBLES_MAX];
static tUwCoordYX s_pSpawns[SPAWNS_MAX];
static UBYTE s_ubSpawnCount;
static UBYTE s_ubActiveCrumbles;
static UBYTE s_ubCrumbleAddCooldown;

static tTileDrawQueueEntry s_pTileRedrawQueue[TILE_QUEUE_SIZE];
static UBYTE s_ubRedrawPushPos;
static UBYTE s_ubRedrawPopPos;
static tTileCrumbleOrderEntry s_pTileCrumbleOrder[TILE_WIDTH * TILE_HEIGHT];

static UWORD s_uwTileCount;
static UWORD s_uwCurrentTileCrumble;

/**
 * @brief The easy to read tile layout.
 * Note that indices are reversed here, but the ascii is in correct order.
 */
static const char s_pMapPatternsYx[3][TILE_HEIGHT][TILE_WIDTH + 1] = {
	{
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@....@..b..c..@....@@",
		"@@.a..@........@..d.@@",
		"@@@@@.@@@@..@@@@.@@@@@",
		"@@@@@....@..@....@@@@@",
		"@@...@...@..@...@...@@",
		"@@.l.....@..@.....j.@@",
		"@@...m...@..@...k...@@",
		"@@...@...@..@...@...@@",
		"@@@@@....@..@....@@@@@",
		"@@@@@.@@@@..@@@@.@@@@@",
		"@@.e..@........@..f.@@",
		"@@....@..h..g..@....@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@"
	},
	{
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@..................@@",
		"@@.a...j....f..k..b.@@",
		"@@..................@@",
		"@@.....@@@@@@@@.....@@",
		"@@....@@@@@@@@@@..o.@@",
		"@@.g.@@@@@@@@@@@@...@@",
		"@@...@@@@@@@@@@@@.h.@@",
		"@@.n..@@@@@@@@@@....@@",
		"@@.....@@@@@@@@.....@@",
		"@@..................@@",
		"@@.d..m...e....l..c.@@",
		"@@..................@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@"
	},
	{
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@.....L......J.....@@",
		"@@.1......9.......3.@@",
		"@@....@@@....@@@....@@",
		"@@.G..@@@..5.@@@..D.@@",
		"@@....@@@....@@@....@@",
		"@@.....B...M......8.@@",
		"@@.7......N...C.....@@",
		"@@....@@@....@@@....@@",
		"@@.E..@@@.6..@@@..F.@@",
		"@@....@@@....@@@....@@",
		"@@.4.......A......2.@@",
		"@@.....H......K.....@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@",
		"@@@@@@@@@@@@@@@@@@@@@@"
	}
};

//------------------------------------------------------------------ PRIVATE FNS

static void tileQueueReset(void) {
	for(UBYTE i = 0; i < TILE_QUEUE_SIZE; ++i) {
		s_pTileRedrawQueue[i].ubDrawCount = 0;
	}
}

static void tileQueueAddEntry(UBYTE ubTileX, UBYTE ubTileY, tTile eTile) {
	s_pTilesXy[ubTileX][ubTileY] = eTile;
	tTileDrawQueueEntry *pEntry = &s_pTileRedrawQueue[s_ubRedrawPushPos];
	pEntry->uwTileOffset = eTile * MAP_FULL_TILE_HEIGHT;
	pEntry->uwTileOffsetAbove = s_pTilesXy[ubTileX][ubTileY - 1] * MAP_FULL_TILE_HEIGHT + MAP_TILE_SIZE;
	pEntry->uwTileOffsetBelow = s_pTilesXy[ubTileX][ubTileY + 1] * MAP_FULL_TILE_HEIGHT;
	pEntry->uwX = ubTileX * MAP_TILE_SIZE;
	pEntry->uwY = ubTileY * MAP_TILE_SIZE;
#if defined(ACE_BOB_PRISTINE_BUFFER)
	pEntry->ubDrawCount = 4; // + 2x pristine buffer
#else
	pEntry->ubDrawCount = 2;
#endif

	if(++s_ubRedrawPushPos == TILE_QUEUE_SIZE) {
		s_ubRedrawPushPos = 0;
	}
	if(s_ubRedrawPushPos == s_ubRedrawPopPos) {
		logWrite("ERR: Ring buffer overflow");
	}
}

static void tileQueueProcess(tBitMap *pBuffer) {
	tTileDrawQueueEntry *pEntry = &s_pTileRedrawQueue[s_ubRedrawPopPos];
	if(pEntry->ubDrawCount == 0) {
		return;
	}

	// Draw side part of the tile above masked with the tile: D=AB+!AC
	// A - current tile mask
	// B - current tile
	// C - above tile
	// D - destination buffer
	UWORD uwWidthWords = 1;
	ULONG ulCurrOffs = g_pTileset->BytesPerRow * pEntry->uwTileOffset;
	ULONG ulAboveOffs = g_pTileset->BytesPerRow * (pEntry->uwTileOffsetAbove);
	ULONG ulDstOffs = pBuffer->BytesPerRow * pEntry->uwY + (pEntry->uwX / 8);
	WORD wTileModulo = 0;
	WORD wDstModulo = (DISPLAY_WIDTH / 8) - (uwWidthWords * 2);
	WORD wHeight = MAP_TILE_SIDE_HEIGHT * DISPLAY_BPP;

	blitWait(); // Don't modify registers when other blit is in progress
	g_pCustom->bltcon0 = USEA|USEB|USEC|USED | MINTERM_COOKIE;
	g_pCustom->bltcon1 = 0;
	g_pCustom->bltafwm = 0xFFFF;
	g_pCustom->bltalwm = 0xFFFF;

	g_pCustom->bltamod = wTileModulo;
	g_pCustom->bltbmod = wTileModulo;
	g_pCustom->bltcmod = wTileModulo;
	g_pCustom->bltdmod = wDstModulo;

	g_pCustom->bltapt = (UBYTE*)((ULONG)g_pTilesetMask->Planes[0] + ulCurrOffs);
	g_pCustom->bltbpt = (UBYTE*)((ULONG)g_pTileset->Planes[0] + ulCurrOffs);
	g_pCustom->bltcpt = (UBYTE*)((ULONG)g_pTileset->Planes[0] + ulAboveOffs);
	g_pCustom->bltdpt = (UBYTE*)((ULONG)pBuffer->Planes[0] + ulDstOffs);
	g_pCustom->bltsize = (wHeight << 6) | uwWidthWords;

	// Draw remaining part of current tile, without side part
	wHeight = (MAP_TILE_SIZE - MAP_TILE_SIDE_HEIGHT) * DISPLAY_BPP;
	blitWait(); // Don't modify registers when other blit is in progress
	g_pCustom->bltcon0 = USEB|USED | MINTERM_B;
	g_pCustom->bltsize = (wHeight << 6) | uwWidthWords;

	// Draw side part of current tile masked with tile below
	// Mask is for below-tile (C), so minterm is reversed: D=AC+!AB
	wHeight = MAP_TILE_SIDE_HEIGHT * DISPLAY_BPP;
	ULONG ulBelowOffs = g_pTileset->BytesPerRow * pEntry->uwTileOffsetBelow;
	blitWait(); // Don't modify registers when other blit is in progress
	g_pCustom->bltcon0 = USEA|USEB|USEC|USED | MINTERM_REVERSE_COOKIE;
	g_pCustom->bltapt = (UBYTE*)((ULONG)g_pTilesetMask->Planes[0] + ulBelowOffs);
	g_pCustom->bltcpt = (UBYTE*)((ULONG)g_pTileset->Planes[0] + ulBelowOffs);
	g_pCustom->bltsize = (wHeight << 6) | uwWidthWords;

	if(--pEntry->ubDrawCount == 0) {
		if(++s_ubRedrawPopPos == TILE_QUEUE_SIZE) {
			s_ubRedrawPopPos = 0;
		}
	}
}

static UBYTE tileQueueHasSpace(void) {
	// UBYTE ubPopPos = s_ubRedrawPopPos;
	// if(ubPopPos <= s_ubRedrawPushPos) {
	// 	ubPopPos += TILE_QUEUE_SIZE;
	// }
	// return (ubPopPos - s_ubRedrawPushPos) > 2;
	return s_ubRedrawPopPos == s_ubRedrawPushPos;
}

static int onTileCrumbleSort(const void *pLhs, const void *pRhs) {
	const tTileCrumbleOrderEntry *pLhsCoord = (tTileCrumbleOrderEntry*)pLhs;
	const tTileCrumbleOrderEntry *pRhsCoord = (tTileCrumbleOrderEntry*)pRhs;
	return pRhsCoord->uwSortOrder - pLhsCoord->uwSortOrder;
}

static void tileCrumbleAddNext(void) {
	if(s_uwCurrentTileCrumble >= s_uwTileCount) {
		return;
	}

	tUbCoordYX sPos = {.uwYX = s_pTileCrumbleOrder[s_uwCurrentTileCrumble].sPos.uwYX};
	tTile *pTile = &s_pTilesXy[sPos.ubX][sPos.ubY];
	if(*pTile != TILE_FLOOR1) {
		return;
	}

	for(UBYTE i = 0; i < CRUMBLES_MAX; ++i) {
		if(!s_pCrumbleList[i].pTile) {
			s_pCrumbleList[i].pTile = pTile;
			s_pCrumbleList[i].ubCooldown = CRUMBLE_COOLDOWN;
			s_pCrumbleList[i].ubTileX = sPos.ubX;
			s_pCrumbleList[i].ubTileY = sPos.ubY;
			++s_ubActiveCrumbles;
			++s_uwCurrentTileCrumble;
			return;
		}
	}
}

//------------------------------------------------------------------- PUBLIC FNS

void tilesInit(void) {
	UBYTE ubMapIndex = randUwMax(&g_sRandManager, 2);
	s_ubSpawnCount = 0;
	s_uwTileCount = 0;
	for(UBYTE ubY = 0; ubY < TILE_HEIGHT; ++ubY) {
		for(UBYTE ubX = 0; ubX < TILE_WIDTH; ++ubX) {
			s_pTilesSourceXy[ubX][ubY] = (
				s_pMapPatternsYx[ubMapIndex][ubY][ubX] == '@' ? TILE_VOID : TILE_FLOOR1
			);

			if(s_pMapPatternsYx[ubMapIndex][ubY][ubX] != '@' && s_pMapPatternsYx[ubMapIndex][ubY][ubX] != '.') {
				s_pSpawns[s_ubSpawnCount++] = (tUwCoordYX){
					.uwX = ubX * MAP_TILE_SIZE + (MAP_TILE_SIZE / 2),
					.uwY = ubY * MAP_TILE_SIZE + (MAP_TILE_SIZE / 2)
				};
				logWrite(
					"Loaded spawn at %hhu,%hhu: %hu,%hu\n", ubX, ubY,
					s_pSpawns[s_ubSpawnCount-1].uwX, s_pSpawns[s_ubSpawnCount-1].uwY
				);
			}

			if(s_pTilesSourceXy[ubX][ubY] == TILE_FLOOR1) {
				s_pTileCrumbleOrder[s_uwTileCount++] = (tTileCrumbleOrderEntry){
					.sPos = {.ubX = ubX, .ubY = ubY},
					.uwSortOrder = (
						ABS(DISPLAY_WIDTH / 2 - ((ubX * MAP_TILE_SIZE) + HALF_TILE_SIZE)) +
						ABS(DISPLAY_HEIGHT / 2 - ((ubY * MAP_TILE_SIZE) + HALF_TILE_SIZE))
					)
				};
			}
		}
	}

	logWrite("Loaded %hhu spawn points\n", s_ubSpawnCount);

	qsort(
		s_pTileCrumbleOrder, s_uwTileCount, sizeof(s_pTileCrumbleOrder[0]),
		onTileCrumbleSort
	);
	logWrite("Tiles: %hu\n", s_uwTileCount);
}

void tilesReload(void) {
	s_uwCurrentTileCrumble = 0;
	s_ubCrumbleAddCooldown = CRUMBLE_ADD_COOLDOWN;

	const tTile *pBegin = &s_pTilesSourceXy[0][0];
	const tTile *pEnd = &s_pTilesSourceXy[TILE_WIDTH - 1][TILE_HEIGHT - 1 + 1];
	tTile *pDestination = &s_pTilesXy[0][0];
	for(const tTile *pTile = pBegin; pTile != pEnd; ++pTile) {
		*(pDestination++) = *pTile;
	}

	s_ubRedrawPushPos = 0;
	s_ubRedrawPopPos = 0;
	s_ubActiveCrumbles = 0;
	for(UBYTE i = 0; i < CRUMBLES_MAX; ++i) {
		s_pCrumbleList[i].pTile = 0;
	}
	tileQueueReset();
}

void tileCrumbleProcess(tBitMap *pBuffer) {
	if(--s_ubCrumbleAddCooldown == 0) {
		tileCrumbleAddNext();
		s_ubCrumbleAddCooldown = CRUMBLE_ADD_COOLDOWN;
	}

	tileQueueProcess(pBuffer);
	if(!tileQueueHasSpace()) {
		return;
	}

	tCrumble *pCrumble = &s_pCrumbleList[0];
	for(UBYTE i = 0; i < CRUMBLES_MAX; ++i, ++pCrumble) {
		if(!pCrumble->pTile) {
			continue;
		}
		if(--pCrumble->ubCooldown == 0) {
			--*pCrumble->pTile;

			if(!*pCrumble->pTile) {
				pCrumble->pTile = 0;
				ptplayerSfxPlay(g_pSfxCrumble, 2, 64, SFX_PRIORITY_CRUMBLE);
			}

			pCrumble->ubCooldown = CRUMBLE_COOLDOWN;
			tileQueueAddEntry(pCrumble->ubTileX, pCrumble->ubTileY, *pCrumble->pTile);
		}
	}
}

void tileShuffleSpawns(void) {
	for(UBYTE ubShuffle = 0; ubShuffle < 50; ++ubShuffle) {
		UBYTE ubA = randUwMax(&g_sRandManager, s_ubSpawnCount - 1);
		UBYTE ubB = randUwMax(&g_sRandManager, s_ubSpawnCount - 1);

		if(ubA == ubB) {
			continue;
		}

		tUwCoordYX sTmp = {.ulYX = s_pSpawns[ubA].ulYX};
		s_pSpawns[ubA].ulYX = s_pSpawns[ubB].ulYX;
		s_pSpawns[ubB].ulYX = sTmp.ulYX;
	}
}

const tUwCoordYX *tileGetSpawn(UBYTE ubIndex) {
	return &s_pSpawns[ubIndex];
}

void tilesDrawAllOn(tBitMap *pDestination) {
	for(UBYTE ubX = 0; ubX < TILE_WIDTH; ++ubX) {
		for(UBYTE ubY = 1; ubY < TILE_HEIGHT - 1; ++ubY) {
			// Draw side part of the tile above without mask
			blitCopyAligned(
				g_pTileset, 0, s_pTilesXy[ubX][ubY - 1] * MAP_FULL_TILE_HEIGHT + MAP_TILE_SIZE,
				pDestination, ubX * MAP_TILE_SIZE, ubY * MAP_TILE_SIZE, MAP_TILE_SIZE,
				MAP_TILE_SIDE_HEIGHT
			);
			// Draw current tile and its side part with mask
			blitCopyMask(
				g_pTileset, 0, s_pTilesXy[ubX][ubY] * MAP_FULL_TILE_HEIGHT, pDestination,
				ubX * MAP_TILE_SIZE, ubY * MAP_TILE_SIZE, MAP_TILE_SIZE,
				MAP_FULL_TILE_HEIGHT, g_pTilesetMask->Planes[0]
			);
			// Drawing tile beneath isn't needed here since all tiles are drawn in top to bottom order.
		}
	}
}

UBYTE tileIsSolid(UBYTE ubTileX, UBYTE ubTileY) {
	return s_pTilesXy[ubTileX][ubTileY] != TILE_VOID;
}
