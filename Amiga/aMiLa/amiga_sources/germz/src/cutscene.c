/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/system.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/utils/palette.h>
#include <ace/generic/screen.h>
#include "fade.h"
#include "germz.h"
#include "assets.h"
#include "color.h"
#include "music.h"
#include "menu.h"

#define SLIDES_MAX 10
#define LINES_PER_SLIDE_MAX 6
#define SLIDE_SIZE 128
#define SLIDE_POS_X ((SCREEN_PAL_WIDTH - SLIDE_SIZE) / 2)
#define SLIDE_POS_Y ((SCREEN_PAL_HEIGHT - SLIDE_SIZE) / 4)
#define TEXT_POS_X (SCREEN_PAL_WIDTH / 2)
#define TEXT_POS_Y (SLIDE_POS_Y + SLIDE_SIZE + 16)
#define TEXT_FINALE_POS_Y (SCREEN_PAL_HEIGHT / 2)
#define TEXT_LINE_HEIGHT (10 + 2)
#define SLIDE_ANIM_COLS 2
#define COLOR_TEXT COLOR_P3_BRIGHT

#define GRAYSCALE(ubValue) ((ubValue) << 8 | (ubValue) << 4 | (ubValue))

typedef struct tSlide {
	tBitMap *pBitmap;
	UWORD pPalette[32];
} tSlide;

static const char *s_pLinesIntro[][LINES_PER_SLIDE_MAX] = {
	{
		"The great entity created its offspring",
		"and scattered them across the universe",
		0,
	},
	{
		"They travelled through space and eons of time.",
		"Some of them perished on barren rocks",
		"failing to find any nutrition,",
		"but some survived through hibernation",
		0,
	},
	{
		"The more resilient ones have found their way",
		"to colorful planets full of life",
		0,
	},
	{
		"Decimated by the atmosphere,",
		"only strongest survived the landing",
		0,
	},
	{
		"Ignored by most,",
		"but welcomed by some curious inhabitants",
		0,
	},
	{
		"Revived by their science",
		"and waiting for a chance...",
		0,
	},
	{
		"You finally seize the opportunity",
		"and enter the unwilling host",
		0,
	},
	{
		"Fight through its defenses",
		"and take over the whole organism!",
		0,
	},
};

static const char *s_pLinesOutro[][LINES_PER_SLIDE_MAX] = {
	{
		"Your struggle only increased your power",
		"and allowed you to conquer the host",
		0,
	},
	{
		"You took over more and more",
		"until you've conquered all",
		"and soon the whole planet",
		"sung the hymn to your creator",
		0,
	},
	{
		"L' nog c' gnaiih",
		"C' l' uln ymg'",
		"C' ymg' ilyaa",
		"Nog ng c' na'ah'ehye",
		0,
	},
	{
		"Your call was answered",
		"and the gate has opened",
		"your Creator arrived",
		"and claimed the sacrifice",
		"of all planet's life",
		0,
	},
};

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pBuffer;
static tFade *s_pFade;
static UBYTE s_ubSlideCount, s_ubCurrentSlide, s_ubCurrentLine;
static UBYTE s_isOutro;
static UBYTE s_isFinale;
static tState *s_pNextState;
static UWORD s_uwFontColorVal;
static UBYTE s_ubFadeStep;

static tSlide s_pSlides[SLIDES_MAX];

static tCopBlock *s_pBlockAboveLine, *s_pBlockBelowLine, *s_pBlockAfterLines;

static const char *getLine(UBYTE ubSlide, UBYTE ubLine) {
	const char *pLine = (s_isOutro ? s_pLinesOutro : s_pLinesIntro)[ubSlide][ubLine];
	return pLine;
}

static void drawSlide(void) {
	// Draw slide
	blitCopyAligned(
		s_pSlides[s_ubCurrentSlide].pBitmap, 0, 0, s_pBuffer->pBack,
		SLIDE_POS_X, SLIDE_POS_Y, SLIDE_SIZE, SLIDE_SIZE
	);

	// Erase old text
	blitRect(
		s_pBuffer->pBack, 0, TEXT_POS_Y,
		SCREEN_PAL_WIDTH, LINES_PER_SLIDE_MAX * TEXT_LINE_HEIGHT, 0
	);

	// Load new palette
	fadeChangeRefPalette(s_pFade, s_pSlides[s_ubCurrentSlide].pPalette, 32);

	// Update the color used by copper to match the palette
	s_pBlockAfterLines->pCmds[0].sMove.bfValue = s_pSlides[s_ubCurrentSlide].pPalette[COLOR_TEXT];
}

