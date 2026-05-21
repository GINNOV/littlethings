/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "base_unlocks.h"
#include "background_bob.h"
#include "base.h"
#include "inventory.h"
#include "game.h"
#include "assets.h"

#define BASE_ANTENNA_WIDTH 32
#define BASE_ANTENNA_HEIGHT 28
#define BASE_WORKSHOP_WIDTH 32
#define BASE_WORKSHOP_HEIGHT 25
#define BASE_WORKSHOP_OFFSET BASE_ANTENNA_HEIGHT
#define BASE_TELEPORTER_IDLE_FRAME_HEIGHT 12
#define BASE_TELEPORTER_FRONT_FRAME_HEIGHT 7
#define BASE_TELEPORTER_IDLE_DELTA_Y (BASE_TELEPORTER_HEIGHT - BASE_TELEPORTER_IDLE_FRAME_HEIGHT)
#define BASE_TELEPORTER_FRONT_DELTA_Y (BASE_TELEPORTER_HEIGHT - BASE_TELEPORTER_FRONT_FRAME_HEIGHT)

static tBackgroundBob s_sBgBobTeleporter, s_sBgBobAntenna, s_sBgBobWarehouse;
static tBob s_sBobTeleporterFront;
static tBitMap *s_pTeleporterIdleFrame;
static tBitMap *s_pTeleporterIdleMask;
static tBitMap *s_pBaseUnlocksFrames;
static tBitMap *s_pBaseUnlocksMasks;
static tBaseId s_eBaseIdPrev;

void baseUnlocksCreate(void) {
	s_pTeleporterIdleFrame = bitmapCreateFromFd(GET_SUBFILE_PREFIX("base_teleporter_idle.bm"), 0);
	s_pTeleporterIdleMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("base_teleporter_idle_mask.bm"), 0);
	s_pBaseUnlocksFrames = bitmapCreateFromFd(GET_SUBFILE_PREFIX("base_unlocks.bm"), 0);
	s_pBaseUnlocksMasks = bitmapCreateFromFd(GET_SUBFILE_PREFIX("base_unlocks_mask.bm"), 0);
	s_eBaseIdPrev = BASE_ID_COUNT;

	bobInit(
		&s_sBgBobTeleporter.sBob, BASE_TELEPORTER_WIDTH, BASE_TELEPORTER_IDLE_FRAME_HEIGHT, 0,
		s_pTeleporterIdleFrame->Planes[0], s_pTeleporterIdleMask->Planes[0], 0, 0
	);
	backgroundBobResetCounter(&s_sBgBobTeleporter);
	bobInit(
		&s_sBgBobAntenna.sBob, BASE_ANTENNA_WIDTH, BASE_ANTENNA_HEIGHT, 0,
		s_pBaseUnlocksFrames->Planes[0], s_pBaseUnlocksMasks->Planes[0], 0, 0
	);
	backgroundBobResetCounter(&s_sBgBobAntenna);
	bobInit(
		&s_sBgBobWarehouse.sBob, BASE_WORKSHOP_WIDTH, BASE_WORKSHOP_HEIGHT, 0,
		bobCalcFrameAddress(s_pBaseUnlocksFrames, BASE_WORKSHOP_OFFSET),
		bobCalcFrameAddress(s_pBaseUnlocksMasks, BASE_WORKSHOP_OFFSET), 0, 0
	);
	backgroundBobResetCounter(&s_sBgBobWarehouse);

	bobInit(
		&s_sBobTeleporterFront, BASE_TELEPORTER_WIDTH, BASE_TELEPORTER_FRONT_FRAME_HEIGHT, 0,
		bobCalcFrameAddress(s_pTeleporterIdleFrame, BASE_TELEPORTER_IDLE_FRAME_HEIGHT),
		bobCalcFrameAddress(s_pTeleporterIdleMask, BASE_TELEPORTER_IDLE_FRAME_HEIGHT),
		0, 0
	);
}

void baseUnlocksDrawBack(void) {
	tBaseId eBaseId = baseGetCurrentId();
	const tBase *pBase = baseGetCurrent();
	if(eBaseId != s_eBaseIdPrev) {
		s_sBgBobTeleporter.sBob.sPos.ulYX = pBase->sPosTeleport.ulYX;
		s_sBgBobTeleporter.sBob.sPos.uwY += BASE_TELEPORTER_IDLE_DELTA_Y;
		backgroundBobResetCounter(&s_sBgBobTeleporter);
		s_sBobTeleporterFront.sPos.ulYX = pBase->sPosTeleport.ulYX;
		s_sBobTeleporterFront.sPos.uwY += BASE_TELEPORTER_FRONT_DELTA_Y;

		s_sBgBobAntenna.sBob.sPos.ulYX = pBase->sPosAntenna.ulYX;
		backgroundBobResetCounter(&s_sBgBobAntenna);

		s_sBgBobWarehouse.sBob.sPos.ulYX = pBase->sPosWorkshop.ulYX;
		backgroundBobResetCounter(&s_sBgBobWarehouse);
	}

	if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, eBaseId)) {
		backgroundBobPush(&s_sBgBobTeleporter);
	}
	if(eBaseId != BASE_ID_GROUND) {
		tCommUnlockState eCommUnlockState = inventoryGetCommUnlockState(eBaseId);
		if(eCommUnlockState >= COMM_UNLOCK_STATE_OFFICE_WORKSHOP) {
			backgroundBobPush(&s_sBgBobAntenna);
		}
		if(eCommUnlockState >= COMM_UNLOCK_STATE_WAREHOUSE) {
			backgroundBobPush(&s_sBgBobWarehouse);
		}
	}

	s_eBaseIdPrev = eBaseId;
}

void baseUnlocksDrawFront(void) {
	if(inventoryGetBasePartLevel(INVENTORY_PART_BASE_PLATFORM, s_eBaseIdPrev)) {
		gameTryPushBob(&s_sBobTeleporterFront);
	}
}

void baseUnlocksDestroy(void) {
	bitmapDestroy(s_pTeleporterIdleFrame);
	bitmapDestroy(s_pTeleporterIdleMask);
	bitmapDestroy(s_pBaseUnlocksFrames);
	bitmapDestroy(s_pBaseUnlocksMasks);
}
