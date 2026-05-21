/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "gs_shop.h"
#include <ace/managers/system.h>
#include <comm/comm.h>
#include <comm/page_warehouse.h>
#include <comm/page_workshop.h>
#include <comm/page_office.h>
#include <comm/page_news.h>
#include <comm/page_msg.h>
#include <comm/page_accounting.h>
#include <comm/page_bribe.h>
#include <comm/page_gate_dilemma.h>
#include <comm/page_questioning.h>
#include <comm/page_use_crates.h>
#include <comm/page_escape.h>
#include <comm/page_list.h>
#include <comm/page_sokoban.h>
#include <comm/page_market.h>
#include <comm/page_comm_unlock.h>
#include "core.h"
#include "dino.h"
#include "game.h"
#include "hud.h"
#include "inbox.h"
#include "menu.h"
#include "tutorial.h"
#include "achievement.h"
#include "settings.h"
#include "inventory.h"

#define LED_BLINK_COUNTER_MAX 15

static tCommTab s_eTab;
static tCommShopPage s_eCurrentPage;
static tCommShopPage s_eCameFrom;
static tTabNavigationState s_eTabNavigationState;
static UBYTE s_ubLedBlinkCounter;
static UBYTE s_ubLedBlinkState;

static const char * const s_pRebukeToMessageFileName[] = {
	[REBUKE_INVALID] = 0,
	[REBUKE_ACCOUNTING] = "rebuke_accounting",
	[REBUKE_BRIBE] = "rebuke_bribe",
	[REBUKE_FINAL] = "rebuke_final",
	[REBUKE_GATE_DESTROYED] = "rebuke_gate_destroyed",
	[REBUKE_PLAN_1] = "rebuke_plan_1",
	[REBUKE_PLAN_2] = "rebuke_plan_2",
	[REBUKE_QUESTIONING_CRATE] = "rebuke_questioning_crate",
	[REBUKE_QUESTIONING_GATE] = "rebuke_questioning_gate",
	[REBUKE_VEHICLE_DESTROYED] = "rebuke_vehicle_destroyed",
};

//------------------------------------------------------------------ PRIVATE FNS

static tCommShopPage commShopTabToPage(tCommTab eTab) {
	switch(eTab) {
		case COMM_TAB_OFFICE:
			return COMM_SHOP_PAGE_OFFICE_MAIN;
		case COMM_TAB_WAREHOUSE:
			return COMM_SHOP_PAGE_WAREHOUSE;
		case COMM_TAB_WORKSHOP:
			return COMM_SHOP_PAGE_WORKSHOP;
		default:
			return COMM_SHOP_PAGE_COUNT;
	}
}

static void onBack(void) {
	tCommShopPage ePage;
	if(inboxTryPopFront(&ePage)) {
		commShopChangePage(s_eCameFrom, ePage);
	}
	else {
		hudClearInboxNotification();
		commShopChangePage(COMM_SHOP_PAGE_COUNT, s_eCameFrom);
	}
}

static void onBackFromEpilogueText(void) {
	statePop(g_pGameStateManager);
	menuGsEnter(0);
}

static void commGsShopCreate(void) {
	UBYTE isShopShown = commTryShow(gameGetSteers(), 2, 0);
	if(!isShopShown) {
		// Camera not placed properly
		statePop(g_pGameStateManager);
		return;
	}

	s_eTabNavigationState = TAB_NAVIGATION_STATE_DISABLED;
	pageOfficeResetSelection();

	tCommShopPage ePage;
	if(!inboxTryPopFront(&ePage)) {
		ePage = COMM_SHOP_PAGE_OFFICE_MAIN;
		hudClearInboxNotification();
	}
	commShopChangePage(COMM_SHOP_PAGE_OFFICE_MAIN, ePage);

	// Process managers once so that backbuffer becomes front buffer
	// Single buffering from now!
	viewProcessManagers(g_pMainBuffer->sCommon.pVPort->pView);
	copProcessBlocks();
	vPortWaitForEnd(g_pMainBuffer->sCommon.pVPort);
}

