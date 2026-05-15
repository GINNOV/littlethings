/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "aminer.h"
#define GENERIC_MAIN_LOOP_CONDITION g_pGameStateManager->pCurrent
#include <ace/generic/main.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/ptplayer.h>
#include "logo.h"
#include "sorry.h"
#include "assets.h"

tStateManager *g_pGameStateManager;

void genericCreate(void) {
	keyCreate();
	joyOpen();
	g_pGameStateManager = stateManagerCreate();

#if defined(USE_PAK_FILE)
	g_pPakFile = pakFileOpen("data.pak", 0);
#endif

	// Bare minimum
	ptplayerCreate(1);
	ptplayerSetChannelsForPlayer(0b0111);
	ptplayerSetMasterVolume(8);
	g_pFont = fontCreateFromFd(GET_SUBFILE_PREFIX("uni54.fnt"));
	if(memGetFreeChipSize() < 900 * 1024 || memGetFreeSize() < 1600 * 1024) {
		sorryReset(0);
		statePush(g_pGameStateManager, &g_sStateSorry);
	}
	else if(!systemIsStartVolumeWritable()) {
		sorryReset(1);
		statePush(g_pGameStateManager, &g_sStateSorry);
	}
	else {
		statePush(g_pGameStateManager, &g_sStateLogo);
	}
}

void genericProcess(void) {
	keyProcess();
	joyProcess();
	stateProcess(g_pGameStateManager);
}

void genericDestroy(void) {
	fontDestroy(g_pFont);
	ptplayerDestroy();

#if defined(USE_PAK_FILE)
	pakFileClose(g_pPakFile);
#endif

	stateManagerDestroy(g_pGameStateManager);
	keyDestroy();
	joyClose();
}
