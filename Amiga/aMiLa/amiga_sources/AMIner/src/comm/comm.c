/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "comm.h"
#include <ace/managers/ptplayer.h>
#include <ace/managers/rand.h>
#include <ace/managers/system.h>
#include <ace/managers/key.h>
#include <ace/utils/chunky.h>
#include <ace/contrib/managers/audio_mixer.h>
#include "../assets.h"
#include "../core.h"
#include "../game.h"
#include "../progress_bar.h"
#include "../defs.h"
#include "../msg.h"
#include "settings.h"

#define SFX_CHANNEL_KEY 0
#define COMM_BUTTON_LABEL_Y 170
#define COMM_BUTTON_LABEL_OFFICE_X 39
#define COMM_BUTTON_LABEL_WORKSHOP_X 115
#define COMM_BUTTON_LABEL_WAREHOUSE_X 201
#define COMM_BUTON_LABEL_COLOR_TEXT 9
#define COMM_BUTON_LABEL_COLOR_SHADOW 6
#define COMM_BUTON_LABEL_COLOR_BG 5
#define COMM_BUTON_LABEL_COLOR_CORNER 6
#define COMM_PROGRESS_BAR_WIDTH (COMM_DISPLAY_WIDTH - 20)
#define COMM_PROGRESS_BAR_HEIGHT 5
#define COMM_PROGRESS_BAR_BORDER_DISTANCE 2

static tBitMap *s_pBmEdgesMask;
static tBitMap *s_pPristineBuffer;
static tBitMap *s_pBg, *s_pButtons;
static UBYTE s_pNav[DIRECTION_COUNT] = {BTN_STATE_NACTIVE};
static UBYTE s_pNavEx[COMM_NAV_EX_COUNT] = {BTN_STATE_NACTIVE};
static tBitMap *s_pBmDraw;
static tTextBitMap *s_pLineBuffer;
static UBYTE s_isCommShown = 0;
static tPtplayerSfx *s_pSfxKeyPress[4];
static tPtplayerSfx *s_pSfxKeyRelease[4];
static UBYTE s_ubSteerCount;
static tSteer *s_pSteers;
static const char *s_szPrevProgressText;
static UBYTE s_isIntro;
static tPageProcess s_pPageProcess = 0;
static tPageCleanup s_pPageCleanup = 0;

static tProgressBarConfig s_sProgressBarConfig = {
	.sBarPos = {.ulYX = 0},
	.uwWidth =  COMM_PROGRESS_BAR_WIDTH,
	.uwHeight = COMM_PROGRESS_BAR_HEIGHT,
	.ubBorderDistance = COMM_PROGRESS_BAR_BORDER_DISTANCE,
	.ubColorBorder = COMM_DISPLAY_COLOR_TEXT,
	.ubColorBar = COMM_DISPLAY_COLOR_TEXT_DARK,
};

tBitMap *g_pCommBmFaces;
tBitMap *g_pCommBmSelection;
tBitMap *g_pCommWorkshopIcons;

//------------------------------------------------------------ PRIVATE FUNCTIONS

static void drawButtonLabels(void) {
	static const UBYTE s_pLabelOffsetsX[] = {
		COMM_BUTTON_LABEL_OFFICE_X,
		COMM_BUTTON_LABEL_WORKSHOP_X,
		COMM_BUTTON_LABEL_WAREHOUSE_X
	};

	tUwCoordYX sOrigin = commGetOrigin();
	for(UBYTE i = 0; i < 3; ++i) {
		fontFillTextBitMap(g_pFont, s_pLineBuffer,  g_pMsgs[MSG_TAB_NAME_OFFICE + i]);
		UWORD uwTextWidth = s_pLineBuffer->uwActualWidth;

		UWORD uwLabelX = sOrigin.uwX + s_pLabelOffsetsX[i] - 2;
		UWORD uwLabelY = sOrigin.uwY + COMM_BUTTON_LABEL_Y;
		UWORD uwLabelWidth = uwTextWidth + 3;
		UWORD uwLabelHeight = g_pFont->uwHeight + 2;

		blitRect(
			s_pBmDraw, uwLabelX, uwLabelY, uwLabelWidth, uwLabelHeight,
			COMM_BUTON_LABEL_COLOR_BG
		);

		// Corners: top-left, top-right, bottom-left, bottom-right
		UBYTE ubColor = COMM_BUTON_LABEL_COLOR_CORNER;
		chunkyToPlanar(
			ubColor, uwLabelX, uwLabelY, s_pBmDraw
		);
		chunkyToPlanar(
			ubColor, uwLabelX + uwLabelWidth - 1, uwLabelY, s_pBmDraw
		);
		chunkyToPlanar(
			ubColor, uwLabelX, uwLabelY + uwLabelHeight - 1, s_pBmDraw
		);
		chunkyToPlanar(
			ubColor, uwLabelX + uwLabelWidth - 1, uwLabelY + uwLabelHeight - 1, s_pBmDraw
		);

		fontDrawTextBitMap(
			s_pBmDraw, s_pLineBuffer,
			sOrigin.uwX + s_pLabelOffsetsX[i],
			sOrigin.uwY + COMM_BUTTON_LABEL_Y + 1, 6, FONT_COOKIE
		);
		fontDrawTextBitMap(
			s_pBmDraw, s_pLineBuffer,
			sOrigin.uwX + s_pLabelOffsetsX[i],
			sOrigin.uwY + COMM_BUTTON_LABEL_Y, 9, FONT_COOKIE
		);
	}
}

