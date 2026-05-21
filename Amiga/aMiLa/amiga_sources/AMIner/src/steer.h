/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_STEER_H
#define INCLUDE_STEER_H

#include <ace/managers/joy.h> // for steerInitJoy() param
#include "direction.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum tSteerMode {
	STEER_MODE_JOY_1,
	STEER_MODE_JOY_2,
	STEER_MODE_KEY_WSAD,
	STEER_MODE_KEY_ARROWS,
	STEER_MODE_IDLE,
	STEER_MODE_OFF,
	STEER_MODE_COUNT,
} tSteerMode;

struct tSteer;

typedef void (*tCbSteerProcess)(struct tSteer *pSteer);

typedef enum tSteerDirState {
	STEER_DIR_STATE_INACTIVE,
	STEER_DIR_STATE_USED,
	STEER_DIR_STATE_ACTIVE,
} tSteerDirState;

typedef enum tSteerKeymap {
	STEER_KEYMAP_WSAD,
	STEER_KEYMAP_ARROWS
} tSteerKeymap;

typedef struct tSteer {
	tCbSteerProcess cbProcess;
	tSteerDirState pDirectionStates[DIRECTION_COUNT];
	union {
		UBYTE ubJoy; ///< for joy steer
		tSteerKeymap eKeymap; ///< for keyboard steer
	};
} tSteer;

tSteer steerInitFromMode(tSteerMode eMode);

void steerProcess(tSteer *pSteer);

UBYTE steerIsPlayer(const tSteer *pSteer);

UBYTE steerIsArrows(const tSteer *pSteer);

UBYTE steerDirCheck(const tSteer *pSteer, tDirection eDir);

UBYTE steerDirUse(tSteer *pSteer, tDirection eDir);

tDirection steerGetPressedDir(const tSteer *pSteer);

#ifdef __cplusplus
}
#endif

#endif // INCLUDE_STEER_H
