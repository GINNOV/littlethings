/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "hud.h"
#include <ace/managers/ptplayer.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/contrib/managers/audio_mixer.h>
#include <ace/utils/palette.h>
#include <ace/utils/chunky.h>
#include <ace/utils/string.h>
#include "defs.h"
#include "save.h"
#include "blitter_mutex.h"
#include "comm/inbox.h"
#include "assets.h"

#define HUD_COLOR_BG 11
#define HUD_COLOR_BAR_FULL 14
#define HUD_COLOR_BAR_EMPTY 12

#define HUD_ORIGIN_X 11
#define HUD_ORIGIN_Y 9
#define HUD_FACE_SIZE 16

#define MSG_ICON_X 300
#define MSG_ICON_Y 9
#define MSG_ICON_WIDTH 11
#define MSG_ICON_HEIGHT 6

#define GAUGE_DRILL_X (HUD_ORIGIN_X + 65)
#define GAUGE_CARGO_X (HUD_ORIGIN_X + 125)
#define GAUGE_HULL_X (HUD_ORIGIN_X + 182)
#define GAUGE_DEPTH_X (HUD_ORIGIN_X + 248)
#define GAUGE_CASH_X (HUD_ORIGIN_X + 248)
#define GAUGE_TIME_X (HUD_ORIGIN_X + 248)

#define ROW_1_Y (HUD_ORIGIN_Y + 0)
#define ROW_2_Y (HUD_ORIGIN_Y + 9)
#define HUD_MESSAGE_BUFFER_SIZE 250
#define HUD_MSG_WAIT_CNT 200

#define HUD_ICON_INBOX_SRC_OFFS_Y (FACE_ID_COUNT * 16)
#define HUD_NOISE_DURATION 25

#define SFX_CHANNEL_HUD 2
#define SFX_PRIORITY_HUD 5

typedef enum _tHudPage {
	HUD_PAGE_MAIN,
	HUD_PAGE_NOISE_1,
	HUD_PAGE_NOISE_2,
	HUD_PAGE_NOISE_3,
	HUD_PAGE_MSG,
	HUD_PAGE_PAUSE,
	HUD_PAGE_COUNT,
} tHudPage;

typedef enum _tHudState {
	// State machine for drawing main HUD
	STATE_MAIN_PREPARE_TIME,
	STATE_MAIN_PREPARE_DEPTH,
	STATE_MAIN_DRAW_DEPTH,
	STATE_MAIN_PREPARE_CASH,
	STATE_MAIN_DRAW_CASH,
	STATE_MAIN_DRAW_FUEL,
	STATE_MAIN_DRAW_CARGO,
	STATE_MAIN_DRAW_HULL,
	STATE_MAIN_DRAW_END,
	// State machine for drawing message
	STATE_MSG_NOISE_IN,
	STATE_MSG_DRAW_FACE,
	STATE_MSG_PREPARE_LETTER,
	STATE_MSG_DRAW_LETTER,
	STATE_MSG_WAIT_OUT,
	STATE_MSG_NOISE_OUT,
	STATE_MSG_END,
	// State machine for pause screen
	STATE_PAUSE_INITIAL_DRAW,
	STATE_PAUSE_LOOP,
} tHudState;

typedef struct _tHudPlayerData {
	UWORD uwDepth, uwDepthDisp;
	UWORD uwTime, uwTimeDisp;
	LONG lCash, lCashDisp;
	UWORD uwDrill, uwDrillMax;
	UBYTE ubCargo, ubCargoMax;
	UWORD uwHull, uwHullMax;
	UBYTE ubHullDisp, ubCargoDisp, ubDrillDisp;
} tHudPlayerData;

static tVPort *s_pVpHud;
static tSimpleBufferManager *s_pHudBuffer;
static const tFont *s_pFont;
static tTextBitMap *s_pLineBuffer;
static tBitMap *s_pFaces;
static tPtplayerSfx *s_pSfxNoise;
static tPtplayerSfx *s_pSfxMsg;

static UBYTE s_ubLineHeight;
static UBYTE s_isBitmapFilled = 0;
static tHudPlayerData s_pPlayerData[2];
static tHudState s_eState;
static tHudPlayer s_ePlayer;
static UBYTE s_ubHudOffsY;
static UBYTE s_is2pPlaying;
static tGameMode s_eGameMode;
static UWORD s_uwFrameDelay, s_uwStateCounter;
static tHudPage s_ePageCurrent = HUD_PAGE_MAIN;

// Message vars
static UWORD s_uwMsgLen;
static tUwCoordYX s_sMsgCharPos;
static UBYTE s_ubMsgCharIdx;
static char s_szMsg[HUD_MESSAGE_BUFFER_SIZE];
static char s_szLetter[2] = {'\0'};
static tFaceId s_eFaceToDraw;

// Pause vars
static UBYTE s_ubSelection, s_ubSelectionPrev;

//----------------------------------------------------------------------- STATIC

