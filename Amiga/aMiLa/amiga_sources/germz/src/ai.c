/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "ai.h"
#include "astar.h"
#include "player.h"

static const tMap *s_pMap;
static tAstarData *s_pAstar[4];

#if defined GAME_DEBUG_AI
#define logWriteAi(...) logWrite(__VA_ARGS__)
#else
#define logWriteAi(...) do {} while(0)
#endif

static void aiTransitToPlanning(tAi *pAi) {
	if(pAi->wasLastAggresive) {
		pAi->eState = AI_STATE_PLANNING_DEFENSIVE;
		logWriteAi("\n[AI] Replan to def\n");
	}
	else {
		pAi->eState = AI_STATE_PLANNING_AGGRESIVE;
		logWriteAi("\n[AI] Replan to aggro\n");
	}
	pAi->uwCurrNode = 0;
	pAi->wBiggestDelta = -32768;
	pAi->pTargetSrc = 0;
	pAi->pTarget = 0;
	pAi->eNeighborIdx = 0;
	pAi->wasLastAggresive = !pAi->wasLastAggresive;
	pAi->pTargetCurrNode = pAi->pTarget;
	pAi->wBiggestDeltaCurrNode = pAi->wBiggestDelta;
}

static tDirection aiProcessPlanningAggressive(tAi *pAi) {
	const tPlayer *pPlayer = playerFromIdx(pAi->ubPlayerIdx);

	// Process only if there's at least one free plep
	if(!playerHasFreePlep(pPlayer)) {
		return DIRECTION_COUNT;
	}

	// Get next owned blob
	const tNode *pNode = &s_pMap->pNodes[pAi->uwCurrNode];
	UBYTE isNextNode = 0;

	if(pNode->pPlayer == pPlayer && pNode->wCharges > 10) {
		// Check directions for enemy neighbors
		if(pAi->eNeighborIdx < 4) {
			// Store the weakest enemy
			if(
				pNode->pNeighbors[pAi->eNeighborIdx] &&
				pNode->pNeighbors[pAi->eNeighborIdx]->pPlayer != pPlayer
			) {
				WORD wDelta = pNode->wCharges - pNode->pNeighbors[pAi->eNeighborIdx]->wCharges;
				logWriteAi(
					"[AI] wDelta: %hd - %hd = %hd\n",
					pNode->wCharges, pNode->pNeighbors[pAi->eNeighborIdx]->wCharges, wDelta
				);
				if(wDelta > pAi->wBiggestDelta) {
					pAi->pTargetSrc = pNode;
					pAi->pTarget = pNode->pNeighbors[pAi->eNeighborIdx];
					pAi->wBiggestDelta = wDelta;
					logWriteAi("[AI] aggro: stored next potential target: %p\n", pAi->pTarget);
				}
			}
			++pAi->eNeighborIdx;
		}
		else {
			// Out of directions - next node
			isNextNode = 1;
			logWriteAi(
				"[AI] aggro: out of directions for node at %hhu,%hhu\n",
				pNode->sPosTile.ubX, pNode->sPosTile.ubY
			);
		}
	}
	else {
		isNextNode = 1;
	}

	if(isNextNode) {
		pAi->eNeighborIdx = 0;
		if(++pAi->uwCurrNode >= s_pMap->uwNodeCount) {
			// Out of nodes - execute attack or plan defensive move
			if(pAi->pTarget) {
				logWriteAi(
					"[AI] aggro: cursor %p, getting to %p to fire into %p (%hhu,%hhu)\n",
					pPlayer->pNodeCursor, pAi->pTargetSrc, pAi->pTarget,
					pAi->pTarget->sPosTile.ubX, pAi->pTarget->sPosTile.ubY
				);
				pAi->eState = AI_STATE_ROUTING;
			}
			else {
				aiTransitToPlanning(pAi);
			}
		}
	}
	return DIRECTION_COUNT;
}

