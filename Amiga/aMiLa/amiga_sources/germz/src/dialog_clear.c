/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ace/utils/bmframe.h>
#include "gui/dialog.h"
#include "dialog_clear.h"
#include "dialog_yes_no.h"
#include "gui_scanlined.h"
#include "game.h"
#include "germz.h"
#include "assets.h"

//----------------------------------------------------------------------- LAYOUT
#define DLG_CLEAR_WIDTH 256
#define DLG_CLEAR_HEIGHT 160

//----------------------------------------------------------------- DIALOG STATE

static UBYTE *s_pDialogResult;
static tBitMap s_sBmDlgScanlined;

static void dialogClearCreate(void) {
	tBitMap *pBmDlg = dialogCreate(
		DLG_CLEAR_WIDTH, DLG_CLEAR_HEIGHT, gameGetBackBuffer(), gameGetFrontBuffer()
	);

	// Create bitmap for scanlined draw
	s_sBmDlgScanlined.BytesPerRow = pBmDlg->BytesPerRow;
	s_sBmDlgScanlined.Rows = pBmDlg->Rows;
	s_sBmDlgScanlined.Depth = 4;
	s_sBmDlgScanlined.Flags = BMF_INTERLEAVED;
	s_sBmDlgScanlined.Planes[0] = pBmDlg->Planes[1];
	s_sBmDlgScanlined.Planes[1] = pBmDlg->Planes[2];
	s_sBmDlgScanlined.Planes[2] = pBmDlg->Planes[3];
	s_sBmDlgScanlined.Planes[3] = pBmDlg->Planes[4];
	guiScanlinedInit(&s_sBmDlgScanlined);

	bmFrameDraw(
		g_pFrameDisplay, pBmDlg, 0, 0,
		DLG_CLEAR_WIDTH / 16, DLG_CLEAR_HEIGHT / 16, 16
	);

	static const char *pMessageLines[] = {
		"Do you want to clear map without saving progress?",
	};
	*s_pDialogResult = 0;
	dialogYesNoCreate(&s_sBmDlgScanlined, pMessageLines, 1, 0);
}

static void dialogClearLoop(void) {
	tDialogYesNoResult eResult = dialogYesNoLoop();
	if(eResult != DIALOG_YES_NO_RESULT_BUSY) {
		if(eResult == DIALOG_YES_NO_RESULT_YES) {
			*s_pDialogResult = 1;
		}
		else {
			*s_pDialogResult = 0;
		}
		statePop(g_pStateMachineGame);
	}
}

static void dialogClearDestroy(void) {
	dialogYesNoDestroy();
	dialogDestroy();
}

static tState g_sStateDialogClear = {
	.cbCreate = dialogClearCreate, .cbLoop = dialogClearLoop,
	.cbDestroy = dialogClearDestroy
};

//------------------------------------------------------------------- PUBLIC FNS

void dialogClearShow(UBYTE *pResult) {
	s_pDialogResult = pResult;
	statePush(g_pStateMachineGame, &g_sStateDialogClear);
}