static void commGsShopLoop(void) {
	commProcess();
	tutorialProcess();
	dinoProcess();
	gameProcessMusicInterval();

	hudProcess();
	// Process only managers of HUD because we want single buffering on main one
	vPortProcessManagers(g_pMainBuffer->sCommon.pVPort->pView->pFirstVPort);
	copProcessBlocks();
	vPortWaitForEnd(g_pMainBuffer->sCommon.pVPort);

	if(commShopPageToTab(s_eCurrentPage) != COMM_TAB_COUNT) {
		// Process inbox when on main tab page, e.g. after fulfilling plan
		tCommShopPage ePage;
		if(inboxTryPopFront(&ePage)) {
			commShopChangePage(s_eCameFrom, ePage);
			return;
		}
		hudClearInboxNotification();

		tCommTab eOldTab = s_eTab;
		// Tab nav using shift+left / shift+right
		if(commNavExUse(COMM_NAV_EX_SHIFT_LEFT)) {
			if(s_eTab) {
				--s_eTab;
			}
			else {
				s_eTab = COMM_TAB_COUNT - 1;
			}
		}
		else if(commNavExUse(COMM_NAV_EX_SHIFT_RIGHT)) {
			if(s_eTab < COMM_TAB_COUNT - 1) {
				++s_eTab;
			}
			else {
				s_eTab = 0;
			}
		}
		if(s_eTab != eOldTab) {
			tCommShopPage ePage = commShopTabToPage(s_eTab);
			commShopChangePage(s_eCurrentPage, ePage);
			return;
		}
	}

	if(s_eTabNavigationState == TAB_NAVIGATION_STATE_ENABLED) {
		tCommTab eOldTab = s_eTab;
		if(commNavUse(DIRECTION_LEFT)) {
			if(s_eTab) {
				--s_eTab;
			}
			else {
				s_eTab = COMM_TAB_COUNT - 1;
			}
		}
		else if(commNavUse(DIRECTION_RIGHT)) {
			if(s_eTab < COMM_TAB_COUNT - 1) {
				++s_eTab;
			}
			else {
				s_eTab = 0;
			}
		}
		else if(commNavUse(DIRECTION_UP)) {
			s_eTabNavigationState = TAB_NAVIGATION_STATE_DISABLING;
		}
		else if(
			commNavUse(DIRECTION_FIRE) && s_eTab == COMM_TAB_WAREHOUSE &&
			g_isSokoUnlock && s_eCurrentPage != COMM_SHOP_PAGE_SOKOBAN
		) {
			commShopChangePage(COMM_SHOP_PAGE_WAREHOUSE, COMM_SHOP_PAGE_SOKOBAN);
			return;
		}

		if(s_eTab != eOldTab) {
			commSetActiveLed(s_eTab);
			s_ubLedBlinkCounter = 0;
			tCommShopPage ePage = commShopTabToPage(s_eTab);
			commShopChangePage(s_eCurrentPage, ePage);
			return;
		}

		if(s_eTabNavigationState == TAB_NAVIGATION_STATE_DISABLING) {
			commSetActiveLed(s_eTab);
		}
		else {
			if(++s_ubLedBlinkCounter > LED_BLINK_COUNTER_MAX) {
				s_ubLedBlinkState = !s_ubLedBlinkState;
				commSetActiveLed(s_ubLedBlinkState ? s_eTab : COMM_TAB_COUNT);
				s_ubLedBlinkCounter = 0;
			}
		}
	}
	else {
		if(!commProcessPage()) {
			// gameTriggerSave(); // Too slow for FDD!
			logWrite("shop quit\n");
			statePop(g_pGameStateManager);
			return;
		}
		if(s_eTabNavigationState == TAB_NAVIGATION_STATE_DISABLING) {
			s_eTabNavigationState = TAB_NAVIGATION_STATE_DISABLED;
		}
	}
}

static void commGsShopDestroy(void) {
	if(!commIsShown()) {
		return;
	}

	viewProcessManagers(g_pMainBuffer->sCommon.pVPort->pView);
	copProcessBlocks();
	vPortWaitForEnd(g_pMainBuffer->sCommon.pVPort);
	commHide();
}

//------------------------------------------------------------------- PUBLIC FNS

