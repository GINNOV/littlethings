/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "mode_menu.h"
#include <ace/utils/bitmap.h>
#include "vehicle.h"
#include "mode_menu.h"
#include "game.h"
#include "assets.h"

#define MODE_ICON_WIDTH 16
#define MODE_ICON_HEIGHT 12
#define MODE_ICON_MARGIN 4

typedef enum tModeMask {
	MODE_MASK_MULTI,
	MODE_MASK_SINGLE,
	MODE_MASK_COUNT,
} tModeMask;

//----------------------------------------------------------------- PRIVATE VARS

static tBitMap *s_pModeIcons;
static tBitMap *s_pModeIconMask;
static UBYTE *s_pModeIconOffsets[MODE_OPTION_COUNT];
static UBYTE *s_pModeMaskOffsets[MODE_OPTION_COUNT];

//------------------------------------------------------------------ PRIVATE FNS

//------------------------------------------------------------------- PUBLIC FNS

void modeMenuManagerCreate(void) {
	s_pModeIcons = bitmapCreateFromFd(GET_SUBFILE_PREFIX("mode_icons.bm"), 0);
	s_pModeIconMask = bitmapCreateFromFd(GET_SUBFILE_PREFIX("mode_icon_mask.bm"), 0);

	for(tModeOption eOption = 0; eOption < MODE_OPTION_COUNT; ++eOption) {
		s_pModeIconOffsets[eOption] = bobCalcFrameAddress(s_pModeIcons, eOption * MODE_ICON_HEIGHT);
	}

	for(tModeMask eMask = 0; eMask < MODE_MASK_COUNT; ++eMask) {
		s_pModeMaskOffsets[eMask] = bobCalcFrameAddress(s_pModeIconMask, eMask * MODE_ICON_HEIGHT);
	}
}

void modeMenuInitBob(tModeMenu *pModeMenu) {
	bobInit(
		&pModeMenu->sBob,
		MODE_ICON_WIDTH, MODE_ICON_HEIGHT,
		1, 0, s_pModeIconMask->Planes[0], 0, 0
	);
}

void modeMenuManagerDestroy(void) {
	bitmapDestroy(s_pModeIcons);
	bitmapDestroy(s_pModeIconMask);
}

void modeMenuReset(tModeMenu *pModeMenu, UBYTE ubPlayerIndex) {
	modeMenuClearOptions(pModeMenu);
	modeMenuAddOption(pModeMenu, MODE_OPTION_DRILL);
	pModeMenu->ubCurrent = 0;
	pModeMenu->isActive = 0;
	pModeMenu->ubPlayerIndex = ubPlayerIndex;
}

void modeMenuClearOptions(tModeMenu *pModeMenu) {
	pModeMenu->ubCount = 0;
	pModeMenu->ubCurrent = 0;
}

void modeMenuAddOption(tModeMenu *pModeMenu, tModeOption eOption) {
	UBYTE ubIndex = pModeMenu->ubCount;
	pModeMenu->pModeOptions[ubIndex] = eOption;
	pModeMenu->ubCount = ubIndex + 1;
}

void modeMenuProcess(tModeMenu *pModeMenu, tDirection eDirection) {
	if(eDirection == DIRECTION_LEFT) {
		if(pModeMenu->ubCurrent) {
			--pModeMenu->ubCurrent;
		}
		else {
			pModeMenu->ubCurrent = pModeMenu->ubCount - 1;
		}
	}
	else if(eDirection == DIRECTION_RIGHT) {
		++pModeMenu->ubCurrent;
		if(pModeMenu->ubCurrent >= pModeMenu->ubCount) {
			pModeMenu->ubCurrent = 0;
		}
	}
	else {
		return;
	}

	pModeMenu->sBob.pFrameData = s_pModeIconOffsets[modeMenuGetSelected(pModeMenu)];
}

void modeMenuShow(tModeMenu *pModeMenu) {
	pModeMenu->isActive = 1;
	pModeMenu->sBob.pFrameData = s_pModeIconOffsets[modeMenuGetSelected(pModeMenu)];
	pModeMenu->sBob.pMaskData = s_pModeMaskOffsets[pModeMenu->ubCount == 1];
}

tModeOption modeMenuHide(tModeMenu *pModeMenu) {
	pModeMenu->isActive = 0;
	return modeMenuGetSelected(pModeMenu);
}

tModeOption modeMenuGetSelected(tModeMenu *pModeMenu) {
	return pModeMenu->pModeOptions[pModeMenu->ubCurrent];
}

void modeMenuTryDisplay(tModeMenu *pModeMenu) {
	if(!pModeMenu->isActive) {
		return;
	}

	const tVehicle *pVehicle = &g_pVehicles[pModeMenu->ubPlayerIndex];
	pModeMenu->sBob.sPos.uwX = pVehicle->sBobBody.sPos.uwX + (VEHICLE_WIDTH - MODE_ICON_WIDTH) / 2;
	pModeMenu->sBob.sPos.uwY = pVehicle->sBobBody.sPos.uwY - (MODE_ICON_HEIGHT + MODE_ICON_MARGIN);
	gameTryPushBob(&pModeMenu->sBob);
}
