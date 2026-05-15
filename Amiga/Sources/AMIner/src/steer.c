/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "steer.h"
#include <ace/managers/joy.h>
#include <ace/managers/key.h>

//------------------------------------------------------------------ PRIVATE FNS

static void onJoy(tSteer *pSteer) {
	// Joy direction enum is not in same order as steer enum
	// There is a reason why it's ordered that way in game, so it needs remapping
	static const UBYTE pDirToJoy[] = {
		[DIRECTION_UP] = JOY_UP,
		[DIRECTION_DOWN] = JOY_DOWN,
		[DIRECTION_LEFT] = JOY_LEFT,
		[DIRECTION_RIGHT] = JOY_RIGHT,
		[DIRECTION_FIRE] = JOY_FIRE
	};

	UBYTE ubJoy = pSteer->ubJoy;

	for(tDirection eDir = 0; eDir < DIRECTION_COUNT; ++eDir) {
		if(joyCheck(ubJoy + pDirToJoy[eDir])) {
			if(pSteer->pDirectionStates[eDir] == STEER_DIR_STATE_INACTIVE) {
				pSteer->pDirectionStates[eDir] = STEER_DIR_STATE_ACTIVE;
			}
		}
		else {
			pSteer->pDirectionStates[eDir] = STEER_DIR_STATE_INACTIVE;
		}
	}
}

static void onKey(tSteer *pSteer) {
	static const UBYTE pDirsWsad[] = {
		[DIRECTION_UP] = KEY_W,
		[DIRECTION_DOWN] = KEY_S,
		[DIRECTION_LEFT] = KEY_A,
		[DIRECTION_RIGHT] = KEY_D,
		[DIRECTION_FIRE] = KEY_LSHIFT
	};
	static const UBYTE pDirsArrows[] = {
		[DIRECTION_UP] = KEY_UP,
		[DIRECTION_DOWN] = KEY_DOWN,
		[DIRECTION_LEFT] = KEY_LEFT,
		[DIRECTION_RIGHT] = KEY_RIGHT,
		[DIRECTION_FIRE] = KEY_RSHIFT
	};

	const UBYTE *pDirToKey = (pSteer->eKeymap == STEER_KEYMAP_WSAD) ? pDirsWsad : pDirsArrows;

	for(tDirection eDir = 0; eDir < DIRECTION_COUNT; ++eDir) {
		if(keyCheck(pDirToKey[eDir])) {
			if(pSteer->pDirectionStates[eDir] == STEER_DIR_STATE_INACTIVE) {
				pSteer->pDirectionStates[eDir] = STEER_DIR_STATE_ACTIVE;
			}
		}
		else {
			pSteer->pDirectionStates[eDir] = STEER_DIR_STATE_INACTIVE;
		}
	}
}

static void onIdle(UNUSED_ARG tSteer *pSteer) {
	// Do nothing
}

static tSteer steerInitJoy(UBYTE ubJoy) {
	tSteer sSteer = {
		.cbProcess = onJoy,
		.ubJoy = ubJoy
	};
	return sSteer;
}

static tSteer steerInitKey(tSteerKeymap eKeymap) {
	tSteer sSteer = {
		.cbProcess = onKey,
		.eKeymap = eKeymap
	};
	return sSteer;
}

static tSteer steerInitIdle(void) {
	tSteer sSteer = {
		.cbProcess = onIdle
	};
	return sSteer;
}


//------------------------------------------------------------------- PUBLIC FNS

tSteer steerInitFromMode(tSteerMode eMode) {
	switch(eMode) {
		case STEER_MODE_JOY_1:
			return steerInitJoy(JOY1);
		case STEER_MODE_JOY_2:
			return steerInitJoy(JOY2);
		case STEER_MODE_KEY_ARROWS:
			return steerInitKey(STEER_KEYMAP_ARROWS);
		case STEER_MODE_KEY_WSAD:
			return steerInitKey(STEER_KEYMAP_WSAD);
		default:
			return steerInitIdle();
	}
}

void steerProcess(tSteer *pSteer) {
	if(pSteer->cbProcess) {
		pSteer->cbProcess(pSteer);
	}
}

UBYTE steerIsPlayer(const tSteer *pSteer) {
	return (pSteer->cbProcess == onJoy || pSteer->cbProcess == onKey);
}

UBYTE steerIsArrows(const tSteer *pSteer) {
	UBYTE isArrows = (pSteer->cbProcess == onKey && pSteer->eKeymap == STEER_KEYMAP_ARROWS);
	return isArrows;
}

UBYTE steerDirCheck(const tSteer *pSteer, tDirection eDir) {
	return pSteer->pDirectionStates[eDir] != STEER_DIR_STATE_INACTIVE;
}

UBYTE steerDirUse(tSteer *pSteer, tDirection eDir) {
	if(pSteer->pDirectionStates[eDir] == STEER_DIR_STATE_ACTIVE) {
		pSteer->pDirectionStates[eDir] = STEER_DIR_STATE_USED;
		return 1;
	}
	return 0;
}

tDirection steerGetPressedDir(const tSteer *pSteer) {
	if(pSteer->pDirectionStates[DIRECTION_UP] != STEER_DIR_STATE_INACTIVE) {
		return DIRECTION_UP;
	}
	if(pSteer->pDirectionStates[DIRECTION_DOWN] != STEER_DIR_STATE_INACTIVE) {
		return DIRECTION_DOWN;
	}
	if(pSteer->pDirectionStates[DIRECTION_LEFT] != STEER_DIR_STATE_INACTIVE) {
		return DIRECTION_LEFT;
	}
	if(pSteer->pDirectionStates[DIRECTION_RIGHT] != STEER_DIR_STATE_INACTIVE) {
		return DIRECTION_RIGHT;
	}
	return DIRECTION_COUNT;
}
