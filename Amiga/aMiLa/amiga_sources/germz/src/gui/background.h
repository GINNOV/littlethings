/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GUI_BACKGROUND_H
#define GUI_BACKGROUND_H

#include <ace/utils/bitmap.h>

// I'm still not sure if this shouldn't be a callback to x,y,width,height drawing fn, defined individually for each case.

typedef struct tGuiBackground {
	const tBitMap *pBm;
	UBYTE ubColorIdx;
} tGuiBackground;

void guiBackgroundClear(
	const tGuiBackground *pBg, tBitMap *pDest,
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight
);

#endif // GUI_BACKGROUND_H
