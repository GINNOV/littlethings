/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _DEFS_H_
#define _DEFS_H_

#include <ace/types.h>
#include <fixmath/fix16.h>
#include "mineral.h"
#include "utf8_remap.h"

#define DEFS_QUEST_DINO_BONE_COUNT 9
#define DEFS_MINE_DIGGABLE_WIDTH 10
#define DEFS_QUEST_GATE_PART_COUNT 16
#define DEFS_QUEST_CRATE_COUNT 10

extern const LONG g_lInitialCash;
extern const UBYTE g_ubUpgradeLevels;
extern const UBYTE g_ubPlansPerAccolade;
extern const UBYTE g_ubAccoladesInMainStory;
extern const UBYTE g_ubDrillingCost;
extern const UBYTE g_ubLiterPrice, g_ubFuelInLiter, g_ubHullPrice;
extern const fix16_t g_fPlanIncreaseRatioSingleplayer;
extern const fix16_t g_fPlanIncreaseRatioMultiplayer;
extern const UBYTE g_ubMinePercentForPlans;
extern const UBYTE g_ubTrailingMineralCountPercent;
extern const ULONG g_ulExtraPlanMoney;

extern const UWORD g_pUpgradeCosts[4];
extern const UWORD g_pDinoDepths[DEFS_QUEST_DINO_BONE_COUNT];
extern const UWORD g_pGateDepths[DEFS_QUEST_GATE_PART_COUNT];
extern const UWORD g_pCrateDepths[DEFS_QUEST_CRATE_COUNT];
extern const UWORD g_uwCapsuleDepth;
extern const UWORD g_uwPrisonerDepth;
extern const UWORD g_pMineralPlans[MINERAL_TYPE_COUNT];

extern const char **g_pMsgs;

void defsCreateLocale(const char *szLangPrefix);

void defsDestroyLocale(void);

extern const tCodeRemap g_pRemap[19];

#endif // _DEFS_H_
