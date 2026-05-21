/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "game_pause.h"
#include <ace/managers/key.h>
#include <ace/utils/bmframe.h>
#include <ace/utils/string.h>
#include "germz.h"
#include "gui/dialog.h"
#include "game.h"
#include "assets.h"
#include "color.h"
#include "menu_list.h"
#include "player.h"
#include "gui_scanlined.h"

#define PAUSE_MENU_MAX 3
#define PAUSE_MENU_COLOR_ACTIVE (COLOR_P3_BRIGHT >> 1)
#define PAUSE_MENU_COLOR_INACTIVE ((COLOR_P3_BRIGHT + 2) >> 1)

static tBitMap *s_pBmDialog;
static tBitMap s_sBmDlgScanline;
static tPauseKind s_eKind;

static tSteer s_sSteerPause; ///< Emergency steer in case no player uses arrows
static tSteer *s_pSteers[4];
static UBYTE s_ubSteerCount;

static void onRestart(void);
static void onExit(void);
static void onBack(void);
static void onNextMap(void);

static tMenuListOption s_pPauseOptions[PAUSE_MENU_MAX];
static const char *s_pPauseLabels[PAUSE_MENU_MAX];

static void pauseMenuPosDraw(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
) {
	// Draw pos + non-zero shadow
	fontFillTextBitMap(g_pFontBig, g_pTextBitmap, szText);
	*pUndrawWidth = g_pTextBitmap->uwActualWidth;
	UBYTE ubColor = (isActive ? PAUSE_MENU_COLOR_ACTIVE : PAUSE_MENU_COLOR_INACTIVE);

	fontDrawTextBitMap(
		&s_sBmDlgScanline, g_pTextBitmap, uwX, uwY, ubColor, FONT_COOKIE
	);
}

