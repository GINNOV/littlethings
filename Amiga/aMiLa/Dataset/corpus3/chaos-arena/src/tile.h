/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_TILE_H
#define INCLUDE_TILE_H

#include <ace/utils/bitmap.h>

#define MAP_TILE_SIZE 16
#define MAP_TILE_SIDE_HEIGHT 4
#define MAP_FULL_TILE_HEIGHT (MAP_TILE_SIZE + MAP_TILE_SIDE_HEIGHT)
#define HALF_TILE_SIZE (MAP_TILE_SIZE / 2)

void tilesInit(void);

void tilesDrawAllOn(tBitMap *pDestination);

UBYTE tileIsSolid(UBYTE ubTileX, UBYTE ubTileY);

void tileShuffleSpawns(void);

const tUwCoordYX *tileGetSpawn(UBYTE ubIndex);

void tileCrumbleProcess(tBitMap *pBuffer);

void tilesReload(void);

#endif // INCLUDE_TILE_H
