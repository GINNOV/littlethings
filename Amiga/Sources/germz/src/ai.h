/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_AI_H
#define GERMZ_AI_H

#include <ace/types.h>
#include "direction.h"
#include "map.h"

typedef enum tAiState {
	AI_STATE_PLANNING_AGGRESIVE,
	AI_STATE_PLANNING_DEFENSIVE,
	AI_STATE_ROUTING,
	AI_STATE_GETTING_TO_SOURCE_BLOB,
	AI_STATE_TARGETING_TARGET,
	AI_STATE_CONFIRMING_TARGET,
} tAiState;

typedef struct tAi {
	UBYTE ubPlayerIdx;
	UWORD uwCurrNode;
	UBYTE wasLastAggresive;
	UBYTE isAstarStarted;
	//
	WORD wBiggestDelta;
	const struct tNode *pTargetSrc, *pTarget;
	//
	WORD wBiggestDeltaCurrNode;
	const struct tNode *pTargetCurrNode;
	tAiState eState;
	tDirection eNeighborIdx;
	UBYTE ubCnt;
	UBYTE isPressingFire;
	tDirection ePrevDir;
} tAi;

void aiCreate(const tMap *pMap);

void aiDestroy(void);

void aiSetNodeCount(void);

void aiInit(tAi *pAi, UBYTE ubPlayerIdx);

tDirection aiProcess(tAi *pAi);

#endif // GERMZ_AI_H