static void fixNextBackgroundEdge(UWORD uwX, UWORD uwY, UWORD uwHeight) {
	tUwCoordYX sOrigin = commGetOrigin();
	UWORD uwBlitWidthInWords = 1;
	ULONG ulOffsBCD = s_pBmDraw->BytesPerRow * (uwY + sOrigin.uwY) + ((uwX + sOrigin.uwX) / 8);
	blitWait();
	g_pCustom->bltbpt = (UBYTE*)((ULONG)s_pPristineBuffer->Planes[0] + ulOffsBCD);
	g_pCustom->bltcpt = (UBYTE*)((ULONG)s_pBmDraw->Planes[0] + ulOffsBCD);
	g_pCustom->bltdpt = (UBYTE*)((ULONG)s_pBmDraw->Planes[0] + ulOffsBCD);
	g_pCustom->bltsize = ((uwHeight * GAME_BPP) << HSIZEBITS) | (uwBlitWidthInWords);
}

static void fixBackgroundEdges(void) {
	// A: edge mask, B: restore buffer, C/D: display buffer
	// Use C channel instead of A - same speed, less regs to set up
	UWORD uwBltCon0 = USEA|USEB|USEC|USED | MINTERM_COOKIE;
	UWORD uwBlitWidthInWords = 1;
	WORD wModuloBCD = bitmapGetByteWidth(s_pBmDraw) - (uwBlitWidthInWords << 1);

	blitWait();
	g_pCustom->bltafwm = 0xFFFF;
	g_pCustom->bltalwm = 0xFFFF;
	g_pCustom->bltcon0 = uwBltCon0;
	g_pCustom->bltcon1 = 0;

	g_pCustom->bltapt = (UBYTE*)((ULONG)s_pBmEdgesMask->Planes[0]);
	g_pCustom->bltamod = 0;
	g_pCustom->bltbmod = wModuloBCD;
	g_pCustom->bltcmod = wModuloBCD;
	g_pCustom->bltdmod = wModuloBCD;

	fixNextBackgroundEdge(0, 0, 5);
	fixNextBackgroundEdge(COMM_WIDTH - 16, 0, 4);
	fixNextBackgroundEdge(0, COMM_HEIGHT - 4, 4);
	fixNextBackgroundEdge(COMM_WIDTH - 16, COMM_HEIGHT - 5, 5);
}

//------------------------------------------------------------- PUBLIC FUNCTIONS

void commCreate(tBitMap *pPristineBuffer) {
	systemUse();
	s_pPristineBuffer = pPristineBuffer;
	s_pBg = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_bg.bm"), 0);
	s_pButtons = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_buttons.bm"), 0);
	s_pLineBuffer = fontCreateTextBitMap(
		CEIL_TO_FACTOR(COMM_DISPLAY_WIDTH, 16), g_pFont->uwHeight
	);
	s_pBmEdgesMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_edges_mask.bm"), 0);

	for(UBYTE i = 0; i < 4; ++i) {
		char szPath[40];
		sprintf(szPath, SUBFILE_PREFIX "sfx/key_press_%hhu.sfx", i);
		s_pSfxKeyPress[i] = ptplayerSfxCreateFromFd(GET_SUBFILE(szPath), 1);
		sprintf(szPath, SUBFILE_PREFIX "sfx/key_release_%hhu.sfx", i);
		s_pSfxKeyRelease[i] = ptplayerSfxCreateFromFd(GET_SUBFILE(szPath), 1);
	}

	g_pCommBmFaces = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_faces_office.bm"), 0);
	g_pCommBmSelection = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_office_selection.bm"), 0);
	g_pCommWorkshopIcons = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_workshop_icons.bm"), 0);
	systemUnuse();

	s_isCommShown = 0;
}

