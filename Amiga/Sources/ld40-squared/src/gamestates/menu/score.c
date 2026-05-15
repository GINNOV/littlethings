#include "gamestates/menu/score.h"
#include <stdio.h>
#include <string.h>
#include <ace/generic/screen.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/game.h>
#include "main.h"
#include "gamestates/menu/menu.h"
#include "gamestates/game/game.h"

#define SCORE_COUNT 10
#define SCORE_NAME_LENGTH 10

static UWORD s_pScores[SCORE_COUNT];
static char s_pScoreNames[SCORE_COUNT][SCORE_NAME_LENGTH+1];
static UBYTE s_ubNewNameLength;
static tState s_sStateHiScoreEntry;
static tState s_sStateHiScoreView;

void scoreLoadBest(void) {
	// tFile *pScoreFile = fileOpen("data/scores.txt", "rb");
	// char szDummy[SCORE_NAME_LENGTH+1];
	// fscanf(pScoreFile, "%hu %s", &g_uwHiScore, szDummy);
	// for(UBYTE i = 0; i != SCORE_COUNT-1; ++i) {
	// 	fscanf(pScoreFile, "%hu %s", &g_uwLoScore, szDummy);
	// }
	// fileClose(pScoreFile);

	logWrite("Best: %hu, worst: %hu\n", g_uwHiScore, g_uwLoScore);
}

void scoreSave(void) {
	tFile *pScoreFile = fileOpen("data/scores.txt", "wb");
	for(UBYTE i = 0; i != SCORE_COUNT; ++i) {
		char szBfr[20];
		UBYTE ubLength = sprintf(szBfr, "%hu %s\n", s_pScores[i], s_pScoreNames[i]);
		fileWrite(pScoreFile, szBfr, ubLength);
	}
	fileClose(pScoreFile);
}

static UBYTE s_ubNewScorePos;

void scoreDisplay(UBYTE isNew) {
	logBlockBegin("scoreDisplay(isNew: %hhu)", isNew);
	viewLoad(0);
	blitRect(g_pMenuBfrMgr->pBack, 0, 0, SCREEN_PAL_WIDTH, SCREEN_PAL_HEIGHT, 0);
	// tFile *pScoreFile = fileOpen("data/scores.txt", "rb");
	// for(UBYTE i = 0; i != SCORE_COUNT; ++i)
	// 	fscanf(pScoreFile, "%hu %s", &s_pScores[i], s_pScoreNames[i]);
	// fileClose(pScoreFile);

	char szNewHeader[] = {"Enter your score!"};
	char szViewHeader[] = {"Top scores:"};
	char *szHeader;
	if(isNew) {
		// Find place for new score
		for(s_ubNewScorePos = 0; s_ubNewScorePos < SCORE_COUNT; ++s_ubNewScorePos) {
			if(s_pScores[s_ubNewScorePos] < g_uwScore)
				break;
		}
		if(s_ubNewScorePos >= SCORE_COUNT) {
			isNew = 0;
			szHeader = szViewHeader;
		}
		else {
			logWrite("New score at pos %hhu\n", s_ubNewScorePos);
			// Move worse score down
			for(BYTE i = SCORE_COUNT-2; i >= s_ubNewScorePos; --i) {
				strcpy(s_pScoreNames[i+1], s_pScoreNames[i]);
				s_pScores[i+1] = s_pScores[i];
			}

			// Make room for new score
			memset(s_pScoreNames[s_ubNewScorePos], 0, SCORE_NAME_LENGTH);
			s_ubNewNameLength = 0;
			s_pScores[s_ubNewScorePos] = g_uwScore;
			szHeader = szNewHeader;
		}
	}
	else
		szHeader = szViewHeader;

	fontDrawStr(
		g_pFont, g_pMenuBfrMgr->pBack,
		(SCREEN_PAL_WIDTH>>1),
		(SCREEN_PAL_HEIGHT >> 1) - 7*10,
		szHeader, 1, FONT_CENTER, g_pTextBitMap
	);

	// Display score
	char szScore[20];
	for(UBYTE i = 0; i != SCORE_COUNT; ++i) {
		if(strlen(s_pScoreNames[i])) {
			fontDrawStr(
				g_pFont, g_pMenuBfrMgr->pBack,
				(SCREEN_PAL_WIDTH>>1) - 50,
				(SCREEN_PAL_HEIGHT >> 1) - 5*10 + i*10,
				s_pScoreNames[i], 1, FONT_VCENTER | FONT_LEFT, g_pTextBitMap
			);
		}

		sprintf(szScore, "%hu", s_pScores[i]);
		fontDrawStr(
			g_pFont, g_pMenuBfrMgr->pBack,
			(SCREEN_PAL_WIDTH>>1) + 50,
			(SCREEN_PAL_HEIGHT >> 1) - 5*10 + i*10,
			szScore, 1, FONT_VCENTER | FONT_RIGHT, g_pTextBitMap
		);
	}

	// Go to loop
	if(isNew) {
		fontDrawStr(
			g_pFont, g_pMenuBfrMgr->pBack,
			(SCREEN_PAL_WIDTH>>1),
			(SCREEN_PAL_HEIGHT >> 1) + 7*10,
			"Press ENTER to save", 1, FONT_CENTER, g_pTextBitMap
		);
		statePush(g_pStateMachine, &s_sStateHiScoreEntry);
	}
	else {
		statePush(g_pStateMachine, &s_sStateHiScoreView);
	}
	viewLoad(g_pMenuBfrMgr->sCommon.pVPort->pView);
	logBlockEnd("scoreDisplay()");
}

void scoreEntryLoop(void) {
	if(keyUse(KEY_RETURN) || keyUse(KEY_NUMENTER)) {
		if(s_ubNewNameLength) {
			scoreSave();
		}
		statePop(g_pStateMachine);
		return;
	}
	if(keyUse(g_sKeyManager.ubLastKey)) {
		char c = g_pToAscii[g_sKeyManager.ubLastKey];
		if(
			(c >= 'A' && c <= 'Z') ||
			(c >= 'a' && c <= 'z') ||
			(c >= '0' && c <= '9')
		) {
			if(s_ubNewNameLength < SCORE_NAME_LENGTH) {
				s_pScoreNames[s_ubNewScorePos][s_ubNewNameLength] = c;
				++s_ubNewNameLength;
				fontDrawStr(
					g_pFont, g_pMenuBfrMgr->pBack,
					(SCREEN_PAL_WIDTH>>1) - 50,
					(SCREEN_PAL_HEIGHT >> 1) - 5*10 + s_ubNewScorePos*10,
					s_pScoreNames[s_ubNewScorePos], 1, FONT_VCENTER | FONT_LEFT, g_pTextBitMap
				);
			}
		}
	}
	vPortWaitForEnd(g_pMenuBfrMgr->sCommon.pVPort);
}

void scoreViewLoop(void) {
	if(
		keyUse(KEY_ESCAPE) || keyUse(KEY_NUMENTER) || keyUse(KEY_RETURN) ||
		keyUse(KEY_SPACE) || joyUse(JOY1_FIRE)
	) {
		statePop(g_pStateMachine);
	}
}

static tState s_sStateHiScoreEntry = {.cbLoop = scoreEntryLoop};
static tState s_sStateHiScoreView = {.cbLoop = scoreViewLoop};
