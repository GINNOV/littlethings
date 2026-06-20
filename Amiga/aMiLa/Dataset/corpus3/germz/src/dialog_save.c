/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "dialog_save.h"
#include <ace/managers/game.h>
#include <ace/managers/key.h>
#include <ace/managers/state.h>
#include <ace/utils/bmframe.h>
#include <ace/utils/dir.h>
#include "gui/dialog.h"
#include "gui/input.h"
#include "gui/button.h"
#include "gui/config.h"
#include "dialog_yes_no.h"
#include "game_editor.h"
#include "game.h"
#include "assets.h"
#include "germz.h"
#include "gui_scanlined.h"
#include "color.h"

#define FILE_PATH_PREFIX "data/maps/"
#define FILE_PATH_EXTENSION ".json"
#define FILE_PATH_SIZE 100
#define FILE_NAME_SIZE (FILE_PATH_SIZE - sizeof(FILE_PATH_PREFIX) - sizeof(FILE_PATH_EXTENSION))

//----------------------------------------------------------------------- Layout

#define DLG_SAVE_PAD 16
#define DLG_SAVE_WIDTH 256
#define DLG_SAVE_HEIGHT 160

#define INPUT_X (DLG_SAVE_PAD + 50)
#define INPUT_TITLE_Y (DLG_SAVE_PAD + 10)
#define INPUT_AUTHOR_Y (INPUT_TITLE_Y + 20)
#define INPUT_PATH_Y (INPUT_AUTHOR_Y + 20)
#define JSON_EXT_WIDTH 30
#define INPUT_WIDTH (DLG_SAVE_WIDTH - DLG_SAVE_PAD - INPUT_X - JSON_EXT_WIDTH)

#define BTN_WIDTH 50
#define BTN_HEIGHT 10
#define BTN_Y (DLG_SAVE_HEIGHT - BTN_HEIGHT - DLG_SAVE_PAD)

//------------------------------------------------------------------- Layout end

typedef enum tSaveInput {
	SAVE_INPUT_TITLE,
	SAVE_INPUT_AUTHOR,
	SAVE_INPUT_FILENAME,
	SAVE_INPUT_COUNT
} tSaveInput;

static tBitMap *s_pBmDlg;
static tBitMap s_sBmDlgScanlined;
static tGuiInput *s_pInputs[SAVE_INPUT_COUNT];
static tSaveInput s_eCurrentInput;
static tGuiButton *s_pButtonSave, *s_pButtonCancel;
static tStateManager *s_pDlgStateMachine;
static UBYTE s_isQuitting;

/**
 * @brief Buffer for file name - everything past "data/maps/" and without ".json".
 */
static char s_szFileName[FILE_NAME_SIZE] = "";

/**
 * @brief Buffer for whole path - including "data/maps/" and ".json".
 */
static char s_szFilePath[FILE_PATH_SIZE];

static tState s_sStateOverwrite, s_sStateCreateDir, s_sStateSelect, s_sStateSaving;

static UBYTE onCharAllowedPath(char c) {
	UBYTE isAllowed = (
		('A' <= c && c <= 'Z') ||
		('a' <= c && c <= 'z') ||
		('0' <= c && c <= '9') ||
		c == '/' || c == '_' || c == '-'
	);
	return isAllowed;
}

static UBYTE onCharAllowedName(char c) {
	UBYTE isAllowed = (
		('A' <= c && c <= 'Z') ||
		('a' <= c && c <= 'z') ||
		('0' <= c && c <= '9') ||
		c == ' ' || c == '_' || c == '-'
	);
	return isAllowed;
}

static void saveDialogClear(void) {
	dialogClear();
	bmFrameDraw(
		g_pFrameDisplay, s_pBmDlg, 0, 0,
		DLG_SAVE_WIDTH / 16, DLG_SAVE_HEIGHT / 16, 16
	);
}

//----------------------------------------------------------------- STATE YES NO

void dialogSaveYesNoCreate(
	const char **pMsgLines, UBYTE ubLineCount, UBYTE isCancel
) {
	saveDialogClear();
	dialogYesNoCreate(&s_sBmDlgScanlined, pMsgLines, ubLineCount, isCancel);
}

