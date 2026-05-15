/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "quest_crate.h"
#include <comm/page_office.h>
#include <comm/page_questioning.h>
#include <comm/inbox.h>
#include "save.h"
#include "hud.h"
#include "game.h"
#include "base.h"

static UBYTE s_ubCrateCount;
static UBYTE s_ubCratesSold;
static UBYTE s_isScientistUnlocked;
static UBYTE s_isFirstCrateFound;
static tCapsuleState s_eCapsuleState;

static void questCrateOnQuestioningEnd(
	tQuestioningBit eQuestioningBit, UBYTE isReportedOrCaught
) {
	switch(eQuestioningBit) {
		case QUESTIONING_BIT_TELEPORT_PARTS:
			if(isReportedOrCaught) {
				s_ubCrateCount = 0;
			}
			break;
		case QUESTIONING_BIT_AGENT:
			if(isReportedOrCaught) {
				pageOfficeLockPerson(FACE_ID_AGENT);
			}
			break;
		default:
			break;
	}
}

UBYTE questCrateTryUnlockSciCrateTexts(void) {
	if(s_isScientistUnlocked && pageOfficeTryUnlockPersonSubpage(
		FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_FIRST_CRATE
	)) {
		pageOfficeTryUnlockPersonSubpage(
			FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_CRATE_TELEPORTER
		);
		inboxPushBack(COMM_SHOP_PAGE_OFFICE_SCIENTIST_FIRST_CRATE, 0);
		return 1;
	}
	return 0;
}

void questCrateReset(void) {
	s_ubCrateCount = 0;
	s_ubCratesSold = 0;
	s_isScientistUnlocked = 0;
	s_isFirstCrateFound = 0;
	pageQuestioningSetHandler(QUESTIONING_BIT_TELEPORT_PARTS, questCrateOnQuestioningEnd);
	pageQuestioningSetHandler(QUESTIONING_BIT_AGENT, questCrateOnQuestioningEnd);
}

UBYTE questCrateGetCratesSold(void) {
	return s_ubCratesSold;
}

void questCrateSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_CRATE);
	fileWrite(pFile, &s_ubCrateCount, sizeof(s_ubCrateCount));
	fileWrite(pFile, &s_ubCratesSold, sizeof(s_ubCratesSold));
	fileWrite(pFile, &s_isScientistUnlocked, sizeof(s_isScientistUnlocked));
	fileWrite(pFile, &s_isFirstCrateFound, sizeof(s_isFirstCrateFound));
	fileWrite(pFile, &s_eCapsuleState, sizeof(s_eCapsuleState));
	saveWriteTag(pFile, SAVE_TAG_CRATE_END);
}

UBYTE questCrateLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_CRATE)) {
		return 0;
	}

	fileRead(pFile, &s_ubCrateCount, sizeof(s_ubCrateCount));
	fileRead(pFile, &s_ubCratesSold, sizeof(s_ubCratesSold));
	fileRead(pFile, &s_isScientistUnlocked, sizeof(s_isScientistUnlocked));
	fileRead(pFile, &s_isFirstCrateFound, sizeof(s_isFirstCrateFound));
	fileRead(pFile, &s_eCapsuleState, sizeof(s_eCapsuleState));

	return saveReadTag(pFile, SAVE_TAG_CRATE_END);
}

void questCrateProcess(void) {

}

void questCrateAdd(void) {
	s_ubCrateCount += 1;
	if(s_isFirstCrateFound) {
		if(s_ubCrateCount % 3 == 0) {
			pageQuestioningTrySetPendingQuestioning(QUESTIONING_BIT_TELEPORT_PARTS, 1);
		}
	}
	else {
		s_isFirstCrateFound = 1;
		pageOfficeUnlockPerson(FACE_ID_AGENT);
		pageQuestioningAddReporting(QUESTIONING_BIT_AGENT);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_DOSSIER);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_WELCOME);
		pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_SELL_CRATES);
		inboxPushBack(COMM_SHOP_PAGE_OFFICE_AGENT_WELCOME, 0);

		questCrateTryUnlockSciCrateTexts();
		if(pageOfficeHasPerson(FACE_ID_SCIENTIST) && pageOfficeHasPerson(FACE_ID_AGENT)) {
			pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_SCIENTISTS);
		}
	}
}

UBYTE questCrateGetCount(void) {
	return s_ubCrateCount;
}

UBYTE questCrateTryConsume(UBYTE ubAmount) {
	if(questCrateGetCount() >= ubAmount) {
		s_ubCrateCount -= ubAmount;
		return 1;
	}
	return 0;
}

UBYTE questCrateTrySell(void) {
	if(questCrateTryConsume(1)) {
		s_ubCratesSold += 1;
		return 1;
	}
	return 0;
}

void questCrateSetCapsuleState(tCapsuleState eNewState) {
	s_eCapsuleState = eNewState;
	switch(s_eCapsuleState) {
		case CAPSULE_STATE_NOT_FOUND:
			break;
		case CAPSULE_STATE_FOUND:
			hudShowMessage(FACE_ID_MIETEK, g_pMsgs[MSG_HUD_CAPSULE_FOUND]);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_MIETEK, COMM_SHOP_PAGE_OFFICE_MIETEK_CAPSULE_FOUND);
			inboxPushBack(COMM_SHOP_PAGE_OFFICE_MIETEK_CAPSULE_FOUND, 0);
			pageOfficeUnlockPerson(FACE_ID_CRYO);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_OFFICE_CRYO_DOSSIER);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_OFFICE_CRYO_TRAMIEL);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_CRYO, COMM_SHOP_PAGE_OFFICE_CRYO_CONSOLE);
			break;
		case CAPSULE_STATE_OPENED:
			pageOfficeLockPerson(FACE_ID_CRYO);
			pageOfficeUnlockPerson(FACE_ID_JAY);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_JAY, COMM_SHOP_PAGE_JAY_DOSSIER);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_JAY, COMM_SHOP_PAGE_JAY_CONGRATS);
			commShopChangePage(COMM_SHOP_PAGE_OFFICE_LIST_JAY, COMM_SHOP_PAGE_CRYO_SUCCESS);
			break;
	}
}

tCapsuleState questCrateGetCapsuleState(void) {
	return s_eCapsuleState;
}

void questCrateProcessBase(void) {
	if(!s_isScientistUnlocked) {
		const tBase *pBase = baseGetCurrent();
		if(gameIsRangeVisibleOnCamera(pBase->sPosTeleport.uwY, pBase->sPosTeleport.uwY + 32)) {
			pageOfficeUnlockPerson(FACE_ID_SCIENTIST);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_DOSSIER);
			pageOfficeTryUnlockPersonSubpage(FACE_ID_SCIENTIST, COMM_SHOP_PAGE_OFFICE_SCIENTIST_WELCOME);
			inboxPushBack(COMM_SHOP_PAGE_OFFICE_SCIENTIST_WELCOME, 0);
			hudShowMessage(FACE_ID_SCIENTIST, g_pMsgs[MSG_HUD_SCI_WELCOME]);
			s_isScientistUnlocked = 1;
			if(s_isFirstCrateFound) {
				questCrateTryUnlockSciCrateTexts();
				if(pageOfficeHasPerson(FACE_ID_SCIENTIST) && pageOfficeHasPerson(FACE_ID_AGENT)) {
					pageOfficeTryUnlockPersonSubpage(FACE_ID_AGENT, COMM_SHOP_PAGE_OFFICE_AGENT_SCIENTISTS);
				}
			}
		}
	}
}
