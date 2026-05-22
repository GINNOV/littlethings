/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "game_init.h"
#include <ace/managers/game.h>
#include <ace/managers/system.h>
#include "game.h"
#include "assets.h"
#include "game_play.h"
#include "map.h"
#include "fade.h"
#include "germz.h"

static UBYTE s_isDrawnOnce;
static UBYTE s_ubCurrY;
static UBYTE s_ubWaitFrame = 0;

static UBYTE initialAnim(void) {
	UBYTE isDrawnAnyBlob = 0;
	UBYTE ubY = s_ubCurrY;
	UBYTE ubFrame = s_ubWaitFrame;
	while(!isDrawnAnyBlob && ubY < MAP_SIZE) {
		for(UBYTE ubX = 0; ubX < MAP_SIZE; ++ubX) {
			tTile eTile = g_sMapData.pTiles[ubX][ubY];
			if(tileIsNode(eTile)) {
				isDrawnAnyBlob = 1;
			}
			tUbCoordYX sPos = {.ubX = ubX, .ubY = ubY};
			gameDrawMapTileAt(sPos, ubFrame);
		}

		if(!isDrawnAnyBlob || ++ubFrame >= BLOB_FRAME_COUNT) {
			ubFrame = 0;
			++ubY;
		}
	};


	if(s_isDrawnOnce) {
		s_ubCurrY = ubY;
		s_ubWaitFrame = ubFrame;
		if(ubY >= MAP_SIZE) {
			return 1;
		}
	}
	s_isDrawnOnce = !s_isDrawnOnce;
	return 0;
}

//-------------------------------------------------------------------- GAMESTATE

static void gameInitGsCreate(void) {
	s_isDrawnOnce = 0;
	s_ubCurrY = 0;
	s_ubWaitFrame = 0;
	tBitMap *pDisplay = gameGetBackBuffer();

	bobNewDiscardUndraw();

	bitmapLoadFromFile(pDisplay, "data/game_hud.bm", HUD_OFFS_X, 0);
	bitmapLoadFromFile(pDisplay, "data/game_bg.bm", 0, 0);

	// Draw monitors on back buffer
	for(UBYTE i = 1; i < 4; ++i) {
		blitCopyAligned(
			pDisplay, HUD_OFFS_X, 0, pDisplay,
			HUD_OFFS_X, i * HUD_MONITOR_SIZE, HUD_MONITOR_SIZE, HUD_MONITOR_SIZE
		);
	}

	// Draw tiled bg on back buffer
	for(UBYTE x = 0; x < 256 / 64; ++x) {
		for(UBYTE y = 0; y < 256 / 64; ++y) {
			if(x == 0 && y == 0) {
				continue;
			}
			UBYTE ubSrcY = 0;
			blitCopyAligned(pDisplay, 0, ubSrcY, pDisplay, x * 64, y * 64, 64, 64);
		}
	}

	gameCopyBackToFront();

	bobNewManagerReset();
	gameInitCursorBobs();
	gameInitMap();
	bobNewReallocateBgBuffers();
}

static void gameInitGsLoop(void) {
	if(!gamePreprocess(1)) {
		return;
	}
	if(initialAnim() && gameGetFade()->eState == FADE_STATE_IDLE) {
		stateChange(g_pStateMachineGame, &g_sStateGamePlay);
		return;
	}
	gamePostprocess();
}

static void gameInitGsDestroy(void) {

}

tState g_sStateGameInit = {
	.cbCreate = gameInitGsCreate, .cbLoop = gameInitGsLoop,
	.cbDestroy = gameInitGsDestroy
};
