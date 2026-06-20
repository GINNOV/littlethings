/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _VEHICLE_H_
#define _VEHICLE_H_

#include <ace/types.h>
#include <fixmath/fix16.h>
#include <ace/managers/bob.h>
#include "text_bob.h"
#include "mineral.h"
#include "tnt.h"
#include "string_array.h"
#include "mode_menu.h"
#include "base.h"
#include "flipbook.h"

#define VEHICLE_WIDTH 32
#define VEHICLE_HEIGHT 24

typedef enum tTeleportKind {
	TELEPORT_KIND_BASE_TO_BASE,
	TELEPORT_KIND_BASE_TO_MINE,
	TELEPORT_KIND_MINE_TO_BASE
} tTeleportKind;

typedef enum _tDrillDir {
	DRILL_DIR_NONE = 0,
	DRILL_DIR_H,
	DRILL_DIR_V,
} tDrillDir;

typedef enum _tDrillState {
	DRILL_STATE_VERT_ANIM_IN = 0,
	DRILL_STATE_DRILLING,
	DRILL_STATE_VERT_ANIM_OUT,
	DRILL_STATE_OFF,
} tDrillState;

typedef enum _tToolState {
	TOOL_STATE_IDLE,
	TOOL_STATE_DRILL,
} tToolState;

typedef enum _tVehicleState {
	VEHICLE_STATE_MOVING,
	VEHICLE_STATE_DRILLING,
	VEHICLE_STATE_EXPLODING,
	VEHICLE_STATE_SMOKING,
	VEHICLE_STATE_TELEPORTING_WAIT_FOR_CAMERA,
	VEHICLE_STATE_TELEPORTING_INVISIBLE,
	VEHICLE_STATE_TELEPORTING_VISIBLE,
	VEHICLE_STATE_COUNT,
} tVehicleState;

typedef struct _tVehicle {
	tBCoordYX sSteer;
	tTextBob sTextBob;
	tBob sBobBody;
	tBob sBobTrack;
	tBob sBobJet;
	tBob sBobTool;
	tBob sBobWreck;
	tBob sBobSmoke;
	tBob sBobMarker;
	fix16_t fX;
	fix16_t fY;
	fix16_t fDx;
	fix16_t fDy;
	UBYTE ubPlayerIdx;
	UBYTE ubVehicleState;
	UBYTE isFacingRight;
	UBYTE ubBodyShakeCnt;
	UBYTE isJetting;
	UBYTE ubJetShowFrame;
	UBYTE ubJetAnimFrame;
	UBYTE ubJetAnimCnt;
	UBYTE ubToolAnimCnt;
	tModeOption eDrillMode;
	tBaseId eLastVisitedTeleportableBase;
	// Drilling
	UBYTE ubDrillDir;
	UBYTE ubDrillVAnimCnt;
	fix16_t fDrillDestX, fDrillDestY;
	fix16_t fDrillDelta;
	fix16_t fToolOffset;
	tUwCoordYX sDrillTile;
	// Anims
	fix16_t fTrackAnimCnt;
	UBYTE ubTrackFrame;
	UBYTE ubSmokeAnimFrame;
	UBYTE ubSmokeAnimCnt;
	UBYTE ubDrillState;
	tTeleportKind eTeleportKind;
	UWORD uwTeleportX;
	UWORD uwTeleportY;
	tFlipbookKind eTeleportInFlipbook;
	// Cargo
	UBYTE uwCargoCurr;
	UWORD uwCargoScore;
	UWORD pStock[MINERAL_TYPE_COUNT];
	// Cash, drill, hull
	LONG lCash;
	UWORD uwDrillCurr;
	UWORD wHullCurr;
	tTnt sDynamite;
	// Hull damage frames
	UBYTE ubHullDamageFrame;
	UBYTE ubDamageBlinkCooldown;
	UBYTE isChallengeEnded;
	UBYTE isMarkerShown;
} tVehicle;

void vehicleManagerCreate(void);

void vehicleManagerDestroy(void);

void vehicleStopLoopAudio(UBYTE ubPlayerIdx);

UBYTE vehicleIsNearShop(const tVehicle *pVehicle);

UBYTE vehicleIsNearBaseTeleporter(const tVehicle *pVehicle);

UBYTE vehicleIsInBase(const tVehicle *pVehicle);

void vehicleSetPos(tVehicle *pVehicle, UWORD uwX, UWORD uwY);

void vehicleResetPos(tVehicle *pVehicle);

void vehicleReset(tVehicle *pVehicle);

void vehicleSave(tVehicle *pVehicle, tFile *pFile);

UBYTE vehicleLoad(tVehicle *pVehicle, tFile *pFile);

void vehicleMove(tVehicle *pVehicle, BYTE bDirX, BYTE bDirY);

void vehicleProcessText(void);

void vehicleProcess(tVehicle *pVehicle);

void vehicleTeleport(tVehicle *pVehicle, UWORD uwX, UWORD uwY, tTeleportKind eTeleportKind);

UBYTE vehiclesAreClose(void);

void vehicleExcavateTile(tVehicle *pVehicle, UWORD uwTileX, UWORD uwTileY);

UBYTE vehicleTrySpendCash(UBYTE ubPlayerIndex, LONG lCost);

extern tVehicle g_pVehicles[2];

#endif // _VEHICLE_H_
