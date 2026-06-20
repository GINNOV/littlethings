/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _TEXT_BOB_H_
#define _TEXT_BOB_H_

#include <ace/managers/bob.h>
#include <ace/utils/font.h>

typedef struct _tTextBob {
	const tFont *pFont;
	char szText[100];
	tBitMap *pTextBm;
	tBitMap *pTextMask;
	tBob sBob;
	UWORD uwWidth;
	UWORD uwDestPosY;
	UBYTE isUpdateRequired;
	UBYTE ubColor;
} tTextBob;

void textBobManagerCreate(const tFont *pBiggestFont);

void textBobManagerDestroy(void);

void textBobCreate(
	tTextBob *pTextBob, const tFont *pFont, const char *szMaxText
);

void textBobDestroy(tTextBob *pTextBob);

void textBobSet(
	tTextBob *pTextBob, const char *szText, UBYTE ubColor,
	UWORD uwPosX, UWORD uwPosY, UWORD uwDestPosY, UBYTE isCenterH
);

void textBobSetTextVa(tTextBob *pTextBob, UBYTE ubColor, const char *szText, ...);

void textBobSetText(tTextBob *pTextBob, UBYTE ubColor, const char *szText);

void textBobSetPos(
	tTextBob *pTextBob, UWORD uwX, UWORD uwY, UWORD uwDestY, UBYTE isCenterH
);

void textBobUpdate(tTextBob *pTextBob);

void textBobAnimate(tTextBob *pTextBob);

#endif // _TEXT_BOB_H_
