/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "hi_score.h"
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/utils/bitmap.h>
#include <ace/utils/disk_file.h>
#include <ace/utils/string.h>
#include <comm/comm.h>
#include "defs.h"
#include "assets.h"
#include "game.h"
#include "achievement.h"
#include "msg.h"

#define SCORE_NAME_LENGTH 16
#define SCORE_COUNT 10
#define SCORE_CURSOR_BLINK_TICKS 25 // 25 ticks = 500ms
#define SCORE_RESULT_MSG_MAX 40

typedef struct tHiScore {
	LONG lScore;
	char szName[SCORE_NAME_LENGTH];
} tHiScore;

static tHiScore s_pScores[SCORE_MODE_COUNT][SCORE_COUNT];

static tHiScore s_pPrevScores[SCORE_MODE_COUNT][SCORE_COUNT] = {
	{
		{.lScore = 847, .szName = "Kanarki_rulez"},
		{.lScore = 812, .szName = "afrokamil"},
		{.lScore = 700, .szName = "Softiron"},
		{.lScore = 600, .szName = "Luc3k"},
		{.lScore = 500, .szName = "KaiN"},
		{.lScore = 400, .szName = "Krycha666"},
		{.lScore = 300, .szName = "MrNatas"},
		{.lScore = 200, .szName = "Mietek"},
		{.lScore = 100, .szName = "Tramiel"},
		{.lScore =  50, .szName = "Sordan"},
	},
	{
		{.lScore = 20530, .szName = "afrokamil"},
		{.lScore = 3097,  .szName = "Kanarki_rulez"},
		{.lScore = 2500,  .szName = "Luc3k"},
		{.lScore = 2000,  .szName = "Softiron"},
		{.lScore = 1500,  .szName = "KaiN"},
		{.lScore = 1000,  .szName = "Krycha666"},
		{.lScore = 500,  .szName = "MrNatas"},
		{.lScore = 300,  .szName = "Mietek"},
		{.lScore = 200,  .szName = "Tramiel"},
		{.lScore = 100,  .szName = "Sordan"},
	},
};

static UBYTE s_ubNewNameLength;
static UBYTE s_ubNewScorePos;
static UBYTE s_isEnteringHiScore;
static UBYTE s_isShift = 0;
static UBYTE s_isCursor = 0;
static UBYTE s_ubBlinkTicks = 0;
static char s_szResultMsg[SCORE_RESULT_MSG_MAX];
static tScoreMode s_eScoreMode;

void hiScoreLoad(void) {
	systemUse();
	if(diskFileExists("scores.dat")) {
		tFile *pFile = diskFileOpen("scores.dat", DISK_FILE_MODE_READ, 0);
		for(UBYTE ubMode = 0; ubMode < SCORE_MODE_COUNT; ++ubMode) {
			for(UBYTE i = 0; i < SCORE_COUNT; ++i) {
				fileRead(pFile, &s_pScores[ubMode][i], sizeof(s_pScores[ubMode][i]));
			}
		}
		fileClose(pFile);
		memcpy(s_pPrevScores, s_pScores, sizeof(s_pPrevScores));
	}
	else {
		memcpy(s_pScores, s_pPrevScores, sizeof(s_pScores));
	}
	systemUnuse();
}

static void hiScoreSave(void) {
	systemUse();
	tFile *pFile = diskFileOpen("scores.dat", DISK_FILE_MODE_WRITE, 1);
	if(pFile) {
		for(UBYTE ubMode = 0; ubMode < SCORE_MODE_COUNT; ++ubMode) {
			for(UBYTE i = 0; i < SCORE_COUNT; ++i) {
				fileWrite(pFile, &s_pScores[ubMode][i], sizeof(s_pScores[ubMode][i]));
			}
		}
		fileClose(pFile);
	}
	memcpy(s_pPrevScores, s_pScores, sizeof(s_pPrevScores));
	systemUnuse();
}

static void hiScoreDrawPosition(UBYTE ubPos) {
	UWORD uwY = ubPos * 10;
	UBYTE ubColor = (s_isEnteringHiScore && ubPos == s_ubNewScorePos)
		? COMM_DISPLAY_COLOR_TEXT_HOVER
		: COMM_DISPLAY_COLOR_TEXT;

	// Clear BG
	commErase(0, uwY, COMM_DISPLAY_WIDTH, commGetLineHeight());

	// Score name
	char szBfr[SCORE_NAME_LENGTH + 5];
	snprintf(szBfr, sizeof(szBfr), "%hhu. %s", ubPos + 1, s_pScores[s_eScoreMode][ubPos].szName);
	commDrawText(
		16, uwY, szBfr, FONT_LAZY | FONT_COOKIE | FONT_SHADOW, ubColor
	);

	// Score count
	stringDecimalFromULong(s_pScores[s_eScoreMode][ubPos].lScore, szBfr);
	commDrawText(
		COMM_DISPLAY_WIDTH - 16, uwY, szBfr,
		FONT_LAZY | FONT_COOKIE | FONT_RIGHT | FONT_SHADOW, ubColor
	);
}

