/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _BLITTER_MUTEX_H_
#define _BLITTER_MUTEX_H_

#include <ace/types.h>

void blitterMutexReset(void);

UBYTE blitterMutexTryLock(void);

void blitterMutexLock(void);

void blitterMutexUnlock(void);

#endif // _BLITTER_MUTEX_H_
