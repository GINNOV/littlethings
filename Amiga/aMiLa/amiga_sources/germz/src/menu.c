/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "menu.h"
#include <ace/types.h>
#include <ace/managers/system.h>
#include <ace/managers/game.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/utils/font.h>
#include <ace/utils/palette.h>
#include <ace/managers/ptplayer.h>
#include <ace/utils/bmframe.h>
#include <ace/utils/file.h>
#include "game.h"
#include "fade.h"
#include "steer.h"
#include "germz.h"
#include "assets.h"
#include "map_list.h"
#include "menu_list.h"
#include "color.h"
#include "gui_scanlined.h"
#include "cutscene.h"
#include "music.h"

#define MENU_COLOR_ACTIVE (COLOR_P3_BRIGHT)
#define MENU_COLOR_INACTIVE (COLOR_P3_BRIGHT + 1)
#define MENU_COLOR_SHADOW (COLOR_P3_BRIGHT + 3)
#define MENU_COLOR_ERROR (COLOR_P2_BRIGHT)

#define INFO_X 46
#define INFO_Y 28
#define PREVIEW_X (INFO_X + 120)
#define PREVIEW_Y INFO_Y
#define BATTLE_MENU_X 75
#define BATTLE_MENU_Y 134
#define CAMPAIGN_MENU_Y 68
#define BATTLE_MENU_WIDTH 180
#define BATTLE_MENU_HEIGHT 93

static UBYTE s_ubBattleMode;
static UBYTE s_ubTeamCfg;
static UBYTE s_isCampaign;
static UBYTE s_ubMapCount;
static UBYTE s_ubStartingLevel = 1;
static UBYTE s_isStartWithCredits = 0;

static UBYTE s_pPlayerSteers[4] = {
	STEER_MODE_JOY_1, STEER_MODE_JOY_2,
	STEER_MODE_KEY_WSAD, STEER_MODE_KEY_ARROWS
};

	// [0:P1 .. 3:P4][0: inactive, 1: active]
static const UBYTE s_pScanlinedMenuColors[][2] = {
	{(COLOR_P1_BRIGHT + 2) >> 1, COLOR_P1_BRIGHT >> 1},
	{(COLOR_P2_BRIGHT + 2) >> 1, COLOR_P2_BRIGHT >> 1},
	{(COLOR_P3_BRIGHT + 2) >> 1, COLOR_P3_BRIGHT >> 1},
	{(COLOR_P4_BRIGHT + 2) >> 1, COLOR_P4_BRIGHT >> 1},
};

static const char *s_pMenuCaptions[] = {
	"CAMPAIGN",
	"BATTLE",
	"EDITOR",
	"HOW TO PLAY",
	"CREDITS",
	"CURE"
};

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pBfr;
static tBitMap *s_pBg, *s_pBgSub;
static tBitMap s_sBmFrontScanline;
static tFade *s_pFadeMenu;
static tCbFadeOnDone s_cbOnEscape;

static tStateManager *s_pStateMachineMenu;
static tState
	s_sStateMain, s_sStateBattle, s_sStateCampaign, s_sStateCredits,
	s_sStateHowTo, s_sStateSteer;

//------------------------------------------------------------------ PRIVATE FNS

static void onFadeoutEditorGameStart(void) {
	stateChange(g_pStateMachineGame, &g_sStateGame);
}

static void onFadeoutGameStart(void) {
	statePop(g_pStateMachineGame); // Pop from map select to main menu
	if(s_isCampaign) {
		if(s_ubStartingLevel == 1) {
			// Only intro when starting first level
			cutsceneSetup(0, &g_sStateGame);
			stateChange(g_pStateMachineGame, &g_sStateCutscene);
		}
		else {
			// Skip intro for later levels
			stateChange(g_pStateMachineGame, &g_sStateGame);
		}
	}
	else {
		stateChange(g_pStateMachineGame, &g_sStateGame);
	}
}

static void menuErrorMsg(const char *szMsg) {
	char szLine[80];
	const char *szLineStart = szMsg;
	UWORD uwOffsY = 124;
	UBYTE ubLineHeight = g_pFontSmall->uwHeight + 1;
	blitRect(
		&s_sBmFrontScanline, 48, uwOffsY, 320 - (2 * 48), ubLineHeight,
		COLOR_CONSOLE_BG >> 1
	);

	while(szLineStart) {
		const char *szLineEnd = strchr(szLineStart, '\n');
		if(szLineEnd) {
			UWORD uwLineWidth = szLineEnd - szLineStart;
			memcpy(szLine, szLineStart, uwLineWidth);
			szLine[uwLineWidth] = '\0';
			szLineStart = szLineEnd + 1;
		}
		else {
			UWORD uwLineWidth = strlen(szLineStart);
			memcpy(szLine, szLineStart, uwLineWidth);
			szLine[uwLineWidth] = '\0';
			szLineStart = 0;
		}
		fontDrawStr(
			g_pFontSmall, &s_sBmFrontScanline, 320/2, uwOffsY, szLine,
			MENU_COLOR_ERROR >> 1, FONT_COOKIE | FONT_HCENTER, g_pTextBitmap
		);
		uwOffsY += ubLineHeight;
	}
}

