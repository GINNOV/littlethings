/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "page_workshop.h"
#include <ace/utils/string.h>
#include <comm/comm.h>
#include <comm/button.h>
#include <comm/gs_shop.h>
#include "../string_array.h"
#include "../vehicle.h"
#include "../inventory.h"
#include "../defs.h"
#include "../hud.h"

#define WORKSHOP_PART_ICON_WIDTH 64
#define WORKSHOP_PART_ICON_HEIGHT 56

typedef enum tWorkshopRow {
	WORKSHOP_ROW_BUY,
	WORKSHOP_ROW_EXIT,
	WORKSHOP_ROW_NAV,
} tWorkshopRow;

static tPartKind s_eSelectedPart = 0;
static tWorkshopRow s_eWorkshopRow;

static UBYTE pageWorkshopIsPartAcquirable(tPartKind ePart) {
	UBYTE isAcquirable = (
		ePart == INVENTORY_PART_TELEPORT || ePart == INVENTORY_PART_TNT ||
		ePart == INVENTORY_PART_BASE_WORKSHOP || ePart == INVENTORY_PART_BASE_PLATFORM
	);
	return isAcquirable;
}

static UBYTE pageWorkshopGetPartCurrentLevel(void) {
	if(inventoryIsBasePart(s_eSelectedPart)) {
		return inventoryGetBasePartLevel(s_eSelectedPart, baseGetCurrentId());
	}
	return inventoryGetPartDef(s_eSelectedPart)->ubLevel;
}

static void pageWorkshopSetPartCurrentLevel(UBYTE ubLevel) {
	if(inventoryIsBasePart(s_eSelectedPart)) {
		inventorySetBasePartLevel(s_eSelectedPart, baseGetCurrentId(), ubLevel);
	}
	else {
		inventorySetPartLevel(s_eSelectedPart, ubLevel);
	}
}

static ULONG pageWorkshopGetPartUpgradeCost(UBYTE ubCurrentLevel) {
	if(inventoryIsBasePart(s_eSelectedPart)) {
		return g_pUpgradeCosts[ubCurrentLevel];
	}
	else {
		return g_pUpgradeCosts[ubCurrentLevel + (s_eSelectedPart == INVENTORY_PART_TELEPORT ? 1 : 0)];
	}
}

static void pageWorkshopUpdateText(void) {
	UBYTE isActive = (s_eWorkshopRow == WORKSHOP_ROW_BUY);
	const UBYTE ubRowSize = commGetLineHeight() + 1;
	const UBYTE ubFontFlags = FONT_COOKIE | FONT_SHADOW;
	const UBYTE ubColorText = (
		isActive ? COMM_DISPLAY_COLOR_TEXT : COMM_DISPLAY_COLOR_TEXT_DARK
	);

	UWORD uwOffsY = 0;
	commDrawText(
		0, uwOffsY, inventoryIsBasePart(s_eSelectedPart) ? "BAZA" : "KRTEK 2600" ,
		ubFontFlags, ubColorText
	);
	uwOffsY += ubRowSize;

	UBYTE isAcquirable = pageWorkshopIsPartAcquirable(s_eSelectedPart);
	UBYTE ubLevel = pageWorkshopGetPartCurrentLevel();
	UBYTE ubMaxLevel = inventoryGetPartMaxLevel(s_eSelectedPart);

	UBYTE ubDisplayLevel = ubLevel + (isAcquirable ? 0 : 1);
	if(!isAcquirable || ubLevel > 0) {
		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s %s%hhu", g_pMsgs[MSG_PART_NAME_DRILL + s_eSelectedPart], g_pMsgs[MSG_COMM_MK], ubDisplayLevel);
	}
	else {
		stringCopy(g_pMsgs[MSG_PART_NAME_DRILL + s_eSelectedPart], gameGetMessageBuffer());
	}
	commDrawText(0, uwOffsY, gameGetMessageBuffer(), ubFontFlags, ubColorText);
	uwOffsY += ubRowSize;

	if(ubLevel < ubMaxLevel) {
		snprintf(
			gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s%hhu: %lu\x1F",
			g_pMsgs[MSG_COMM_UPGRADE_TO_MK],
			ubDisplayLevel + 1, pageWorkshopGetPartUpgradeCost(ubLevel)
		);
		commDrawText(0, uwOffsY, gameGetMessageBuffer(), ubFontFlags, ubColorText);
	}
	uwOffsY += 2 * ubRowSize;

	const char *szDescription = 0;
	if(ubLevel < ubMaxLevel) {
		switch(s_eSelectedPart) {
			case INVENTORY_PART_DRILL:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_DRILL];
				break;
			case INVENTORY_PART_CARGO:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_CARGO];
				break;
			case INVENTORY_PART_HULL:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_HULL];
				break;
			case INVENTORY_PART_TNT:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_TNT_0 + ubLevel];
				break;
			case INVENTORY_PART_TELEPORT:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_TELEPORT_0 + ubLevel];
				break;
			case INVENTORY_PART_BASE_PLATFORM:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_PLATFORM_0 + ubLevel];
				break;
			case INVENTORY_PART_BASE_WORKSHOP:
				szDescription = g_pMsgs[MSG_COMM_WORKSHOP_WORKSHOP_0 + ubLevel];
				break;
			default:
				break;
		}
	}
	else {
		szDescription = g_pMsgs[MSG_COMM_WORKSHOP_MAX_LVL];
	}

	uwOffsY = WORKSHOP_PART_ICON_HEIGHT;
	if(szDescription) {
		commDrawMultilineText(szDescription, 0, uwOffsY);
	}

	tUwCoordYX sButtonBuyPosition = buttonGetPosition(0);
	UBYTE ubArrowColor = (buttonGetSelected() == 0) ? COMM_DISPLAY_COLOR_TEXT_HOVER : COMM_DISPLAY_COLOR_TEXT_DARK;
	commDrawText(sButtonBuyPosition.uwX - 4, sButtonBuyPosition.uwY + 2, "<", FONT_RIGHT | FONT_VCENTER | FONT_COOKIE, ubArrowColor);
	commDrawText(sButtonBuyPosition.uwX + 5 + buttonGetWidth(0), sButtonBuyPosition.uwY + 2, ">", FONT_LEFT | FONT_VCENTER | FONT_COOKIE, ubArrowColor);

	buttonDrawAll(commGetDisplayBuffer());
}

