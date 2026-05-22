/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GUI_BUTTON_H
#define GUI_BUTTON_H

#ifdef __cplusplus
extern "C" {
#endif

#include <ace/types.h>
#include <ace/utils/bitmap.h>
#include <ace/utils/font.h>

#define BUTTON_MAX_TEXT 20
#define BUTTON_INVALID 0xFF

struct tGuiButton;

typedef void (*tGuiBtnOnClick)(void *pData);
typedef void (*tGuiBtnOnDraw)(struct tGuiButton *pButton);

typedef struct tGuiButton {
	tUwRect sRect;
	char szText[BUTTON_MAX_TEXT];
	tGuiBtnOnClick onClick;
	void *pData;
} tGuiButton;

void buttonListCreate(UBYTE ubButtonCount, const tGuiBtnOnDraw cbOnDraw);

void buttonListDestroy(void);

tGuiButton *buttonAdd(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	const char *szText, tGuiBtnOnClick cbOnClick, void *pData
);

void buttonDrawAll(void);

void buttonSelect(tGuiButton *pButton);

void buttonSelectNext(void);

void buttonSelectPrev(void);

tGuiButton *buttonGetSelected(void);

UBYTE buttonListProcessMouseClick(UWORD uwX, UWORD uwY);

void buttonClick(const tGuiButton *pButton);

UBYTE buttonIsSelected(const tGuiButton *pButton);

#ifdef __cplusplus
}
#endif

#endif // GUI_BUTTON_H
