#ifndef GUARD_OF_GAMESTATES_MENU_MENU_H
#define GUARD_OF_GAMESTATES_MENU_MENU_H

#include <ace/types.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/utils/font.h>

#define MENU_BPP 4
#define MENU_COLOR_TEXT 13
#define MENU_COLOR_BG 0

void menuCreate(void);

void menuLoop(void);

void menuDestroy(void);

void menuMainCreate(void);

void menuMainDestroy(void);

void menuProcess(void);

void menuDrawButton(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	char *szText, UBYTE isSelected
);

extern tSimpleBufferManager *g_pMenuBuffer;
extern tFont *g_pMenuFont;
extern tTextBitMap *g_pMenuTextBitmap;

#endif // GUARD_OF_GAMESTATES_MENU_MENU_H
