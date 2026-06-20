/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "dialog_yes_no.h"
#include <ace/utils/font.h>
#include <ace/managers/key.h>
#include "gui/button.h"
#include "gui/dialog.h"
#include "gui_scanlined.h"
#include "game_editor.h"
#include "game.h"
#include "assets.h"
#include "color.h"

static tGuiButton *s_pButtonYes, *s_pButtonNo, *s_pButtonCancel;

#define DLG_PAD 16
#define BTN_WIDTH 50
#define BTN_HEIGHT 10

void dialogYesNoCreate(
	tBitMap *pDlgBitMap, const char **pMsgLines, UBYTE ubLineCount, UBYTE isCancel
) {
	UBYTE ubButtonCount = 2;
	if(isCancel) {
		++ubButtonCount;
	}

	buttonListCreate(ubButtonCount, guiScanlinedButtonDraw);

	const UWORD uwDlgWidth = bitmapGetByteWidth(pDlgBitMap) * 8;
	const UWORD uwDlgHeight = pDlgBitMap->Rows;
	const UWORD uwBtnY = uwDlgHeight - BTN_HEIGHT - DLG_PAD;

	for(UBYTE i = 0; i < ubLineCount; ++i) {
		fontDrawStr(
			g_pFontSmall, pDlgBitMap, uwDlgWidth / 2,
			uwBtnY / 2 + g_pFontSmall->uwHeight * (i - (ubLineCount / 2)),
			pMsgLines[i], COLOR_P3_BRIGHT >> 1, FONT_COOKIE | FONT_CENTER, g_pTextBitmap
		);
	}

	s_pButtonYes = buttonAdd(
		1 * uwDlgWidth / (ubButtonCount + 1) - BTN_WIDTH / 2, uwBtnY,
		BTN_WIDTH, BTN_HEIGHT, "Yes", 0, 0
	);
	s_pButtonNo = buttonAdd(
		2 * uwDlgWidth / (ubButtonCount + 1) - BTN_WIDTH / 2, uwBtnY,
		BTN_WIDTH, BTN_HEIGHT, "No", 0, 0
	);
	if(isCancel) {
		s_pButtonCancel = buttonAdd(
			3 * uwDlgWidth / (ubButtonCount + 1) - BTN_WIDTH / 2, uwBtnY,
			BTN_WIDTH, BTN_HEIGHT, "Cancel", 0, 0
		);
	}
	buttonSelect(s_pButtonNo);
	buttonDrawAll();
}

tDialogYesNoResult dialogYesNoLoop(void) {
	tDirection eDir = gameEditorProcessSteer();
	if(eDir == DIRECTION_LEFT) {
		buttonSelectPrev();
		buttonDrawAll();
	}
	else if(eDir == DIRECTION_RIGHT) {
		buttonSelectNext();
		buttonDrawAll();
	}

	dialogProcess(gameGetBackBuffer());
	gamePostprocess();

	if(eDir == DIRECTION_FIRE || keyUse(KEY_RETURN) || keyUse(KEY_NUMENTER)) {
		if(buttonGetSelected() == s_pButtonYes) {
			return DIALOG_YES_NO_RESULT_YES;
		}
		if(buttonGetSelected() == s_pButtonNo) {
			return DIALOG_YES_NO_RESULT_NO;
		}
		return DIALOG_YES_NO_RESULT_CANCEL;
	}
	if(keyUse(KEY_ESCAPE)) {
		return DIALOG_YES_NO_RESULT_CANCEL;
	}
	return DIALOG_YES_NO_RESULT_BUSY;
}

void dialogYesNoDestroy(void) {
	buttonListDestroy();
}