static tDirection aiProcessPlanningDefensive(tAi *pAi) {
	const tPlayer *pPlayer = playerFromIdx(pAi->ubPlayerIdx);

	// Process only if there's at least one free plep
	if(!playerHasFreePlep(pPlayer)) {
		return DIRECTION_COUNT;
	}

	// Get next owned blob
	const tNode *pNode = &s_pMap->pNodes[pAi->uwCurrNode];
	UBYTE isNextNode = 0;

	if(pNode->pPlayer == pPlayer && pNode->wCharges > 10) {
		// Check directions for allied neighbors
		if(pAi->eNeighborIdx < 4) {
			// Store the weakest ally
			if(pNode->pNeighbors[pAi->eNeighborIdx]) {
				if(pNode->pNeighbors[pAi->eNeighborIdx]->pPlayer != pPlayer) {
					// Colliding with enemy - skip node entirely
					logWriteAi(
						"[AI] def: skipping node %p (%hhu,%hhu) since it's in border\n",
						pNode, pNode->sPosTile.ubX, pNode->sPosTile.ubY
					);
					isNextNode = 1;
				}
				else if(
					pNode->pNeighbors[pAi->eNeighborIdx]->pPlayer == pPlayer
				) {
					WORD wDelta = pNode->wCharges - pNode->pNeighbors[pAi->eNeighborIdx]->wCharges;
					logWriteAi(
						"[AI] wDelta: %hd - %hd = %hd\n",
						pNode->wCharges, pNode->pNeighbors[pAi->eNeighborIdx]->wCharges, wDelta
					);
					if(wDelta > pAi->wBiggestDeltaCurrNode) {
						// Store target/delta for current node in case it gets discarded
						// because of being on border
						pAi->pTargetCurrNode = pNode->pNeighbors[pAi->eNeighborIdx];
						pAi->wBiggestDeltaCurrNode = wDelta;
						logWriteAi("[AI] def: stored next potential target for current node %p: %p\n", pNode, pAi->pTargetCurrNode);
					}
				}
			}
			++pAi->eNeighborIdx;
		}
		else {
			// Out of directions - next node, but store target if there is new
			if(pAi->pTarget != pAi->pTargetCurrNode) {
				pAi->pTarget = pAi->pTargetCurrNode;
				pAi->pTargetSrc = pNode;
				pAi->wBiggestDelta = pAi->wBiggestDeltaCurrNode;
				logWriteAi("[AI] def: stored global potential target: %p\n", pAi->pTarget);
			}
			isNextNode = 1;
		}
	}
	else {
		isNextNode = 1;
	}

	if(isNextNode) {
		pAi->pTargetCurrNode = pAi->pTarget;
		pAi->wBiggestDeltaCurrNode = pAi->wBiggestDelta;
		pAi->eNeighborIdx = 0;
		if(++pAi->uwCurrNode >= s_pMap->uwNodeCount) {
			// Out of nodes - execute defense or plan aggresive move
			if(pAi->pTarget) {
				logWriteAi(
					"[AI] def: cursor %p, getting to %p (%hhu,%hhu) to fire into %p (%hhu,%hhu)\n",
					pPlayer->pNodeCursor,
					pAi->pTargetSrc, pAi->pTargetSrc->sPosTile.ubX, pAi->pTargetSrc->sPosTile.ubY,
					pAi->pTarget, pAi->pTarget->sPosTile.ubX, pAi->pTarget->sPosTile.ubY
				);
				pAi->eState = AI_STATE_ROUTING;
			}
			else {
				aiTransitToPlanning(pAi);
			}
		}
	}
	return DIRECTION_COUNT;
}

static tDirection aiProcessRouting(tAi *pAi) {
	tAstarData *pNav = s_pAstar[pAi->ubPlayerIdx];
	if(pAi->isAstarStarted) {
		if(astarProcess(pNav)) {
			logWriteAi(
				"[AI] Found route with %hhu steps\n",
				pNav->sRoute.bNodeCount
			);
			for(UBYTE i = pNav->sRoute.bNodeCount; i--;) {
				logWriteAi(
					"-> %hhu@%p (%hhu,%hhu)", i, pNav->sRoute.pNodes[i],
					pNav->sRoute.pNodes[i]->sPosTile.ubX,
					pNav->sRoute.pNodes[i]->sPosTile.ubY
				);
			}
			logWriteAi("\n");
			pAi->eState = AI_STATE_GETTING_TO_SOURCE_BLOB;
			pAi->isAstarStarted = 0;
		}
	}
	else {
		const tPlayer *pPlayer = playerFromIdx(pAi->ubPlayerIdx);
		astarStart(pNav, pPlayer->pNodeCursor, pAi->pTargetSrc);
		pAi->isAstarStarted = 1;
	}
	return DIRECTION_COUNT;
}