static void hudResetStateMachine(void) {
	switch(s_eGameMode) {
		case GAME_MODE_CHALLENGE: s_eState = STATE_MAIN_PREPARE_CASH; break;
		case GAME_MODE_STORY: s_eState = STATE_MAIN_PREPARE_DEPTH; break;
		case GAME_MODE_DEADLINE: s_eState = STATE_MAIN_PREPARE_TIME; break;
	}
	s_ePlayer = PLAYER_1;
	s_ubHudOffsY = ROW_1_Y;
	s_isBitmapFilled = 0;
}

static void hudShowPage(tHudPage eHudPage) {
	s_ePageCurrent = eHudPage;
	cameraSetCoord(s_pHudBuffer->pCamera, 0, eHudPage * HUD_HEIGHT);
}

static void hudRefresh(void) {
	const UBYTE ubLabelWidth = fontMeasureText(
		s_pFont, g_pMsgs[MSG_HUD_DEPTH]
	).uwX;

	// Clear depth label and use it as cash/time/depth
	blitRect(
		s_pHudBuffer->pBack, GAUGE_DEPTH_X - 1 - ubLabelWidth, ROW_2_Y,
		ubLabelWidth, s_ubLineHeight, HUD_COLOR_BG
	);

	if(s_eGameMode == GAME_MODE_DEADLINE) {
		// Time instead of 2p cash
		fontDrawStr(
			s_pFont, s_pHudBuffer->pBack, GAUGE_TIME_X - 1, ROW_2_Y - 3,
			g_pMsgs[MSG_HUD_TIME], HUD_COLOR_BAR_FULL,
			FONT_LAZY | FONT_COOKIE | FONT_RIGHT, s_pLineBuffer
		);
	}
	else if(s_eGameMode == GAME_MODE_STORY) {
		// Depth instead of 2p cash
		fontDrawStr(
			s_pFont, s_pHudBuffer->pBack, GAUGE_DEPTH_X - 1, ROW_2_Y - 3,
			g_pMsgs[MSG_HUD_DEPTH], HUD_COLOR_BAR_FULL,
			FONT_LAZY | FONT_COOKIE | FONT_RIGHT, s_pLineBuffer
		);
	}

	// Empty bars
	UWORD pBarOffsX[3] = {GAUGE_DRILL_X, GAUGE_CARGO_X, GAUGE_HULL_X};
	for(UBYTE i = 0; i < 3; ++i) {
		for(UBYTE b = 0; b < 10; ++b) {
			blitRect(
				s_pHudBuffer->pBack, pBarOffsX[i] + 3 * b, ROW_1_Y,
				2, 5, HUD_COLOR_BAR_EMPTY
			);
			blitRect(
				s_pHudBuffer->pBack, pBarOffsX[i] + 3 * b, ROW_2_Y,
				2, 5, HUD_COLOR_BAR_EMPTY
			);
		}
	}

	// Values to display
	for(UBYTE ubPlayer = PLAYER_1; ubPlayer <= PLAYER_2; ++ubPlayer) {
		s_pPlayerData[ubPlayer].uwDepthDisp = 0xFFFF;
		s_pPlayerData[ubPlayer].lCashDisp = 0xFFFFFFFF;
		s_pPlayerData[ubPlayer].ubCargoDisp = 0;
		s_pPlayerData[ubPlayer].ubDrillDisp = 0;
		s_pPlayerData[ubPlayer].ubHullDisp = 0;
	}

	hudResetStateMachine();
}

static void hudTriggerMessage(void) {
	s_eState = STATE_MSG_NOISE_IN;
	s_uwFrameDelay = HUD_NOISE_DURATION;
	s_uwStateCounter = 0;
	audioMixerPlaySfx(s_pSfxNoise, SFX_CHANNEL_HUD, SFX_PRIORITY_HUD, 0);
}

//------------------------------------------------------------------------ PAUSE

void hudPause(UBYTE isPaused) {
	if(isPaused) {
		s_eState = STATE_PAUSE_INITIAL_DRAW;
	}
	else {
		hudShowMain();
		hudResetStateMachine();
		// TODO: perhaps reset to last "safe" state? E.g. begin of msg display
	}
}

UBYTE hudIsPaused(void) {
	return (
		s_eState == STATE_PAUSE_INITIAL_DRAW ||
		s_eState == STATE_PAUSE_LOOP
	);
}

void hudSelect(UBYTE ubSelection) {
	s_ubSelection = ubSelection;
}

UBYTE hudGetSelection(void) {
	return s_ubSelection;
}

//------------------------------------------------------------------------- MAIN

