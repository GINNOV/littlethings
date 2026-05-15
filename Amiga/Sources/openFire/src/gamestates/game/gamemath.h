#ifndef GUARD_OF_GAMESTATES_GAME_GAMEMATH_H
#define GUARD_OF_GAMESTATES_GAME_GAMEMATH_H

#include <ace/types.h>
#include <fixmath/fix16.h>

#define ANGLE_0    0
#define ANGLE_45   16
#define ANGLE_90   32
#define ANGLE_180  64
#define ANGLE_360  128
#define ANGLE_LAST 127
#define csin(x) (g_pSin[x])
#define ccos(x) ((x < 96?csin(ANGLE_90+x):csin(x-3*ANGLE_90)))
#define angleToFrame(angle) (angle>>1)

extern fix16_t g_pSin[128];

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

#endif // GUARD_OF_GAMESTATES_GAME_GAMEMATH_H
