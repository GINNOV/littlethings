/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "menu_list.h"

static UBYTE s_ubActiveOption;
static UBYTE s_ubOptionCount;
static tMenuListOption *s_pOptions;
static const char **s_pOptionCaptions;
static tFont *s_pFont;
static UWORD s_uwX, s_uwY;
static tCbMenuListUndraw s_cbUndraw;
static tCbMenuListDrawPos s_cbDrawPos;

void menuListInit(
	tMenuListOption *pOptions, const char **pOptionCaptions, UBYTE ubOptionCount,
	tFont *pFont, UWORD uwX, UWORD uwY, const tCbMenuListUndraw cbUndraw,
	const tCbMenuListDrawPos cbDrawPos
) {
	s_pOptions = pOptions;
	s_ubOptionCount = ubOptionCount;
	s_ubActiveOption = 0;
	s_pFont = pFont;
	s_pOptionCaptions = pOptionCaptions;
	s_uwX = uwX;
	s_uwY = uwY;
	s_cbUndraw = cbUndraw;
	s_cbDrawPos = cbDrawPos;

	for(UBYTE ubMenuPos = 0; ubMenuPos < ubOptionCount; ++ubMenuPos) {
		s_pOptions[ubMenuPos].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
	}
}

void menuListDraw(void) {
	for(UBYTE ubMenuPos = 0; ubMenuPos < s_ubOptionCount; ++ubMenuPos) {
		if(s_pOptions[ubMenuPos].eDirty) {
			menuListDrawPos(ubMenuPos);
			s_pOptions[ubMenuPos].eDirty = 0;
		}
	}
}

void menuListUndrawPos(UBYTE ubPos) {
	UWORD uwPosY = s_uwY + ubPos * (s_pFont->uwHeight + 1);
	if(s_cbUndraw) {
		s_cbUndraw(
			s_uwX, uwPosY, s_pOptions[ubPos].uwUndrawWidth, s_pFont->uwHeight
		);
	}
}

void menuListDrawPos(UBYTE ubPos) {
	UWORD uwPosY = s_uwY + ubPos * (s_pFont->uwHeight + 1);

	char szBfr[50];
	const char *szText = 0;
	const char *szCaption = s_pOptionCaptions[ubPos];
	tMenuListOption *pOption = &s_pOptions[ubPos];
	if(pOption->eOptionType == MENU_LIST_OPTION_TYPE_UINT8) {
		if(pOption->sOptUb.pEnumLabels) {
			sprintf(
				szBfr, "%s: %s", szCaption,
				pOption->sOptUb.pEnumLabels[*pOption->sOptUb.pVar]
			);
		}
		else {
			sprintf(szBfr, "%s: %hhu", szCaption, *pOption->sOptUb.pVar);
		}
		szText = szBfr;
	}
	else if(pOption->eOptionType == MENU_LIST_OPTION_TYPE_CALLBACK) {
		szText = szCaption;
	}
	if(pOption->eDirty == MENU_LIST_DIRTY_VAL_CHANGE && pOption->uwUndrawWidth) {
		menuListUndrawPos(ubPos);
	}
	if(!pOption->isHidden && szText != 0) {
		if(s_cbDrawPos) {
			UBYTE isActive = (ubPos == s_ubActiveOption);
			s_cbDrawPos(s_uwX, uwPosY, szCaption, szText, isActive, &pOption->uwUndrawWidth);
		}
		if(pOption->sOptUb.cbOnValDraw) {
			pOption->sOptUb.cbOnValDraw(ubPos);
		}
	}
}

UBYTE menuListNavigate(BYTE bDir) {
	WORD wNewPos = s_ubActiveOption;

	// Find next non-hidden pos
	do {
		wNewPos += bDir;
	} while(0 < wNewPos && wNewPos < (WORD)s_ubOptionCount && s_pOptions[wNewPos].isHidden);

	if(wNewPos < 0 || wNewPos >= (WORD)s_ubOptionCount) {
		// Out of bounds - cancel
		return 0;
	}

	// Update active pos and mark as dirty
	menuListSetActive(wNewPos);
	return 1;
}

UBYTE menuListToggle(BYTE bDelta) {
	if(s_pOptions[s_ubActiveOption].eOptionType == MENU_LIST_OPTION_TYPE_UINT8) {
		WORD wNewVal = *s_pOptions[s_ubActiveOption].sOptUb.pVar + bDelta;
		if(
			wNewVal < s_pOptions[s_ubActiveOption].sOptUb.ubMin ||
			wNewVal > s_pOptions[s_ubActiveOption].sOptUb.ubMax
		) {
			if(s_pOptions[s_ubActiveOption].sOptUb.isCyclic) {
				wNewVal = (
					wNewVal < s_pOptions[s_ubActiveOption].sOptUb.ubMin ?
					s_pOptions[s_ubActiveOption].sOptUb.ubMax :
					s_pOptions[s_ubActiveOption].sOptUb.ubMin
				);
			}
			else {
				return 0; // Out of bounds on non-cyclic option
			}
		}
		*s_pOptions[s_ubActiveOption].sOptUb.pVar = wNewVal;
		s_pOptions[s_ubActiveOption].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
		if(s_pOptions[s_ubActiveOption].sOptUb.cbOnValChange) {
			s_pOptions[s_ubActiveOption].sOptUb.cbOnValChange();
		}
		return 1;
	}
	return 0;
}

UBYTE menuListEnter(void) {
	if(
		s_pOptions[s_ubActiveOption].eOptionType == MENU_LIST_OPTION_TYPE_CALLBACK &&
		s_pOptions[s_ubActiveOption].sOptCb.cbSelect
	) {
		s_pOptions[s_ubActiveOption].sOptCb.cbSelect();
		return 1;
	}
	return 0;
}

void menuListHidePos(UBYTE ubPos, UBYTE isHidden) {
	UBYTE wasHidden = s_pOptions[ubPos].isHidden;
	s_pOptions[ubPos].isHidden = isHidden;
	if(wasHidden != isHidden) {
		s_pOptions[ubPos].eDirty = MENU_LIST_DIRTY_VAL_CHANGE;
	}
}

void menuListUndraw(void) {
	for(UBYTE i = 0; i < s_ubOptionCount; ++i) {
		menuListUndrawPos(i);
	}
}

UBYTE menuListGetActive(void) {
	return s_ubActiveOption;
}

void menuListSetActive(UBYTE ubNewPos) {
	s_pOptions[s_ubActiveOption].eDirty = MENU_LIST_DIRTY_SELECTION;
	s_pOptions[ubNewPos].eDirty = MENU_LIST_DIRTY_SELECTION;
	s_ubActiveOption = ubNewPos;
}
