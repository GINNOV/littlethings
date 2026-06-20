/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "dialog_load.h"
#include <gui/dialog.h>
#include <gui/list_ctl.h>
#include <gui/button.h>
#include <ace/utils/dir.h>
#include <ace/utils/bmframe.h>
#include <ace/managers/game.h>
#include <ace/managers/key.h>
#include "game_editor.h"
#include "dialog_save.h"
#include "game.h"
#include "assets.h"
#include "germz.h"
#include "map_list.h"
#include "gui_scanlined.h"

//----------------------------------------------------------------------- Layout
#define DLG_LOAD_PAD 16
#define DLG_LOAD_WIDTH 256
#define DLG_LOAD_HEIGHT 160

#define MAP_LIST_X DLG_LOAD_PAD
#define MAP_LIST_Y DLG_LOAD_PAD
#define MAP_LIST_WIDTH ((DLG_LOAD_WIDTH - 2 * DLG_LOAD_PAD) / 2)
#define MAP_LIST_HEIGHT (DLG_LOAD_HEIGHT - 2 * DLG_LOAD_PAD)

#define PREVIEW_X (MAP_LIST_X + MAP_LIST_WIDTH + 10)
#define PREVIEW_Y (MAP_LIST_Y)
#define PREVIEW_TILE_SIZE 4

#define INFO_X PREVIEW_X
#define INFO_Y (PREVIEW_Y + 16 * PREVIEW_TILE_SIZE + 10)

#define BTN_LOAD_WIDTH 50
#define BTN_LOAD_HEIGHT 10
#define BTN_LOAD_X (INFO_X + (DLG_LOAD_WIDTH - INFO_X - DLG_LOAD_PAD) / 2)
#define BTN_LOAD_Y (DLG_LOAD_HEIGHT - DLG_LOAD_PAD - BTN_LOAD_HEIGHT / 2)
//------------------------------------------------------------------- Layout end

static tListCtl *s_pCtrl;
static tMapData *s_pPreview;
static tBitMap *s_pBmDlg;
static ULONG s_ullChangeTimer; // Inactive if set to 0.
static tBitMap s_sBmDlgScanlined;
static char s_szCurrentDir[100];
static const char *s_szBasePath = "data/maps";

static void invalidateMapSelection(void) {
	clearMapInfo(&s_sBmDlgScanlined, INFO_X, INFO_Y, 0);
	s_ullChangeTimer = timerGet();
}

static void dialogLoadGsCreate(void) {
	s_pBmDlg = dialogCreate(
		DLG_LOAD_WIDTH, DLG_LOAD_HEIGHT, gameGetBackBuffer(), gameGetFrontBuffer()
	);
	bmFrameDraw(
		g_pFrameDisplay, s_pBmDlg, 0, 0,
		DLG_LOAD_WIDTH / 16, DLG_LOAD_HEIGHT / 16, 16
	);
	s_pPreview = memAllocFast(sizeof(*s_pPreview));

	// Create bitmap for scanlined draw
	s_sBmDlgScanlined.BytesPerRow = s_pBmDlg->BytesPerRow;
	s_sBmDlgScanlined.Rows = s_pBmDlg->Rows;
	s_sBmDlgScanlined.Depth = 4;
	s_sBmDlgScanlined.Flags = BMF_INTERLEAVED;
	s_sBmDlgScanlined.Planes[0] = s_pBmDlg->Planes[1];
	s_sBmDlgScanlined.Planes[1] = s_pBmDlg->Planes[2];
	s_sBmDlgScanlined.Planes[2] = s_pBmDlg->Planes[3];
	s_sBmDlgScanlined.Planes[3] = s_pBmDlg->Planes[4];
	guiScanlinedInit(&s_sBmDlgScanlined);

	gameSetSpecialColors(0x333, 0x222);

	// Map list
	strcpy(s_szCurrentDir, s_szBasePath);
	buttonListCreate(5, guiScanlinedButtonDraw);
	s_pCtrl = mapListCreateCtl(
		&s_sBmDlgScanlined, MAP_LIST_X, MAP_LIST_Y, MAP_LIST_WIDTH, MAP_LIST_HEIGHT,
		s_szBasePath, s_szCurrentDir
	);
	if(!s_pCtrl) {
		statePop(g_pStateMachineGame);
	}

	// Info & Preview
	invalidateMapSelection();

	// Button: "Load"
	tGuiButton *pButtonLoad = buttonAdd(
		BTN_LOAD_X, BTN_LOAD_Y, BTN_LOAD_WIDTH, BTN_LOAD_HEIGHT, "Load", 0, 0
	);
	buttonSelect(pButtonLoad);

	// Initial draw
	listCtlDraw(s_pCtrl);
	buttonDrawAll();
}

