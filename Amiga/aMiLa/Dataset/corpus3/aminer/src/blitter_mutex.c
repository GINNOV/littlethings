/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "blitter_mutex.h"

static volatile UBYTE s_isBlitterLocked;

void blitterMutexReset(void) {
	s_isBlitterLocked = 0;
}

UBYTE blitterMutexTryLock(void) {
	if(!s_isBlitterLocked) {
		s_isBlitterLocked = 1;
		return 1;
	}
	return 0;
}

void blitterMutexLock(void) {
	while(!blitterMutexTryLock()) continue;
}

void blitterMutexUnlock(void) {
	s_isBlitterLocked = 0;
}
