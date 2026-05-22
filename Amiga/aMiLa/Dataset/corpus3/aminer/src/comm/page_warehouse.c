#include "page_warehouse.h"
#include <ace/utils/string.h>
#include <ace/managers/key.h>
#include <comm/comm.h>
#include <comm/button.h>
#include <comm/page_accounting.h>
#include <comm/page_news.h>
#include <comm/page_office.h>
#include <comm/inbox.h>
#include "../warehouse.h"
#include "../assets.h"
#include "../defs.h"
#include "../hud.h"
#include "../game.h"
#include "../vehicle.h"
#include "../protests.h"

#define WAREHOUSE_COL_COUNT 4
#define USE_COOLDOWN_NEXT 10
#define USE_COOLDOWN_FIRST 25

static UBYTE s_ubPosCurr = 0, s_ubPosCount = 0;
static const UBYTE s_pColOffs[WAREHOUSE_COL_COUNT] = {0,  50, 85, 130};
static UBYTE s_pMineralsOnList[MINERAL_TYPE_COUNT];

static UWORD s_pTmpSell[MINERAL_TYPE_COUNT];
static UWORD s_pTmpPlan[MINERAL_TYPE_COUNT];
static UWORD s_pTmpStock[MINERAL_TYPE_COUNT];
static UBYTE s_ubButtonCurrent;
static UBYTE s_ubUseCooldown;
static UBYTE s_ubUseCount;
static tDirection s_eUseDirection;

static UBYTE getMineralsOnList(UBYTE *pMineralsOnList) {
	UBYTE ubCount = 0;
	tPlan *pPlan = planGetCurrent();
	for(UBYTE i = 0; i < MINERAL_TYPE_COUNT; ++i) {
		// Omit minerals not in plan
		if(pPlan->pMineralsRequired[i] || warehouseGetStock(i)) {
			pMineralsOnList[ubCount] = i;
			s_pTmpStock[i] = warehouseGetStock(i);
			s_pTmpPlan[i] = planManagerGet()->pMineralsSpent[i];
			s_pTmpSell[i] = 0;
			++ubCount;
		}
	}
	return ubCount;
}

static void pageWarehouseDrawRow(UBYTE ubPos) {
	UBYTE ubMineral = s_pMineralsOnList[ubPos];
	UBYTE ubColor = (
		ubPos == s_ubPosCurr ?
		COMM_DISPLAY_COLOR_TEXT_HOVER : COMM_DISPLAY_COLOR_TEXT_DARK
	);

	UWORD uwRowOffsY = 11 + ubPos * 10;

	// Erase
	commErase(0, uwRowOffsY, COMM_DISPLAY_WIDTH, 10);

	// Name
	commDrawText(
		s_pColOffs[0], uwRowOffsY, g_pMsgs[MSG_MINERAL_SILVER + ubMineral],
		FONT_COOKIE | FONT_SHADOW, ubColor
	);

	// Sell
	UWORD uwMineralReward = s_pTmpSell[ubMineral] * g_pMinerals[ubMineral].ubReward;
	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%hu\x1F", uwMineralReward);
	commDrawText(s_pColOffs[1], uwRowOffsY, gameGetMessageBuffer(), FONT_COOKIE | FONT_SHADOW, ubColor);

	// Stock
	UBYTE ubStockCenter = fontMeasureText(g_pFont, g_pMsgs[MSG_WAREHOUSE_COL_STOCK]).uwX / 2;
	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%hu", s_pTmpStock[ubMineral]);
	UBYTE ubValWidthHalf = fontMeasureText(g_pFont, gameGetMessageBuffer()).uwX / 2;

	if(ubPos == s_ubPosCurr) {
		commDrawText(
			s_pColOffs[2] + ubStockCenter + ubValWidthHalf + 3, uwRowOffsY, ">",
			FONT_COOKIE | FONT_SHADOW | FONT_LEFT, ubColor
		);
		commDrawText(
			s_pColOffs[2] + ubStockCenter - ubValWidthHalf - 3, uwRowOffsY, "<",
			FONT_COOKIE | FONT_SHADOW | FONT_RIGHT, ubColor
		);
	}
	else {
		commErase(
			s_pColOffs[2] + ubStockCenter + ubValWidthHalf + 3, uwRowOffsY,
			5, commGetLineHeight()
		);
		commErase(
			s_pColOffs[2] + ubStockCenter + ubValWidthHalf - 3 - 5, uwRowOffsY,
			5, commGetLineHeight()
		);
	}
	commDrawText(
		s_pColOffs[2] + ubStockCenter - ubValWidthHalf, uwRowOffsY, gameGetMessageBuffer(),
		FONT_COOKIE | FONT_SHADOW, ubColor
	);

	// Plan
	if(planManagerGet()->isPlanActive) {
		snprintf(
			gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%hu/%hu",
			s_pTmpPlan[ubMineral], planGetCurrent()->pMineralsRequired[ubMineral]
		);
	}
	else {
		stringCopy("-", gameGetMessageBuffer());
	}
	commDrawText(s_pColOffs[3], uwRowOffsY, gameGetMessageBuffer(), FONT_COOKIE | FONT_SHADOW, ubColor);
}

