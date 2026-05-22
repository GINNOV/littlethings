/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef INCLUDE_ANIM_H
#define INCLUDE_ANIM_H

typedef enum tAnimDirection {
	ANIM_DIRECTION_S,
	ANIM_DIRECTION_SE,
	ANIM_DIRECTION_E,
	ANIM_DIRECTION_NE,
	ANIM_DIRECTION_N,
	ANIM_DIRECTION_NW,
	ANIM_DIRECTION_W,
	ANIM_DIRECTION_SW,
	ANIM_DIRECTION_COUNT,
} tAnimDirection;

typedef enum tAnim {
	ANIM_IDLE,
	ANIM_WALK,
	ANIM_ATTACK,
	ANIM_HURT,
	ANIM_FALLING,
	ANIM_COUNT,
} tAnim;

#endif // INCLUDE_ANIM_H
