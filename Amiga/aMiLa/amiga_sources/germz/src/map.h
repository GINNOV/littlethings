/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_MAP_H
#define GERMZ_MAP_H

#include "direction.h"
#include "map_data.h"

#define MAP_NODES_MAX 255
#define MAP_TILE_SIZE 16
// #define MAP_TICK_RATE 25
#define MAP_TICK_RATE 5

typedef enum tNodeType {
	NODE_TYPE_NORMAL,
	NODE_TYPE_SUPER_CAP,
	NODE_TYPE_SUPER_TICK,
	NODE_TYPE_SUPER_ATK,
	NODE_TYPE_COUNT
} tNodeType;

typedef struct tNode {
	UBYTE ubIdx;
	tUbCoordYX sPosTile;
	struct tPlayer *pPlayer;
	struct tNode *pNeighbors[DIRECTION_COUNT - 1];
	WORD wCharges;
	UBYTE ubChargeClock;
	tNodeType eType;
} tNode;

typedef struct tMap {
	tNode pNodes[MAP_NODES_MAX];
	tNode *pNodesOnTiles[MAP_SIZE][MAP_SIZE];
	UWORD uwNodeCount;
	tNode *pPlayerStartNodes[4];
	UBYTE ubChargeClock;
} tMap;

void mapInitFromMapData(void);

void mapProcessNodes(void);

void nodeChangeOwnership(tNode *pNode, struct tPlayer *pPlayer);

void mapUpdateNodeCountForPlayers(void);

tNodeType nodeTypeFromTile(tTile eTile);

tTile nodeToTile(const tNode *pNode);

extern tMapData g_sMapData;
extern tMap g_sMap;

#endif // GERMZ_MAP_H
