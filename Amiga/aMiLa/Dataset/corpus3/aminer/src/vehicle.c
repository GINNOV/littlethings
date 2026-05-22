/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "vehicle.h"
#include <ace/managers/rand.h>
#include <ace/utils/string.h>
#include <ace/contrib/managers/audio_mixer.h>
#include "hud.h"
#include "core.h"
#include "game.h"
#include "tile.h"
#include "warehouse.h"
#include "color.h"
#include "flipbook.h"
#include "dino.h"
#include "ground_layer.h"
#include "defs.h"
#include "inventory.h"
#include "save.h"
#include "quest_gate.h"
#include "quest_crate.h"
#include "assets.h"
#include "blitter_mutex.h"
#include "base_unlocks.h"
#include "protests.h"
#include "msg.h"
#include <comm/page_workshop.h>

#define RESTOCK_RESULT_ONLY_MINERALS 0x7FFF
#define VEHICLE_BODY_HEIGHT 20
#define VEHICLE_DESTRUCTION_FRAMES 4
#define VEHICLE_TOOL_ANIM_FRAMES 2
#define VEHICLE_TOOL_OFFSET_Y 3
#define VEHICLE_TRACK_HEIGHT 7
#define VEHICLE_TRACK_DRILL_HEIGHT 7
#define VEHICLE_TRACK_JET_HEIGHT 5
#define VEHICLE_FLAME_HEIGHT 21
#define VEHICLE_TOOL_WIDTH 16
#define VEHICLE_TOOL_HEIGHT 16
#define VEHICLE_WRECK_WIDTH 48
#define VEHICLE_WRECK_HEIGHT 21
#define VEHICLE_SMOKE_WIDTH 48
#define VEHICLE_SMOKE_FRAME_HEIGHT 29
#define VEHICLE_SMOKE_ANIM_HEIGHT 42
#define VEHICLE_SMOKE_FRAMES 12
#define VEHICLE_JET_SHOW_FRAME_COUNT 10
#define VEHICLE_TOOL_PATH_LENGTH 8
#define VEHICLE_HALF_WIDTH 12

#define SFX_CHANNEL_LOOP_P1 0
#define SFX_CHANNEL_LOOP_P2 1
#define SFX_CHANNEL_EFFECT 2
#define SFX_PRIORITY_PENALTY 1
#define SFX_PRIORITY_PICKUP 0

#define TRACK_OFFSET_TRACK 0
#define TRACK_OFFSET_JET 28
#define TRACK_OFFSET_DRILL 35
#define DRILL_V_ANIM_LEN (VEHICLE_TRACK_HEIGHT + VEHICLE_TRACK_DRILL_HEIGHT - 1)

static const fix16_t s_fAccGrav = F16(1) / 8;
static const fix16_t s_fMaxGravDy = 4 * F16(1);

tBitMap *s_pBodyFrames[2], *s_pBodyMask;
tBitMap *s_pTrackFrames, *s_pTrackMask;
tBitMap *s_pJetFrames, *s_pJetMask;
tBitMap *s_pToolFrames[2], *s_pToolMask;
tBitMap *s_pWreckFrames[2], *s_pWreckMask;
tBitMap *s_pSmokeFrames, *s_pSmokeMask;
tBitMap *s_pWhiteBody, *s_pWhiteTool;
tBitMap *s_pPlayerMarkerFrames, *s_pPlayerMarkerMask;

const UBYTE s_pJetAnimOffsets[VEHICLE_TRACK_HEIGHT * 2 + 1] = {
	0, 1, 2, 3, 4, 5, 4, 3, 2, 1, 0
};

UBYTE *s_pMarkerFrameAddresses[2][2]; // [ubDir][ubPlayer]
UBYTE *s_pMarkerMaskAddresses[2]; // [ubDir]

static UBYTE s_ubBebCountdown = 0;

//------------------------------------------------------------------ PRIVATE FNS

static void vehicleCreate(tVehicle *pVehicle, UBYTE ubIdx) {
	logBlockBegin("vehicleCreate(pVehicle: %p, ubIdx: %hhu)", pVehicle, ubIdx);

	// Setup bobs
  bobInit(
		&pVehicle->sBobBody, VEHICLE_WIDTH, VEHICLE_BODY_HEIGHT, 1,
		bobCalcFrameAddress(s_pBodyFrames[ubIdx], 0),
		bobCalcFrameAddress(s_pBodyMask, 0),
		0, 0
	);
	bobInit(
		&pVehicle->sBobTrack, VEHICLE_WIDTH, VEHICLE_TRACK_HEIGHT, 1,
		bobCalcFrameAddress(s_pTrackFrames, 0),
		bobCalcFrameAddress(s_pTrackMask, 0),
		0, 0
	);
	bobInit(
		&pVehicle->sBobJet, VEHICLE_WIDTH, VEHICLE_FLAME_HEIGHT, 1,
		bobCalcFrameAddress(s_pJetFrames, 0),
		bobCalcFrameAddress(s_pJetMask, 0),
		0, 0
	);
	bobInit(
		&pVehicle->sBobTool, VEHICLE_TOOL_WIDTH, VEHICLE_TOOL_HEIGHT, 1,
		bobCalcFrameAddress(s_pToolFrames[ubIdx], 0),
		bobCalcFrameAddress(s_pToolMask, 0),
		0, 0
	);
	bobInit(
		&pVehicle->sBobWreck, VEHICLE_WRECK_WIDTH, VEHICLE_WRECK_HEIGHT, 1,
		bobCalcFrameAddress(s_pWreckFrames[ubIdx], 0),
		bobCalcFrameAddress(s_pWreckMask, 0),
		0, 0
	);
	bobInit(
		&pVehicle->sBobSmoke, VEHICLE_SMOKE_WIDTH, VEHICLE_SMOKE_FRAME_HEIGHT, 1,
		bobCalcFrameAddress(s_pSmokeFrames, 0),
		bobCalcFrameAddress(s_pSmokeMask, 0),
		0, 0
	);
	bobInit(&pVehicle->sBobMarker, 16, 4, 1, 0, 0, 0, 0);
	pVehicle->ubPlayerIdx = ubIdx;
	pVehicle->sDynamite.ubPlayer = ubIdx;

	vehicleReset(pVehicle);

	textBobCreate(&pVehicle->sTextBob, g_pFont, "Teleportacja: +1000\x1F");
	logBlockEnd("vehicleCreate()");
}

static void vehicleDestroy(tVehicle *pVehicle) {
	textBobDestroy(&pVehicle->sTextBob);
}

static void vehicleSetState(tVehicle *pVehicle, tVehicleState eNewState) {
#if defined(GAME_DEBUG)
	static const char * const pStateNames[VEHICLE_STATE_COUNT] = {
		[VEHICLE_STATE_MOVING] = "MOVING",
		[VEHICLE_STATE_DRILLING] = "DRILLING",
		[VEHICLE_STATE_EXPLODING] = "EXPLODING",
		[VEHICLE_STATE_SMOKING] = "SMOKING",
		[VEHICLE_STATE_TELEPORTING_WAIT_FOR_CAMERA] = "TELEPORTING_WAIT_FOR_CAMERA",
		[VEHICLE_STATE_TELEPORTING_INVISIBLE] = "TELEPORTING_INVISIBLE",
		[VEHICLE_STATE_TELEPORTING_VISIBLE] = "TELEPORTING_VISIBLE",
	};

	logWrite("Vehicle state: %s -> %s", pStateNames[pVehicle->ubVehicleState], pStateNames[eNewState]);
#endif
	pVehicle->ubVehicleState = eNewState;
}

//------------------------------------------------------------------- PUBLIC FNS

void vehicleManagerCreate(void) {
	// Load gfx
	s_pBodyFrames[0] = bitmapCreateFromFd(GET_SUBFILE_PREFIX("drill.bm"), 0);
	s_pBodyFrames[1] = bitmapCreateFromFd(GET_SUBFILE_PREFIX("drill_2.bm"), 0);
	s_pBodyMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("drill_mask.bm"), 0);

	s_pTrackFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("track.bm"), 0);
	s_pTrackMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("track_mask.bm"), 0);

	s_pJetFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("jet.bm"), 0);
	s_pJetMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("jet_mask.bm"), 0);

	s_pToolFrames[0] = bitmapCreateFromFd(GET_SUBFILE_PREFIX("tool.bm"), 0);
	s_pToolFrames[1] = bitmapCreateFromFd(GET_SUBFILE_PREFIX("tool_2.bm"), 0);
	s_pToolMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("tool_mask.bm"), 0);

	s_pWreckFrames[0] = bitmapCreateFromFd(GET_SUBFILE_PREFIX("wreck.bm"), 0);
	s_pWreckFrames[1] = bitmapCreateFromFd(GET_SUBFILE_PREFIX("wreck_2.bm"), 0);
	s_pWreckMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("wreck_mask.bm"), 0);

	s_pSmokeFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("smoke.bm"), 0);
	s_pSmokeMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("smoke_mask.bm"), 0);

	s_pPlayerMarkerFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("player_markers.bm"), 0);
	s_pPlayerMarkerMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("player_marker_mask.bm"), 0);

	for(UBYTE ubDir = 0; ubDir < 2; ++ubDir) {
		for(UBYTE ubPlayerIndex = 0; ubPlayerIndex < 2; ++ubPlayerIndex) {
			s_pMarkerFrameAddresses[ubDir][ubPlayerIndex] = bobCalcFrameAddress(s_pPlayerMarkerFrames, ubDir * 4 + ubPlayerIndex * 8);
			s_pMarkerMaskAddresses[ubDir] = bobCalcFrameAddress(s_pPlayerMarkerMask, ubDir * 4);
		}
	}

	blitterMutexLock();
	s_pWhiteBody = bitmapCreate(VEHICLE_WIDTH, VEHICLE_BODY_HEIGHT, GAME_BPP, BMF_INTERLEAVED);
	blitRect(s_pWhiteBody, 0, 0, VEHICLE_WIDTH, VEHICLE_BODY_HEIGHT, COLOR_WHITE);
	s_pWhiteTool = bitmapCreate(VEHICLE_TOOL_WIDTH, VEHICLE_TOOL_HEIGHT, GAME_BPP, BMF_INTERLEAVED);
	blitRect(s_pWhiteTool, 0, 0, VEHICLE_TOOL_WIDTH, VEHICLE_TOOL_HEIGHT, COLOR_WHITE);
	blitterMutexUnlock();

	vehicleCreate(&g_pVehicles[0], PLAYER_1);
	vehicleCreate(&g_pVehicles[1], PLAYER_2);
}

