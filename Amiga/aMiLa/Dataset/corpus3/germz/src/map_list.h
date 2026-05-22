/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_MAP_LIST_H
#define GERMZ_MAP_LIST_H

#include "gui/list_ctl.h"
#include "map_data.h"

#define MAP_FILENAME_MAX 100

typedef enum tMapEntryType {
	MAP_ENTRY_TYPE_MAP,
	MAP_ENTRY_TYPE_DIR,
	MAP_ENTRY_TYPE_PARENT,
} tMapEntryType;

tListCtl *mapListCreateCtl(
	tBitMap *pBmBfr, UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	const char *szBaseDirPath, const char *szDirPath
);

UBYTE mapListLoadMap(
	const tListCtl *pCtrl, tMapData *pMapData, const char *szDirPath
);

void mapInfoDrawAuthorTitle(
	const tMapData *pMapData, tBitMap *pBmBuffer, UWORD uwX, UWORD uwY
);

void clearMapInfo(tBitMap *pBmBuffer, UWORD uwX, UWORD uwY, UBYTE isDir);

void mapListDrawPreview(
	const tMapData *pMapData, tBitMap *pBmDest, UWORD uwX, UWORD uwY,
	UBYTE ubTileSize
);

void mapListFillWithDir(tListCtl *pCtrl, const char *szDirPath);

#endif // GERMZ_MAP_LIST_H
