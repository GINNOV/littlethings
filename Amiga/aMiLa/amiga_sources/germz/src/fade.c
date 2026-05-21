/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "fade.h"
#include <ace/utils/palette.h>
#include <ace/managers/ptplayer.h>

tFade *fadeCreate(tView *pView, const UWORD *pPaletteRef, UBYTE ubColorCount) {
	logBlockBegin(
		"fadeCreate(pView: %p, pPaletteRef: %p, ubColorCount: %hhu)",
		pView, pPaletteRef, ubColorCount
	);
	tFade *pFade = memAllocFastClear(sizeof(*pFade));
	pFade->eState = FADE_STATE_IDLE;
	pFade->pView = pView;
	fadeChangeRefPalette(pFade, pPaletteRef, ubColorCount);
	logBlockEnd("fadeCreate()");
	return pFade;
}

void fadeDestroy(tFade *pFade) {
	memFree(pFade, sizeof(*pFade));
}

void fadeSet(
	tFade *pFade, tFadeState eState, UBYTE ubFramesToFullFade, UBYTE isMusic,
	tCbFadeOnDone cbOnDone
) {
	logBlockBegin(
		"fadeSet(pFade: %p, eState: %d, ubFramesToFullFade: %hhu, cbOnDone: %p)",
		pFade, eState, ubFramesToFullFade, cbOnDone
	);
	pFade->eState = eState;
	pFade->ubCnt = 0;
	pFade->ubCntEnd = ubFramesToFullFade;
	pFade->cbOnDone = cbOnDone;
	pFade->isMusic = isMusic;
	logBlockEnd("fadeSet()");
}

tFadeState fadeProcess(tFade *pFade) {
	tFadeState eState = pFade->eState;
	if(pFade->eState != FADE_STATE_IDLE && pFade->eState != FADE_STATE_EVENT_FIRED) {
		++pFade->ubCnt;

		UBYTE ubCnt = pFade->ubCnt;
		if(pFade->eState == FADE_STATE_OUT) {
			ubCnt = pFade->ubCntEnd - pFade->ubCnt;
		}

		UBYTE ubRatio = (15 * ubCnt) / pFade->ubCntEnd;
		paletteDim(
			pFade->pPaletteRef, pFade->pView->pFirstVPort->pPalette,
			pFade->ubColorCount, ubRatio
		);
		viewUpdateCLUT(pFade->pView);

		if(pFade->isMusic) {
			UBYTE ubVolume = (64 * ubCnt) / pFade->ubCntEnd;
			ptplayerSetMasterVolume(ubVolume);
		}

		if(pFade->ubCnt >= pFade->ubCntEnd) {
			pFade->eState = FADE_STATE_EVENT_FIRED;
			// Save state for return incase fade object gets destroyed in fade cb
			eState = pFade->eState;
			if(pFade->cbOnDone) {
				pFade->cbOnDone();
			}
		}
	}
	else {
		pFade->eState = FADE_STATE_IDLE;
		eState = pFade->eState;
	}
	return eState;
}

void fadeChangeRefPalette(
	tFade *pFade, const UWORD *pPaletteRef, UBYTE ubColorCount
) {
	pFade->ubColorCount = ubColorCount;
	const UBYTE ubMaxColors = (
		sizeof(pFade->pPaletteRef) / sizeof(pFade->pPaletteRef[0])
	);
	if(ubColorCount > ubMaxColors) {
		logWrite(
			"ERR: Unsupported palette size: %hhu, max: %hhu",
			ubColorCount, ubMaxColors
		);
	}
	for(UBYTE i = 0; i < ubColorCount; ++i) {
		pFade->pPaletteRef[i] = pPaletteRef[i];
	}
}