void commShopChangePage(tCommShopPage eCameFrom, tCommShopPage ePage) {
	s_eCurrentPage = ePage;
	s_eTab = commShopPageToTab(ePage);

	if(s_eTabNavigationState != TAB_NAVIGATION_STATE_ENABLED) {
		commSetActiveLed(s_eTab);
		s_ubLedBlinkCounter = 0;
	}
	commEraseAll();

	s_eCameFrom = eCameFrom;
	const char *szTitle = g_pMsgs[commShopPageToTitle(ePage)];
	switch(ePage) {
		case COMM_SHOP_PAGE_WORKSHOP:
			if(inventoryGetCommUnlockState(baseGetCurrentId()) >= COMM_UNLOCK_STATE_OFFICE_WORKSHOP) {
				pageWorkshopCreate();
			}
			else {
				pageCommUnlockCreate(
					COMM_UNLOCK_STATE_OFFICE_WORKSHOP,
					COMM_SHOP_PAGE_WORKSHOP,
					g_pMsgs[MSG_COMM_UNLOCK_OFFICE_WORKSHOP], 100
				);
			}
			break;
		case COMM_SHOP_PAGE_WAREHOUSE:
			if(inventoryGetCommUnlockState(baseGetCurrentId()) >= COMM_UNLOCK_STATE_WAREHOUSE) {
				pageWarehouseCreate();
			}
			else if(inventoryGetCommUnlockState(baseGetCurrentId()) >= COMM_UNLOCK_STATE_OFFICE_WORKSHOP) {
				pageCommUnlockCreate(
					COMM_UNLOCK_STATE_WAREHOUSE,
					COMM_SHOP_PAGE_WAREHOUSE,
					g_pMsgs[MSG_COMM_UNLOCK_WAREHOUSE], 100
				);
			}
			else {
				pageCommUnlockCreate(
					COMM_UNLOCK_STATE_OFFICE_WORKSHOP,
					COMM_SHOP_PAGE_WAREHOUSE,
					g_pMsgs[MSG_COMM_UNLOCK_OFFICE_WORKSHOP], 100
				);
			}
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_DOSSIER:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_WELCOME:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_FIRST_PLAN:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "first_plan", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_PLAN_COMPLETE:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "plan_complete", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_MARKET:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "market", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_START:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "protest_start", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_PROTEST_STRIKE:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "protest_strike", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_MIETEK_CAPSULE_FOUND:
			pageMsgCreate(FACE_ID_MIETEK, szTitle, "capsule_found", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KRYSTYNA_DOSSIER:
			pageMsgCreate(FACE_ID_KRYSTYNA, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KRYSTYNA_ACCOUNTING:
			pageAccountingCreate();
			break;
		case COMM_SHOP_PAGE_OFFICE_KRYSTYNA_PROTEST_WARNING:
			pageMsgCreate(FACE_ID_KRYSTYNA, szTitle, "protest_warning", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_DOSSIER:
			pageMsgCreate(FACE_ID_URZEDAS, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_WELCOME:
			pageMsgCreate(FACE_ID_URZEDAS, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_FIRST_PLAN:
			pageMsgCreate(FACE_ID_URZEDAS, szTitle, "first_plan", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_COMPLETE:
			pageMsgCreate(FACE_ID_URZEDAS, szTitle, "plan_complete", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_DELAYED:
			pageMsgCreate(FACE_ID_URZEDAS, szTitle, "plan_delayed", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_ACCOLADE:
			pageMsgCreate(FACE_ID_URZEDAS, szTitle, "plan_accolade", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_URZEDAS_BRIBE:
			pageBribeCreate();
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_DOSSIER:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_WELCOME:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_DINO_INTRO:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "dino_intro", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REBUKE_1:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, s_pRebukeToMessageFileName[gameGetRebuke(0)], onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REBUKE_2:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, s_pRebukeToMessageFileName[gameGetRebuke(1)], onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REBUKE_3:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, s_pRebukeToMessageFileName[gameGetRebuke(2)], onBackFromEpilogueText);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_QUESTIONING:
			pageQuestioningCreate();
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_ARCH_ACCOLADE:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "arch_accolade", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_LIST:
			pageListCreate(FACE_ID_KOMISARZ, pageQuestioningGetNotReportedPages());
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_GATE:
			pageQuestioningReport(QUESTIONING_BIT_GATE); // HACK HACK HACK
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "reported_gate", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_TELEPORT_PARTS:
			pageQuestioningReport(QUESTIONING_BIT_TELEPORT_PARTS); // HACK HACK HACK
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "reported_crate", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_REPORTING_AGENT:
			pageQuestioningReport(QUESTIONING_BIT_AGENT); // HACK HACK HACK
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "reported_agent", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_QUESTIONING_ACCOLADE:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "questioning_accolade", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_KOMISARZ_GATE_OPENING:
			pageMsgCreate(FACE_ID_KOMISARZ, szTitle, "gate_opening", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_DOSSIER:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_WELCOME:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_ACCOLADE:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "accolade", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_PLAN_FAIL:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "plan_fail", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_GATE_OPENED_DINO_INCOMPLETE:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "gate_opened_dino_incomplete", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_GATE_OPENED_DINO_COMPLETE:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "gate_opened_dino_complete", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_ARCH_GATE_DESTROYED:
			pageMsgCreate(FACE_ID_ARCH, szTitle, "gate_destroyed", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_PRISONER_DOSSIER:
			pageMsgCreate(FACE_ID_PRISONER, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_PRISONER_WELCOME:
			pageMsgCreate(FACE_ID_PRISONER, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_PRISONER_GATE_DESTROYED:
			pageMsgCreate(FACE_ID_PRISONER, szTitle, "gate_destroyed", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_1:
			pageMsgCreate(FACE_ID_PRISONER, szTitle, "radio_1", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_2:
			pageMsgCreate(FACE_ID_PRISONER, szTitle, "radio_2", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_PRISONER_RADIO_3:
			pageMsgCreate(FACE_ID_PRISONER, szTitle, "radio_3", onBack);
			break;

		case COMM_SHOP_PAGE_OFFICE_AGENT_WELCOME:
			pageMsgCreate(FACE_ID_AGENT, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_AGENT_DOSSIER:
			pageMsgCreate(FACE_ID_AGENT, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_AGENT_SCIENTISTS:
			pageMsgCreate(FACE_ID_AGENT, szTitle, "sci", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_AGENT_ALL_CRATES:
			pageMsgCreate(FACE_ID_AGENT, szTitle, "all_crates", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_AGENT_SELL_CRATES:
			pageUseCratesCreate(PAGE_USE_CRATES_SCENARIO_SELL);
			break;
		case COMM_SHOP_PAGE_OFFICE_AGENT_ESCAPE:
			pageEscapeCreate(PAGE_ESCAPE_SCENARIO_AGENT);
			break;
		case COMM_SHOP_PAGE_OFFICE_AGENT_EPILOGUE:
			achievementUnlock(ACHIEVEMENT_ESCAPE);
			pageMsgCreate(FACE_ID_COUNT, szTitle, "agent_epilogue", onBackFromEpilogueText);
			break;

		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_DOSSIER:
			pageMsgCreate(FACE_ID_SCIENTIST, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_WELCOME:
			pageMsgCreate(FACE_ID_SCIENTIST, szTitle, "welcome", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_FIRST_CRATE:
			pageMsgCreate(FACE_ID_SCIENTIST, szTitle, "first_crate", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_ALL_CRATES:
			pageMsgCreate(FACE_ID_SCIENTIST, szTitle, "all_crates", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_CRATE_TELEPORTER:
			pageUseCratesCreate(PAGE_USE_CRATES_SCENARIO_TELEPORTER);
			break;
		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_ESCAPE:
			pageEscapeCreate(PAGE_ESCAPE_SCENARIO_TELEPORT);
			break;
		case COMM_SHOP_PAGE_OFFICE_SCIENTIST_EPILOGUE:
			achievementUnlock(ACHIEVEMENT_ESCAPE);
			pageMsgCreate(FACE_ID_SCIENTIST, szTitle, "epilogue", onBackFromEpilogueText);
			break;

		case COMM_SHOP_PAGE_OFFICE_CRYO_DOSSIER:
			pageMsgCreate(FACE_ID_CRYO, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_CRYO_TRAMIEL:
			pageMsgCreate(FACE_ID_CRYO, szTitle, "tramiel", onBack);
			break;
		case COMM_SHOP_PAGE_OFFICE_CRYO_CONSOLE:
			pageUseCratesCreate(PAGE_USE_CRATES_SCENARIO_CAPSULE);
			break;
		case COMM_SHOP_PAGE_CRYO_SUCCESS:
			g_isSokoUnlock = 1;
			pageMsgCreate(FACE_ID_CRYO, szTitle, "success", onBack);
			break;

		case COMM_SHOP_PAGE_JAY_DOSSIER:
			pageMsgCreate(FACE_ID_JAY, szTitle, "dossier", onBack);
			break;
		case COMM_SHOP_PAGE_JAY_CONGRATS:
			pageMsgCreate(FACE_ID_JAY, szTitle, "congrats", onBack);
			break;

		case COMM_SHOP_PAGE_OFFICE_LIST_MIETEK:
		case COMM_SHOP_PAGE_OFFICE_LIST_KRYSTYNA:
		case COMM_SHOP_PAGE_OFFICE_LIST_KOMISARZ:
		case COMM_SHOP_PAGE_OFFICE_LIST_URZEDAS: {
		case COMM_SHOP_PAGE_OFFICE_LIST_ARCH:
		case COMM_SHOP_PAGE_OFFICE_LIST_PRISONER:
		case COMM_SHOP_PAGE_OFFICE_LIST_AGENT:
		case COMM_SHOP_PAGE_OFFICE_LIST_SCI:
		case COMM_SHOP_PAGE_OFFICE_LIST_CRYO:
		case COMM_SHOP_PAGE_OFFICE_LIST_JAY:
			tFaceId eFace = ePage - COMM_SHOP_PAGE_OFFICE_LIST_MIETEK + FACE_ID_MIETEK;
			pageListCreate(eFace, officeGetPagesForFace(eFace));
		} break;
		case COMM_SHOP_PAGE_NEWS_ACCOLADES:
			achievementUnlock(ACHIEVEMENT_WORK_LEADER);
			achievementTryUnlockRighteous();
			pageNewsCreate(NEWS_KIND_ACCOLADES);
			break;
		case COMM_SHOP_PAGE_NEWS_GATE_ENEMY:
			achievementUnlock(ACHIEVEMENT_ARCHEO_VICTIM);
			pageNewsCreate(NEWS_KIND_GATE_ENEMY);
			break;
		case COMM_SHOP_PAGE_NEWS_GATE_RED:
			achievementUnlock(ACHIEVEMENT_BATTLE_OF_CENTURY);
			pageNewsCreate(NEWS_KIND_GATE_RED);
			break;
		case COMM_SHOP_PAGE_NEWS_ESCAPE_FAIL:
			pageNewsCreate(NEWS_KIND_ESCAPE_FAIL);
			break;
		case COMM_SHOP_PAGE_NEWS_RIOTS:
			achievementUnlock(ACHIEVEMENT_PROTESTS);
			pageNewsCreate(NEWS_KIND_RIOTS);
			break;
		case COMM_SHOP_PAGE_SOKOBAN:
			pageSokobanCreate();
			break;
		case COMM_SHOP_PAGE_MARKET:
			pageMarketCreate();
			break;
		case COMM_SHOP_PAGE_ARCH_GATE_PLEA:
			pageMsgCreate(FACE_ID_ARCH, "", "gate_plea", onBack);
			break;
		case COMM_SHOP_PAGE_PRISONER_GATE_PLEA:
			pageMsgCreate(FACE_ID_PRISONER, "", "gate_plea", onBack);
			break;
		case COMM_SHOP_PAGE_GATE_DILEMMA:
			pageGateDilemmaCreate();
			break;
		case COMM_SHOP_PAGE_OFFICE_MAIN:
		default:
			if(inventoryGetCommUnlockState(baseGetCurrentId()) >= COMM_UNLOCK_STATE_OFFICE_WORKSHOP) {
				pageOfficeShow();
			}
			else {
				pageCommUnlockCreate(
					COMM_UNLOCK_STATE_OFFICE_WORKSHOP,
					COMM_SHOP_PAGE_OFFICE_MAIN,
					g_pMsgs[MSG_COMM_UNLOCK_OFFICE_WORKSHOP], 100
				);
			}
			break;
	}
}

UBYTE commShopIsActive(void) {
	return commIsShown();
}

tCommShopPage commShopGetCurrentPage(void) {
	return s_eCurrentPage;
}

tCommTab commShopPageToTab(tCommShopPage ePage) {
	switch(ePage) {
		case COMM_SHOP_PAGE_OFFICE_MAIN:
			return COMM_TAB_OFFICE;
		case COMM_SHOP_PAGE_WAREHOUSE:
		case COMM_SHOP_PAGE_SOKOBAN:
			return COMM_TAB_WAREHOUSE;
		case COMM_SHOP_PAGE_WORKSHOP:
			return COMM_TAB_WORKSHOP;
		default:
			return COMM_TAB_COUNT;
	}
}

tMsg commShopPageToTitle(tCommShopPage ePage) {
	return MSG_PAGE_LIST_MIETEK + ePage - COMM_SHOP_PAGE_OFFICE_LIST_MIETEK;
}

void commShopGoBack(void) {
	onBack();
}

tTabNavigationState commShopGetTabNavigationState(void)
{
	return s_eTabNavigationState;
}

void commShopFocusOnTabNavigation(void)
{
	s_eTabNavigationState = TAB_NAVIGATION_STATE_ENABLED;
}

tState g_sStateShop = {
	.cbCreate = commGsShopCreate, .cbLoop = commGsShopLoop,
	.cbDestroy = commGsShopDestroy
};
