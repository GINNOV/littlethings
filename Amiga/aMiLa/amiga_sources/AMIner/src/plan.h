/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _PLAN_H_
#define _PLAN_H_

#include <ace/utils/file.h>
#include "mineral.h"

#define PLAN_COUNT_MAX 50

typedef struct _tPlan {
	UWORD pMineralsRequired[MINERAL_TYPE_COUNT];
	ULONG ulTargetSum;
	UWORD uwTotalMineralsRequired;
} tPlan;

typedef enum tPlanProlongState {
	PLAN_PROLONG_NONE,
	PLAN_PROLONG_CURRENT,
	PLAN_PROLONG_PAST,
} tPlanProlongState;

typedef struct tPlanManager {
	tPlan pPlanSequence[PLAN_COUNT_MAX];
	UWORD pMineralsSpent[MINERAL_TYPE_COUNT];
	WORD wTimeMax;
	WORD wTimeRemaining;
	UBYTE ubCurrentPlanIndex;
	UBYTE isExtendedTimeByBribe;
	tPlanProlongState eProlongState;
	UBYTE isPlanActive;
	UBYTE ubPlanCount;
} tPlanManager;

//------------------------------------------------------------------ MANAGER FNS

void planManagerInit(void);

void planManagerSave(tFile *pFile);

UBYTE planManagerLoad(tFile *pFile);

const tPlanManager *planManagerGet(void);

//------------------------------------------------------------------- PLAN MANIP

UBYTE planGetAllowedMineralsForIndex(UBYTE ubPlanIndex, tMineralType *pAllowedMinerals);

tPlan *planGetCurrent(void);

UBYTE planIsCurrentFulfilled(void);

void planElapseTime(UWORD uwTime);

void planStart(void);

WORD planGetRemainingDays(void);

void planAddDays(UBYTE ubDays, UBYTE isBribe);

void planSetMinerals(UBYTE ubMineralType, UBYTE ubCount);

UBYTE planTryProlong(void);

UWORD planGetRemainingCost(void);

void planAdvance(void);

void planFailDeadline(void);

#endif // _PLAN_H_
