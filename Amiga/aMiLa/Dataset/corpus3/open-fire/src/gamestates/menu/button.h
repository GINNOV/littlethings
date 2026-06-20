#ifndef GUARD_OF_GAMESTATES_MENU_BUTTON_H
#define GUARD_OF_GAMESTATES_MENU_BUTTON_H

#include <ace/types.h>
#include <ace/utils/bitmap.h>
#include <ace/utils/font.h>

#define BUTTON_MAX_TEXT 20

typedef struct _tButton {
	tUwRect sRect;
	char szText[BUTTON_MAX_TEXT];
	void (*onClick)(void);
} tButton;

void buttonListCreate(FUBYTE fubButtonCount, tBitMap *pBfr, tFont *pFont);

void buttonListDestroy(void);

void buttonAdd(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	char *szText, void (*onClick)(void)
);

void buttonDrawAll(void);

FUBYTE buttonProcessClick(UWORD uwX, UWORD uwY);

#endif // GUARD_OF_GAMESTATES_MENU_BUTTON_H
