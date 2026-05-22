/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "assets.h"
#include "gui/config.h"
#include <ace/managers/system.h>
#include <ace/utils/file.h>
#include <json/json.h>

static ULONG s_ulSampleSize;
UWORD *g_pModSamples;

void assetsGlobalCreate(void) {
	// Defs
	tJson *pJsonDefs = jsonCreate("data/defs.json");

	UWORD uwTokJson = jsonGetDom(pJsonDefs, "baseMods.ubChargeRate");
	ULONG ulVal = jsonTokToUlong(pJsonDefs, uwTokJson);
	g_sDefs.sBaseMods.ubChargeRate = ulVal;

	uwTokJson = jsonGetDom(pJsonDefs, "baseMods.ubChargeRateNeutral");
	ulVal = jsonTokToUlong(pJsonDefs, uwTokJson);
	g_sDefs.sBaseMods.ubChargeRateNeutral = ulVal;

	uwTokJson = jsonGetDom(pJsonDefs, "baseMods.wCapacity");
	ulVal = jsonTokToUlong(pJsonDefs, uwTokJson);
	g_sDefs.sBaseMods.wCapacity = ulVal;

	jsonDestroy(pJsonDefs);

	// Mods
	for(UBYTE i = 0; i < ASSET_MOD_COUNT; ++i) {
		char szPath[20];
		sprintf(szPath, "data/germz%hhu.mod", (UBYTE)(i + 1));
		g_pMods[i] = ptplayerModCreate(szPath);
	}
	s_ulSampleSize = fileGetSize("data/samples.samplepack");
	g_pModSamples = memAllocChip(s_ulSampleSize);
	tFile *pFileSamples = fileOpen("data/samples.samplepack", "rb");
	fileRead(pFileSamples, g_pModSamples, s_ulSampleSize);
	fileClose(pFileSamples);

	// Font
	g_pFontSmall = fontCreate("data/uni54.fnt");
	g_pFontBig = fontCreate("data/germz.fnt");
	g_pTextBitmap = fontCreateTextBitMap(320, g_pFontBig->uwHeight);

	// Bitmaps
	g_pFrameDisplay = bitmapCreateFromFile("data/display.bm", 0);

	// Bitmaps for howto submoenu
	g_pBmHudTarget = bitmapCreateFromFile("data/hud_target.bm", 0);
	g_pBmBlobs[0] = bitmapCreateFromFile("data/blob0.bm", 0);
	g_pBmBlobMask = bitmapCreateFromFile("data/blob_mask.bm", 0);
	g_pCursors = bitmapCreateFromFile("data/cursors.bm", 0);
	g_pCursorsMask = bitmapCreateFromFile("data/cursors_mask.bm", 0);

	tGuiConfig *pConfig = guiGetConfig();
	pConfig->ubColorLight = 20 >> 1;
	pConfig->ubColorDark = 20 >> 1;
	pConfig->ubColorFill = 20 >> 1;
	pConfig->ubColorText = 18 >> 1;
}

void assetsGlobalDestroy(void) {
	// Mods
	for(UBYTE i = ASSET_MOD_COUNT; i--;) {
		ptplayerModDestroy(g_pMods[i]);
	}
	memFree(g_pModSamples, s_ulSampleSize);

	// Font
	fontDestroy(g_pFontSmall);
	fontDestroy(g_pFontBig);
	fontDestroyTextBitMap(g_pTextBitmap);

	// Bitmaps
	bitmapDestroy(g_pFrameDisplay);
	bitmapDestroy(g_pBmHudTarget);
	bitmapDestroy(g_pBmBlobs[0]);
	bitmapDestroy(g_pBmBlobMask);
	bitmapDestroy(g_pCursors);
	bitmapDestroy(g_pCursorsMask);
}

void assetsGameCreate(void) {
	systemUse();
	// Blob gfx
	for(UBYTE i = 1; i < BLOB_COLOR_COUNT; ++i) {
		char szName[15];
		sprintf(szName, "data/blob%hhu.bm", i);
		g_pBmBlobs[i] = bitmapCreateFromFile(szName, 0);
	}

	// Blob links
	g_pBmLinks = bitmapCreateFromFile("data/links.bm", 0);
	g_pBmLinksMask = bitmapCreateFromFile("data/links_mask.bm", 0);
	systemUnuse();

	// Sounds
	g_pSfxPlep1 = ptplayerSfxCreateFromFile("data/sfx/plep1.sfx");
	g_pSfxPlep2 = ptplayerSfxCreateFromFile("data/sfx/plep2.sfx");
}

void assetsGameDestroy(void) {
	systemUse();
	logBlockBegin("gameAssetsDestroy()");
	// Blob gfx
	for(UBYTE i = 1; i < BLOB_COLOR_COUNT; ++i) {
		bitmapDestroy(g_pBmBlobs[i]);
	}

	// Blob links
	bitmapDestroy(g_pBmLinks);
	bitmapDestroy(g_pBmLinksMask);

	// Sounds
	ptplayerSfxDestroy(g_pSfxPlep1);
	ptplayerSfxDestroy(g_pSfxPlep2);

	systemUnuse();
	logBlockEnd("gameAssetsDestroy()");
}

// Global assets
tPtplayerMod *g_pMods[ASSET_MOD_COUNT];
tFont *g_pFontSmall, *g_pFontBig;
tTextBitMap *g_pTextBitmap;
tBitMap *g_pFrameDisplay;
tDefs g_sDefs;
tBitMap *g_pCursors, *g_pCursorsMask;
tBitMap *g_pBmHudTarget;

// Game assets
tBitMap *g_pBmBlobs[BLOB_COLOR_COUNT], *g_pBmBlobMask;
tBitMap *g_pBmLinks, *g_pBmLinksMask;
tPtplayerSfx *g_pSfxPlep1, *g_pSfxPlep2;
