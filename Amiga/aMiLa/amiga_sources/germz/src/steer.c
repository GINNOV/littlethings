/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "steer.h"
#include "player.h"
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

	const UBYTE *pDirToKey = (pSteer->eKeymap == KEYMAP_WSAD) ? pDirsWsad : pDirsArrows;

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

static void onAi(tSteer *pSteer) {
	tAi *pAi = &pSteer->sAi;
	tDirection eDir = aiProcess(pAi);

	// Fire is a special button - can be pressed for more than one process
	if(pAi->isPressingFire) {
		if(pSteer->pDirectionStates[DIRECTION_FIRE] == STEER_DIR_STATE_INACTIVE) {
			logWrite("Pressing fire\n");
			pSteer->pDirectionStates[DIRECTION_FIRE] = STEER_DIR_STATE_ACTIVE;
		}
	}
	else {
		if(pSteer->pDirectionStates[DIRECTION_FIRE] != STEER_DIR_STATE_INACTIVE) {
			logWrite("Releasing fire\n");
		}
		pSteer->pDirectionStates[DIRECTION_FIRE] = STEER_DIR_STATE_INACTIVE;
	}

	if(eDir != DIRECTION_COUNT) {
		// Push the selected button
		if(pSteer->pDirectionStates[eDir] == STEER_DIR_STATE_INACTIVE) {
			logWrite("Pressing dir %hhu\n", eDir);
			pSteer->pDirectionStates[eDir] = STEER_DIR_STATE_ACTIVE;
		}
	}

	// Unpress the previous action
	if(pAi->ePrevDir != DIRECTION_COUNT) {
		logWrite("Releasing dir %hhu\n", pAi->ePrevDir);
		pSteer->pDirectionStates[pAi->ePrevDir] = STEER_DIR_STATE_INACTIVE;
	}

	// Save the current action for later unpressing
	pAi->ePrevDir = eDir;
}

static void onIdle(UNUSED_ARG tSteer *pSteer) {
	// Do nothing
}

//------------------------------------------------------------------- PUBLIC FNS

tSteer steerInitFromMode(tSteerMode eMode, UBYTE ubPlayerIdx) {
	switch(eMode) {
		case STEER_MODE_JOY_1:
			return steerInitJoy(JOY1);
		case STEER_MODE_JOY_2:
			return steerInitJoy(JOY2);
		case STEER_MODE_JOY_3:
			return steerInitJoy(JOY3);
		case STEER_MODE_JOY_4:
			return steerInitJoy(JOY4);
		case STEER_MODE_KEY_ARROWS:
			return steerInitKey(KEYMAP_ARROWS);
		case STEER_MODE_KEY_WSAD:
			return steerInitKey(KEYMAP_WSAD);
		case STEER_MODE_AI:
			return steerInitAi(ubPlayerIdx);
		default:
			return steerInitIdle();
	}
}

tSteer steerInitJoy(UBYTE ubJoy) {
	tSteer sSteer = {
		.cbProcess = onJoy,
		.ubJoy = ubJoy
	};
	return sSteer;
}

tSteer steerInitKey(tKeymap eKeymap) {
	tSteer sSteer = {
		.cbProcess = onKey,
		.eKeymap = eKeymap
	};
	return sSteer;
}

tSteer steerInitAi(UBYTE ubPlayerIdx) {
	tSteer sSteer = {
		.cbProcess = onAi
	};
	aiInit(&sSteer.sAi, ubPlayerIdx);
	return sSteer;
}

tSteer steerInitIdle(void) {
	tSteer sSteer = {
		.cbProcess = onIdle
	};
	return sSteer;
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
	UBYTE isArrows = (pSteer->cbProcess == onKey && pSteer->eKeymap == KEYMAP_ARROWS);
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

void steerResetAi(tSteer *pSteer) {
	if(pSteer->cbProcess == onAi) {
		aiInit(&pSteer->sAi, pSteer->sAi.ubPlayerIdx);
	}
}

const char *g_pSteerModeLabels[STEER_MODE_COUNT] = {
	"JOY 1", "JOY 2", "JOY 3", "JOY 4", "WSAD", "ARROWS", "CPU", "IDLE", "OFF"
};