//----------------------------------------------------------------- STATE SELECT

void dialogSaveSelectCreate(void) {
	saveDialogClear();

	buttonListCreate(2, guiScanlinedButtonDraw);
	s_pInputs[SAVE_INPUT_TITLE] = inputCreate(
		INPUT_X, INPUT_TITLE_Y, INPUT_WIDTH, sizeof(g_sMapData.szName), "Title",
		g_sMapData.szName, guiScanlinedInputDraw, guiScanlinedInputGetHeight,
		onCharAllowedName
	);
	s_pInputs[SAVE_INPUT_AUTHOR] = inputCreate(
		INPUT_X, INPUT_AUTHOR_Y, INPUT_WIDTH, sizeof(g_sMapData.szAuthor), "Author",
		g_sMapData.szAuthor, guiScanlinedInputDraw, guiScanlinedInputGetHeight,
		onCharAllowedName
	);
	s_pInputs[SAVE_INPUT_FILENAME] = inputCreate(
		INPUT_X, INPUT_PATH_Y, INPUT_WIDTH, sizeof(s_szFileName), "File name",
		s_szFileName, guiScanlinedInputDraw, guiScanlinedInputGetHeight,
		onCharAllowedPath
	);
	fontDrawStr(
		g_pFontSmall, &s_sBmDlgScanlined,
		s_pInputs[SAVE_INPUT_FILENAME]->sPos.uwX + s_pInputs[SAVE_INPUT_FILENAME]->uwWidth + 2,
		s_pInputs[SAVE_INPUT_FILENAME]->sPos.uwY + inputGetHeight(s_pInputs[SAVE_INPUT_FILENAME]) / 2,
		FILE_PATH_EXTENSION, COLOR_P3_BRIGHT >> 1,
		FONT_COOKIE | FONT_VCENTER, g_pTextBitmap
	);

	s_eCurrentInput = 0;
	s_pButtonSave = buttonAdd(
		DLG_SAVE_WIDTH * 1 / 3 - BTN_WIDTH / 2, BTN_Y,
		BTN_WIDTH, BTN_HEIGHT, "Save", 0, 0
	);
	s_pButtonCancel = buttonAdd(
		DLG_SAVE_WIDTH * 2 / 3 - BTN_WIDTH / 2, BTN_Y,
		BTN_WIDTH, BTN_HEIGHT, "Cancel", 0, 0
	);
	inputSetFocus(s_pInputs[s_eCurrentInput]);
	buttonDrawAll();
}

static void dialogSaveSelectLoop(void) {
	UBYTE isTab = keyUse(KEY_TAB);
	tDirection eDir = gameEditorProcessSteer();
	if(eDir == DIRECTION_UP || (isTab && keyCheck(KEY_LSHIFT))) {
		if(s_eCurrentInput) {
			if(s_eCurrentInput == SAVE_INPUT_COUNT) {
				// Focus out of button
				buttonSelect(0);
				buttonDrawAll();
			}
			else {
				inputLoseFocus(s_pInputs[s_eCurrentInput]);
			}
			--s_eCurrentInput;
			inputSetFocus(s_pInputs[s_eCurrentInput]);
		}
	}
	else if(eDir == DIRECTION_DOWN || (isTab && !keyCheck(KEY_LSHIFT))) {
		if(s_eCurrentInput < SAVE_INPUT_COUNT) {
			inputLoseFocus(s_pInputs[s_eCurrentInput]);
			++s_eCurrentInput;
			if(s_eCurrentInput == SAVE_INPUT_COUNT) {
				buttonSelect(s_pButtonSave);
				buttonDrawAll();
			}
			else {
				inputSetFocus(s_pInputs[s_eCurrentInput]);
			}
		}
	}
	else if(eDir == DIRECTION_LEFT && s_eCurrentInput == SAVE_INPUT_COUNT) {
		buttonSelect(s_pButtonSave);
		buttonDrawAll();
	}
	else if(eDir == DIRECTION_RIGHT && s_eCurrentInput == SAVE_INPUT_COUNT) {
		buttonSelect(s_pButtonCancel);
		buttonDrawAll();
	}

	for(tSaveInput eInput = 0; eInput < SAVE_INPUT_COUNT; ++eInput) {
		inputProcess(s_pInputs[eInput]);
	}

	dialogProcess(gameGetBackBuffer());
	gamePostprocess();

	if(eDir == DIRECTION_FIRE || keyUse(KEY_RETURN) || keyUse(KEY_NUMENTER)) {
		if(buttonGetSelected() == s_pButtonSave) {
			if(!strlen(g_sMapData.szName)) {
				// TODO: ERR
			}
			else if(!strlen(g_sMapData.szAuthor)) {
				// TODO: ERR
			}
			else if(!strlen(s_szFileName)) {
				// TODO: ERR
			}
			else {
				strcpy(s_szFilePath, FILE_PATH_PREFIX);
				strcat(s_szFilePath, s_szFileName);
				strcat(s_szFilePath, FILE_PATH_EXTENSION);
				if(fileExists(s_szFilePath)) {
					stateChange(s_pDlgStateMachine, &s_sStateOverwrite);
				}
				else {
					char *pLastSlash = strrchr(s_szFilePath, '/');
					*pLastSlash = '\0';
					UBYTE isDirExisting = dirExists(s_szFilePath);
					*pLastSlash = '/';
					if(isDirExisting) {
						stateChange(s_pDlgStateMachine, &s_sStateSaving);
					}
					else {
						stateChange(s_pDlgStateMachine, &s_sStateCreateDir);
					}
				}
			}
		}
		else if(buttonGetSelected() == s_pButtonCancel) {
			statePop(g_pStateMachineGame);
		}
	}
	else if(keyUse(KEY_ESCAPE)) {
		statePop(g_pStateMachineGame);
	}
}

