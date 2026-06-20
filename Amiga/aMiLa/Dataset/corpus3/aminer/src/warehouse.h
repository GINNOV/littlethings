/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _WAREHOUSE_H_
#define _WAREHOUSE_H_

#include <ace/utils/file.h>
#include "plan.h"

typedef enum tNextPlanReason {
	NEXT_PLAN_REASON_FULFILLED,
	NEXT_PLAN_REASON_FULFILLED_ACCOUNTING,
} tNextPlanReason;

void warehouseReset(void);

void warehouseSave(tFile *pFile);

UBYTE warehouseLoad(tFile *pFile);

UWORD warehouseGetStock(UBYTE ubMineralType);

void warehouseSetStock(UBYTE ubMineralType, UWORD uwCount);

void warehouseNextPlan(tNextPlanReason eReason);

#endif // _WAREHOUSE_H_
