#ifndef _LD40_GAMESTATES_GAME_MAP_H
#define _LD40_GAMESTATES_GAME_MAP_H

#include "gamestates/game/game.h"
#include <ace/generic/screen.h>

#define MAP_TILE_FREE 0
#define MAP_TILE_BEB 1
#define MAP_TILE_PICKUP 2
#define MAP_TILE_EXIT 3

#define MAP_WIDTH (SCREEN_PAL_WIDTH>>3)
#define MAP_HEIGHT (GAME_MAIN_VPORT_HEIGHT>>3)

void mapCreate(const char *szMapName);

void mapDraw(tBitMap *pBuffer);

extern UBYTE g_pMap[MAP_WIDTH][MAP_HEIGHT];

#define MAP_COUNT 4

#endif // _LD40_GAMESTATES_GAME_MAP_H
