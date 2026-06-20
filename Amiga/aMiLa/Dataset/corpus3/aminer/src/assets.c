/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "assets.h"

tPtplayerSfx *g_pSfxDrill;
tPtplayerSfx *g_pSfxOre;
tPtplayerSfx *g_pSfxPenalty;
tPtplayerSfx *g_pSfxFlyLoop;
tPtplayerSfx *g_pSfxThud;
tPtplayerSfx *g_pSfxGate;
tPtplayerSfx *g_pSfxRune;
tPtplayerSfx *g_pSfxQuake;

tPtplayerMod *g_pGameMods[ASSETS_GAME_MOD_COUNT];
tPtplayerMod *g_pMenuMod;
tPtplayerSamplePack *g_pModSampleData;

tBitMap *g_pBombMarker;
tBitMap *g_pBombMarkerMask;
tBitMap *g_pTileOverlays;
tBitMap *g_pTileOverlayMasks;
tFont *g_pFont;

#if defined(USE_PAK_FILE)
tPakFile *g_pPakFile;
#endif

void assetsAudioCreate(void) {
	g_pSfxThud = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/thud.sfx"), 1);
	g_pSfxFlyLoop = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/fly_loop.sfx"), 1);
	g_pSfxDrill = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/drill1.sfx"), 1);
	g_pSfxOre = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/ore2.sfx"), 1);
	g_pSfxPenalty = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/penalty.sfx"), 1);
	g_pSfxGate = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/gate_opened.sfx"), 1);
	g_pSfxRune = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/gate_rune.sfx"), 1);
	g_pSfxQuake = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/gate_quake.sfx"), 1);

	for(UBYTE i = 0; i < ASSETS_GAME_MOD_COUNT; ++i) {
		char szModPath[30];
		sprintf(szModPath, SUBFILE_PREFIX "music/game%hhu.mod", i);
		g_pGameMods[i] = ptplayerModCreateFromFd(GET_SUBFILE(szModPath));
	}
	g_pMenuMod = ptplayerModCreateFromFd(GET_SUBFILE_PREFIX("music/menu.mod"));
	g_pModSampleData = ptplayerSampleDataCreateFromFd(GET_SUBFILE_PREFIX("music/samples.samplepack"));
}

void assetsAudioDestroy(void) {
	ptplayerSfxDestroy(g_pSfxDrill);
	ptplayerSfxDestroy(g_pSfxFlyLoop);
	ptplayerSfxDestroy(g_pSfxThud);
	ptplayerSfxDestroy(g_pSfxOre);
	ptplayerSfxDestroy(g_pSfxPenalty);
	ptplayerSfxDestroy(g_pSfxGate);
	ptplayerSfxDestroy(g_pSfxRune);
	ptplayerSfxDestroy(g_pSfxQuake);

	for(UBYTE i = 0; i < ASSETS_GAME_MOD_COUNT; ++i) {
		ptplayerModDestroy(g_pGameMods[i]);
	}
	ptplayerModDestroy(g_pMenuMod);
	ptplayerSamplePackDestroy(g_pModSampleData);
}

void assetsMarkersCreate(void) {
	g_pBombMarker = bitmapCreateFromFd(GET_SUBFILE_PREFIX("bomb_marker.bm"), 0);
	g_pBombMarkerMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("bomb_marker_mask.bm"), 0);
}

void assetsMarkersDestroy(void) {
	bitmapDestroy(g_pBombMarker);
	bitmapDestroy(g_pBombMarkerMask);
}

void assetsTileOverlayCreate(void) {
	g_pTileOverlays = bitmapCreateFromFd(GET_SUBFILE_PREFIX("tiles_overlay.bm"), 0);
	g_pTileOverlayMasks = bitmapCreateFromFd(GET_SUBFILE_PREFIX("tiles_overlay_masks.bm"), 0);
}

void assetsTileOverlayDestroy(void) {
	bitmapDestroy(g_pTileOverlays);
	bitmapDestroy(g_pTileOverlayMasks);
}
