/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "page_office.h"
#include <comm/page_bribe.h>
#include <comm/page_accounting.h>
#include <comm/page_questioning.h>
#include <comm/page_market.h>
#include <comm/gs_shop.h>
#include <comm/inbox.h>
#include <comm/button.h>
#include "../save.h"
#include "../heat.h"

#define PPL_PER_ROW 4

typedef enum _tOfficeControls {
	OFFICE_CONTROLS_ACCEPT_DECLINE,
	OFFICE_CONTROLS_OK,
} tOfficeControls;

//----------------------------------------------------------------- PRIVATE VARS

static tFaceId s_pActivePpl[FACE_ID_COUNT]; // Key: pos in office, val: ppl
static tCommShopPage s_pOfficePages[FACE_ID_COUNT][PAGE_OFFICE_SUBPAGES_PER_PERSON];
static BYTE s_bSelectionCurr;
static UBYTE s_ubUnlockedPplCount;

//------------------------------------------------------------------ PRIVATE FNS

static void officeDrawFaceAtPos(BYTE bPos) {
	const UBYTE ubSpaceX = (COMM_DISPLAY_WIDTH - 2*2 - PPL_PER_ROW * 32) / 3;
	const UBYTE ubSpaceY = 10;
	const tUwCoordYX sOrigin = commGetOriginDisplay();

	UWORD uwRelativeX = 2 + (bPos % PPL_PER_ROW) * (32 + ubSpaceX);
	UWORD uwRelativeY = 2 + (bPos / PPL_PER_ROW) * (32 + ubSpaceY);
	UWORD uwX = sOrigin.uwX + uwRelativeX;
	UWORD uwY = sOrigin.uwY + uwRelativeY;

	tBitMap *pBmDraw = commGetDisplayBuffer();
	blitRect(pBmDraw, uwX - 2, uwY - 2, 36, 36, COMM_DISPLAY_COLOR_BG);

	// Draw selection
	if(bPos == s_bSelectionCurr) {
		blitCopy(g_pCommBmSelection, 0, 0,  pBmDraw, uwX - 2, uwY - 2, 9, 9, MINTERM_COOKIE);
		blitCopy(g_pCommBmSelection, 0, 9,  pBmDraw, uwX + 7 - 2 + 36 - 16, uwY - 2, 9, 9, MINTERM_COOKIE);
		blitCopy(g_pCommBmSelection, 0, 18, pBmDraw, uwX - 2, uwY - 2 + 36 - 9, 9, 9, MINTERM_COOKIE);
		blitCopy(g_pCommBmSelection, 0, 27, pBmDraw, uwX + 7 - 2 + 36 - 16, uwY - 2 + 36 - 9, 9, 9, MINTERM_COOKIE);
	}

	commDrawFaceAt(s_pActivePpl[bPos], uwRelativeX, uwRelativeY);
}

static UBYTE pageOfficeIsSelectionOnButton(UBYTE ubSelection) {
	return ubSelection == s_ubUnlockedPplCount;
}

static UBYTE pageOfficeIsSelectionOnPortrait(UBYTE ubSelection) {
	return ubSelection < s_ubUnlockedPplCount;
}

