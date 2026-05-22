/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "logo.h"
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/game.h>
#include <ace/managers/system.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/blit.h>
#include <ace/utils/palette.h>
#include <ace/managers/ptplayer.h>
#include "menu.h"
#include "fade.h"
#include "assets.h"
#include "core.h"
#include "language.h"

#define FLASH_START_FRAME_A 1
#define FLASH_START_FRAME_C 10
#define FLASH_START_FRAME_E 30
#define FLASH_START_FRAME_PWR 50
#define FLASH_RATIO_INACTIVE -1
#define RGB(r,g,b) ((((r) >> 4) << 8) | (((g) >> 4) << 4) | (((b) >> 4) << 0))

typedef enum tStateAce {
	STATE_ACE_FADE_IN,
	STATE_ACE_FADE_OUT
} tStateAce;

typedef void (*tCbLogo)(void);
typedef UBYTE (*tCbFadeOut)(void);

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pBfr;
static UBYTE s_ubWaitFrame = 0;

static UBYTE s_isAnyPressed = 0;
static tPtplayerSfx *s_pSfxLmc, *s_pSfxAce;

static tState s_sStateLogoLmc;
static tState s_sStateLogoAce;
static tState s_sStateLogoLang;

static tStateManager *s_pStateMachineLogo;
static tStateAce s_eStateAce;
static tState *s_pNextState;

static tCopBlock *s_pAceBlocks[30];

static const UWORD s_pAceColors[] = {
  0xA00, 0xA00,
  0xC00, 0xC00, 0xC00,
  0xD40, 0xD40,
  0xE80, 0xE80, 0xE80,
  0xFB2, 0xFB2,
  0xFE5, 0xFE5, 0xFE5,
  0xCC2, 0xCC2,
  0x990, 0x990, 0x990,
  0x494, 0x494,
  0x099, 0x099, 0x099,
  0x077, 0x077,
  0x055, 0x055,
  0x055
};

static const UWORD s_uwColorPowered = 0x343;
static UWORD s_uwFlashFrame;
static BYTE s_bAceFadeoutRatio;
static BYTE s_bRatioFlashA;
static BYTE s_bRatioFlashC;
static BYTE s_bRatioFlashE;
static BYTE s_bRatioFlashPwr;
static tUwRect s_sLogoRect;
static UWORD s_pLogoPaletteRef[32];

static void logoGsCreate(void) {
	logBlockBegin("logoGsCreate()");

	s_pView = viewCreate(0,
		TAG_VIEW_GLOBAL_PALETTE, 1,
	TAG_END);

	s_pVp = vPortCreate(0,
		TAG_VPORT_BPP, 5,
		TAG_VPORT_VIEW, s_pView,
	TAG_END);

	s_pBfr = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
		TAG_SIMPLEBUFFER_VPORT, s_pVp,
		TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
		TAG_SIMPLEBUFFER_USE_X_SCROLLING, 0,
	TAG_END);

	s_pStateMachineLogo = stateManagerCreate();
	stateChange(s_pStateMachineLogo, &s_sStateLogoLmc);
	fadeMorphTo(FADE_STATE_IN, 0);
	logBlockEnd("logoGsCreate()");
	systemUnuse();
	viewLoad(s_pView);
}

static void logoGsLoop(void) {
	s_isAnyPressed = (
		keyUse(KEY_RETURN) | keyUse(KEY_NUMENTER) | keyUse(KEY_ESCAPE) |
		keyUse(KEY_SPACE) | keyUse(KEY_LSHIFT) | keyUse(KEY_RSHIFT) |
		joyUse(JOY1_FIRE)
	);

	fadeProcess();
	tFadeState eState = fadeGetState();
	if(eState == FADE_STATE_IN_MORPHING || eState == FADE_STATE_OUT_MORPHING) {
		UBYTE ubLevel = fadeGetLevel();
		paletteDim(s_pLogoPaletteRef, s_pVp->pPalette, 32, ubLevel);
		viewUpdateGlobalPalette(s_pView);
		vPortWaitForEnd(s_pVp);
	}
	else if(eState == FADE_STATE_IN) {
		stateProcess(s_pStateMachineLogo);
	}
	else if(eState == FADE_STATE_OUT) {
		if(s_pNextState) {
			stateChange(s_pStateMachineLogo, s_pNextState);
			fadeMorphTo(FADE_STATE_IN, 0);
		}
		else {
			stateChange(g_pGameStateManager, &g_sStateCore);
		}
	}
}

static void logoGsDestroy(void) {
	// this must be here or else state destruction will be called when os is alive and it shouldn't be
	statePopAll(s_pStateMachineLogo);

	systemUse();
	logBlockBegin("logoGsDestroy()");
	stateManagerDestroy(s_pStateMachineLogo);
	viewDestroy(s_pView);
	logBlockEnd("logoGsDestroy()");
}

