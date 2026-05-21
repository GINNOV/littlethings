/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "menu.h"
#include <ace/managers/blit.h>
#include <ace/managers/game.h>
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/utils/string.h>
#include <mini_std/stdio.h>
#include "display.h"
#include "assets.h"
#include "menu_list.h"
#include "chaos_arena.h"
#include "steer.h"
#include "warrior.h"

//---------------------------------------------------------------------- DEFINES

#define MENU_WIDTH 224
#define MENU_HEIGHT 184
#define MENU_DISPLAY_START_X ((DISPLAY_WIDTH - MENU_WIDTH) / 2)
#define MENU_DISPLAY_START_Y ((DISPLAY_HEIGHT - MENU_HEIGHT) / 2)
#define MENU_DISPLAY_END_Y (MENU_DISPLAY_START_Y + MENU_HEIGHT)
#define MENU_COLOR_BG 0
#define MENU_COLOR_INACTIVE 10
#define MENU_COLOR_ACTIVE 12
#define MENU_COLOR_TITLE 11
#define MENU_COLOR_FOOTER 3
#define APPEAR_ANIM_SPEED 6
#define CHAOS_MARGIN_X ((MENU_WIDTH - 160) / 2)
#define CHAOS_MARGIN_Y ((MENU_HEIGHT - 160) / 2)

//-------------------------------------------------------------------------TYPES

typedef enum tMenuPage {
	MENU_PAGE_MAIN,
	MENU_PAGE_SUMMARY,
	MENU_PAGE_CREDITS,
} tMenuPage;

typedef enum tSteerKind {
	STEER_KIND_JOY1,
	STEER_KIND_JOY2,
	STEER_KIND_JOY3,
	STEER_KIND_JOY4,
	STEER_KIND_WSAD,
	STEER_KIND_ARROWS,
	STEER_KIND_OFF,
	STEER_KIND_COUNT,
} tSteerKind;

//---------------------------------------------------------------- PRIVATE DECLS

static void onStart(void);
static void onExitSelected(void);
static void onCredits(void);
static void onContinue(void);
static void onGoToMain(void);
static void onUndraw(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight);
static void onDrawPos(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
);

//----------------------------------------------------------------- PRIVATE VARS

static tSimpleBufferManager *s_pVpManager;
static tBitMap *s_pMenuBitmap;
static UBYTE s_pPlayersEnabled[PLAYER_MAX_COUNT] = {0, 0, 0, 0, 0, 0};
static UBYTE s_ubExtraEnemies = 0;
static UBYTE s_ubThunders = 0;
static tSteer s_pMenuSteers[PLAYER_MAX_COUNT];
static UBYTE s_pScores[PLAYER_MAX_COUNT];
static UWORD s_pLastDrawEnd[2];
static UBYTE s_isOdd;
static tMenuPage s_eCurrentPage;
static UBYTE s_ubLastWinner;

static const char * const s_pBoolEnumLabels[2] = {"OFF", "ON"};

static tMenuListOption s_pMenuMainOptions[] = {
	{.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK, .sOptCb = {.cbSelect = onStart}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_pPlayersEnabled[0],
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_pPlayersEnabled[1],
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_pPlayersEnabled[2],
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_pPlayersEnabled[3],
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_pPlayersEnabled[4],
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_pPlayersEnabled[5],
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_ubExtraEnemies,
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .sOptUb = {
		.isCyclic = 1, .pEnumLabels = s_pBoolEnumLabels, .pVar = &s_ubThunders,
		.ubMin = 0, .ubMax = 1
	}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK, .sOptCb = {.cbSelect = onCredits}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK, .sOptCb = {.cbSelect = onExitSelected}},
};
#define MENU_MAIN_OPTION_COUNT ARRAY_SIZE(s_pMenuMainOptions)

static const char * const s_pMenuMainCaptions[MENU_MAIN_OPTION_COUNT] = {
	"BEGIN CHAOS",
	"Player 1 (Joy 1)",
	"Player 2 (Joy 2)",
	"Player 3 (Joy 3)",
	"Player 4 (Joy 4)",
	"Player 5 (Arrows)",
	"Player 6 (WSAD)",
	"Extra enemies",
	"Thunders",
	"Credits",
	"Exit",
};

static tMenuListOption s_pMenuSummaryOptions[] = {
	{.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK, .sOptCb = {.cbSelect = onContinue}},
	{.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK, .sOptCb = {.cbSelect = onGoToMain}}
};
#define MENU_SUMMARY_OPTION_COUNT ARRAY_SIZE(s_pMenuSummaryOptions)