void vehicleManagerDestroy(void) {
	bitmapDestroy(s_pBodyFrames[0]);
	bitmapDestroy(s_pBodyFrames[1]);
	bitmapDestroy(s_pBodyMask);

	bitmapDestroy(s_pTrackFrames);
	bitmapDestroy(s_pTrackMask);

	bitmapDestroy(s_pJetFrames);
	bitmapDestroy(s_pJetMask);

	bitmapDestroy(s_pToolFrames[0]);
	bitmapDestroy(s_pToolFrames[1]);
	bitmapDestroy(s_pToolMask);

	bitmapDestroy(s_pWreckFrames[0]);
	bitmapDestroy(s_pWreckFrames[1]);
	bitmapDestroy(s_pWreckMask);

	bitmapDestroy(s_pSmokeFrames);
	bitmapDestroy(s_pSmokeMask);

	bitmapDestroy(s_pWhiteBody);
	bitmapDestroy(s_pWhiteTool);

	bitmapDestroy(s_pPlayerMarkerFrames);
	bitmapDestroy(s_pPlayerMarkerMask);

	vehicleDestroy(&g_pVehicles[0]);
	vehicleDestroy(&g_pVehicles[1]);
}

void vehicleStopLoopAudio(UBYTE ubPlayerIdx) {
	audioMixerStopSfxOnChannel(SFX_CHANNEL_LOOP_P1 + ubPlayerIdx);
}

void vehicleSetPos(tVehicle *pVehicle, UWORD uwX, UWORD uwY) {
	pVehicle->ubDrillDir = DRILL_DIR_NONE;
	pVehicle->ubDrillState = DRILL_STATE_OFF;
	vehicleSetState(pVehicle, VEHICLE_STATE_MOVING);
	pVehicle->fToolOffset = 0;

	pVehicle->fTrackAnimCnt = 0;
	pVehicle->ubTrackFrame = 0;
	pVehicle->ubBodyShakeCnt = 0;
	pVehicle->isJetting = 0;
	pVehicle->ubJetShowFrame = 0;
	pVehicle->ubJetAnimFrame = 0;
	pVehicle->ubJetAnimCnt = 0;
	pVehicle->ubToolAnimCnt = 0;
	pVehicle->ubDrillVAnimCnt = 0;
	pVehicle->ubSmokeAnimFrame = 0;
	pVehicle->ubSmokeAnimCnt = 0;


	pVehicle->fX = fix16_from_int(uwX);
	pVehicle->fY = fix16_from_int(uwY);
	pVehicle->sBobBody.sPos.uwX = fix16_to_int(pVehicle->fX);
	pVehicle->sBobBody.sPos.uwY = fix16_to_int(pVehicle->fY);
	pVehicle->fDx = 0;
	pVehicle->fDy = 0;

	// Ugly hack to reset facing
	if(pVehicle->ubPlayerIdx == PLAYER_1) {
		vehicleMove(pVehicle, 1, 0);
	}
	else {
		vehicleMove(pVehicle, -1, 0);
	}

	// Remove side effects of hack above
	pVehicle->sSteer.bX = 0;
	pVehicle->fDx = 0;

	pVehicle->isMarkerShown = 0;
}

void vehicleResetPos(tVehicle *pVehicle) {
	UWORD uwX;
	if(pVehicle->ubPlayerIdx == PLAYER_1) {
		uwX = (g_eGameMode == GAME_MODE_CHALLENGE) ? 0 : 96;
	}
	else {
		uwX = (g_eGameMode == GAME_MODE_CHALLENGE) ? 96 : 320-64;
	}
	UWORD uwY = (TILE_ROW_BASE_DIRT - 1) * TILE_SIZE;
	vehicleSetPos(pVehicle, uwX, uwY);
}

// Update body rotation as well as white frames
static void vehicleUpdateBodyBob(tVehicle *pVehicle) {
	UBYTE ubFrameOffs = VEHICLE_BODY_HEIGHT * pVehicle->ubHullDamageFrame;
	if(!pVehicle->isFacingRight) {
		ubFrameOffs += VEHICLE_BODY_HEIGHT * VEHICLE_DESTRUCTION_FRAMES;
	}

	UWORD uwByteOffset = s_pBodyMask->BytesPerRow * ubFrameOffs;
	UBYTE *pFrame;
	if(pVehicle->ubDamageBlinkCooldown) {
		--pVehicle->ubDamageBlinkCooldown;
		pFrame = s_pWhiteBody->Planes[0];
	}
	else {
		pFrame = &s_pBodyFrames[pVehicle->ubPlayerIdx]->Planes[0][uwByteOffset];
	}

	bobSetFrame(
		&pVehicle->sBobBody,
		pFrame,
		&s_pBodyMask->Planes[0][uwByteOffset]
	);
}

static void vehicleOnExplodePeak(void *pData) {
	UBYTE ubPlayerIdx = (UBYTE)(ULONG)pData;
	tVehicle *pVehicle = &g_pVehicles[ubPlayerIdx];
	vehicleSetState(pVehicle, VEHICLE_STATE_SMOKING);
	if(g_eGameMode == GAME_MODE_STORY) {
		gameAddRebuke(REBUKE_VEHICLE_DESTROYED);
		hudShowMessage(FACE_ID_KRYSTYNA, g_pMsgs[MSG_HUD_WAITING_KOMISARZ]);
	}
}

static void vehicleCrash(tVehicle *pVehicle) {
	// Calculate pos for bobs
	pVehicle->sBobWreck.sPos.uwX = fix16_to_int(pVehicle->fX);
	pVehicle->sBobWreck.sPos.uwY = (
		fix16_to_int(pVehicle->fY) + VEHICLE_BODY_HEIGHT +
		VEHICLE_TRACK_HEIGHT - VEHICLE_WRECK_HEIGHT
	);
	pVehicle->sBobSmoke.sPos.uwX = fix16_to_int(pVehicle->fX);

	flipbookAdd(
		pVehicle->sBobWreck.sPos.uwX, pVehicle->sBobWreck.sPos.uwY,
		vehicleOnExplodePeak, 0, (void*)(ULONG)(pVehicle->ubPlayerIdx), FLIPBOOK_KIND_BOOM
	);
	vehicleSetState(pVehicle, VEHICLE_STATE_EXPLODING);
	s_ubBebCountdown = 200;
}

static void vehicleHullDamage(tVehicle *pVehicle, UWORD uwDmg) {
	gameCancelModeForPlayer(pVehicle->ubPlayerIdx);
	UWORD uwHullMax = inventoryGetPartDef(INVENTORY_PART_HULL)->uwMax;
	pVehicle->wHullCurr = MAX(0, pVehicle->wHullCurr - uwDmg);
	pVehicle->ubDamageBlinkCooldown = 5;
	if(pVehicle->wHullCurr == 0) {
		vehicleCrash(pVehicle);
	}
	else {
		pVehicle->ubHullDamageFrame = (
			(((UWORD)pVehicle->wHullCurr - 1) * VEHICLE_DESTRUCTION_FRAMES) /
			uwHullMax
		);
		vehicleUpdateBodyBob(pVehicle);
		audioMixerPlaySfx(g_pSfxThud, SFX_CHANNEL_EFFECT, SFX_PRIORITY_PENALTY, 0);
	}
	hudSetHull(pVehicle->ubPlayerIdx, pVehicle->wHullCurr, uwHullMax);
}

static void vehicleHullRepair(tVehicle *pVehicle, UWORD uwNewValue) {
	UWORD uwHullMax = inventoryGetPartDef(INVENTORY_PART_HULL)->uwMax;
	pVehicle->wHullCurr = uwNewValue;
	pVehicle->ubHullDamageFrame = VEHICLE_DESTRUCTION_FRAMES - 1;
	hudSetHull(pVehicle->ubPlayerIdx, pVehicle->wHullCurr, uwHullMax);
}

void vehicleRespawn(tVehicle *pVehicle) {
	pVehicle->eDrillMode = MODE_OPTION_DRILL;
	pVehicle->uwCargoCurr = 0;
	pVehicle->uwCargoScore = 0;
	pVehicle->uwDrillCurr = inventoryGetPartDef(INVENTORY_PART_DRILL)->uwMax;
	vehicleHullRepair(pVehicle, inventoryGetPartDef(INVENTORY_PART_HULL)->uwMax);
	pVehicle->ubDamageBlinkCooldown = 0;
	for(UBYTE i = 0; i < MINERAL_TYPE_COUNT; ++i) {
		pVehicle->pStock[i] = 0;
	}
	vehicleResetPos(pVehicle);
}

void vehicleReset(tVehicle *pVehicle) {
	// Initial values
	pVehicle->isChallengeEnded = 0;
	pVehicle->lCash = g_lInitialCash;
	pVehicle->eLastVisitedTeleportableBase = BASE_ID_COUNT_UNIQUE;
	if(g_eGameMode == GAME_MODE_DEADLINE) {
		pVehicle->eLastVisitedTeleportableBase = BASE_ID_GROUND;
	}
	vehicleRespawn(pVehicle);
}

