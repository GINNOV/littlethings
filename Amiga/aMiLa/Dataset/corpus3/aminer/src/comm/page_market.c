/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "page_market.h"
#include <ace/utils/string.h>
#include <comm/comm.h>
#include <comm/button.h>
#include <comm/gs_shop.h>
#include <comm/page_warehouse.h>
#include "defs.h"
#include "warehouse.h"
#include "save.h"
#include "game.h"

#define TARGET_ROW_COUNT 4
#define MARKET_LINE_HEIGHT 9
#define MARKET_PRICE_INCREMENT 4

#define MARKET_ROW_SOURCE_Y 0
#define MARKET_ROW_SOURCE_STOCK_Y MARKET_LINE_HEIGHT
#define MARKET_ROW_TARGET_LEGEND_Y (MARKET_ROW_SOURCE_STOCK_Y + (3 * MARKET_LINE_HEIGHT) / 2)
#define MARKET_ROW_FIRST_TARGET_Y (MARKET_ROW_TARGET_LEGEND_Y + (3 * MARKET_LINE_HEIGHT) / 2)

#define MARKET_SOURCE_STOCK_WIDTH 100
#define MARKET_TRADE_COLUMN_WIDTH 70
#define MARKET_STOCK_COLUMN_WIDTH 30

typedef enum tMarketRow {
	MARKET_ROW_SOURCE_MINERAL,
	MARKET_ROW_TARGET_FIRST,
	MARKET_ROW_TARGET_2,
	MARKET_ROW_TARGET_3,
	MARKET_ROW_TARGET_LAST,
	MARKET_ROW_BUTTTONS,
	MARKET_ROW_COUNT
} tMarketRow;

typedef struct tTargetMineral {
	tMineralType eMineral;
	UBYTE ubPrice;
} tTargetMineral;

//----------------------------------------------------------------- PRIVATE VARS

static tMarketRow s_eRow;
static tMineralType s_eSource;
static tTargetMineral s_pTargets[TARGET_ROW_COUNT];
static UWORD s_uwResourcesTraded;

//------------------------------------------------------------ PRIVATE FUNCTIONS

static void drawSourceStock(void) {
	UWORD uwY = MARKET_ROW_SOURCE_STOCK_Y;
	UWORD uwX = 0;
	commErase(uwX, uwY, MARKET_SOURCE_STOCK_WIDTH, MARKET_LINE_HEIGHT);
	snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s: %hu", g_pMsgs[MSG_COMM_STOCK], warehouseGetStock(s_eSource));
	commDrawText(
		uwX, uwY, gameGetMessageBuffer(), FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT
	);
}

static void drawRowStock(tMarketRow eRow) {
	UBYTE ubColor = (
		(eRow == s_eRow) ?
		COMM_DISPLAY_COLOR_TEXT_HOVER :
		COMM_DISPLAY_COLOR_TEXT_DARK
	);

	UBYTE ubTargetIndex = eRow - MARKET_ROW_TARGET_FIRST;
	const tTargetMineral *pTarget = &s_pTargets[ubTargetIndex];
	UWORD uwY = MARKET_ROW_FIRST_TARGET_Y + ubTargetIndex * MARKET_LINE_HEIGHT;
	UWORD uwX = COMM_DISPLAY_WIDTH - MARKET_STOCK_COLUMN_WIDTH;
	char szStock[sizeof("65535")];

	commErase(uwX, uwY, MARKET_STOCK_COLUMN_WIDTH, MARKET_LINE_HEIGHT);
	stringDecimalFromULong(warehouseGetStock(pTarget->eMineral), szStock);
	commDrawText(uwX, uwY, szStock, FONT_COOKIE | FONT_SHADOW, ubColor);
}

static void drawRow(tMarketRow eRow) {
	UBYTE ubColor = (
		(eRow == s_eRow) ?
		COMM_DISPLAY_COLOR_TEXT_HOVER :
		COMM_DISPLAY_COLOR_TEXT_DARK
	);

	if(eRow == MARKET_ROW_SOURCE_MINERAL) {
		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%s: < %s >", g_pMsgs[MSG_WAREHOUSE_COL_MINERAL], g_pMsgs[MSG_MINERAL_SILVER + s_eSource]);
		commDrawText(0, 0, gameGetMessageBuffer(), FONT_COOKIE | FONT_SHADOW, ubColor);
	}
	else if(MARKET_ROW_TARGET_FIRST <= eRow && eRow <= MARKET_ROW_TARGET_LAST) {
		UBYTE ubTargetIndex = eRow - MARKET_ROW_TARGET_FIRST;
		const tTargetMineral *pTarget = &s_pTargets[ubTargetIndex];
		UWORD uwY = MARKET_ROW_FIRST_TARGET_Y + ubTargetIndex * MARKET_LINE_HEIGHT;

		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%hhux %s", pTarget->ubPrice, g_pMsgs[MSG_MINERAL_SILVER + s_eSource]);
		commDrawText(0, uwY, gameGetMessageBuffer(), FONT_COOKIE | FONT_SHADOW, ubColor);

		snprintf(gameGetMessageBuffer(), GAME_MESSAGE_BUFFER_SIZE, "%hhux %s", 1, g_pMsgs[MSG_MINERAL_SILVER + pTarget->eMineral]);
		commDrawText(MARKET_TRADE_COLUMN_WIDTH, uwY, gameGetMessageBuffer(), FONT_COOKIE | FONT_SHADOW, ubColor);

		drawRowStock(eRow);
	}
	else if(eRow == MARKET_ROW_BUTTTONS) {
		buttonDrawAll(commGetDisplayBuffer());
	}
}