static void dialogLoadGsLoop(void) {
	if(!gamePreprocess(0)) {
		return;
	}

	UBYTE isMapSelected = 0;
	tDirection eDir = gameEditorProcessSteer();
	if(
		(eDir == DIRECTION_UP && listCtlSelectPrev(s_pCtrl)) ||
		(eDir == DIRECTION_DOWN && listCtlSelectNext(s_pCtrl))
	) {
		invalidateMapSelection();
	}
	else if(eDir == DIRECTION_FIRE || keyUse(KEY_RETURN) || keyUse(KEY_NUMENTER)) {
		// No processing via the OK button callback - code is shorter that way
		const tListCtlEntry *pSelection = listCtlGetSelection(s_pCtrl);
		tMapEntryType eType = (tMapEntryType)pSelection->pData;
		if(eType == MAP_ENTRY_TYPE_DIR) {
			UWORD uwLenOld = strlen(s_szCurrentDir);
			if(uwLenOld + 1 + strlen(pSelection->szLabel) < sizeof(s_szCurrentDir)) {
				// Append subdirectory to current path, skip icon char
				sprintf(&s_szCurrentDir[uwLenOld], "/%s", &pSelection->szLabel[1]);
			}
			invalidateMapSelection();
			mapListFillWithDir(s_pCtrl, s_szCurrentDir);
			listCtlDraw(s_pCtrl);
			buttonDrawAll();
		}
		else if(eType == MAP_ENTRY_TYPE_PARENT) {
			char *pLastPos = strrchr(s_szCurrentDir, '/');
			if(pLastPos) {
				*pLastPos = '\0';
			}
			invalidateMapSelection();
			mapListFillWithDir(s_pCtrl, s_szCurrentDir);
			listCtlDraw(s_pCtrl);
			buttonDrawAll();
		}
		else {
			mapListLoadMap(s_pCtrl, s_pPreview, s_szCurrentDir);
			memcpy(&g_sMapData, s_pPreview, sizeof(g_sMapData));
			dialogSaveSetSaveName(
				&s_szCurrentDir[strlen(s_szBasePath)],
				listCtlGetSelection(s_pCtrl)->szLabel
			);
			isMapSelected = 1;
		}
	}

	if(s_ullChangeTimer && timerGetDelta(s_ullChangeTimer, timerGet()) >= 25) {
		mapListLoadMap(s_pCtrl, s_pPreview, s_szCurrentDir);
		mapInfoDrawAuthorTitle(s_pPreview, &s_sBmDlgScanlined, INFO_X, INFO_Y);
		mapListDrawPreview(
			s_pPreview, &s_sBmDlgScanlined, PREVIEW_X, PREVIEW_Y, PREVIEW_TILE_SIZE
		);
		s_ullChangeTimer = 0;
	}

	// Copy dialog bitmap to screen
	dialogProcess(gameGetBackBuffer());

	gamePostprocess();

	if(isMapSelected || keyUse(KEY_ESCAPE)) {
		statePop(g_pStateMachineGame);
	}
}

static void dialogLoadGsDestroy(void) {
	memFree(s_pPreview, sizeof(*s_pPreview));
	buttonListDestroy();
	listCtlDestroy(s_pCtrl);
	dialogDestroy();
}


void dialogLoadShow(void) {
	statePush(g_pStateMachineGame, &g_sStateDialogLoad);
}

tState g_sStateDialogLoad = {
	.cbCreate = dialogLoadGsCreate, .cbLoop = dialogLoadGsLoop,
	.cbDestroy = dialogLoadGsDestroy
};
