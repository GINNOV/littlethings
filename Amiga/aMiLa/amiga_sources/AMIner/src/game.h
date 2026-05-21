/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _GAME_H_
#define _GAME_H_

#include "aminer.h"
#include <ace/managers/ptplayer.h>
#include <ace/managers/bob.h>
#include "string_array.h"
#include "steer.h"

#ifdef __cplusplus
extern "C" {
#endif

#define GAME_BPP 5
#define GAME_TIME_PER_DAY 140
#define GAME_MESSAGE_BUFFER_SIZE 500

typedef enum tRebukeKind {
	REBUKE_INVALID,
	REBUKE_ACCOUNTING,
	REBUKE_BRIBE,
	REBUKE_FINAL,
	REBUKE_GATE_DESTROYED,
	REBUKE_PLAN_1,
	REBUKE_PLAN_2,
	REBUKE_QUESTIONING_CRATE,
	REBUKE_QUESTIONING_GATE,
	REBUKE_VEHICLE_DESTROYED,
} tRebukeKind;

typedef enum tGameMode {
	GAME_MODE_STORY,
	GAME_MODE_CHALLENGE,
	GAME_MODE_DEADLINE,
} tGameMode;

typedef struct tGameSummary {
	ULONG ulGameTime;
	LONG lCash;
	UWORD uwMaxDepth;
	UBYTE ubRebukes;
	UBYTE ubAccolades;
	UBYTE ubHeatPercent;
	UBYTE ubPlanIndex;
} tGameSummary;

typedef enum tGameCutscene {
	GAME_CUTSCENE_TELEPORT,
	GAME_CUTSCENE_GATE_OPEN,
	GAME_CUTSCENE_GATE_EXPLODE,
} tGameCutscene;

UBYTE tileIsSolid(UWORD uwX, UWORD uwY);

void gameGsLoopChallengeEnd(void);

void gameStart(tGameMode g_eGameMode, tSteer sSteerP1, tSteer sSteerP2);

void gameTriggerSave(void);

UBYTE gameLoad(tFile *pFile);

UBYTE gameLoadSummary(tFile *pFile, tGameSummary *pSummary);

void gameGsLoopEnterScore(void);

void gameInitBobs(void);

UBYTE gameIsRangeVisibleOnCamera(UWORD uwStartY, UWORD uwEndY);

UBYTE gameCanPushBob(const tBob *pBob);

UBYTE gameTryPushBob(tBob *pBob);

void gameAdvanceAccolade(void);

void gameAddAccolade(void);

void gameAddRebuke(tRebukeKind eRebuke);

UBYTE gameGetAccoladeCount(void);

UBYTE gameGetRebukeCount(void);

tRebukeKind gameGetRebuke(UBYTE ubRebukeIndex);

void gameElapseTime(UWORD uwTime);

void gameElapseDay(void);

ULONG gameGetTime(void);

UBYTE gameIsElapsedDays(ULONG ulStart, UBYTE ubDays);

tSteer *gameGetSteers(void);

void gameCancelModeForPlayer(UBYTE ubPlayer);

void gameUpdateMaxDepth(UWORD uwTileY);

UBYTE gameIsCutsceneActive(void);

void gameTriggerCutscene(tGameCutscene eCutscene);

void gameProcessMusicInterval(void);

void gameProcessBaseWestern(void);

void gameProcessBaseGate(void);

char *gameGetMessageBuffer(void);

// Game config
extern UBYTE g_is2pPlaying;
extern UBYTE g_isAtari;
extern UBYTE g_isSokoUnlock;
extern tGameMode g_eGameMode;
extern tState g_sStateGame;

#ifdef __cplusplus
}
#endif

#endif // _GAME_H_
