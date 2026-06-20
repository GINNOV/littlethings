#include "gamestates/menu.h"

#include <ace/managers/log.h>
#include <ace/managers/key.h>
#include <ace/managers/state.h>
#include <ace/managers/game.h>
#include <ace/managers/system.h>

#include <ace/utils/bitmap.h>

#include "game.h"

#include "gamestates/editor.h"

void gsMenuCreate() {
	logBlockBegin("gsMenuCreate()");

	systemUse();

	drawLogo();

	systemUnuse();

	logBlockEnd("gsMenuCreate()");
}

void gsMenuLoop() {
	if (keyUse(KEY_RETURN) || keyUse(KEY_SPACE)) {
		statePush(g_pGameStateManager, g_pGameStates[GAME_STATE_EDITOR]);
	}

	if (keyUse(KEY_ESCAPE) || keyUse(KEY_BACKSPACE)) {
		statePop(g_pGameStateManager);
	}
}

void gsMenuSuspend() {
	logBlockBegin("gsMenuSuspend()");

	clearBuffer();

	logBlockEnd("gsMenuSuspend()");
}

void gsMenuResume() {
	logBlockBegin("gsMenuResume()");

	systemUse();

	drawLogo();
	
	systemUnuse();

	logBlockEnd("gsMenuResume()");
}

void drawLogo() {
	bitmapLoadFromFile(g_pBufferManager->pBack, "data/menu_frames/logo.bm", 0, 0);
}