static void startGame(UBYTE isEditor, UBYTE ubPlayerMask, UBYTE ubCampaignStage) {
	// Menulist uses UBYTE[], gameSetRules expects tSteerMode[], so convert
	tSteerMode pSteers[4] = {
		s_pPlayerSteers[0], s_pPlayerSteers[1],
		s_pPlayerSteers[2], s_pPlayerSteers[3]
	};

	if(isEditor) {
		gameSetRules(1, BATTLE_MODE_FFA, TEAM_CONFIG_P1_P2_AND_P3_P4, 0, pSteers);
		fadeSet(s_pFadeMenu, FADE_STATE_OUT, 50, 1, onFadeoutEditorGameStart);
	}
	else {
		UBYTE pSteerToPlayer[STEER_MODE_AI] = {0};
		for(UBYTE i = 0; i < 4; ++i) {
			if((
				s_pPlayerSteers[i] == STEER_MODE_JOY_3 ||
				s_pPlayerSteers[i] == STEER_MODE_JOY_4
			) && !joyEnableParallel()) {
				menuErrorMsg(
					"Can't open parallel port - joy 3 & 4 are not usable!"
				);
				return;
			}

			if(s_pPlayerSteers[i] < STEER_MODE_AI && BTST(ubPlayerMask, i)) {
				if(!pSteerToPlayer[s_pPlayerSteers[i]]) {
					pSteerToPlayer[s_pPlayerSteers[i]] = 1;
				}
				else {
					char szMsg[80];
					sprintf(
						szMsg, "Controller %s is bound to more than 1 player",
						g_pSteerModeLabels[s_pPlayerSteers[i]]
					);
					menuErrorMsg(szMsg);
					return;
				}
			}
		}
		gameSetRules(
			0, s_isCampaign ? BATTLE_MODE_FFA : s_ubBattleMode, s_ubTeamCfg,
			ubCampaignStage, pSteers
		);
		fadeSet(s_pFadeMenu, FADE_STATE_OUT, 50, 1, onFadeoutGameStart);
	}
}

static UBYTE menuProcessList(UBYTE isEnabled34) {
	UBYTE isEarlyReturn = 0;
	if(
		keyUse(KEY_UP) || keyUse(KEY_W) ||
		joyUse(JOY1_UP) || joyUse(JOY2_UP) ||
		(isEnabled34 && (joyUse(JOY3_UP) || joyUse(JOY4_UP)))
	) {
		menuListNavigate(-1);
	}
	else if(
		keyUse(KEY_DOWN) || keyUse(KEY_S) ||
		joyUse(JOY1_DOWN) || joyUse(JOY2_DOWN) ||
		(isEnabled34 && (joyUse(JOY3_DOWN) || joyUse(JOY4_DOWN)))
	) {
		menuListNavigate(+1);
	}
	else if(
		keyUse(KEY_LEFT) || keyUse(KEY_A) ||
		joyUse(JOY1_LEFT) || joyUse(JOY2_LEFT) ||
		(isEnabled34 && (joyUse(JOY3_LEFT) || joyUse(JOY4_LEFT)))
	) {
		menuListToggle(-1);
	}
	else if(
		keyUse(KEY_RIGHT) || keyUse(KEY_D) ||
		joyUse(JOY1_RIGHT) || joyUse(JOY2_RIGHT) ||
		(isEnabled34 && (joyUse(JOY3_RIGHT) || joyUse(JOY4_RIGHT)))
	) {
		menuListToggle(+1);
	}
	else 	if(
		keyUse(KEY_RETURN) || keyUse(KEY_LSHIFT) || keyUse(KEY_RSHIFT) ||
		joyUse(JOY1_FIRE) || joyUse(JOY2_FIRE) ||
		(isEnabled34 && (joyUse(JOY3_FIRE) || joyUse(JOY4_FIRE)))
	) {
		// menuEnter may change gamestate, so do nothing past it
		menuListEnter();
		isEarlyReturn = 1;
	}
	return isEarlyReturn;
}

static void menuGsCreate(void) {
	s_pView = viewCreate(0,
		TAG_VIEW_GLOBAL_PALETTE, 1,
		TAG_END
	);

	s_pVp = vPortCreate(0,
		TAG_VPORT_VIEW, s_pView,
		TAG_VPORT_BPP, 5,
		TAG_END
	);

	s_pBfr = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_VPORT, s_pVp,
		TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_INTERLEAVED,
		TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
		TAG_SIMPLEBUFFER_USE_X_SCROLLING, 0,
		TAG_END
	);
	s_pBg = bitmapCreateFromFile("data/menu_main.bm", 0);
	s_pBgSub = bitmapCreateFromFile("data/menu_sub.bm", 0);

	s_sBmFrontScanline.BytesPerRow = s_pBfr->pBack->BytesPerRow;
	s_sBmFrontScanline.Rows = s_pBfr->pBack->Rows;
	s_sBmFrontScanline.Depth = 4;
	s_sBmFrontScanline.Planes[0] = s_pBfr->pBack->Planes[1];
	s_sBmFrontScanline.Planes[1] = s_pBfr->pBack->Planes[2];
	s_sBmFrontScanline.Planes[2] = s_pBfr->pBack->Planes[3];
	s_sBmFrontScanline.Planes[3] = s_pBfr->pBack->Planes[4];
	guiScanlinedInit(&s_sBmFrontScanline);

	UWORD pPalette[32];
	paletteLoad("data/germz.plt", pPalette, 32);
	s_pFadeMenu = fadeCreate(s_pView, pPalette, 32);

	s_pStateMachineMenu = stateManagerCreate();

	// Get number of maps
	char szPath[30];
	s_ubMapCount = 1;
	do {
		sprintf(szPath, "data/maps/campaign/c%02hhu.json", s_ubMapCount);
		tFile *pMapFile = fileOpen(szPath, "rb");
		if(!pMapFile) {
			break;
		}
		fileClose(pMapFile);
	}
	while(++s_ubMapCount < 100);
	logWrite("Campaign map count: %hhu", s_ubMapCount);

	systemUnuse();
	musicLoadPreset(MUSIC_PRESET_MENU);
	if(s_isStartWithCredits) {
		s_isStartWithCredits = 0;
		stateChange(s_pStateMachineMenu, &s_sStateCredits);
	}
	else {
		stateChange(s_pStateMachineMenu, &s_sStateMain);
	}

	fadeSet(s_pFadeMenu, FADE_STATE_IN, 50, 1, 0);
	viewLoad(s_pView);
	ptplayerEnableMusic(1);
}

static void menuGsLoop(void) {
	tFadeState eFadeState = fadeProcess(s_pFadeMenu);
	if(eFadeState == FADE_STATE_EVENT_FIRED) {
		return;
	}
	if(eFadeState != FADE_STATE_OUT && keyUse(KEY_ESCAPE)) {
		s_cbOnEscape();
		return;
	}
	if(eFadeState != FADE_STATE_OUT) {
		stateProcess(s_pStateMachineMenu);
	}

	copProcessBlocks();
	systemIdleBegin();
	vPortWaitForEnd(s_pVp);
	systemIdleEnd();
}