//-------------------------------------------------------------------------- LMC

static void logoLmcCreate(void) {
	systemUse();
	paletteLoadFromFd(GET_SUBFILE_PREFIX("logo/lmc.plt"), s_pLogoPaletteRef, 1 << s_pVp->ubBpp);
	tBitMap *pLogo = bitmapCreateFromFd(GET_SUBFILE_PREFIX("logo/lmc.bm"), 0);
	s_pSfxLmc = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("logo/lmc.sfx"), 0);
	systemUnuse();

	s_sLogoRect.uwWidth = bitmapGetByteWidth(pLogo) * 8;
	s_sLogoRect.uwHeight = pLogo->Rows;
	blitCopy(
		pLogo, 0, 0, s_pBfr->pBack,
		(s_pVp->uwWidth - s_sLogoRect.uwWidth) / 2,
		(s_pVp->uwHeight - s_sLogoRect.uwHeight) / 2,
		s_sLogoRect.uwWidth, s_sLogoRect.uwHeight, MINTERM_COOKIE
	);

	systemUse();
	bitmapDestroy(pLogo);
	systemUnuse();
	s_pNextState = &s_sStateLogoAce;
}

static void logoLmcLoop(void) {
	tFadeState eFadeState = fadeGetState();

	if(eFadeState == FADE_STATE_IN && s_isAnyPressed) {
		fadeMorphTo(FADE_STATE_OUT, 0);
	}
	else if(eFadeState == FADE_STATE_IN) {
		++s_ubWaitFrame;

		if(s_ubWaitFrame >= 100 || s_isAnyPressed) {
			fadeMorphTo(FADE_STATE_OUT, 0);
		}
		else if(s_ubWaitFrame == 1){
			ptplayerSfxPlay(s_pSfxLmc, 0, PTPLAYER_VOLUME_MAX, 1);
			// fadeMorphTo(FADE_STATE_OUT, 0); // FOR DEBUGGING SFX GLITCHES
		}
	}

	vPortWaitForEnd(s_pVp);
}

static void logoLmcDestroy(void) {
	// Clear after LMC logo
	blitRect(
		s_pBfr->pBack,
		(s_pVp->uwWidth - s_sLogoRect.uwWidth) / 2,
		(s_pVp->uwHeight - s_sLogoRect.uwHeight) / 2,
		s_sLogoRect.uwWidth, s_sLogoRect.uwHeight, 0
	);

	ptplayerWaitForSfx();
	ptplayerSfxDestroy(s_pSfxLmc);
}

//-------------------------------------------------------------------------- ACE

static UWORD blendColors(UWORD uwColorSrc, UWORD uwColorDst, UBYTE ubRatio)
{
  BYTE bSrcR = (uwColorSrc >> 8);
  BYTE bSrcG = ((uwColorSrc >> 4) & 0xF);
  BYTE bSrcB = ((uwColorSrc >> 0) & 0xF);
  BYTE bDstR = (uwColorDst >> 8);
  BYTE bDstG = ((uwColorDst >> 4) & 0xF);
  BYTE bDstB = ((uwColorDst >> 0) & 0xF);
  UBYTE ubCurrentR = bSrcR + ((bDstR - bSrcR) * ubRatio) / 15;
  UBYTE ubCurrentG = bSrcG + ((bDstG - bSrcG) * ubRatio) / 15;
  UBYTE ubCurrentB = bSrcB + ((bDstB - bSrcB) * ubRatio) / 15;
  UWORD uwColorOut = (ubCurrentR << 8) | (ubCurrentG << 4) | ubCurrentB;
  return uwColorOut;
}

static void logoAceCreate(void) {
	systemUse();

	for(UBYTE i = 0; i < 32; ++i) {
		s_pLogoPaletteRef[i] = 0;
	}

	tBitMap *pLogoAce = bitmapCreateFromFd(GET_SUBFILE_PREFIX("logo/ace.bm"), 0);
	s_sLogoRect.uwWidth = bitmapGetByteWidth(pLogoAce) * 8;
	s_sLogoRect.uwHeight = pLogoAce->Rows;
	UWORD uwLogoOffsY = (256 - s_sLogoRect.uwHeight) / 2;

	for(UBYTE i = 0; i < 30; ++i) {
    s_pAceBlocks[i] = copBlockCreate(s_pView->pCopList, 3, 0, s_pView->ubPosY + uwLogoOffsY + i * 2);
    copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[1], 0x000);
    copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[2], 0x000);
    copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[3], 0x000);
  }

	s_uwFlashFrame = 1;
	s_bRatioFlashA = FLASH_RATIO_INACTIVE;
	s_bRatioFlashC = FLASH_RATIO_INACTIVE;
	s_bRatioFlashE = FLASH_RATIO_INACTIVE;
	s_bRatioFlashPwr = FLASH_RATIO_INACTIVE;

	s_pSfxAce = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("logo/ace.sfx"), 0);
	systemUnuse();

	blitCopy(
		pLogoAce, 0, 0, s_pBfr->pBack, (320 - s_sLogoRect.uwWidth) / 2, uwLogoOffsY,
		s_sLogoRect.uwWidth, s_sLogoRect.uwHeight, MINTERM_COOKIE
	);

	systemUse();
	bitmapDestroy(pLogoAce);
	systemUnuse();

	s_eStateAce = STATE_ACE_FADE_IN;
	ptplayerSfxPlay(s_pSfxAce, 0, 64, 100);
	s_bAceFadeoutRatio = 15;
	s_pNextState = &s_sStateLogoLang;
}

