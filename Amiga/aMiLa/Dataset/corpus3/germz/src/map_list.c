/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "map_list.h"
#include <ace/utils/dir.h>
#include <ace/utils/string.h>
#include "assets.h"
#include "gui/border.h"
#include "gui/background.h"
#include "color.h"
#include "gui_scanlined.h"

static const char *s_szFilePrev;
static UBYTE s_ubBaseNestLevel;
static UBYTE s_isMapInfoRefreshed;

static UBYTE getPathNestLevel(const char *szPath) {
	UBYTE ubNestLevel = 0;
	UWORD uwLen = strlen(szPath);
	for(UBYTE i = 0; i < uwLen; ++i) {
		if(szPath[i] == '/') {
			++ubNestLevel;
		}
	}
	return ubNestLevel;
}

static int onMapListSort(const void *pA, const void *pB) {
	const tListCtlEntry *pEntryA = (const tListCtlEntry*)pA;
	const tListCtlEntry *pEntryB = (const tListCtlEntry*)pB;
	tMapEntryType eEntryTypeA = (tMapEntryType)pEntryA->pData;
	tMapEntryType eEntryTypeB = (tMapEntryType)pEntryB->pData;

	// Parent directory always first
	if(eEntryTypeA == MAP_ENTRY_TYPE_PARENT) {
		return -1;
	}
	if(eEntryTypeB == MAP_ENTRY_TYPE_PARENT) {
		return -1;
	}

	// Rest is done by sorting of strings - dirs start with dir icon which has
	// lower code than any filename char.
	return SGN(strcmp(pEntryA->szLabel, pEntryB->szLabel));
}

void mapListDrawPreview(
	const tMapData *pMapData, tBitMap *pBmDest, UWORD uwX, UWORD uwY,
	UBYTE ubTileSize
) {
	static const UBYTE pTileColors[TILE_COUNT] = {
		[TILE_BLOB_P1] = 12,
		[TILE_BLOB_P2] = 16,
		[TILE_BLOB_P3] = 20,
		[TILE_BLOB_P4] = 24,
		[TILE_BLOB_NEUTRAL] = 8,
		[TILE_SUPER_CAP_P1] = COLOR_P1_BRIGHT,
		[TILE_SUPER_CAP_P2] = COLOR_P2_BRIGHT,
		[TILE_SUPER_CAP_P3] = COLOR_P3_BRIGHT,
		[TILE_SUPER_CAP_P4] = COLOR_P4_BRIGHT,
		[TILE_SUPER_CAP_NEUTRAL] = 4,
		[TILE_SUPER_TICK_P1] = COLOR_P1_BRIGHT,
		[TILE_SUPER_TICK_P2] = COLOR_P2_BRIGHT,
		[TILE_SUPER_TICK_P3] = COLOR_P3_BRIGHT,
		[TILE_SUPER_TICK_P4] = COLOR_P4_BRIGHT,
		[TILE_SUPER_TICK_NEUTRAL] = 4,
		[TILE_SUPER_ATK_P1] = COLOR_P1_BRIGHT,
		[TILE_SUPER_ATK_P2] = COLOR_P2_BRIGHT,
		[TILE_SUPER_ATK_P3] = COLOR_P3_BRIGHT,
		[TILE_SUPER_ATK_P4] = COLOR_P4_BRIGHT,
		[TILE_SUPER_ATK_NEUTRAL] = 4,
		[TILE_BLANK] = COLOR_SPECIAL_1,
		[TILE_EDITOR_BLANK] = COLOR_SPECIAL_1,
		[TILE_PATH_H1] = 28,
		[TILE_PATH_H2] = 28,
		[TILE_PATH_H3] = 28,
		[TILE_PATH_H4] = 28,
		[TILE_PATH_V1] = 28,
		[TILE_PATH_V2] = 28,
		[TILE_PATH_V3] = 28,
		[TILE_PATH_V4] = 28,
		[TILE_PATH_X1] = 28,
		[TILE_PATH_X2] = 28,
		[TILE_PATH_X3] = 28,
		[TILE_PATH_X4] = 28,
	};

	// const UBYTE ubSize = ubTileSize * 16;
	// guiDraw3dBorder(pBmDest, uwX, uwY, ubSize + 2, ubSize + 2);
	UWORD uwPosY = uwY;
	for(UBYTE ubTileY = 0; ubTileY < MAP_SIZE; ++ubTileY) {
		UWORD uwPosX = uwX;
		for(UBYTE ubTileX = 0; ubTileX < MAP_SIZE; ++ubTileX) {
			UBYTE ubColor = pTileColors[pMapData->pTiles[ubTileX][ubTileY]] >> 1;
			blitRect(pBmDest, uwPosX, uwPosY, ubTileSize, ubTileSize, ubColor);
			uwPosX += ubTileSize;
		}
		uwPosY += ubTileSize;
	}
}

tListCtl *mapListCreateCtl(
	tBitMap *pBmBfr, UWORD uwX, UWORD uwY, UWORD uwWidth, UWORD uwHeight,
	const char *szBaseDirPath, const char *szDirPath
) {
	tListCtl *pCtrl = listCtlCreate(
		pBmBfr, uwX, uwY, uwWidth, uwHeight, g_pFontSmall, 50, "\x1D", "\x1E", 0,
		guiScanlinedBgClear, guiScanlinedListCtlDrawPos
	);
	s_ubBaseNestLevel = getPathNestLevel(szBaseDirPath);
	mapListFillWithDir(pCtrl, szDirPath);
	return pCtrl;
}

