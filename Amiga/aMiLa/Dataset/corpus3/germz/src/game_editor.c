/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "game_editor.h"
#include <ace/managers/game.h>
#include <ace/managers/system.h>
#include <ace/managers/key.h>
#include <ace/managers/timer.h>
#include <gui/config.h>
#include "assets.h"
#include "dialog_load.h"
#include "dialog_save.h"
#include "dialog_test.h"
#include "dialog_clear.h"
#include "game.h"
#include "game_init.h"
#include "blob_anim.h"
#include "steer.h"
#include "germz.h"

typedef struct tEditorPlayer {
	UBYTE ubX;
	UBYTE ubY;
	UBYTE ubPaletteOption;
} tEditorPlayer;

typedef enum tDialogResult {
	DIALOG_RESULT_NONE,
	DIALOG_RESULT_RELOAD_MAP,
	DIALOG_RESULT_CLEAR_MAP,
	DIALOG_RESULT_EXIT,
} tDialogResult;

typedef void (*tCbFn)(void);

static tEditorPlayer s_sPlayer;
static tDialogResult s_eDialogResult;
static tSteer s_sSteerKey, s_sSteerJoy;
static ULONG s_ulRepeatCounter;
static UBYTE s_isClear;

static tTile s_pMenuTiles[] = {
	TILE_BLOB_P1, TILE_SUPER_CAP_P1, TILE_SUPER_TICK_P1, TILE_SUPER_ATK_P1,
	TILE_PATH_H1, TILE_PATH_V1, TILE_PATH_X1, TILE_BLANK, TILE_BLANK
};
static const UBYTE s_ubMenuPosCount = sizeof(s_pMenuTiles) / sizeof(s_pMenuTiles[0]);

static tBitMap *s_pBtnSmall, *s_pBtnSmallMask, *s_pBtnBig, *s_pBtnBigMask;
static tBitMap *s_pLedSmall, *s_pLedSmallMask, *s_pLedBig, *s_pLedBigMask;
static tBobNew s_sBobBtnTile, s_sBobLedTile, s_sBobBtnFn, s_sBobLedColor;
static UBYTE s_ubCurrentColor;
static UBYTE s_ubTileDrawCount, s_ubPaletteDrawCount;

static void editorDrawMapTileAt(tUbCoordYX sPosTile) {
	const UBYTE ubFrame = BLOB_FRAME_COUNT - 1;
	blitRect(
		gameGetBackBuffer(), sPosTile.ubX * MAP_TILE_SIZE, sPosTile.ubY * MAP_TILE_SIZE,
		16, 16, 0
	);
	gameDrawTileAt(
		TILE_EDITOR_BLANK,
		sPosTile.ubX * MAP_TILE_SIZE, sPosTile.ubY * MAP_TILE_SIZE, ubFrame
	);
	gameDrawMapTileAt(sPosTile, ubFrame);
}

static void setPaletteBlobColor(UBYTE ubColor) {
	s_ubCurrentColor = ubColor;
	s_pMenuTiles[0] = TILE_BLOB_P1 + ubColor;
	s_pMenuTiles[1] = TILE_SUPER_CAP_P1 + ubColor;
	s_pMenuTiles[2] = TILE_SUPER_TICK_P1 + ubColor;
	s_pMenuTiles[3] = TILE_SUPER_ATK_P1 + ubColor;
	bobNewSetBitMapOffset(&s_sBobLedColor, 10 * ubColor);
	s_ubPaletteDrawCount = 2;
}

static void editorInitialDraw(void) {
	tBitMap *pDisplay = gameGetBackBuffer();
	blitRect(pDisplay, 0, 0, HUD_OFFS_X, 128, 0);
	blitRect(pDisplay, 0, 128, HUD_OFFS_X, 128, 0);
	bitmapLoadFromFile(pDisplay, "data/editor_hud.bm", HUD_OFFS_X, 0);

	for(UBYTE x = 0; x < MAP_SIZE; ++x) {
		for(UBYTE y = 0; y < MAP_SIZE; ++y) {
			tUbCoordYX sPos = {.ubX = x, .ubY = y};
			editorDrawMapTileAt(sPos);
		}
	}

	// Schedule tile palette drawing
	s_ubTileDrawCount = 0;
	setPaletteBlobColor(0);

	gameCopyBackToFront();
}