static const char * const s_pMenuSummaryCaptions[MENU_SUMMARY_OPTION_COUNT] = {
	"CONTINUE CHAOS",
	"End game",
};

static const char *s_pCreditsLines[] = {
	"Chaos Arena by Last Minute Creations",
	"lastminutecreations.itch.io/chaos-arena",
	"  Graphics: Softiron",
	"  Sounds and music: Luc3k",
	"  Code: KaiN",
	"  Announcer voice by ELEKTRON",
	"  (youtube.com/c/ELEKTRON1)",
	"Game source code is available on",
	"  github.com/Last-Minute-Creations/chaosArena",
	"Used third party code and assets:",
	"  Amiga C Engine (github.com/AmigaPorts/ACE)",
	"  uni05_54 font (minimal.com/fonts)",
	"  Warrior graphics based on Puny characters",
	"  (merchant-shade.itch.io/16x16-puny-characters)",
	"",
	"Thanks for playing!"
};
#define MENU_CREDITS_LINE_COUNT ARRAY_SIZE(s_pCreditsLines)

//------------------------------------------------------------------ PRIVATE FNS

static UBYTE isAnyPlayerOn(void) {
	for(UBYTE i = 0; i < PLAYER_MAX_COUNT; ++i) {
		if(s_pPlayersEnabled[i]) {
			return 1;
		}
	}
	return 0;
}

static void menuDrawPage(tMenuPage ePage) {
	blitRect(s_pMenuBitmap, 0, 0, MENU_WIDTH, MENU_HEIGHT, MENU_COLOR_BG);
	blitCopy(g_pChaos, 0, 0, s_pMenuBitmap, CHAOS_MARGIN_X, CHAOS_MARGIN_Y, 160, 160, MINTERM_COPY);
	UBYTE ubLineHeight = g_pFontSmall->uwHeight + 1;

	if(ePage == MENU_PAGE_MAIN) {
		menuListInit(
			s_pMenuMainOptions, s_pMenuMainCaptions, MENU_MAIN_OPTION_COUNT,
			g_pFontSmall, 0, 40, onUndraw, onDrawPos
		);
		menuListSetActiveIndex(isAnyPlayerOn() ? 0 : 255);

		UWORD uwTitleWidth = bitmapGetByteWidth(g_pTitleBitmap) * 8;
		UWORD uwTitleHeight = g_pTitleBitmap->Rows;
		blitCopyMask(
			g_pTitleBitmap, 0, 0, s_pMenuBitmap,
			(MENU_WIDTH - uwTitleWidth) / 2, 5,
			uwTitleWidth, uwTitleHeight, g_pTitleMask->Planes[0]
		);

		fontDrawStr(
			g_pFontSmall, s_pMenuBitmap, MENU_WIDTH - 5, 5,
			"v." GAME_VERSION,
			MENU_COLOR_FOOTER, FONT_COOKIE | FONT_SHADOW | FONT_RIGHT, g_pTextBitmap
		);

		UWORD uwY = MENU_HEIGHT - ubLineHeight - 5;
		fontDrawStr(
			g_pFontSmall, s_pMenuBitmap, MENU_WIDTH / 2, uwY,
			"A game by Last Minute Creations",
			MENU_COLOR_FOOTER, FONT_COOKIE | FONT_SHADOW | FONT_HCENTER, g_pTextBitmap
		);
	}
	else if(ePage == MENU_PAGE_SUMMARY) {
		char szEntry[20];
		if(s_ubLastWinner < PLAYER_MAX_COUNT && s_pPlayersEnabled[s_ubLastWinner]) {
			char *pEnd = szEntry;
			pEnd = stringCopy("PLAYER ", pEnd);
			pEnd = stringDecimalFromULong(s_ubLastWinner + 1, pEnd);
			pEnd = stringCopy(" WINS", pEnd);
		}
		else if(s_ubLastWinner == WARRIOR_LAST_ALIVE_INDEX_INVALID) {
			stringCopy("DRAW", szEntry);
		}
		else {
			stringCopy("DEFEATED", szEntry);
		}
		fontDrawStr(
			g_pFontBig, s_pMenuBitmap, MENU_WIDTH / 2, 20, szEntry,
			MENU_COLOR_TITLE, FONT_COOKIE | FONT_SHADOW | FONT_HCENTER, g_pTextBitmap
		);

		UWORD uwY = 50;
		fontDrawStr(
			g_pFontSmall, s_pMenuBitmap, MENU_WIDTH / 2, uwY, "Scores so far:",
			MENU_COLOR_ACTIVE, FONT_COOKIE | FONT_SHADOW | FONT_HCENTER, g_pTextBitmap
		);
		uwY += 15;
		for(UBYTE i = 0; i < PLAYER_MAX_COUNT; ++i) {
			if(s_pPlayersEnabled[i]) {
				char *pEnd = szEntry;
				pEnd = stringCopy("Player ", pEnd);
				pEnd = stringDecimalFromULong(i + 1, pEnd);
				pEnd = stringCopy(": ", pEnd);
				pEnd = stringDecimalFromULong(s_pScores[i], pEnd);
				fontDrawStr(
					g_pFontSmall, s_pMenuBitmap, MENU_WIDTH / 2, uwY, szEntry,
					MENU_COLOR_INACTIVE, FONT_COOKIE | FONT_SHADOW | FONT_HCENTER, g_pTextBitmap
				);
				uwY += ubLineHeight;
			}
		}

		menuListInit(
			s_pMenuSummaryOptions, s_pMenuSummaryCaptions, MENU_SUMMARY_OPTION_COUNT,
			g_pFontSmall, 0, MENU_HEIGHT - 4 * ubLineHeight, onUndraw, onDrawPos
		);
	}
	else { // MENU_PAGE_CREDITS
		UWORD uwY = 5;
		for(UBYTE ubLine = 0; ubLine < MENU_CREDITS_LINE_COUNT; ++ubLine) {
			if(!stringIsEmpty(s_pCreditsLines[ubLine])) {
				fontDrawStr(
					g_pFontSmall, s_pMenuBitmap, 5, uwY, s_pCreditsLines[ubLine],
					s_pCreditsLines[ubLine][0] == ' ' ? MENU_COLOR_INACTIVE : MENU_COLOR_TITLE,
					FONT_COOKIE | FONT_SHADOW, g_pTextBitmap
				);
			}
			uwY += ubLineHeight;
		}
	}

	if(ePage != MENU_PAGE_CREDITS) {
		menuListDraw();
	}
}

