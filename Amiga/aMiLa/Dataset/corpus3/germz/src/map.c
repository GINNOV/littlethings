/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "map.h"
#include <string.h>
#include <ace/managers/memory.h>
#include <ace/managers/log.h>
#include "json/json.h"
#include "player.h"
#include "blob_anim.h"
#include "assets.h"

static void recalcMods(tPlayer *pPlayer) {
	BYTE bCntTick = pPlayer->pNodeTypeCounts[NODE_TYPE_SUPER_TICK];
	BYTE bCntCap = pPlayer->pNodeTypeCounts[NODE_TYPE_SUPER_CAP];
	BYTE bCntAtk = pPlayer->pNodeTypeCounts[NODE_TYPE_SUPER_ATK];

	pPlayer->pMods->ubChargeRate = MAX(
		5, g_sDefs.sBaseMods.ubChargeRate - (5 * bCntTick)
	);
	pPlayer->pMods->wCapacity = g_sDefs.sBaseMods.wCapacity + 20 * bCntCap;
	pPlayer->pMods->ubPower = bCntAtk * 3;
}

static tNode *nodeAdd(UBYTE ubX, UBYTE ubY, tTile eTile) {
	if(g_sMap.uwNodeCount >= MAP_NODES_MAX) {
		logWrite("ERR: Can't add another node\n");
		return 0;
	}
	tNode *pNode = &g_sMap.pNodes[g_sMap.uwNodeCount];
	pNode->sPosTile.ubX = ubX;
	pNode->sPosTile.ubY = ubY;
	for(UBYTE i = 4; i--;) {
		pNode->pNeighbors[i] = 0;
	}
	pNode->pPlayer = playerFromTile(eTile);
	pNode->eType = nodeTypeFromTile(eTile);
	pNode->ubChargeClock = 0;
	if(pNode->pPlayer) {
		pNode->wCharges = 60;
		logWrite("player at pos %hhu,%hhu: %p (%d)\n", ubX, ubY, pNode->pPlayer, eTile);
	}
	else {
		pNode->wCharges = 20;
	}

	pNode->ubIdx = g_sMap.uwNodeCount;
	++g_sMap.uwNodeCount;
	g_sMap.pNodesOnTiles[ubX][ubY] = pNode;
	logWrite("Added node %p (%hhu) at %hhu,%hhu\n", pNode, pNode->ubIdx, ubX, ubY);
	return pNode;
}

static tDirection dirReverse(tDirection eDir) {
	return (eDir ^ 1);
}

static void nodeFindNeighbor(tNode *pNode, tDirection eDir) {
	static const tBCoordYX pDeltas[DIRECTION_COUNT] = {
		[DIRECTION_UP]    = {.bX =  0, .bY = -1},
		[DIRECTION_DOWN]  = {.bX =  0, .bY =  1},
		[DIRECTION_LEFT]  = {.bX = -1, .bY =  0},
		[DIRECTION_RIGHT] = {.bX =  1, .bY =  0},
		[DIRECTION_FIRE]  = {.bX =  0, .bY =  0}, // SHOULDN'T HAPPEN!
	};
	static const tTile pAllowedPaths[DIRECTION_COUNT] = {
		[DIRECTION_UP]    = TILE_PATH_V1,
		[DIRECTION_DOWN]  = TILE_PATH_V1,
		[DIRECTION_LEFT]  = TILE_PATH_H1,
		[DIRECTION_RIGHT] = TILE_PATH_H1,
		[DIRECTION_FIRE]  = TILE_PATH_H1, // SHOULDN'T HAPPEN!
	};

	// Find next blob in line or give up
	BYTE x = pNode->sPosTile.ubX;
	BYTE y = pNode->sPosTile.ubY;
	tTile eTile;
	tTile eAllowedPath = pAllowedPaths[eDir];
	do {
		x += pDeltas[eDir].bX;
		y += pDeltas[eDir].bY;
		if(x < 0 || MAP_SIZE <= x || y < 0 || MAP_SIZE <= y) {
			// logWrite("No more tiles on dir %d\n", eDir);
			return;
		}
		eTile = g_sMapData.pTiles[x][y];
	} while(tileIsVariantOfPath(eTile, eAllowedPath) || tileIsJunction(eTile));

	if(tileIsNode(g_sMapData.pTiles[x][y])) {
		// Mark given node as neigbor
		tNode *pNeighbor = g_sMap.pNodesOnTiles[x][y];
		pNode->pNeighbors[eDir] = pNeighbor;
		pNeighbor->pNeighbors[dirReverse(eDir)] = pNode;
		logWrite("Connected to %p in dir %d\n", pNeighbor, eDir);
	}
}

static void nodeCalculateNeighbors(void) {
	logBlockBegin("nodeCalculateNeighbors()");
	for(UBYTE i = 0; i < g_sMap.uwNodeCount; ++i) {
		logWrite(
			"Searching for neighbors for node %p (%hhu,%hhu)\n",
			&g_sMap.pNodes[i], g_sMap.pNodes[i].sPosTile.ubX, g_sMap.pNodes[i].sPosTile.ubY
		);
		for(tDirection eDir = 0; eDir < DIRECTION_FIRE; ++eDir) {
			if(!g_sMap.pNodes[i].pNeighbors[eDir]) {
				nodeFindNeighbor(&g_sMap.pNodes[i], eDir);
			}
		}
	}
	logBlockEnd("nodeCalculateNeighbors()");
}

