/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "astar.h"
#include <ace/managers/memory.h>
#include <ace/managers/log.h>

tAstarData *astarCreate(void) {
	tAstarData *pNav = memAllocFast(sizeof(*pNav));
	pNav->uwNodesMax = MAP_NODES_MAX;
	pNav->pFrontier = heapCreate(MAP_NODES_MAX);
	pNav->ubState = ASTAR_STATE_OFF;
	return pNav;
}

void astarSetMaxNodes(tAstarData *pNav, UWORD uwNodesMax) {
	pNav->uwNodesMax = uwNodesMax;
}

void astarDestroy(tAstarData *pNav) {
	// GCC -O2 heisenbug - hangs if ommited logBlockBegin/End here
	logBlockBegin("astarDestroy(pNav: %p)", pNav);
	heapDestroy(pNav->pFrontier);
	memFree(pNav, sizeof(*pNav));
	logBlockEnd("astarDestroy()");
}

void astarStart(tAstarData *pNav, const tNode *pNodeSrc, const tNode *pNodeDst) {
	for(UWORD i = pNav->uwNodesMax; i--;) {
		pNav->pCostSoFar[i] = 0xFFFF;
		pNav->pCameFrom[i] = 0;
	}
	pNav->pCostSoFar[pNodeSrc->ubIdx] = 0;
	pNav->pNodeDst = pNodeDst;
	heapPush(pNav->pFrontier, pNodeSrc, 0);
	pNav->ubState = ASTAR_STATE_LOOPING;
	pNav->ubCurrNeighborIdx = 4;
}

UBYTE astarProcess(tAstarData *pNav) {
	if(pNav->ubState == ASTAR_STATE_LOOPING) {
		const ULONG ulMaxTime = 1250; // PAL: 1 = 0.4us => 10000 = 4ms => 2500 = 1ms
		ULONG ulStart = timerGetPrec(), ulDelta;
		do {
			if(pNav->ubCurrNeighborIdx >= 4) {
				// All neightbors checked - get next node on frontier to process
				if(!pNav->pFrontier->uwCount) {
					// Out of nodes in frontier
					// TODO What then?
					return 0;
				}

				// Get next node from frontier
				pNav->pNodeCurr = heapPop(pNav->pFrontier);
				if(pNav->pNodeCurr == pNav->pNodeDst) {
					// We're at destination!
					pNav->ubState = ASTAR_STATE_DONE;
					return 0;
				}
				pNav->ubCurrNeighborIdx = 0;
			}

			tNode *pNextNode = pNav->pNodeCurr->pNeighbors[pNav->ubCurrNeighborIdx];
			if(pNextNode != 0 && pNextNode != pNav->pNodeCurr) {
				UWORD uwCost = pNav->pCostSoFar[pNav->pNodeCurr->ubIdx] + 1;
				if(uwCost < pNav->pCostSoFar[pNextNode->ubIdx]) {
					pNav->pCostSoFar[pNextNode->ubIdx] = uwCost;
					UWORD uwPriority = (
						uwCost
						+ ABS(pNextNode->sPosTile.ubX - pNav->pNodeDst->sPosTile.ubX)
						+ ABS(pNextNode->sPosTile.ubY - pNav->pNodeDst->sPosTile.ubY)
					);
					// This doesn't replace old occurences of node on heap - other path
					// may be better in the long run.
					heapPush(pNav->pFrontier, pNextNode, uwPriority);
					pNav->pCameFrom[pNextNode->ubIdx] = pNav->pNodeCurr;
				}
			}
			++pNav->ubCurrNeighborIdx;
			ULONG ulNow = timerGetPrec();
			ulDelta = timerGetDelta(ulStart, ulNow);
		} while(ulDelta <= ulMaxTime);
	}
	else {
		// ASTAR_STATE_DONE
		pNav->sRoute.pNodes[0] = pNav->pNodeDst;
		pNav->sRoute.bNodeCount = 1;
		const tNode *pPrev = pNav->pCameFrom[pNav->pNodeDst->ubIdx];
		while(pPrev) {
			pNav->sRoute.pNodes[pNav->sRoute.bNodeCount] = pPrev;
			++pNav->sRoute.bNodeCount;
			pPrev = pNav->pCameFrom[pPrev->ubIdx];
		}
		pNav->sRoute.bCurrNode = pNav->sRoute.bNodeCount-1;

		heapClear(pNav->pFrontier);
		pNav->ubState = ASTAR_STATE_OFF;
		return 1;
	}
	return 0;
}