static void menuNavigateToPage(tMenuPage ePage) {
	s_eCurrentPage = ePage;
	menuDrawPage(ePage);
}

static UBYTE menuProcessDrawIn(void) {
	if(s_pLastDrawEnd[s_isOdd] >= DISPLAY_HEIGHT - DISPLAY_MARGIN_SIZE) {
		return 0;
	}

	UWORD uwStartRow = s_pLastDrawEnd[s_isOdd];
	UWORD uwEndRow;

	if(s_pLastDrawEnd[s_isOdd] < MENU_DISPLAY_START_Y) {
		uwEndRow = MIN(s_pLastDrawEnd[!s_isOdd] + APPEAR_ANIM_SPEED, MENU_DISPLAY_START_Y);
		blitRect(
			s_pVpManager->pBack, DISPLAY_MARGIN_SIZE, uwStartRow,
			DISPLAY_WIDTH - 2 * DISPLAY_MARGIN_SIZE, uwEndRow - uwStartRow, MENU_COLOR_BG
		);
	}
	else if(
		MENU_DISPLAY_START_Y <= s_pLastDrawEnd[s_isOdd] &&
		s_pLastDrawEnd[s_isOdd] < MENU_DISPLAY_END_Y
	) {
		uwEndRow = MIN(s_pLastDrawEnd[!s_isOdd] + APPEAR_ANIM_SPEED, MENU_DISPLAY_END_Y);
		blitRect(
			s_pVpManager->pBack, DISPLAY_MARGIN_SIZE, uwStartRow,
			DISPLAY_WIDTH - 2 * DISPLAY_MARGIN_SIZE, uwEndRow - uwStartRow, MENU_COLOR_BG
		);
		blitCopyAligned(
			s_pMenuBitmap, 0, uwStartRow - MENU_DISPLAY_START_Y, s_pVpManager->pBack,
			MENU_DISPLAY_START_X, uwStartRow, MENU_WIDTH, uwEndRow - uwStartRow
		);
	}
	else {
		uwEndRow = MIN(
			s_pLastDrawEnd[!s_isOdd] + APPEAR_ANIM_SPEED,
			DISPLAY_HEIGHT - DISPLAY_MARGIN_SIZE
		);
		blitRect(
			s_pVpManager->pBack, DISPLAY_MARGIN_SIZE, uwStartRow,
			DISPLAY_WIDTH - 2 * DISPLAY_MARGIN_SIZE, uwEndRow - uwStartRow, MENU_COLOR_BG
		);
	}

	s_pLastDrawEnd[s_isOdd] = uwEndRow;
	s_isOdd = !s_isOdd;
	return 1;
}

