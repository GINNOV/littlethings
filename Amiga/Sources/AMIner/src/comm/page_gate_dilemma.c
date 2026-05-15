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

static void pageGateDilemmaProcess(void) {
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
		if(buttonGetSelected() == 0) {
			gameTriggerCutscene(GAME_CUTSCENE_GATE_EXPLODE);
		}
		else {
			gameTriggerCutscene(GAME_CUTSCENE_GATE_OPEN);
		}
		commRegisterPage(0, 0);
	}
}

void pageGateDilemmaCreate(void) {
	commRegisterPage(pageGateDilemmaProcess, 0);
	const UBYTE ubLineHeight = commGetLineHeight();
	UWORD uwPosY = 0;

	uwPosY += commDrawMultilineText(
		g_pMsgs[MSG_COMM_GATE_OPENING],
		0, uwPosY
	) * ubLineHeight;
	// uwPosY += ubLineHeight / 2;

	buttonInitAcceptDecline(g_pMsgs[MSG_COMM_DETONATE], g_pMsgs[MSG_COMM_DO_NOTHING]);
	buttonSelect(1);
	buttonDrawAll(commGetDisplayBuffer());
}
