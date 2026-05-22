#include "gamestates/game/ai/astar.h"

tAstarData *astarCreate(void) {
	tAstarData *pNav = memAllocFast(sizeof(tAstarData));
	pNav->pFrontier = heapCreate(AI_MAX_NODES*AI_MAX_NODES);
	pNav->ubState = ASTAR_STATE_OFF;
	return pNav;
}

void astarDestroy(tAstarData *pNav) {
	// GCC -O2 heisenbug - hangs if ommited logBlockBegin/End here
	logBlockBegin("astarDestroy(pNav: %p)", pNav);
	heapDestroy(pNav->pFrontier);
	memFree(pNav, sizeof(tAstarData));
	logBlockEnd("astarDestroy()");
}

void astarStart(tAstarData *pNav, tAiNode *pNodeSrc, tAiNode *pNodeDst) {
	memset(pNav->pCostSoFar, 0xFF, sizeof(UWORD) * AI_MAX_NODES);
	memset(pNav->pCameFrom, 0, sizeof(tAiNode*) * AI_MAX_NODES);
	pNav->pCostSoFar[pNodeSrc->fubIdx] = 0;
	pNav->pNodeDst = pNodeDst;
	heapPush(pNav->pFrontier, pNodeSrc, 0);
	pNav->ubState = ASTAR_STATE_LOOPING;
	pNav->uwCurrNeighbourIdx = g_fubNodeCount;
}

UBYTE astarProcess(tAstarData *pNav) {
	const ULONG ulMaxTime = 2500; // PAL: 1 = 0.4us => 10000 = 4ms => 2500 = 1ms
	if(pNav->ubState == ASTAR_STATE_LOOPING) {
		ULONG ulStart = timerGetPrec();
		do {
			if(pNav->uwCurrNeighbourIdx >= g_fubNodeCount) {
				if(!pNav->pFrontier->uwCount) {
					// TODO What then?
					return 0;
				}
				pNav->pNodeCurr = heapPop(pNav->pFrontier);
				if(pNav->pNodeCurr == pNav->pNodeDst) {
					pNav->ubState = ASTAR_STATE_DONE;
					return 0;
				}
				pNav->uwCurrNeighbourIdx = 0;
			}

			tAiNode *pNextNode = &g_pNodes[pNav->uwCurrNeighbourIdx];
			if(pNextNode != pNav->pNodeCurr) {
				UWORD uwCost = pNav->pCostSoFar[pNav->pNodeCurr->fubIdx]
					+ aiGetCostBetweenNodes(pNav->pNodeCurr, pNextNode);
				if(uwCost < pNav->pCostSoFar[pNextNode->fubIdx]) {
					pNav->pCostSoFar[pNextNode->fubIdx] = uwCost;
					UWORD uwPriority = uwCost
						+ ABS(pNextNode->fubX - pNav->pNodeDst->fubX)
						+ ABS(pNextNode->fubY - pNav->pNodeDst->fubY);
					heapPush(pNav->pFrontier, pNextNode, uwPriority);
					pNav->pCameFrom[pNextNode->fubIdx] = pNav->pNodeCurr;
				}
			}
			++pNav->uwCurrNeighbourIdx;
		} while(timerGetDelta(ulStart, timerGetPrec()) <= ulMaxTime);
	}
	else {
		// ASTAR_STATE_DONE
		pNav->sRoute.pNodes[0] = pNav->pNodeDst;
		pNav->sRoute.ubNodeCount = 1;
		tAiNode *pPrev = pNav->pCameFrom[pNav->pNodeDst->fubIdx];
		while(pPrev) {
			pNav->sRoute.pNodes[pNav->sRoute.ubNodeCount] = pPrev;
			++pNav->sRoute.ubNodeCount;
			pPrev = pNav->pCameFrom[pPrev->fubIdx];
		}
		pNav->sRoute.ubCurrNode = pNav->sRoute.ubNodeCount-1;

		heapClear(pNav->pFrontier);
		pNav->ubState = ASTAR_STATE_OFF;
		return 1;
	}
	return 0;
}