static void logoAceLoop(void) {
	if(s_eStateAce == STATE_ACE_FADE_IN) {
		++s_uwFlashFrame;

		if(s_uwFlashFrame >= FLASH_START_FRAME_A) {
			s_bRatioFlashA = MIN(16, s_bRatioFlashA + 1);
		}
		if(s_uwFlashFrame >= FLASH_START_FRAME_C) {
			s_bRatioFlashC = MIN(16, s_bRatioFlashC + 1);
		}
		if(s_uwFlashFrame >= FLASH_START_FRAME_E) {
			s_bRatioFlashE = MIN(16, s_bRatioFlashE + 1);
		}
		if(s_uwFlashFrame >= FLASH_START_FRAME_PWR) {
			s_bRatioFlashPwr = MIN(16, s_bRatioFlashPwr + 1);
		}
		if (s_uwFlashFrame >= 215 || s_isAnyPressed) {
			s_eStateAce = STATE_ACE_FADE_OUT;
		}

		for(UBYTE i = 0; i < 30; ++i) {
			if(s_bRatioFlashA != FLASH_RATIO_INACTIVE && s_bRatioFlashA < 16) {
				s_pAceBlocks[i]->pCmds[0].sMove.bfValue = blendColors(0xFFF, s_pAceColors[i], s_bRatioFlashA);
			}

			if(s_bRatioFlashC != FLASH_RATIO_INACTIVE && s_bRatioFlashC < 16) {
				s_pAceBlocks[i]->pCmds[1].sMove.bfValue = blendColors(0xFFF, s_pAceColors[i], s_bRatioFlashC);
			}

			if(i < 9) {
				// Watch out for "E" flash interfering here
				UWORD uwColor = (
					s_bRatioFlashPwr != FLASH_RATIO_INACTIVE ?
					blendColors(0xFFF, s_uwColorPowered, s_bRatioFlashPwr) : 0
				);
				s_pAceBlocks[i]->pCmds[2].sMove.bfValue = uwColor;
			}
			else {
				if(s_bRatioFlashE != FLASH_RATIO_INACTIVE && s_bRatioFlashE < 16) {
					s_pAceBlocks[i]->pCmds[2].sMove.bfValue = blendColors(0xFFF, s_pAceColors[i], s_bRatioFlashE);
				}
			}

			s_pAceBlocks[i]->ubUpdated = 2;
			s_pView->pCopList->ubStatus |= STATUS_UPDATE;
		}
	}
	else if(s_eStateAce == STATE_ACE_FADE_OUT) {
		for(UBYTE i = 0; i < 30; ++i) {
			s_pAceBlocks[i]->uwCurrCount = 0;
			copMove(
				s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[1],
				blendColors(0x000, s_pAceColors[i], s_bAceFadeoutRatio)
			);
			copMove(
				s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[2],
				blendColors(0x000, s_pAceColors[i], s_bAceFadeoutRatio)
			);
			copMove(
				s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[3],
				blendColors(0x000, i < 9 ? s_uwColorPowered : s_pAceColors[i], s_bAceFadeoutRatio)
			);
		}

		--s_bAceFadeoutRatio;
	}

	copProcessBlocks();
	vPortWaitForEnd(s_pVp);

	if (s_bAceFadeoutRatio <= 0)
	{
		stateChange(s_pStateMachineLogo, s_pNextState);
		fadeSetLevel(0);
		fadeMorphTo(FADE_STATE_IN, 0);
		return;
	}
}

static void logoAceDestroy(void) {
	ptplayerWaitForSfx();
	ptplayerSfxDestroy(s_pSfxAce);
}

//------------------------------------------------------------------------- LANG

static const char * const s_pLanguageNames[LANGUAGE_COUNT] = {
	[LANGUAGE_ENGLISH] = "Johnny English",
	[LANGUAGE_POLISH] = "Mietek Polisz",
};

