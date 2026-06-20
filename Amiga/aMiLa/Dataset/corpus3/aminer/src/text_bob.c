/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "text_bob.h"
#include <ace/utils/string.h>
#include "game.h"

static tTextBitMap *s_pTextBitmap;

void textBobManagerCreate(const tFont *pBiggestFont) {
	s_pTextBitmap = fontCreateTextBitMap(320, pBiggestFont->uwHeight);
}

void textBobManagerDestroy(void) {
	fontDestroyTextBitMap(s_pTextBitmap);
}

void textBobCreate(
	tTextBob *pTextBob, const tFont *pFont, const char *szMaxText
) {
	logBlockBegin(
		"textBobCreate(pTextBob: %p, pFont: %p, szMaxText: '%s')",
		pTextBob, pFont, szMaxText
	);
	tUwCoordYX sBounds = fontMeasureText(pFont, szMaxText);
	pTextBob->pFont = pFont;
	pTextBob->uwWidth = ((sBounds.uwX + 2 + 15) / 16) * 16;
	UWORD uwHeight = sBounds.uwY + 2;
	pTextBob->pTextBm = bitmapCreate(
		pTextBob->uwWidth, uwHeight, GAME_BPP, BMF_INTERLEAVED | BMF_CLEAR
	);
	pTextBob->pTextMask = bitmapCreate(
		pTextBob->uwWidth, uwHeight, GAME_BPP, BMF_INTERLEAVED | BMF_CLEAR
	);
	bobInit(
		&pTextBob->sBob, pTextBob->uwWidth, uwHeight, 1,
		bobCalcFrameAddress(pTextBob->pTextBm, 0),
		bobCalcFrameAddress(pTextBob->pTextMask, 0),
		0, 0
	);
	pTextBob->isUpdateRequired = 0;
	logBlockEnd("textBobCreate()");
}

void textBobSet(
	tTextBob *pTextBob, const char *szText, UBYTE ubColor,
	UWORD uwPosX, UWORD uwPosY, UWORD uwDestPosY, UBYTE isCenterH
) {
	textBobSetText(pTextBob, ubColor, szText);
	textBobSetPos(pTextBob, uwPosX, uwPosY, uwDestPosY, isCenterH);
}

void textBobSetTextVa(tTextBob *pTextBob, UBYTE ubColor, const char *szText, ...) {
	va_list vaArgs;
	va_start(vaArgs, szText);
	vsprintf(pTextBob->szText, szText, vaArgs);
	va_end(vaArgs);
	pTextBob->ubColor = ubColor;
	tUwCoordYX sSize = fontMeasureText(pTextBob->pFont, szText);
	pTextBob->uwWidth = sSize.uwX;
	pTextBob->isUpdateRequired = 1;
}

void textBobSetText(tTextBob *pTextBob, UBYTE ubColor, const char *szText) {
	stringCopy(szText, pTextBob->szText);
	pTextBob->ubColor = ubColor;
	tUwCoordYX sSize = fontMeasureText(pTextBob->pFont, szText);
	pTextBob->uwWidth = sSize.uwX;
	pTextBob->isUpdateRequired = 1;
}

void textBobSetPos(
	tTextBob *pTextBob, UWORD uwX, UWORD uwY, UWORD uwDestY, UBYTE isCenterH
) {
	pTextBob->sBob.sPos.uwX = uwX;
	pTextBob->sBob.sPos.uwY = uwY;
	if(isCenterH) {
		pTextBob->sBob.sPos.uwX -= pTextBob->uwWidth / 2;
	}
	pTextBob->uwDestPosY = uwDestY;
	pTextBob->isUpdateRequired = 1;
}

void textBobUpdate(tTextBob *pTextBob) {
	if(!pTextBob->isUpdateRequired) {
		return;
	}
	fontFillTextBitMap(pTextBob->pFont, s_pTextBitmap, pTextBob->szText);
	fontDrawTextBitMap(
		pTextBob->pTextBm, s_pTextBitmap, 1, 1, pTextBob->ubColor, 0
	);
	// Mask outline
	blitRect(
		pTextBob->pTextMask, 0, 0,
		pTextBob->sBob.uwWidth, pTextBob->pTextMask->Rows, 0
	);
	UBYTE ubMaskColor = (1 << pTextBob->pTextMask->Depth) - 1;
	fontDrawTextBitMap(
		pTextBob->pTextMask, s_pTextBitmap, 1, 1, ubMaskColor, 0
	);
	fontDrawTextBitMap(
		pTextBob->pTextMask, s_pTextBitmap, 1, 0, ubMaskColor, FONT_COOKIE
	);
	fontDrawTextBitMap(
		pTextBob->pTextMask, s_pTextBitmap, 1, 2, ubMaskColor, FONT_COOKIE
	);
	fontDrawTextBitMap(
		pTextBob->pTextMask, s_pTextBitmap, 0, 1, ubMaskColor, FONT_COOKIE
	);
	fontDrawTextBitMap(
		pTextBob->pTextMask, s_pTextBitmap, 2, 1, ubMaskColor, FONT_COOKIE
	);
	pTextBob->isUpdateRequired = 0;
}

void textBobAnimate(tTextBob *pTextBob) {
	if(
		!pTextBob->isUpdateRequired &&
		pTextBob->sBob.sPos.uwY != pTextBob->uwDestPosY
	) {
		if(pTextBob->sBob.sPos.uwY < pTextBob->uwDestPosY) {
			++pTextBob->sBob.sPos.uwY;
		}
		else {
			--pTextBob->sBob.sPos.uwY;
		}
		gameTryPushBob(&pTextBob->sBob);
	}
}

void textBobDestroy(tTextBob *pTextBob) {
	bitmapDestroy(pTextBob->pTextBm);
	bitmapDestroy(pTextBob->pTextMask);
}
