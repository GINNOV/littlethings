#ifndef OF_GAMESTATES_MENU_LISTCTL_H
#define OF_GAMESTATES_MENU_LISTCTL_H

#include <ace/types.h>
#include <ace/utils/font.h>

#define LISTCTL_ENTRY_INVALID 0xFFFF
#define LISTCTL_DRAWSTATE_OK 0
#define LISTCTL_DRAWSTATE_NEEDS_REDRAW 1

typedef struct _tListCtl {
	tUwRect sRect;
	UBYTE ubDrawState;
	UBYTE ubEntryHeight;
	UWORD uwEntryCnt;
	UWORD uwEntryMaxCnt;
	UWORD uwEntrySel;
	char **pEntries;
	tFont *pFont;
	tBitMap *pBfr;
	void (*onChange)(void);
} tListCtl;

tListCtl *listCtlCreate(
	tBitMap *pBfr, UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	tFont *pFont, UWORD uwEntryMaxCnt, void (*onChange)(void)
);

void listCtlDestroy(tListCtl *pCtl);

UWORD listCtlAddEntry(tListCtl *pCtl, char *szTxt);

void listCtlRemoveEntry(tListCtl *pCtl, UWORD uwIdx);

void listCtlDraw(tListCtl *pCtl);

FUBYTE listCtlProcessClick(tListCtl *pCtl, UWORD uwMouseX, UWORD uwMouseY);

#endif // OF_GAMESTATES_MENU_LISTCTL_H
