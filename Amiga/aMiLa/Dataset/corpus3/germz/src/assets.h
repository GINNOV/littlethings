/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_ASSETS_H
#define GERMZ_ASSETS_H

#include <ace/utils/font.h>
#include <ace/managers/ptplayer.h>
#include "map.h"

#define BLOB_COLOR_COUNT 5
#define BLOB_FRAME_COUNT 9

typedef enum tAssetMods {
	ASSET_MOD_MENU,
	ASSET_MOD_GAME1,
	ASSET_MOD_GAME2,
	ASSET_MOD_GAME3,
	ASSET_MOD_GAME_COUNT,
	ASSET_MOD_INTRO = ASSET_MOD_GAME_COUNT,
	ASSET_MOD_OUTRO,
	ASSET_MOD_COUNT
} tAssetMods;

typedef struct tNodeModsBase {
	UBYTE ubChargeRate;
	UBYTE ubChargeRateNeutral;
	WORD wCapacity;
} tNodeModsBase;

typedef struct tDefs {
	tNodeModsBase sBaseMods;
} tDefs;

/**
 * @brief Everything that haven't found its place everywhere else.
 * All those things need to be loaded constantly for game to function properly.
 */

void assetsGlobalCreate(void);

void assetsGlobalDestroy(void);

/**
 * @brief Loads assets from files.
 */
void assetsGameCreate(void);

/**
 * @brief Frees loaded assets.
 */
void assetsGameDestroy(void);

// Global assets
extern tPtplayerMod *g_pMods[ASSET_MOD_COUNT];
extern UWORD *g_pModSamples;
extern tFont *g_pFontSmall, *g_pFontBig;
extern tTextBitMap *g_pTextBitmap;
extern tBitMap *g_pFrameDisplay;
extern tDefs g_sDefs;
extern tBitMap *g_pCursors, *g_pCursorsMask;
extern tBitMap *g_pBmHudTarget;

// Game assets
extern tBitMap *g_pBmBlobs[BLOB_COLOR_COUNT], *g_pBmBlobMask;
extern tBitMap *g_pBmLinks, *g_pBmLinksMask;
extern tPtplayerSfx *g_pSfxPlep1, *g_pSfxPlep2;

#endif // GERMZ_GAME_ASSETS_H
