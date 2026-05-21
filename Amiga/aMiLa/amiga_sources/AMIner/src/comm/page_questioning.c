/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "page_questioning.h"
#include <comm/comm.h>
#include <comm/page_office.h>
#include <comm/button.h>
#include <comm/inbox.h>
#include "../save.h"
#include "../heat.h"
#include "../game.h"
#include "../hud.h"
#include "../achievement.h"
#include "../protests.h"
#include "../core.h"

#define QUESTIONING_HEAT_INCREASE 5
#define QUESTIONING_HEAT_DECREASE_TRUTH 5
#define QUESTIONING_HEAT_DECREASE_REPORT 100

static tQuestioningFlag s_eQuestioningsPending;
static tQuestioningFlag s_eQuestioningsReported;
static tQuestioningFlag s_eQuestioningsNotReported; // for future reporting at will
static tQuestioningBit s_eQuestioningBitCurrent;
static tQuestioningHandler s_pQuestioningHandlers[QUESTIONING_BIT_COUNT] = {0};
static tCommShopPage s_pOfficeQuestioningPages[PAGE_OFFICE_SUBPAGES_PER_PERSON];
static UWORD s_uwLiesCount;
static UBYTE s_ubReportingAccoladeChance;

static tCommShopPage pageQuestioningBitToShopPage(tQuestioningBit eBit) {
	static const tCommShopPage pQuestioningPages[QUESTIONING_BIT_COUNT] = {
		COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_GATE,
		COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_TELEPORT_PARTS,
		COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_AGENT,
	};
	return pQuestioningPages[eBit];
}

static void pageQuestioningProcess(void) {
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
			// Told the truth
			heatTryReduce(QUESTIONING_HEAT_DECREASE_TRUTH);
			s_eQuestioningsNotReported &= ~BV(s_eQuestioningBitCurrent);
			pageQuestioningReport(s_eQuestioningBitCurrent);
			inboxPushBack(pageQuestioningBitToShopPage(s_eQuestioningBitCurrent), 1);
		}
		else {
			++s_uwLiesCount;
			if(heatTryPassCheck()) {
				s_eQuestioningsNotReported |= BV(s_eQuestioningBitCurrent);
			}
			else {
				// Got caught
				gameAddRebuke(
					(s_eQuestioningBitCurrent == QUESTIONING_BIT_GATE)
						? REBUKE_QUESTIONING_GATE
						: REBUKE_QUESTIONING_CRATE
				);
				s_eQuestioningsNotReported &= ~BV(s_eQuestioningBitCurrent);
				pageQuestioningReport(s_eQuestioningBitCurrent);
			}
		}

		// Questioning has ended - clear pending and launch callback
		s_eQuestioningsPending &= ~BV(s_eQuestioningBitCurrent);
		commShopGoBack();
	}
}

void pageQuestioningCreate(void) {
	commRegisterPage(pageQuestioningProcess, 0);
	UWORD uwPosY = 0;
	UBYTE ubLineHeight = commGetLineHeight();

	s_eQuestioningBitCurrent = QUESTIONING_BIT_GATE;
	while(s_eQuestioningBitCurrent < QUESTIONING_BIT_COUNT) {
		if(s_eQuestioningsPending & BV(s_eQuestioningBitCurrent)) {
			break;
		}
		++s_eQuestioningBitCurrent;
	}

	if(s_eQuestioningBitCurrent >= QUESTIONING_BIT_COUNT) {
		commShopGoBack();
		return;
	}

	const char *szMsg = "???";
	switch (s_eQuestioningBitCurrent)
	{
		case QUESTIONING_BIT_GATE:
			szMsg = g_pMsgs[MSG_QUESTIONING_GATE];
			break;
		case QUESTIONING_BIT_TELEPORT_PARTS:
			szMsg = g_pMsgs[MSG_QUESTIONING_CRATE];
			break;
		default:
			logWrite("ERR: Unhandled questioning value: %d\n", s_eQuestioningBitCurrent);
			// TODO: exit earlier?
	}

	uwPosY += commDrawMultilineText(szMsg, 0, uwPosY) * ubLineHeight;
	uwPosY += ubLineHeight / 2;
	snprintf(
		gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE,
		g_pMsgs[MSG_QUESTIONING_DESCRIPTION],
		QUESTIONING_HEAT_DECREASE_TRUTH,
		heatGetPercent()
	);
	uwPosY += commDrawMultilineText(gameGetMessageBuffer(),  0, uwPosY) * ubLineHeight;

	buttonInitAcceptDecline(g_pMsgs[MSG_QUESTIONING_TRUTH], g_pMsgs[MSG_QUESTIONING_LIE]);
	buttonDrawAll(commGetDisplayBuffer());
}

void pageQuestioningReset(void) {
	s_eQuestioningsPending = 0;
	s_eQuestioningsReported = 0;
	s_eQuestioningsNotReported = 0;
	s_uwLiesCount = 0;
	s_ubReportingAccoladeChance = 25;
}

void pageQuestioningSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_QUESTIONING);
	fileWrite(pFile, &s_eQuestioningsPending, sizeof(s_eQuestioningsPending));
	fileWrite(pFile, &s_eQuestioningsReported, sizeof(s_eQuestioningsReported));
	fileWrite(pFile, &s_eQuestioningsNotReported, sizeof(s_eQuestioningsNotReported));
	fileWrite(pFile, &s_uwLiesCount, sizeof(s_uwLiesCount));
	fileWrite(pFile, &s_ubReportingAccoladeChance, sizeof(s_ubReportingAccoladeChance));
	saveWriteTag(pFile, SAVE_TAG_QUESTIONING_END);
}

UBYTE pageQuestioningLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_QUESTIONING)) {
		return 0;
	}

	fileRead(pFile, &s_eQuestioningsPending, sizeof(s_eQuestioningsPending));
	fileRead(pFile, &s_eQuestioningsReported, sizeof(s_eQuestioningsReported));
	fileRead(pFile, &s_eQuestioningsNotReported, sizeof(s_eQuestioningsNotReported));
	fileRead(pFile, &s_uwLiesCount, sizeof(s_uwLiesCount));
	fileRead(pFile, &s_ubReportingAccoladeChance, sizeof(s_ubReportingAccoladeChance));
	return saveReadTag(pFile, SAVE_TAG_QUESTIONING_END);
}

void pageQuestioningTrySetPendingQuestioning(tQuestioningBit eQuestioningBit, UBYTE isForce) {
	tQuestioningFlag ePendingQuestioningPrev = s_eQuestioningsPending;

	if(isForce || !pageQuestioningIsReported(eQuestioningBit)) {
		// Not reported yet - increase heat and add as pending questioning.
		// Increases heat each time it's triggered, even when questioning is already pending.
		s_eQuestioningsPending |= BV(eQuestioningBit);
		UBYTE ubHeat = QUESTIONING_HEAT_INCREASE;
		if(protestsGetState() >= PROTEST_STATE_STRIKE) {
			ubHeat *= 2;
		}
		heatTryIncrease(ubHeat);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_LIST);
	}

	if(ePendingQuestioningPrev != s_eQuestioningsPending) {
		inboxPushBack(COMM_SHOP_PAGE_OFFICE_KOMISARZ_QUESTIONING, 1);
		hudShowMessage(FACE_ID_KRYSTYNA, g_pMsgs[MSG_HUD_WAITING_KOMISARZ]);
	}
}

void pageQuestioningTryCancelPendingQuestioning(tQuestioningBit eQuestioningBit) {
	s_eQuestioningsPending &= ~BV(eQuestioningBit);
}

UBYTE pageQuestioningIsReported(tQuestioningBit eQuestioningBit) {
	return (s_eQuestioningsReported & BV(eQuestioningBit)) != 0;
}

void pageQuestioningSetHandler(
	tQuestioningBit eQuestioningBit, tQuestioningHandler cbOnQuestioningEnded
) {
	s_pQuestioningHandlers[eQuestioningBit] = cbOnQuestioningEnded;
}

const tCommShopPage *pageQuestioningGetNotReportedPages(void) {
	UBYTE ubPos = 0;
	for(tQuestioningBit eBit = 0; eBit < QUESTIONING_BIT_COUNT; ++eBit) {
		if(s_eQuestioningsNotReported & BV(eBit)) {
			s_pOfficeQuestioningPages[ubPos] = pageQuestioningBitToShopPage(eBit);
			++ubPos;
		}
	}

	s_pOfficeQuestioningPages[ubPos] = COMM_SHOP_PAGE_OFFICE_MAIN; // Serves as list terminator
	return s_pOfficeQuestioningPages;
}

void pageQuestioningReport(tQuestioningBit eQuestioningBit) {
	UBYTE isVoluntarily = (s_eQuestioningsNotReported & BV(eQuestioningBit)) != 0;

	s_eQuestioningsReported |= BV(eQuestioningBit);
	s_eQuestioningsPending &= ~BV(eQuestioningBit);
	if(s_eQuestioningsReported == QUESTIONING_FLAG_ALL) {
		achievementUnlock(ACHIEVEMENT_CONFIDENT);
	}

	if(isVoluntarily) {
		s_eQuestioningsNotReported &= ~BV(eQuestioningBit);
		heatTryReduce(QUESTIONING_HEAT_DECREASE_REPORT);
		if(s_ubReportingAccoladeChance < randUwMinMax(&g_sRand, 1, 100)) {
			gameAddAccolade();
			pageOfficeTryUnlockPersonSubpage(FACE_ID_KOMISARZ, COMM_SHOP_PAGE_OFFICE_KOMISARZ_QUESTIONING_ACCOLADE);
			inboxPushBack(COMM_SHOP_PAGE_OFFICE_KOMISARZ_QUESTIONING_ACCOLADE, 1);
		}
		s_ubReportingAccoladeChance = MIN(100, s_ubReportingAccoladeChance + 25);
	}

	if(s_pQuestioningHandlers[eQuestioningBit]) {
		s_pQuestioningHandlers[eQuestioningBit](
			eQuestioningBit, pageQuestioningIsReported(eQuestioningBit)
		);
	}
}

void pageQuestioningAddReporting(tQuestioningBit eQuestioningBit) {
	s_eQuestioningsNotReported |= BV(eQuestioningBit);
}

UBYTE pageQuestioningIsAnyReported(void) {
	return s_eQuestioningsReported != 0;
}

UBYTE pageQuestioningGetLiesCount(void) {
	return s_uwLiesCount;
}
