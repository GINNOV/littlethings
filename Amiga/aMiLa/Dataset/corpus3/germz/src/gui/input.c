/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "input.h"
#include <ace/managers/system.h>
#include <ace/managers/key.h>
#include <ace/utils/string.h>
#include "config.h"
#include "border.h"

tGuiInput *inputCreate(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwMaxChars,
	const char *szLabel, char *szValueBuffer, tGuiInputCbDraw cbDraw,
	tGuiInputCbGetHeight cbGetHeight, tGuiInputCbCharAllowed cbCharAllowed
) {
	systemUse();
	tGuiInput *pInput = memAllocFast(sizeof(*pInput));
	if(!pInput) {
		goto fail;
	}
	pInput->szLabel = szLabel;
	if(szValueBuffer) {
		pInput->szValue = szValueBuffer;
		pInput->isValueBufferAllocated = 0;
	}
	else {
		pInput->isValueBufferAllocated = 1;
		pInput->szValue = memAllocFastClear(uwMaxChars);
		if(!pInput->szValue) {
			goto fail;
		}
	}
	systemUnuse();

	pInput->sPos.uwX = uwX;
	pInput->sPos.uwY = uwY;
	pInput->uwWidth = uwWidth;
	pInput->uwMaxChars = uwMaxChars;
	pInput->uwValueLength = strlen(pInput->szValue);
	pInput->isFocus = 0;
	pInput->eDrawFlags = (
		GUI_INPUT_DRAW_BORDER | GUI_INPUT_DRAW_CURSOR | GUI_INPUT_DRAW_TEXT
	);
	pInput->cbDraw = cbDraw;
	pInput->cbGetHeight = cbGetHeight;
	pInput->cbCharAllowed = cbCharAllowed;

	return pInput;
fail:
	inputDestroy(pInput);
	systemUnuse();
	return 0;
}

void inputDestroy(tGuiInput *pInput) {
	systemUse();
	if(pInput) {
		if(pInput->isValueBufferAllocated && pInput->szValue) {
			memFree(pInput->szValue, pInput->uwMaxChars);
		}
		memFree(pInput, sizeof(*pInput));
	}
	systemUnuse();
}

void inputProcess(tGuiInput *pInput) {
	// Process keystrokes
	if(pInput->isFocus && keyUse(g_sKeyManager.ubLastKey)) {
		WORD wInput = g_pToAscii[g_sKeyManager.ubLastKey];
		if(keyCheck(KEY_LSHIFT) || keyCheck(KEY_RSHIFT)) {
			wInput = charToUpper(wInput);
		}
		if(pInput->cbCharAllowed(wInput)) {
			if(pInput->uwValueLength < pInput->uwMaxChars - 1) {
				if(pInput->szValue[pInput->uwValueLength] == '\0') {
					// Move null terminator one char further if editing end of string
					pInput->szValue[pInput->uwValueLength + 1] = '\0';
				}
				pInput->szValue[pInput->uwValueLength] = wInput;
				++pInput->uwValueLength;
			}
			pInput->eDrawFlags |= GUI_INPUT_DRAW_TEXT | GUI_INPUT_DRAW_CURSOR;
		}
		else if(g_sKeyManager.ubLastKey == KEY_BACKSPACE && pInput->uwValueLength){
			--pInput->uwValueLength;
			pInput->szValue[pInput->uwValueLength] = '\0';
			pInput->eDrawFlags |= GUI_INPUT_DRAW_TEXT | GUI_INPUT_DRAW_CURSOR;
		}
	}
	if(pInput->eDrawFlags) {
		if(pInput->cbDraw) {
			pInput->cbDraw(pInput);
		}
		pInput->eDrawFlags = 0;
	}
}

UBYTE inputGetHeight(const tGuiInput *pInput) {
	UBYTE ubHeight = pInput->cbGetHeight(pInput);
	return ubHeight;
}

void inputLoseFocus(tGuiInput *pInput) {
	pInput->isFocus = 0;
	pInput->eDrawFlags |= GUI_INPUT_DRAW_TEXT | GUI_INPUT_DRAW_CURSOR;
}

void inputSetFocus(tGuiInput *pInput) {
	pInput->isFocus = 1;
	pInput->eDrawFlags |= GUI_INPUT_DRAW_TEXT | GUI_INPUT_DRAW_CURSOR;
}
