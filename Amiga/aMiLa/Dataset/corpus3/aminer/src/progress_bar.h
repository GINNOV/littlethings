/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef PROGRESS_BAR_H
#define PROGRESS_BAR_H

#include <ace/utils/bitmap.h>

typedef struct tProgressBarConfig {
	tUwCoordYX sBarPos;
	UWORD uwWidth;
	UWORD uwHeight;
	UBYTE ubBorderDistance;
	UBYTE ubColorBorder;
	UBYTE ubColorBar;
} tProgressBarConfig;

void progressBarInit(const tProgressBarConfig *pConfig, tBitMap *pBuffer);

void progressBarAdvance(
	const tProgressBarConfig *pConfig, tBitMap *pBuffer, UBYTE ubProgressPercent
);

#endif // PROGRESS_BAR_H

