/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef BACKGROUND_BOB_H
#define BACKGROUND_BOB_H

#include <ace/managers/bob.h>

typedef struct tBackgroundBob {
	tBob sBob;
	UBYTE ubDrawCount;
} tBackgroundBob;

/**
 * @brief Tries to draw the bob on the background. Also transfers to pristine buffer.
 *
 * @param pBackgroundBob Bob to display.
 */
void backgroundBobPush(tBackgroundBob *pBackgroundBob);

/**
 * @brief Resets draw counter of the backround bob.
 * Call this when changing bob's anim frame or position.
 *
 * @param pBackgroundBob Bob to have its counter reset.
 */
void backgroundBobResetCounter(tBackgroundBob *pBackgroundBob);

#endif // BACKGROUND_BOB_H