static void gameEditorGsCreate(void) {
	systemUse();

	s_pBtnSmall = bitmapCreateFromFile("data/btn_small.bm", 0);
	s_pBtnSmallMask = bitmapCreateFromFile("data/btn_small_mask.bm", 0);
	s_pBtnBig = bitmapCreateFromFile("data/btn_big.bm", 0);
	s_pBtnBigMask = bitmapCreateFromFile("data/btn_big_mask.bm", 0);
	s_pLedSmall = bitmapCreateFromFile("data/led_small.bm", 0);
	s_pLedSmallMask = bitmapCreateFromFile("data/led_small_mask.bm", 0);
	s_pLedBig = bitmapCreateFromFile("data/led_big.bm", 0);
	s_pLedBigMask = bitmapCreateFromFile("data/led_big_mask.bm", 0);

	bobNewManagerReset();
	bobNewInit(&s_sBobBtnTile, 16, 10, 1, s_pBtnSmall, s_pBtnSmallMask, 0, 0);
	bobNewInit(&s_sBobLedTile, 16, 10, 1, s_pLedSmall, s_pLedSmallMask, 0, 0);
	bobNewInit(&s_sBobBtnFn, 32, 10, 1, s_pBtnBig, s_pBtnBigMask, 0, 0);
	bobNewInit(&s_sBobLedColor, 32, 10, 1, s_pLedBig, s_pLedBigMask, 0, 0);
	gameInitCursorBobs();
	bobNewReallocateBgBuffers();

	s_sBobLedTile.sPos.uwX = HUD_OFFS_X + 27;
	s_sBobLedTile.sPos.uwY = 10;

	s_sBobLedColor.sPos.uwX = HUD_OFFS_X + 5;
	s_sBobLedColor.sPos.uwY = 164;

	s_sBobBtnTile.sPos.uwX = HUD_OFFS_X + 37;
	s_sBobBtnFn.sPos.uwX = HUD_OFFS_X + 29;

	systemUnuse();

	s_sSteerKey = steerInitKey(KEYMAP_ARROWS);
	s_sSteerJoy = steerInitJoy(JOY1);
	s_isClear = 0;

	s_sPlayer.ubPaletteOption = 0;
	s_sPlayer.ubX = 0;
	s_sPlayer.ubY = 0;
	s_eDialogResult = DIALOG_RESULT_NONE;
	s_ulRepeatCounter = timerGet();
	editorInitialDraw();
}

static void onChangeColor(void) {
	// Change color
	setPaletteBlobColor((s_ubCurrentColor + 1) % 5);
}

static void onClear(void) {
	dialogClearShow(&s_isClear);
	s_eDialogResult = DIALOG_RESULT_CLEAR_MAP;
}

static void onTest(void) {
	dialogTestShow();
}

static void onLoad(void) {
	dialogLoadShow();
	s_eDialogResult = DIALOG_RESULT_RELOAD_MAP;
}

static void onSave(void) {
	dialogSaveShow(0);
}

static void onQuit(void) {
	dialogSaveShow(1);
}

static const tCbFn s_pFnCallbacks[] = {
	onChangeColor, onClear, onTest, onSave, onLoad, onQuit
};
static const UBYTE s_ubFnBtnCount = sizeof(s_pFnCallbacks) / sizeof(s_pFnCallbacks[0]);