static tDirection aiProcessGettingToSourceBlob(tAi *pAi) {
	const tPlayer *pPlayer = playerFromIdx(pAi->ubPlayerIdx);
	tAstarData *pNav = s_pAstar[pAi->ubPlayerIdx];

	if(pNav->sRoute.bCurrNode < 0) {
		// End of the road
		if(pPlayer->pNodeCursor == pAi->pTargetSrc) {
			// We're at last on source
			if(pAi->pTargetSrc->pPlayer == pPlayer) {
				// It's still ours so let's continue
				logWriteAi("[AI] We're at source, fire!\n");
				pAi->eNeighborIdx = 0;
				pAi->eState = AI_STATE_TARGETING_TARGET;
				pAi->isPressingFire = 1;
				return DIRECTION_COUNT;
			}
			logWriteAi("[AI] Source node's no longer ours - start again\n");
			aiTransitToPlanning(pAi);
		}
		else {
			logWrite(
				"[AI] ERR: End of road and no destination - we're at %hhu,%hhu! WTF\n",
				pPlayer->pNodeCursor->sPosTile.ubX,
				pPlayer->pNodeCursor->sPosTile.ubY
			);
			aiTransitToPlanning(pAi);
		}
	}
	else {
		const tNode *pNode = pNav->sRoute.pNodes[pNav->sRoute.bCurrNode];
		logWriteAi(
			"[AI] We're at %p: %hhu,%hhu, next route node: %p: %hhu,%hhu\n",
			pPlayer->pNodeCursor, pPlayer->pNodeCursor->sPosTile.ubX, pPlayer->pNodeCursor->sPosTile.ubY,
			pNode, pNode->sPosTile.ubX, pNode->sPosTile.ubY
		);
		if(pNode == pPlayer->pNodeCursor) {
			// We're here, skip
			--pNav->sRoute.bCurrNode;
			logWriteAi("[AI] Skipping movement\n");
		}
		else {
			for(tDirection i = 0; i < 4; ++i) {
				if(pPlayer->pNodeCursor->pNeighbors[i] == pNode) {
					--pNav->sRoute.bCurrNode;
					logWriteAi("[AI] Moving in dir %d\n", i);
					return i;
				}
			}
			logWrite("[AI] ERR: Couldn't navigate from node %p to %p\n", pPlayer->pNodeCursor, pNode);
			aiTransitToPlanning(pAi);
			// Go to source node by pushing buttons
		}
	}
	return DIRECTION_COUNT;
}

static tDirection aiProcessTargetingTarget(tAi *pAi) {
	// we've pressed fire button on source and now we'll attack weakest neighbor
	if(pAi->pTargetSrc->pNeighbors[pAi->eNeighborIdx] == pAi->pTarget) {
		// That's our neighbor
		logWriteAi("[AI] Confirming target!\n");
		pAi->eState = AI_STATE_CONFIRMING_TARGET;
		return pAi->eNeighborIdx;
	}
	if(++pAi->eNeighborIdx >= 4) {
		logWrite(
			"[AI] ERR: AI lost target node! While checking if target src %p (%hhu,%hhu) neighbors with target %p (%hhu,%hhu)\n",
			pAi->pTargetSrc, pAi->pTargetSrc->sPosTile.ubX, pAi->pTargetSrc->sPosTile.ubY,
			pAi->pTarget, pAi->pTarget->sPosTile.ubX, pAi->pTarget->sPosTile.ubY
		);
		logPushIndent();
		for(UBYTE i = 0; i < 4; ++i) {
			logWriteAi("[AI] Neighbor at dir %hhu: %p\n", i, pAi->pTargetSrc->pNeighbors[i]);
		}
		logPopIndent();
		aiTransitToPlanning(pAi);
	}
	return DIRECTION_COUNT;
}

static tDirection aiProcessConfirmingTarget(tAi *pAi) {
	// FIRE!
	pAi->isPressingFire = 0;
	aiTransitToPlanning(pAi);
	return DIRECTION_COUNT;
}

tDirection aiProcess(tAi *pAi) {
	// Check if it's turn of AI for given player
	if(++pAi->ubCnt >= 4) {
		pAi->ubCnt = 0;
	}
	if(pAi->ubCnt != pAi->ubPlayerIdx) {
		return DIRECTION_COUNT;
	}

	// It's its turn - process
	switch(pAi->eState) {
		case AI_STATE_PLANNING_AGGRESIVE:
			return aiProcessPlanningAggressive(pAi);
		case AI_STATE_PLANNING_DEFENSIVE:
			return aiProcessPlanningDefensive(pAi);
		case AI_STATE_ROUTING:
			return aiProcessRouting(pAi);
		case AI_STATE_GETTING_TO_SOURCE_BLOB:
			return aiProcessGettingToSourceBlob(pAi);
		case AI_STATE_TARGETING_TARGET:
			return aiProcessTargetingTarget(pAi);
		case AI_STATE_CONFIRMING_TARGET:
			return aiProcessConfirmingTarget(pAi);
		default:
			return DIRECTION_COUNT;
	}
}

void aiCreate(const tMap *pMap) {
	for(UBYTE i = 0; i < 4; ++i) {
		s_pAstar[i] = astarCreate();
	}
	s_pMap = pMap;
}

void aiSetNodeCount(void) {
	for(UBYTE i = 0; i < 4; ++i) {
		astarSetMaxNodes(s_pAstar[i], s_pMap->uwNodeCount);
	}
}

void aiDestroy(void) {
	for(UBYTE i = 0; i < 4; ++i) {
		astarDestroy(s_pAstar[i]);
	}
}

void aiInit(tAi *pAi, UBYTE ubPlayerIdx) {
	logWrite("AI init for player %hhu\n", ubPlayerIdx);
	pAi->ubPlayerIdx = ubPlayerIdx;
	pAi->ubCnt = 0;
	pAi->wasLastAggresive = 0;
	pAi->eState = AI_STATE_PLANNING_DEFENSIVE;
	pAi->isPressingFire = 0;
	pAi->ePrevDir = DIRECTION_COUNT;
	aiTransitToPlanning(pAi);
}
