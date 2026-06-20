#ifndef GUARD_OF_GAMESTATES_GAME_WORLDMAP_H
#define GUARD_OF_GAMESTATES_GAME_WORLDMAP_H

#include <ace/utils/extview.h>
#include <ace/utils/bitmap.h>
#include "map.h"

#define MAP_TILE_SIZE 5
#define MAP_FULL_TILE (1 << MAP_TILE_SIZE)
#define MAP_HALF_TILE (MAP_FULL_TILE >> 1)

#define MAP_TILE_WATER      0
#define MAP_TILE_SPAWN_BLUE 1
#define MAP_TILE_SPAWN_RED  2
#define MAP_TILE_SPAWN_NONE 3

#define MAP_TILE_SPAWN_BLUE_HI 4
#define MAP_TILE_SPAWN_RED_HI  5
#define MAP_TILE_SPAWN_NONE_HI 6

// Capture points
#define MAP_TILE_CAPTURE_BLUE 7
#define MAP_TILE_CAPTURE_RED  8
#define MAP_TILE_CAPTURE_NONE 9

// Flag buildings - 'live' & destroyed
#define MAP_TILE_FLAG1L 10
#define MAP_TILE_FLAG2L 11
#define MAP_TILE_FLAGD  12

// Destroyed wall tile
#define MAP_TILE_WALLD    13

// Gates - horizontal & vertical, 'live' & destroyed
// #define MAP_TILE_GATEVL   11
// #define MAP_TILE_GATEVD   12
// #define MAP_TILE_GATEHL   13
// #define MAP_TILE_GATEHD   14

// 16-variant tiles - base codes, ends 16 positions later.
#define MAP_TILE_DIRT     16
#define MAP_TILE_ROAD     32
#define MAP_TILE_WALL     48

#define MAP_TILE_SURFACING_TANK_BLUE     64
#define MAP_TILE_SURFACING_CHOPPER_BLUE  80
#define MAP_TILE_SURFACING_ASV_BLUE      96
#define MAP_TILE_SURFACING_JEEP_BLUE    112

#define MAP_TILE_SURFACING_TANK_RED     70
#define MAP_TILE_SURFACING_CHOPPER_RED  86
#define MAP_TILE_SURFACING_ASV_RED     102
#define MAP_TILE_SURFACING_JEEP_RED    118


typedef struct _tTileCoord {
	UBYTE ubX;
	UBYTE ubY;
} tTileCoord;

void worldMapCreate(tBitMap *pFront, tBitMap *pBack);

void worldMapDestroy(void);

void worldMapSwapBuffers(void);

UBYTE worldMapTileFromLogic(FUBYTE ubTileX, FUBYTE ubTileY);

UBYTE worldMapIsWall(UBYTE ubMapTile);

void worldMapUpdateTiles(void);

//-------------------------------------------------- Tile manipulation functions

void worldMapSetTile(UBYTE ubX, UBYTE ubY, UBYTE ubLogicTileIdx);

void worldMapTrySetTile(UBYTE ubX, UBYTE ubY, UBYTE ubLogicTileIdx);

void worldMapRequestUpdateTile(UBYTE ubTileX, UBYTE ubTileY);

//----------------------------------------------------------- Tile idx functions

UBYTE worldMapTileWater(void);

UBYTE worldMapTileDirt(UBYTE ubX, UBYTE ubY);

UBYTE worldMapTileRoad(UBYTE ubX, UBYTE ubY);

UBYTE worldMapTileSpawn(UBYTE ubTeam, UBYTE ubIsActive);

UBYTE worldMapTileWall(UBYTE ubX, UBYTE ubY);

UBYTE worldMapTileTurret(void);

UBYTE worldMapTileCapture(UBYTE ubTeam);

extern tBitMap *g_pMapTileset;

#endif // GUARD_OF_GAMESTATES_GAME_WORLDMAP_H
