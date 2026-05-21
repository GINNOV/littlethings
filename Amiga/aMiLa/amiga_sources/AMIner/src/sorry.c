/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "sorry.h"
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/system.h>
#include <ace/utils/font.h>
#include <ace/utils/palette.h>
#include "assets.h"
#include "logo.h"

#define RGB(r,g,b) ((((r) >> 4) << 8) | (((g) >> 4) << 4) | (((b) >> 4) << 0))

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pBfr;
static UBYTE s_isWriteProtected;


void sorryReset(UBYTE isWriteProtected) {
	s_isWriteProtected = isWriteProtected;
}

static void sorryGsCreate(void) {
logBlockBegin("logoGsCreate()");

	s_pView = viewCreate(0,
		TAG_VIEW_GLOBAL_PALETTE, 1,
	TAG_END);

	s_pVp = vPortCreate(0,
		TAG_VPORT_BPP, 5,
		TAG_VPORT_VIEW, s_pView,
	TAG_END);
	paletteLoadFromFd(GET_SUBFILE_PREFIX("aminer.plt"), s_pVp->pPalette, 1 << s_pVp->ubBpp);
	// Same colors as logo
	s_pVp->pPalette[0] = 0x0000;
	s_pVp->pPalette[27] = RGB(51, 34, 0);
	s_pVp->pPalette[28] = RGB(102, 68, 0);
	s_pVp->pPalette[29] = RGB(153, 102, 17);
	s_pVp->pPalette[30] = RGB(204, 136, 34);
	s_pVp->pPalette[31] = RGB(255, 170, 51);


	s_pBfr = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
		TAG_SIMPLEBUFFER_VPORT, s_pVp,
		TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
	TAG_END);

	tBitMap *pBitMap = bitmapCreateFromFd(GET_SUBFILE_PREFIX("lang_select.bm"), 0);
	blitCopy(
		pBitMap, 0, 64, s_pBfr->pBack, (320 - 64) / 2, (256 - 64) / 2,
		64, 64, MINTERM_COPY
	);
	bitmapDestroy(pBitMap);

	tTextBitMap *pTextBuffer = fontCreateTextBitMap(320, g_pFont->uwHeight);
	if(s_isWriteProtected) {
		fontDrawStr(
			g_pFont, s_pBfr->pBack, 160, 128 - 32 - 12,
			"Kiedy p\x82""aczesz (bo nie mo\x80""esz zapisa\x83""), On to widzi",
			18, FONT_BOTTOM | FONT_HCENTER | FONT_LAZY, pTextBuffer
		);
		fontDrawStr(
			g_pFont, s_pBfr->pBack, 160, 128 + 32 + 12,
			"Disk write protected, unlock please!",
			14, FONT_TOP | FONT_HCENTER | FONT_LAZY, pTextBuffer
		);
	}
	else {
		fontDrawStr(
			g_pFont, s_pBfr->pBack, 160, 128 - 32 - 12,
			"Kiedy p\x82""aczesz (bo nie masz ramu), On to widzi",
			18, FONT_BOTTOM | FONT_HCENTER | FONT_LAZY, pTextBuffer
		);
		fontDrawStr(
			g_pFont, s_pBfr->pBack, 160, 128 + 32 + 12,
			"Min. 1MB CHIP RAM + 1MB RAM, sorry Ci\x84 bardzo!",
			14, FONT_TOP | FONT_HCENTER | FONT_LAZY, pTextBuffer
		);
	}
	fontDrawStr(
		g_pFont, s_pBfr->pBack, 160, 128 + 32 + 24,
		"Press ENTER, SPACE, FIRE or ESCAPE...",
		14, FONT_TOP | FONT_HCENTER | FONT_LAZY, pTextBuffer
	);
	fontDestroyTextBitMap(pTextBuffer);

	systemUnuse();
	viewLoad(s_pView);
}

static void sorryGsLoop(void) {
	if(
		keyUse(KEY_RETURN) || keyUse(KEY_NUMENTER) || keyUse(KEY_ESCAPE) ||
		keyUse(KEY_SPACE) || joyUse(JOY1_FIRE)
	) {
		statePopAll(g_pGameStateManager);
		return;
	}
	vPortWaitForEnd(s_pVp);
}

static void sorryGsDestroy(void) {
	systemUse();
	viewDestroy(s_pView);
}

tState g_sStateSorry = {
	.cbCreate = sorryGsCreate, .cbLoop = sorryGsLoop, .cbDestroy = sorryGsDestroy
};
