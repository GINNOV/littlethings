#include "gamestates/menu/minimap.h"
#include "gamestates/menu/maplist.h"
#include <ace/utils/bitmap.h>
#include "map.h"
#include "gamestates/menu/menu.h"

#define MINIMAP_COLOR_WATER     0
#define MINIMAP_COLOR_TERRAIN   1
#define MINIMAP_COLOR_WALL      2
#define MINIMAP_COLOR_SPAWN0    3
#define MINIMAP_COLOR_SPAWN1    4
#define MINIMAP_COLOR_SPAWN2    5
#define MINIMAP_COLOR_CONTROL0  6
#define MINIMAP_COLOR_CONTROL1  7
#define MINIMAP_COLOR_CONTROL2  8

void minimapDraw(tBitMap *pDest, tMap *pMap) {
	// Clear Map area
	blitRect(
		pDest, MAPLIST_MINIMAP_X, MAPLIST_MINIMAP_Y,
		MAPLIST_MINIMAP_WIDTH, MAPLIST_MINIMAP_WIDTH, MINIMAP_COLOR_WATER
	);

	// Padding, scale
	UBYTE ubScale = MAPLIST_MINIMAP_WIDTH / MAX(pMap->fubWidth, pMap->fubHeight);
	UBYTE ubPadX = (MAPLIST_MINIMAP_WIDTH - pMap->fubWidth*ubScale) >> 1;
	UBYTE ubPadY = (MAPLIST_MINIMAP_WIDTH - pMap->fubHeight*ubScale) >> 1;

	UBYTE ubTileColor;
	for (FUBYTE y = 0; y != pMap->fubHeight; ++y) {
		for (FUBYTE x = 0; x != pMap->fubWidth; ++x) {
			switch (pMap->pData[x][y].ubIdx) {
				case MAP_LOGIC_WATER:
					ubTileColor = MINIMAP_COLOR_WATER;
					break;
				case MAP_LOGIC_WALL:
				case MAP_LOGIC_SENTRY0:
				case MAP_LOGIC_SENTRY1:
				case MAP_LOGIC_SENTRY2:
					ubTileColor = MINIMAP_COLOR_WALL;
					break;
				case MAP_LOGIC_SPAWN0:
					ubTileColor = MINIMAP_COLOR_SPAWN0;
					break;
				case MAP_LOGIC_SPAWN1:
					ubTileColor = MINIMAP_COLOR_SPAWN1;
					break;
				case MAP_LOGIC_SPAWN2:
					ubTileColor = MINIMAP_COLOR_SPAWN2;
					break;
				case MAP_LOGIC_CAPTURE0:
					ubTileColor = MINIMAP_COLOR_CONTROL0;
					break;
				case MAP_LOGIC_CAPTURE1:
					ubTileColor = MINIMAP_COLOR_CONTROL1;
					break;
				case MAP_LOGIC_CAPTURE2:
					ubTileColor = MINIMAP_COLOR_CONTROL2;
					break;
				default:
					ubTileColor = MINIMAP_COLOR_TERRAIN;
			}

			blitRect(
				pDest,
				MAPLIST_MINIMAP_X + ubPadX + x * ubScale,
				MAPLIST_MINIMAP_Y + ubPadY + y * ubScale,
				ubScale, ubScale, ubTileColor
			);
		}
	}
}