void commDestroy(void) {
	systemUse();
	for(UBYTE i = 0; i < 4; ++i) {
		ptplayerSfxDestroy(s_pSfxKeyPress[i]);
		ptplayerSfxDestroy(s_pSfxKeyRelease[i]);
	}

	bitmapDestroy(s_pBg);
	bitmapDestroy(s_pButtons);
	bitmapDestroy(s_pBmEdgesMask);
	fontDestroyTextBitMap(s_pLineBuffer);

	bitmapDestroy(g_pCommBmFaces);
	bitmapDestroy(g_pCommBmSelection);
	bitmapDestroy(g_pCommWorkshopIcons);

	systemUnuse();
}

void commSetActiveLed(tCommTab eLed) {
	const UBYTE ubLedWidth = 16;
	const UBYTE ubLedHeight = 13;
	const UBYTE ubGrnLedY = ubLedHeight;
	static const UBYTE pLedX[] = {19, 95, 181};
	const UBYTE ubLedY = 169;

	tUwCoordYX sOrigin = commGetOrigin();
	for(UBYTE i = 0; i < COMM_TAB_COUNT; ++i) {
		blitCopy(
			s_pButtons, 0, (i == eLed ? ubGrnLedY : 0),
			s_pBmDraw, sOrigin.uwX + pLedX[i], sOrigin.uwY + ubLedY,
			ubLedWidth, ubLedHeight, MINTERM_COOKIE
		);
	}
}

UBYTE commTryShow(tSteer *pSteers, UBYTE ubSteerCount, UBYTE isIntro) {
	s_isIntro = isIntro;
	tUwCoordYX sOrigin = commGetOrigin();
	if(g_pMainBuffer->uwMarginedHeight - sOrigin.uwX < COMM_HEIGHT) {
		// Not positioned evenly
		return 0;
	}
	s_isCommShown = 1;
	s_pSteers = pSteers;
	s_ubSteerCount = ubSteerCount;

	s_pBmDraw = g_pMainBuffer->pScroll->pBack;

	// Draw commrade background
	blitCopyAligned(
		s_pBg, 0, 0, s_pBmDraw, sOrigin.uwX, sOrigin.uwY,
		COMM_WIDTH, COMM_HEIGHT
	);

	drawButtonLabels();
	fixBackgroundEdges();

	// Skip the initial fire press
	s_pNav[DIRECTION_FIRE] = BTN_STATE_USED;

	return 1;
}