static void initSlideText(void) {
	// Reset copblocks
	s_ubCurrentLine = 0;
	copBlockWait(
		s_pView->pCopList, s_pBlockAboveLine, 0,
		s_pView->ubPosY + TEXT_POS_Y + TEXT_LINE_HEIGHT * s_ubCurrentLine
	);
	copBlockWait(
		s_pView->pCopList, s_pBlockBelowLine, 0,
		s_pView->ubPosY + TEXT_POS_Y + TEXT_LINE_HEIGHT * (s_ubCurrentLine + 1) - 1
	);
	s_pBlockAboveLine->uwCurrCount = 0;
	copMove(
		s_pView->pCopList, s_pBlockAboveLine,
		&g_pCustom->color[COLOR_TEXT], 0x000
	);
	copProcessBlocks();
	vPortWaitForEnd(s_pVp);
	s_ubFadeStep = 0;

	// Draw text
	while(getLine(s_ubCurrentSlide, s_ubCurrentLine)) {
		const char *szLine = getLine(s_ubCurrentSlide, s_ubCurrentLine);
		// Draw next portion of text
		fontDrawStr(
			g_pFontSmall, s_pBuffer->pBack, TEXT_POS_X,
			TEXT_POS_Y + TEXT_LINE_HEIGHT * s_ubCurrentLine, szLine,
			COLOR_TEXT, FONT_LAZY | FONT_HCENTER, g_pTextBitmap
		);
		++s_ubCurrentLine;
	}

	s_ubCurrentLine = 0;
}

static void onFadeIn(void) {
	copBlockEnable(s_pView->pCopList, s_pBlockAboveLine);
	copBlockEnable(s_pView->pCopList, s_pBlockBelowLine);
	copBlockEnable(s_pView->pCopList, s_pBlockAfterLines);
	initSlideText();
}

static void cutsceneGsCreate(void) {
	s_pView = viewCreate(0,
		TAG_VIEW_GLOBAL_PALETTE, 1,
	TAG_END);

	s_pVp = vPortCreate(0,
		TAG_VPORT_BPP, 5,
		TAG_VPORT_VIEW, s_pView,
	TAG_END);

	s_pBuffer = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
		TAG_SIMPLEBUFFER_VPORT, s_pVp,
		TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
	TAG_END);


	// Load palette
	UWORD pPalette[32];
	paletteLoad("data/germz.plt", pPalette, 32);
	s_pFade = fadeCreate(s_pView, pPalette, 32);

	s_uwFontColorVal = pPalette[COLOR_TEXT];
	s_pBlockAboveLine = copBlockCreate(s_pView->pCopList, 1, 0, 0);
	s_pBlockBelowLine = copBlockCreate(s_pView->pCopList, 1, 0, 0);
	s_pBlockAfterLines = copBlockCreate(
		s_pView->pCopList, 1, 0,
		s_pView->ubPosY + TEXT_POS_Y + (LINES_PER_SLIDE_MAX - 1) * TEXT_LINE_HEIGHT
	);
	copMove(
		s_pView->pCopList, s_pBlockBelowLine,
		&g_pCustom->color[COLOR_TEXT], 0x000
	);
	copMove(
		s_pView->pCopList, s_pBlockAfterLines,
		&g_pCustom->color[COLOR_TEXT], s_uwFontColorVal
	);
	copBlockDisable(s_pView->pCopList, s_pBlockAboveLine);
	copBlockDisable(s_pView->pCopList, s_pBlockBelowLine);
	copBlockDisable(s_pView->pCopList, s_pBlockAfterLines);

	// Load slides
	char szPath[30];
	s_ubSlideCount = 0;
	for(s_ubSlideCount = 0; s_ubSlideCount < 10; ++s_ubSlideCount) {
		sprintf(szPath, "data/%s/%hhu.bm", s_isOutro ? "outro" : "intro", s_ubSlideCount);
		s_pSlides[s_ubSlideCount].pBitmap = bitmapCreateFromFile(szPath, 0);
		if(!s_pSlides[s_ubSlideCount].pBitmap) {
			break;
		}
		sprintf(szPath, "data/%s/%hhu.plt", s_isOutro ? "outro" : "intro", s_ubSlideCount);
		paletteLoad(szPath, s_pSlides[s_ubSlideCount].pPalette, 32);
		s_pSlides[s_ubSlideCount].pPalette[COLOR_TEXT] = s_uwFontColorVal;
	}

	systemUnuse();
	musicLoadPreset(s_isOutro ? MUSIC_PRESET_OUTRO : MUSIC_PRESET_INTRO);

	// Draw first slide
	drawSlide();
	fadeSet(s_pFade, FADE_STATE_IN, 50, 1, onFadeIn);
	viewLoad(s_pView);
}

