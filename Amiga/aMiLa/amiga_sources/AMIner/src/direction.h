/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_DIRECTION_H
#define INCLUDE_DIRECTION_H

#include <ace/types.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum tDirection {
	DIRECTION_UP,
	DIRECTION_DOWN,
	DIRECTION_LEFT,
	DIRECTION_RIGHT,
	DIRECTION_FIRE,
	DIRECTION_COUNT
} tDirection;

static inline UBYTE dirIsVertical(tDirection eDir) {
	return (eDir < DIRECTION_LEFT);
}

static inline tBCoordYX dirToDelta(tDirection eDir) {
	switch(eDir) {
		case DIRECTION_LEFT:
			return (tBCoordYX){.bY = 0, .bX = -1};
		case DIRECTION_RIGHT:
			return (tBCoordYX){.bY = 0, .bX = 1};
		case DIRECTION_UP:
			return (tBCoordYX){.bY = -1, .bX = 0};
		case DIRECTION_DOWN:
			return (tBCoordYX){.bY = 1, .bX = 0};
		default:
			return (tBCoordYX){.bY = 0, .bX = 0};
	}
}

static inline tDirection dirGetOpposite(tDirection eDir) {
	switch(eDir) {
		case DIRECTION_LEFT:
			return DIRECTION_RIGHT;
		case DIRECTION_RIGHT:
			return DIRECTION_LEFT;
		case DIRECTION_UP:
			return DIRECTION_DOWN;
		case DIRECTION_DOWN:
			return DIRECTION_UP;
		default:
			return DIRECTION_COUNT;
	}
}

#ifdef __cplusplus
}
#endif

#endif // INCLUDE_DIRECTION_H