void hudCreate(tVPort *pVpHud, const tFont *pFont) {
  s_pVpHud = pVpHud;

  s_pHudBuffer = simpleBufferCreate(0,
    TAG_SIMPLEBUFFER_VPORT, s_pVpHud,
    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_INTERLEAVED,
		TAG_SIMPLEBUFFER_BOUND_HEIGHT, HUD_HEIGHT * HUD_PAGE_COUNT,
  TAG_END);

	bitmapLoadFromFd(s_pHudBuffer->pBack, GET_SUBFILE_PREFIX("hud.bm"), 0, 0);
	s_pFaces = bitmapCreateFromFd(GET_SUBFILE_PREFIX("comm_faces.bm"), 0);
	s_pSfxNoise = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/hud_noise.sfx"), 1);
	s_pSfxMsg = ptplayerSfxCreateFromFd(GET_SUBFILE_PREFIX("sfx/hud_msg.sfx"), 1);

	s_pFont = pFont;
	s_ubLineHeight = 7;
	s_pLineBuffer = fontCreateTextBitMap(s_pHudBuffer->uBfrBounds.uwX, s_pFont->uwHeight);

	blitterMutexLock();
	fontDrawStr(
		s_pFont, s_pHudBuffer->pBack, HUD_ORIGIN_X, ROW_1_Y - 3,
		g_pMsgs[MSG_HUD_P1], HUD_COLOR_BAR_FULL, FONT_LAZY | FONT_COOKIE, s_pLineBuffer
	);
	fontDrawStr(
		s_pFont, s_pHudBuffer->pBack, HUD_ORIGIN_X, ROW_2_Y - 3,
		g_pMsgs[MSG_HUD_P2], HUD_COLOR_BAR_FULL, FONT_LAZY | FONT_COOKIE, s_pLineBuffer
	);

	fontDrawStr(
		s_pFont, s_pHudBuffer->pBack, GAUGE_DRILL_X - 1, ROW_1_Y - 3,
		g_pMsgs[MSG_HUD_DRILL], HUD_COLOR_BAR_FULL,
		FONT_LAZY | FONT_COOKIE | FONT_RIGHT, s_pLineBuffer
	);
	fontDrawStr(
		s_pFont, s_pHudBuffer->pBack, GAUGE_CARGO_X - 1, ROW_1_Y - 3,
		g_pMsgs[MSG_HUD_CARGO], HUD_COLOR_BAR_FULL,
		FONT_LAZY | FONT_COOKIE | FONT_RIGHT, s_pLineBuffer
	);
	fontDrawStr(
		s_pFont, s_pHudBuffer->pBack, GAUGE_HULL_X - 1, ROW_1_Y - 3,
		g_pMsgs[MSG_HUD_HULL], HUD_COLOR_BAR_FULL,
		FONT_LAZY | FONT_COOKIE | FONT_RIGHT, s_pLineBuffer
	);
	fontDrawStr(
		s_pFont, s_pHudBuffer->pBack, GAUGE_CASH_X - 1, ROW_1_Y - 3,
		g_pMsgs[MSG_HUD_CASH], HUD_COLOR_BAR_FULL,
		FONT_LAZY | FONT_COOKIE | FONT_RIGHT, s_pLineBuffer
	);
	hudReset(0, 0);
	blitterMutexUnlock();
}

UBYTE hudIsShowingMessage(void) {
	return STATE_MSG_NOISE_IN <= s_eState && s_eState <= STATE_MSG_END;
}

void hudShowMessage(tFaceId eFace, const char *szMsg) {
	logWrite("hudShowMessage(eFace: %d, szMsg: '%s')\n", eFace, szMsg);
	stringCopyLimited(szMsg, s_szMsg, HUD_MESSAGE_BUFFER_SIZE);
	s_eFaceToDraw = eFace;
	hudTriggerMessage();
}

void hudShowMessageVa(tFaceId eFace, const char *szFormat, ...) {
	logWrite("hudShowMessageVa(eFace: %d, szFormat: '%s')\n", eFace, szFormat);
	va_list vaArgs;
	va_start(vaArgs, szFormat);
	vsnprintf(s_szMsg, HUD_MESSAGE_BUFFER_SIZE, szFormat, vaArgs);
	va_end(vaArgs);
	s_eFaceToDraw = eFace;
	hudTriggerMessage();
}

void hudSet2pPlaying(UBYTE isPlaying) {
	s_is2pPlaying = isPlaying;
}

void hudReset(tGameMode eGameMode, UBYTE is2pPlaying) {
	s_eGameMode = eGameMode;
	s_is2pPlaying = is2pPlaying;

	for(UBYTE ubPlayer = PLAYER_1; ubPlayer <= PLAYER_2; ++ubPlayer) {
		s_pPlayerData[ubPlayer].uwDepth = 0;
		s_pPlayerData[ubPlayer].lCash = 0;
		s_pPlayerData[ubPlayer].ubCargo = 0;
		s_pPlayerData[ubPlayer].ubCargoMax = 0;
		s_pPlayerData[ubPlayer].uwDrill = 0;
		s_pPlayerData[ubPlayer].uwDrillMax = 0;
		s_pPlayerData[ubPlayer].uwHull = 0;
		s_pPlayerData[ubPlayer].uwHullMax = 0;
	}

	hudRefresh();
}

void hudSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_HUD);
	// fileWrite(pFile, &s_ubLineHeight, sizeof(s_ubLineHeight));
	fileWrite(pFile, &s_isBitmapFilled, sizeof(s_isBitmapFilled));
	fileWrite(pFile, s_pPlayerData, sizeof(s_pPlayerData));
	fileWrite(pFile, &s_eState, sizeof(s_eState));
	fileWrite(pFile, &s_ePlayer, sizeof(s_ePlayer));
	fileWrite(pFile, &s_ubHudOffsY, sizeof(s_ubHudOffsY));
	fileWrite(pFile, &s_eGameMode, sizeof(s_eGameMode));
	fileWrite(pFile, &s_is2pPlaying, sizeof(s_is2pPlaying));
	fileWrite(pFile, &s_uwFrameDelay, sizeof(s_uwFrameDelay));
	fileWrite(pFile, &s_uwStateCounter, sizeof(s_uwStateCounter));
	fileWrite(pFile, &s_ePageCurrent, sizeof(s_ePageCurrent));
	fileWrite(pFile, &s_uwMsgLen, sizeof(s_uwMsgLen));
	fileWrite(pFile, &s_sMsgCharPos, sizeof(s_sMsgCharPos));
	fileWrite(pFile, &s_ubMsgCharIdx, sizeof(s_ubMsgCharIdx));
	fileWrite(pFile, s_szMsg, sizeof(s_szMsg));
	fileWrite(pFile, s_szLetter, sizeof(s_szLetter));
	fileWrite(pFile, &s_eFaceToDraw, sizeof(s_eFaceToDraw));
	// fileWrite(pFile, &s_ubSelection, sizeof(s_ubSelection));
	// fileWrite(pFile, &s_ubSelectionPrev, sizeof(s_ubSelectionPrev));
	saveWriteTag(pFile, SAVE_TAG_HUD_END);
}

UBYTE hudLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_HUD)) {
		return 0;
	}

	// fileRead(pFile, &s_ubLineHeight, sizeof(s_ubLineHeight));
	fileRead(pFile, &s_isBitmapFilled, sizeof(s_isBitmapFilled));
	fileRead(pFile, s_pPlayerData, sizeof(s_pPlayerData));
	fileRead(pFile, &s_eState, sizeof(s_eState));
	fileRead(pFile, &s_ePlayer, sizeof(s_ePlayer));
	fileRead(pFile, &s_ubHudOffsY, sizeof(s_ubHudOffsY));
	fileRead(pFile, &s_eGameMode, sizeof(s_eGameMode));
	fileRead(pFile, &s_is2pPlaying, sizeof(s_is2pPlaying));
	fileRead(pFile, &s_uwFrameDelay, sizeof(s_uwFrameDelay));
	fileRead(pFile, &s_uwStateCounter, sizeof(s_uwStateCounter));
	fileRead(pFile, &s_ePageCurrent, sizeof(s_ePageCurrent));
	fileRead(pFile, &s_uwMsgLen, sizeof(s_uwMsgLen));
	fileRead(pFile, &s_sMsgCharPos, sizeof(s_sMsgCharPos));
	fileRead(pFile, &s_ubMsgCharIdx, sizeof(s_ubMsgCharIdx));
	fileRead(pFile, s_szMsg, sizeof(s_szMsg));
	fileRead(pFile, s_szLetter, sizeof(s_szLetter));
	fileRead(pFile, &s_eFaceToDraw, sizeof(s_eFaceToDraw));
	// fileRead(pFile, &s_ubSelection, sizeof(s_ubSelection));
	// fileRead(pFile, &s_ubSelectionPrev, sizeof(s_ubSelectionPrev));

	hudRefresh();
	return saveReadTag(pFile, SAVE_TAG_HUD_END);
}

void hudSetDepth(UBYTE ubPlayer, UWORD uwDepth) {
	s_pPlayerData[ubPlayer].uwDepth = uwDepth;
}

void hudSetTime(UWORD uwTime) {
	s_pPlayerData[0].uwTime = uwTime;
}

void hudSetCash(UBYTE ubPlayer, LONG lCash) {
	if(lCash > 99999) {
		lCash = 99999;
	}
	s_pPlayerData[ubPlayer].lCash = lCash;
}

void hudSetCargo(UBYTE ubPlayer, UBYTE ubCargo, UBYTE ubCargoMax) {
	s_pPlayerData[ubPlayer].ubCargo = ubCargo;
	s_pPlayerData[ubPlayer].ubCargoMax = ubCargoMax;
}

void hudSetDrill(UBYTE ubPlayer, UWORD uwDrill, UWORD uwDrillMax) {
	s_pPlayerData[ubPlayer].uwDrill = uwDrill;
	s_pPlayerData[ubPlayer].uwDrillMax = uwDrillMax;
}

void hudSetHull(UBYTE ubPlayer, UWORD uwHull, UWORD uwHullMax) {
	s_pPlayerData[ubPlayer].uwHull = uwHull;
	s_pPlayerData[ubPlayer].uwHullMax = uwHullMax;
}

