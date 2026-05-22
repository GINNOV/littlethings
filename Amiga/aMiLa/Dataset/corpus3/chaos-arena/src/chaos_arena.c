/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "chaos_arena.h"
#include <ace/generic/main.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/ptplayer.h>
#include "menu.h"
#include "tile.h"
#include "debug.h"

tStateManager *g_pStateMachineDisplay;
tRandManager g_sRandManager;

void genericCreate(void) {
	g_pStateMachineDisplay = stateManagerCreate();
	keyCreate();
	joyOpen();
	joyEnableParallel();
	ptplayerCreate(1);
	randInit(&g_sRandManager, 0x2184, 0x1911);
	statePush(g_pStateMachineDisplay, &g_sStateLogo);
}

void genericProcess(void) {
	debugSetColor(0x333);
	ptplayerProcess();
	keyProcess();
	joyProcess();

	if (keyUse(KEY_F1)) {
		debugToggle();
	}

	stateProcess(g_pStateMachineDisplay);
}

void genericDestroy(void) {
	ptplayerStop();

	stateManagerDestroy(g_pStateMachineDisplay);
	ptplayerDestroy();
	keyDestroy();
	joyClose();
}