static void menuGsDestroy(void) {
	viewLoad(0);
	systemUse();
	stateManagerDestroy(s_pStateMachineMenu);
	bitmapDestroy(s_pBg);
	bitmapDestroy(s_pBgSub);
	viewDestroy(s_pView);
	fadeDestroy(s_pFadeMenu);
}

void menuStartWithCredits(void) {
	s_isStartWithCredits = 1;
}


//------------------------------------------------------------- SUBSTATE: COMMON

// It needs to work on state changing instead of  pushing/popping since it needs
// to redraw each screen on transition.
static tState *s_pNextSubstate;

static const char *s_pSteerPlayerLabels[] = {
	"PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4"
};

static void onFadeToSubstate(void) {
	stateChange(s_pStateMachineMenu, s_pNextSubstate);
	fadeSet(s_pFadeMenu, FADE_STATE_IN, 50, 1, 0);
}

static void fadeToSubstate(tState *pNextSubstate) {
	s_pNextSubstate = pNextSubstate;
	fadeSet(s_pFadeMenu, FADE_STATE_OUT, 50, 1, onFadeToSubstate);
}

static void onCampaign(void) {
	fadeToSubstate(&s_sStateCampaign);
}

static void onEditor(void) {
	mapDataClear(&g_sMapData);
	startGame(1, 1, 0);
}

static void onBattle(void) {
	fadeToSubstate(&s_sStateBattle);
}

static void onCredits(void) {
	fadeToSubstate(&s_sStateCredits);
}

static void onHowTo(void) {
	fadeToSubstate(&s_sStateHowTo);
}

static void onFadeoutToExit(void) {
	gameExit();
}

static void fadeToExit(void) {
	fadeSet(s_pFadeMenu, FADE_STATE_OUT, 50, 1, onFadeoutToExit);
}

static tMenuListOption s_pOptions[] = {
	{MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onCampaign}},
	{MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onBattle}},
	{MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onEditor}},
	{MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onHowTo}},
	{MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onCredits}},
	{MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = fadeToExit}},
};
#define MENU_POS_COUNT (sizeof(s_pOptions) / sizeof(s_pOptions[0]))

static void fadeToMain(void) {
	fadeToSubstate(&s_sStateMain);
}

static void fadeToBattle(void) {
	stateChange(s_pStateMachineMenu, &s_sStateBattle);
}

static void menuSubstateLoop(void) {
	menuListDraw();

	UBYTE isEnabled34 = joyIsParallelEnabled();
	if(menuProcessList(isEnabled34)) {
		// menuEnter may change gamestate and deallocate s_pVp
		return;
	}
}

static void scanlinedMenuUndraw(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight) {
	blitRect(&s_sBmFrontScanline, uwX, uwY, uwWidth, uwHeight, COLOR_CONSOLE_BG >> 1);
}

static void scanlinedMenuPosDraw(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
) {
	// Draw pos + non-zero shadow
	fontFillTextBitMap(g_pFontBig, g_pTextBitmap, szText);
	*pUndrawWidth = g_pTextBitmap->uwActualWidth;
	UBYTE ubPlayerIdx = 2;
	for(UBYTE i = 0; i < 4; ++i) {
		if(szCaption == s_pSteerPlayerLabels[i]) {
			ubPlayerIdx = i;
			break;
		}
	}

	UBYTE ubColor = s_pScanlinedMenuColors[ubPlayerIdx][isActive];
	fontDrawTextBitMap(
		&s_sBmFrontScanline, g_pTextBitmap, uwX, uwY, ubColor, FONT_COOKIE
	);
}

static void textBasedGsLoop(void) {
	tFadeState eFadeState = fadeProcess(s_pFadeMenu);

	UBYTE isEnabled34 = joyIsParallelEnabled();
	if(eFadeState != FADE_STATE_OUT && (
		keyUse(KEY_RETURN) || keyUse(KEY_LSHIFT) || keyUse(KEY_RSHIFT) ||
		joyUse(JOY1_FIRE) || joyUse(JOY2_FIRE) ||
		(isEnabled34 && (joyUse(JOY3_FIRE) || joyUse(JOY4_FIRE)))
	)) {
		// menuEnter may change gamestate, so do nothing past it
		fadeToMain();
	}

	copProcessBlocks();
	systemIdleBegin();
	vPortWaitForEnd(s_pVp);
	systemIdleEnd();
}

#define TEXT_ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

static UWORD drawTextArray(
	UWORD uwOffsX, UWORD uwOffsY, const char **pLines, UBYTE ubLineCount,
	UBYTE ubLineHeight
) {
	for(UBYTE ubLine = 0; ubLine < ubLineCount; ++ubLine) {
		// Draw only non-empty lines
		if(pLines[ubLine][0] != '\0') {
			fontDrawStr(
				g_pFontSmall, s_pBfr->pBack, uwOffsX, uwOffsY, pLines[ubLine],
				MENU_COLOR_ACTIVE, FONT_COOKIE | FONT_SHADOW, g_pTextBitmap
			);
		}

		// Advance Y pos nonetheless
		uwOffsY += ubLineHeight;
	}
	return uwOffsY;
}

static void textBasedGsCreate(const char **pLines, UBYTE ubLineCount) {
	blitCopy(s_pBgSub, 0, 0, s_pBfr->pBack, 0, 0, 320, 128, MINTERM_COPY);
	blitCopy(s_pBgSub, 0, 128, s_pBfr->pBack, 0, 128, 320, 128, MINTERM_COPY);

	UBYTE ubLineHeight = g_pFontSmall->uwHeight + 1;
	UWORD uwOffsY = 0;
	drawTextArray(0, uwOffsY, pLines, ubLineCount, ubLineHeight);

	s_cbOnEscape = fadeToMain;
}

