/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "game_play.h"
#include <ace/managers/game.h>
#include <ace/managers/key.h>
#include <ace/utils/font.h>
#include <ace/utils/string.h>
#include "game.h"
#include "assets.h"
#include "game_pause.h"
#include "game_editor.h"
#include "player.h"
#include "blob_anim.h"
#include "germz.h"
#include "color.h"

#define HUD_GRABBED_OFFS_Y 15
#define HUD_COPY_DELTA_Y 3

// The widest digit is 11px wide, there may be 3 of them, each spaced with 1px
#define HUD_UNDRAW_WIDTH ((11 + 1) * 3 - 1)
// Whole row because of icon
#define HUD_UNDRAW_WIDTH_GRAB 44
#define HUD_UNDRAW_HEIGHT 10

typedef enum tHudState {
	HUD_STATE_PLEPS_DRAW,
	HUD_STATE_GRABBED_PLEPS_DRAW,
	HUD_STATE_NEXT_PLAYER,
	HUD_STATE_RIP_UNDRAW
} tHudState;

static UBYTE s_isHudDrawnOnce;
static UBYTE s_isHudDrawCurrent;
static tPlayerIdx s_eHudCurrPlayer;
static UBYTE s_pHudPlayersWereDead[4];
tHudState s_eHudState;

static tBitMap s_sBmHudAlias, s_sBmHudAliasFront;

void gamePlayHudClear(void) {
	const UBYTE ubMonitorPad = 7;
	const UWORD uwMonitorX = HUD_OFFS_X + ubMonitorPad;
	s_sBmHudAliasFront.Planes[0] = gameGetFrontBuffer()->Planes[2];

	for(UBYTE i = 0; i < 4; ++i) {
		if(!s_pHudPlayersWereDead[i]) {
			const UWORD uwMonitorY = i * HUD_MONITOR_SIZE + ubMonitorPad;

			// Erase whole HUD
			blitRect(
				&s_sBmHudAliasFront, uwMonitorX, uwMonitorY,
				48, HUD_GRABBED_OFFS_Y + g_pFontBig->uwHeight, 0
			);
		}
	}
}