static void pageWarehouseRedraw(void) {
	for(UBYTE ubCol = 0; ubCol < 4; ++ubCol) {
		commDrawText(
			s_pColOffs[ubCol], 0, g_pMsgs[MSG_WAREHOUSE_COL_MINERAL + ubCol],
			FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT
		);
	}

	tBitMap *pBmDraw = commGetDisplayBuffer();
	const tUwCoordYX sPosDisplay = commGetOriginDisplay();
	const UBYTE ubLineHeight = commGetLineHeight();
	blitRect(
		pBmDraw, sPosDisplay.uwX, sPosDisplay.uwY + ubLineHeight,
		COMM_DISPLAY_WIDTH, 1, COMM_DISPLAY_COLOR_TEXT
	);

	s_ubPosCount = getMineralsOnList(s_pMineralsOnList);
	s_ubPosCurr = s_ubPosCount; // move to buttons on start
	for(UBYTE i = 0; i < s_ubPosCount; ++i) {
		pageWarehouseDrawRow(i);
	}

	// Buttons
	UWORD uwBtnY = COMM_DISPLAY_HEIGHT - 2 * ubLineHeight - buttonGetHeight() + 2;
	s_ubButtonCurrent = 0;
	buttonReset(BUTTON_LAYOUT_HORIZONTAL, uwBtnY);
	buttonAdd(g_pMsgs[MSG_COMM_ACCEPT]);
	buttonAdd(g_pMsgs[MSG_COMM_MARKET]);
	buttonAdd(g_pMsgs[MSG_COMM_EXIT]);
	if(commShopGetTabNavigationState() != TAB_NAVIGATION_STATE_ENABLED) {
		buttonSelect(s_ubButtonCurrent);
	}
	else {
		s_ubPosCurr = s_ubPosCount + 1;
		buttonDeselectAll();
	}
	buttonRowApply();
	buttonDrawAll(pBmDraw);

	// Time remaining
	if(planManagerGet()->isPlanActive) {
		snprintf(
			gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, g_pMsgs[MSG_COMM_TIME_REMAINING],
			planGetRemainingDays()
		);
		commDrawText(
			COMM_DISPLAY_WIDTH, COMM_DISPLAY_HEIGHT - ubLineHeight, gameGetMessageBuffer(),
			FONT_COOKIE | FONT_SHADOW | FONT_RIGHT, COMM_DISPLAY_COLOR_TEXT
		);
	}

	// Accolades
	snprintf(
		gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s %hhu",
		g_pMsgs[MSG_COMM_ACCOLADES], gameGetAccoladeCount()
	);
	commDrawText(
		0, COMM_DISPLAY_HEIGHT - 2 * ubLineHeight, gameGetMessageBuffer(),
		FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT
	);

	// Rebukes
	snprintf(
		gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s %hhu", g_pMsgs[MSG_COMM_REBUKES], gameGetRebukeCount()
	);
	commDrawText(
		0, COMM_DISPLAY_HEIGHT - ubLineHeight, gameGetMessageBuffer(),
		FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT
	);
}

