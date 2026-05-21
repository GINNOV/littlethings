/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "button.h"
#include "border.h"
#include "config.h"
#include <ace/managers/log.h>

static UBYTE s_ubButtonCount;
static UBYTE s_ubMaxButtonCount;
static tGuiButton *s_pSelected = 0;
static tGuiButton *s_pButtons;
static tGuiBtnOnDraw s_cbOnDraw;

// TODO: move font / textBfr to config?
// TODO: when moved to C++, pass font and textBfr as shared_ptr

void buttonListCreate(UBYTE ubButtonCount, const tGuiBtnOnDraw cbOnDraw) {
	logBlockBegin(
		"buttonListCreate(ubButtonCount: %hhu, cbOnDraw: %p)",
		ubButtonCount, cbOnDraw
	);
	s_ubButtonCount = 0;
	s_ubMaxButtonCount = ubButtonCount;
	s_pSelected = 0;
	s_cbOnDraw = cbOnDraw;
	s_pButtons = memAllocFastClear(s_ubMaxButtonCount * sizeof(tGuiButton));
	logBlockEnd("buttonListCreate()");
}

void buttonListDestroy(void) {
	logBlockBegin("buttonListDestroy()");
	memFree(s_pButtons, s_ubMaxButtonCount * sizeof(tGuiButton));
	s_ubButtonCount = 0;
	s_ubMaxButtonCount = 0;
	logBlockEnd("buttonListDestroy()");
}

tGuiButton *buttonAdd(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	const char *szText, tGuiBtnOnClick cbOnClick, void *pData
) {
	// Count check
	if(s_ubButtonCount >= s_ubMaxButtonCount) {
		return 0;
	}
	// Sanity check
	if(strlen(szText) >= BUTTON_MAX_TEXT) {
		return 0;
	}

	// Fill fields
	tGuiButton *pButton = &s_pButtons[s_ubButtonCount];
	pButton->sRect.uwX = uwX;
	pButton->sRect.uwY = uwY;
	pButton->sRect.uwWidth = uwWidth;
	pButton->sRect.uwHeight = uwHeight;
	strcpy(pButton->szText, szText);
	pButton->onClick = cbOnClick;
	pButton->pData = pData;

	++s_ubButtonCount;
	return pButton;
}

void buttonDrawAll(void) {
	if(s_cbOnDraw) {
		for(UBYTE i = 0; i < s_ubButtonCount; ++i) {
			s_cbOnDraw(&s_pButtons[i]);
		}
	}
}

UBYTE buttonListProcessMouseClick(UWORD uwX, UWORD uwY) {
	for(UBYTE i = 0; i < s_ubButtonCount; ++i) {
		const tGuiButton *pButton = &s_pButtons[i];
		if(inRect(uwX, uwY, pButton->sRect)) {
			buttonClick(pButton);
			return 1;
		}
	}
	return 0;
}

void buttonClick(const tGuiButton *pButton) {
	if(pButton->onClick) {
		pButton->onClick(pButton->pData);
	}
}

void buttonSelect(tGuiButton *pButton) {
	s_pSelected = pButton;
}

tGuiButton *buttonGetSelected(void) {
	return s_pSelected;
}

void buttonSelectNext(void) {
	tGuiButton *pNext = s_pSelected + 1;
	if(pNext != &s_pButtons[s_ubButtonCount]) {
		s_pSelected = pNext;
	}
}

void buttonSelectPrev(void) {
	if(s_pSelected != &s_pButtons[0]) {
		--s_pSelected;
	}
}

UBYTE buttonIsSelected(const tGuiButton *pButton) {
	UBYTE isSelected = (pButton == s_pSelected);
	return isSelected;
}