void vehicleSave(tVehicle *pVehicle, tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_VEHICLE);
	fileWrite(pFile, &pVehicle->sSteer, sizeof(pVehicle->sSteer));
	// textBobSave(&pVehicle->sTextBob, pFile);
	// bobSave(&pVehicle->sBobBody, pFile);
	// bobSave(&pVehicle->sBobTrack, pFile);
	// bobSave(&pVehicle->sBobJet, pFile);
	// bobSave(&pVehicle->sBobTool, pFile);
	// bobSave(&pVehicle->sBobWreck, pFile);
	// bobSave(&pVehicle->sBobSmoke, pFile);
	fileWrite(pFile, &pVehicle->fX, sizeof(pVehicle->fX));
	fileWrite(pFile, &pVehicle->fY, sizeof(pVehicle->fY));
	fileWrite(pFile, &pVehicle->fDx, sizeof(pVehicle->fDx));
	fileWrite(pFile, &pVehicle->fDy, sizeof(pVehicle->fDy));
	fileWrite(pFile, &pVehicle->ubVehicleState, sizeof(pVehicle->ubVehicleState));
	fileWrite(pFile, &pVehicle->isFacingRight, sizeof(pVehicle->isFacingRight));
	// fileWrite(pFile, &pVehicle->ubTrackFrame, sizeof(pVehicle->ubTrackFrame));
	// fileWrite(pFile, &pVehicle->fTrackAnimCnt, sizeof(pVehicle->fTrackAnimCnt));
	fileWrite(pFile, &pVehicle->ubBodyShakeCnt, sizeof(pVehicle->ubBodyShakeCnt));
	fileWrite(pFile, &pVehicle->isJetting, sizeof(pVehicle->isJetting));
	fileWrite(pFile, &pVehicle->ubJetShowFrame, sizeof(pVehicle->ubJetShowFrame));
	fileWrite(pFile, &pVehicle->ubJetAnimFrame, sizeof(pVehicle->ubJetAnimFrame));
	fileWrite(pFile, &pVehicle->ubJetAnimCnt, sizeof(pVehicle->ubJetAnimCnt));
	fileWrite(pFile, &pVehicle->ubToolAnimCnt, sizeof(pVehicle->ubToolAnimCnt));
	// fileWrite(pFile, &pVehicle->eDrillMode, sizeof(pVehicle->eDrillMode));
	fileWrite(pFile, &pVehicle->eLastVisitedTeleportableBase, sizeof(pVehicle->eLastVisitedTeleportableBase));
	fileWrite(pFile, &pVehicle->ubDrillDir, sizeof(pVehicle->ubDrillDir));
	fileWrite(pFile, &pVehicle->ubDrillVAnimCnt, sizeof(pVehicle->ubDrillVAnimCnt));
	fileWrite(pFile, &pVehicle->ubDrillState, sizeof(pVehicle->ubDrillState));
	fileWrite(pFile, &pVehicle->fDrillDestX, sizeof(pVehicle->fDrillDestX));
	fileWrite(pFile, &pVehicle->fDrillDestY, sizeof(pVehicle->fDrillDestY));
	fileWrite(pFile, &pVehicle->fDrillDelta, sizeof(pVehicle->fDrillDelta));
	fileWrite(pFile, &pVehicle->sDrillTile, sizeof(pVehicle->sDrillTile));
	// fileWrite(pFile, &pVehicle->ubTrackFrame, sizeof(pVehicle->ubTrackFrame));
	fileWrite(pFile, &pVehicle->ubSmokeAnimFrame, sizeof(pVehicle->ubSmokeAnimFrame));
	fileWrite(pFile, &pVehicle->ubSmokeAnimCnt, sizeof(pVehicle->ubSmokeAnimCnt));
	fileWrite(pFile, &pVehicle->eTeleportKind, sizeof(pVehicle->eTeleportKind));
	fileWrite(pFile, &pVehicle->uwTeleportX, sizeof(pVehicle->uwTeleportX));
	fileWrite(pFile, &pVehicle->uwTeleportY, sizeof(pVehicle->uwTeleportY));
	// fileWrite(pFile, &pVehicle->eTeleportInFlipbook, sizeof(pVehicle->eTeleportInFlipbook));
	fileWrite(pFile, &pVehicle->uwCargoCurr, sizeof(pVehicle->uwCargoCurr));
	fileWrite(pFile, &pVehicle->uwCargoScore, sizeof(pVehicle->uwCargoScore));
	fileWrite(pFile, pVehicle->pStock, sizeof(pVehicle->pStock));
	fileWrite(pFile, &pVehicle->lCash, sizeof(pVehicle->lCash));
	fileWrite(pFile, &pVehicle->uwDrillCurr, sizeof(pVehicle->uwDrillCurr));
	fileWrite(pFile, &pVehicle->wHullCurr, sizeof(pVehicle->wHullCurr));
	fileWrite(pFile, &pVehicle->ubPlayerIdx, sizeof(pVehicle->ubPlayerIdx));
	fileWrite(pFile, &pVehicle->ubHullDamageFrame, sizeof(pVehicle->ubHullDamageFrame));
	fileWrite(pFile, &pVehicle->sDynamite, sizeof(pVehicle->sDynamite));
	fileWrite(pFile, &pVehicle->ubDamageBlinkCooldown, sizeof(pVehicle->ubDamageBlinkCooldown));
	saveWriteTag(pFile, SAVE_TAG_VEHICLE_END);
}

UBYTE vehicleLoad(tVehicle *pVehicle, tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_VEHICLE)) {
		return 0;
	}

	fileRead(pFile, &pVehicle->sSteer, sizeof(pVehicle->sSteer));
	// textBobLoad(&pVehicle->sTextBob, pFile);
	// bobLoad(&pVehicle->sBobBody, pFile);
	// bobLoad(&pVehicle->sBobTrack, pFile);
	// bobLoad(&pVehicle->sBobJet, pFile);
	// bobLoad(&pVehicle->sBobTool, pFile);
	// bobLoad(&pVehicle->sBobWreck, pFile);
	// bobLoad(&pVehicle->sBobSmoke, pFile);
	fileRead(pFile, &pVehicle->fX, sizeof(pVehicle->fX));
	fileRead(pFile, &pVehicle->fY, sizeof(pVehicle->fY));
	fileRead(pFile, &pVehicle->fDx, sizeof(pVehicle->fDx));
	fileRead(pFile, &pVehicle->fDy, sizeof(pVehicle->fDy));
	fileRead(pFile, &pVehicle->ubVehicleState, sizeof(pVehicle->ubVehicleState));
	fileRead(pFile, &pVehicle->isFacingRight, sizeof(pVehicle->isFacingRight));
	// fileRead(pFile, &pVehicle->ubTrackFrame, sizeof(pVehicle->ubTrackFrame));
	// fileRead(pFile, &pVehicle->fTrackAnimCnt, sizeof(pVehicle->fTrackAnimCnt));
	fileRead(pFile, &pVehicle->ubBodyShakeCnt, sizeof(pVehicle->ubBodyShakeCnt));
	fileRead(pFile, &pVehicle->isJetting, sizeof(pVehicle->isJetting));
	fileRead(pFile, &pVehicle->ubJetShowFrame, sizeof(pVehicle->ubJetShowFrame));
	fileRead(pFile, &pVehicle->ubJetAnimFrame, sizeof(pVehicle->ubJetAnimFrame));
	fileRead(pFile, &pVehicle->ubJetAnimCnt, sizeof(pVehicle->ubJetAnimCnt));
	fileRead(pFile, &pVehicle->ubToolAnimCnt, sizeof(pVehicle->ubToolAnimCnt));
	// fileRead(pFile, &pVehicle->eDrillMode, sizeof(pVehicle->eDrillMode));
	fileRead(pFile, &pVehicle->eLastVisitedTeleportableBase, sizeof(pVehicle->eLastVisitedTeleportableBase));
	fileRead(pFile, &pVehicle->ubDrillDir, sizeof(pVehicle->ubDrillDir));
	fileRead(pFile, &pVehicle->ubDrillVAnimCnt, sizeof(pVehicle->ubDrillVAnimCnt));
	fileRead(pFile, &pVehicle->ubDrillState, sizeof(pVehicle->ubDrillState));
	fileRead(pFile, &pVehicle->fDrillDestX, sizeof(pVehicle->fDrillDestX));
	fileRead(pFile, &pVehicle->fDrillDestY, sizeof(pVehicle->fDrillDestY));
	fileRead(pFile, &pVehicle->fDrillDelta, sizeof(pVehicle->fDrillDelta));
	fileRead(pFile, &pVehicle->sDrillTile, sizeof(pVehicle->sDrillTile));
	// fileRead(pFile, &pVehicle->ubTrackFrame, sizeof(pVehicle->ubTrackFrame));
	fileRead(pFile, &pVehicle->ubSmokeAnimFrame, sizeof(pVehicle->ubSmokeAnimFrame));
	fileRead(pFile, &pVehicle->ubSmokeAnimCnt, sizeof(pVehicle->ubSmokeAnimCnt));
	fileRead(pFile, &pVehicle->eTeleportKind, sizeof(pVehicle->eTeleportKind));
	fileRead(pFile, &pVehicle->uwTeleportX, sizeof(pVehicle->uwTeleportX));
	fileRead(pFile, &pVehicle->uwTeleportY, sizeof(pVehicle->uwTeleportY));
	// fileRead(pFile, &pVehicle->eTeleportInFlipbook, sizeof(pVehicle->eTeleportInFlipbook));
	fileRead(pFile, &pVehicle->uwCargoCurr, sizeof(pVehicle->uwCargoCurr));
	fileRead(pFile, &pVehicle->uwCargoScore, sizeof(pVehicle->uwCargoScore));
	fileRead(pFile, pVehicle->pStock, sizeof(pVehicle->pStock));
	fileRead(pFile, &pVehicle->lCash, sizeof(pVehicle->lCash));
	fileRead(pFile, &pVehicle->uwDrillCurr, sizeof(pVehicle->uwDrillCurr));
	fileRead(pFile, &pVehicle->wHullCurr, sizeof(pVehicle->wHullCurr));
	fileRead(pFile, &pVehicle->ubPlayerIdx, sizeof(pVehicle->ubPlayerIdx));
	fileRead(pFile, &pVehicle->ubHullDamageFrame, sizeof(pVehicle->ubHullDamageFrame));
	fileRead(pFile, &pVehicle->sDynamite, sizeof(pVehicle->sDynamite));
	fileRead(pFile, &pVehicle->ubDamageBlinkCooldown, sizeof(pVehicle->ubDamageBlinkCooldown));
	return saveReadTag(pFile, SAVE_TAG_VEHICLE_END);
}

UBYTE vehicleIsNearShop(const tVehicle *pVehicle) {
	if(g_eGameMode == GAME_MODE_DEADLINE && baseGetCurrentId() != BASE_ID_GROUND) {
		return 0;
	}

	const tBase *pBase = baseGetCurrent();

	UWORD uwCenterX = pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH/2;
	UWORD uwY = pVehicle->sBobBody.sPos.uwY;
	UBYTE isNearShop = (
		pBase->sRectRestock.uwX1 <= uwCenterX && uwCenterX <= pBase->sRectRestock.uwX2 &&
		pBase->sRectRestock.uwY1 <= uwY && uwY <= pBase->sRectRestock.uwY2
	);

	return isNearShop;
}