static void menuGsCreate(void) {
	ptplayerLoadMod(g_pModMenu, g_pModSamples, 0);
	ptplayerEnableMusic(1);

	s_pMenuBitmap = bitmapCreate(MENU_WIDTH, MENU_HEIGHT, DISPLAY_BPP, BMF_INTERLEAVED);
	systemUnuse();
	s_pVpManager = displayGetManager();
	UBYTE isParallel = joyIsParallelEnabled();

	UBYTE ubPlayer = 0;
	s_pMenuSteers[ubPlayer++] = steerInitFromMode(STEER_MODE_JOY_1, 0);
	s_pMenuSteers[ubPlayer++] = steerInitFromMode(STEER_MODE_JOY_2, 0);
	s_pMenuSteers[ubPlayer++] = steerInitFromMode(isParallel ? STEER_MODE_JOY_3 : STEER_MODE_IDLE, 0);
	s_pMenuSteers[ubPlayer++] = steerInitFromMode(isParallel ? STEER_MODE_JOY_4 : STEER_MODE_IDLE, 0);
	s_pMenuSteers[ubPlayer++] = steerInitFromMode(STEER_MODE_KEY_ARROWS, 0);
	s_pMenuSteers[ubPlayer++] = steerInitFromMode(STEER_MODE_KEY_WSAD, 0);

	menuDrawPage(s_eCurrentPage);
	s_pLastDrawEnd[0] = DISPLAY_MARGIN_SIZE;
	s_pLastDrawEnd[1] = DISPLAY_MARGIN_SIZE;
	s_isOdd = 0;
}

static void menuGsLoop(void) {
	tFadeState eFadeState = displayFadeProcess();
	if(eFadeState == FADE_STATE_EVENT_FIRED) {
		return;
	}

	const UBYTE isInReplayMode = 0;
	if(menuProcessDrawIn()) {
		return;
	}

	if(!isInReplayMode && eFadeState == FADE_STATE_IDLE && keyUse(KEY_ESCAPE)) {
		if(s_eCurrentPage == MENU_PAGE_MAIN) {
			onExitSelected();
		}
		else {
			menuNavigateToPage(MENU_PAGE_MAIN);
		}
		return;
	}

	UBYTE isNavigatingUpDown = 0;
	UBYTE isNavigatingToggle = 0;
	for(UBYTE ubPlayer = 0; ubPlayer < PLAYER_MAX_COUNT; ++ubPlayer) {
		tSteer *pSteer = &s_pMenuSteers[ubPlayer];
		steerProcess(pSteer);

		if(!s_pPlayersEnabled[ubPlayer]) {
			if(steerDirUse(pSteer, DIRECTION_FIRE)) {
				s_pPlayersEnabled[ubPlayer] = 1;
				s_pMenuMainOptions[1 + ubPlayer].eDirty |= MENU_LIST_DIRTY_VAL_CHANGE;
				ptplayerSfxPlay(g_pSfxSwipeHit, 3, PTPLAYER_VOLUME_MAX, 10);
				if(menuListGetActiveIndex() == 255) {
					menuListSetActiveIndex(0);
				}
			}
			continue;
		}

		if(eFadeState != FADE_STATE_OUT) {
			if(s_eCurrentPage == MENU_PAGE_CREDITS) {
				if(eFadeState == FADE_STATE_IDLE && (
					steerDirUse(pSteer, DIRECTION_FIRE) ||
					(!isInReplayMode && keyUse(KEY_RETURN))
				)) {
					ptplayerSfxPlay(g_pSfxSwipeHit, 3, PTPLAYER_VOLUME_MAX, 10);
					menuNavigateToPage(MENU_PAGE_MAIN);
					return;
				}
			}
			else {
				if(steerDirUse(pSteer, DIRECTION_UP)) {
					isNavigatingUpDown |= menuListNavigate(-1);
				}
				else if(steerDirUse(pSteer, DIRECTION_DOWN)) {
					isNavigatingUpDown |= menuListNavigate(+1);
				}
				else if(steerDirUse(pSteer, DIRECTION_LEFT)) {
					isNavigatingToggle |= menuListToggle(-1);
				}
				else if(steerDirUse(pSteer, DIRECTION_RIGHT)) {
					isNavigatingToggle |= menuListToggle(+1);
				}
				else if (eFadeState == FADE_STATE_IDLE && (
					steerDirUse(pSteer, DIRECTION_FIRE) ||
					(!isInReplayMode && keyUse(KEY_RETURN))
				)) {
					const tMenuListOption *pOption = menuListGetActiveOption();
					if(pOption->eOptionType == MENU_LIST_OPTION_TYPE_CALLBACK) {
						if(pOption->sOptCb.cbSelect == onExitSelected) {
							ptplayerSfxPlay(g_pSfxNo, 3, PTPLAYER_VOLUME_MAX, 15);
						}
						else {
							ptplayerSfxPlay(g_pSfxSwipeHit, 3, PTPLAYER_VOLUME_MAX, 10);
						}
						menuListEnter();
						return;
					}
				}
			}
		}
	}

	if(isNavigatingToggle) {
		ptplayerSfxPlay(g_pSfxSwipeHit, 3, PTPLAYER_VOLUME_MAX, 10);
	}
	else if(isNavigatingUpDown) {
		ptplayerSfxPlay(g_pSfxSwipes[0], 3, PTPLAYER_VOLUME_MAX, 5);
	}

	if(s_eCurrentPage != MENU_PAGE_CREDITS) {
		menuListDraw();
	}

	blitCopyAligned(
		s_pMenuBitmap, 0, 0, s_pVpManager->pBack,
		MENU_DISPLAY_START_X, MENU_DISPLAY_START_Y,
		MENU_WIDTH, MENU_HEIGHT
	);
}

