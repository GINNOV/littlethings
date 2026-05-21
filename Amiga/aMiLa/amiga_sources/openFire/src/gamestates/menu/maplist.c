#include "gamestates/menu/maplist.h"
#include <string.h>
#include <ace/types.h>
#include <ace/managers/memory.h>
#include <ace/managers/key.h>
#include <ace/managers/game.h>
#include <ace/managers/mouse.h>
#include <ace/managers/system.h>
#include <ace/utils/dir.h>
#include "cursor.h"
#include "map.h"
#include "gamestates/menu/menu.h"
#include "gamestates/menu/button.h"
#include "gamestates/menu/listctl.h"
#include "gamestates/menu/minimap.h"
#include "gamestates/game/game.h"

#define MAPLIST_FILENAME_MAX 108

#define MAPLIST_COLOR_MINIMAP_BORDER 1

typedef char tMapListEntry[MAPLIST_FILENAME_MAX];

typedef struct _tMapList {
	UWORD uwMapCount;
	tMapListEntry *pMaps;
} tMapList;

static tMapList s_sMapList;
static tListCtl *s_pListCtl;

static void mapListPrepareList(void) {
	systemUse();
	// Get map count
	s_sMapList.uwMapCount = 0;
	tDir *pDir = dirOpen("data/maps");
	char szFileName[MAPLIST_FILENAME_MAX];
	if(!pDir) {
		systemUnuse();
		return;
	}
	while(dirRead(pDir, szFileName, MAPLIST_FILENAME_MAX)) {
		if(!strcmp(&szFileName[strlen(szFileName)-strlen(".json")], ".json")) {
			++s_sMapList.uwMapCount;
		}
	}
	dirClose(pDir);

	// Alloc map list
	if(!s_sMapList.uwMapCount) {
		systemUnuse();
		return;
	}
	s_sMapList.pMaps = memAllocFast(s_sMapList.uwMapCount * sizeof(tMapListEntry));
	UBYTE i = 0;
	pDir = dirOpen("data/maps");
	while(dirRead(pDir, szFileName, MAPLIST_FILENAME_MAX)) {
		if(!strcmp(&szFileName[strlen(szFileName)-strlen(".json")], ".json")) {
			memcpy(s_sMapList.pMaps[i], szFileName, MAPLIST_FILENAME_MAX);
			++i;
		}
	}
	dirClose(pDir);
	systemUnuse();
}

static void mapListSelect(UWORD uwIdx) {
	systemUse();
	mapInit(s_sMapList.pMaps[uwIdx]);
	minimapDraw(g_pMenuBuffer->pBack, &g_sMap);
	char szBfr[20 + MAX(MAP_AUTHOR_MAX, MAP_NAME_MAX)];
	blitRect(
		g_pMenuBuffer->pBack, MAPLIST_MINIMAP_X,
		MAPLIST_MINIMAP_Y + MAPLIST_MINIMAP_WIDTH + 16,
		320-MAPLIST_MINIMAP_X, 3*(g_pMenuFont->uwHeight + 1), MENU_COLOR_BG
	);
	sprintf(szBfr, "Map name: %s", g_sMap.szName);
	fontFillTextBitMap(g_pMenuFont, g_pMenuTextBitmap, szBfr);
	fontDrawTextBitMap(g_pMenuBuffer->pBack, g_pMenuTextBitmap,
		MAPLIST_MINIMAP_X,
		MAPLIST_MINIMAP_Y + MAPLIST_MINIMAP_WIDTH + 16 + 0*(g_pMenuFont->uwHeight+1),
		MENU_COLOR_TEXT, 0
	);
	sprintf(szBfr, "Author: %s", g_sMap.szAuthor);
	fontFillTextBitMap(g_pMenuFont, g_pMenuTextBitmap, szBfr);
	fontDrawTextBitMap(g_pMenuBuffer->pBack, g_pMenuTextBitmap,
		MAPLIST_MINIMAP_X,
		MAPLIST_MINIMAP_Y + MAPLIST_MINIMAP_WIDTH + 16 + 1*(g_pMenuFont->uwHeight+1),
		MENU_COLOR_TEXT, 0
	);
	const char szModeConquest[] = "Mode: Conquest";
	const char szModeCtf[] = "Mode: CTF";
	const char *pMode = 0;
	if(g_sMap.ubMode == MAP_MODE_CONQUEST) {
		pMode = szModeConquest;
	}
	else if(g_sMap.ubMode == MAP_MODE_CTF) {
		pMode = szModeCtf;
	}
	fontFillTextBitMap(g_pMenuFont, g_pMenuTextBitmap, pMode);
	fontDrawTextBitMap(g_pMenuBuffer->pBack, g_pMenuTextBitmap,
		MAPLIST_MINIMAP_X,
		MAPLIST_MINIMAP_Y + MAPLIST_MINIMAP_WIDTH + 16 + 2*(g_pMenuFont->uwHeight+1),
		MENU_COLOR_TEXT, 0
	);
	systemUnuse();
}