static void gamePauseGsCreate(void) {
	s_ubSteerCount = 0;
	UBYTE isArrows = 0;
	for(tPlayerIdx ePlayerIdx = 0; ePlayerIdx <= PLAYER_4; ++ePlayerIdx) {
		const tPlayer *pPlayer = playerFromIdx(ePlayerIdx);
		if(steerIsPlayer(pPlayer->pSteer)) {
			s_pSteers[s_ubSteerCount++] = pPlayer->pSteer;
			if(steerIsArrows(pPlayer->pSteer)) {
				isArrows = 1;
			}
		}
	}
	if(!isArrows) {
		s_sSteerPause = steerInitKey(KEYMAP_ARROWS);
		s_pSteers[s_ubSteerCount++] = &s_sSteerPause;
	}

	UWORD uwDlgWidth = 192;
	UWORD uwDlgHeight = 160;
	s_pBmDialog = dialogCreate(
		uwDlgWidth, uwDlgHeight, gameGetFrontBuffer(), gameGetFrontBuffer()
	);

	s_sBmDlgScanline.BytesPerRow = s_pBmDialog->BytesPerRow;
	s_sBmDlgScanline.Rows = s_pBmDialog->Rows;
	s_sBmDlgScanline.Depth = s_pBmDialog->Depth - 1;
	s_sBmDlgScanline.Planes[0] = s_pBmDialog->Planes[1];
	s_sBmDlgScanline.Planes[1] = s_pBmDialog->Planes[2];
	s_sBmDlgScanline.Planes[2] = s_pBmDialog->Planes[3];
	s_sBmDlgScanline.Planes[3] = s_pBmDialog->Planes[4];

	bmFrameDraw(
		g_pFrameDisplay, s_pBmDialog, 0, 0, uwDlgWidth / 16, uwDlgHeight / 16, 16
	);

	UWORD uwX = 16;
	UWORD uwY = 16;
	UWORD uwRowSize = g_pFontBig->uwHeight + 2;

	switch(s_eKind) {
		case PAUSE_KIND_BATTLE_PAUSE:
		case PAUSE_KIND_CAMPAIGN_PAUSE:
		case PAUSE_KIND_CAMPAIGN_WIN:
		case PAUSE_KIND_CAMPAIGN_DEFEAT: {
			static const char *pMsgs[] = {
				[PAUSE_KIND_BATTLE_PAUSE] = "PAUSED",
				[PAUSE_KIND_CAMPAIGN_PAUSE] = "PAUSED",
				[PAUSE_KIND_CAMPAIGN_WIN] = "YOU WIN",
				[PAUSE_KIND_CAMPAIGN_DEFEAT] = "DEFEATED"
			};
			fontDrawStr(
				g_pFontBig, &s_sBmDlgScanline, uwDlgWidth / 2, uwY, pMsgs[s_eKind],
				18 >> 1, FONT_HCENTER | FONT_COOKIE, g_pTextBitmap
			);
		} break;
		case PAUSE_KIND_BATTLE_SUMMARY: {
			char szWins[15];
			UBYTE ubColor;
			if(gameGetBattleMode() == BATTLE_MODE_TEAMS) {
				tTeamIdx eTeam  = gameGetWinnerTeams();
				if(eTeam == TEAM_NONE) {
					ubColor = COLOR_P3_BRIGHT;
					strcpy(szWins, "DRAW");
				}
				else {
					ubColor = COLOR_P1_BRIGHT + 4 * playerToIdx(gameGetTeamLeaders()[eTeam]);
					sprintf(szWins, "TEAM %d WINS", eTeam + 1);
				}
			}
			else {
				tPlayerIdx ePlayer = gameGetWinnerFfa();
				if(ePlayer == PLAYER_NONE) {
					ubColor = COLOR_P3_BRIGHT;
					strcpy(szWins, "DRAW");
				}
				else {
					ubColor = COLOR_P1_BRIGHT + 4 * ePlayer;
					sprintf(szWins, "PLAYER %d WINS", ePlayer + 1);
				}
			}
			fontDrawStr(
				g_pFontBig, &s_sBmDlgScanline, uwDlgWidth / 2, uwY, szWins,
				ubColor >> 1, FONT_HCENTER | FONT_COOKIE, g_pTextBitmap
			);
		} break;
	}
	uwY += uwRowSize * 3 / 2;

	if(
		s_eKind == PAUSE_KIND_BATTLE_PAUSE || s_eKind == PAUSE_KIND_BATTLE_SUMMARY
	) {
		fontDrawStr(
			g_pFontBig, &s_sBmDlgScanline, uwX, uwY, "CURRENT SCORE", 18 >> 1,
			FONT_COOKIE, g_pTextBitmap
		);
		uwY += uwRowSize;

		if(gameIsCampaign()) {
			// Campaign - map number?
		}
		else {
			// Battle
			UBYTE ubPlayerCount;
			UBYTE ubMask;
			const UBYTE *pColors;
			if(gameGetBattleMode() == BATTLE_MODE_TEAMS) {
				// Teams
				static const UBYTE pTeamColors[TEAM_CONFIG_COUNT][4] = {
					[TEAM_CONFIG_P1_P2_AND_P3_P4] = {COLOR_P1_BRIGHT, COLOR_P3_BRIGHT},
					[TEAM_CONFIG_P1_P3_AND_P2_P4] = {COLOR_P1_BRIGHT, COLOR_P2_BRIGHT},
					[TEAM_CONFIG_P1_P4_AND_P2_P3] = {COLOR_P1_BRIGHT, COLOR_P2_BRIGHT},
				};
				ubMask = 0b11;
				ubPlayerCount = 2;
				pColors = pTeamColors[gameGetTeamConfig()];
			}
			else {
				// FFA
				static const UBYTE pPlayerColors[] = {
					COLOR_P1_BRIGHT, COLOR_P2_BRIGHT, COLOR_P3_BRIGHT, COLOR_P4_BRIGHT
				};
				ubPlayerCount = mapDataGetPlayerCount(&g_sMapData);
				ubMask = g_sMapData.ubPlayerMask;
				pColors = pPlayerColors;
			}

			UBYTE *pScores = gameGetScores();
			char szScore[4];
			UBYTE i = 0;
			for(UBYTE ubPlayer = 0; ubPlayer < 4; ++ubPlayer) {
				if(ubMask & 1) {
					stringDecimalFromULong(pScores[ubPlayer], szScore);
					UBYTE ubColor = pColors[ubPlayer];
					UWORD uwPlayerX = uwX + (i + 1) * ((uwDlgWidth - 2 * uwX) / (ubPlayerCount + 1));
					fontDrawStr(
						g_pFontBig, &s_sBmDlgScanline, uwPlayerX, uwY, szScore,
						ubColor >> 1, FONT_HCENTER | FONT_COOKIE, g_pTextBitmap
					);
					++i;
				}
				ubMask >>= 1;
			}
			uwY += uwRowSize * 2;
		}
	}

	UBYTE ubOptionCount = 0;

	if(s_eKind == PAUSE_KIND_BATTLE_PAUSE || s_eKind == PAUSE_KIND_CAMPAIGN_PAUSE) {
		s_pPauseLabels[ubOptionCount] = "BACK";
		s_pPauseOptions[ubOptionCount++] = (tMenuListOption){
			.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK,
			.sOptCb = {.cbSelect = onBack}
		};
	}

	if(s_eKind == PAUSE_KIND_CAMPAIGN_WIN) {
		s_pPauseLabels[ubOptionCount] = "CONTINUE";
		s_pPauseOptions[ubOptionCount++] = (tMenuListOption){
			.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK,
			.sOptCb = {.cbSelect = onNextMap}
		};
	}
	else {
		s_pPauseLabels[ubOptionCount] = "RESTART MATCH";
		s_pPauseOptions[ubOptionCount++] = (tMenuListOption){
			.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK,
			.sOptCb = {.cbSelect = onRestart}
		};

		s_pPauseLabels[ubOptionCount] = "EXIT TO MENU";
		s_pPauseOptions[ubOptionCount++] = (tMenuListOption){
			.eOptionType = MENU_LIST_OPTION_TYPE_CALLBACK,
			.sOptCb = {.cbSelect = onExit}
		};
	}

	menuListInit(
		s_pPauseOptions, s_pPauseLabels, ubOptionCount, g_pFontBig,
		uwX, uwY, guiScanlinedBgClear, pauseMenuPosDraw
	);
}

