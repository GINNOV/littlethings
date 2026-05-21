/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "state_main.h"
#include <ace/managers/state.h>
#include <ace/managers/system.h>
#include "display.h"
#include "menu.h"
#include "chaos_arena.h"
#include "assets.h"
#include "debug.h"

tStateManager *g_pStateMachineGame;

static void stateMainCreate(void) {
	logBlockBegin("stateMainCreate()");
	g_pStateMachineGame = stateManagerCreate();
	assetsGlobalCreate();
	displayCreate();
	systemUnuse();

	displayOn();
	menuSetupMain();
	statePush(g_pStateMachineGame, &g_sStateMenu);
	logBlockEnd("stateMainCreate()");
}

static void stateMainLoop(void) {
	stateProcess(g_pStateMachineGame);
	debugSetColor(0xf00);
	displayProcess();
}

static void stateMainDestroy(void) {
	logBlockBegin("stateMainDestroy()");
	displayOff();
	stateManagerDestroy(g_pStateMachineGame);
	displayDestroy();
	assetsGlobalDestroy();
	logBlockEnd("stateMainDestroy()");
}

tState g_sStateMain = {
	.cbCreate = stateMainCreate, .cbLoop = stateMainLoop,
	.cbDestroy = stateMainDestroy
};