static void menuGsDestroy(void) {
	systemUse();
	bitmapDestroy(s_pMenuBitmap);
	ptplayerStop();
}

static void onStart(void) {
	for(UBYTE i = 0; i < PLAYER_MAX_COUNT; ++i) {
		s_pScores[i] = 0;
	}
	ptplayerWaitForSfx();
	stateChange(g_pStateMachineGame, &g_sStateGame);
}

static void onExitFadeoutCompleted(void) {
	gameExit();
}

static void onExitSelected(void) {
	displayFadeStart(0, onExitFadeoutCompleted);
}

static void onCredits(void) {
	menuNavigateToPage(MENU_PAGE_CREDITS);
}

static void onContinue(void) {
	stateChange(g_pStateMachineGame, &g_sStateGame);
}

static void onGoToMain(void) {
	menuNavigateToPage(MENU_PAGE_MAIN);
}

static void onUndraw(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight) {
	// Add 1 to height for font shadow
	++uwHeight;
	blitRect(s_pMenuBitmap, uwX, uwY, uwWidth, uwHeight, MENU_COLOR_BG);
	blitCopy(g_pChaos, 0, uwY - CHAOS_MARGIN_Y, s_pMenuBitmap, CHAOS_MARGIN_X, uwY, 160, uwHeight, MINTERM_COPY);
}

static void onDrawPos(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
) {
	UWORD uwTextWidth = fontMeasureText(g_pFontSmall, szText).uwX;
	fontDrawStr(
		g_pFontSmall, s_pMenuBitmap, uwX + MENU_WIDTH / 2, uwY, szText,
		isActive ? MENU_COLOR_ACTIVE : MENU_COLOR_INACTIVE,
		FONT_SHADOW | FONT_COOKIE | FONT_HCENTER, g_pTextBitmap
	);
	*pUndrawWidth = (MENU_WIDTH + uwTextWidth) / 2;
}

//------------------------------------------------------------------- PUBLIC FNS

tSteerMode menuGetSteerModeForPlayer(UBYTE ubPlayerIndex) {
	static const tSteerMode pSteersForPlayers[PLAYER_MAX_COUNT] = {
		STEER_MODE_JOY_1, STEER_MODE_JOY_2, STEER_MODE_JOY_3, STEER_MODE_JOY_4,
		STEER_MODE_KEY_ARROWS, STEER_MODE_KEY_WSAD
	};
	if(ubPlayerIndex >= PLAYER_MAX_COUNT || !s_pPlayersEnabled[ubPlayerIndex]) {
		return STEER_MODE_AI;
	}
	return pSteersForPlayers[ubPlayerIndex];
}

void menuSetupMain(void) {
	s_eCurrentPage = MENU_PAGE_MAIN;
}

void menuSetupSummary(UBYTE ubWinnerIndex) {
	s_eCurrentPage = MENU_PAGE_SUMMARY;
	s_ubLastWinner = ubWinnerIndex;
	if(
		ubWinnerIndex == WARRIOR_LAST_ALIVE_INDEX_INVALID ||
		!s_pPlayersEnabled[ubWinnerIndex]
	) {
		return;
	}
	++s_pScores[ubWinnerIndex];
}

UBYTE menuIsExtraEnemiesEnabled(void) {
	return s_ubExtraEnemies;
}

UBYTE menuAreThundersEnabled(void) {
	return s_ubThunders;
}

//------------------------------------------------------------------ PUBLIC VARS

tState g_sStateMenu = {
	.cbCreate = menuGsCreate, .cbLoop = menuGsLoop, .cbDestroy = menuGsDestroy
};
