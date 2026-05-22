/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "game.h"
#include <ace/managers/key.h>
#include <ace/managers/game.h>
#include <ace/managers/sprite.h>
#include <ace/managers/system.h>
#include <ace/managers/bob.h>
#include "display.h"
#include "warrior.h"
#include "assets.h"
#include "tile.h"
#include "chaos_arena.h"
#include "sfx.h"
#include "menu.h"
#include "debug.h"

#define GAME_CRUMBLE_COOLDOWN 1
#define GAME_COUNTDOWN_COOLDOWN 50
#define GAME_STOP_COOLDOWN 50

typedef enum tCountdownPhase {
	COUNTDOWN_PHASE_OFF,
	COUNTDOWN_PHASE_FIGHT,
	COUNTDOWN_PHASE_1,
	COUNTDOWN_PHASE_2,
	COUNTDOWN_PHASE_3,
	COUNTDOWN_PHASE_COUNT,
} tCountdownPhase;

static tSimpleBufferManager *s_pVpManager;
#if defined(ACE_BOB_PRISTINE_BUFFER)
static tBitMap *s_pPristineBuffer;
#endif
static tBob s_sBobCountdown;
static tBob s_sBobFight;
static tCountdownPhase s_eCountdownPhase;
static UBYTE s_ubCountdownCooldown;
static UBYTE s_ubCrumbleCooldown;
static UBYTE s_ubGameStopCooldown;

static void gameGsCreate(void) {
	tilesInit();
	s_pVpManager = displayGetManager();
#if defined(ACE_BOB_PRISTINE_BUFFER)
	s_pPristineBuffer = bitmapCreate(
		bitmapGetByteWidth(s_pVpManager->pBack) * 8,
		s_pVpManager->pBack->Rows,
		s_pVpManager->pBack->Depth, BMF_INTERLEAVED
	);
#endif

	bobManagerCreate(
		s_pVpManager->pBack, s_pVpManager->pFront,
#if defined(ACE_BOB_PRISTINE_BUFFER)
		s_pPristineBuffer,
#endif
		512
	);
	warriorsCreate(menuIsExtraEnemiesEnabled());

	UBYTE ubCountdownWidth = bitmapGetByteWidth(g_pCountdownFrames) * 8;
	UBYTE ubFightWidth = bitmapGetByteWidth(g_pFightBitmap) * 8;
	bobInit(
		&s_sBobCountdown, ubCountdownWidth, g_pCountdownFrames->Rows / 3, 1,
		g_pCountdownFrames->Planes[0], g_pCountdownMask->Planes[0],
		(DISPLAY_WIDTH - ubCountdownWidth) / 2, 100
	);
	bobInit(
		&s_sBobFight, ubFightWidth, g_pFightBitmap->Rows, 1,
		g_pFightBitmap->Planes[0], g_pFightMask->Planes[0],
		(DISPLAY_WIDTH - ubFightWidth) / 2, 100
	);

	s_eCountdownPhase = COUNTDOWN_PHASE_COUNT;
	s_ubCountdownCooldown = 1;
	s_ubCrumbleCooldown = GAME_CRUMBLE_COOLDOWN;
	s_ubGameStopCooldown = GAME_STOP_COOLDOWN;

	bobReallocateBuffers();
	systemUnuse();

	tilesReload();
	tilesDrawAllOn(s_pVpManager->pBack);
	tilesDrawAllOn(s_pVpManager->pFront);
#if defined(ACE_BOB_PRISTINE_BUFFER)
	tilesDrawAllOn(s_pPristineBuffer);
#endif
	warriorsEnableMove(0);
	ptplayerLoadMod(g_pModCombat, g_pModSamples, 0);
	ptplayerEnableMusic(1);
}