UBYTE vehicleIsNearBaseTeleporter(const tVehicle *pVehicle) {
	if(!inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, baseGetCurrentId())) {
		return 0;
	}
	const tBase *pBase = baseGetCurrent();

	UWORD uwCenterX = pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH/2;
	UWORD uwY = pVehicle->sBobBody.sPos.uwY;
	UBYTE isNearTeleporter = (
		pBase->sPosTeleport.uwX <= uwCenterX && uwCenterX <= pBase->sPosTeleport.uwX + BASE_TELEPORTER_WIDTH &&
		pBase->sPosTeleport.uwY <= uwY && uwY <= pBase->sPosTeleport.uwY + BASE_TELEPORTER_HEIGHT
	);

	return isNearTeleporter;
}

UBYTE vehicleIsInBase(const tVehicle *pVehicle) {
	const tBase *pBase = baseGetCurrent();

	UWORD uwY = pVehicle->sBobBody.sPos.uwY;
	UWORD uwBaseStartY = pBase->uwTileDepth * TILE_SIZE;
	UWORD uwBaseEndY = uwBaseStartY + BASE_PATTERN_HEIGHT * TILE_SIZE;
	UBYTE isInBase = (
		uwBaseStartY <= uwY && uwY <= uwBaseEndY
	);

	return isInBase;
}

void vehicleMove(tVehicle *pVehicle, BYTE bDirX, BYTE bDirY) {
	// Always register steer requests so that vehicle can continuously drill down
	pVehicle->sSteer.bX = bDirX;
	pVehicle->sSteer.bY = bDirY;

	// No vehicle rotating when other state than moving
	if(pVehicle->ubVehicleState == VEHICLE_STATE_MOVING) {
		if(bDirX > 0) {
			pVehicle->isFacingRight = 1;
		}
		else if(bDirX < 0) {
			pVehicle->isFacingRight = 0;
		}
	}

	vehicleUpdateBodyBob(pVehicle);
}

static inline void vehicleSetTool(
	tVehicle *pVehicle, tToolState eToolState, UBYTE ubFrame
) {
	pVehicle->sBobTool.sPos.ulYX = pVehicle->sBobBody.sPos.ulYX;
	pVehicle->sBobTool.sPos.uwY -= VEHICLE_TOOL_OFFSET_Y;
	UBYTE ubFrameOffsetY;
	if(eToolState == TOOL_STATE_IDLE) {
		ubFrameOffsetY = 0;
		if(pVehicle->fToolOffset <= 0) {
			pVehicle->fToolOffset = 0;
		}
		else {
			pVehicle->fToolOffset = fix16_sub(pVehicle->fToolOffset, fix16_one * 2);
		}
	}
	else { // if(eToolState == TOOL_STATE_DRILL)
		ubFrameOffsetY = ubFrame ? VEHICLE_TOOL_HEIGHT : 0;
		if(pVehicle->fToolOffset >= fix16_one * VEHICLE_TOOL_PATH_LENGTH) {
			pVehicle->fToolOffset = fix16_one * VEHICLE_TOOL_PATH_LENGTH;
		}
		else {
			pVehicle->fToolOffset += pVehicle->fDrillDelta;
		}
	}

	if(pVehicle->isFacingRight) {
		pVehicle->sBobTool.sPos.uwX += 17 + fix16_to_int(pVehicle->fToolOffset);
	}
	else {
		pVehicle->sBobTool.sPos.uwX += -1 - fix16_to_int(pVehicle->fToolOffset);
		ubFrameOffsetY += (
			VEHICLE_TOOL_ANIM_FRAMES * VEHICLE_DESTRUCTION_FRAMES *
			VEHICLE_TOOL_HEIGHT
		);
	}

	// Apply destruction
	ubFrameOffsetY += (
		VEHICLE_TOOL_HEIGHT * VEHICLE_TOOL_ANIM_FRAMES *
		pVehicle->ubHullDamageFrame
	);

	// Vertical drill anim
	UBYTE *pFrame;
	if(pVehicle->ubDamageBlinkCooldown) {
		pFrame = s_pWhiteTool->Planes[0];
	}
	else {
		pFrame = bobCalcFrameAddress(s_pToolFrames[pVehicle->ubPlayerIdx], ubFrameOffsetY);
	}
	bobSetFrame(
		&pVehicle->sBobTool,
		pFrame,
		bobCalcFrameAddress(s_pToolMask, ubFrameOffsetY)
	);
}

static inline UBYTE vehicleStartDrilling(
	tVehicle *pVehicle, UWORD uwTileX, UWORD uwTileY, tDrillDir eDrillDir, WORD wAddX
) {
	if(pVehicle->isChallengeEnded) {
		return 0;
	}

	static UBYTE ubCooldown = 0;

	// Check if other player drills the same tile
	const tVehicle * const pOther = &g_pVehicles[!pVehicle->ubPlayerIdx];
	if(
		pOther->ubDrillDir &&
		pOther->sDrillTile.uwY == uwTileY && pOther->sDrillTile.uwX == uwTileX
	) {
		return 0;
	}

	// Calculate layer difficulty
	BYTE bDifficulty;
	if(tileIsHardToDrill(uwTileX, uwTileY)) {
		bDifficulty = 10;
	}
	else {
		bDifficulty = groundLayerGetDifficultyAtDepth(uwTileY << TILE_SHIFT);
	}
	BYTE bDrillLevel = inventoryGetPartDef(INVENTORY_PART_DRILL)->ubLevel;
	BYTE bDrillDuration = MAX(1, bDifficulty - bDrillLevel);
	UBYTE ubDrillCost = g_ubDrillingCost * bDrillDuration;

	// Check vehicle's drill depletion
	if(g_eGameMode != GAME_MODE_CHALLENGE) {
		if(pVehicle->uwDrillCurr < ubDrillCost) {
			if(!ubCooldown) {
				textBobSet(
					&pVehicle->sTextBob, g_pMsgs[MSG_MISC_DRILL_DEPLETED], COLOR_REDEST,
					pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH/2,
					pVehicle->sBobBody.sPos.uwY,
					pVehicle->sBobBody.sPos.uwY - 32, 1
				);
				audioMixerPlaySfx(g_pSfxPenalty, SFX_CHANNEL_EFFECT, SFX_PRIORITY_PENALTY, 0);
				ubCooldown = 25;
			}
			else {
				--ubCooldown;
			}
			return 0;
		}
		pVehicle->uwDrillCurr -= ubDrillCost;
		gameElapseTime(ubDrillCost);
	}

	pVehicle->ubDrillState = (
		eDrillDir == DRILL_DIR_V ? DRILL_STATE_VERT_ANIM_IN : DRILL_STATE_DRILLING
	);
	vehicleSetState(pVehicle, VEHICLE_STATE_DRILLING);
	pVehicle->ubDrillDir = eDrillDir;

	pVehicle->sDrillTile.uwX = uwTileX;
	pVehicle->sDrillTile.uwY = uwTileY;
	pVehicle->fDrillDestX = fix16_from_int((uwTileX << TILE_SHIFT) + wAddX);
	pVehicle->fDrillDestY = fix16_from_int(((uwTileY + 1) << TILE_SHIFT) - VEHICLE_HEIGHT - 4);
	pVehicle->fDrillDelta = (fix16_one * 3)/(bDrillDuration * 2);

	pVehicle->fDx = 0;
	pVehicle->fDy = 0;
	audioMixerPlaySfx(g_pSfxDrill, SFX_CHANNEL_LOOP_P1 + pVehicle->ubPlayerIdx, 1, 1);

	return 1;
}

static WORD vehicleRestock(tVehicle *pVehicle) {
	tBaseId eBaseId = baseGetCurrentId();
	if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, baseGetCurrentId())) {
		pVehicle->eLastVisitedTeleportableBase = eBaseId;
	}

	UBYTE isRestockedMinerals = 0;
	if(
		g_eGameMode == GAME_MODE_CHALLENGE || eBaseId == BASE_ID_GROUND ||
		inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, eBaseId)
	) {
		if(pVehicle->uwCargoCurr) {
			isRestockedMinerals = 1;
			pVehicle->uwCargoCurr = 0;
		}
		UWORD uwCargoMax = inventoryGetPartDef(INVENTORY_PART_CARGO)->uwMax;
		hudSetCargo(pVehicle->ubPlayerIdx, 0, uwCargoMax);
		for(UBYTE i = 0; i < MINERAL_TYPE_COUNT; ++i) {
			warehouseSetStock(i, warehouseGetStock(i) + pVehicle->pStock[i]);
			pVehicle->pStock[i] = 0;
		}
	}

	WORD wCashDelta = (g_eGameMode == GAME_MODE_STORY) ? 0 : pVehicle->uwCargoScore;
	pVehicle->uwCargoScore = 0;
	if(g_eGameMode == GAME_MODE_CHALLENGE || inventoryGetBasePartLevel(INVENTORY_PART_BASE_WORKSHOP, eBaseId)) {
		tProtestState eProtestState = protestsGetState();
		// Buy as much fuel as needed
		// Start refueling if half a liter is spent
		UWORD uwDrillMax = inventoryGetPartDef(INVENTORY_PART_DRILL)->uwMax;
		if(eProtestState >= PROTEST_STATE_PROTEST) {
			uwDrillMax /= 2;
		}
		WORD wDeltaPart = uwDrillMax - pVehicle->uwDrillCurr;
		UWORD uwRefuelLiters = 0;
		if(wDeltaPart > 0) {
			uwRefuelLiters = ((UWORD)wDeltaPart + g_ubFuelInLiter / 2) / g_ubFuelInLiter;
			// It's possible to buy more fuel than needed (last liter) - fill up to max
			pVehicle->uwDrillCurr = MIN(
				pVehicle->uwDrillCurr + uwRefuelLiters * g_ubFuelInLiter, uwDrillMax
			);
		}


		UWORD uwRehullCost = 0;
		if(eProtestState < PROTEST_STATE_STRIKE) {
			// Buy as much hull as needed
			UWORD uwHullMax = inventoryGetPartDef(INVENTORY_PART_HULL)->uwMax;
			if(eProtestState >= PROTEST_STATE_PROTEST) {
				uwHullMax /= 2;
			}
			wDeltaPart = uwHullMax - pVehicle->wHullCurr;
			if(wDeltaPart > 0) {
				uwRehullCost = g_ubHullPrice * (UWORD)wDeltaPart;
				vehicleHullRepair(pVehicle, uwHullMax);
			}
		}

		// Pay for your fuel & hull!
		UWORD uwRestockCost = uwRefuelLiters * g_ubLiterPrice + uwRehullCost;
		if(g_eGameMode == GAME_MODE_DEADLINE) {
			uwRestockCost /= 2;
		}
		wCashDelta -= uwRestockCost;
		LONG *pCash = (g_eGameMode == GAME_MODE_CHALLENGE) ? &pVehicle->lCash : &g_pVehicles[0].lCash;
		*pCash += wCashDelta;
	}

	if(!wCashDelta && isRestockedMinerals) {
		wCashDelta = RESTOCK_RESULT_ONLY_MINERALS;
	}
	return wCashDelta;
}

