#include "gamestates/menu/listCtl.h"
#include "gamestates/menu/button.h"
#include <ace/managers/log.h>
#include <ace/macros.h>

#define LISTCTL_BTN_WIDTH 10

tTextBitMap *s_pEntryTextBfr;

tListCtl *listCtlCreate(
	tBitMap *pBfr,
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	tFont *pFont, UWORD uwEntryMaxCnt,
	void (*onChange)(void)
) {
	logBlockBegin(
		"listCtlCreate(uwX: %hu, uwY: %hu, uwWidth: %hu, uwHeight: %hu, pFont: %p)",
		uwX, uwY, uwWidth, uwHeight, pFont
	);

	tListCtl *pCtl = memAllocFast(sizeof(tListCtl));
	pCtl->ubEntryHeight = pFont->uwHeight + 2;
	pCtl->uwEntryCnt = 0;
	pCtl->uwEntryMaxCnt = uwEntryMaxCnt;
	pCtl->sRect.uwX = uwX;
	pCtl->sRect.uwY = uwY;
	pCtl->sRect.uwWidth = uwWidth;
	pCtl->sRect.uwHeight = uwHeight;
	pCtl->ubDrawState = LISTCTL_DRAWSTATE_NEEDS_REDRAW;
	pCtl->pFont = pFont;
	pCtl->pBfr = pBfr;
	pCtl->uwEntrySel = 0;
	pCtl->onChange = onChange;

	pCtl->pEntries =  memAllocFastClear(uwEntryMaxCnt * sizeof(char*));

	s_pEntryTextBfr = fontCreateTextBitMap(uwWidth, pFont->uwHeight);

	buttonAdd(
		uwX + uwWidth - LISTCTL_BTN_WIDTH-2, uwY+2,
		LISTCTL_BTN_WIDTH, LISTCTL_BTN_WIDTH, "U", 0
	);
	buttonAdd(
		uwX + uwWidth - LISTCTL_BTN_WIDTH-2, uwY + uwHeight - LISTCTL_BTN_WIDTH -2,
		LISTCTL_BTN_WIDTH, LISTCTL_BTN_WIDTH, "D", 0
	);

	logBlockEnd("listCtlCreate()");
	return pCtl;
}

void listCtlDestroy(tListCtl *pCtl) {
	for(UWORD i = pCtl->uwEntryCnt; i--;) {
		listCtlRemoveEntry(pCtl, i);
	}
	memFree(pCtl->pEntries, pCtl->uwEntryMaxCnt * sizeof(char*));
	fontDestroyTextBitMap(s_pEntryTextBfr);
	memFree(pCtl, sizeof(tListCtl));
}

UWORD listCtlAddEntry(tListCtl *pCtl, char *szTxt) {
	if(pCtl->uwEntryCnt >= pCtl->uwEntryMaxCnt)
		return LISTCTL_ENTRY_INVALID;
	pCtl->pEntries[pCtl->uwEntryCnt] = memAllocFast(strlen(szTxt)+1);
	strcpy(pCtl->pEntries[pCtl->uwEntryCnt], szTxt);
	pCtl->ubDrawState = LISTCTL_DRAWSTATE_NEEDS_REDRAW;
	return pCtl->uwEntryCnt++;
}

void listCtlRemoveEntry(tListCtl *pCtl, UWORD uwIdx) {
	if(pCtl->pEntries[uwIdx])
		memFree(pCtl->pEntries[uwIdx], strlen(pCtl->pEntries[uwIdx])+1);
}