static void pageOfficeProcess(void) {
	BYTE bOldSelection = s_bSelectionCurr;

	if(commNavUse(DIRECTION_LEFT)) {
		if(!pageOfficeIsSelectionOnButton(s_bSelectionCurr)) {
			if(s_bSelectionCurr) {
				--s_bSelectionCurr;
			}
		}
	}
	else if(commNavUse(DIRECTION_RIGHT)) {
		if(!pageOfficeIsSelectionOnButton(s_bSelectionCurr)) {
			if(s_bSelectionCurr + 1 < s_ubUnlockedPplCount) {
				++s_bSelectionCurr;
			}
		}
	}
	else if(commNavUse(DIRECTION_DOWN)) {
		if(pageOfficeIsSelectionOnButton(s_bSelectionCurr)) {
			++s_bSelectionCurr;
			if(s_bSelectionCurr > s_ubUnlockedPplCount + 1) {
				s_bSelectionCurr = s_ubUnlockedPplCount + 1;
			}
		}
		else if(pageOfficeIsSelectionOnPortrait(s_bSelectionCurr)) {
			s_bSelectionCurr += PPL_PER_ROW;
			if(s_bSelectionCurr > s_ubUnlockedPplCount) {
				// don't teleport selection from portrait to nav
				s_bSelectionCurr = s_ubUnlockedPplCount;
			}
		}
	}
	else if(
		commNavUse(DIRECTION_UP) ||
		commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_DISABLING
	){
		if(!pageOfficeIsSelectionOnPortrait(s_bSelectionCurr)) {
			--s_bSelectionCurr;
		}
		else {
			s_bSelectionCurr -= PPL_PER_ROW;
			if(s_bSelectionCurr < 0) {
				s_bSelectionCurr = 0;
			}
		}
	}


	if(s_bSelectionCurr != bOldSelection) {
		if(pageOfficeIsSelectionOnButton(bOldSelection)) {
			buttonDeselectAll();
			buttonDrawAll(commGetDisplayBuffer());
		}
		else if(pageOfficeIsSelectionOnPortrait(bOldSelection)) {
			officeDrawFaceAtPos(bOldSelection);
		}

		if(pageOfficeIsSelectionOnButton(s_bSelectionCurr)) {
			buttonSelect(0);
			buttonDrawAll(commGetDisplayBuffer());
		}
		else if(pageOfficeIsSelectionOnPortrait(s_bSelectionCurr)) {
			officeDrawFaceAtPos(s_bSelectionCurr);
		}
		else if(s_bSelectionCurr == s_ubUnlockedPplCount + 1) {
			commShopFocusOnTabNavigation();
		}
	}

	if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
		if(pageOfficeIsSelectionOnButton(s_bSelectionCurr)) {
			commRegisterPage(0, 0);
			return;
		}
		else if(pageOfficeIsSelectionOnPortrait(s_bSelectionCurr)) {
			commShopChangePage(
				COMM_SHOP_PAGE_OFFICE_MAIN,
				COMM_SHOP_PAGE_OFFICE_LIST_MIETEK + s_pActivePpl[s_bSelectionCurr] - FACE_ID_MIETEK
			);
		}
	}
}

//------------------------------------------------------------------- PUBLIC FNS

void pageOfficeResetSelection(void) {
	s_bSelectionCurr = 0;
}

void pageOfficeShow(void) {
	if(commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_ENABLED) {
		s_bSelectionCurr = s_ubUnlockedPplCount + 1;
	}
	else if(s_bSelectionCurr == s_ubUnlockedPplCount + 1) {
		// was on nav, moved to other page with non-nav
		pageOfficeResetSelection();
	}

	commRegisterPage(pageOfficeProcess, 0);
	for(tFaceId i = 0; i < s_ubUnlockedPplCount; ++i) {
		officeDrawFaceAtPos(i);
	}

	buttonInitOk(g_pMsgs[MSG_COMM_EXIT]);
	if(pageOfficeIsSelectionOnButton(s_bSelectionCurr)) {
		buttonSelect(0);
	}
	else {
		buttonDeselectAll();
	}
	buttonDrawAll(commGetDisplayBuffer());
}

void pageOfficeReset(void) {
	// Make all ppl locked
	for(tFaceId ePos = 0; ePos < FACE_ID_COUNT; ++ePos) {
		s_pActivePpl[ePos] = FACE_ID_COUNT;
	}
	s_ubUnlockedPplCount = 0;

	// Lock all dialogue options
	for(tFaceId ePerson = 0; ePerson < FACE_ID_COUNT; ++ePerson) {
		s_pOfficePages[ePerson][0] = COMM_SHOP_PAGE_OFFICE_MAIN; // Serves as list terminator
	}

	// Unlock select characters
	pageOfficeUnlockPerson(FACE_ID_MIETEK);
	pageOfficeUnlockPerson(FACE_ID_KRYSTYNA);

	// Unlock select pages
	pageOfficeTryUnlockPersonSubpage(FACE_ID_KRYSTYNA, COMM_SHOP_PAGE_OFFICE_KRYSTYNA_DOSSIER);
	pageOfficeTryUnlockPersonSubpage(FACE_ID_KRYSTYNA, COMM_SHOP_PAGE_OFFICE_KRYSTYNA_ACCOUNTING);

	// Reset counters
	pageBribeReset();
	pageAccountingReset();
	pageQuestioningReset();
	pageMarketReset();
}

void pageOfficeSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_OFFICE);
	fileWrite(pFile, s_pActivePpl, sizeof(s_pActivePpl[0]) * FACE_ID_COUNT);
	fileWrite(pFile, s_pOfficePages, sizeof(s_pOfficePages[0][0]) * FACE_ID_COUNT * PAGE_OFFICE_SUBPAGES_PER_PERSON);
	fileWrite(pFile, &s_bSelectionCurr, sizeof(s_bSelectionCurr));
	fileWrite(pFile, &s_ubUnlockedPplCount, sizeof(s_ubUnlockedPplCount));
	pageBribeSave(pFile);
	pageAccountingSave(pFile);
	pageQuestioningSave(pFile);
	pageMarketSave(pFile);
	saveWriteTag(pFile, SAVE_TAG_OFFICE_END);
}

UBYTE pageOfficeLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_OFFICE)) {
		return 0;
	}

	fileRead(pFile, s_pActivePpl, sizeof(s_pActivePpl[0]) * FACE_ID_COUNT);
	fileRead(pFile, s_pOfficePages, sizeof(s_pOfficePages[0][0]) * FACE_ID_COUNT * PAGE_OFFICE_SUBPAGES_PER_PERSON);
	fileRead(pFile, &s_bSelectionCurr, sizeof(s_bSelectionCurr));
	fileRead(pFile, &s_ubUnlockedPplCount, sizeof(s_ubUnlockedPplCount));
	return pageBribeLoad(pFile) &&
		pageAccountingLoad(pFile) &&
		pageQuestioningLoad(pFile) &&
		pageMarketLoad(pFile) &&
		saveReadTag(pFile, SAVE_TAG_OFFICE_END);
}

__attribute__((optimize("Os")))
void pageOfficeUnlockPerson(tFaceId ePerson) {
	for(UBYTE i = 0; i < s_ubUnlockedPplCount; ++i) {
		if(s_pActivePpl[i] == ePerson) {
			// Already unlocked
			return;
		}
	}
	s_pActivePpl[s_ubUnlockedPplCount++] = ePerson;
}

__attribute__((optimize("Os")))
void pageOfficeLockPerson(tFaceId ePerson) {
	for(UBYTE i = 0; i < s_ubUnlockedPplCount; ++i) {
		if(s_pActivePpl[i] == ePerson) {
			while(++i < s_ubUnlockedPplCount) {
				s_pActivePpl[i - 1] = s_pActivePpl[i];
			}
			--s_ubUnlockedPplCount;
			break;
		}
	}
}

__attribute__((optimize("Os")))
UBYTE pageOfficeHasPerson(tFaceId ePerson) {
	for(UBYTE i = 0; i < s_ubUnlockedPplCount; ++i) {
		if(s_pActivePpl[i] == ePerson) {
			return 1;
		}
	}
	return 0;
}

__attribute__((optimize("Os")))
void pageOfficeLockPersonSubpage(tFaceId ePerson, tCommShopPage eSubpage) {
	for(UBYTE i = 0; i < PAGE_OFFICE_SUBPAGES_PER_PERSON - 1; ++i) {
		if(s_pOfficePages[ePerson][i] == eSubpage) {
			do {
				++i;
				s_pOfficePages[ePerson][i - 1] = s_pOfficePages[ePerson][i];
			} while(s_pOfficePages[ePerson][i] != COMM_SHOP_PAGE_OFFICE_MAIN);
			break;
		}
	}
}

__attribute__((optimize("Os")))
UBYTE pageOfficeTryUnlockPersonSubpage(tFaceId ePerson, tCommShopPage eSubpage) {
	for(UBYTE i = 0; i < PAGE_OFFICE_SUBPAGES_PER_PERSON - 1; ++i) {
		if(s_pOfficePages[ePerson][i] == eSubpage) {
			// Already unlocked
			return 0;
		}
		if(s_pOfficePages[ePerson][i] == COMM_SHOP_PAGE_OFFICE_MAIN) {
			s_pOfficePages[ePerson][i] = eSubpage;
			s_pOfficePages[ePerson][i + 1] = COMM_SHOP_PAGE_OFFICE_MAIN;
			return 1;
		}
	}

	logWrite(
		"ERR: Can't add subpage %d to person %d - no more space\n",
		eSubpage, ePerson
	);
	return 0;
}

const tCommShopPage *officeGetPagesForFace(tFaceId eFace) {
	return s_pOfficePages[eFace];
}
