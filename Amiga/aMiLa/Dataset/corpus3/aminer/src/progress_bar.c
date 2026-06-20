/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "progress_bar.h"
#include "blitter_mutex.h"
#include <ace/managers/blit.h>

static UBYTE s_ubPrevProgressPercent;

void progressBarInit(const tProgressBarConfig *pConfig, tBitMap *pBuffer) {
	s_ubPrevProgressPercent = 0;

	// X lines
	blitRect(
		pBuffer,
		pConfig->sBarPos.uwX - pConfig->ubBorderDistance,
		pConfig->sBarPos.uwY - pConfig->ubBorderDistance,
		pConfig->ubBorderDistance + pConfig->uwWidth + pConfig->ubBorderDistance,
		1,
		pConfig->ubColorBorder
	);
	blitRect(
		pBuffer,
		pConfig->sBarPos.uwX - pConfig->ubBorderDistance,
		pConfig->sBarPos.uwY + pConfig->uwHeight + pConfig->ubBorderDistance - 1,
		pConfig->ubBorderDistance + pConfig->uwWidth + pConfig->ubBorderDistance,
		1,
		pConfig->ubColorBorder
	);

	// Y lines
	blitRect(
		pBuffer,
		pConfig->sBarPos.uwX - pConfig->ubBorderDistance,
		pConfig->sBarPos.uwY - pConfig->ubBorderDistance,
		1,
		pConfig->ubBorderDistance + pConfig->uwHeight + pConfig->ubBorderDistance,
		pConfig->ubColorBorder
	);
	blitRect(
		pBuffer,
		pConfig->sBarPos.uwX + pConfig->uwWidth + pConfig->ubBorderDistance - 1,
		pConfig->sBarPos.uwY - pConfig->ubBorderDistance,
		1,
		pConfig->ubBorderDistance + pConfig->uwHeight + pConfig->ubBorderDistance,
		pConfig->ubColorBorder
	);

}

void progressBarAdvance(
	const tProgressBarConfig *pConfig, tBitMap *pBuffer, UBYTE ubProgressPercent
) {
	if(ubProgressPercent < s_ubPrevProgressPercent) {
		logWrite("ERR: progress goes backwards");
	}
	else if(ubProgressPercent != s_ubPrevProgressPercent) {
		// Fill
		UWORD uwPrevPosX = (pConfig->uwWidth * s_ubPrevProgressPercent) / 100;
		UWORD uwNewPosX = (pConfig->uwWidth * ubProgressPercent) / 100;
		blitterMutexLock();
		blitRect(
			pBuffer, pConfig->sBarPos.uwX + uwPrevPosX, pConfig->sBarPos.uwY,
			uwNewPosX - uwPrevPosX, pConfig->uwHeight, pConfig->ubColorBar
		);
		blitterMutexUnlock();

		s_ubPrevProgressPercent = ubProgressPercent;
	}
}
