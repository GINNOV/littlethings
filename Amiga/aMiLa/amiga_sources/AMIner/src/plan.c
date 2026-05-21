/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "plan.h"
#include <ace/macros.h>
#include <ace/managers/log.h>
#include "core.h"
#include "game.h"
#include "defs.h"
#include "save.h"

static tPlanManager s_sPlanManager;

//------------------------------------------------------------------ PRIVATE FNS

static void planReset(UBYTE isPlanActive) {
	logBlockBegin("planReset(isPlanActive: %hhu)", isPlanActive);
	for(UBYTE eMineral = 0; eMineral < MINERAL_TYPE_COUNT; ++eMineral) {
		s_sPlanManager.pMineralsSpent[eMineral] = 0;
	};

	s_sPlanManager.wTimeMax = 25 * GAME_TIME_PER_DAY;

	if(g_eGameMode == GAME_MODE_DEADLINE) {
		s_sPlanManager.wTimeRemaining = (GAME_TIME_PER_DAY * 20);
	}
	else {
		s_sPlanManager.wTimeRemaining = isPlanActive ? s_sPlanManager.wTimeMax : (GAME_TIME_PER_DAY * 5);
	}
	s_sPlanManager.isExtendedTimeByBribe = 0;
	s_sPlanManager.eProlongState = PLAN_PROLONG_NONE;
	s_sPlanManager.isPlanActive = isPlanActive;
	logBlockEnd("planReset()");
}

//------------------------------------------------------------------- PUBLIC FNS

void planManagerInit(void) {
	// First plan
	memset(&s_sPlanManager.pPlanSequence[0], 0, sizeof(s_sPlanManager.pPlanSequence[0]));
	s_sPlanManager.pPlanSequence[0].pMineralsRequired[MINERAL_TYPE_SILVER] = 3;

	// Generate plan based on allowed minerals and target money - no more than dirt tiles in segment
	s_sPlanManager.ubPlanCount = g_ubAccoladesInMainStory * g_ubPlansPerAccolade;
	if(s_sPlanManager.ubPlanCount > PLAN_COUNT_MAX) {
		logWrite(
			"ERR: Too many plans: %hhu, max %hhu\n",
			s_sPlanManager.ubPlanCount, PLAN_COUNT_MAX
		);
	}
	static tMineralType pAllowedMinerals[MINERAL_TYPE_COUNT];
	for(UBYTE ubPlanIndex = 1; ubPlanIndex < s_sPlanManager.ubPlanCount; ++ubPlanIndex) {
		tPlan *pPlan = &s_sPlanManager.pPlanSequence[ubPlanIndex];
		UWORD uwRemainingStacks = MIN(ubPlanIndex * 5, 40);
		UBYTE ubAllowedMineralsCount = planGetAllowedMineralsForIndex(ubPlanIndex, pAllowedMinerals); // bitfield
		memset(pPlan->pMineralsRequired, 0, sizeof(pPlan->pMineralsRequired));
		pPlan->uwTotalMineralsRequired = 0;
		pPlan->ulTargetSum = 0;
		while(uwRemainingStacks > 0) {
			tMineralType eMineral = pAllowedMinerals[randUwMax(&g_sRand, ubAllowedMineralsCount - 1)];
			UBYTE ubCount = randUwMinMax(&g_sRand, 1, 3);
			pPlan->pMineralsRequired[eMineral] += ubCount;
			pPlan->ulTargetSum += g_pMinerals[eMineral].ubReward * ubCount;
			pPlan->uwTotalMineralsRequired += ubCount;
			--uwRemainingStacks;
		}
		logWrite(
			"Plan %hhu, total minerals required: %hu, target sum: %lu\n",
			ubPlanIndex, pPlan->uwTotalMineralsRequired, pPlan->ulTargetSum
		);
	}

	s_sPlanManager.ubCurrentPlanIndex = 0;
	planReset(0);
}

void planManagerSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_PLAN);
	fileWrite(pFile, &s_sPlanManager, sizeof(s_sPlanManager));
	saveWriteTag(pFile, SAVE_TAG_PLAN_END);
}