static void pageWorkshopNavigateToPart(tPartKind ePart) {
	s_eSelectedPart = ePart;

	commEraseAll();
	tUwCoordYX sOrigin = commGetOriginDisplay();
	blitCopy(
		g_pCommWorkshopIcons, 0, WORKSHOP_PART_ICON_HEIGHT * ePart,
		commGetDisplayBuffer(),
		sOrigin.uwX + COMM_DISPLAY_WIDTH - WORKSHOP_PART_ICON_WIDTH, sOrigin.uwY,
		WORKSHOP_PART_ICON_WIDTH, WORKSHOP_PART_ICON_HEIGHT, MINTERM_COOKIE
	);

	pageWorkshopUpdateText();
}

static UBYTE pageWorkshopBuyIsMax(UBYTE ubGot, UBYTE ubMax) {
	if(ubGot < ubMax) {
		return 0;
	}
	// TODO: msg szMsg
	logWrite("pageWorkshopBuyIsMax: Exceeded max level %hhu\n", ubMax);
	return 1;
}

static tPartKind pageWorkshopGetNextPart(BYTE bDir) {
	UBYTE isPartUpgradeUnlocked = inventoryGetBasePartLevel(
		INVENTORY_PART_BASE_WORKSHOP, baseGetCurrentId()
	) >= 2;
	BYTE bNewPos = s_eSelectedPart;
	do {
		bNewPos += bDir;
		if(bNewPos >= INVENTORY_PART_COUNT) {
			bNewPos = 0;
		}
		else if(bNewPos < 0) {
			bNewPos = INVENTORY_PART_COUNT - 1;
		}

		if(isPartUpgradeUnlocked || inventoryIsBasePart(bNewPos)) {
			break;
		}
	} while((tPartKind)bNewPos != s_eSelectedPart);
	return bNewPos;
}

static void pageWorkshopProcess(void) {
	tWorkshopRow ePrevRow = s_eWorkshopRow;

	if(commNavUse(DIRECTION_UP) || commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_DISABLING) {
		if(s_eWorkshopRow > WORKSHOP_ROW_BUY) {
			--s_eWorkshopRow;
		}
	}
	if(commNavUse(DIRECTION_DOWN)) {
		if(s_eWorkshopRow < WORKSHOP_ROW_NAV) {
			++s_eWorkshopRow;
		}
	}

	if(ePrevRow != s_eWorkshopRow) {
		if(s_eWorkshopRow == WORKSHOP_ROW_NAV) {
			commShopFocusOnTabNavigation();
			buttonDeselectAll();
		}
		else {
			buttonSelect(s_eWorkshopRow);
		}
		pageWorkshopUpdateText();
	}

	if(s_eWorkshopRow == WORKSHOP_ROW_BUY) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			if(s_eSelectedPart < INVENTORY_PART_COUNT) {
				UBYTE ubLevel = pageWorkshopGetPartCurrentLevel();
				if(
					!pageWorkshopBuyIsMax(ubLevel, inventoryGetPartMaxLevel(s_eSelectedPart)) &&
					vehicleTrySpendCash(0, pageWorkshopGetPartUpgradeCost(ubLevel))
				) {
					pageWorkshopSetPartCurrentLevel(ubLevel+1);
					// text have changed, so draw everything again
					pageWorkshopNavigateToPart(s_eSelectedPart);
				}
			}
		}
		else if(commNavUse(DIRECTION_RIGHT)) {
			tPartKind eNewPart = pageWorkshopGetNextPart(+1);
			pageWorkshopNavigateToPart(eNewPart);
		}
		else if(commNavUse(DIRECTION_LEFT)) {
			tPartKind eNewPart = pageWorkshopGetNextPart(-1);
			pageWorkshopNavigateToPart(eNewPart);
		}
	}
	else if(s_eWorkshopRow == WORKSHOP_ROW_EXIT) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			// Exit
			commRegisterPage(0, 0);
		}
	}
}

void pageWorkshopCreate(void) {
	commRegisterPage(pageWorkshopProcess, 0);

	// Buttons
	UWORD uwBtnY = COMM_DISPLAY_HEIGHT - 2 * (buttonGetHeight() + 2);
	buttonReset(BUTTON_LAYOUT_VERTICAL, uwBtnY);
	buttonAdd(g_pMsgs[MSG_COMM_BUY]);
	buttonAdd(g_pMsgs[MSG_COMM_EXIT]);
	if(commShopGetTabNavigationState() == TAB_NAVIGATION_STATE_ENABLED) {
		buttonDeselectAll();
		s_eWorkshopRow = WORKSHOP_ROW_NAV;
	}
	else {
		buttonSelect(0);
		s_eWorkshopRow = WORKSHOP_ROW_BUY;
	}
	buttonRowApply();

	s_eSelectedPart = INVENTORY_PART_COUNT;
	pageWorkshopNavigateToPart(pageWorkshopGetNextPart(+1));
}
