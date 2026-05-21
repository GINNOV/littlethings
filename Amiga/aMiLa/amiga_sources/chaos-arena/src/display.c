/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "display.h"
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/system.h>
#include <ace/managers/sprite.h>
#include <ace/utils/palette.h>
#include "tile.h"
#include "debug.h"

#define GAME_COLORS (1 << DISPLAY_BPP)
#define FADE_SPEED 50

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;
static UWORD s_pPaletteThunder[8];
static tFade *s_pFade;
static UWORD s_pPaletteRef[GAME_COLORS];

void displayCreate(void) {
	// Dear reader - don't EVER do one global display manager, unless you're
	// 500% sure you won't need different BPP or copperlist mode along the way.
	UWORD uwDisplayCopperInstructions = simpleBufferGetRawCopperlistInstructionCount(DISPLAY_BPP);
	UWORD uwSpriteCopperInstructions = 8 * 2;
	s_pView = viewCreate(0,
		TAG_VIEW_COPLIST_MODE, VIEW_COPLIST_MODE_RAW,
		TAG_VIEW_COPLIST_RAW_COUNT, uwDisplayCopperInstructions + uwSpriteCopperInstructions + 2,
		TAG_VIEW_GLOBAL_PALETTE, 1,
	TAG_DONE);

	s_pVp = vPortCreate(0,
		TAG_VPORT_BPP, DISPLAY_BPP,
		TAG_VPORT_VIEW, s_pView,
	TAG_DONE);

	s_pVpManager = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
		TAG_SIMPLEBUFFER_IS_DBLBUF, 1,
		TAG_SIMPLEBUFFER_USE_X_SCROLLING, 0,
		TAG_SIMPLEBUFFER_BOUND_WIDTH, DISPLAY_WIDTH,
		TAG_SIMPLEBUFFER_BOUND_HEIGHT, DISPLAY_HEIGHT,
		TAG_SIMPLEBUFFER_VPORT, s_pVp,
		TAG_SIMPLEBUFFER_COPLIST_OFFSET, uwSpriteCopperInstructions,
	TAG_DONE);

	cameraSetCoord(
		s_pVpManager->pCamera, DISPLAY_MARGIN_SIZE, DISPLAY_MARGIN_SIZE
	);

	paletteLoadFromPath("data/palette.plt", s_pPaletteRef, GAME_COLORS);
	paletteLoadFromPath("data/thunder.plt", s_pPaletteThunder, ARRAY_SIZE(s_pPaletteThunder));
	s_pVp->pPalette[16] = 0xF0F; // transparent
	s_pVp->pPalette[17] = 0xFF0; // unused
	s_pVp->pPalette[18] = 0xFF0; // unused
	s_pVp->pPalette[19] = s_pPaletteThunder[0];
	displaySetThunderColor(0);
	s_pVp->pPalette[20] = 0xF0F; // transparent
	s_pVp->pPalette[21] = 0x511;
	s_pVp->pPalette[22] = 0xA00;
	s_pVp->pPalette[23] = 0xF11;

	s_pFade = fadeCreate(s_pView, s_pPaletteRef, GAME_COLORS);
	fadeStart(s_pFade, FADE_STATE_IN, FADE_SPEED, 1, 0);

	tilesDrawAllOn(s_pVpManager->pBack);
	tilesDrawAllOn(s_pVpManager->pFront);
	debugInit(s_pVp->pPalette[0]);
	spriteManagerCreate(s_pView, 0);
	systemSetDmaBit(DMAB_SPRITE, 1);
}

void displayFadeStart(UBYTE isIn, void (*cbOnFadeDone)(void)) {
	fadeStart(s_pFade, isIn ? FADE_STATE_IN : FADE_STATE_OUT, FADE_SPEED, 1, cbOnFadeDone);
}

tFadeState displayFadeProcess(void) {
	tFadeState eState = fadeProcess(s_pFade);
	return eState;
}

void displayDestroy(void) {
	systemSetDmaBit(DMAB_SPRITE, 0);
	spriteManagerDestroy();
	fadeDestroy(s_pFade);
	viewDestroy(s_pView);
}

void displayProcess(void) {
	spriteProcessChannel(DISPLAY_SPRITE_CHANNEL_CURSOR);
	spriteProcessChannel(DISPLAY_SPRITE_CHANNEL_THUNDER);
	viewProcessManagers(s_pView);
	copProcessBlocks();
	debugReset();
	systemIdleBegin();
	vPortWaitForEnd(s_pVp);
	systemIdleEnd();
}

void displayOn(void) {
	viewLoad(s_pView);
}

void displayOff(void) {
	viewLoad(0);
}

void displaySetThunderColor(UBYTE ubColorIndex) {
	g_pCustom->color[19] = s_pPaletteThunder[ubColorIndex];
}

tSimpleBufferManager *displayGetManager(void) {
	return s_pVpManager;
}
