/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GAME_MATH_H
#define GAME_MATH_H

#include <ace/types.h>
#include <fixmath/fix16.h>

#define GAME_MATH_ANGLE_COUNT 128
#define GAME_MATH_ATAN2_SCALE 4
#define GAME_MATH_PRECALCULATED
//#define GAME_MATH_SAVE_PRECALC

#define ANGLE_0    0
#define ANGLE_45   (GAME_MATH_ANGLE_COUNT / 8)
#define ANGLE_90   (GAME_MATH_ANGLE_COUNT / 4)
#define ANGLE_180  (GAME_MATH_ANGLE_COUNT / 2)
#define ANGLE_360  (GAME_MATH_ANGLE_COUNT)
#define ANGLE_LAST ((GAME_MATH_ANGLE_COUNT)-1)

#define csin(x) (g_pSin[x])
#define ccos(x) (((x) < 3 * ANGLE_90) ? csin(ANGLE_90 + (x)) : csin((x) - (3 * ANGLE_90)))
#define angleToFrame(angle) (angle>>1)

extern fix16_t g_pSin[GAME_MATH_ANGLE_COUNT];

/**
 *  Calculates angle between source and destination points.
 *  Source point is center of circle, destination is orbiting around it.
 *  @param uwSrcX Source point X.
 *  @param uwSrcY Ditto, Y.
 *  @param uwDstX Destination point X.
 *  @param uwDstY Ditto, Y.
 *  @return Angle value between ANGLE_0 and ANGLE_LAST
 */
UBYTE getAngleBetweenPoints(
	UWORD uwSrcX, UWORD uwSrcY, UWORD uwDstX, UWORD uwDstY
);

/**
 *  Returns direction between two angles scaled with given unit.
 *  Direction is calculated so that delta angle is less than 180deg.
 *  @param ubPrevAngle Start angle.
 *  @param ubNewAngle  Destination angle.
 *  @param wUnit Scale multiplayer of result.
 *  @return supplied unit with sign relating to shorter path from start angle
            to dest angle.
 */
WORD getDeltaAngleDirection(
	UBYTE ubPrevAngle, UBYTE ubNewAngle, WORD wUnit
);

WORD catan2(WORD wDy, WORD wDx);

void gameMathInit(void);

UWORD fastMagnitude(UWORD uwDx, UWORD uwDy);

#endif