static void hudProcess(void) {
	static const UWORD pPlayerColors[][2] = {
		{RGB8TO4(68, 255, 153), RGB8TO4(51, 204, 119)},
		{RGB8TO4(255, 85, 85), RGB8TO4(204, 51, 51)},
		{RGB8TO4(255, 221, 102), RGB8TO4(204, 170, 68)},
		{RGB8TO4(17, 119, 255), RGB8TO4(0, 85, 204)},
		{RGB8TO4(170, 187, 170), RGB8TO4(136, 153, 136)},
	};
	// colors are arranged so that only top bitplane needs updating:
	// 6: 00110 special
	// 7: 00111 special scanlines dark
	// 2: 00010 bg
	// 3: 00011 bg scanlines dark, so do scanlines with LSbit

	const tPlayer *pPlayer = playerFromIdx(s_eHudCurrPlayer);
	const UBYTE ubMonitorPad = 7;
	const UWORD uwMonitorX = HUD_OFFS_X + ubMonitorPad;
	const UWORD uwMonitorY = s_eHudCurrPlayer * HUD_MONITOR_SIZE + ubMonitorPad;
	s_sBmHudAlias.Planes[0] = gameGetBackBuffer()->Planes[2];
	s_sBmHudAliasFront.Planes[0] = gameGetFrontBuffer()->Planes[2];

	tHudState eNextState = s_eHudState;
	switch(s_eHudState) {
		case HUD_STATE_PLEPS_DRAW:
			if(pPlayer->isDead) {
				if(!s_pHudPlayersWereDead[s_eHudCurrPlayer]) {
					eNextState = HUD_STATE_RIP_UNDRAW;
				}
				else {
					eNextState = HUD_STATE_NEXT_PLAYER;
				}
				s_isHudDrawnOnce = 1;
			}
			else {
				if(!s_isHudDrawnOnce) {
					blitRect(
						&s_sBmHudAlias, uwMonitorX, uwMonitorY + HUD_COPY_DELTA_Y,
						HUD_UNDRAW_WIDTH, HUD_UNDRAW_HEIGHT, 0
					);
					char szBfr[6];
					stringDecimalFromULong(pPlayer->pNodeCursor->wCharges, szBfr);
					fontDrawStr1bpp(
						g_pFontBig, &s_sBmHudAlias, uwMonitorX, uwMonitorY, szBfr
					);
				}
				else {
					blitCopy(
						&s_sBmHudAliasFront, uwMonitorX, uwMonitorY + HUD_COPY_DELTA_Y,
						&s_sBmHudAlias, uwMonitorX, uwMonitorY + HUD_COPY_DELTA_Y,
						HUD_UNDRAW_WIDTH, HUD_UNDRAW_HEIGHT, MINTERM_COOKIE
					);
				}
				// Update HUD color
				tCopCmd *pList = gameGetColorCopperlist();
				tPlayerIdx ePlayerHover = playerToIdx(pPlayer->pNodeCursor->pPlayer);
				pList[s_eHudCurrPlayer * 3 + 1].sMove.bfValue = pPlayerColors[ePlayerHover][0];
				pList[s_eHudCurrPlayer * 3 + 2].sMove.bfValue = pPlayerColors[ePlayerHover][1];

				eNextState = HUD_STATE_GRABBED_PLEPS_DRAW;
			}
			break;
		case HUD_STATE_GRABBED_PLEPS_DRAW:
			if(!s_isHudDrawnOnce) {
				blitRect(
					&s_sBmHudAlias, uwMonitorX, uwMonitorY + HUD_GRABBED_OFFS_Y + HUD_COPY_DELTA_Y,
					HUD_UNDRAW_WIDTH_GRAB, HUD_UNDRAW_HEIGHT, 0
				);
				if(pPlayer->isSelectingDestination) {
					char szBfr[6];
					stringDecimalFromULong(pPlayer->pNodePlepSrc->wCharges / 2, szBfr);
					fontDrawStr1bpp(
						g_pFontBig, &s_sBmHudAlias,
						uwMonitorX, uwMonitorY + HUD_GRABBED_OFFS_Y, szBfr
					);
					blitCopy(
						g_pBmHudTarget, 0, 0, &s_sBmHudAlias, uwMonitorX + 44 - 10,
						uwMonitorY + HUD_GRABBED_OFFS_Y + HUD_COPY_DELTA_Y, 9, 9, MINTERM_COOKIE
					);
				}
			}
			else {
				blitCopy(
					&s_sBmHudAliasFront, uwMonitorX, uwMonitorY + HUD_GRABBED_OFFS_Y + HUD_COPY_DELTA_Y,
					&s_sBmHudAlias, uwMonitorX, uwMonitorY + HUD_GRABBED_OFFS_Y + HUD_COPY_DELTA_Y,
					HUD_UNDRAW_WIDTH_GRAB, HUD_UNDRAW_HEIGHT, MINTERM_COOKIE
				);
			}
			eNextState = HUD_STATE_NEXT_PLAYER;
			break;
		case HUD_STATE_RIP_UNDRAW:
			// Go here only once
			s_pHudPlayersWereDead[s_eHudCurrPlayer] = 1;

			// Erase whole HUD
			blitRect(
				&s_sBmHudAlias, uwMonitorX, uwMonitorY,
				32, HUD_GRABBED_OFFS_Y + g_pFontBig->uwHeight, 0
			);
			eNextState = HUD_STATE_NEXT_PLAYER;
			break;
		default:
			break;
	}

	if(!s_isHudDrawnOnce) {
		// Stay in same state for one more frame (double buffering)
		s_isHudDrawnOnce = 1;
	}
	else {
		s_isHudDrawnOnce = 0;
		if(eNextState == HUD_STATE_NEXT_PLAYER) {
			// Switch player, reset state machine
			s_eHudCurrPlayer = (s_eHudCurrPlayer + 1) & 3;
			s_eHudState = 0;
		}
		else {
			// Proceed to next state
			s_eHudState = eNextState;
		}
	}
}

