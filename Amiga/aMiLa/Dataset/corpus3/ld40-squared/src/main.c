#include "main.h"
#include <ace/managers/joy.h>
#include <ace/managers/key.h>
#include <ace/managers/state.h>
#include "gamestates/game/game.h"
#include "gamestates/menu/menu.h"
#include "maths.h"

tTextBitMap *g_pTextBitMap;
tFont *g_pFont;
tStateManager *g_pStateMachine;

#define GENERIC_MAIN_LOOP_CONDITION g_pStateMachine->pCurrent
#include <ace/generic/main.h>

void inputProcess() {
	joyProcess();
	keyProcess();
}

void genericCreate(void) {
	keyCreate();
	joyOpen();
	mathsInit();

	g_pFont = fontCreate("data/silkscreen5.fnt");
	g_pTextBitMap = fontCreateTextBitMap(320, g_pTextBitMap->uwActualHeight);
	g_pStateMachine = stateManagerCreate();
	statePush(g_pStateMachine, &g_sStateMenu); // gamePushState vs gameChangeState
}

void genericProcess(void) {
	inputProcess();
	stateProcess(g_pStateMachine);
}

void genericDestroy(void) {
	stateManagerDestroy(g_pStateMachine);
	fontDestroy(g_pFont);
	fontDestroyTextBitMap(g_pTextBitMap);
	keyDestroy();
	joyClose();
}