static void gamePauseGsLoop(void) {
	UBYTE isAnyPlayerMoved = 0;
	for(UBYTE ubSteerIdx = 0; ubSteerIdx < s_ubSteerCount; ++ubSteerIdx) {
		tSteer *pSteer = s_pSteers[ubSteerIdx];
		steerProcess(pSteer);
		if(steerDirUse(pSteer, DIRECTION_UP)) {
			menuListNavigate(-1);
			isAnyPlayerMoved = 1;
		}
		else if(steerDirUse(pSteer, DIRECTION_DOWN)) {
			menuListNavigate(+1);
			isAnyPlayerMoved = 1;
		}
	}

	menuListDraw();
	dialogProcess(gameGetFrontBuffer());

	// Process pressing fire after gamePostProcess and only if noone moved up/down
	if(!isAnyPlayerMoved) {
		for(UBYTE ubSteerIdx = 0; ubSteerIdx < s_ubSteerCount; ++ubSteerIdx) {
			tSteer *pSteer = s_pSteers[ubSteerIdx];
			if(steerDirUse(pSteer, DIRECTION_FIRE) || keyUse(KEY_RETURN)) {
				menuListEnter();
				// Don't process anything else past this point
				return;
			}
		}
	}

	if(
		keyUse(KEY_ESCAPE) &&
		(s_eKind == PAUSE_KIND_BATTLE_PAUSE || s_eKind == PAUSE_KIND_CAMPAIGN_PAUSE)
	) {
		onBack();
	}
}

static void gamePauseGsDestroy(void) {
	dialogDestroy();
}

tState g_sStateGamePause = {
	.cbCreate = gamePauseGsCreate, .cbLoop = gamePauseGsLoop,
	.cbDestroy = gamePauseGsDestroy
};

//--------------------------------------------------------------- MENU CALLBACKS

static void onRestart(void) {
	// Back to original state
	statePop(g_pStateMachineGame);

	// Restart game
	gameRestart();
}

static void onExit(void) {
	// Back to original state
	statePop(g_pStateMachineGame);

	// Make game quit
	gameQuit();
}

static void onBack(void) {
	// Back to original state
	statePop(g_pStateMachineGame);

	// Do nothing else
}

static void onNextMap(void) {
	// Back to original state
	statePop(g_pStateMachineGame);

	// Advance the campaign state
	gameCampaignAdvance();
}

//------------------------------------------------------------------- PUBLIC FNS

void gamePauseEnable(tPauseKind eKind) {
	s_eKind = eKind;
	// Switch to pause gamestate - needs pop 'cuz we can't call destroy callback
	// of gameInit/gamePlay here
	statePush(g_pStateMachineGame, &g_sStateGamePause);
}