void mapInitFromMapData(void) {
	logBlockBegin("mapInitFromMapData()");
	g_sMap.uwNodeCount = 0;

	// Populate map matrix with node pointers
	for(UBYTE x = 0; x < MAP_SIZE; ++x) {
		for(UBYTE y = 0; y < MAP_SIZE; ++y) {
			g_sMap.pNodesOnTiles[x][y] = 0;
			tTile eTile = g_sMapData.pTiles[x][y];
			if(tileIsNode(eTile)) {
				tNode *pNode = nodeAdd(x, y, eTile);
				tPlayerIdx ePlayerIdx = playerToIdx(playerFromTile(eTile));
				if(ePlayerIdx != PLAYER_NONE) {
					g_sMap.pPlayerStartNodes[ePlayerIdx] = pNode;
					logWrite(
						"Player %d start: %hhu,%hhu\n",
						ePlayerIdx, pNode->sPosTile.ubX, pNode->sPosTile.ubY
					);
				}
			}
		}
	}
	logWrite("Node count: %hu", g_sMap.uwNodeCount);

	// Reset stuff
	g_sMap.ubChargeClock = 0;

	// Now that the node matrix is filled, determine neighbors for each node
	nodeCalculateNeighbors();
	logBlockEnd("mapInitFromMapData()");
}

void mapProcessNodes(void) {
	// ++g_sMap.ubChargeClock;
	// if(g_sMap.ubChargeClock >= 5) {
	// 	g_sMap.ubChargeClock = 0;
		for(UBYTE i = 0; i < g_sMap.uwNodeCount; ++i) {
			tNode *pNode = &g_sMap.pNodes[i];
			++pNode->ubChargeClock;
			WORD wCapacity;
			UBYTE ubChargeRate;
			if(pNode->pPlayer) {
				const tPlayerMapModifiers *pNodeMods = pNode->pPlayer->pMods;
				ubChargeRate = pNodeMods->ubChargeRate;
				wCapacity = pNodeMods->wCapacity;
			}
			else {
				ubChargeRate = g_sDefs.sBaseMods.ubChargeRateNeutral;
				wCapacity = g_sDefs.sBaseMods.wCapacity;
			}
			if(pNode->wCharges < wCapacity && pNode->ubChargeClock >= ubChargeRate) {
				pNode->ubChargeClock = 0;
				++pNode->wCharges;
			}
			else if (pNode->wCharges > wCapacity && pNode->ubChargeClock >= 100) {
				pNode->ubChargeClock = 0;
				--pNode->wCharges;
			}
		}
	// }
}

void nodeChangeOwnership(tNode *pNode, tPlayer *pPlayer) {
	if(pNode->pPlayer) {
		--pNode->pPlayer->bNodeCount;
		--pNode->pPlayer->pNodeTypeCounts[pNode->eType];
		if(pNode->eType != NODE_TYPE_NORMAL) {
			recalcMods(pNode->pPlayer);
		}
		playerUpdateDead(pNode->pPlayer);
	}
	pNode->pPlayer = pPlayer;
	if(pPlayer) {
		++pPlayer->bNodeCount;
		++pPlayer->pNodeTypeCounts[pNode->eType];
		if(pNode->eType != NODE_TYPE_NORMAL) {
			recalcMods(pPlayer);
		}
	}
	blobAnimAddToQueue(pNode);
}

void mapUpdateNodeCountForPlayers(void) {
	for(UBYTE i = 0; i < g_sMap.uwNodeCount; ++i) {
		tNode *pNode = &g_sMap.pNodes[i];
		if(pNode->pPlayer) {
			++pNode->pPlayer->bNodeCount;
			++pNode->pPlayer->pNodeTypeCounts[pNode->eType];
		}
	}
	for(tPlayerIdx ePlayerIdx = PLAYER_1; ePlayerIdx <= PLAYER_4; ++ePlayerIdx) {
		recalcMods(playerFromIdx(ePlayerIdx));
	}
}

tMapData g_sMapData;
tMap g_sMap;

tNodeType nodeTypeFromTile(tTile eTile) {
	if(eTile >= TILE_SUPER_ATK_P1) {
		return NODE_TYPE_SUPER_ATK;
	}
	else if(eTile >= TILE_SUPER_TICK_P1) {
		return NODE_TYPE_SUPER_TICK;
	}
	else if(eTile >= TILE_SUPER_CAP_P1) {
		return NODE_TYPE_SUPER_CAP;
	}
	else { // eTile >= TILE_BLOB_P1
		return NODE_TYPE_NORMAL;
	}
}

tTile nodeToTile(const tNode *pNode) {
	tTile eTile;
	switch(pNode->eType) {
		case NODE_TYPE_SUPER_CAP:
			eTile = TILE_SUPER_CAP_P1;
			break;
		case NODE_TYPE_SUPER_TICK:
			eTile = TILE_SUPER_TICK_P1;
			break;
		case NODE_TYPE_SUPER_ATK:
			eTile = TILE_SUPER_ATK_P1;
			break;
		default:
			eTile = TILE_BLOB_P1;
			break;
	}
	eTile += playerToIdx(pNode->pPlayer) - PLAYER_1;
	return eTile;
}
