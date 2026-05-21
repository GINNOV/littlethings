/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "background.h"
#include <ace/managers/blit.h>

void guiBackgroundClear(
	const tGuiBackground *pBg, tBitMap *pDest,
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight
) {
	if(pBg->pBm) {
		// Fill background with bg
		blitCopy(
			pBg->pBm, uwX, uwY, pDest, uwX, uwY,
			uwWidth, uwHeight, MINTERM_COOKIE
		);
	}
	else {
		// Fill background with color
		blitRect(pDest, uwX, uwY, uwWidth, uwHeight, pBg->ubColorIdx);
	}
}