static void dialogSaveSelectDestroy(void) {
	buttonListDestroy();
	for(tSaveInput eInput = 0; eInput < SAVE_INPUT_COUNT; ++eInput) {
		inputDestroy(s_pInputs[eInput]);
	}
}

static tState s_sStateSelect = {
	.cbCreate = dialogSaveSelectCreate, .cbLoop = dialogSaveSelectLoop,
	.cbDestroy = dialogSaveSelectDestroy
};

//-------------------------------------------------------------- STATE OVERWRITE

static void dialogSaveOverwriteCreate(void) {
	static const char *szMessages[] = {
		"File already exists",
		s_szFilePath,
		"Do you want to overwrite?",
	};

	dialogSaveYesNoCreate(
		szMessages, sizeof(szMessages) / sizeof(szMessages[0]), 0
	);
}

static void dialogSaveOverwriteLoop(void) {
	tDialogYesNoResult eResult = dialogYesNoLoop();
	if(eResult != DIALOG_YES_NO_RESULT_BUSY) {
		if(eResult == DIALOG_YES_NO_RESULT_YES) {
			stateChange(s_pDlgStateMachine, &s_sStateSaving);
		}
		else {
			stateChange(s_pDlgStateMachine, &s_sStateSelect);
		}
	}
}

static tState s_sStateOverwrite = {
	.cbCreate = dialogSaveOverwriteCreate, .cbLoop = dialogSaveOverwriteLoop,
	.cbDestroy = dialogYesNoDestroy
};

//------------------------------------------------------------- STATE CREATE DIR

static void dialogSaveCreateDirCreate(void) {
	static const char *szMessages[] = {
		"Subdirectory doesn't exist",
		s_szFilePath,
		"Do you want to create it?",
	};

	char *pLastSlash = strrchr(s_szFilePath, '/');
	*pLastSlash = '\0';
	dialogSaveYesNoCreate(
		szMessages, sizeof(szMessages) / sizeof(szMessages[0]), 0
	);
	*pLastSlash = '/';
}

static void dialogSaveCreateDirLoop(void) {
	tDialogYesNoResult eResult = dialogYesNoLoop();
	if(eResult != DIALOG_YES_NO_RESULT_BUSY) {
		if(eResult == DIALOG_YES_NO_RESULT_YES) {
			char *pLastSlash = strrchr(s_szFilePath, '/');
			*pLastSlash = '\0';
			dirCreatePath(s_szFilePath);
			*pLastSlash = '/';
			stateChange(s_pDlgStateMachine, &s_sStateSaving);
		}
		else {
			stateChange(s_pDlgStateMachine, &s_sStateSelect);
		}
	}
}

