/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include <ace/utils/bitmap.h>

typedef enum tDialogYesNoResult {
	DIALOG_YES_NO_RESULT_BUSY,
	DIALOG_YES_NO_RESULT_YES,
	DIALOG_YES_NO_RESULT_NO,
	DIALOG_YES_NO_RESULT_CANCEL,
} tDialogYesNoResult;

void dialogYesNoCreate(
	tBitMap *pDlgBitMap, const char **pMsgLines, UBYTE ubLineCount, UBYTE isCancel
);

tDialogYesNoResult dialogYesNoLoop(void);

void dialogYesNoDestroy(void);