//-------------------------------------------------------------- SUBSTATE: STEER

#define STEER_MENU_OPTION_MAX 8
static const char *s_pMenuCaptionsSteer[STEER_MENU_OPTION_MAX];
static tMenuListOption s_pOptionsSteer[STEER_MENU_OPTION_MAX];
static UBYTE s_ubSteerOptionCount;

static void onStart(void) {
	startGame(0, g_sMapData.ubPlayerMask, s_isCampaign ? s_ubStartingLevel : 0);
}

static void menuSteerGsCreate(void) {
	s_ubSteerOptionCount = 0;

	// Undraw battle's menu list
	blitRect(
		&s_sBmFrontScanline, BATTLE_MENU_X, BATTLE_MENU_Y,
		BATTLE_MENU_WIDTH, BATTLE_MENU_HEIGHT, COLOR_CONSOLE_BG >> 1
	);

	// Players
	for(UBYTE i = 0; i < 4; ++i) {
		if(BTST(g_sMapData.ubPlayerMask, i)) {
			s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
				MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 0, .sOptUb = {
				.pVar = &s_pPlayerSteers[i], .ubMax = STEER_MODE_IDLE, .isCyclic = 1,
				.pEnumLabels = g_pSteerModeLabels
			}};
			s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = s_pSteerPlayerLabels[i];
		}
	}

	// Infect
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onStart}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "INFECT";

	// Back
	UBYTE ubOptionIdxBack = s_ubSteerOptionCount;
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0,
		.sOptCb = {.cbSelect = fadeToBattle}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "BACK";

	menuListInit(
		s_pOptionsSteer, s_pMenuCaptionsSteer, s_ubSteerOptionCount,
		g_pFontBig, BATTLE_MENU_X, BATTLE_MENU_Y, scanlinedMenuUndraw,
		scanlinedMenuPosDraw
	);
	menuListSetActive(s_ubSteerOptionCount - 2);

	s_cbOnEscape = s_pOptionsSteer[ubOptionIdxBack].sOptCb.cbSelect;
}

//------------------------------------------------------------- SUBSTATE: BATTLE

#define BATTLE_MENU_OPTION_MAX 6

static ULONG s_ullChangeTimer;
static const char *s_pMenuBattleCaptions[BATTLE_MENU_OPTION_MAX];
static tMenuListOption s_pOptionsBattle[BATTLE_MENU_OPTION_MAX];
static UBYTE s_ubBattleOptionCount;
static tListCtl *s_pMapList;
static const char *s_pLabelsMode[] = {"SOLO", "TEAMS"};
static const char *s_pLabelsTeam1[TEAM_CONFIG_COUNT] = {"", "", ""};
static const char *s_pLabelsTeam2[TEAM_CONFIG_COUNT] = {"", "", ""};
static UBYTE s_ubOptionIdxTeam1, s_ubOptionIdxTeam2;
static UWORD s_uwBattleLastSelectedEntry = 0xFFFF;
static const char s_szBaseDir[] = "data/maps";
static char s_szCurrDir[100] = "data/maps";

tTeamConfig menuGetTeamConfig(void) {
	tTeamConfig eCfg = s_ubTeamCfg;
	return eCfg;
}

UBYTE menuGetBattleMode(void) {
	return s_ubBattleMode;
}

static void battleGsLoopMapSelect(void);

static void onBattleGoToSteer(void) {
	stateChange(s_pStateMachineMenu, &s_sStateSteer);
}

static void onMap(void) {
	// Undraw menu list
	blitRect(
		&s_sBmFrontScanline, BATTLE_MENU_X, BATTLE_MENU_Y,
		BATTLE_MENU_WIDTH, BATTLE_MENU_HEIGHT, COLOR_CONSOLE_BG >> 1
	);

	// Draw map list ctrl instead
	listCtlDraw(s_pMapList);
	buttonDrawAll();
	s_sStateBattle.cbLoop = battleGsLoopMapSelect;
}

static void onModeChange(void) {
	if(s_ubBattleMode) {
		// Teams - allow selecting
		s_pOptionsBattle[s_ubOptionIdxTeam1].isHidden = 0;
		s_pOptionsBattle[s_ubOptionIdxTeam2].isHidden = 0;
	}
	else {
		// Solo - hide
		s_pOptionsBattle[s_ubOptionIdxTeam1].isHidden = 1;
		s_pOptionsBattle[s_ubOptionIdxTeam2].isHidden = 1;

		// Ensure that teams get undrawn
		UWORD uwX = BATTLE_MENU_X + 80;
		UWORD uwY = BATTLE_MENU_Y + s_ubOptionIdxTeam1 * (g_pFontBig->uwHeight + 1); // HACK HACK HACK
		blitRect(
			&s_sBmFrontScanline, uwX, uwY, 60, (g_pFontBig->uwHeight + 1) * 2,
			 COLOR_CONSOLE_BG >> 1
		);
	}
	s_pOptionsBattle[s_ubOptionIdxTeam1].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
	s_pOptionsBattle[s_ubOptionIdxTeam2].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
}

static void onTeamChange(void) {
	// Team changed - mark both for redraw since it's the same var
	s_pOptionsBattle[s_ubOptionIdxTeam1].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
	s_pOptionsBattle[s_ubOptionIdxTeam2].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
}

