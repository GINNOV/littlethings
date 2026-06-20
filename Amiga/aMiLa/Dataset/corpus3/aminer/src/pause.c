#include "pause.h"
#include <ace/managers/key.h>
#include "hud.h"
#include "game.h"
#include "core.h"
#include "menu.h"
#include "steer.h"
#include "settings.h"

static UBYTE s_ubSelectionMax;

void pauseGsCreate(void) {
	hudPause(1);
	s_ubSelectionMax = (g_eGameMode == GAME_MODE_CHALLENGE) ? 2 : 3;
}

void pauseGsLoop(void) {
	tSteer *pSteers = gameGetSteers();
	steerProcess(&pSteers[0]);
	steerProcess(&pSteers[1]);
	UBYTE ubSelection = hudGetSelection();

	if(
		steerDirUse(&pSteers[0], DIRECTION_LEFT) ||
		(g_is2pPlaying && steerDirUse(&pSteers[1], DIRECTION_LEFT))
	) {
		if(ubSelection == 0) {
			hudSelect(s_ubSelectionMax - 1);
		}
		else {
			hudSelect(ubSelection - 1);
		}
	}
	else if(
		steerDirUse(&pSteers[0], DIRECTION_RIGHT) ||
		(g_is2pPlaying && steerDirUse(&pSteers[1], DIRECTION_RIGHT))
	) {
		if(++ubSelection >= s_ubSelectionMax) {
			hudSelect(0);
		}
		else {
			hudSelect(ubSelection);
		}
	}
	else if(
		steerDirUse(&pSteers[0], DIRECTION_FIRE) ||
		(g_is2pPlaying && steerDirUse(&pSteers[1], DIRECTION_FIRE)) ||
		keyUse(KEY_SPACE) || keyUse(KEY_RETURN) || keyUse(KEY_NUMENTER)
	) {
		if(ubSelection == 0) {
			stateChange(g_pGameStateManager, &g_sStateGame);
		}
		else if(ubSelection == 1) {
			if(g_eGameMode == GAME_MODE_CHALLENGE) {
				menuGsEnter(0);
			}
			else {
				gameTriggerSave();
				stateChange(g_pGameStateManager, &g_sStateGame);
			}
		}
		else if(ubSelection == 2) {
			gameTriggerSave();
			menuGsEnter(0);
		}
	}
	hudProcess();

	tView *pView = g_pMainBuffer->sCommon.pVPort->pView;
	tVPort *pVpHud = pView->pFirstVPort;
	vPortProcessManagers(pVpHud);
	copProcessBlocks();
	vPortWaitForEnd(pVpHud->pNext);
}

void pauseGsDestroy(void) {
	hudPause(0);
}

tState g_sStatePause = {
	.cbCreate = pauseGsCreate, .cbLoop = pauseGsLoop, .cbDestroy = pauseGsDestroy
};