void commProcess(void) {
	static const UWORD pBtnPos[DIRECTION_COUNT][4] = {
		// dX, dY, sY, h
		{218, 114, 26, 14},
		{218, 143, 54, 14},
		{203, 128, 82, 15},
		{234, 128, 112, 15},
		{218, 129, 142, 13}
	};

	UBYTE pTests[DIRECTION_COUNT] = {0};
	for(UBYTE i = 0; i < s_ubSteerCount; ++i) {
		tSteer *pSteer = &s_pSteers[i];
		steerProcess(pSteer);
		pTests[DIRECTION_UP] |= steerDirCheck(pSteer, DIRECTION_UP);
		pTests[DIRECTION_DOWN] |= steerDirCheck(pSteer, DIRECTION_DOWN);
		pTests[DIRECTION_LEFT] |= steerDirCheck(pSteer, DIRECTION_LEFT);
		pTests[DIRECTION_RIGHT] |= steerDirCheck(pSteer, DIRECTION_RIGHT);
		pTests[DIRECTION_FIRE] |= steerDirCheck(pSteer, DIRECTION_FIRE);
	}
	pTests[DIRECTION_FIRE] |= keyCheck(KEY_SPACE) | keyCheck(KEY_RETURN) | keyCheck(KEY_NUMENTER);

	tUwCoordYX sOrigin = commGetOrigin();

	for(UBYTE i = 0; i < DIRECTION_COUNT; ++i) {
		if(pTests[i]) {
			if(s_pNav[i] == BTN_STATE_NACTIVE) {
				audioMixerPlaySfx(s_pSfxKeyPress[randUw(&g_sRand) & 3], SFX_CHANNEL_KEY, 1, 0);
				s_pNav[i] = BTN_STATE_ACTIVE;
				blitCopy(
					s_pButtons, 0, pBtnPos[i][2], s_pBmDraw,
					sOrigin.uwX + pBtnPos[i][0],
					sOrigin.uwY + pBtnPos[i][1],
					16, pBtnPos[i][3], MINTERM_COOKIE
				);
			}
		}
		else if(s_pNav[i] != BTN_STATE_NACTIVE) {
			audioMixerPlaySfx(s_pSfxKeyRelease[randUw(&g_sRand) & 3], SFX_CHANNEL_KEY, 1, 0);
			s_pNav[i] = BTN_STATE_NACTIVE;
			blitCopy(
				s_pButtons, 0, pBtnPos[i][2] + pBtnPos[i][3], s_pBmDraw,
				sOrigin.uwX + pBtnPos[i][0],
				sOrigin.uwY + pBtnPos[i][1],
				16, pBtnPos[i][3], MINTERM_COOKIE
			);
		}
	}

	// Process ex events
	static UBYTE isShift = 0;
	static UBYTE wasShiftAction = 0;
	if(commNavCheck(DIRECTION_FIRE) == BTN_STATE_ACTIVE) {
		isShift = 1;
	}
	else {
		s_pNavEx[COMM_NAV_EX_BTN_CLICK] = BTN_STATE_NACTIVE;
		if(isShift) {
			if(!wasShiftAction) {
				// Btn released and no other pressed in the meantime
				s_pNavEx[COMM_NAV_EX_BTN_CLICK] = BTN_STATE_ACTIVE;
			}
			isShift = 0;
			wasShiftAction = 0;
		}
	}

	// Tab nav using shift+left / shift+right
	if(isShift) {
		if(commNavUse(DIRECTION_LEFT)) {
			s_pNavEx[COMM_NAV_EX_SHIFT_LEFT] = BTN_STATE_ACTIVE;
			wasShiftAction = 1;
		}
		else if(commNavUse(DIRECTION_RIGHT)) {
			s_pNavEx[COMM_NAV_EX_SHIFT_RIGHT] = BTN_STATE_ACTIVE;
			wasShiftAction = 1;
		}
	}
	else {
		s_pNavEx[COMM_NAV_EX_SHIFT_LEFT] = BTN_STATE_NACTIVE;
		s_pNavEx[COMM_NAV_EX_SHIFT_RIGHT] = BTN_STATE_NACTIVE;
	}
}

tBtnState commNavCheck(tDirection eDir) {
	return s_pNav[eDir];
}

UBYTE commNavUse(tDirection eDir) {
	// Relying on btn states from commProcess() makes it independent from state
	// changes during interrupts and allows hierarchical usage of buttons
	if(s_pNav[eDir] == BTN_STATE_ACTIVE) {
		s_pNav[eDir] = BTN_STATE_USED;
		return 1;
	}
	return 0;
}

void commNavUnuse(tDirection eDir) {
	if(s_pNav[eDir] == BTN_STATE_USED) {
		s_pNav[eDir] = BTN_STATE_ACTIVE;
	}
}

UBYTE commNavExUse(tCommNavEx eNavEx) {
	if(s_pNavEx[eNavEx] == BTN_STATE_ACTIVE) {
		s_pNavEx[eNavEx] = BTN_STATE_USED;
		return 1;
	}
	return 0;
}

void commHide(void) {
	if(!s_isCommShown) {
		return;
	}
	s_isCommShown = 0;

	commRegisterPage(0, 0);

	// Restore content beneath commrade
	tUwCoordYX sOrigin = commGetOrigin();
	blitCopyAligned(
		s_pPristineBuffer, sOrigin.uwX, sOrigin.uwY,
		s_pBmDraw, sOrigin.uwX, sOrigin.uwY,
		COMM_WIDTH, COMM_HEIGHT
	);
}

UBYTE commIsIntro(void) {
	return s_isIntro;
}

UBYTE commIsShown(void) {
	return s_isCommShown;
}

tBitMap *commGetDisplayBuffer(void) {
	return s_pBmDraw;
}

