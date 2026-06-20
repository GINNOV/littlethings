/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <comm/page_escape.h>
#include <comm/page_office.h>
#include <comm/button.h>
#include "../vehicle.h"
#include "../quest_crate.h"
#include "../hud.h"
#include "../heat.h"
#include "../protests.h"

static tPageEscapeScenario s_eScenario;

static void pageEscapeProcess(void) {
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
		if(bButtonCurr == 0) {
			switch(s_eScenario) {
				case PAGE_ESCAPE_SCENARIO_AGENT:
					UBYTE ubHeatAdd = 20;
					if(protestsGetState() >= PROTEST_STATE_STRIKE) {
						ubHeatAdd *= 2;
					}

					heatTryIncrease(ubHeatAdd);
					if(heatTryPassCheck()) {
						commShopChangePage(COMM_SHOP_PAGE_OFFICE_MAIN, COMM_SHOP_PAGE_OFFICE_AGENT_EPILOGUE);
					}
					else {
						commShopChangePage(COMM_SHOP_PAGE_OFFICE_MAIN, COMM_SHOP_PAGE_NEWS_ESCAPE_FAIL);
					}
					break;
				case PAGE_ESCAPE_SCENARIO_TELEPORT:
					commShopChangePage(COMM_SHOP_PAGE_OFFICE_MAIN, COMM_SHOP_PAGE_OFFICE_SCIENTIST_EPILOGUE);
					break;
			}
		}
		else {
			commShopGoBack();
		}
	}
}

void pageEscapeCreate(tPageEscapeScenario eScenario) {
	s_eScenario = eScenario;
	commRegisterPage(pageEscapeProcess, 0);
	const UBYTE ubLineHeight = commGetLineHeight();
	UWORD uwPosY = 0;

	uwPosY += commDrawMultilineText(
		g_pMsgs[MSG_COMM_ESCAPE_OFFER], 0, uwPosY
	) * ubLineHeight;

	buttonInitAcceptDecline(g_pMsgs[MSG_COMM_ESCAPE], g_pMsgs[MSG_PAGE_BACK]);
	buttonDrawAll(commGetDisplayBuffer());
}
