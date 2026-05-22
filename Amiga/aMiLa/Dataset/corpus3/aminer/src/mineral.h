/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef _MINERAL_H_
#define _MINERAL_H_

#include <ace/types.h>
#include "string_array.h"

typedef enum _tMineralType {
	MINERAL_TYPE_SILVER,
	MINERAL_TYPE_GOLD,
	MINERAL_TYPE_EMERALD,
	MINERAL_TYPE_RUBY,
	MINERAL_TYPE_MOONSTONE,
	MINERAL_TYPE_COAL,

	MINERAL_TYPE_COUNT
} tMineralType;

typedef struct _tMineralDef {
	UBYTE ubReward;
	UBYTE ubTitleColor;
} tMineralDef;

extern const tMineralDef g_pMinerals[MINERAL_TYPE_COUNT];

#endif // _MINERAL_H_