static void mapListOnBtnStart(void) {
	g_isLocalBot = 0;
	gamePopState(); // From menu substate
	gameChangeState(gsGameCreate, gsGameLoop, gsGameDestroy);
}

static void mapListOnBtnBack(void) {
	gameChangeState(menuMainCreate, menuLoop, menuMainDestroy);
}

static void mapListOnMapChange(void) {
	mapListSelect(s_pListCtl->uwEntrySel);
}

void mapListCreate(void) {
	systemUse();
	logBlockBegin("mapListCreate()");
	// Clear bg
	blitRect(
		g_pMenuBuffer->pBack, 0, 0,
		(WORD)(bitmapGetByteWidth(g_pMenuBuffer->pBack) << 3),
		(WORD)(g_pMenuBuffer->pBack->Rows),
		MENU_COLOR_BG
	);
	blitWait();

	buttonListCreate(10, g_pMenuBuffer->pBack, g_pMenuFont);

	mapListPrepareList();

	s_pListCtl = listCtlCreate(
		g_pMenuBuffer->pBack, 10, 10, 100, 200,
		g_pMenuFont, s_sMapList.uwMapCount,
		mapListOnMapChange
	);
	for(UWORD i = 0; i != s_sMapList.uwMapCount; ++i) {
		s_sMapList.pMaps[i][strlen(s_sMapList.pMaps[i])-5] = '\0';
		listCtlAddEntry(s_pListCtl, s_sMapList.pMaps[i]);
		s_sMapList.pMaps[i][strlen(s_sMapList.pMaps[i])] = '.';
	}
	listCtlDraw(s_pListCtl);

	buttonAdd(220, 200, 80, 16, "Play", mapListOnBtnStart);
	buttonAdd(220, 220, 80, 16, "Back", mapListOnBtnBack);
	buttonDrawAll();

	blitRect(
		g_pMenuBuffer->pBack,
		MAPLIST_MINIMAP_X - 1, MAPLIST_MINIMAP_Y - 1,
		MAPLIST_MINIMAP_WIDTH + 2, MAPLIST_MINIMAP_WIDTH + 2,
		MAPLIST_COLOR_MINIMAP_BORDER
	);
	mapListSelect(s_pListCtl->uwEntrySel);
	logBlockEnd("mapListCreate()");
	systemUnuse();
}

void mapListLoop(void) {
	if(keyUse(KEY_ESCAPE)) {
		gameChangeState(menuMainCreate, menuLoop, menuMainDestroy);
		return;
	}

	if(mouseUse(MOUSE_PORT_1, MOUSE_LMB)) {
		if(!buttonProcessClick(mouseGetX(MOUSE_PORT_1), mouseGetY(MOUSE_PORT_1))) {
			if(listCtlProcessClick(
				s_pListCtl, mouseGetX(MOUSE_PORT_1), mouseGetY(MOUSE_PORT_1)
			)) {
				return;
			}
		}
		return;
	}

	menuProcess();
}

void mapListDestroy(void) {
	systemUse();
	logBlockBegin("mapListDestroy()");
	memFree(s_sMapList.pMaps, s_sMapList.uwMapCount * sizeof(tMapListEntry));
	listCtlDestroy(s_pListCtl);
	buttonListDestroy();
	logBlockEnd("mapListDestroy()");
	systemUnuse();
}