static void veryNastyOutroHack() {
	// I'm going to hell for this

	// clear slide
	blitRect(
		s_pBuffer->pBack, SLIDE_POS_X, SLIDE_POS_Y, SLIDE_SIZE, SLIDE_SIZE, 0
	);

	// Erase old text
	blitRect(
		s_pBuffer->pBack, 0, TEXT_POS_Y,
		SCREEN_PAL_WIDTH, LINES_PER_SLIDE_MAX * TEXT_LINE_HEIGHT, 0
	);

	// Draw new text
	static const char *szLines[] = {
		"SACRIFICE",
		"TO",
		"YOG SOTHOTH"
	};

	copBlockEnable(s_pView->pCopList, s_pBlockAboveLine);
	copBlockEnable(s_pView->pCopList, s_pBlockBelowLine);
	copBlockEnable(s_pView->pCopList, s_pBlockAfterLines);

	// Reset copblocks
	s_ubCurrentLine = 0;
	copBlockWait(
		s_pView->pCopList, s_pBlockAboveLine, 0,
		s_pView->ubPosY + TEXT_FINALE_POS_Y + TEXT_LINE_HEIGHT * 2 * (s_ubCurrentLine - 1)
	);
	copBlockWait(
		s_pView->pCopList, s_pBlockBelowLine, 0,
		s_pView->ubPosY + TEXT_FINALE_POS_Y + TEXT_LINE_HEIGHT * 2 * (s_ubCurrentLine - 1 + 1) - 1
	);
	s_pBlockAboveLine->uwCurrCount = 0;
	copMove(
		s_pView->pCopList, s_pBlockAboveLine,
		&g_pCustom->color[COLOR_TEXT], 0x000
	);
	copProcessBlocks();
	vPortWaitForEnd(s_pVp);
	s_ubFadeStep = 0;

	for(BYTE i = 0; i < 3; ++i) {
		fontDrawStr(
			g_pFontSmall, s_pBuffer->pBack, TEXT_POS_X,
			TEXT_FINALE_POS_Y + 2 * TEXT_LINE_HEIGHT * (i - 1), szLines[i],
			COLOR_TEXT, FONT_LAZY | FONT_HCENTER, g_pTextBitmap
		);
	}

	fadeChangeRefPalette(s_pFade, s_pSlides[0].pPalette, 32);
}

static void onCutsceneFadeOut(void) {
		if(s_isOutro && !s_isFinale) {
			s_isFinale = 1;
			menuStartWithCredits();
			veryNastyOutroHack();
			return;
		}

	// Pop to previous state or change to next state
	if(!s_pNextState) {
		statePop(g_pStateMachineGame);
	}
	else {
		stateChange(g_pStateMachineGame, s_pNextState);
	}
}

static void onFadeOutSlide(void) {
	drawSlide();
	fadeSet(s_pFade, FADE_STATE_IN, 15, 0, onFadeIn);
}

static void cutsceneLoopFinale(void) {
	tFadeState eFadeState = fadeProcess(s_pFade);
	if(s_pVp) {
		vPortWaitForEnd(s_pVp);
	}
	if(eFadeState != FADE_STATE_IDLE) {
		return;
	}

	UBYTE isEnabled34 = joyIsParallelEnabled();
	if(s_ubFadeStep <= 0x10) {
		// Process text fade-in
		// Increment color
		s_pBlockAboveLine->uwCurrCount = 0;
		copMove(
			s_pView->pCopList, s_pBlockAboveLine, &g_pCustom->color[COLOR_TEXT],
			s_ubFadeStep < 0x10 ? GRAYSCALE(s_ubFadeStep) : s_uwFontColorVal
		);
		++s_ubFadeStep;

		// Refresh copperlist
		copProcessBlocks();
	}
	else if(s_ubCurrentLine < 3) {
		// Start fade-in for next line
		++s_ubCurrentLine;
		if(s_ubCurrentLine < 3) {
			// Draw next portion of text - move copBlocks and reset fadeStep
			copBlockWait(
				s_pView->pCopList, s_pBlockAboveLine, 0,
				s_pView->ubPosY + TEXT_FINALE_POS_Y + TEXT_LINE_HEIGHT * 2 * (s_ubCurrentLine - 1)
			);
			copBlockWait(
				s_pView->pCopList, s_pBlockBelowLine, 0,
				s_pView->ubPosY + TEXT_FINALE_POS_Y + TEXT_LINE_HEIGHT * 2 * (s_ubCurrentLine - 1 + 1) - 1
			);
			s_pBlockAboveLine->uwCurrCount = 0;
			copMove(
				s_pView->pCopList, s_pBlockAboveLine,
				&g_pCustom->color[COLOR_TEXT], 0x000
			);
			copProcessBlocks();
			s_ubFadeStep = 0;
			for(UBYTE i = 0; i < 50; ++i) {
				vPortWaitForEnd(s_pVp);
			}
		}
		else {
			// Last line was displayed - copblocks are no longer needed
			copBlockDisable(s_pView->pCopList, s_pBlockAboveLine);
			copBlockDisable(s_pView->pCopList, s_pBlockBelowLine);
			copBlockDisable(s_pView->pCopList, s_pBlockAfterLines);
			copProcessBlocks();
		}
	}
	else if(
		keyUse(KEY_RETURN) || keyUse(KEY_LSHIFT) || keyUse(KEY_RSHIFT) ||
		joyUse(JOY1_FIRE) || joyUse(JOY2_FIRE) ||
		(isEnabled34 && (joyUse(JOY3_FIRE) || joyUse(JOY4_FIRE)))
	) {
		// Quit the cutscene
		fadeSet(s_pFade, FADE_STATE_OUT, 50, 1, onCutsceneFadeOut);
	}
}

