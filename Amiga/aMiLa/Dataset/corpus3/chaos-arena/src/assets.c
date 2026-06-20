/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "assets.h"
#include <ace/macros.h>
#include "display.h"

tBitMap *g_pWarriorFrames;
tBitMap *g_pWarriorMasks;

tBitMap *g_pChaos;
tBitMap *g_pTileset;
tBitMap *g_pTilesetMask;

tFont *g_pFontBig;
tFont *g_pFontSmall;
tTextBitMap *g_pTextBitmap;

tBitMap *g_pCountdownMask;
tBitMap *g_pCountdownFrames;
tBitMap *g_pFightBitmap;
tBitMap *g_pFightMask;
tBitMap *g_pTitleBitmap;
tBitMap *g_pTitleMask;
tBitMap *g_pFramesThunder[2];
tBitMap *g_pFramesCross;

tPtplayerSfx *g_pSfxNo;
tPtplayerSfx *g_pSfxSwipes[2];
tPtplayerSfx *g_pSfxSwipeHit;
tPtplayerSfx *g_pSfxCrumble;
tPtplayerSfx *g_pSfxCountdown[3];
tPtplayerSfx *g_pSfxCountdownFight;
tPtplayerSfx *g_pSfxThunder;

tPtplayerMod *g_pModCombat;
tPtplayerMod *g_pModMenu;
tPtplayerSamplePack *g_pModSamples = 0;
static ULONG s_ulSampleSize;

void assetsGlobalCreate(void) {
	g_pWarriorFrames = bitmapCreateFromPath("data/warrior.bm", 0);
	g_pWarriorMasks = bitmapCreateFromPath("data/warrior_mask.bm", 0);
	g_pCountdownFrames = bitmapCreateFromPath("data/countdown.bm", 0);
	g_pCountdownMask = bitmapCreateFromPath("data/countdown_mask.bm", 0);
	g_pFightBitmap = bitmapCreateFromPath("data/fight.bm", 0);
	g_pFightMask = bitmapCreateFromPath("data/fight_mask.bm", 0);
	g_pTitleBitmap = bitmapCreateFromPath("data/title.bm", 0);
	g_pTitleMask = bitmapCreateFromPath("data/title_mask.bm", 0);

	g_pChaos = bitmapCreateFromPath("data/chaos.bm", 0);
	g_pTileset = bitmapCreateFromPath("data/tiles.bm", 0);
	g_pTilesetMask = bitmapCreateFromPath("data/tiles_mask.bm", 0);
	g_pFramesThunder[0] = bitmapCreateFromPath("data/thunder_0.bm", 0);
	g_pFramesThunder[1] = bitmapCreateFromPath("data/thunder_1.bm", 0);
	g_pFramesCross = bitmapCreateFromPath("data/cross.bm", 0);

	g_pFontBig = fontCreateFromPath("data/menu.fnt");
	g_pFontSmall = fontCreateFromPath("data/uni54.fnt");
	g_pTextBitmap = fontCreateTextBitMap(320, g_pFontBig->uwHeight);

	g_pSfxCrumble = ptplayerSfxCreateFromPath("data/crumble.sfx", 0);
	g_pSfxNo = ptplayerSfxCreateFromPath("data/noo.sfx", 0);
	g_pSfxSwipes[0] = ptplayerSfxCreateFromPath("data/swipe1.sfx", 0);
	g_pSfxSwipes[1] = ptplayerSfxCreateFromPath("data/swipe2.sfx", 0);
	g_pSfxSwipeHit = ptplayerSfxCreateFromPath("data/swipeHit.sfx", 0);
	g_pSfxCountdown[2] = ptplayerSfxCreateFromPath("data/cd3.sfx", 0);
	g_pSfxCountdown[1] = ptplayerSfxCreateFromPath("data/cd2.sfx", 0);
	g_pSfxCountdown[0] = ptplayerSfxCreateFromPath("data/cd1.sfx", 0);
	g_pSfxCountdownFight = ptplayerSfxCreateFromPath("data/cdfight.sfx", 0);
	g_pSfxThunder = ptplayerSfxCreateFromPath("data/thunder.sfx", 0);

	g_pModCombat = ptplayerModCreateFromPath("data/charena_game.mod");
	g_pModMenu = ptplayerModCreateFromPath("data/charena_menu.mod");

	g_pModSamples = ptplayerSampleDataCreateFromPath("data/samples.samplepack");
}

void assetsGlobalDestroy(void) {
	bitmapDestroy(g_pWarriorFrames);
	bitmapDestroy(g_pWarriorMasks);
	bitmapDestroy(g_pCountdownMask);
	bitmapDestroy(g_pCountdownFrames);
	bitmapDestroy(g_pFightBitmap);
	bitmapDestroy(g_pFightMask);
	bitmapDestroy(g_pTitleBitmap);
	bitmapDestroy(g_pTitleMask);

	bitmapDestroy(g_pChaos);
	bitmapDestroy(g_pTileset);
	bitmapDestroy(g_pTilesetMask);
	bitmapDestroy(g_pFramesThunder[0]);
	bitmapDestroy(g_pFramesThunder[1]);
	bitmapDestroy(g_pFramesCross);

	fontDestroy(g_pFontBig);
	fontDestroy(g_pFontSmall);
	fontDestroyTextBitMap(g_pTextBitmap);

	ptplayerSfxDestroy(g_pSfxCrumble);
	ptplayerSfxDestroy(g_pSfxNo);
	ptplayerSfxDestroy(g_pSfxSwipes[0]);
	ptplayerSfxDestroy(g_pSfxSwipes[1]);
	ptplayerSfxDestroy(g_pSfxSwipeHit);
	ptplayerSfxDestroy(g_pSfxCountdown[2]);
	ptplayerSfxDestroy(g_pSfxCountdown[1]);
	ptplayerSfxDestroy(g_pSfxCountdown[0]);
	ptplayerSfxDestroy(g_pSfxCountdownFight);
	ptplayerSfxDestroy(g_pSfxThunder);

	ptplayerModDestroy(g_pModCombat);
	ptplayerModDestroy(g_pModMenu);
	memFree(g_pModSamples, s_ulSampleSize);
}
