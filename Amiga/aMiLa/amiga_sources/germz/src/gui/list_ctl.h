/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GUI_LIST_CTL_H
#define GUI_LIST_CTL_H

#ifdef __cplusplus
extern "C" {
#endif

#include <ace/types.h>
#include <ace/utils/font.h>
#include <gui/button.h>

#define LISTCTL_ENTRY_INVALID 0xFFFF
#define LISTCTL_DRAWSTATE_OK 0
#define LISTCTL_DRAWSTATE_NEEDS_REDRAW 1

struct tListCtl;

typedef void (*tGuiListCtlCbOnSelect)(void);
typedef void (*tGuiListCtlCbUndraw)(UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight);
typedef void (*tGuiListCtlCbDrawPos)(struct tListCtl *pCtl, UWORD uwIdx, UBYTE ubPosOnView, UBYTE isSelected);

/**
 * @brief The sort function callback compatible with qsort() function.
 * pA and pB are pointers to tListCtrlEntry which are to be compared.
 */
typedef int (*tGuiListCtlCbSort)(const void *pA, const void *pB);

typedef struct tListCtrlEntry {
	char *szLabel;
	void *pData;
} tListCtlEntry;

typedef struct tListCtl {
	tUwRect sRect;
	UBYTE ubDrawState;
	UBYTE ubEntryHeight;
	UWORD uwEntryCnt;
	UWORD uwEntryMaxCnt;
	UWORD uwEntrySel;
	UWORD uwEntryScrollPos;
	tListCtlEntry *pEntries;
	tFont *pFont;
	tBitMap *pBfr;
	tGuiListCtlCbOnSelect cbOnSelect;
	tGuiListCtlCbUndraw cbUndraw;
	tGuiListCtlCbDrawPos cbDrawPos;
	tGuiButton *pButtonUp;
	tGuiButton *pButtonDown;
} tListCtl;

tListCtl *listCtlCreate(
	tBitMap *pBfr, UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	tFont *pFont, UWORD uwEntryMaxCnt, const char *szLabelUp, const char *szLabelDown,
	tGuiListCtlCbOnSelect cbOnSelect, tGuiListCtlCbUndraw cbUndraw,
	tGuiListCtlCbDrawPos cbDrawPos
);

void listCtlDestroy(tListCtl *pCtl);

UWORD listCtlAddEntry(tListCtl *pCtl, const char *szTxt, void *pData);

void listCtlRemoveEntry(tListCtl *pCtl, UWORD uwIdx);

void listCtlDraw(tListCtl *pCtl);

void listCtlUndraw(tListCtl *pCtl);

UBYTE listCtlProcessClick(tListCtl *pCtl, UWORD uwMouseX, UWORD uwMouseY);

/**
 * @brief Selects previous entry on the list.
 *
 * @param pCtl
 * @return 1 if selection was changed, otherwise 0.
 */
UBYTE listCtlSelectPrev(tListCtl *pCtl);

/**
 * @brief Selects next entry on the list.
 *
 * @param pCtl
 * @return 1 if selection was changed, otherwise 0.
 */
UBYTE listCtlSelectNext(tListCtl *pCtl);

void listCtlSortEntries(tListCtl *pCtl, tGuiListCtlCbSort cbSort);

const tListCtlEntry *listCtlGetSelection(const tListCtl *pCtl);

void listCtlSetSelectionIdx(tListCtl *pCtl, UWORD uwIdx);

UWORD listCtlGetSelectionIdx(const tListCtl *pCtl);

void listCtlClear(tListCtl *pCtl);

/**
 * @brief The default sort handler for listCtl. Sorts by labels in ascending order.
 */
int listCtlCbSortAsc(const void *pA, const void *pB);

#ifdef __cplusplus
}
#endif

#endif // GUI_LIST_CTL_H
