/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_BASE_H_
#define _AMINER_BASE_H_

#include <ace/managers/viewport/tilebuffer.h>
#include "defs.h"

/**
 * @brief Determines that the base is a variant of other base and shouldn't
 * be naturally spawned on any depth.
 */
#define BASE_TILE_DEPTH_VARIANT 65535
#define BASE_PATTERN_HEIGHT 10
#define BASE_CAVE_HEIGHT 8

typedef enum tBaseId {
	BASE_ID_GROUND,
	BASE_ID_DINO,
	BASE_ID_GATE,
	BASE_ID_WESTERN,
	BASE_ID_COUNT_UNIQUE,
	// Variants:
	BASE_ID_DINO_POPULATED = BASE_ID_COUNT_UNIQUE,
	BASE_ID_COUNT,
} tBaseId;

typedef void (*tCbBaseProcess)(void);

typedef struct _tBase {
	UBYTE pTilePattern[DEFS_MINE_DIGGABLE_WIDTH * BASE_PATTERN_HEIGHT];
	UWORD uwTileDepth;
	tUwAbsRect sRectRestock;
	tUwCoordYX sPosTeleport;
	tUwCoordYX sPosAntenna;
	tUwCoordYX sPosWorkshop;
	tCbBaseProcess cbProcess;
} tBase;

void baseCreate(tTileBufferManager *pManager);

void baseDestroy(void);

void baseProcess(void);

const tBase *baseGetById(tBaseId eId);

const tBase *baseGetCurrent(void);

tBaseId baseGetCurrentId(void);

void baseUpdateDinoTileset(UBYTE isPopulated);

void baseTilesetPrepareForChallenge(void);

#endif // _AMINER_BASE_H_
