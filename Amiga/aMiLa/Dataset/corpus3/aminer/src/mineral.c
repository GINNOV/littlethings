/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "mineral.h"

const tMineralDef g_pMinerals[MINERAL_TYPE_COUNT] = {
	[MINERAL_TYPE_SILVER] = {.ubReward = 5, .ubTitleColor = 9},
	[MINERAL_TYPE_GOLD] = {.ubReward = 10, .ubTitleColor = 16},
	[MINERAL_TYPE_EMERALD] = {.ubReward = 15, .ubTitleColor = 3},
	[MINERAL_TYPE_RUBY] = {.ubReward = 20, .ubTitleColor = 17},
	[MINERAL_TYPE_MOONSTONE] = {.ubReward = 25, .ubTitleColor = 25},
	[MINERAL_TYPE_COAL] = {.ubReward = 5, .ubTitleColor = 6},
};