static void gameEditorGsLoop(void) {
	if(keyUse(KEY_ESCAPE)) {
		onQuit();
		return;
	}

	if(s_eDialogResult != DIALOG_RESULT_NONE) {
		if(s_eDialogResult == DIALOG_RESULT_RELOAD_MAP) {
			editorInitialDraw();
		}
		else if(s_eDialogResult == DIALOG_RESULT_CLEAR_MAP) {
			if(s_isClear) {
				s_isClear = 0;
				mapDataClear(&g_sMapData);
			}
			editorInitialDraw();
		}
		s_eDialogResult = DIALOG_RESULT_NONE;
		return;
	}

	UBYTE ubFnBtnPressed = s_ubFnBtnCount;
	for(UBYTE i = 0; i < s_ubFnBtnCount; ++i) {
		if(keyCheck(KEY_F1 + i)) {
			ubFnBtnPressed = i;
			break;
		}
	}
	if(ubFnBtnPressed != s_ubFnBtnCount && keyUse(KEY_F1 + ubFnBtnPressed)) {
		bobNewSetBitMapOffset(&s_sBobBtnFn, ubFnBtnPressed * 10);
		s_sBobBtnFn.sPos.uwY = 164 + ubFnBtnPressed * 14;
		s_pFnCallbacks[ubFnBtnPressed]();
		// Don't process anything else since callbacks could change game state
		return;
	}

	if(!gamePreprocess(0)) {
		return;
	}

	// Process tile button press
	UBYTE ubTileBtnPressed = s_ubMenuPosCount;
	for(UBYTE i = 0; i < s_ubMenuPosCount; ++i) {
		if(keyCheck(KEY_1 + i)) {
			ubTileBtnPressed = i;
			break;
		}
	}
	if(ubTileBtnPressed != s_ubMenuPosCount) {
		s_sBobLedTile.sPos.uwY = 10 + ubTileBtnPressed * 17;
		s_sBobBtnTile.sPos.uwY = 10 + ubTileBtnPressed * 17;
		bobNewSetBitMapOffset(&s_sBobBtnTile, ubTileBtnPressed * 10);
		s_sPlayer.ubPaletteOption = ubTileBtnPressed;
	}

	if(s_ubPaletteDrawCount) {
		--s_ubPaletteDrawCount;
		for(UBYTE i = 0; i < s_ubMenuPosCount; ++i) {
			gameDrawTileAt(
				s_pMenuTiles[i], HUD_OFFS_X + 6, 7 + i * (MAP_TILE_SIZE + 1),
				BLOB_FRAME_COUNT - 1
			);
		}
	}
	else if(s_ubTileDrawCount) {
		--s_ubTileDrawCount;

		tUbCoordYX sPosCurr = {.ubX = s_sPlayer.ubX, .ubY = s_sPlayer.ubY};
		editorDrawMapTileAt(sPosCurr);
	}
	else {
		// Hackty hack
		tDirection eDir = gameEditorProcessSteer();

		switch(eDir) {
			case DIRECTION_UP:
				if(s_sPlayer.ubY > 0) {
					--s_sPlayer.ubY;
				}
				break;
			case DIRECTION_DOWN:
				if(s_sPlayer.ubY < MAP_SIZE - 1) {
					++s_sPlayer.ubY;
				}
				break;
			case DIRECTION_LEFT:
				if(s_sPlayer.ubX > 0) {
					--s_sPlayer.ubX;
				}
				break;
			case DIRECTION_RIGHT:
				if(s_sPlayer.ubX < MAP_SIZE - 1) {
					++s_sPlayer.ubX;
				}
				break;
			case DIRECTION_FIRE: {
				tTile eTile = s_pMenuTiles[s_sPlayer.ubPaletteOption];
				g_sMapData.pTiles[s_sPlayer.ubX][s_sPlayer.ubY] = eTile;
				s_ubTileDrawCount = 2;
			} break;
			default:
				break;
		}
	}

	// Now that all manual blits are done draw bobs
	if(ubFnBtnPressed != s_ubFnBtnCount) {
		bobNewPush(&s_sBobBtnFn);
	}
	if(ubTileBtnPressed != s_ubMenuPosCount) {
		bobNewPush(&s_sBobBtnTile);
	}
	bobNewPush(&s_sBobLedTile);
	bobNewPush(&s_sBobLedColor);

	tBobNew *pBobCursor = gameGetCursorBob(0);
	pBobCursor->sPos.uwX = s_sPlayer.ubX * MAP_TILE_SIZE;
	pBobCursor->sPos.uwY = s_sPlayer.ubY * MAP_TILE_SIZE;
	bobNewPush(pBobCursor);

	gamePostprocess();
}

static void gameEditorGsDestroy(void) {
	systemUse();
	bitmapDestroy(s_pBtnSmall);
	bitmapDestroy(s_pBtnSmallMask);
	bitmapDestroy(s_pBtnBig);
	bitmapDestroy(s_pBtnBigMask);
	bitmapDestroy(s_pLedSmall);
	bitmapDestroy(s_pLedSmallMask);
	bitmapDestroy(s_pLedBig);
	bitmapDestroy(s_pLedBigMask);
	systemUnuse();
}

tDirection gameEditorProcessSteer(void) {
	steerProcess(&s_sSteerKey);
	steerProcess(&s_sSteerJoy);

	UBYTE isRepeat = timerGetDelta(s_ulRepeatCounter, timerGet()) >= 10;

	tDirection eDir;
	for(eDir = 0; eDir < DIRECTION_COUNT; ++eDir) {
		if(
			(steerDirUse(&s_sSteerKey, eDir) || (steerDirCheck(&s_sSteerKey, eDir) && isRepeat)) ||
			(steerDirUse(&s_sSteerJoy, eDir) || (steerDirCheck(&s_sSteerJoy, eDir) && isRepeat))
		) {
			s_ulRepeatCounter = timerGet();
			break;
		}
	}

	return eDir;
}

tState g_sStateEditor = {
	.cbCreate = gameEditorGsCreate, .cbLoop = gameEditorGsLoop,
	.cbDestroy = gameEditorGsDestroy
};

void editorStart(void) {
	mapDataRecalculateStuff(&g_sMapData);

	// Simulate fadeout to prevent flicker on gameInit
	for(UBYTE i = 0 ; i < 32; ++i) {
		gameGetFade()->pView->pFirstVPort->pPalette[i] = 0;
	}
	viewUpdateCLUT(gameGetFade()->pView);

	stateChange(g_pStateMachineGame, &g_sStateGameInit);
}