UBYTE planManagerLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_PLAN)) {
		return 0;
	}

	fileRead(pFile, &s_sPlanManager, sizeof(s_sPlanManager));
	return saveReadTag(pFile, SAVE_TAG_PLAN_END);
}

const tPlanManager *planManagerGet(void) {
	return &s_sPlanManager;
}

UBYTE planGetAllowedMineralsForIndex(UBYTE ubPlanIndex, tMineralType *pAllowedMinerals) {
	UBYTE ubMineralTypeCount = 0;
	for(tMineralType eMineral = 0; eMineral < MINERAL_TYPE_COUNT; ++eMineral) {
		if(ubPlanIndex >= g_pMineralPlans[eMineral]) {
			pAllowedMinerals[ubMineralTypeCount++] = eMineral;
		}
	}
	return ubMineralTypeCount;
}

UBYTE planIsCurrentFulfilled(void) {
	const tPlan *pPlan = planGetCurrent();
	for(UBYTE i = 0; i < MINERAL_TYPE_COUNT; ++i) {
		if(s_sPlanManager.pMineralsSpent[i] < pPlan->pMineralsRequired[i]) {
			return 0;
		}
	}
	return 1;
}

void planElapseTime(UWORD uwTime) {
	if(s_sPlanManager.wTimeRemaining) {
		s_sPlanManager.wTimeRemaining = MAX(0, s_sPlanManager.wTimeRemaining - uwTime);
	}
}

void planStart(void) {
	if(s_sPlanManager.isPlanActive) {
		logWrite("ERR: Plan already started\n");
	}

	s_sPlanManager.isPlanActive = 1;
	s_sPlanManager.wTimeRemaining = s_sPlanManager.wTimeMax;
}

WORD planGetRemainingDays(void) {
	WORD wRemainingDays = (
		(s_sPlanManager.wTimeRemaining + GAME_TIME_PER_DAY - 1) /
		GAME_TIME_PER_DAY
	);
	return wRemainingDays;
}

void planAddDays(UBYTE ubDays, UBYTE isBribe) {
	if(isBribe) {
		s_sPlanManager.isExtendedTimeByBribe = 1;
	}
	s_sPlanManager.wTimeRemaining = MIN(
		s_sPlanManager.wTimeRemaining + ubDays * GAME_TIME_PER_DAY,
		200 * GAME_TIME_PER_DAY
	);
}

void planSetMinerals(UBYTE ubMineralType, UBYTE ubCount) {
	s_sPlanManager.pMineralsSpent[ubMineralType] = ubCount;
}

UBYTE planTryProlong(void) {
	if(s_sPlanManager.eProlongState == PLAN_PROLONG_NONE) {
		planAddDays(14, 0);
		s_sPlanManager.eProlongState = PLAN_PROLONG_CURRENT;
		return 1;
	}
	return 0;
}

UWORD planGetRemainingCost(void) {
	UWORD uwRemainingCost = 0;
	tPlan *pPlan = planGetCurrent();
	for(UBYTE i = MINERAL_TYPE_COUNT; i--;) {
		UWORD uwRemainingCount = MAX(0, (WORD)pPlan->pMineralsRequired[i] - s_sPlanManager.pMineralsSpent[i]);
		UBYTE ubReward = g_pMinerals[i].ubReward;

		uwRemainingCost += uwRemainingCount * ubReward;
	}
	return uwRemainingCost;
}

tPlan *planGetCurrent(void) {
	return &s_sPlanManager.pPlanSequence[s_sPlanManager.ubCurrentPlanIndex];
}

void planAdvance(void) {
	++s_sPlanManager.ubCurrentPlanIndex;
	if(s_sPlanManager.eProlongState == PLAN_PROLONG_CURRENT) {
		s_sPlanManager.eProlongState = PLAN_PROLONG_PAST;
	}
	planReset(0);
}

void planFailDeadline(void) {
	s_sPlanManager.wTimeRemaining += 14 * GAME_TIME_PER_DAY;
}
