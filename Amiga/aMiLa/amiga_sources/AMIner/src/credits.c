/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "credits.h"
#include <ace/managers/ptplayer.h>
#include <ace/utils/string.h>
#include <comm/comm.h>
#include "aminer.h"
#include "core.h"

static const char * const s_pCreditsLines[] = {
	"Aminer by Last Minute Creations",
	"lastminutecreations.itch.io/aminer",
	"",
	"Softiron: graphics, game design",
	"Luc3k: sounds, music",
	"KaiN: code",
	"",
	"Tests: afroholic7, CptPusheen, Koyot1222, kuba_slonka, Saberman, SzulcBryggeri",
	"",
	"Special thanks to: Rav.En, JakubH",
	"and two little RKLE18 testers!"
};

static void creditsGsCreate(void) {
	commEraseAll();
	UWORD uwOffsY = 0;
	UBYTE ubLineHeight = commGetLineHeight() - 2;
	for(UBYTE i = 0; i < ARRAY_SIZE(s_pCreditsLines); ++i) {
		if(stringIsEmpty(s_pCreditsLines[i])) {
			uwOffsY += ubLineHeight;
		}
		else {
			uwOffsY += commDrawMultilineText(s_pCreditsLines[i], 0, uwOffsY) * ubLineHeight;
		}
	}
}

static void creditsGsLoop(void) {
	commProcess();

	if(commNavExUse(COMM_NAV_EX_BTN_CLICK)) {
		statePop(g_pGameStateManager);
	}

	vPortWaitForEnd(g_pMainBuffer->sCommon.pVPort);
}

static void creditsGsDestroy(void) {
}

tState g_sStateMenuCredits = {
	.cbCreate = creditsGsCreate, .cbLoop = creditsGsLoop,
	.cbDestroy = creditsGsDestroy
};