static void setSource(tMineralType eSource) {
	s_eSource = eSource;

	// Update targets
	UBYTE ubTargetIdx = 0;
	UBYTE ubPrice = MARKET_PRICE_INCREMENT;
	for(tMineralType eMineral = MINERAL_TYPE_SILVER; eMineral < MINERAL_TYPE_COAL; ++eMineral) {
		if(eMineral != eSource) {
			s_pTargets[ubTargetIdx].eMineral = eMineral;
			if(eMineral < s_eSource) {
				s_pTargets[ubTargetIdx].ubPrice = 1;
			}
			else {
				s_pTargets[ubTargetIdx].ubPrice = ubPrice;
				ubPrice += MARKET_PRICE_INCREMENT;
			}
			++ubTargetIdx;
		}
	}

	commEraseAll();
	drawSourceStock();
	commDrawText(0, MARKET_ROW_TARGET_LEGEND_Y, g_pMsgs[MSG_COMM_MARKET_TRADE_COL], FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT);
	commDrawText(MARKET_TRADE_COLUMN_WIDTH, MARKET_ROW_TARGET_LEGEND_Y, g_pMsgs[MSG_COMM_MARKET_FOR_COL], FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT);
	commDrawText(COMM_DISPLAY_WIDTH - MARKET_STOCK_COLUMN_WIDTH, MARKET_ROW_TARGET_LEGEND_Y, g_pMsgs[MSG_COMM_STOCK], FONT_COOKIE | FONT_SHADOW, COMM_DISPLAY_COLOR_TEXT);

	for(tMarketRow eRow = 0; eRow < MARKET_ROW_COUNT; ++eRow) {
		drawRow(eRow);
	}
	buttonDrawAll(commGetDisplayBuffer());
}

static UBYTE tryTrade(void) {
	UBYTE ubTargetIndex = s_eRow - MARKET_ROW_TARGET_FIRST;
	const tTargetMineral *pTarget = &s_pTargets[ubTargetIndex];

	UWORD uwSourceStock = warehouseGetStock(s_eSource);
	if(uwSourceStock < pTarget->ubPrice) {
		return 0;
	}

	uwSourceStock -= pTarget->ubPrice;
	warehouseSetStock(s_eSource, uwSourceStock);
	warehouseSetStock(pTarget->eMineral, warehouseGetStock(pTarget->eMineral) + 1);
	s_uwResourcesTraded += pTarget->ubPrice;
	return 1;
}

static void pageMarketProcess(void) {
	tMarketRow ePrevRow = s_eRow;
	if(commNavUse(DIRECTION_UP)) {
		if(s_eRow) {
			--s_eRow;
		}
	}
	if(commNavUse(DIRECTION_DOWN)) {
		if(s_eRow < MARKET_ROW_BUTTTONS) {
			++s_eRow;
		}
	}

	if(s_eRow != ePrevRow) {
		if(s_eRow == MARKET_ROW_BUTTTONS) {
			buttonSelect(0);
		}
		else if(ePrevRow == MARKET_ROW_BUTTTONS) {
			buttonDeselectAll();
		}

		// Update highlight
		drawRow(ePrevRow);
		drawRow(s_eRow);
	}

	if(s_eRow == MARKET_ROW_SOURCE_MINERAL) {
		tMineralType eNewSource = s_eSource;
		if(commNavUse(DIRECTION_LEFT)) {
			if(eNewSource > MINERAL_TYPE_SILVER) {
				--eNewSource;
			}
			else {
				eNewSource = MINERAL_TYPE_MOONSTONE;
			}
		}
		if(commNavUse(DIRECTION_RIGHT)) {
			if(eNewSource < MINERAL_TYPE_MOONSTONE) {
				++eNewSource;
			}
			else {
				eNewSource = MINERAL_TYPE_SILVER;
			}
		}

		if(eNewSource != s_eSource) {
			setSource(eNewSource);
		}
	}
	else if(MARKET_ROW_TARGET_FIRST <= s_eRow && s_eRow <= MARKET_ROW_TARGET_LAST) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			UBYTE isTraded = tryTrade();
			if(isTraded) {
				drawSourceStock();
				drawRowStock(s_eRow);
			}
		}
	}
	else if(s_eRow == MARKET_ROW_BUTTTONS) {
		if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
			commShopGoBack();
			return;
		}
	}
}

static void pageMarketDestroy(void) {

}

//------------------------------------------------------------- PUBLIC FUNCTIONS

void pageMarketCreate(void) {
	commRegisterPage(pageMarketProcess, pageMarketDestroy);
	buttonInitOk(g_pMsgs[MSG_COMM_EXIT]);
	buttonDeselectAll();
	s_eRow = MARKET_ROW_SOURCE_MINERAL;
	setSource(MINERAL_TYPE_SILVER);
}

void pageMarketReset(void) {
	s_uwResourcesTraded = 0;
}

void pageMarketSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_MARKET);
	fileWrite(pFile, &s_uwResourcesTraded, sizeof(s_uwResourcesTraded));
	saveWriteTag(pFile, SAVE_TAG_MARKET_END);
}

UBYTE pageMarketLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_MARKET)) {
		return 0;
	}
	fileRead(pFile, &s_uwResourcesTraded, sizeof(s_uwResourcesTraded));
	return saveReadTag(pFile, SAVE_TAG_MARKET_END);
}

UBYTE pageMarketGetResourcesTraded(void) {
	return s_uwResourcesTraded;
}