static void onTeamDraw(UBYTE ubIdx) {
	// Team combos, consisting of 2 players (X and Y)
	static const UBYTE pComboA[TEAM_CONFIG_COUNT][2] = {
		[TEAM_CONFIG_P1_P2_AND_P3_P4] = {0, 1},
		[TEAM_CONFIG_P1_P3_AND_P2_P4] = {0, 2},
		[TEAM_CONFIG_P1_P4_AND_P2_P3] = {0, 3}
	};
	static const UBYTE pComboB[TEAM_CONFIG_COUNT][2] = {
		[TEAM_CONFIG_P1_P2_AND_P3_P4] = {2, 3},
		[TEAM_CONFIG_P1_P3_AND_P2_P4] = {1, 3},
		[TEAM_CONFIG_P1_P4_AND_P2_P3] = {1, 2}
	};
	static const char *pPlayerNames[] = {"P1", "P2", "P3", "P4"};

	UBYTE ubActiveIdx = menuListGetActive();
	const UBYTE (*pCombo)[2] = (ubIdx == s_ubOptionIdxTeam1 ? pComboA : pComboB);

	UWORD uwX = BATTLE_MENU_X + 80;
	UWORD uwY = BATTLE_MENU_Y + ubIdx * (g_pFontBig->uwHeight + 1); // HACK HACK HACK
	UBYTE ubPlayerX = pCombo[s_ubTeamCfg][0];
	UBYTE ubPlayerY = pCombo[s_ubTeamCfg][1];

	blitRect(
		&s_sBmFrontScanline, uwX, uwY, 60, g_pFontBig->uwHeight,
		COLOR_CONSOLE_BG >> 1
	);

	UBYTE ubColor = s_pScanlinedMenuColors[ubPlayerX][ubActiveIdx == ubIdx];
	fontDrawStr(
		g_pFontBig, &s_sBmFrontScanline, uwX, uwY, pPlayerNames[ubPlayerX],
		ubColor, FONT_COOKIE, g_pTextBitmap
	);

	ubColor = s_pScanlinedMenuColors[ubPlayerY][ubActiveIdx == ubIdx];
	fontDrawStr(
		g_pFontBig, &s_sBmFrontScanline, uwX + 30, uwY, pPlayerNames[ubPlayerY],
		ubColor, FONT_COOKIE, g_pTextBitmap
	);
}

static void battleRegenMenuList(UBYTE ubPlayerMask) {
	s_ubBattleOptionCount = 0;

	// Select map
	s_pOptionsBattle[s_ubBattleOptionCount] = (tMenuListOption){
		.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0,
		.sOptCb = {.cbSelect = onMap}
	};
	s_pMenuBattleCaptions[s_ubBattleOptionCount++] = "SELECT MAP";

	// Game mode
	UBYTE isTeamsAllowed = (g_sMapData.ubPlayerMask == 0xF);
	s_pOptionsBattle[s_ubBattleOptionCount] = (tMenuListOption){
		.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 0, .sOptUb = {
			.isCyclic = 1, .pEnumLabels = s_pLabelsMode, .pVar = &s_ubBattleMode,
			.ubMax = 0, .cbOnValChange = onModeChange
		}
	};
	if(isTeamsAllowed) {
		// All players are available - allow team mode
		s_pOptionsBattle[s_ubBattleOptionCount].sOptUb.ubMax = 1;
	}
	s_pMenuBattleCaptions[s_ubBattleOptionCount++] = "GAME MODE";

	// Team 1
	s_ubOptionIdxTeam1 = s_ubBattleOptionCount;
	s_pOptionsBattle[s_ubBattleOptionCount] = (tMenuListOption){
		.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 1, .sOptUb = {
			.isCyclic = 1, .pEnumLabels = s_pLabelsTeam1, .pVar = &s_ubTeamCfg,
			.ubMax = 2, .cbOnValChange = onTeamChange, .cbOnValDraw = onTeamDraw
		}
	};
	if(isTeamsAllowed && s_ubBattleMode) {
		s_pOptionsBattle[s_ubBattleOptionCount].isHidden = 0;
	}
	s_pMenuBattleCaptions[s_ubBattleOptionCount++] = "TEAM 1";

	// Team 2
	s_ubOptionIdxTeam2 = s_ubBattleOptionCount;
	s_pOptionsBattle[s_ubBattleOptionCount] = (tMenuListOption){
		.eOptionType = MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 1, .sOptUb = {
			.isCyclic = 1, .pEnumLabels = s_pLabelsTeam2, .pVar = &s_ubTeamCfg,
			.ubMax = 2, .cbOnValChange = onTeamChange, .cbOnValDraw = onTeamDraw
		}
	};
	if(isTeamsAllowed && s_ubBattleMode) {
		s_pOptionsBattle[s_ubBattleOptionCount].isHidden = 0;
	}
	s_pMenuBattleCaptions[s_ubBattleOptionCount++] = "TEAM 2";

	// Proceed
	s_pOptionsBattle[s_ubBattleOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onBattleGoToSteer}
	};
	s_pMenuBattleCaptions[s_ubBattleOptionCount++] = "PROCEED";

	// Back
	s_pOptionsBattle[s_ubBattleOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = fadeToMain}
	};
	s_pMenuBattleCaptions[s_ubBattleOptionCount++] = "BACK";
}

static void menuMapListLoadMap(UBYTE isForce) {
	if(mapListLoadMap(s_pMapList, &g_sMapData, s_szCurrDir) || isForce) {
		mapInfoDrawAuthorTitle(&g_sMapData, &s_sBmFrontScanline, INFO_X, INFO_Y);
		mapListDrawPreview(&g_sMapData, &s_sBmFrontScanline, PREVIEW_X, PREVIEW_Y, 6);
	}
}

static void battleDrawMenuList(void) {
	battleRegenMenuList(g_sMapData.ubPlayerMask);
	UBYTE ubActive = menuListGetActive();
	menuListInit(
		s_pOptionsBattle, s_pMenuBattleCaptions, s_ubBattleOptionCount,
		g_pFontBig, BATTLE_MENU_X, BATTLE_MENU_Y, scanlinedMenuUndraw,
		scanlinedMenuPosDraw
	);
	menuListSetActive(ubActive);
	menuListDraw();
}

