/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "warehouse.h"
#include <ace/macros.h>
#include <ace/managers/log.h>
#include <fixmath/fix16.h>
#include "mineral.h"
#include "game.h"
#include "core.h"
#include "defs.h"
#include "comm/page_accounting.h"
#include "save.h"
#include "heat.h"

// Not spent on plan, not sold
static UWORD s_pStock[MINERAL_TYPE_COUNT] = {0};

void warehouseReset(void) {
	memset(s_pStock, 0, sizeof(s_pStock));
	planManagerInit();
}

void warehouseSave(tFile *pFile) {
	saveWriteTag(pFile, SAVE_TAG_WAREHOUSE);
	fileWrite(pFile, s_pStock, sizeof(s_pStock[0]) * MINERAL_TYPE_COUNT);
	planManagerSave(pFile);
	saveWriteTag(pFile, SAVE_TAG_WAREHOUSE_END);
}

UBYTE warehouseLoad(tFile *pFile) {
	if(!saveReadTag(pFile, SAVE_TAG_WAREHOUSE)) {
		return 0;
	}

	fileRead(pFile, s_pStock, sizeof(s_pStock[0]) * MINERAL_TYPE_COUNT);
	return planManagerLoad(pFile) &&
		saveReadTag(pFile, SAVE_TAG_WAREHOUSE_END);
}

void warehouseNextPlan(tNextPlanReason eReason) {
	gameAdvanceAccolade();
	planAdvance();

	if(eReason != NEXT_PLAN_REASON_FULFILLED_ACCOUNTING) {
		heatTryReduce(3);
	}
}

UWORD warehouseGetStock(UBYTE ubMineralType) {
	return s_pStock[ubMineralType];
}

void warehouseSetStock(UBYTE ubMineralType, UWORD uwCount) {
	s_pStock[ubMineralType] = uwCount;
}
