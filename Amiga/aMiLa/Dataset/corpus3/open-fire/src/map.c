#include "map.h"
#include <ace/managers/log.h>
#include <ace/managers/memory.h>
#include "mapjson.h"

tMap g_sMap = {.fubWidth = 0, .fubHeight = 0, .pData = {{{0}}}};

void mapInit(char *szFileName) {
	logBlockBegin("mapInit(szPath: %s)", szFileName);
	sprintf(g_sMap.szPath, "data/maps/%s", szFileName);
	tJson *pMapJson = jsonCreate(g_sMap.szPath);

	// Objects may have properties passed in random order
	// so 1st pass will extract only general data
	mapJsonGetMeta(pMapJson, &g_sMap);
	logWrite(
		"Dimensions: %" PRI_FUBYTE "x%" PRI_FUBYTE "\n",
		g_sMap.fubWidth, g_sMap.fubHeight
	);

	mapJsonReadTiles(pMapJson, &g_sMap);

	jsonDestroy(pMapJson);
	logBlockEnd("mapInit()");
}

void mapSetLogic(UBYTE ubX, UBYTE ubY, UBYTE ubLogic) {
	g_sMap.pData[ubX][ubY].ubIdx = ubLogic;
}
