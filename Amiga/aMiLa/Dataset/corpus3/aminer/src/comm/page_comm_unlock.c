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
#include "../inventory.h"


static tCommUnlockState s_eTargetState;
static tCommShopPage s_eTargetPage;
static UWORD s_uwCost;

static void pageCommUnlockProcess(void) {
	BYTE bButtonPrev = buttonGetSelected(), bButtonCurr = bButtonPrev;
	BYTE bButtonCount = buttonGetCount();

	if(commNavUse(DIRECTION_UP) || commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_DISABLING) {
		buttonSelect(0);
		buttonDrawAll(commGetDisplayBuffer());
	}
	if(commNavUse(DIRECTION_DOWN) && commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_DISABLED) {
		commShopFocusOnTabNavigation();
		buttonDeselectAll();
		buttonDrawAll(commGetDisplayBuffer());
	}

	if(commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_DISABLED) {
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
			if(buttonGetCount() == 2) {
				if(buttonGetSelected() == 0) {
					if(vehicleTrySpendCash(0, s_uwCost)) {
						inventorySetCommUnlock(baseGetCurrentId(), s_eTargetState);
						commShopChangePage(s_eTargetPage, s_eTargetPage);
					}
				}
				else {
					commRegisterPage(0, 0);
				}
			}
			else {
				if(buttonGetSelected() == 0) {
					commRegisterPage(0, 0);
				}
			}
		}
	}
}

void pageCommUnlockCreate(
	tCommUnlockState eTargetState, tCommShopPage eTargetPage,
	const char *szMsg, UWORD uwCost
) {
	s_eTargetState = eTargetState;
	s_eTargetPage = eTargetPage;
	s_uwCost = uwCost;

	commRegisterPage(pageCommUnlockProcess, 0);

	const UBYTE ubLineHeight = commGetLineHeight();
	UWORD uwPosY = 0;

	uwPosY += commDrawMultilineText(szMsg, 0, uwPosY) * ubLineHeight;
	uwPosY += ubLineHeight;

	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s: %hu\x1F", g_pMsgs[MSG_COMM_PRICE], s_uwCost);
	commDrawText(0, uwPosY, gameGetMessageBuffer(), FONT_COOKIE, COMM_DISPLAY_COLOR_TEXT);
	uwPosY += ubLineHeight;

	if(g_pVehicles[0].lCash >= uwCost) {
		buttonInitAcceptDecline(g_pMsgs[MSG_COMM_BUY], g_pMsgs[MSG_COMM_EXIT]);
	}
	else {
		buttonInitOk(g_pMsgs[MSG_COMM_EXIT]);
	}

	if(commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_ENABLED) {
		buttonDeselectAll();
	}

	buttonDrawAll(commGetDisplayBuffer());
}
