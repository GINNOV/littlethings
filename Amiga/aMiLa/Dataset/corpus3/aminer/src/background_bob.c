/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "background_bob.h"
#include "core.h"
#include "game.h"

void backgroundBobPush(tBackgroundBob *pBackgroundBob) {
	if(!gameCanPushBob(&pBackgroundBob->sBob)) {
		backgroundBobResetCounter(pBackgroundBob);
	}
	else if(pBackgroundBob->ubDrawCount < 2) {
		bobPush(&pBackgroundBob->sBob);
		coreTransferBobToPristine(&pBackgroundBob->sBob);
		++pBackgroundBob->ubDrawCount;
	}
}

void backgroundBobResetCounter(tBackgroundBob *pBackgroundBob) {
	pBackgroundBob->ubDrawCount = 0;
}
