#ifndef GUARD_OF_MAP_H
#define GUARD_OF_MAP_H

#include <ace/types.h>

#define MAP_LOGIC_WATER   '.'
#define MAP_LOGIC_DIRT    ' '
#define MAP_LOGIC_ROAD    '#'
#define MAP_LOGIC_WALL    '-'
#define MAP_LOGIC_WALL_VERTICAL '|' /* Convenience */
#define MAP_LOGIC_SPAWN0  '0'
#define MAP_LOGIC_SPAWN1  '1'
#define MAP_LOGIC_SPAWN2  '2'
#define MAP_LOGIC_SENTRY0 '$'
#define MAP_LOGIC_SENTRY1 's'
#define MAP_LOGIC_SENTRY2 'S'
#define MAP_LOGIC_FLAG1   'f'
#define MAP_LOGIC_FLAG2   'F'
#define MAP_LOGIC_GATE1   'g'
#define MAP_LOGIC_GATE2   'G'
#define MAP_LOGIC_CAPTURE0 'o'
#define MAP_LOGIC_CAPTURE1 'c'
#define MAP_LOGIC_CAPTURE2 'C'

#define MAP_MAX_SIZE 128
#define MAP_NAME_MAX 30
#define MAP_AUTHOR_MAX 30

#define MAP_MODE_CONQUEST 1
#define MAP_MODE_CTF 2

typedef struct _tTile {
	UBYTE ubIdx;  ///< Tileset idx
	UBYTE ubBuilding; ///< For buildings/gates/spawns used as array idx.
} tMapTile;

typedef struct _tMap {
	char szPath[200];
	char szName[MAP_NAME_MAX];
	char szAuthor[MAP_AUTHOR_MAX];
	FUBYTE fubWidth;
	FUBYTE fubHeight;
	FUBYTE fubSpawnCount;
	UBYTE ubMode;
	tMapTile pData[MAP_MAX_SIZE][MAP_MAX_SIZE];
} tMap;

void mapInit(char *szPath);

void mapSetLogic(UBYTE ubX, UBYTE ubY, UBYTE ubLogic);

extern tMap g_sMap;

#endif // GUARD_OF_MAP_H