void mapListFillWithDir(tListCtl *pCtrl, const char *szDirPath) {
	tDir *pDir = dirOpen(szDirPath);
	if(!pDir) {
		dirCreate(szDirPath);
		pDir = dirOpen(szDirPath);
	}
	if(!pDir) {
		// TODO: something better
		logWrite("Can't open or create maps dir!\n");
		return;
	}

	// Count relevant files
	char szFullPath[strlen(szDirPath) + MAP_FILENAME_MAX + 1];
	char szFileName[MAP_FILENAME_MAX];
	listCtlClear(pCtrl);
	UBYTE ubNestLevel = getPathNestLevel(szDirPath);
	if(ubNestLevel > s_ubBaseNestLevel) {
		listCtlAddEntry(pCtrl, "\x1FPARENT", (void*)((ULONG)MAP_ENTRY_TYPE_PARENT));
	}
	while(dirRead(pDir, szFileName, MAP_FILENAME_MAX)) {
		UWORD uwLen = strlen(szFileName);
		if(uwLen < 20) {
			sprintf(szFullPath, "%s/%s", szDirPath, szFileName);
			tMapEntryType eEntryType = MAP_ENTRY_TYPE_MAP;
			tDir *pOpenedAsDir = dirOpen(szFullPath);
			if(pOpenedAsDir) {
				dirClose(pOpenedAsDir);
				eEntryType = MAP_ENTRY_TYPE_DIR;
				memmove(&szFileName[1], &szFileName[0], strlen(szFileName));
				szFileName[0] = '\x1F';
			}
			else if(!strcmp(&szFileName[uwLen - 5], ".json")) {
				// Trim extension and add to list
				szFileName[strlen(szFileName) - strlen(".json")] = '\0';
			}
			else {
				continue;
			}
			if(listCtlAddEntry(
				pCtrl, szFileName, (void*)((ULONG)eEntryType)
			) == LISTCTL_ENTRY_INVALID) {
				logWrite("ERR: map limit reached\n");
				break;
			}
		}
	}
	dirClose(pDir);
	listCtlSortEntries(pCtrl, onMapListSort);

	// Select first map which is not directory, if possible
	UWORD uwSelection = 0;
	while(uwSelection < pCtrl->uwEntryCnt) {
		tMapEntryType eType = (tMapEntryType)(pCtrl->pEntries[uwSelection].pData);
		if(eType == MAP_ENTRY_TYPE_MAP) {
			listCtlSetSelectionIdx(pCtrl, uwSelection);
			break;
		}
		++uwSelection;
	}

	s_isMapInfoRefreshed = 0;
	s_szFilePrev = 0;
}

UBYTE mapListLoadMap(
	const tListCtl *pCtrl, tMapData *pMapData, const char *szDirPath
) {
	const char *szFile = listCtlGetSelection(pCtrl)->szLabel;
	if(szFile == s_szFilePrev && s_isMapInfoRefreshed) {
		return 0;
	}

	char szPath[MAP_FILENAME_MAX];
	sprintf(szPath, "%s/%s.json", szDirPath, szFile);
	mapDataInitFromFile(pMapData, szPath);

	s_isMapInfoRefreshed = 1;
	s_szFilePrev = szFile;
	return 1;
}

void mapInfoDrawAuthorTitle(
	const tMapData *pMapData, tBitMap *pBmBuffer, UWORD uwX, UWORD uwY
) {
	const UBYTE ubRowWidth = 100;
	const UBYTE ubRowHeight = g_pFontSmall->uwHeight + 2;

	guiScanlinedBgClear(uwX, uwY, ubRowWidth, ubRowHeight);
	fontDrawStr(
		g_pFontSmall, pBmBuffer, uwX, uwY, "Title:",
		18 >> 1, FONT_COOKIE, g_pTextBitmap
	);
	uwY += ubRowHeight;

	guiScanlinedBgClear(uwX, uwY, ubRowWidth, ubRowHeight);
	fontDrawStr(
		g_pFontSmall, pBmBuffer, uwX + 5, uwY, pMapData->szName,
		18 >> 1, FONT_COOKIE, g_pTextBitmap
	);
	uwY += ubRowHeight;

	guiScanlinedBgClear(uwX, uwY, ubRowWidth, ubRowHeight);
	fontDrawStr(
		g_pFontSmall, pBmBuffer, uwX, uwY, "Author:",
		18 >> 1, FONT_COOKIE, g_pTextBitmap
	);
	uwY += ubRowHeight;

	guiScanlinedBgClear(uwX, uwY, ubRowWidth, ubRowHeight);
	fontDrawStr(
		g_pFontSmall, pBmBuffer, uwX + 5, uwY, pMapData->szAuthor,
		18 >> 1, FONT_COOKIE, g_pTextBitmap
	);
}

void clearMapInfo(tBitMap *pBmBuffer, UWORD uwX, UWORD uwY, UBYTE isDir) {
	const UBYTE ubRowWidth = 100;
	const UBYTE ubRowHeight = g_pFontSmall->uwHeight + 2;

	guiScanlinedBgClear(uwX, uwY, ubRowWidth, ubRowHeight * 4);
	fontDrawStr(
		g_pFontSmall, pBmBuffer, uwX, uwY, isDir ? "Opening dir..." : "Loading map...",
		18 >> 1, FONT_COOKIE, g_pTextBitmap
	);
	s_isMapInfoRefreshed = 0;
}
