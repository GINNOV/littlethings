/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <comm/page_use_crates.h>
#include <comm/page_office.h>
#include <comm/button.h>
#include "../vehicle.h"
#include "../quest_crate.h"
#include "../hud.h"
#include "../protests.h"

static tPageUseCratesScenario s_eScenario;

static UBYTE pageUseCratesGetMinAmount(void) {
	switch(s_eScenario) {
		case PAGE_USE_CRATES_SCENARIO_TELEPORTER:
			return 5;
		case PAGE_USE_CRATES_SCENARIO_CAPSULE:
			return 5;
		case PAGE_USE_CRATES_SCENARIO_SELL:
			return 1;
	}
	return 0;
}

static void pageUseCratesDrawAll(void) {
	const UBYTE ubLineHeight = commGetLineHeight();
	UWORD uwPosY = 0;
	UBYTE ubCrateCount = questCrateGetCount();

	const char *szMsgPremise = 0;
	const char *szMsgNotYet = 0;
	const char *szMsgUse = 0;
	UBYTE ubMinAmount = pageUseCratesGetMinAmount();
	switch(s_eScenario) {
		case PAGE_USE_CRATES_SCENARIO_TELEPORTER:
			szMsgPremise = g_pMsgs[MSG_CRATES_PREMISE_TELEPORT];
			szMsgNotYet = g_pMsgs[MSG_CRATES_NOT_YET_GIVE];
			szMsgUse = g_pMsgs[MSG_CRATES_GIVE];
			break;
		case PAGE_USE_CRATES_SCENARIO_CAPSULE:
			szMsgPremise = g_pMsgs[MSG_CRATES_PREMISE_CAPSULE];
			szMsgNotYet = 0;
			szMsgUse = g_pMsgs[MSG_CRATES_USE];
			break;
		case PAGE_USE_CRATES_SCENARIO_SELL:
			snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_CRATES_PREMISE_SELL], 1000, '\x1F');
			szMsgPremise = gameGetMessageBuffer();
			szMsgNotYet = g_pMsgs[MSG_CRATES_NOT_YET_SELL];
			szMsgUse = g_pMsgs[MSG_CRATES_SELL];
			break;
	}

	uwPosY += commDrawMultilineText(szMsgPremise, 0, uwPosY) * ubLineHeight;
	if(ubCrateCount < ubMinAmount) {
		if(szMsgNotYet) {
			uwPosY += commDrawMultilineText(szMsgNotYet, 0, uwPosY) * ubLineHeight;
		}
		buttonInitOk(g_pMsgs[MSG_PAGE_BACK]);
	}
	else {
		buttonInitAcceptDecline(szMsgUse, g_pMsgs[MSG_PAGE_BACK]);
	}

	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_CRATES_REMAINING], ubCrateCount);
	uwPosY += ubLineHeight;
	uwPosY += commDrawMultilineText(gameGetMessageBuffer(), 0, uwPosY) * ubLineHeight;

	buttonDrawAll(commGetDisplayBuffer());
}

static void pageUseCratesProcess(void) {
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

	tButtonPreset ePreset = buttonGetPreset();
	if(ePreset == BUTTON_PRESET_ACCEPT_DECLINE) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			if(bButtonCurr == 0) {
				switch(s_eScenario) {
					case PAGE_USE_CRATES_SCENARIO_TELEPORTER:
						if(questCrateTryConsume(pageUseCratesGetMinAmount())) {
							pageOfficeLockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_CRATE_TELEPORTER);
							pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_ALL_CRATES);
							pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_ESCAPE);
							commShopChangePage(COMM_SHOP_PAGE_OFFICE_LIST_SCI, COMM_SHOP_PAGE_OFFICE_SCIENTIST_ALL_CRATES);
						}
						else {
							commShopGoBack();
						}
						break;
					case PAGE_USE_CRATES_SCENARIO_CAPSULE:
						if(questCrateTryConsume(pageUseCratesGetMinAmount())) {
							questCrateSetCapsuleState(CAPSULE_STATE_OPENED);
						}
						else {
							commShopGoBack();
						}
						break;
					case PAGE_USE_CRATES_SCENARIO_SELL:
						if(questCrateTrySell()) {
							g_pVehicles[0].lCash += 1000;
							hudSetCash(0, g_pVehicles[0].lCash);
							protestsProcess();
							if(questCrateGetCratesSold() == QUEST_CRATE_MIN_SELLS_FOR_ESCAPE) {
								pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_ALL_CRATES);
								pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_ESCAPE);
								commShopChangePage(COMM_SHOP_PAGE_OFFICE_LIST_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_ALL_CRATES);
							}
							else {
								commEraseAll();
								pageUseCratesDrawAll();
							}
						}
						break;
				}
			}
			else {
				commShopGoBack();
			}
		}
	}
	else if(ePreset == BUTTON_PRESET_OK) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			commShopGoBack();
		}
	}
}

void pageUseCratesCreate(tPageUseCratesScenario eScenario) {
	commRegisterPage(pageUseCratesProcess, 0);
	s_eScenario = eScenario;
	pageUseCratesDrawAll();
}