static void vehicleEndChallenge(tVehicle *pVehicle) {
	vehicleRestock(pVehicle);
	pVehicle->isChallengeEnded = 1;
}

typedef enum tPickupSfxKind {
	PICKUP_SFX_KIND_NONE,
	PICKUP_SFX_KIND_BONUS,
	PICKUP_SFX_KIND_PENALTY,
} tPickupSfxKind;

void vehicleExcavateTile(tVehicle *pVehicle, UWORD uwTileX, UWORD uwTileY) {
	tPickupSfxKind ePickupKind = PICKUP_SFX_KIND_NONE;
	// Load mineral to vehicle
	UBYTE ubTile = g_pMainBuffer->pTileData[uwTileX][uwTileY];
	if(g_pTileDefs[ubTile].ubSlots) {
		UWORD uwCargoMax = inventoryGetPartDef(INVENTORY_PART_CARGO)->uwMax;
		UBYTE ubMineralType = g_pTileDefs[ubTile].ubMineral;
		const tMineralDef *pMineral = &g_pMinerals[ubMineralType];
		UBYTE ubSlots = g_pTileDefs[ubTile].ubSlots;
		ubSlots = MIN(ubSlots, uwCargoMax - pVehicle->uwCargoCurr);
		pVehicle->uwCargoScore += pMineral->ubReward * ubSlots;
		pVehicle->uwCargoCurr += ubSlots;
		pVehicle->pStock[ubMineralType] += ubSlots;

		hudSetCargo(pVehicle->ubPlayerIdx, pVehicle->uwCargoCurr, uwCargoMax);
		if(pVehicle->uwCargoCurr == uwCargoMax) {
			textBobSetText(&pVehicle->sTextBob, COLOR_REDEST, g_pMsgs[MSG_MISC_CARGO_FULL]);
			ePickupKind = PICKUP_SFX_KIND_PENALTY;
		}
		else {
			textBobSetTextVa(
				&pVehicle->sTextBob, pMineral->ubTitleColor, "%s x%hhu",
				g_pMsgs[MSG_MINERAL_SILVER + g_pTileDefs[ubTile].ubMineral],
				g_pTileDefs[ubTile].ubSlots
			);
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
	}
	else if(g_eGameMode == GAME_MODE_CHALLENGE) {
		if(TILE_CHECKPOINT_1 <= ubTile && ubTile <= TILE_CHECKPOINT_10) {
			if(uwTileY == TILE_ROW_CHALLENGE_FINISH) {
				vehicleEndChallenge(pVehicle);
			}
			else {
				textBobSetTextVa(
					&pVehicle->sTextBob, COLOR_GREEN, "%s %+hu\x1F",
					g_pMsgs[MSG_CHALLENGE_CHECKPOINT], pVehicle->uwCargoScore
				);
				vehicleRestock(pVehicle);
			}
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
	}
	else if(g_eGameMode == GAME_MODE_DEADLINE) {
		if(ubTile == TILE_CRATE_1) {
			planAddDays(10, 0);
			tPartKind ePart = randUwMinMax(&g_sRand, INVENTORY_PART_DRILL, INVENTORY_PART_TNT);
			const tPartDef *pPartDef = inventoryGetPartDef(ePart);
			if(pPartDef->ubLevel < inventoryGetPartMaxLevel(ePart)) {
				inventorySetPartLevel(ePart, pPartDef->ubLevel + 1);
				textBobSetTextVa(&pVehicle->sTextBob, COLOR_GREEN, "Bonus: %s", g_pMsgs[MSG_PART_NAME_DRILL + ePart]);
			}
			else {
				textBobSetText(&pVehicle->sTextBob, COLOR_GREEN, "T +10");
			}
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
		if(TILE_CHECKPOINT_1 <= ubTile && ubTile <= TILE_CHECKPOINT_10) {
			vehicleRestock(&g_pVehicles[0]);
			if(g_is2pPlaying) {
				vehicleRestock(&g_pVehicles[1]);
			}
			g_pVehicles[0].lCash += 5000;
			g_pVehicles[0].isChallengeEnded = 1;
		}
	}
	else {
		if(TILE_PRISONER_1 <= ubTile && ubTile <= TILE_PRISONER_8) {
			textBobSetText(
				&pVehicle->sTextBob, COLOR_GREEN, g_pMsgs[MSG_PAGE_LIST_PRISONER]
			);

			ePickupKind = PICKUP_SFX_KIND_BONUS;
			questGateUnlockPrisoner();
		}
		else if(ubTile == TILE_BONE_HEAD || ubTile == TILE_BONE_1) {
			UBYTE ubBoneIndex = dinoAddBone();
			textBobSetTextVa(
				&pVehicle->sTextBob, COLOR_GREEN, g_pMsgs[MSG_MISC_FOUND_BONE],
				ubBoneIndex
			);
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
		else if(ubTile == TILE_GATE_1 || ubTile == TILE_GATE_2) {
			UBYTE ubFragmentIndex = questGateAddFragment();
			textBobSetTextVa(
				&pVehicle->sTextBob, COLOR_GREEN, g_pMsgs[MSG_MISC_FOUND_GATE],
				ubFragmentIndex
			);
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
		else if(ubTile == TILE_CRATE_1) {
			questCrateAdd();
			textBobSetText(
				&pVehicle->sTextBob, COLOR_GREEN, g_pMsgs[MSG_MISC_FOUND_CRATE]
			);
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
		else if(ubTile == TILE_CAPSULE) {
			questCrateSetCapsuleState(CAPSULE_STATE_FOUND);
			textBobSetText(
				&pVehicle->sTextBob, COLOR_GREEN, g_pMsgs[MSG_MISC_FOUND_CAPSULE]
			);
			ePickupKind = PICKUP_SFX_KIND_BONUS;
		}
	}

	tileExcavate(uwTileX, uwTileY);
	gameUpdateMaxDepth(uwTileY);

	switch(ePickupKind) {
		case PICKUP_SFX_KIND_NONE:
			return;
		case PICKUP_SFX_KIND_BONUS:
			audioMixerPlaySfx(g_pSfxOre, SFX_CHANNEL_EFFECT, SFX_PRIORITY_PICKUP, 0);
			break;
		case PICKUP_SFX_KIND_PENALTY:
			audioMixerPlaySfx(g_pSfxPenalty, SFX_CHANNEL_EFFECT, SFX_PRIORITY_PENALTY, 0);
			break;
	}

	textBobSetPos(
		&pVehicle->sTextBob,
		pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH/2,
		pVehicle->sBobBody.sPos.uwY,
		pVehicle->sBobBody.sPos.uwY - 32, 1
	);
}

UBYTE vehicleTrySpendCash(UBYTE ubPlayerIndex, LONG lCost) {
	tVehicle *pVehicle = &g_pVehicles[ubPlayerIndex];
	if(pVehicle->lCash >= lCost) {
		pVehicle->lCash -= lCost;
		hudSetCash(ubPlayerIndex, pVehicle->lCash);
		protestsProcess();
		return 1;
	}
	logWrite("Not enough cash\n");
	return 0;
}

static void vehicleDrawMarker(tVehicle *pVehicle) {
	pVehicle->sBobMarker.sPos.uwX = pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH / 2;
	pVehicle->sBobMarker.sPos.uwY = g_pMainBuffer->pCamera->uPos.uwY;
	if(pVehicle->sBobBody.sPos.uwY < g_pMainBuffer->pCamera->uPos.uwY) {
		pVehicle->sBobMarker.pFrameData = s_pMarkerFrameAddresses[1][pVehicle->ubPlayerIdx];
		pVehicle->sBobMarker.pMaskData = s_pMarkerMaskAddresses[1];
	}
	else {
		pVehicle->sBobMarker.sPos.uwY += g_pMainBuffer->sCommon.pVPort->uwHeight - 4;
		pVehicle->sBobMarker.pFrameData = s_pMarkerFrameAddresses[0][pVehicle->ubPlayerIdx];
		pVehicle->sBobMarker.pMaskData = s_pMarkerMaskAddresses[0];
	}
	gameTryPushBob(&pVehicle->sBobMarker);
}

static void vehicleProcessMovement(tVehicle *pVehicle) {
	UBYTE isOnGround = 0;
	const fix16_t fMaxDx = 2 * fix16_one;
	const fix16_t fAccX = fix16_one / 16;
	const fix16_t fFrictX = fix16_one / 12;

	// Challenge camera teleport
	if(
		g_eGameMode == GAME_MODE_CHALLENGE &&
		fix16_to_int(pVehicle->fY) < g_pMainBuffer->pCamera->uPos.uwY
	) {
		UWORD uwTileY = (
			g_pMainBuffer->pCamera->uPos.uwY +
			g_pMainBuffer->pCamera->sCommon.pVPort->uwHeight / 2
		) / 32;
		UWORD uwTileX = fix16_to_int(pVehicle->fX)/32;
		if(tileIsSolid(uwTileX, uwTileY)) {
			tileExcavate(uwTileX, uwTileY);
		}
		pVehicle->fY = fix16_from_int(uwTileY * TILE_SIZE);
		pVehicle->fDy = fix16_from_int(-1); // HACK HACK HACK
		pVehicle->sBobBody.sPos.uwY = fix16_to_int(pVehicle->fY);
		audioMixerPlaySfx(g_pSfxPenalty, SFX_CHANNEL_EFFECT, SFX_PRIORITY_PENALTY, 0);
		UWORD uwTeleportPenalty = 50;
		textBobSetTextVa(
			&pVehicle->sTextBob, COLOR_REDEST, "%s -%hu\x1F",
			g_pMsgs[MSG_CHALLENGE_TELEPORT], uwTeleportPenalty
		);
		textBobSetPos(
			&pVehicle->sTextBob,
			pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH/2,
			pVehicle->sBobBody.sPos.uwY,
			pVehicle->sBobBody.sPos.uwY - 48, 1
		);
		pVehicle->lCash -= uwTeleportPenalty;
	}

	if(g_eGameMode == GAME_MODE_CHALLENGE && !pVehicle->isChallengeEnded) {
		UWORD uwTileY = fix16_to_int(pVehicle->fY) / 32;
		if(uwTileY >= TILE_ROW_CHALLENGE_FINISH) {
			vehicleEndChallenge(pVehicle);
		}
	}

	if(pVehicle->sSteer.bX) {
		if(pVehicle->sSteer.bX > 0) {
			pVehicle->fDx = MIN(pVehicle->fDx + fAccX, fMaxDx);
		}
		else {
			pVehicle->fDx = MAX(pVehicle->fDx - fAccX, -fMaxDx);
		}
	}
	else {
		if(pVehicle->fDx > 0) {
			pVehicle->fDx = MAX(0, pVehicle->fDx - fFrictX);
		}
		else {
			pVehicle->fDx = MIN(0, pVehicle->fDx + fFrictX);
		}
	}

	// Limit X movement
	const fix16_t fMaxPosX = fix16_one * (11 * TILE_SIZE - VEHICLE_WIDTH);
	pVehicle->fX = CLAMP(pVehicle->fX + pVehicle->fDx, fix16_from_int(32), fMaxPosX);
	pVehicle->sBobBody.sPos.uwX = fix16_to_int(pVehicle->fX);
	UBYTE ubAdd = (pVehicle->sBobBody.sPos.uwY > (1 + TILE_ROW_BASE_DIRT) * TILE_SIZE) ? 4 : 2;

	UWORD uwCenterX = pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH / 2;
	UWORD uwTileBottom = (pVehicle->sBobBody.sPos.uwY + VEHICLE_HEIGHT + ubAdd) >> TILE_SHIFT;
	UWORD uwTileMid = (pVehicle->sBobBody.sPos.uwY + VEHICLE_HEIGHT / 2) >> TILE_SHIFT;
	UWORD uwTileCenter = uwCenterX >> TILE_SHIFT;
	UWORD uwTileLeft = (uwCenterX - VEHICLE_HALF_WIDTH) >> TILE_SHIFT;
	UWORD uwTileRight = (uwCenterX + VEHICLE_HALF_WIDTH) >> TILE_SHIFT;

	if(tileIsSolid(uwTileLeft, uwTileMid)) {
		pVehicle->fX = fix16_from_int(((uwTileLeft+1) << TILE_SHIFT) - VEHICLE_WIDTH / 2 + VEHICLE_HALF_WIDTH);
		pVehicle->fDx = 0;
	}
	else if(tileIsSolid(uwTileRight, uwTileMid)) {
		pVehicle->fX = fix16_from_int((uwTileRight << TILE_SHIFT) - VEHICLE_WIDTH / 2 - VEHICLE_HALF_WIDTH);
		pVehicle->fDx = 0;
	}

	const fix16_t fMaxFlightDy = 3 * fix16_one;
	const fix16_t fAccFlight = fix16_one / 12;
	if(pVehicle->sSteer.bY < 0) {
		if(pVehicle->ubJetShowFrame == VEHICLE_JET_SHOW_FRAME_COUNT) {
			pVehicle->fDy = MAX(-fMaxFlightDy, pVehicle->fDy - fAccFlight);
			if(!pVehicle->isJetting) {
				audioMixerPlaySfx(g_pSfxFlyLoop, SFX_CHANNEL_LOOP_P1 + pVehicle->ubPlayerIdx, 1, 1);
				pVehicle->isJetting = 1;
			}
		}
		else {
			++pVehicle->ubJetShowFrame;
		}
	}
	else {
		if(pVehicle->isJetting) {
			vehicleStopLoopAudio(pVehicle->ubPlayerIdx);
			pVehicle->isJetting = 0;
		}
		if(pVehicle->ubJetShowFrame) {
			--pVehicle->ubJetShowFrame;
		}
		pVehicle->fDy = MIN(s_fMaxGravDy, pVehicle->fDy + s_fAccGrav);
	}

	if(pVehicle->fDy < 0) {
		UWORD uwTileTop = (fix16_to_int(pVehicle->fY) - 1) >> TILE_SHIFT;
		// Flying
		pVehicle->fY += pVehicle->fDy;
		if(pVehicle->fY < F16(VEHICLE_TOOL_OFFSET_Y)) {
			pVehicle->fY = F16(VEHICLE_TOOL_OFFSET_Y);
			pVehicle->fDy = 0;
		}
		else if(tileIsSolid(uwTileCenter, uwTileTop)) {
			pVehicle->fY = fix16_from_int((uwTileTop+1) << TILE_SHIFT);
			pVehicle->fDy = 0;
		}
	}
	else {
		if(!tileIsSolid(uwTileCenter, uwTileBottom)) {
			// Gravity
			pVehicle->fY += pVehicle->fDy;
			gameCancelModeForPlayer(pVehicle->ubPlayerIdx);
		}
		else {
			// Collision with ground
			isOnGround = 1;
			pVehicle->fY = fix16_from_int((uwTileBottom << TILE_SHIFT) - VEHICLE_HEIGHT - ubAdd);
			if(pVehicle->fDy > 2 * fix16_one) {
				// vehicleHullDamage(pVehicle, fix16_to_int(pVehicle->fDy - 4 * fix16_one));
				vehicleHullDamage(pVehicle, fix16_to_int(fix16_mul(
					pVehicle->fDy - 2 * fix16_one, fix16_one * 4
				)));
			}
			pVehicle->fDy = 0;
		}
	}
	pVehicle->sBobBody.sPos.uwY = fix16_to_int(pVehicle->fY);

	// Vehicle has its destination position calculated - check if it's visible
	// TODO: Could check only row for a bit faster calculations
	UWORD uwTileTop = (pVehicle->sBobBody.sPos.uwY + ubAdd) / 32;
	UBYTE isVehicleVisible = (
		tileBufferIsTileOnBuffer(g_pMainBuffer, uwTileLeft, uwTileTop) &&
		tileBufferIsTileOnBuffer(g_pMainBuffer, uwTileLeft, uwTileBottom)
	);

	// Update track bob
	pVehicle->sBobTrack.sPos.ulYX = pVehicle->sBobBody.sPos.ulYX;
	pVehicle->sBobTrack.sPos.uwY += VEHICLE_BODY_HEIGHT - 1;
	if(pVehicle->ubJetShowFrame == 0) {
		// Jet hidden
		if(pVehicle->fDx) {
			// Animate wheel rotation
			pVehicle->fTrackAnimCnt += fix16_abs(pVehicle->fDx);
			if(fix16_to_int(pVehicle->fTrackAnimCnt) >= 5) {
				if(pVehicle->fDx > 0) {
					if(pVehicle->ubTrackFrame >= 3) {
						pVehicle->ubTrackFrame = 0;
					}
					else {
						++pVehicle->ubTrackFrame;
					}
				}
				else {
					if(pVehicle->ubTrackFrame <= 0) {
						pVehicle->ubTrackFrame = 3;
					}
					else {
						--pVehicle->ubTrackFrame;
					}
				}
				UWORD uwOffsY = pVehicle->ubTrackFrame * VEHICLE_TRACK_HEIGHT;
				bobSetFrame(
					&pVehicle->sBobTrack,
					bobCalcFrameAddress(s_pTrackFrames, uwOffsY),
					bobCalcFrameAddress(s_pTrackMask, uwOffsY)
				);
				pVehicle->fTrackAnimCnt = 0;
			}
		}

		++pVehicle->ubBodyShakeCnt;
		UBYTE ubShakeSpeed = (pVehicle->fDx ? 5 : 10);
		if(pVehicle->ubBodyShakeCnt >= 2 * ubShakeSpeed) {
			pVehicle->ubBodyShakeCnt = 0;
		}
		if(pVehicle->ubBodyShakeCnt >= ubShakeSpeed) {
			pVehicle->sBobBody.sPos.uwY += 1;
		}
	}
	else {
		pVehicle->sBobBody.sPos.uwY += s_pJetAnimOffsets[pVehicle->ubJetShowFrame];
		if(pVehicle->ubJetShowFrame == VEHICLE_JET_SHOW_FRAME_COUNT / 2) {
			UWORD uwOffsetY = (pVehicle->sSteer.bY ? TRACK_OFFSET_JET : 0);
			bobSetFrame(
				&pVehicle->sBobTrack,
				bobCalcFrameAddress(s_pTrackFrames, uwOffsetY),
				bobCalcFrameAddress(s_pTrackMask, uwOffsetY)
			);
		}
		else if(pVehicle->ubJetShowFrame == VEHICLE_JET_SHOW_FRAME_COUNT) {
			// Update jet pos
			pVehicle->ubJetAnimCnt = (pVehicle->ubJetAnimCnt + 1) & 63;
			UWORD uwOffsetY = VEHICLE_FLAME_HEIGHT * (pVehicle->ubJetAnimCnt / 4);
			bobSetFrame(
				&pVehicle->sBobJet,
				bobCalcFrameAddress(s_pJetFrames, uwOffsetY),
				bobCalcFrameAddress(s_pJetMask, uwOffsetY)
			);
			pVehicle->sBobJet.sPos.ulYX = pVehicle->sBobTrack.sPos.ulYX;
			pVehicle->sBobJet.sPos.uwY += VEHICLE_TRACK_JET_HEIGHT;
			if(isVehicleVisible) {
				gameTryPushBob(&pVehicle->sBobJet);
			}
		}
	}
	if(isVehicleVisible) {
		gameTryPushBob(&pVehicle->sBobTrack);
	}

	// Drilling
	if(isOnGround && !tntIsDetonationActive(&pVehicle->sDynamite)) {
		if(pVehicle->sSteer.bX > 0 && tileIsDrillable(uwTileRight, uwTileMid)) {
			vehicleStartDrilling(pVehicle, uwTileRight, uwTileMid, DRILL_DIR_H, TILE_SIZE / 2 - VEHICLE_HALF_WIDTH);
		}
		else if(pVehicle->sSteer.bX < 0 && tileIsDrillable(uwTileLeft, uwTileMid)) {
			vehicleStartDrilling(pVehicle, uwTileLeft, uwTileMid, DRILL_DIR_H, -TILE_SIZE / 2 + VEHICLE_HALF_WIDTH);
		}
		else if(
			pVehicle->sSteer.bY > 0 && uwTileBottom < TILE_MINE_DEPTH - 1 &&
			tileIsDrillable(uwTileCenter, uwTileBottom)
		) {
			vehicleStartDrilling(pVehicle, uwTileCenter, uwTileBottom, DRILL_DIR_V, 0);
		}
	}
	if(isVehicleVisible) {
		gameTryPushBob(&pVehicle->sBobBody);
		pVehicle->isMarkerShown = 0;
	}
	else {
		vehicleDrawMarker(pVehicle);
		pVehicle->isMarkerShown = 1;
	}

	// Tool
	vehicleSetTool(pVehicle, TOOL_STATE_IDLE, 0);
	if(isVehicleVisible) {
		gameTryPushBob(&pVehicle->sBobTool);
	}

	if(vehicleIsNearShop(pVehicle)) {
		// If restocked then play audio & display score
		WORD wDeltaScore = vehicleRestock(pVehicle);
		if(wDeltaScore) {
			if(wDeltaScore == RESTOCK_RESULT_ONLY_MINERALS) {
				textBobSetText(&pVehicle->sTextBob, COLOR_GOLD, g_pMsgs[MSG_MISC_RESTOCK]);
			}
			else {
				textBobSetTextVa(
					&pVehicle->sTextBob, COLOR_GOLD, "%s %hd\x1F",
					g_pMsgs[MSG_MISC_RESTOCK], wDeltaScore
				);
			}
			audioMixerPlaySfx(g_pSfxOre, SFX_CHANNEL_EFFECT, SFX_PRIORITY_PICKUP, 0);
			textBobSetPos(
				&pVehicle->sTextBob,
				pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH/2,
				pVehicle->sBobBody.sPos.uwY,
				pVehicle->sBobBody.sPos.uwY - 48, 1
			);
			protestsProcess();
		}
	}
}

static void vehicleProcessDeadGravity(tVehicle *pVehicle) {
	UWORD uwY = fix16_to_int(pVehicle->fY);
	UBYTE ubAdd = (uwY > (1 + TILE_ROW_BASE_DIRT) * TILE_SIZE) ? 4 : 2;
	UWORD uwTileBottom = (uwY + VEHICLE_HEIGHT + ubAdd) >> TILE_SHIFT;
	UWORD uwCenterX = pVehicle->sBobBody.sPos.uwX + VEHICLE_WIDTH / 2;
	UWORD uwTileCenter = uwCenterX >> TILE_SHIFT;
	if(!tileIsSolid(uwTileCenter, uwTileBottom)) {
		// Gravity
		pVehicle->fDy = MIN(s_fMaxGravDy, pVehicle->fDy + s_fAccGrav);
		pVehicle->fY += pVehicle->fDy;
	}
	else {
		// Collision with ground
		pVehicle->fY = fix16_from_int((uwTileBottom << TILE_SHIFT) - VEHICLE_HEIGHT - ubAdd);
		pVehicle->fDy = 0;
	}
}

static void vehicleProcessSmoking(tVehicle *pVehicle) {
	// TODO: push if vehicle is visible
	vehicleProcessDeadGravity(pVehicle);
	pVehicle->sBobWreck.sPos.uwY = (
		fix16_to_int(pVehicle->fY) + VEHICLE_BODY_HEIGHT +
		VEHICLE_TRACK_HEIGHT - VEHICLE_WRECK_HEIGHT
	);
	gameTryPushBob(&pVehicle->sBobWreck);

	pVehicle->sBobSmoke.sPos.uwY = (
		fix16_to_int(pVehicle->fY) + VEHICLE_BODY_HEIGHT +
		VEHICLE_TRACK_HEIGHT - VEHICLE_SMOKE_ANIM_HEIGHT
	);
	if(pVehicle->ubSmokeAnimCnt == 10) {
		pVehicle->ubSmokeAnimCnt = 0;
		++pVehicle->ubSmokeAnimFrame;
		if(pVehicle->ubSmokeAnimFrame == VEHICLE_SMOKE_FRAMES) {
			pVehicle->ubSmokeAnimFrame = 0;
		}
		UWORD uwOffsY = VEHICLE_SMOKE_FRAME_HEIGHT * pVehicle->ubSmokeAnimFrame;
		bobSetFrame(
			&pVehicle->sBobSmoke,
			bobCalcFrameAddress(s_pSmokeFrames, uwOffsY),
			bobCalcFrameAddress(s_pSmokeMask, uwOffsY)
		);
	}
	else {
		++pVehicle->ubSmokeAnimCnt;
	}
	gameTryPushBob(&pVehicle->sBobSmoke);

	if(s_ubBebCountdown == 0) {
		vehicleRespawn(pVehicle);
	}
	else {
		--s_ubBebCountdown;
	}
}

UBYTE transitionVarToBy(fix16_t *pVar, fix16_t fDest, fix16_t fDelta) {
	// Var is close to dest - set to same
	if(fix16_abs(*pVar - fDest) <= fDelta) {
		*pVar = fDest;
		return 1;
	}

	// Increment by delta if diff is big enough
	if (*pVar < fDest) {
		*pVar += fDelta;
	}
	else {
		*pVar -= fDelta;
	}
	return 0;
}

static void vehicleDrawOrMarker(tVehicle *pVehicle) {
	UBYTE isAnyDrawn = (
		gameTryPushBob(&pVehicle->sBobTrack) |
		gameTryPushBob(&pVehicle->sBobBody) |
		gameTryPushBob(&pVehicle->sBobTool)
	);
	if(!isAnyDrawn) {
		vehicleDrawMarker(pVehicle);
		pVehicle->isMarkerShown = 1;
	}
	else {
		pVehicle->isMarkerShown = 0;
	}
}

static void vehicleProcessDrilling(tVehicle *pVehicle) {
	static const UBYTE pTrackAnimOffs[DRILL_V_ANIM_LEN] = {
		0, 1, 2, 3, 4, 5, 6, 5, 4, 3, 2, 1, 0
	};
	switch(pVehicle->ubDrillState) {
		case DRILL_STATE_VERT_ANIM_IN:
		case DRILL_STATE_VERT_ANIM_OUT:
			if(pVehicle->ubDrillState == DRILL_STATE_VERT_ANIM_IN) {
				++pVehicle->ubDrillVAnimCnt;
				if(pVehicle->ubDrillVAnimCnt >= DRILL_V_ANIM_LEN - 1) {
					pVehicle->ubDrillState = DRILL_STATE_DRILLING;
				}
				else if(pVehicle->ubDrillVAnimCnt == 5) {
					bobSetFrame(
						&pVehicle->sBobTrack,
						bobCalcFrameAddress(s_pTrackFrames, TRACK_OFFSET_DRILL),
						bobCalcFrameAddress(s_pTrackMask, TRACK_OFFSET_DRILL)
					);
				}
			}
			else {
				if(!--pVehicle->ubDrillVAnimCnt) {
					pVehicle->ubDrillDir = DRILL_DIR_NONE;
					pVehicle->ubDrillState = DRILL_STATE_OFF;
					vehicleSetState(pVehicle, VEHICLE_STATE_MOVING);
				}
				else if(pVehicle->ubDrillVAnimCnt == 5) {
					bobSetFrame(
						&pVehicle->sBobTrack,
						bobCalcFrameAddress(s_pTrackFrames, TRACK_OFFSET_TRACK),
						bobCalcFrameAddress(s_pTrackMask, TRACK_OFFSET_TRACK)
					);
				}
			}

			pVehicle->sBobBody.sPos.uwX = fix16_to_int(pVehicle->fX);
			pVehicle->sBobBody.sPos.uwY = fix16_to_int(pVehicle->fY);
			pVehicle->sBobBody.sPos.uwY += pTrackAnimOffs[pVehicle->ubDrillVAnimCnt];
			vehicleSetTool(pVehicle, TOOL_STATE_IDLE, 0);
			break;
		case DRILL_STATE_DRILLING: {
			// Movement - process X and Y since vehicle may be not centered on tile
			// when drilling vertically and we must correct X pos
			fix16_t fDrillDelta = pVehicle->fDrillDelta;
			UBYTE isDoneX = transitionVarToBy(&pVehicle->fX, pVehicle->fDrillDestX, fDrillDelta);
			UBYTE isDoneY = transitionVarToBy(&pVehicle->fY, pVehicle->fDrillDestY, fDrillDelta);

			// Pos for tool & track
			pVehicle->sBobTrack.sPos.ulYX = pVehicle->sBobBody.sPos.ulYX;
			pVehicle->sBobTrack.sPos.uwY += VEHICLE_BODY_HEIGHT - 1;
			pVehicle->sBobBody.sPos.uwX = fix16_to_int(pVehicle->fX);
			pVehicle->sBobBody.sPos.uwY = fix16_to_int(pVehicle->fY);

			if(isDoneX && isDoneY) {
				tTile eTile = g_pMainBuffer->pTileData[pVehicle->sDrillTile.uwX][pVehicle->sDrillTile.uwY];
				vehicleExcavateTile(pVehicle, pVehicle->sDrillTile.uwX, pVehicle->sDrillTile.uwY);
				if(eTile == TILE_MAGMA_1 || eTile == TILE_MAGMA_2) {
					vehicleHullDamage(pVehicle, 5 + (randUw(&g_sRand) & 0x7));
				}

				if(pVehicle->ubDrillDir == DRILL_DIR_H) {
					pVehicle->ubDrillDir = DRILL_DIR_NONE;
					pVehicle->ubDrillState = DRILL_STATE_OFF;
					vehicleSetState(pVehicle, VEHICLE_STATE_MOVING);
					vehicleStopLoopAudio(pVehicle->ubPlayerIdx);
				}
				else {
					const UBYTE ubAdd = 4; // No grass past this point
					UWORD uwTileBottom = (pVehicle->sBobBody.sPos.uwY + VEHICLE_HEIGHT + ubAdd) >> TILE_SHIFT;
					UWORD uwTileX = pVehicle->sBobBody.sPos.uwX >> TILE_SHIFT;
					if(
						pVehicle->sSteer.bY > 0 && uwTileBottom < TILE_MINE_DEPTH - 1 &&
						tileIsDrillable(uwTileX, uwTileBottom) &&
						vehicleStartDrilling(pVehicle, uwTileX, uwTileBottom, DRILL_DIR_V, 0)
					) {
						pVehicle->ubDrillState = DRILL_STATE_DRILLING;
					}
					else {
						pVehicle->ubDrillState = DRILL_STATE_VERT_ANIM_OUT;
						vehicleStopLoopAudio(pVehicle->ubPlayerIdx);
					}
				}
			}
			else {
				// Body shake
				pVehicle->sBobBody.sPos.uwX += randUw(&g_sRand) & 1;
				pVehicle->sBobBody.sPos.uwY += randUw(&g_sRand) & 1;

				// Anim counter for Tool / track drill
				UBYTE ubDrillAnimFrame = 0;
				++pVehicle->ubToolAnimCnt;
				if(pVehicle->ubToolAnimCnt >= 4) {
					pVehicle->ubToolAnimCnt = 0;
				}
				else if(pVehicle->ubToolAnimCnt >= 2) {
					ubDrillAnimFrame = 1;
				}

				// Anim for Tool / track drill
				if(pVehicle->ubDrillDir == DRILL_DIR_H) {
					vehicleSetTool(pVehicle, TOOL_STATE_DRILL, ubDrillAnimFrame);
				}
				else {
					vehicleSetTool(pVehicle, TOOL_STATE_IDLE, 0);
					UWORD uwOffsY = TRACK_OFFSET_DRILL + (ubDrillAnimFrame ? VEHICLE_TRACK_HEIGHT : 0);
					bobSetFrame(
						&pVehicle->sBobTrack,
						bobCalcFrameAddress(s_pTrackFrames, uwOffsY),
						bobCalcFrameAddress(s_pTrackMask, uwOffsY)
					);
				}
			}
		} break;
		default:
			break;
	}

	vehicleDrawOrMarker(pVehicle);
}

void vehicleProcessText(void) {
	// MUST BE BEFORE ANY BOB PUSH
	static UBYTE ubPlayer = 0;
	textBobUpdate(&g_pVehicles[ubPlayer].sTextBob);
	ubPlayer = !ubPlayer;
}

void vehicleProcessExploding(tVehicle *pVehicle) {
	// TODO: push if vehicle is visible
	vehicleProcessDeadGravity(pVehicle);
	pVehicle->sBobTrack.sPos.ulYX = pVehicle->sBobBody.sPos.ulYX;
	pVehicle->sBobTrack.sPos.uwY += VEHICLE_BODY_HEIGHT - 1;
	vehicleSetTool(pVehicle, TOOL_STATE_IDLE, 0);

	vehicleDrawOrMarker(pVehicle);
}

static void vehicleProcessTeleportingVisible(tVehicle *pVehicle) {
	pVehicle->sBobBody.sPos.uwX = fix16_to_int(pVehicle->fX);
	pVehicle->sBobBody.sPos.uwY = fix16_to_int(pVehicle->fY);
	pVehicle->sBobTrack.sPos.ulYX = pVehicle->sBobBody.sPos.ulYX;
	pVehicle->sBobTrack.sPos.uwY += VEHICLE_BODY_HEIGHT - 1;
	vehicleSetTool(pVehicle, TOOL_STATE_IDLE, 0);

	vehicleDrawOrMarker(pVehicle);
}

void vehicleProcess(tVehicle *pVehicle) {
	switch(pVehicle->ubVehicleState) {
		case VEHICLE_STATE_DRILLING:
			vehicleProcessDrilling(pVehicle);
			break;
		case VEHICLE_STATE_MOVING:
			vehicleProcessMovement(pVehicle);
			break;
		case VEHICLE_STATE_EXPLODING:
			vehicleProcessExploding(pVehicle);
			break;
		case VEHICLE_STATE_SMOKING:
			vehicleProcessSmoking(pVehicle);
			break;
		case VEHICLE_STATE_TELEPORTING_INVISIBLE:
			break;
		case VEHICLE_STATE_TELEPORTING_VISIBLE:
			vehicleProcessTeleportingVisible(pVehicle);
			break;
	}

	UBYTE ubPlayerIdx = pVehicle->ubPlayerIdx;
	UWORD uwDrillMax = inventoryGetPartDef(INVENTORY_PART_DRILL)->uwMax;
	hudSetDrill(ubPlayerIdx, pVehicle->uwDrillCurr, uwDrillMax);
	textBobAnimate(&pVehicle->sTextBob);
	UWORD uwDepthDm = MAX(
		0, fix16_to_int(pVehicle->fY) + VEHICLE_HEIGHT - (TILE_ROW_BASE_DIRT) * TILE_SIZE
	);
	gameUpdateMaxDepth(uwDepthDm);
	hudSetDepth(ubPlayerIdx, uwDepthDm);
	hudSetCash(ubPlayerIdx, pVehicle->lCash);
}

uint8_t vehiclesAreClose(void) {
	const UWORD uwVpHeight = 256 - HUD_HEIGHT;
	WORD wDelta = ABS(
		g_pVehicles[0].sBobBody.sPos.uwY - g_pVehicles[1].sBobBody.sPos.uwY
	);
	if(wDelta <= uwVpHeight) {
		return 1;
	}
	return 0;
}

static void vehicleOnTeleportInEnd(void *pData) {
	tVehicle *pVehicle = pData;
	if(pVehicle->ubVehicleState == VEHICLE_STATE_TELEPORTING_VISIBLE) {
		vehicleSetState(pVehicle, VEHICLE_STATE_MOVING);
	}
}

static void vehicleOnTeleportInPeak(void *pData) {
	tVehicle *pVehicle = pData;
	vehicleSetState(pVehicle, VEHICLE_STATE_TELEPORTING_VISIBLE);

	if(pVehicle->eTeleportKind == TELEPORT_KIND_MINE_TO_BASE && (
		inventoryGetPartDef(INVENTORY_PART_TELEPORT)->ubLevel == INVENTORY_LEVEL_TELEPORTER_WEAK ||
		protestsGetState() >= PROTEST_STATE_PROTEST
	)) {
		UWORD uwMaxHealth = inventoryGetPartDef(INVENTORY_PART_HULL)->uwMax;
		if(randUwMax(&g_sRand, 100) <= 5) {
			vehicleHullDamage(pVehicle, (uwMaxHealth * 4) / 5);
		}
		else if(randUwMax(&g_sRand, 100) <= 20) {
			vehicleHullDamage(pVehicle, uwMaxHealth / 2);
		}
	}
}

static void vehicleOnTeleportOutPeak(void *pData) {
	tVehicle *pVehicle = pData;
	flipbookAdd(
		pVehicle->uwTeleportX, pVehicle->uwTeleportY,
		vehicleOnTeleportInPeak, vehicleOnTeleportInEnd,
		pVehicle, pVehicle->eTeleportInFlipbook
	);

	// pVehicle->uwTeleportX/Y is flipbook pos - add a bit to vehicle pos to accomodate for its wide bob
	if(pVehicle->eTeleportInFlipbook == FLIPBOOK_KIND_TELEPORTER_IN) {
		pVehicle->uwTeleportX += 7;
		pVehicle->uwTeleportY += 3;
	}
	vehicleSetPos(pVehicle, pVehicle->uwTeleportX, pVehicle->uwTeleportY);
	vehicleSetState(pVehicle, VEHICLE_STATE_TELEPORTING_INVISIBLE);
}

void vehicleTeleport(
	tVehicle *pVehicle, UWORD uwX, UWORD uwY, tTeleportKind eTeleportKind
) {
	UBYTE isWeakTeleporter = (
		eTeleportKind == TELEPORT_KIND_MINE_TO_BASE &&
		inventoryGetPartDef(INVENTORY_PART_TELEPORT)->ubLevel == INVENTORY_LEVEL_TELEPORTER_WEAK
	);

	pVehicle->eTeleportKind = eTeleportKind;
	pVehicle->uwTeleportX = uwX;
	pVehicle->uwTeleportY = uwY;
	if(isWeakTeleporter) {
		pVehicle->uwTeleportX += randUwMax(&g_sRand, 64) - 32;
		pVehicle->uwTeleportY -= randUwMax(&g_sRand, 64);
	}

	UWORD uwFlipbookX;
	UWORD uwFlipbookY;
	tFlipbookKind eFlipbookKind;
	if(eTeleportKind == TELEPORT_KIND_MINE_TO_BASE) {
		uwFlipbookX = pVehicle->sBobBody.sPos.uwX;
		uwFlipbookY = pVehicle->sBobBody.sPos.uwY;
		eFlipbookKind = FLIPBOOK_KIND_TELEPORT;
	}
	else {
		const tBase *pBase = baseGetCurrent();
		eFlipbookKind = FLIPBOOK_KIND_TELEPORTER_OUT;
		uwFlipbookX = pBase->sPosTeleport.uwX;
		uwFlipbookY = pBase->sPosTeleport.uwY;
		vehicleSetPos(pVehicle, pBase->sPosTeleport.uwX + 7, pBase->sPosTeleport.uwY + 3);
	}
	vehicleSetState(pVehicle, VEHICLE_STATE_TELEPORTING_VISIBLE);

	pVehicle->eTeleportInFlipbook = (
		eTeleportKind == TELEPORT_KIND_BASE_TO_MINE || isWeakTeleporter
	)
		? FLIPBOOK_KIND_TELEPORT : FLIPBOOK_KIND_TELEPORTER_IN;
	flipbookAdd(
		uwFlipbookX, uwFlipbookY,
		vehicleOnTeleportOutPeak, 0, pVehicle, eFlipbookKind
	);
}

tVehicle g_pVehicles[2];
