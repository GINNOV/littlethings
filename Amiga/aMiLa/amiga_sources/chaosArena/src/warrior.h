/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_WARRIOR_H
#define INCLUDE_WARRIOR_H

#include <ace/managers/bob.h>
#include "steer.h"
#include "anim.h"

#define WARRIOR_LAST_ALIVE_INDEX_INVALID 255

typedef struct tWarrior {
	tUwCoordYX sPos;
	tBob sBob;
	UBYTE ubAnimFrame;
	UBYTE ubFrameCooldown;
	UBYTE ubStunCooldown;
	UBYTE isDead;
	UBYTE ubIndex;
	tAnim eAnim;
	tAnimDirection eDirection;
	tSteer sSteer;
	tBCoordYX sPushDelta;
} tWarrior;

extern const tBCoordYX g_pAnimDirToPushDelta[ANIM_DIRECTION_COUNT];

void warriorsCreate(UBYTE isExtraEnemiesEnabled);

void warriorsProcess(void);

void warriorsDestroy(void);

void warriorsDrawLookup(tBitMap *pBuffer);

UBYTE warriorsGetAliveCount(void);

UBYTE warriorsGetAlivePlayerCount(void);

// number is zero-based
UBYTE warriorsGetLastAliveIndex(void);

void warriorsEnableMove(UBYTE isEnabled);

void warriorAttackWithLightning(tUwCoordYX sAttackPos);

tWarrior *warriorGetStrikeTarget(
	const tWarrior *pWarrior, tAnimDirection eDirection
);

#endif // INCLUDE_WARRIOR_H