static void cutsceneGsLoop(void) {
	if(s_isFinale) {
		cutsceneLoopFinale();
		return;
	}
	tFadeState eFadeState = fadeProcess(s_pFade);
	if(eFadeState != FADE_STATE_IDLE) {
		return;
	}

	vPortWaitForEnd(s_pVp);
	UBYTE isEnabled34 = joyIsParallelEnabled();
	if(s_ubFadeStep <= 0x10) {
		// Process text fade-in
		// Increment color
		s_pBlockAboveLine->uwCurrCount = 0;
		copMove(
			s_pView->pCopList, s_pBlockAboveLine, &g_pCustom->color[COLOR_TEXT],
			s_ubFadeStep < 0x10 ? GRAYSCALE(s_ubFadeStep) : s_uwFontColorVal
		);
		++s_ubFadeStep;

		// Refresh copperlist
		copProcessBlocks();
	}
	else if(getLine(s_ubCurrentSlide, s_ubCurrentLine)) {
		// Start fade-in for next line
		++s_ubCurrentLine;
		if(getLine(s_ubCurrentSlide, s_ubCurrentLine)) {
			// Draw next portion of text - move copBlocks and reset fadeStep
			copBlockWait(
				s_pView->pCopList, s_pBlockAboveLine, 0,
				s_pView->ubPosY + TEXT_POS_Y + TEXT_LINE_HEIGHT * s_ubCurrentLine
			);
			copBlockWait(
				s_pView->pCopList, s_pBlockBelowLine, 0,
				s_pView->ubPosY + TEXT_POS_Y + TEXT_LINE_HEIGHT * (s_ubCurrentLine + 1) - 1
			);
			s_pBlockAboveLine->uwCurrCount = 0;
			copMove(
				s_pView->pCopList, s_pBlockAboveLine,
				&g_pCustom->color[COLOR_TEXT], 0x000
			);
			copProcessBlocks();
			s_ubFadeStep = 0;
		}
		else {
			// Last line was displayed - copblocks are no longer needed
			copBlockDisable(s_pView->pCopList, s_pBlockAboveLine);
			copBlockDisable(s_pView->pCopList, s_pBlockBelowLine);
			copBlockDisable(s_pView->pCopList, s_pBlockAfterLines);
			copProcessBlocks();
		}
	}
	else if(
		keyUse(KEY_RETURN) || keyUse(KEY_LSHIFT) || keyUse(KEY_RSHIFT) ||
		joyUse(JOY1_FIRE) || joyUse(JOY2_FIRE) ||
		(isEnabled34 && (joyUse(JOY3_FIRE) || joyUse(JOY4_FIRE)))
	) {
		if(++s_ubCurrentSlide < s_ubSlideCount) {
			// Draw next slide
			fadeSet(s_pFade, FADE_STATE_OUT, 15, 0, onFadeOutSlide);
		}
		else {
			// Quit the cutscene
			fadeSet(s_pFade, FADE_STATE_OUT, 50, !s_isOutro, onCutsceneFadeOut);
		}
	}
}

static void cutsceneGsDestroy(void) {
	viewLoad(0);
	systemUse();
	viewDestroy(s_pView);
	fadeDestroy(s_pFade);
	s_pVp = 0;

	// Destroy slides
	for(UBYTE i = 0; i < s_ubSlideCount; ++i) {
		bitmapDestroy(s_pSlides[i].pBitmap);
	}

	// Destroy text array

}

void cutsceneSetup(UBYTE isOutro, tState *pNextState) {
	s_isOutro = isOutro;
	s_isFinale = 0;
	s_ubCurrentSlide = 0;
	s_ubCurrentLine = 0;
	s_pNextState = pNextState;
}

tState g_sStateCutscene = {
	.cbCreate = cutsceneGsCreate, .cbLoop = cutsceneGsLoop,
	.cbDestroy = cutsceneGsDestroy
};
