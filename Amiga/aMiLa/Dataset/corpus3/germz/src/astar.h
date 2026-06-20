/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_ASTAR_H
#define GERMZ_ASTAR_H

#include <ace/types.h>
#include "map.h"
#include "heap.h"

#define ASTAR_STATE_OFF 0
#define ASTAR_STATE_LOOPING 1
#define ASTAR_STATE_DONE 2

#define ASTAR_ROUTE_NODE_MAX 20

/**
 * Pathfinding route struct.
 * Nodes are in reverse order - index zero is always destination.
 * TOOD implement as stack
 */
typedef struct tRoute {
	BYTE bNodeCount; ///< Number of nodes in route.
	BYTE bCurrNode; ///< Currently processed route node idx.
	const tNode *pNodes[ASTAR_ROUTE_NODE_MAX]; ///< First is dest
} tRoute;

typedef struct {
	UBYTE ubState; ///< See ASTAR_STATE_* defines
	UBYTE ubCurrNeighborIdx;
	UWORD pCostSoFar[MAP_NODES_MAX];
	tHeap *pFrontier;
	const tNode *pCameFrom[MAP_NODES_MAX];
	const tNode *pNodeDst;
	const tNode *pNodeCurr;
	UWORD uwNodesMax;
	tRoute sRoute;
} tAstarData;

/**
 * Allocates data for A* algorithm.
 * @return Newly allocated A* data struct.
 */
tAstarData *astarCreate(void);

/**
 * Frees A* data structure.
 * @param pNav A* data structure to be freed.
 */
void astarDestroy(tAstarData *pNav);

/**
 * @brief Set the upper bound for A* arrays.
 * Setting to low values speeds up clearing arrays.
 *
 * @param pNav
 * @param uwNodesMax
 */
void astarSetMaxNodes(tAstarData *pNav, UWORD uwNodesMax);

/**
 * Prepares A* initial conditions.
 * @param pNav A* data struct to be used.
 * @param pNodeSrc Route's first node.
 * @param pNodeDst Route's destination node.
 */
void astarStart(tAstarData *pNav, const tNode *pNodeSrc, const tNode *pNodeDst);

/**
 *
 */
UBYTE astarProcess(tAstarData *pNav);

#endif // GERMZ_ASTAR_H