tUwCoordYX commGetOrigin(void) {
	UWORD uwScrollX = g_pMainBuffer->pCamera->uPos.uwX;
	UWORD uwScrollY = g_pMainBuffer->pCamera->uPos.uwY;
	UWORD uwBufferHeight = g_pMainBuffer->uwMarginedHeight;
	UWORD uwFoldScrollY = uwScrollY & (uwBufferHeight-1);
	UWORD uwCommOffsY = (g_pMainBuffer->sCommon.pVPort->uwHeight - COMM_HEIGHT) / 2;
	UWORD uwCommOffsX = (g_pMainBuffer->sCommon.pVPort->uwWidth - COMM_WIDTH) / 2;

	tUwCoordYX sOrigin;
	sOrigin.uwX = uwScrollX + uwCommOffsX;
	if(s_isIntro) {
		sOrigin.uwY = 0;
	}
	else {
		sOrigin.uwY = uwFoldScrollY + uwCommOffsY;
	}

	return sOrigin;
}

tUwCoordYX commGetOriginDisplay(void) {
	tUwCoordYX sOrigin = commGetOrigin();
	sOrigin.uwX += COMM_DISPLAY_X;
	sOrigin.uwY += COMM_DISPLAY_Y;
	return sOrigin;
}

void commDrawText(
	UWORD uwX, UWORD uwY, const char *szText, UBYTE ubFontFlags, UBYTE ubColor
) {
	const tUwCoordYX sOrigin = commGetOriginDisplay();
	fontDrawStr(
		g_pFont, s_pBmDraw, sOrigin.uwX + uwX, sOrigin.uwY + uwY,
		szText, ubColor, ubFontFlags, s_pLineBuffer
	);
}

UBYTE commDrawMultilineText(
	const char *szText, UWORD uwStartX, UWORD uwStartY
) {
	UWORD uwTextOffs = 0;
	UBYTE ubLinesWritten = 0;
	UWORD uwCurrY = uwStartY;
	UBYTE ubLineHeight = commGetLineHeight();
	char szLineBfr[50];
	do {
		// Measure chars in line
		UBYTE ubCharsInLine = commBreakTextToWidth(
			&szText[uwTextOffs], COMM_DISPLAY_WIDTH - uwStartX
		);

		// Copy to line buffer and draw
		memcpy(szLineBfr, &szText[uwTextOffs], ubCharsInLine);
		szLineBfr[ubCharsInLine] = '\0';
		if(szLineBfr[ubCharsInLine - 1] == '\n') {
			szLineBfr[ubCharsInLine - 1] = ' ';
		}
		commDrawText(uwStartX, uwCurrY, szLineBfr, FONT_COOKIE, COMM_DISPLAY_COLOR_TEXT);

		// Advance
		uwTextOffs += ubCharsInLine;
		++ubLinesWritten;
		uwCurrY += ubLineHeight;
	} while(szText[uwTextOffs] != '\0');

	return ubLinesWritten;
}

void commDrawTitle(UWORD uwX, UWORD uwY, const char *szTitle) {
	// Clear old contents
	if(s_pLineBuffer->uwActualWidth) {
		blitRect(
			s_pLineBuffer->pBitMap, 0, 0,
			s_pLineBuffer->uwActualWidth, s_pLineBuffer->pBitMap->Rows, 0
		);
	}

	char szChar[2] = {0};
	UWORD uwEndX = 0;
	for(const char *pNextChar = szTitle; *pNextChar != '\0'; ++pNextChar) {
		// Prepare "bold" letter
		szChar[0] = *pNextChar;
		uwEndX = fontDrawStr1bpp(g_pFont, s_pLineBuffer->pBitMap, uwEndX, 0, szChar).uwX + 1;
	}
	s_pLineBuffer->uwActualWidth = uwEndX - 1;

	const tUwCoordYX sOrigin = commGetOriginDisplay();
	fontDrawTextBitMap(
		s_pBmDraw, s_pLineBuffer, sOrigin.uwX + uwX, sOrigin.uwY + uwY,
		COMM_DISPLAY_COLOR_TEXT, FONT_COOKIE
	);
	fontDrawTextBitMap(
		s_pBmDraw, s_pLineBuffer, sOrigin.uwX + uwX + 1, sOrigin.uwY + uwY,
		COMM_DISPLAY_COLOR_TEXT, FONT_COOKIE
	);
}