static void battleGsCreate(void) {
	s_isCampaign = 0;
	s_pFadeMenu->pPaletteRef[COLOR_SPECIAL_1] = 0x333;
	s_pFadeMenu->pPaletteRef[COLOR_SPECIAL_2] = 0x222;

	// Prepare current bg
	blitCopy(s_pBgSub, 0, 0, s_pBfr->pBack, 0, 0, 320, 128, MINTERM_COPY);
	blitCopy(s_pBgSub, 0, 128, s_pBfr->pBack, 0, 128, 320, 128, MINTERM_COPY);
	bmFrameDraw(g_pFrameDisplay, s_pBfr->pBack, 32, 16, 16, 14, 16);

	buttonListCreate(5, guiScanlinedButtonDraw);
	s_pMapList = mapListCreateCtl(
		&s_sBmFrontScanline, BATTLE_MENU_X, BATTLE_MENU_Y,
		BATTLE_MENU_WIDTH, BATTLE_MENU_HEIGHT, s_szBaseDir, s_szCurrDir
	);
	if(s_uwBattleLastSelectedEntry == 0xFFFF) {
		s_uwBattleLastSelectedEntry = listCtlGetSelectionIdx(s_pMapList);
	}
	else {
		listCtlSetSelectionIdx(s_pMapList, s_uwBattleLastSelectedEntry);
	}

	// Always start in menu loop (after ESC pressed when in map select)
	s_sStateBattle.cbLoop = menuSubstateLoop;

	s_cbOnEscape = fadeToMain;
	menuListSetActive(4);
	menuMapListLoadMap(1);
	battleDrawMenuList();
	s_ullChangeTimer = timerGet();
}

static void battleGsLoopMapSelect(void) {
	UBYTE isMapSelected = 0;
	UBYTE isEnabled34 = joyIsParallelEnabled();

	if(
		keyUse(KEY_UP) || keyUse(KEY_W) ||
		joyUse(JOY1_UP) || joyUse(JOY2_UP) ||
		(isEnabled34 && (joyUse(JOY3_UP) || joyUse(JOY4_UP)))
	) {
		listCtlSelectPrev(s_pMapList);
		clearMapInfo(&s_sBmFrontScanline, INFO_X, INFO_Y, 0);
		s_ullChangeTimer = timerGet();
	}
	else if(
		keyUse(KEY_DOWN) || keyUse(KEY_S) ||
		joyUse(JOY1_DOWN) || joyUse(JOY2_DOWN) ||
		(isEnabled34 && (joyUse(JOY3_DOWN) || joyUse(JOY4_DOWN)))
	) {
		listCtlSelectNext(s_pMapList);
		clearMapInfo(&s_sBmFrontScanline, INFO_X, INFO_Y, 0);
		s_ullChangeTimer = timerGet();
	}
	else if(
		keyUse(KEY_RETURN) || keyUse(KEY_LSHIFT) || keyUse(KEY_RSHIFT) ||
		joyUse(JOY1_FIRE) || joyUse(JOY2_FIRE) ||
		(isEnabled34 && (joyUse(JOY3_FIRE) || joyUse(JOY4_FIRE)))
	) {
		const tListCtlEntry *pSelection = listCtlGetSelection(s_pMapList);
		tMapEntryType eType = (tMapEntryType)pSelection->pData;
		if(eType == MAP_ENTRY_TYPE_DIR) {
			UWORD uwLenOld = strlen(s_szCurrDir);
			if(uwLenOld + 1 + strlen(pSelection->szLabel) < sizeof(s_szCurrDir)) {
				// Append subdirectory to current path, skip icon char
				sprintf(&s_szCurrDir[uwLenOld], "/%s", &pSelection->szLabel[1]);
			}
			clearMapInfo(&s_sBmFrontScanline, INFO_X, INFO_Y, 1);
			mapListFillWithDir(s_pMapList, s_szCurrDir);
			listCtlDraw(s_pMapList);
			buttonDrawAll();
		}
		else if(eType == MAP_ENTRY_TYPE_PARENT) {
			char *pLastPos = strrchr(s_szCurrDir, '/');
			if(pLastPos) {
				*pLastPos = '\0';
			}
			clearMapInfo(&s_sBmFrontScanline, INFO_X, INFO_Y, 1);
			mapListFillWithDir(s_pMapList, s_szCurrDir);
			listCtlDraw(s_pMapList);
			buttonDrawAll();
		}
		else {
			isMapSelected = 1;
		}
		menuMapListLoadMap(0);
	}

	if(timerGetDelta(s_ullChangeTimer, timerGet()) >= 25) {
		menuMapListLoadMap(0);
		s_ullChangeTimer = timerGet();
	}

	if(isMapSelected || keyUse(KEY_ESCAPE)) {
		// Undraw map select ui
		blitRect(
			&s_sBmFrontScanline, BATTLE_MENU_X, BATTLE_MENU_Y,
			BATTLE_MENU_WIDTH, BATTLE_MENU_HEIGHT, COLOR_CONSOLE_BG >> 1
		);

		// Draw menu list instead
		battleDrawMenuList();

		s_sStateBattle.cbLoop = menuSubstateLoop;
	}
}

static void battleGsDestroy(void) {
	// Save previous selection if it wasn't a directory
	if(!(ULONG)listCtlGetSelection(s_pMapList)->pData) {
		s_uwBattleLastSelectedEntry = s_pMapList->uwEntrySel;
	}

	listCtlDestroy(s_pMapList);
	buttonListDestroy();
}

//------------------------------------------------------------ SUBSTATE: CAMPAIGN


