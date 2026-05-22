/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "page_list.h"
#include <ace/utils/string.h>
#include <comm/page_office.h>
#include <comm/comm.h>
#include <comm/page_office.h>
#include <comm/page_msg.h>
#include <comm/page_bribe.h>
#include <comm/page_accounting.h>
#include "gs_shop.h"
#include "../defs.h"
#include "../protests.h"
#include "../game.h"

#define PORTRAIT_X 0
#define PORTRAIT_Y 0
#define PORTRAIT_HEIGHT 32
#define LIST_SPACING_Y 10
#define LIST_X 40
#define LIST_Y LIST_SPACING_Y
#define TITLE_X LIST_X
#define TITLE_Y PORTRAIT_Y

static BYTE s_bPosCurr, s_bPosCount;
static const tCommShopPage *s_pCurrentList;

static void pageListDrawPos(tCommShopPage eListPage, UBYTE ubPos) {
	UBYTE ubColor = (
		ubPos == s_bPosCurr ?
		COMM_DISPLAY_COLOR_TEXT_HOVER :
		COMM_DISPLAY_COLOR_TEXT_DARK
	);
	commDrawText(
		LIST_X, LIST_Y + LIST_SPACING_Y * ubPos,
		g_pMsgs[commShopPageToTitle(eListPage)],
		FONT_COOKIE, ubColor
	);
}

static void pageListProcess(void) {
	BYTE bPrevPos = s_bPosCurr;
	if(commNavUse(DIRECTION_DOWN)) {
		if(++s_bPosCurr >= s_bPosCount) {
			s_bPosCurr = 0;
		}
	}
	else if(commNavUse(DIRECTION_UP)) {
		if(--s_bPosCurr < 0) {
			s_bPosCurr = s_bPosCount - 1;
		}
	}

	if(bPrevPos != s_bPosCurr) {
		pageListDrawPos(s_pCurrentList[bPrevPos], bPrevPos);
		pageListDrawPos(s_pCurrentList[s_bPosCurr], s_bPosCurr);
	}
	else if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
		commShopChangePage(commShopGetCurrentPage(), s_pCurrentList[s_bPosCurr]);
	}
}

void pageListCreate(tFaceId eFace, const tCommShopPage *pPages) {
	s_pCurrentList = pPages;
	commRegisterPage(pageListProcess, 0);
	s_bPosCurr = 0;

	commDrawTitle(TITLE_X, TITLE_Y, g_pMsgs[MSG_PAGE_LIST_MIETEK + eFace]);
	commDrawFaceAt(eFace, PORTRAIT_X, PORTRAIT_Y);

	tCommShopPage eListPage;
	s_bPosCount = 0;
	do {
		eListPage = pPages[s_bPosCount];
		pageListDrawPos(eListPage, s_bPosCount);
		++s_bPosCount;
	} while(eListPage != COMM_SHOP_PAGE_OFFICE_MAIN);

	// HACK HACK HACK
	if(eFace == FACE_ID_KRYSTYNA) {
		char *pEnd = stringCopy(g_pMsgs[MSG_COMM_PROTESTS_LABEL], gameGetMessageBuffer());
		*(pEnd++) = ':';
		*(pEnd++) = ' ';
		pEnd = stringCopy(g_pMsgs[MSG_COMM_PROTESTS_OK + protestsGetState()], pEnd);

		commDrawText(0, COMM_DISPLAY_HEIGHT, gameGetMessageBuffer(), FONT_BOTTOM | FONT_COOKIE, COMM_DISPLAY_COLOR_TEXT);
	}
}