void hiScoreDrawAll(void) {
	for(UBYTE ubPos = 0; ubPos < SCORE_COUNT; ++ubPos) {
		hiScoreDrawPosition(ubPos);
	}

	// End text
	commErase(
		0, COMM_DISPLAY_HEIGHT - g_pFont->uwHeight * 2,
		COMM_DISPLAY_WIDTH, g_pFont->uwHeight * 2
	);

	if(!stringIsEmpty(s_szResultMsg)) {
		commDrawText(
			COMM_DISPLAY_WIDTH / 2, COMM_DISPLAY_HEIGHT - g_pFont->uwHeight, s_szResultMsg,
			FONT_LAZY | FONT_COOKIE | FONT_HCENTER | FONT_BOTTOM,
			COMM_DISPLAY_COLOR_TEXT
		);
	}
	const char *szMsg = (
		g_pMsgs[hiScoreIsEnteringNew() ? MSG_HI_SCORE_NEW : MSG_HI_SCORE_PRESS]
	);
	commDrawText(
		COMM_DISPLAY_WIDTH / 2, COMM_DISPLAY_HEIGHT, szMsg,
		FONT_LAZY | FONT_COOKIE | FONT_HCENTER | FONT_BOTTOM,
		COMM_DISPLAY_COLOR_TEXT_HOVER
	);
}

void hiScoreEnteringProcess(void) {
	if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
		if(s_ubNewNameLength) {
			hiScoreSave();
		}
		else {
			// No entry provided - revert to old scores
			// not as hiScoreLoadFromFile() because it won't work if file was
			// not yet created
			memcpy(s_pScores, s_pPrevScores, sizeof(s_pScores));
		}
		s_isEnteringHiScore = 0;
		hiScoreDrawAll();
		return;
	}
	UBYTE isUpdateNeeded = 0;
	if(keyUse(KEY_LSHIFT) || keyUse(KEY_RSHIFT)) {
		s_isShift = 1;
	}
	else if(
		s_isShift &&
		keyCheck(KEY_LSHIFT) == KEY_NACTIVE &&
		keyCheck(KEY_RSHIFT) == KEY_NACTIVE
	) {
		s_isShift = 0;
	}
	else if(keyUse(g_sKeyManager.ubLastKey)) {
		isUpdateNeeded = 1;
		WORD wInput = g_pToAscii[g_sKeyManager.ubLastKey];
		if(s_isShift) {
			wInput -= 'a' - 'A';
		}
		if(
			(wInput >= 'A' && wInput <= 'Z') ||
			(wInput >= 'a' && wInput <= 'z') ||
			(wInput >= '0' && wInput <= '9')
		) {
			if(s_ubNewNameLength < SCORE_NAME_LENGTH) {
				s_pScores[s_eScoreMode][s_ubNewScorePos].szName[s_ubNewNameLength] = wInput;
				++s_ubNewNameLength;
			}
		}
		else if(g_sKeyManager.ubLastKey == KEY_BACKSPACE && s_ubNewNameLength){
			--s_ubNewNameLength;
			s_pScores[s_eScoreMode][s_ubNewScorePos].szName[s_ubNewNameLength] = '\0';
		}
		else {
			isUpdateNeeded = 0;
		}
	}

	if(++s_ubBlinkTicks >= SCORE_CURSOR_BLINK_TICKS) {
		s_ubBlinkTicks = 0;
		s_isCursor = !s_isCursor;
		isUpdateNeeded = 1;
	}

	if(isUpdateNeeded) {
		hiScoreDrawPosition(s_ubNewScorePos);
	}
}

UBYTE hiScoreIsEnteringNew(void) {
	return s_isEnteringHiScore;
}

void hiScoreSetup(LONG lScore, const char *szResult, tScoreMode eScoreMode) {
	s_eScoreMode = eScoreMode;
	if(szResult) {
		stringCopyLimited(szResult, s_szResultMsg, SCORE_RESULT_MSG_MAX);
	}
	s_isEnteringHiScore = 0;
	s_ubNewNameLength = 0;
	for(UBYTE i = 0; i < SCORE_COUNT; ++i) {
		if(s_pScores[s_eScoreMode][i].lScore < lScore) {
			s_isEnteringHiScore = 1;
			if(g_eGameMode == GAME_MODE_CHALLENGE) {
				achievementUnlock(ACHIEVEMENT_RECORD_HOLDER);
			}
			if(g_isAtari) {
				achievementUnlock(ACHIEVEMENT_MORE_COAL);
			}
			s_isShift = 0;
			s_isCursor = 0;
			s_ubBlinkTicks = 0;
			s_ubNewScorePos = i;

			// Move worse score down
			for(BYTE j = SCORE_COUNT-2; j >= s_ubNewScorePos; --j) {
				stringCopy(s_pScores[s_eScoreMode][j].szName, s_pScores[s_eScoreMode][j+1].szName);
				s_pScores[s_eScoreMode][j+1].lScore = s_pScores[s_eScoreMode][j].lScore;
			}
			// Make room for new score
			s_pScores[s_eScoreMode][s_ubNewScorePos].lScore = lScore;
			memset(s_pScores[s_eScoreMode][s_ubNewScorePos].szName, '\0', SCORE_NAME_LENGTH);
			break;
		}
	}
}