void campaignGsCreate(void) {
	s_pFadeMenu->pPaletteRef[COLOR_SPECIAL_1] = 0x333;
	s_pFadeMenu->pPaletteRef[COLOR_SPECIAL_2] = 0x222;

	// Prepare current bg
	blitCopy(s_pBgSub, 0, 0, s_pBfr->pBack, 0, 0, 320, 128, MINTERM_COPY);
	blitCopy(s_pBgSub, 0, 128, s_pBfr->pBack, 0, 128, 320, 128, MINTERM_COPY);
	bmFrameDraw(g_pFrameDisplay, s_pBfr->pBack, 32, 4 * 16 - 8, 16, 6, 16);

	s_isCampaign = 1;

	// Copypasta from steer substate, with some changes
	s_ubSteerOptionCount = 0;

	// Only one player, only joy & keyboard, rest is set to AI
	s_pPlayerSteers[0] = STEER_MODE_JOY_1;
	for(UBYTE i = 1; i < 4; ++i) {
		s_pPlayerSteers[i] = STEER_MODE_AI;
	}
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 0, .sOptUb = {
		.pVar = &s_pPlayerSteers[0], .ubMax = STEER_MODE_KEY_ARROWS, .isCyclic = 1,
		.pEnumLabels = g_pSteerModeLabels
	}};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = s_pSteerPlayerLabels[0];

	// Starting level
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 0, .sOptUb = {
			.isCyclic = 1, .ubMin = 1, .ubMax = s_ubMapCount - 1,
			.pVar = &s_ubStartingLevel
		}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "STARTING LEVEL";

	// Infect
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onStart}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "INFECT";

	// Back
	UBYTE ubOptionIdxBack = s_ubSteerOptionCount;
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0,
		.sOptCb = {.cbSelect = fadeToMain}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "BACK";

	menuListInit(
		s_pOptionsSteer, s_pMenuCaptionsSteer, s_ubSteerOptionCount,
		g_pFontBig, BATTLE_MENU_X, CAMPAIGN_MENU_Y, scanlinedMenuUndraw,
		scanlinedMenuPosDraw
	);
	menuListSetActive(s_ubSteerOptionCount - 2);

	s_cbOnEscape = s_pOptionsSteer[ubOptionIdxBack].sOptCb.cbSelect;
}

//------------------------------------------------------------ SUBSTATE: CREDITS

static const char *s_pCreditsLines[] = {
	"GermZ by Last Minute Creations ( lastminutecreations.itch.io/germz )",
	"  Graphics: Softiron",
	"  Sound & Music: Luc3k",
	"  Code: KaiN",
	"Tests: Sordan, Renton, Tomu\x84, JakubH",
	"",
	"Preview released on 2020.04.25 RETROnizacja 3.9 Zoom meeting.",
	"Final version released on 2022.04.30 RETROnizacja 4 Party.",
	"",
	"GermZ source code is available on:",
	"  github.com/Last-Minute-Creations/germz",
	"",
	"This game uses following third party code and assets:",
	"- Amiga C Engine, MPL2 license (github.com/AmigaPorts/ACE)",
	"- jsmn, MIT license (github.com/zserge/jsmn)",
	"- UTF-8 parser, MIT license (bjoern.hoehrmann.de/utf-8/decoder/dfa)",
	"- uni05_54 font by Craig Kroeger (miniml.com/fonts)",
	"See links for license details, sorry for not printing them here!",
	"",
	"Thanks for playing!",
};
#define CREDITS_LINES_COUNT (sizeof(s_pCreditsLines) / sizeof(s_pCreditsLines[0]))

static void creditsGsCreate(void) {
	textBasedGsCreate(s_pCreditsLines, CREDITS_LINES_COUNT);
}

//------------------------------------------------------------- SUBSTATE: HOW_TO

static void howToGsCreate(void) {
	// Bg
	blitCopy(s_pBgSub, 0, 0, s_pBfr->pBack, 0, 0, 320, 128, MINTERM_COPY);
	blitCopy(s_pBgSub, 0, 128, s_pBfr->pBack, 0, 128, 320, 128, MINTERM_COPY);

	UBYTE ubLineHeight = g_pFontSmall->uwHeight + 1;
	UBYTE ubQuartLine = ubLineHeight / 4;
	UWORD uwOffsY = 0;

	// Cursor
	blitCopyMask(
		g_pCursors, 0, 0, s_pBfr->pBack, 8, uwOffsY, 16, 16,
		(UWORD*)g_pCursorsMask->Planes[0]
	);
	static const char *pLinesCursor[] = {
		"Move frame with controller to select a cell."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY + ubQuartLine, pLinesCursor, TEXT_ARRAY_SIZE(pLinesCursor),
		ubLineHeight
	) + ubLineHeight + ubQuartLine;

	// Attack icon - convert 1bpp bitmap to multi-bpp draw it in color.
	// Color 11 is 0b1011, so 3 bitplanes need to be filled.
	tBitMap sAttackSrc = {
		.BytesPerRow = g_pBmHudTarget->BytesPerRow,
		.Rows = g_pBmHudTarget->Rows,
		.Depth = 3,
		.Planes = {
			[0] = g_pBmHudTarget->Planes[0],
			[1] = g_pBmHudTarget->Planes[0],
			[2] = g_pBmHudTarget->Planes[0],
		}
	};
	tBitMap sAttackDst = {
		.BytesPerRow = s_pBfr->pBack->BytesPerRow,
		.Rows = s_pBfr->pBack->Rows,
		.Depth = 3,
		.Planes = {
			[0] = s_pBfr->pBack->Planes[0],
			[1] = s_pBfr->pBack->Planes[1],
			[2] = s_pBfr->pBack->Planes[3],
		}
	};
	blitCopyMask(
		&sAttackSrc, 0, 0, &sAttackDst,
		(32 - 9) / 2, uwOffsY + (2 * ubLineHeight - 9) / 2, 9, 9,
		(UWORD*)g_pBmHudTarget->Planes[0]
	);
	static const char *pLinesAttack[] = {
		"Hold FIRE button to enter attack mode. Use controller to send",
		"virions and infect others or reinforce your own cells."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY, pLinesAttack, TEXT_ARRAY_SIZE(pLinesAttack), ubLineHeight
	) + ubLineHeight;

	// Count
	fontDrawStr(
		g_pFontBig, s_pBfr->pBack, 16, uwOffsY + ubLineHeight, "21",
		COLOR_P1_BRIGHT + 1, FONT_COOKIE | FONT_CENTER, g_pTextBitmap
	);
	static const char *pLinesCounter[] = {
		"The upper number on your HUD is virion count of selected cell.",
		"In attack mode, lower number shows your attack strength."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY, pLinesCounter, TEXT_ARRAY_SIZE(pLinesCounter), ubLineHeight
	) + ubLineHeight;

	// Normal node
	blitCopyMask(
		g_pBmBlobs[0], 0, 16 * 8, s_pBfr->pBack, 8, uwOffsY, 16, 16,
		(UWORD*)g_pBmBlobMask->Planes[0]
	);
	static const char *pLinesNodeNormal[] = {
		"This is an ordinary cell."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY + ubQuartLine, pLinesNodeNormal, TEXT_ARRAY_SIZE(pLinesNodeNormal),
		ubLineHeight
	) + ubLineHeight + ubQuartLine;

	// Special node - cap
	blitCopyMask(
		g_pBmBlobs[0], 0, 16 * 9, s_pBfr->pBack, 8, uwOffsY, 16, 16,
		(UWORD*)g_pBmBlobMask->Planes[0]
	);
	static const char *pLinesNodeCap[] = {
		"This cell's viral strain increases capacity of all your cells."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY + ubQuartLine, pLinesNodeCap, TEXT_ARRAY_SIZE(pLinesNodeCap),
		ubLineHeight
	) + ubLineHeight + ubQuartLine;

	// Special node - tick
	blitCopyMask(
		g_pBmBlobs[0], 0, 16 * 10, s_pBfr->pBack, 8, uwOffsY, 16, 16,
		(UWORD*)g_pBmBlobMask->Planes[0]
	);
	static const char *pLinesNodeTick[] = {
		"This cell's viral strain increses the speed your virions multiply."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY + ubQuartLine, pLinesNodeTick, TEXT_ARRAY_SIZE(pLinesNodeTick),
		ubLineHeight
	) + ubLineHeight + ubQuartLine;

	// Special node - attack
	blitCopyMask(
		g_pBmBlobs[0], 0, 16 * 11, s_pBfr->pBack, 8, uwOffsY, 16, 16,
		(UWORD*)g_pBmBlobMask->Planes[0]
	);
	static const char *pLinesNodeAttack[] = {
		"This cell's viral strain increases strength of your attacks."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY + ubQuartLine, pLinesNodeAttack, TEXT_ARRAY_SIZE(pLinesNodeAttack),
		ubLineHeight
	) + ubLineHeight + ubQuartLine;

	// Effect stacking
	static const char *pLinesEffectStacking[] = {
		"Effects of multiple viral strains stack together.",
		"The more special cells you control, the greater the effect."
	};
	uwOffsY = drawTextArray(
		32, uwOffsY, pLinesEffectStacking, TEXT_ARRAY_SIZE(pLinesEffectStacking),
		ubLineHeight
	) + ubLineHeight;

	// Control layouts
	static const char *pLinesControls[] = {
		"You can play together using up to 4 joysticks or keyboard.",
		"Keyboard controls: WSAD + Left Shift, Arrows + Right Shift."
	};
	drawTextArray(
		32, uwOffsY, pLinesControls, TEXT_ARRAY_SIZE(pLinesControls), ubLineHeight
	);

	s_cbOnEscape = fadeToMain;
}