#define FACE_WIDTH (64)
#define FACE_HEIGHT (64)
#define FACE_DIST (30)
#define FACE_OFFS_Y ((256 - FACE_HEIGHT) / 2)
#define FACE_OFFS_X ((320 - (2 * FACE_WIDTH + FACE_DIST)) / 2)
#define FACE_DELTA_X (FACE_WIDTH + FACE_DIST)

static tLanguage s_eLangCurr = 0;
static tTextBitMap *s_pLineBuffer;

static void drawLangNames(void) {
	for(tLanguage eLang = 0; eLang < LANGUAGE_COUNT; ++eLang) {
		fontFillTextBitMap(g_pFont, s_pLineBuffer, s_pLanguageNames[eLang]);
		fontDrawTextBitMap(
			s_pBfr->pBack, s_pLineBuffer,
			FACE_OFFS_X + eLang * FACE_DELTA_X + FACE_WIDTH / 2,
			FACE_OFFS_Y + FACE_HEIGHT + 2,
			eLang == s_eLangCurr ? 30 : 28, FONT_HCENTER
		);
	}
}

void logoLangCreate(void) {
	systemUse();
	s_pLineBuffer = fontCreateTextBitMap(320, g_pFont->uwHeight);
	paletteLoadFromFd(GET_SUBFILE_PREFIX("aminer.plt"), s_pLogoPaletteRef, 1 << s_pVp->ubBpp);
	tBitMap *pFaces = bitmapCreateFromFd(GET_SUBFILE_PREFIX("lang_select.bm"), 0);
	systemUnuse();

	// Set first color to black, fill rest with colors from layer 1
	s_pLogoPaletteRef[0] = 0x0000;
	s_pLogoPaletteRef[27] = RGB(51, 34, 0);
	s_pLogoPaletteRef[28] = RGB(102, 68, 0);
	s_pLogoPaletteRef[29] = RGB(153, 102, 17);
	s_pLogoPaletteRef[30] = RGB(204, 136, 34);
	s_pLogoPaletteRef[31] = RGB(255, 170, 51);

	for(tLanguage eLang = 0; eLang < LANGUAGE_COUNT; ++eLang) {
		blitCopy(
			pFaces, 0, eLang * FACE_HEIGHT, s_pBfr->pBack,
			FACE_OFFS_X + eLang * FACE_DELTA_X, FACE_OFFS_Y,
			FACE_WIDTH, FACE_HEIGHT, MINTERM_COOKIE
		);
	}

	systemUse();
	bitmapDestroy(pFaces);
	systemUnuse();

	s_eLangCurr = 0;
	fontFillTextBitMap(g_pFont, s_pLineBuffer, "Choose the j\x84zyk");
	fontDrawTextBitMap(
		s_pBfr->pBack, s_pLineBuffer,
		320 / 2, FACE_OFFS_Y - (g_pFont->uwHeight + 2),
		30, FONT_LAZY | FONT_HCENTER | FONT_BOTTOM
	);

	drawLangNames();
	s_pNextState = 0;
}

void logoLangLoop(void) {
	if(keyUse(KEY_LEFT) || keyUse(KEY_A) || joyUse(JOY1_LEFT)) {
		if(s_eLangCurr == 0) {
			s_eLangCurr = LANGUAGE_COUNT - 1;
		}
		else {
			--s_eLangCurr;
		}
		drawLangNames();
	}
	else if(keyUse(KEY_RIGHT) || keyUse(KEY_D) || joyUse(JOY1_RIGHT)) {
		if(++s_eLangCurr == LANGUAGE_COUNT) {
			s_eLangCurr = 0;
		}
		drawLangNames();
	}

	// HACK: auto-choose language
	// s_eLangCurr = LANGUAGE_POLISH;
	// s_isAnyPressed = 1;

	if(s_isAnyPressed) {
		languageSet(s_eLangCurr);
		fadeMorphTo(FADE_STATE_OUT, 0);
	}
}

void logoLangDestroy(void) {
	fontDestroyTextBitMap(s_pLineBuffer);
}

//----------------------------------------------------------------------- STATES

tState g_sStateLogo = {
	.cbCreate = logoGsCreate, .cbLoop = logoGsLoop, .cbDestroy = logoGsDestroy
};

static tState s_sStateLogoLmc = {
	.cbCreate = logoLmcCreate, .cbLoop = logoLmcLoop, .cbDestroy = logoLmcDestroy
};

static tState s_sStateLogoAce = {
	.cbCreate = logoAceCreate, .cbLoop = logoAceLoop, .cbDestroy = logoAceDestroy
};

static tState s_sStateLogoLang = {
	.cbCreate = logoLangCreate, .cbLoop = logoLangLoop, .cbDestroy = logoLangDestroy
};
