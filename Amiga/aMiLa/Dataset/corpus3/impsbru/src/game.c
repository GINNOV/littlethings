#include "game.h"

#include <ace/types.h>

#include <ace/managers/state.h>
#include <ace/managers/key.h>
#include <ace/managers/blit.h>
#include <ace/managers/viewport/simplebuffer.h>

#include <ace/utils/extview.h>
#include <ace/utils/palette.h>

#include "config.h"

#include "gamestates/menu.h"
#include "gamestates/editor.h"

const UWORD WINDOW_SCREEN_WIDTH = 320;
const UWORD WINDOW_SCREEN_HEIGHT = 256;
const UWORD WINDOW_SCREEN_BPP = 4;

tView *g_pView;
tVPort *g_pVPort;
tSimpleBufferManager *g_pBufferManager;
tStateManager *g_pGameStateManager = 0;
tState *g_pGameStates[GAME_STATE_COUNT] = {0};

#define GENERIC_MAIN_LOOP_CONDITION g_pGameStateManager->pCurrent
#include <ace/generic/main.h>

void genericCreate() {
	logBlockBegin("genericCreate()");

	keyCreate();

	g_pView = viewCreate(0,
		TAG_VIEW_GLOBAL_CLUT, 1,
	TAG_END);

	g_pVPort = vPortCreate(0,
		TAG_VPORT_VIEW, g_pView,
		TAG_VPORT_BPP, WINDOW_SCREEN_BPP,
	TAG_END);

	g_pBufferManager = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_VPORT, g_pVPort,
		TAG_SIMPLEBUFFER_IS_DBLBUF, 1,
	TAG_END);

	paletteLoad("data/impsbru.plt", g_pVPort->pPalette, 1 << g_pVPort->ubBPP);
	
	viewLoad(g_pView);

	createGameStates();
	statePush(g_pGameStateManager, g_pGameStates[GAME_STATE_MENU]);

	systemUnuse();

	logBlockEnd("genericCreate()");
}

void genericProcess() {
	keyProcess();
	stateProcess(g_pGameStateManager);

	swapBuffers();
	copyBuffer();

	vPortWaitForEnd(g_pVPort);
}

void genericDestroy() {
	logBlockBegin("genericDestroy()");

	systemUse();
	
	destroyGameStates();
	viewDestroy(g_pView);
	keyDestroy();

	logBlockEnd("genericDestroy()");
}

void createGameStates() {
	g_pGameStateManager = stateManagerCreate();

	g_pGameStates[GAME_STATE_MENU] = stateCreate(gsMenuCreate, gsMenuLoop, 0, gsMenuSuspend, gsMenuResume, 0);
	g_pGameStates[GAME_STATE_EDITOR] = stateCreate(gsEditorCreate, gsEditorLoop, gsEditorDestroy, 0, 0, g_pGameStates[GAME_STATE_EDITOR]);
}

void destroyGameStates() {
	stateManagerDestroy(g_pGameStateManager);

	UBYTE ubStateIndex = GAME_STATE_COUNT;
	while (ubStateIndex--) {
		stateDestroy(g_pGameStates[ubStateIndex]);
	}
}

void swapBuffers() {
    viewProcessManagers(g_pView);
    copProcessBlocks();
}

void copyBuffer() {
	blitCopyAligned(
		g_pBufferManager->pFront, 0, 0,
		g_pBufferManager->pBack, 0, 0,
		WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT
	);
}

void clearBuffer() {
	blitRect(
		g_pBufferManager->pBack, 0, 0,
		WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT,
		0
	);
}