static void pageWarehouseProcess(void) {
	UBYTE isButtonRefresh = 0;
	UBYTE ubPosPrev = s_ubPosCurr;
	// s_ubPosCount is row with buttons
	// s_ubPosCount + 1 is navigation row
	if(commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_DISABLING) {
		s_ubPosCurr = s_ubPosCount;
	}
	else if(commNavUse(DIRECTION_UP) && s_ubPosCurr) {
		 s_ubPosCurr = MAX(0, s_ubPosCurr - 1);
	}
	else if(commNavUse(DIRECTION_DOWN)) {
		s_ubPosCurr = MIN(s_ubPosCount + 1, s_ubPosCurr + 1);
	}

	if(s_ubPosCurr != ubPosPrev) {
		// Deselect previous pos
		if(ubPosPrev == s_ubPosCount) {
			buttonDeselectAll();
			isButtonRefresh = 1;
		}
		else if(ubPosPrev < s_ubPosCount) {
			pageWarehouseDrawRow(ubPosPrev);
		}
		// Select new pos
		if(s_ubPosCurr < s_ubPosCount) {
			pageWarehouseDrawRow(s_ubPosCurr);
		}
		else if(s_ubPosCurr == s_ubPosCount) {
			s_ubButtonCurrent = 0;
			buttonSelect(s_ubButtonCurrent);
			isButtonRefresh = 1;
		}
		else if(s_ubPosCurr == s_ubPosCount + 1) {
			buttonDeselectAll();
			commShopFocusOnTabNavigation();
			isButtonRefresh = 1;
		}
	}
	else if(s_ubPosCurr < s_ubPosCount) {
		UBYTE ubMineral = s_pMineralsOnList[s_ubPosCurr];
		// Process moving stock
		if(commNavUse(DIRECTION_LEFT)) {
			s_eUseDirection = DIRECTION_LEFT;
			s_ubUseCooldown = s_ubUseCount >= 1 ? USE_COOLDOWN_NEXT : USE_COOLDOWN_FIRST;
			++s_ubUseCount;
			if(s_pTmpPlan[ubMineral]) {
				--s_pTmpPlan[ubMineral];
				++s_pTmpStock[ubMineral];
			}
			else if(s_pTmpStock[ubMineral]) {
				++s_pTmpSell[ubMineral];
				--s_pTmpStock[ubMineral];
			}
			pageWarehouseDrawRow(ubPosPrev);
		}
		else if(commNavUse(DIRECTION_RIGHT)) {
			s_eUseDirection = DIRECTION_RIGHT;
			s_ubUseCooldown = s_ubUseCount >= 1 ? USE_COOLDOWN_NEXT : USE_COOLDOWN_FIRST;
			++s_ubUseCount;
			if(s_pTmpSell[ubMineral]) {
				--s_pTmpSell[ubMineral];
				++s_pTmpStock[ubMineral];
			}
			else if(s_pTmpStock[ubMineral] && planManagerGet()->isPlanActive) {
				++s_pTmpPlan[ubMineral];
				--s_pTmpStock[ubMineral];
			}
			pageWarehouseDrawRow(ubPosPrev);
		}
	}
	else if(s_ubPosCurr == s_ubPosCount) {
		// Navigation between buttons
		if(commNavUse(DIRECTION_RIGHT)) {
			if(s_ubButtonCurrent < 2) {
				++s_ubButtonCurrent;
				buttonSelect(s_ubButtonCurrent);
				isButtonRefresh = 1;
			}
		}
		else if(commNavUse(DIRECTION_LEFT)) {
			if(s_ubButtonCurrent > 0) {
				--s_ubButtonCurrent;
				buttonSelect(s_ubButtonCurrent);
				isButtonRefresh = 1;
			}
		}
		else if(ubPosPrev < s_ubPosCount) {
			s_ubButtonCurrent = 0;
			buttonSelect(s_ubButtonCurrent);
			isButtonRefresh = 1;
		}
	}

	if(s_eUseDirection != DIRECTION_COUNT) {
		if(!commNavCheck(s_eUseDirection)) {
			s_eUseDirection = DIRECTION_COUNT;
			s_ubUseCount = 0;
			s_ubUseCooldown = 0;
		}
		else if(s_ubUseCooldown) {
			if(--s_ubUseCooldown == 0) {
				commNavUnuse(s_eUseDirection);
			}
		}
	}

	if(isButtonRefresh) {
		buttonDrawAll(commGetDisplayBuffer());
	}

	// Process button press
	if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
		switch(buttonGetSelected()) {
			case 0: {
				// Confirm
				for(UBYTE i = 0; i < s_ubPosCount; ++i) {
					UBYTE ubMineral = s_pMineralsOnList[i];
					warehouseSetStock(ubMineral, s_pTmpStock[ubMineral]);
					planSetMinerals(ubMineral, s_pTmpPlan[ubMineral]);
					g_pVehicles[0].lCash += g_pMinerals[ubMineral].ubReward * s_pTmpSell[ubMineral];
				}
				hudSetCash(0, g_pVehicles[0].lCash);
				protestsProcess();

				if(planIsCurrentFulfilled()) {
					UBYTE wasDelayed = (planManagerGet()->eProlongState == PLAN_PROLONG_CURRENT);
					warehouseNextPlan(NEXT_PLAN_REASON_FULFILLED);

					if(wasDelayed) {
						pageOfficeTryUnlockPersonSubpage(FACE_ID_URZEDAS, COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_DELAYED);
						inboxPushBack(COMM_SHOP_PAGE_OFFICE_URZEDAS_PLAN_DELAYED, 0);
					}
				}
				commEraseAll();
				pageWarehouseRedraw();
			} break;
			case 1:
				// Market
				commShopChangePage(COMM_SHOP_PAGE_WAREHOUSE, COMM_SHOP_PAGE_MARKET);
				return;
			case 2:
				// Exit
				commRegisterPage(0, 0);
				return;
			default:
				break;
		};
	}
}

void pageWarehouseCreate(void) {
	commRegisterPage(pageWarehouseProcess, 0);
	pageWarehouseRedraw();
	s_ubUseCooldown = 0;
	s_ubUseCount = 0;
	s_eUseDirection = DIRECTION_COUNT;
}
