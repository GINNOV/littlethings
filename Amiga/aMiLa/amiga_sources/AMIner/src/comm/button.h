#ifndef _AMINER_BUTTON_H_
#define _AMINER_BUTTON_H_

#include <ace/types.h>
#include <ace/utils/font.h>

#define BUTTON_NAME_MAX 20
#define BUTTON_INVALID 0xFF

typedef enum tButtonLayout {
	BUTTON_LAYOUT_HORIZONTAL,
	BUTTON_LAYOUT_VERTICAL,
} tButtonLayout;

typedef enum _tButtonPreset {
	BUTTON_PRESET_CUSTOM,
	BUTTON_PRESET_ACCEPT_DECLINE,
	BUTTON_PRESET_OK,
} tButtonPreset;

typedef struct _tButton {
	char szName[BUTTON_NAME_MAX];
	UWORD uwWidth;
	tUwCoordYX sPos; ///< Relative to left of button
} tButton;

void buttonReset(tButtonLayout eLayout, UWORD uwTopY);

UBYTE buttonAdd(const char *szName);

void buttonDraw(UBYTE ubIdx, tBitMap *pBfr);

void buttonRowApply(void);

void buttonDrawAll(tBitMap *pBfr);

UBYTE buttonSelect(UBYTE ubIdx);

void buttonDeselectAll(void);

UBYTE buttonGetCount(void);

UBYTE buttonGetSelected(void);

tUwCoordYX buttonGetPosition(UBYTE ubIndex);

UWORD buttonGetWidth(UBYTE ubIndex);

UBYTE buttonGetHeight(void);

tButtonPreset buttonGetPreset(void);

void buttonInitAcceptDecline(
	const char *szTextAccept, const char *szTextDecline
);

void buttonInitOk(const char *szText);

#endif // _AMINER_BUTTON_H_
