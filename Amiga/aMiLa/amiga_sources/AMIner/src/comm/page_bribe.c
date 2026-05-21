/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <comm/comm.h>
#include <comm/page_office.h>
#include <comm/button.h>
#include "../warehouse.h"
#include "../game.h"
#include "../core.h"
#include "../vehicle.h"
#include "../save.h"
#include "../heat.h"
#include "page_bribe.h"

static UWORD s_uwBribeCount;
static UWORD s_uwBribeCost;

static void pageBribeProcess(void) {
	if(buttonGetPreset() == BUTTON_PRESET_ACCEPT_DECLINE) {
		BYTE bButtonPrev = buttonGetSelected(), bButtonCurr = bButtonPrev;
		BYTE bButtonCount = buttonGetCount();
		if(commNavUse(DIRECTION_RIGHT)) {
			bButtonCurr = MIN(bButtonCurr + 1, bButtonCount - 1);
		}
		else if(commNavUse(DIRECTION_LEFT)) {
			bButtonCurr = MAX(bButtonCurr - 1, 0);
		}
		if(bButtonPrev != bButtonCurr) {
			buttonSelect(bButtonCurr);
			buttonDrawAll(commGetDisplayBuffer());
		}

		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			if(planManagerGet()->isPlanActive) {
				if(bButtonCurr == 0 && vehicleTrySpendCash(0, s_uwBribeCost)) {
					if(randUwMinMax(&g_sRand, 1, 100) > heatGetPercent()) {
						// Success
						heatTryIncrease(5);
						++s_uwBribeCount;
						planAddDays(14, 1);
					}
					else {
						gameAddRebuke(REBUKE_BRIBE);
					}
				}
			}
			commShopGoBack();
		}
	}
	else {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			commShopGoBack();
		}
	}
}

void pageBribeCreate(void) {
	commRegisterPage(pageBribeProcess, 0);
	const UBYTE ubLineHeight = commGetLineHeight();
	UWORD uwPosY = 0;

	s_uwBribeCost = 100;
	for(UBYTE i = s_uwBribeCount; i--;) {
		s_uwBribeCost = (s_uwBribeCost * 150 / 100);
	}

	if (!planManagerGet()->isPlanActive) {
		uwPosY += commDrawMultilineText(
			g_pMsgs[MSG_TRICKS_NO_PLAN], 0, uwPosY
		) * ubLineHeight;
		buttonInitOk(g_pMsgs[MSG_PAGE_BACK]);
	}
	else if(planManagerGet()->isExtendedTimeByBribe) {
		uwPosY += commDrawMultilineText(g_pMsgs[MSG_TRICKS_BRIBE_USED], 0, uwPosY) * ubLineHeight;
		buttonInitOk(g_pMsgs[MSG_PAGE_BACK]);
	}
	else {
		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_TRICKS_BRIBE_PREMISE], 14);
		uwPosY += commDrawMultilineText(gameGetMessageBuffer(), 0, uwPosY) * ubLineHeight;
		uwPosY += ubLineHeight / 2;
		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_TRICKS_BRIBE_DETAILS], heatGetPercent());
		uwPosY += commDrawMultilineText(gameGetMessageBuffer(), 0, uwPosY) * ubLineHeight;
		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_TRICKS_BRIBE_PRICE], s_uwBribeCost, '\x1F');
		uwPosY += commDrawMultilineText(gameGetMessageBuffer(), 0, uwPosY) * ubLineHeight;

		if(g_pVehicles[0].lCash < s_uwBribeCost) {
			uwPosY += ubLineHeight;
			uwPosY += commDrawMultilineText(g_pMsgs[MSG_TRICKS_BRIBE_NO_CASH], 0, uwPosY) * ubLineHeight;
			buttonInitOk(g_pMsgs[MSG_PAGE_BACK]);
		}
		else {
			buttonInitAcceptDecline(g_pMsgs[MSG_COMM_ACCEPT], g_pMsgs[MSG_PAGE_BACK]);
		}
	}

	buttonDrawAll(commGetDisplayBuffer());
}

void pageBribeReset(void) {
	s_uwBribeCount = 0;
}

void pageBribeSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_BRIBE);
	fileWrite(pFile, &s_uwBribeCount, sizeof(s_uwBribeCount));
	saveWriteTag(pFile, SAVE_TAG_BRIBE_END);
}

UBYTE pageBribeLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_BRIBE)) {
		return 0;
	}

	fileRead(pFile, &s_uwBribeCount, sizeof(s_uwBribeCount));
	return saveReadTag(pFile, SAVE_TAG_BRIBE_END);
}

UBYTE pageBribeGetCount(void) {
	return s_uwBribeCount;
}
