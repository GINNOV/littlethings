/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "dialog.h"
#include <ace/managers/blit.h>
#include <ace/managers/system.h>
#include <ace/generic/screen.h>
#include <gui/border.h>

static tBitMap *s_pBmDialog, *s_pBmDialogBgFirst, *s_pBmDialogBgSecond;
static tBitMap *s_pBmFirst, *s_pBmSecond; // For synchronizing save/restore
static UWORD s_uwWidth, s_uwHeight, s_uwOffsX, s_uwOffsY;

tBitMap *dialogCreate(
	UWORD uwWidth, UWORD uwHeight, tBitMap *pBack, tBitMap *pFront
) {
	s_uwWidth = uwWidth;
	s_uwHeight = uwHeight;
	s_uwOffsX = (SCREEN_PAL_WIDTH - s_uwWidth) / 2;
	s_uwOffsY = (SCREEN_PAL_HEIGHT - s_uwHeight) / 2;

	UBYTE ubFlags = (bitmapIsInterleaved(pBack) ? BMF_INTERLEAVED : 0);
	systemUse();
	s_pBmDialog = bitmapCreate(s_uwWidth, s_uwHeight, pBack->Depth, ubFlags);
	s_pBmDialogBgFirst = bitmapCreate(s_uwWidth, s_uwHeight, pBack->Depth, ubFlags);
	systemUnuse();

	dialogClear();
	s_pBmFirst = pBack;
	blitCopy(
		s_pBmFirst, s_uwOffsX, s_uwOffsY, s_pBmDialogBgFirst, 0, 0,
		s_uwWidth, s_uwHeight, MINTERM_COOKIE
	);

	if(pFront != pBack) {
		s_pBmSecond = pFront;
		s_pBmDialogBgSecond = bitmapCreate(s_uwWidth, s_uwHeight, pBack->Depth, ubFlags);
		blitCopy(
			s_pBmSecond, s_uwOffsX, s_uwOffsY, s_pBmDialogBgSecond, 0, 0,
			s_uwWidth, s_uwHeight, MINTERM_COOKIE
		);
	}
	else {
		s_pBmSecond = 0;
	}
	return s_pBmDialog;
}

void dialogDestroy(void) {
	blitCopy(
		s_pBmDialogBgFirst, 0, 0, s_pBmFirst, s_uwOffsX, s_uwOffsY,
		s_uwWidth, s_uwHeight, MINTERM_COOKIE
	);
	if(s_pBmSecond) {
		blitCopy(
			s_pBmDialogBgSecond, 0, 0, s_pBmSecond, s_uwOffsX, s_uwOffsY,
			s_uwWidth, s_uwHeight, MINTERM_COOKIE
		);
		bitmapDestroy(s_pBmDialogBgSecond);
	}
	systemUse();
	bitmapDestroy(s_pBmDialog);
	bitmapDestroy(s_pBmDialogBgFirst);
	systemUnuse();
}

void dialogProcess(tBitMap *pBack) {
	// Copy current dialog bitmap contents to backbuffer
	blitCopy(
		s_pBmDialog, 0, 0, pBack, s_uwOffsX, s_uwOffsY,
		s_uwWidth, s_uwHeight, MINTERM_COOKIE
	);
}

void dialogClear(void) {
	blitRect(s_pBmDialog, 0, 0, s_uwWidth, s_uwHeight, 0);
	// guiDraw3dBorder(s_pBmDialog, 0, 0, s_uwWidth, s_uwHeight);
}
