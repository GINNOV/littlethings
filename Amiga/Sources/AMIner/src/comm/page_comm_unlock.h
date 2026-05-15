/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _AMINER_COMM_PAGE_COMM_UNLOCK_H_
#define _AMINER_COMM_PAGE_COMM_UNLOCK_H_

#include <comm/gs_shop.h>
#include "../inventory.h"

void pageCommUnlockCreate(
	tCommUnlockState eTargetState, tCommShopPage eTargetPage,
	const char *szMsg, UWORD uwCost
);

#endif // _AMINER_COMM_PAGE_COMM_UNLOCK_H_
