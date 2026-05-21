/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "gui_scanlined.h"
#include <ace/utils/string.h>
#include "color.h"
#include "assets.h"

static tBitMap *s_pBfr;

void guiScanlinedInit(tBitMap *pBfr) {
	s_pBfr = pBfr;
}

void guiScanlinedButtonDraw(tGuiButton *pButton) {
	const tUwRect *pRect = &pButton->sRect;
	UBYTE ubColor = COLOR_P3_BRIGHT >> 1;

	// Fill
	if(buttonIsSelected(pButton)) {
		// Draw bracket-like selection
		// [
		blitRect(s_pBfr, pRect->uwX, pRect->uwY, 1, pRect->uwHeight, ubColor);
		blitRect(s_pBfr, pRect->uwX, pRect->uwY, 3, 1, ubColor);
		blitRect(
			s_pBfr, pRect->uwX, pRect->uwY + pRect->uwHeight - 1, 3, 1, ubColor
		);
		// ]
		blitRect(
			s_pBfr, pRect->uwX + pRect->uwWidth - 1, pRect->uwY,
			1, pRect->uwHeight, ubColor
		);
		blitRect(
			s_pBfr, pRect->uwX + pRect->uwWidth - 3, pRect->uwY, 3, 1, ubColor
		);
		blitRect(
			s_pBfr, pRect->uwX + pRect->uwWidth - 3, pRect->uwY + pRect->uwHeight - 1,
			3, 1, ubColor
		);
	}
	else {
		// Fill everything with BG
		guiScanlinedBgClear(
			pRect->uwX, pRect->uwY, pRect->uwWidth, pRect->uwHeight
		);
	}

	// Text
	fontDrawStr(
		g_pFontSmall, s_pBfr,
		pRect->uwX + (pRect->uwWidth + 1)/2, pRect->uwY + pRect->uwHeight/2,
		pButton->szText, ubColor, FONT_CENTER | FONT_COOKIE, g_pTextBitmap
	);
}

void guiScanlinedBgClear(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight) {
	blitRect(s_pBfr, uwX, uwY, uwWidth, uwHeight, COLOR_CONSOLE_BG >> 1);
}

void guiScanlinedInputDraw(const tGuiInput *pInput) {
	UBYTE ubColor = COLOR_P3_BRIGHT >> 1;

	// Initial draw
	if(pInput->eDrawFlags & GUI_INPUT_DRAW_BORDER) {
		UWORD uwHeight = inputGetHeight(pInput);
		if(pInput->szLabel) {
			fontDrawStr(
				g_pFontSmall, s_pBfr, pInput->sPos.uwX - 1, pInput->sPos.uwY + uwHeight / 2,
				pInput->szLabel, ubColor, FONT_COOKIE | FONT_RIGHT | FONT_VCENTER,
				g_pTextBitmap
			);
		}
	}

	if(pInput->eDrawFlags & GUI_INPUT_DRAW_TEXT) {
		// Clear text bg
		guiScanlinedBgClear(
			pInput->sPos.uwX + 2, pInput->sPos.uwY + 2,
			pInput->uwWidth - 4, g_pFontSmall->uwHeight
		);

		// Draw new text
		if(!stringIsEmpty(pInput->szValue)) {
			fontDrawStr(
				g_pFontSmall, s_pBfr, pInput->sPos.uwX + 2, pInput->sPos.uwY + 2,
				pInput->szValue, ubColor, FONT_COOKIE, g_pTextBitmap
			);
		}
	}

	// Draw cursor if needed
	UWORD uwTextLength = fontMeasureText(g_pFontSmall, pInput->szValue).uwX;
	if(pInput->eDrawFlags & GUI_INPUT_DRAW_CURSOR) {
		if(pInput->isFocus) {
			fontDrawStr(
				g_pFontSmall, s_pBfr, pInput->sPos.uwX + 2 + uwTextLength,
				pInput->sPos.uwY + 2, "_", ubColor, FONT_COOKIE, g_pTextBitmap
			);
		}
		else {
			guiScanlinedBgClear(
				pInput->sPos.uwX + 2 + uwTextLength, pInput->sPos.uwY + 2,
				fontGlyphWidth(g_pFontSmall, '_'), g_pFontSmall->uwHeight
			);
		}
	}
}

UBYTE guiScanlinedInputGetHeight(const tGuiInput *pInput) {
	UBYTE ubHeight = g_pFontSmall->uwHeight + 4;
	return ubHeight;
}

void guiScanlinedListCtlDrawPos(
	tListCtl *pCtl, UWORD uwIdx, UBYTE ubPosOnView, UBYTE isSelected
) {
	UBYTE ubEntryWidth = pCtl->sRect.uwWidth - pCtl->pButtonUp->sRect.uwWidth - 2 - 2 - 1;
	if(isSelected) {
		blitRect(
			pCtl->pBfr, pCtl->sRect.uwX+2, pCtl->sRect.uwY+2 + ubPosOnView * pCtl->ubEntryHeight,
			ubEntryWidth, pCtl->ubEntryHeight, (COLOR_P3_BRIGHT + 2) >> 1
		);
	}
	else {
		if(pCtl->cbUndraw) {
			pCtl->cbUndraw(
				pCtl->sRect.uwX+2, pCtl->sRect.uwY+2 + ubPosOnView * pCtl->ubEntryHeight,
				ubEntryWidth, pCtl->ubEntryHeight
			);
		}
	}
	fontDrawStr(
		pCtl->pFont, pCtl->pBfr,
		pCtl->sRect.uwX+2+1, pCtl->sRect.uwY+2+1 + ubPosOnView * pCtl->ubEntryHeight,
		pCtl->pEntries[uwIdx].szLabel, COLOR_P3_BRIGHT >> 1,
		FONT_LEFT | FONT_TOP | FONT_COOKIE, g_pTextBitmap
	);
}