static void hudDrawStateBarPercent(
	UWORD uwOffsX, UBYTE ubOffsY, UBYTE ubPercent, UBYTE ubColor
) {
	// This draws only 0..99! 0: only 1px of first bar, 99: full
	UBYTE ubBarIdx = ubPercent / 10;
	UBYTE ubBarY = 4 - (UBYTE)((ubPercent % 10) * 4) / 9;
	UWORD uwX = uwOffsX + ubBarIdx * 3;
	chunkyToPlanar(ubColor, uwX + 0, ubOffsY + ubBarY, s_pHudBuffer->pBack);
	chunkyToPlanar(ubColor, uwX + 1, ubOffsY + ubBarY, s_pHudBuffer->pBack);
}

void hudClearInboxNotification(void) {
	blitRect(
		s_pHudBuffer->pBack, MSG_ICON_X, MSG_ICON_Y,
		MSG_ICON_WIDTH, MSG_ICON_HEIGHT, HUD_COLOR_BG
	);
}

void hudProcess(void) {
	tHudPlayerData * const pData = &s_pPlayerData[s_ePlayer];
	char szBfr[20];
	UBYTE ubPercent;
	UWORD uwDepth;
	LONG lCash;
	static UBYTE isDrawPending = 0;
	static UBYTE isLineOverflow = 0;
	switch(s_eState) {
		case STATE_MAIN_PREPARE_TIME:
			if(s_pPlayerData[0].uwTime != s_pPlayerData[0].uwTimeDisp) {
				s_pPlayerData[0].uwTimeDisp = s_pPlayerData[0].uwTime;
				stringDecimalFromULong(s_pPlayerData[0].uwTime, szBfr);
				fontFillTextBitMap(s_pFont, s_pLineBuffer, szBfr);
				s_isBitmapFilled = 1;
				isDrawPending = 1;
				s_eState = STATE_MAIN_DRAW_DEPTH;
				break;
			}
			s_eState = STATE_MAIN_DRAW_DEPTH;
			break;
		case STATE_MAIN_PREPARE_DEPTH:
			if(s_is2pPlaying) {
				uwDepth = (s_pPlayerData[0].uwDepth + s_pPlayerData[1].uwDepth) / 2;
			}
			else {
				uwDepth = s_pPlayerData[0].uwDepth;
			}
			if(uwDepth != pData->uwDepthDisp) {
				char *pEnd = szBfr;
				pEnd = stringDecimalFromULong(uwDepth / 10, pEnd);
				*(pEnd++) = '.';
				pEnd = stringDecimalFromULong(uwDepth % 10, pEnd);
				*(pEnd++) = 'm';
				*(pEnd++) = '\0';
				fontFillTextBitMap(s_pFont, s_pLineBuffer, szBfr);
				s_isBitmapFilled = 1;
				pData->uwDepthDisp = uwDepth;
				s_eState = STATE_MAIN_DRAW_DEPTH;
				isDrawPending = 1;
				break;
			}
			// fallthrough if value is the same
		case STATE_MAIN_DRAW_DEPTH:
			if(isDrawPending) {
				// decreased clear height 'cuz digits are smaller than whole font
				blitRect(
					s_pHudBuffer->pBack, GAUGE_DEPTH_X, ROW_2_Y,
					320 - (GAUGE_DEPTH_X + HUD_ORIGIN_X), s_ubLineHeight - 2, HUD_COLOR_BG
				);
				fontDrawTextBitMap(
					s_pHudBuffer->pBack, s_pLineBuffer,
					GAUGE_DEPTH_X, ROW_2_Y - 3, HUD_COLOR_BAR_FULL, FONT_LAZY | FONT_COOKIE
				);
				s_isBitmapFilled = 0;
				s_eState = STATE_MAIN_PREPARE_CASH;
				isDrawPending = 0;
				break;
			}
			// fallthrough if doesn't need to draw new value
		case STATE_MAIN_PREPARE_CASH:
			if(s_eGameMode == GAME_MODE_CHALLENGE) {
				lCash = s_pPlayerData[s_ePlayer].lCash;
			}
			else {
				lCash = s_pPlayerData[0].lCash + s_pPlayerData[1].lCash;
			}
			lCash = MIN(lCash, 99999); // Prevent trashing inbox icon
			if(lCash != pData->lCashDisp) {
				ULONG ulDisp;
				char *pEnd = szBfr;
				if(lCash < 0) {
					ulDisp = -lCash;
					*(pEnd++) = '-';
				}
				else {
					ulDisp = lCash;
				}
				char *pStart = pEnd;
				pEnd = stringDecimalFromULong(ulDisp, pEnd);
				*(pEnd++) = '\x1F';
				*pEnd = '\0';
				char *pSeparator = pEnd - 4;
				while(pSeparator > pStart) {
					char *pSrc = pEnd;
					char *pDst = ++pEnd;
					while(pDst != pSeparator) {
						*(pDst--) = *(pSrc--);
					}
					*pSeparator = '.';
					pSeparator -= 3;
				}
				fontFillTextBitMap(s_pFont, s_pLineBuffer, szBfr);
				s_isBitmapFilled = 1;
				pData->lCashDisp = lCash;
				s_eState = STATE_MAIN_DRAW_CASH;
				isDrawPending = 1;
				break;
			}
			// fallthrough if value is the same
		case STATE_MAIN_DRAW_CASH:
			if(isDrawPending) {
				// decreased clear height 'cuz digits are smaller than whole font
				UBYTE ubY = ((s_eGameMode == GAME_MODE_CHALLENGE) ? s_ubHudOffsY : ROW_1_Y);
				blitRect(
					s_pHudBuffer->pBack, GAUGE_CASH_X, ubY,
					320 - (GAUGE_CASH_X + HUD_ORIGIN_X + MSG_ICON_WIDTH),
					s_ubLineHeight - 1, HUD_COLOR_BG
				);
				fontDrawTextBitMap(
					s_pHudBuffer->pBack, s_pLineBuffer,
					GAUGE_CASH_X, ubY - 3, HUD_COLOR_BAR_FULL, FONT_LAZY | FONT_COOKIE
				);
				s_isBitmapFilled = 0;
				s_eState = STATE_MAIN_DRAW_FUEL;
				isDrawPending = 0;
				break;
			}
			// fallthrough if doesn't need to draw new value
		case STATE_MAIN_DRAW_FUEL:
			ubPercent = 0;
			if(pData->uwDrillMax) {
				ubPercent = (100 * pData->uwDrill) / pData->uwDrillMax;
			}
			if(pData->ubDrillDisp != ubPercent) {
				UBYTE ubColor, ubDraw;
				if(ubPercent > pData->ubDrillDisp) {
					ubDraw = pData->ubDrillDisp;
					++pData->ubDrillDisp;
					ubColor = HUD_COLOR_BAR_FULL;
				}
				else {
					--pData->ubDrillDisp;
					ubDraw = pData->ubDrillDisp;
					ubColor = HUD_COLOR_BAR_EMPTY;
				}
				hudDrawStateBarPercent(GAUGE_DRILL_X, s_ubHudOffsY, ubDraw, ubColor);
				s_eState = STATE_MAIN_DRAW_CARGO;
				break;
			}
			// fallthrough if doesn't need to draw new value
		case STATE_MAIN_DRAW_CARGO:
			ubPercent = 0;
			if(pData->ubCargoMax) {
				ubPercent = (100 * pData->ubCargo) / pData->ubCargoMax;
			}
			if(pData->ubCargoDisp != ubPercent) {
				UBYTE ubColor, ubDraw;
				if(ubPercent > pData->ubCargoDisp) {
					ubDraw = pData->ubCargoDisp;
					++pData->ubCargoDisp;
					ubColor = HUD_COLOR_BAR_FULL;
				}
				else {
					--pData->ubCargoDisp;
					ubDraw = pData->ubCargoDisp;
					ubColor = HUD_COLOR_BAR_EMPTY;
				}
				hudDrawStateBarPercent(GAUGE_CARGO_X, s_ubHudOffsY, ubDraw, ubColor);
				s_eState = STATE_MAIN_DRAW_HULL;
				break;
			}
			// fallthrough if doesn't need to draw new value
		case STATE_MAIN_DRAW_HULL:
			ubPercent = 0;
			if(pData->uwHullMax) {
				ubPercent = (100 * pData->uwHull) / pData->uwHullMax;
			}
			if(pData->ubHullDisp != ubPercent) {
				UBYTE ubColor, ubDraw;
				if(ubPercent > pData->ubHullDisp) {
					ubDraw = pData->ubHullDisp;
					++pData->ubHullDisp;
					ubColor = HUD_COLOR_BAR_FULL;
				}
				else {
					--pData->ubHullDisp;
					ubDraw = pData->ubHullDisp;
					ubColor = HUD_COLOR_BAR_EMPTY;
				}
				hudDrawStateBarPercent(GAUGE_HULL_X, s_ubHudOffsY, ubDraw, ubColor);
				s_eState = STATE_MAIN_DRAW_END;
				break;
			}
			// fallthrough if doesn't need to draw new value
		case STATE_MAIN_DRAW_END:
			// Cycle players and start again
			if(s_ePlayer == PLAYER_1) {
				s_ePlayer = PLAYER_2;
				s_ubHudOffsY = ROW_2_Y;
				s_eState = ((s_eGameMode == GAME_MODE_CHALLENGE) ? STATE_MAIN_PREPARE_CASH : STATE_MAIN_DRAW_FUEL);
			}
			else {
				hudResetStateMachine();
			}
			break;
		case STATE_MSG_NOISE_IN:
			if(--s_uwFrameDelay == 0) {
				s_eState = STATE_MSG_DRAW_FACE;
			}
			else if(++s_uwStateCounter >= 4) {
				hudShowPage(HUD_PAGE_NOISE_1 + (s_uwFrameDelay % 3));
				s_uwStateCounter = 0;
			}
			break;
		case STATE_MSG_DRAW_FACE:
			audioMixerPlaySfx(s_pSfxMsg, SFX_CHANNEL_HUD, SFX_PRIORITY_HUD, 0);
			isLineOverflow = 0;
			s_sMsgCharPos.uwX = HUD_ORIGIN_X;
			s_sMsgCharPos.uwY = 4 * HUD_HEIGHT + HUD_ORIGIN_Y;

			blitCopy(
				s_pFaces, 0, s_eFaceToDraw * HUD_FACE_SIZE,
				s_pHudBuffer->pBack, s_sMsgCharPos.uwX, s_sMsgCharPos.uwY,
				HUD_FACE_SIZE, HUD_FACE_SIZE, MINTERM_COOKIE
			);
			s_sMsgCharPos.uwX += HUD_FACE_SIZE + 1;
			blitRect(
				s_pHudBuffer->pBack, s_sMsgCharPos.uwX, s_sMsgCharPos.uwY - 1,
				283, 2 * s_ubLineHeight + 3, HUD_COLOR_BG
			);
			s_sMsgCharPos.uwY -= 2;

			hudShowPage(HUD_PAGE_MSG);
			s_ubMsgCharIdx = 0;
			s_uwMsgLen = strlen(s_szMsg);
			s_eState = STATE_MSG_PREPARE_LETTER;
			break;
		case STATE_MSG_PREPARE_LETTER:
			s_szLetter[0] = s_szMsg[s_ubMsgCharIdx];
			if(s_szMsg[s_ubMsgCharIdx] != '\n') {
				fontFillTextBitMap(s_pFont, s_pLineBuffer, s_szLetter);
			}
			s_isBitmapFilled = 1;
			s_eState = STATE_MSG_DRAW_LETTER;
			break;
		case STATE_MSG_DRAW_LETTER:
			if(s_szMsg[s_ubMsgCharIdx] == '\n') {
				s_sMsgCharPos.uwX = HUD_ORIGIN_X + HUD_FACE_SIZE + 1;
				s_sMsgCharPos.uwY += s_ubLineHeight + 1;
				isLineOverflow = 0;
			}
			else {
				UBYTE ubGlyphWidth = fontGlyphWidth(s_pFont, s_szMsg[s_ubMsgCharIdx]);
				if(
					!isLineOverflow &&
					s_sMsgCharPos.uwX + ubGlyphWidth <= HUD_ORIGIN_X + HUD_FACE_SIZE + 1 + 283
				) {
					fontDrawTextBitMap(
						s_pHudBuffer->pBack, s_pLineBuffer,
						s_sMsgCharPos.uwX, s_sMsgCharPos.uwY, HUD_COLOR_BAR_FULL, FONT_COOKIE
					);
					s_sMsgCharPos.uwX += ubGlyphWidth + 1;
				}
				else {
					isLineOverflow = 1;
				}
			}
			s_isBitmapFilled = 0;
			if(++s_ubMsgCharIdx >= s_uwMsgLen) {
				s_eState = STATE_MSG_WAIT_OUT;
				s_uwFrameDelay = 0;
			}
			else {
				s_eState = STATE_MSG_PREPARE_LETTER;
			}
			break;
		case STATE_MSG_WAIT_OUT:
			if (++s_uwFrameDelay == HUD_MSG_WAIT_CNT) {
				s_eState = STATE_MSG_NOISE_OUT;
				s_uwFrameDelay = HUD_NOISE_DURATION;
				audioMixerPlaySfx(s_pSfxNoise, SFX_CHANNEL_HUD, SFX_PRIORITY_HUD, 0);
			}
			break;
		case STATE_MSG_NOISE_OUT:
			if(--s_uwFrameDelay == 0) {
				s_eState = STATE_MSG_END;
			}
			else if(++s_uwStateCounter >= 4) {
				hudShowPage(HUD_PAGE_NOISE_1 + (s_uwFrameDelay % 3));
				s_uwStateCounter = 0;
			}
			break;
		case STATE_MSG_END:
			tInboxState eState = inboxGetState();
			switch(eState) {
				case INBOX_STATE_NONE:
					hudClearInboxNotification();
					break;
				case INBOX_STATE_PENDING:
					blitCopy(
						s_pFaces, 0, HUD_ICON_INBOX_SRC_OFFS_Y, s_pHudBuffer->pBack, MSG_ICON_X + 2, MSG_ICON_Y,
						MSG_ICON_WIDTH - 2, MSG_ICON_HEIGHT,
						MINTERM_COOKIE
					);
					break;
				case INBOX_STATE_URGENT:
					blitCopy(
						s_pFaces, 0, HUD_ICON_INBOX_SRC_OFFS_Y, s_pHudBuffer->pBack, MSG_ICON_X, MSG_ICON_Y,
						MSG_ICON_WIDTH, MSG_ICON_HEIGHT,
						MINTERM_COOKIE
					);
					break;
			}
			hudShowPage(HUD_PAGE_MAIN);
			hudResetStateMachine();
			break;
		case STATE_PAUSE_INITIAL_DRAW: {
				const UWORD uwPageOriginY = HUD_PAGE_PAUSE * HUD_HEIGHT + HUD_ORIGIN_Y;
				blitRect(
					s_pHudBuffer->pBack, HUD_ORIGIN_X, uwPageOriginY,
					320 - 2 * HUD_ORIGIN_X, 2 * s_ubLineHeight + 1, HUD_COLOR_BG
				);

				fontFillTextBitMap(s_pFont, s_pLineBuffer, g_pMsgs[MSG_HUD_PAUSED]);
				fontDrawTextBitMap(
					s_pHudBuffer->pBack, s_pLineBuffer,
					HUD_ORIGIN_X + (320 - HUD_ORIGIN_X) / 2,
					uwPageOriginY - 3, HUD_COLOR_BAR_FULL, FONT_COOKIE | FONT_HCENTER
				);
				hudShowPage(HUD_PAGE_PAUSE);
				s_eState = STATE_PAUSE_LOOP;
				s_ubSelection = 0;
				s_ubSelectionPrev = 1;
		} break;
		case STATE_PAUSE_LOOP:
			if(s_ubSelection != s_ubSelectionPrev) {
				const UWORD uwPageOriginY = HUD_PAGE_PAUSE * HUD_HEIGHT + HUD_ORIGIN_Y;
				if(s_eGameMode == GAME_MODE_CHALLENGE) {
					fontFillTextBitMap(s_pFont, s_pLineBuffer, g_pMsgs[MSG_HUD_RESUME]);
					fontDrawTextBitMap(
						s_pHudBuffer->pBack, s_pLineBuffer,
						HUD_ORIGIN_X + (320 - HUD_ORIGIN_X) / 3,
						uwPageOriginY - 3 + s_ubLineHeight,
						(s_ubSelection == 0) ? HUD_COLOR_BAR_FULL : HUD_COLOR_BAR_EMPTY,
						FONT_COOKIE | FONT_HCENTER
					);

					fontFillTextBitMap(s_pFont, s_pLineBuffer, g_pMsgs[MSG_HUD_QUIT]);
					fontDrawTextBitMap(
						s_pHudBuffer->pBack, s_pLineBuffer,
						HUD_ORIGIN_X + 2 * (320 - HUD_ORIGIN_X) / 3,
						uwPageOriginY - 3 + s_ubLineHeight,
						(s_ubSelection == 1) ? HUD_COLOR_BAR_FULL : HUD_COLOR_BAR_EMPTY,
						FONT_COOKIE | FONT_HCENTER
					);
				}
				else {
					fontFillTextBitMap(s_pFont, s_pLineBuffer, g_pMsgs[MSG_HUD_RESUME]);
					fontDrawTextBitMap(
						s_pHudBuffer->pBack, s_pLineBuffer,
						HUD_ORIGIN_X + 1 * (320 - HUD_ORIGIN_X) / 4,
						uwPageOriginY - 3 + s_ubLineHeight,
						(s_ubSelection == 0) ? HUD_COLOR_BAR_FULL : HUD_COLOR_BAR_EMPTY,
						FONT_COOKIE | FONT_HCENTER
					);

					fontFillTextBitMap(s_pFont, s_pLineBuffer, g_pMsgs[MSG_HUD_SAVE]);
					fontDrawTextBitMap(
						s_pHudBuffer->pBack, s_pLineBuffer,
						HUD_ORIGIN_X + 2 * (320 - HUD_ORIGIN_X) / 4,
						uwPageOriginY - 3 + s_ubLineHeight,
						(s_ubSelection == 1) ? HUD_COLOR_BAR_FULL : HUD_COLOR_BAR_EMPTY,
						FONT_COOKIE | FONT_HCENTER
					);

					fontFillTextBitMap(s_pFont, s_pLineBuffer, g_pMsgs[MSG_HUD_SAVE_QUIT]);
					fontDrawTextBitMap(
						s_pHudBuffer->pBack, s_pLineBuffer,
						HUD_ORIGIN_X + 3 * (320 - HUD_ORIGIN_X) / 4,
						uwPageOriginY - 3 + s_ubLineHeight,
						(s_ubSelection == 2) ? HUD_COLOR_BAR_FULL : HUD_COLOR_BAR_EMPTY,
						FONT_COOKIE | FONT_HCENTER
					);
				}
				s_ubSelectionPrev = s_ubSelection;
			}
			break;
	}
}

void hudDestroy(void) {
	fontDestroyTextBitMap(s_pLineBuffer);
	bitmapDestroy(s_pFaces);
	ptplayerSfxDestroy(s_pSfxNoise);
	ptplayerSfxDestroy(s_pSfxMsg);
}

void hudShowMain(void) {
	hudShowPage(HUD_PAGE_MAIN);
}
