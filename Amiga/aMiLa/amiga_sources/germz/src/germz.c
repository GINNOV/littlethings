/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ace/generic/main.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/managers/state.h>
#include <ace/managers/ptplayer.h>
#include "germz.h"
#include "logo.h"
#include "assets.h"
#include "music.h"

tStateManager *g_pStateMachineGame;

void genericCreate(void) {
	g_pStateMachineGame = stateManagerCreate();
	keyCreate();
	joyOpen();
	ptplayerCreate(1);
	assetsGlobalCreate();
	statePush(g_pStateMachineGame, &g_sStateLogo);
}

void genericProcess(void) {
	ptplayerProcess();
	keyProcess();
	joyProcess();
	stateProcess(g_pStateMachineGame);
}

void genericDestroy(void) {
	ptplayerDestroy();
	assetsGlobalDestroy();
	keyDestroy();
	joyClose();
	stateManagerDestroy(g_pStateMachineGame);
}
