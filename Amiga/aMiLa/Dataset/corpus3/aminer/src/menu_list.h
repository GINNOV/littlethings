/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_MENU_LIST_H
#define INCLUDE_MENU_LIST_H

#include <ace/utils/font.h>

typedef enum tMenuListOptionType {
	MENU_LIST_OPTION_TYPE_UINT8,
	MENU_LIST_OPTION_TYPE_CALLBACK
} tMenuListOptionType;

typedef enum tMenuListDirty {
	MENU_LIST_DIRTY_NONE = 0,
	MENU_LIST_DIRTY_VAL_CHANGE = BV(0),
	MENU_LIST_DIRTY_SELECTION = BV(1),
} tMenuListDirty;

typedef void (*tOptionSelectCb)(void);
typedef void (*tOptionValChangeCb)(BYTE bDelta);
typedef void (*tOptionValDrawCb)(UBYTE ubIdx);

typedef void (*tCbMenuListUndraw)(
	UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight
);

typedef void (*tCbMenuListDrawPos)(
	UWORD uwX, UWORD uwY, const char *szCaption, const char *szText,
	UBYTE isActive, UWORD *pUndrawWidth
);

// All options are uint8_t, enums or numbers
typedef struct tMenuListOption {
	const char *szCaption;
	tMenuListOptionType eOptionType;
	UBYTE isHidden;
	tMenuListDirty eDirty;
	UWORD uwUndrawWidth;
	union {
		struct {
			UBYTE *pVar;
			UBYTE ubMin;
			UBYTE ubMax;
			UBYTE isCyclic;
			const char **pEnumLabels;
			tOptionValChangeCb cbOnValChange;
			tOptionValDrawCb cbOnValDraw;
		} sOptUb; ///< Params for uint8-based option
		struct {
			tOptionSelectCb cbSelect;
		} sOptCb; ///< Params for callback-based option
	};
} tMenuListOption;

void menuListInit(
	tMenuListOption *pOptions,
	UBYTE ubOptionCount, tFont *pFont, UWORD uwX, UWORD uwY,
	const tCbMenuListUndraw cbUndraw, const tCbMenuListDrawPos cbDrawPos
);

void menuListDraw(void);

void menuListUndraw(void);

void menuListDrawPos(UBYTE ubPos);

void menuListUndrawPos(UBYTE ubPos);

/**
 * @brief Moved current cursor on menu list up or down.
 *
 * @param bDir Direction to move cursor: -1 for "up", +1 for "down"
 * @return 1 if movement is in menu bounds and done correctly, otherwise 0.
 */
UBYTE menuListNavigate(BYTE bDir);

UBYTE menuListToggle(BYTE bDelta);

UBYTE menuListEnter(void);

void menuListSetPosHidden(UBYTE ubPos, UBYTE isHidden);

tMenuListOption *menuListGetActiveOption(void);

UBYTE menuListGetActiveIndex(void);

void menuListSetActiveIndex(UBYTE ubNewPos);

#endif // INCLUDE_MENU_LIST_H