void listCtlDraw(tListCtl *pCtl) {
	// Draw border
	blitRect(
		pCtl->pBfr, pCtl->sRect.uwX, pCtl->sRect.uwY,
		pCtl->sRect.uwWidth, 1, 9
	);
	blitRect(
		pCtl->pBfr, pCtl->sRect.uwX, pCtl->sRect.uwY,
		1, pCtl->sRect.uwHeight, 9
	);
	blitRect(
		pCtl->pBfr, pCtl->sRect.uwX, pCtl->sRect.uwY + pCtl->sRect.uwHeight-1,
		pCtl->sRect.uwWidth, 1, 4
	);
	blitRect(
		pCtl->pBfr, pCtl->sRect.uwX + pCtl->sRect.uwWidth - 1, pCtl->sRect.uwY,
		1, pCtl->sRect.uwHeight, 4
	);

	// Draw scroll bar
	blitRect(
		pCtl->pBfr,
		pCtl->sRect.uwX + pCtl->sRect.uwWidth - LISTCTL_BTN_WIDTH - 2,
		pCtl->sRect.uwY + LISTCTL_BTN_WIDTH + 3,
		LISTCTL_BTN_WIDTH, pCtl->sRect.uwHeight - 2*LISTCTL_BTN_WIDTH - 6, 1
	);

	UWORD uwFirstVisible = 0;
	UWORD uwLastVisible = MIN(
		pCtl->uwEntryCnt,
		uwFirstVisible + (pCtl->sRect.uwHeight - 4) / pCtl->ubEntryHeight
	);

	// Draw elements
	for(UWORD i = uwFirstVisible; i != uwLastVisible; ++i) {
		if(i == pCtl->uwEntrySel) {
			blitRect(
				pCtl->pBfr, pCtl->sRect.uwX+2, pCtl->sRect.uwY+2 + i* pCtl->ubEntryHeight,
				pCtl->sRect.uwWidth - LISTCTL_BTN_WIDTH - 2 - 2 - 1, pCtl->ubEntryHeight, 7
			);
		}
		fontFillTextBitMap(pCtl->pFont, s_pEntryTextBfr, pCtl->pEntries[i]);
		fontDrawTextBitMap(
			pCtl->pBfr, s_pEntryTextBfr,
			pCtl->sRect.uwX+2+1, pCtl->sRect.uwY+2+1 + i*pCtl->ubEntryHeight,
			13, FONT_LEFT| FONT_TOP | FONT_COOKIE
		);
	}
}

static void listCtlDrawEntry(tListCtl *pCtl, UWORD uwIdx) {
	UWORD uwFirstVisible = 0;
	UWORD uwLastVisible = MIN(
		pCtl->uwEntryCnt,
		uwFirstVisible + (pCtl->sRect.uwHeight - 4) / pCtl->ubEntryHeight
	);
	if(uwIdx >= uwFirstVisible && uwIdx <= uwLastVisible) {
		UBYTE ubBgColor;
		if(uwIdx == pCtl->uwEntrySel)
			ubBgColor = 7;
		else
			ubBgColor = 0;
		blitRect(
			pCtl->pBfr, pCtl->sRect.uwX+2, pCtl->sRect.uwY+2 + uwIdx* pCtl->ubEntryHeight,
			pCtl->sRect.uwWidth - LISTCTL_BTN_WIDTH - 2 - 2 - 1, pCtl->ubEntryHeight,
			ubBgColor
		);
		fontFillTextBitMap(pCtl->pFont, s_pEntryTextBfr, pCtl->pEntries[uwIdx]);
		fontDrawTextBitMap(
			pCtl->pBfr, s_pEntryTextBfr,
			pCtl->sRect.uwX+2+1, pCtl->sRect.uwY+2+1 + uwIdx*pCtl->ubEntryHeight,
			13, FONT_LEFT| FONT_TOP | FONT_COOKIE
		);
	}
}

FUBYTE listCtlProcessClick(tListCtl *pCtl, UWORD uwMouseX, UWORD uwMouseY) {
	if(inRect(uwMouseX, uwMouseY, pCtl->sRect)) {
		UWORD uwPrevSel = pCtl->uwEntrySel;
		UWORD uwFirstVisible = 0;
		pCtl->uwEntrySel = MIN(
			uwFirstVisible + (uwMouseY - pCtl->sRect.uwX - 2) / pCtl->ubEntryHeight,
			pCtl->uwEntryCnt-1
		);
		listCtlDrawEntry(pCtl, uwPrevSel);
		listCtlDrawEntry(pCtl, pCtl->uwEntrySel);
		if(pCtl->onChange)
			pCtl->onChange();
		return 1;
	}
	return 0;
}