//---------------------------------------------------------- SUBSTATE: MAIN MENU

static void mainMenuUndraw(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight) {
	// Copy from current bg, add 1 for text shadow
	blitCopy(
		s_pBg, uwX, uwY, s_pBfr->pBack, uwX, uwY + 1, uwWidth, uwHeight,
		MINTERM_COOKIE
	);
}

static void mainMenuPosDraw(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
) {
	// Draw pos + non-zero shadow
	fontFillTextBitMap(g_pFontBig, g_pTextBitmap, szText);
	*pUndrawWidth = g_pTextBitmap->uwActualWidth;
	UBYTE ubColor = (isActive ? MENU_COLOR_ACTIVE : MENU_COLOR_INACTIVE);

	fontDrawTextBitMap(
		s_pBfr->pBack, g_pTextBitmap, uwX, uwY + 1, MENU_COLOR_SHADOW, FONT_COOKIE
	);
	fontDrawTextBitMap(
		s_pBfr->pBack, g_pTextBitmap, uwX, uwY, ubColor, FONT_COOKIE
	);
}

static void mainGsCreate(void) {
	blitCopy(s_pBg, 0, 0, s_pBfr->pBack, 0, 0, 320, 128, MINTERM_COPY);
	blitCopy(s_pBg, 0, 128, s_pBfr->pBack, 0, 128, 320, 128, MINTERM_COPY);

	menuListInit(
		s_pOptions, s_pMenuCaptions, MENU_POS_COUNT,
		g_pFontBig, 120, 120, mainMenuUndraw, mainMenuPosDraw
	);

	static const char szVersion[15] = "V." GERMZ_VERSION;
	fontDrawStr(
		g_pFontSmall, s_pBfr->pBack, 320, 0, szVersion,
		MENU_COLOR_INACTIVE, FONT_RIGHT | FONT_COOKIE, g_pTextBitmap
	);

	fontDrawStr(
		g_pFontSmall, s_pBfr->pBack, SCREEN_PAL_WIDTH / 2, SCREEN_PAL_HEIGHT - 10,
		"A game by Last Minute Creations",
		MENU_COLOR_INACTIVE, FONT_HCENTER | FONT_COOKIE, g_pTextBitmap
	);

	s_cbOnEscape = fadeToExit;
}

//--------------------------------------------------------------- GAMESTATE DEFS

tState g_sStateMenu = {
	.cbCreate = menuGsCreate, .cbLoop = menuGsLoop, .cbDestroy = menuGsDestroy
};

static tState s_sStateCredits = {
	.cbCreate = creditsGsCreate, .cbLoop = textBasedGsLoop
};

static tState s_sStateHowTo = {
	.cbCreate = howToGsCreate, .cbLoop = textBasedGsLoop
};

static tState s_sStateBattle = {
	.cbCreate = battleGsCreate, .cbLoop = menuSubstateLoop,
	.cbDestroy = battleGsDestroy
};

static tState s_sStateCampaign = {
	.cbCreate = campaignGsCreate, .cbLoop = menuSubstateLoop, .cbDestroy = 0
};

static tState s_sStateMain = {
	.cbCreate = mainGsCreate, .cbLoop = menuSubstateLoop
};

static tState s_sStateSteer = {
	.cbCreate = menuSteerGsCreate, .cbLoop = menuSubstateLoop
};
