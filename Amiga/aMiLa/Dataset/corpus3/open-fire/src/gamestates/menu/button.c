#include "gamestates/menu/button.h"
#include <ace/macros.h>

static FUBYTE s_fubButtonCount;
static FUBYTE s_fubMaxButtonCount;
static tButton *s_pButtons;
static tBitMap *s_pBfr;
static tFont *s_pFont;
static tTextBitMap *s_pLabelTextBfr;

void buttonListCreate(FUBYTE fubButtonCount, tBitMap *pBfr, tFont *pFont) {
	logBlockBegin(
		"buttonListCreate(fubButtonCount: %"PRI_FUBYTE", pBfr: %p, tFont: %p)",
		fubButtonCount, pBfr, pFont
	);
	s_fubButtonCount = 0;
	s_fubMaxButtonCount = fubButtonCount;
	s_pBfr = pBfr;
	s_pFont = pFont;
	s_pLabelTextBfr = fontCreateTextBitMap(128, pFont->uwHeight);
	s_pButtons = memAllocFastClear(s_fubMaxButtonCount * sizeof(tButton));
	logBlockEnd("buttonListCreate()");
}

void buttonListDestroy(void) {
	logBlockBegin("buttonListDestroy()");
	memFree(s_pButtons, s_fubMaxButtonCount * sizeof(tButton));
	fontDestroyTextBitMap(s_pLabelTextBfr);
	s_fubButtonCount = 0;
	s_fubMaxButtonCount = 0;
	logBlockEnd("buttonListDestroy()");
}

void buttonAdd(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	char *szText, void (*onClick)(void)
) {
	// Count check
	if(s_fubButtonCount >= s_fubMaxButtonCount)
		return;
	// Sanity check
	if(strlen(szText) >= BUTTON_MAX_TEXT)
		return;

	// Fill fields
	tButton *pButton = &s_pButtons[s_fubButtonCount];
	pButton->sRect.uwX = uwX;
	pButton->sRect.uwY = uwY;
	pButton->sRect.uwWidth = uwWidth;
	pButton->sRect.uwHeight = uwHeight;
	strcpy(pButton->szText, szText);
	pButton->onClick = onClick;

	++s_fubButtonCount;
}

static void buttonDraw(tButton *pButton) {
	const UBYTE ubColorLight = 12;
	const UBYTE ubColorDark = 3;
	const UBYTE ubColorFill = 7;
	const UBYTE ubColorText = 13;

	tUwRect *pRect = &pButton->sRect;

	// Fill
	blitRect(
		s_pBfr, pRect->uwX, pRect->uwY,
		pRect->uwWidth, pRect->uwHeight, ubColorFill
	);

	// Ridge
	blitRect(s_pBfr, pRect->uwX, pRect->uwY, pRect->uwWidth, 2, ubColorLight);
	blitRect(s_pBfr, pRect->uwX, pRect->uwY, 2, pRect->uwHeight, ubColorLight);

	// Grove
	blitRect(
		s_pBfr, pRect->uwX + 2, pRect->uwY + pRect->uwHeight - 1,
		pRect->uwWidth - 2, 1, ubColorDark
	);
	blitRect(
		s_pBfr, pRect->uwX + pRect->uwWidth - 1, pRect->uwY + 2,
		1, pRect->uwHeight - 2, ubColorDark
	);

	// Text
	fontFillTextBitMap(s_pFont, s_pLabelTextBfr, pButton->szText);
	fontDrawTextBitMap(
		s_pBfr, s_pLabelTextBfr,
		pRect->uwX + pRect->uwWidth/2, pRect->uwY + pRect->uwHeight/2,
		ubColorText, FONT_CENTER | FONT_SHADOW | FONT_COOKIE
	);
}

void buttonDrawAll(void) {
	for(FUBYTE i = 0; i < s_fubButtonCount; ++i)
		buttonDraw(&s_pButtons[i]);
}

FUBYTE buttonProcessClick(UWORD uwX, UWORD uwY) {
	for(FUBYTE i = 0; i < s_fubButtonCount; ++i) {
		if(inRect(uwX, uwY, s_pButtons[i].sRect)) {
			if(s_pButtons[i].onClick)
				s_pButtons[i].onClick();
			return 1;
		}
	}
	return 0;
}