static tState s_sStateCreateDir = {
	.cbCreate = dialogSaveCreateDirCreate, .cbLoop = dialogSaveCreateDirLoop,
	.cbDestroy = dialogYesNoDestroy
};

//----------------------------------------------------------------- STATE SAVING

static void dialogSaveSavingCreate(void) {
	saveDialogClear();

	fontDrawStr(
		g_pFontSmall, &s_sBmDlgScanlined,
		DLG_SAVE_WIDTH / 2, DLG_SAVE_HEIGHT / 2,
		"Saving map. Don't turn off the power...", COLOR_P3_BRIGHT >> 1,
		FONT_COOKIE | FONT_CENTER, g_pTextBitmap
	);
}

static void dialogSaveSavingLoop(void) {
	dialogProcess(gameGetBackBuffer());
	gamePostprocess();

	mapDataSaveToFile(&g_sMapData, s_szFilePath);
	if(s_isQuitting) {
		statePop(g_pStateMachineGame);
		gameQuit();
	}
	else {
		statePop(g_pStateMachineGame);
	}
}

static tState s_sStateSaving = {
	.cbCreate = dialogSaveSavingCreate, .cbLoop = dialogSaveSavingLoop
};

//--------------------------------------------------------------------- QUITTING

static void dialogSaveConfirmQuitCreate(void) {
	static const char *szMessages[] = {
		"Save before quit?",
	};

	dialogSaveYesNoCreate(
		szMessages, sizeof(szMessages) / sizeof(szMessages[0]), 1
	);
}

static void dialogSaveConfirmQuitLoop(void) {
	tDialogYesNoResult eResult = dialogYesNoLoop();
	if(eResult != DIALOG_YES_NO_RESULT_BUSY) {
		if(eResult == DIALOG_YES_NO_RESULT_YES) {
			stateChange(s_pDlgStateMachine, &s_sStateSelect);
		}
		else if(eResult == DIALOG_YES_NO_RESULT_NO) {
			statePop(g_pStateMachineGame); // Pop to game_editor
			gameQuit();
		}
		else {
			statePop(g_pStateMachineGame);
		}
	}
}

static tState s_sStateConfirmQuit = {
	.cbCreate = dialogSaveConfirmQuitCreate, .cbLoop = dialogSaveConfirmQuitLoop,
	.cbDestroy = dialogYesNoDestroy
};

//------------------------------------------------------- SAVE DIALOG GAME STATE

static void dialogSaveGsCreate(void) {
	s_eCurrentInput = 0;
	s_pBmDlg = dialogCreate(
		DLG_SAVE_WIDTH, DLG_SAVE_HEIGHT, gameGetBackBuffer(), gameGetFrontBuffer()
	);

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

	s_pDlgStateMachine = stateManagerCreate();
	if(s_isQuitting) {
		statePush(s_pDlgStateMachine, &s_sStateConfirmQuit);
	}
	else {
		statePush(s_pDlgStateMachine, &s_sStateSelect);
	}
}

static void dialogSaveGsLoop(void) {
	if(!gamePreprocess(0)) {
		return;
	}
	stateProcess(s_pDlgStateMachine);
}

static void dialogSaveGsDestroy(void) {
	stateManagerDestroy(s_pDlgStateMachine);
	dialogDestroy();
}

//------------------------------------------------------------------- PUBLIC FNS

void dialogSaveShow(UBYTE isQuitting) {
	s_isQuitting = isQuitting;
	statePush(g_pStateMachineGame, &g_sStateDialogSave);
}

void dialogSaveSetSaveName(const char *szPath, const char *szName) {
	char *szEnd = s_szFileName;
	if(*szPath == '/') {
		// Skip '/' before subdirectory name
		strcpy(s_szFileName, &szPath[1]);
		szEnd += strlen(s_szFileName);
		*(szEnd++) = '/';
	}
	strcpy(szEnd, szName);
}

tState g_sStateDialogSave = {
	.cbCreate = dialogSaveGsCreate, .cbLoop = dialogSaveGsLoop,
	.cbDestroy = dialogSaveGsDestroy
};