static void countdownProcess(void) {
	if(!s_eCountdownPhase) {
		return;
	}

	if(--s_ubCountdownCooldown == 0) {
		s_ubCountdownCooldown = GAME_COUNTDOWN_COOLDOWN;
		--s_eCountdownPhase;
		if(s_eCountdownPhase > COUNTDOWN_PHASE_FIGHT) {
			UWORD uwBytesPerFrame = g_pCountdownFrames->BytesPerRow * s_sBobCountdown.uwHeight;
			ULONG ulFrameOffset = uwBytesPerFrame * (4 - s_eCountdownPhase);
			bobSetFrame(
				&s_sBobCountdown, &g_pCountdownFrames->Planes[0][ulFrameOffset],
				&g_pCountdownMask->Planes[0][ulFrameOffset]
			);
			ptplayerSfxPlay(
				g_pSfxCountdown[s_eCountdownPhase - COUNTDOWN_PHASE_1],
				2, 64, SFX_PRIORITY_COUNTDOWN
			);
		}
		else if(s_eCountdownPhase == COUNTDOWN_PHASE_FIGHT) {
			ptplayerSfxPlay(g_pSfxCountdownFight, 2, 64, SFX_PRIORITY_COUNTDOWN);
		}
		else if(s_eCountdownPhase == COUNTDOWN_PHASE_OFF) {
			warriorsEnableMove(1);
		}
	}

	switch(s_eCountdownPhase) {
		case COUNTDOWN_PHASE_3:
		case COUNTDOWN_PHASE_2:
		case COUNTDOWN_PHASE_1:
			bobPush(&s_sBobCountdown);
			break;
		case COUNTDOWN_PHASE_FIGHT:
			bobPush(&s_sBobFight);
			break;
		default:
			break;
	}
}

static void gameTransitToMenu(void) {
	// Blit currently visible bitmap to backbuffer in order to mitigate flickering on bobs/crumbles
	const UBYTE ubParts = 4;
	UBYTE ubPartHeight = DISPLAY_HEIGHT / ubParts;
	UWORD uwOffsY = 0;
	for(UBYTE i = 0; i < 4; ++i) {
		blitCopyAligned(
			s_pVpManager->pFront, 0, uwOffsY, s_pVpManager->pBack, 0, uwOffsY,
			DISPLAY_WIDTH, ubPartHeight
		);
		uwOffsY += ubPartHeight;
	}

	// Now that bitmaps are synchronized, go to menu
	stateChange(g_pStateMachineGame, &g_sStateMenu);
}

static void gameGsLoop(void) {
	if(keyUse(KEY_ESCAPE)) {
		// Game canceled - go back to menu
		menuSetupMain();
		gameTransitToMenu();
		return;
	}

	UBYTE ubAlivePlayers = warriorsGetAlivePlayerCount();
	if(ubAlivePlayers == 1 && warriorsGetAliveCount() == 1) {
		--s_ubGameStopCooldown;
	}
	if(ubAlivePlayers == 0 || s_ubGameStopCooldown == 0) {
		menuSetupSummary(warriorsGetLastAliveIndex());
		gameTransitToMenu();
		return;
	}

	debugSetColor(0x008);
	bobBegin(s_pVpManager->pBack);

	debugSetColor(0x0ff);
	if(!s_eCountdownPhase) {
		if(!s_ubCrumbleCooldown) {
			tileCrumbleProcess(s_pVpManager->pBack);
#if defined(ACE_BOB_PRISTINE_BUFFER)
			tileCrumbleProcess(s_pPristineBuffer);
#endif
		}
		else {
			--s_ubCrumbleCooldown;
		}
	}

	debugSetColor(0x0f0);
	warriorsProcess();
	countdownProcess();

	debugSetColor(0x00f);
	bobPushingDone();
	bobEnd();
	// warriorsDrawLookup(s_pVpManager->pBack);
}

static void gameGsDestroy(void) {
	ptplayerStop();
	systemUse();
	bobManagerDestroy();
#if defined(ACE_BOB_PRISTINE_BUFFER)
	bitmapDestroy(s_pPristineBuffer);
#endif
	warriorsDestroy();
}

UBYTE gameIsCountdownActive(void) {
	return s_eCountdownPhase != COUNTDOWN_PHASE_OFF;
}

tState g_sStateGame = {
	.cbCreate = gameGsCreate, .cbLoop = gameGsLoop, .cbDestroy = gameGsDestroy
};