static void hudReset(void) {
	s_isHudDrawnOnce = 0;
	s_isHudDrawCurrent = 0;
	s_eHudCurrPlayer = 0;
	memset(s_pHudPlayersWereDead, 0, sizeof(s_pHudPlayersWereDead));
	s_eHudState = 0;
}

static UBYTE isEndOfMatch(UBYTE ubFfaAliveCount, tPauseKind *pPauseKind) {
	// Process end of match conditions
	if(gameIsCampaign()) {
		// Campaign
		if(playerFromIdx(PLAYER_1)->isDead) {
			*pPauseKind = PAUSE_KIND_CAMPAIGN_DEFEAT;
			return 1;
		}
		if(
			playerFromIdx(PLAYER_2)->isDead &&
			playerFromIdx(PLAYER_3)->isDead &&
			playerFromIdx(PLAYER_4)->isDead
		) {
			*pPauseKind = PAUSE_KIND_CAMPAIGN_WIN;
			return 1;
		}
	}
	else {
		// Battle
		if(gameGetBattleMode() == BATTLE_MODE_TEAMS) {
			// Teams
			tTeamIdx eTeam  = gameGetWinnerTeams();
			if(eTeam != TEAM_NONE) {
				if(gameIsStartedByEditor()) {
					stateChange(g_pStateMachineGame, &g_sStateEditor);
				}
				else {
					UBYTE *pScores = gameGetScores();
					pScores[eTeam] = MIN(pScores[eTeam] + 1, 99);
					*pPauseKind = PAUSE_KIND_BATTLE_SUMMARY;
				}
				return 1;
			}
		}
		else {
			// FFA
			if(ubFfaAliveCount <= 1) {
				tPlayerIdx eWinner = gameGetWinnerFfa();
				if(eWinner != PLAYER_NONE) {
					if(gameIsStartedByEditor()) {
						stateChange(g_pStateMachineGame, &g_sStateEditor);
					}
					else {
						UBYTE *pScores = gameGetScores();
						pScores[eWinner] = MIN(pScores[eWinner] + 1, 99);
						*pPauseKind = PAUSE_KIND_BATTLE_SUMMARY;
					}
					return 1;
				}
			}
		}
	}
	return 0;
}

//-------------------------------------------------------------------- GAMESTATE

static void gamePlayGsCreate(void) {
	tBitMap *pDisplay = gameGetBackBuffer();
	s_sBmHudAlias.Rows = pDisplay->Rows;
	s_sBmHudAlias.BytesPerRow = pDisplay->BytesPerRow;
	s_sBmHudAlias.Depth = 1;
	s_sBmHudAliasFront.Rows = pDisplay->Rows;
	s_sBmHudAliasFront.BytesPerRow = pDisplay->BytesPerRow;
	s_sBmHudAliasFront.Depth = 1;

	hudReset();
	blobAnimReset();
}

static void gamePlayGsLoop(void) {
	if(!gamePreprocess(1)) {
		return;
	}
	blobAnimQueueProcess();
	hudProcess();
	blitWait();
	UBYTE ubAliveCount = playerProcess();
	playerPushCursors();
	bobNewPushingDone();
	mapProcessNodes();

	tPauseKind ePauseKind;
	if(isEndOfMatch(ubAliveCount, &ePauseKind)) {
		gamePauseEnable(ePauseKind);
		return;
	}
	gamePostprocess();
}

static void gamePlayGsDestroy(void) {

}

static void gamePlayGsResume(void) {
	// Restart HUD state machine after going back from pause so that it won't try
	// to use textBitMap with wrong content
	hudReset();
}

tState g_sStateGamePlay = {
	.cbCreate = gamePlayGsCreate, .cbLoop = gamePlayGsLoop,
	.cbDestroy = gamePlayGsDestroy, .cbResume = gamePlayGsResume
};