void commDrawFaceAt(tFaceId eFace, UWORD uwX, UWORD uwY) {
	const tUwCoordYX sOrigin = commGetOriginDisplay();
	blitCopy(
		g_pCommBmFaces, 0, eFace * 32, s_pBmDraw,
		sOrigin.uwX + uwX, sOrigin.uwY + uwY,
		32, 32, MINTERM_COOKIE
	);
}

UBYTE commGetLineHeight(void) {
	return g_pFont->uwHeight + 1;
}

void commErase(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight) {
#if defined(COMM_DEBUG)
	static UBYTE ubDebugColor = 0;
	const UBYTE ubClearColor = ubDebugColor;
	ubDebugColor = (ubDebugColor + 1) & 31;
#else
	const UBYTE ubClearColor = COMM_DISPLAY_COLOR_BG;
#endif
	const tUwCoordYX sPosDisplay = commGetOriginDisplay();
	blitRect(
		s_pBmDraw, sPosDisplay.uwX + uwX, sPosDisplay.uwY + uwY,
		uwWidth, uwHeight, ubClearColor
	);
}

void commEraseAll(void) {
	commErase(0, 0, COMM_DISPLAY_WIDTH, COMM_DISPLAY_HEIGHT);
}

void commProgressInit(void) {
	if(!commIsShown() || s_isIntro) {
		return;
	}

	s_szPrevProgressText = 0;

	tUwCoordYX sBarPos = commGetOriginDisplay();
	sBarPos.uwX += (COMM_DISPLAY_WIDTH - COMM_PROGRESS_BAR_WIDTH) / 2;
	sBarPos.uwY += (COMM_DISPLAY_HEIGHT + g_pFont->uwHeight) / 2 + 2 * COMM_PROGRESS_BAR_BORDER_DISTANCE;
	s_sProgressBarConfig.sBarPos = sBarPos;
	progressBarInit(&s_sProgressBarConfig, s_pBmDraw);
}

void commProgress(UBYTE ubPercent, const char *szDescription) {
	if(!commIsShown() || s_isIntro) {
		return;
	}

	logWrite("Comm Progress: %hhu (%s)\n", ubPercent, szDescription ? szDescription : "???");

	if(szDescription != s_szPrevProgressText) {
		UWORD uwFontPosY = (COMM_DISPLAY_HEIGHT - g_pFont->uwHeight) / 2;
		commErase(0, uwFontPosY, COMM_DISPLAY_WIDTH, g_pFont->uwHeight);
		commDrawText(
			COMM_DISPLAY_WIDTH / 2, uwFontPosY, szDescription,
			FONT_HCENTER | FONT_COOKIE | FONT_LAZY,
			COMM_DISPLAY_COLOR_TEXT
		);
		s_szPrevProgressText = szDescription;
	}

	progressBarAdvance(&s_sProgressBarConfig, s_pBmDraw, ubPercent);
}

UBYTE commBreakTextToWidth(const char *szInput, UWORD uwMaxLineWidth) {
	UWORD uwLineWidth = 0;
	UBYTE ubCharsInLine = 0;
	UBYTE ubLastSpace = 0xFF; // next char, actually

	while(*szInput != '\0') {
		UBYTE ubCharWidth = fontGlyphWidth(g_pFont, *szInput) + 1;

		if(uwLineWidth + ubCharWidth >= uwMaxLineWidth) {
			if(ubLastSpace != 0xFF) {
				ubCharsInLine = ubLastSpace;
			}

			break;
		}

		uwLineWidth += ubCharWidth;
		ubCharsInLine++;

		if(*szInput == ' ') {
			ubLastSpace = ubCharsInLine;
		}
		else if(*szInput == '\r') {
			logWrite("ERR: CR character detected - use LF line endings!");
			break;
		}
		else if(*szInput == '\n') {
			break;
		}

		++szInput;
	}
	return ubCharsInLine;
}

void commRegisterPage(tPageProcess cbProcess, tPageCleanup cbCleanup) {
	logBlockBegin(
		"commRegisterPage(cbProcess: %p, cbCleanup: %p)", cbProcess, cbCleanup
	);
	if(s_pPageCleanup) {
		s_pPageCleanup();
		s_pPageCleanup = 0;
	}
	commEraseAll();

	s_pPageProcess = cbProcess;
	s_pPageCleanup = cbCleanup;
	logBlockEnd("commRegisterPage()");
}

UBYTE commProcessPage(void) {
	if(s_pPageProcess) {
		s_pPageProcess();
		return 1;
	}
	return 0;
}
