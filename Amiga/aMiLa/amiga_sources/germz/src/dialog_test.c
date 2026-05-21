/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "dialog_test.h"
#include "game_editor.h"
#include <ace/utils/bmframe.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include "germz.h"
#include "game.h"
#include "assets.h"
#include "color.h"
#include "gui/dialog.h"
#include "menu_list.h"

#define DLG_TEST_PAD 16
#define DLG_TEST_WIDTH 256
#define DLG_TEST_HEIGHT 160
#define STEER_MENU_OPTION_MAX 8
#define STEER_MENU_X DLG_TEST_PAD
#define STEER_MENU_Y DLG_TEST_PAD

static tBitMap *s_pBmDlg;
static tBitMap s_sBmDlgScanline;

static tMenuListOption s_pOptionsSteer[STEER_MENU_OPTION_MAX];
static const char *s_pMenuCaptionsSteer[STEER_MENU_OPTION_MAX];
static UBYTE s_ubSteerOptionCount;

static UBYTE s_pTestSteers[4] = {
	STEER_MODE_KEY_ARROWS,
	STEER_MODE_IDLE,
	STEER_MODE_IDLE,
	STEER_MODE_IDLE
};

//---------------------------------------- This is a direct copy pasta from menu
// TODO: move it somewhere else

	// [0:P1 .. 3:P4][0: inactive, 1: active]
static const char *s_pSteerPlayerLabels[] = {
	"PLAYER 1", "PLAYER 2", "PLAYER 3", "PLAYER 4"
};

static const UBYTE s_pScanlinedMenuColors[][2] = {
	{(COLOR_P1_BRIGHT + 2) >> 1, COLOR_P1_BRIGHT >> 1},
	{(COLOR_P2_BRIGHT + 2) >> 1, COLOR_P2_BRIGHT >> 1},
	{(COLOR_P3_BRIGHT + 2) >> 1, COLOR_P3_BRIGHT >> 1},
	{(COLOR_P4_BRIGHT + 2) >> 1, COLOR_P4_BRIGHT >> 1},
};

static void scanlinedMenuUndraw(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight) {
	blitRect(&s_sBmDlgScanline, uwX, uwY, uwWidth, uwHeight, COLOR_CONSOLE_BG >> 1);
}

static void scanlinedMenuPosDraw(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
) {
	// Draw pos + non-zero shadow
	fontFillTextBitMap(g_pFontBig, g_pTextBitmap, szText);
	*pUndrawWidth = g_pTextBitmap->uwActualWidth;
	UBYTE ubPlayerIdx = 2;
	for(UBYTE i = 0; i < 4; ++i) {
		if(szCaption == s_pSteerPlayerLabels[i]) {
			ubPlayerIdx = i;
			break;
		}
	}

	UBYTE ubColor = s_pScanlinedMenuColors[ubPlayerIdx][isActive];
	fontDrawTextBitMap(
		&s_sBmDlgScanline, g_pTextBitmap, uwX, uwY, ubColor, FONT_COOKIE
	);
}
//----------------------------------------------------- Ugly copypasta ends here

static void onBack(void) {
	statePop(g_pStateMachineGame);
}

static void onStart(void) {
	// Convert UBYTE[]-based steers to tSteerMode[]
	tSteerMode pSteers[] = {
		s_pTestSteers[0], s_pTestSteers[1], s_pTestSteers[2], s_pTestSteers[3]
	};

	statePop(g_pStateMachineGame);
	gameSetRules(1, BATTLE_MODE_FFA, TEAM_CONFIG_P1_P2_AND_P3_P4, 0, pSteers);
	editorStart();
}

static void dialogTestGsCreate(void) {
	s_pBmDlg = dialogCreate(
		DLG_TEST_WIDTH, DLG_TEST_HEIGHT, gameGetBackBuffer(), gameGetFrontBuffer()
	);
	bmFrameDraw(
		g_pFrameDisplay, s_pBmDlg, 0, 0,
		DLG_TEST_WIDTH / 16, DLG_TEST_HEIGHT / 16, 16
	);

	s_sBmDlgScanline.BytesPerRow = s_pBmDlg->BytesPerRow;
	s_sBmDlgScanline.Rows = s_pBmDlg->Rows;
	s_sBmDlgScanline.Depth = 4;
	s_sBmDlgScanline.Planes[0] = s_pBmDlg->Planes[1];
	s_sBmDlgScanline.Planes[1] = s_pBmDlg->Planes[2];
	s_sBmDlgScanline.Planes[2] = s_pBmDlg->Planes[3];
	s_sBmDlgScanline.Planes[3] = s_pBmDlg->Planes[4];


	s_ubSteerOptionCount = 0;
	for(UBYTE i = 0; i < 4; ++i) {
		// if(BTST(g_sMapData.ubPlayerMask, i)) {
			s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
				MENU_LIST_OPTION_TYPE_UINT8, .isHidden = 0, .sOptUb = {
				.pVar = &s_pTestSteers[i], .ubMax = STEER_MODE_IDLE, .isCyclic = 1,
				.pEnumLabels = g_pSteerModeLabels
			}};
			s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = s_pSteerPlayerLabels[i];
		// }
	}

	// Infect
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0, .sOptCb = {.cbSelect = onStart}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "INFECT";

	// Back
	// UBYTE ubOptionIdxBack = s_ubSteerOptionCount;
	s_pOptionsSteer[s_ubSteerOptionCount] = (tMenuListOption){
		MENU_LIST_OPTION_TYPE_CALLBACK, .isHidden = 0,
		.sOptCb = {.cbSelect = onBack}
	};
	s_pMenuCaptionsSteer[s_ubSteerOptionCount++] = "BACK";

	menuListInit(
		s_pOptionsSteer, s_pMenuCaptionsSteer, s_ubSteerOptionCount,
		g_pFontBig, STEER_MENU_X, STEER_MENU_Y, scanlinedMenuUndraw,
		scanlinedMenuPosDraw
	);
	menuListSetActive(s_ubSteerOptionCount - 2);
}

static void dialogTestGsLoop(void) {
	menuListDraw();

	tDirection eDir = gameEditorProcessSteer();


	if(eDir == DIRECTION_UP) {
		menuListNavigate(-1);
	}
	else if(eDir == DIRECTION_DOWN) {
		menuListNavigate(+1);
	}
	else if(eDir == DIRECTION_LEFT) {
		menuListToggle(-1);
	}
	else if(eDir == DIRECTION_RIGHT) {
		menuListToggle(+1);
	}
	else 	if(eDir == DIRECTION_FIRE || keyUse(KEY_RETURN)) {
		// menuEnter may change gamestate, so do nothing past it
		menuListEnter();
		return;
	}

	if(keyUse(KEY_ESCAPE)) {
		onBack();
		return;
	}

	dialogProcess(gameGetBackBuffer());
	gamePostprocess();
}

static void dialogTestGsDestroy(void) {
	dialogDestroy();
}


void dialogTestShow(void) {
	statePush(g_pStateMachineGame, &g_sStateDialogTest);
}

tState g_sStateDialogTest = {
	.cbCreate = dialogTestGsCreate, .cbLoop = dialogTestGsLoop,
	.cbDestroy = dialogTestGsDestroy
};
