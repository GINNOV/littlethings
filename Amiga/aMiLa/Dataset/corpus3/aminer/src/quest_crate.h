/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef QUEST_CRATE_H
#define QUEST_CRATE_H

#include <ace/utils/file.h>

#define QUEST_CRATE_MIN_SELLS_FOR_ESCAPE 5

typedef enum tCapsuleState {
	CAPSULE_STATE_NOT_FOUND,
	CAPSULE_STATE_FOUND,
	CAPSULE_STATE_OPENED,
} tCapsuleState;

void questCrateReset(void);

UBYTE questCrateGetCratesSold(void);

void questCrateSave(tFile *pFile);

UBYTE questCrateLoad(tFile *pFile);

void questCrateProcess(void);

void questCrateAdd(void);

UBYTE questCrateGetCount(void);

UBYTE questCrateTryConsume(UBYTE ubAmount);

UBYTE questCrateTrySell(void);

void questCrateSetCapsuleState(tCapsuleState eNewState);

tCapsuleState questCrateGetCapsuleState(void);

void questCrateProcessBase(void);

#endif // QUEST_CRATE_H
