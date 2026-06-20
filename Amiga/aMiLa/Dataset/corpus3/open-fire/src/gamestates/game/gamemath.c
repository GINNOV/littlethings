#include "gamestates/game/gamemath.h"

UBYTE getAngleBetweenPoints(
	UWORD uwSrcX, UWORD uwSrcY, UWORD uwDstX, UWORD uwDstY
) {
	UWORD uwDx = uwDstX - uwSrcX;
	UWORD uwDy = uwDstY - uwSrcY;
	// calc: ubAngle = ((pi + atan2(uwDx, uwDy)) * 64)/(2*pi) * 2
	UBYTE ubAngle = (UBYTE)(ANGLE_90 + 2 * fix16_to_int(
		fix16_div(
			fix16_mul(
				fix16_add(fix16_pi, fix16_atan2(fix16_from_int(uwDx), fix16_from_int(-uwDy))),
				fix16_from_int(64)
			),
			fix16_pi*2
		)
	));
	if(ubAngle >= ANGLE_360)
		ubAngle -= ANGLE_360;
	return ubAngle;
}

WORD getDeltaAngleDirection(UBYTE ubPrevAngle, UBYTE ubNewAngle, WORD wUnit) {
	WORD wDelta = ubNewAngle - ubPrevAngle;
	if(!wDelta)
		return 0;
	if((wDelta > 0 && wDelta < ANGLE_180) || wDelta + ANGLE_360 < ANGLE_180)
		return wUnit;
	return -wUnit;
}

fix16_t g_pSin[128] = {
	0, 3215, 6423, 9616, 12785, 15923, 19024, 22078, 25079,
	28020, 30893, 33692, 36409, 39039, 41575, 44011, 46340,
	48558, 50660, 52639, 54491, 56212, 57797, 59243, 60547,
	61705, 62714, 63571, 64276, 64826, 65220, 65457, 65536,
	65457, 65220, 64826, 64276, 63571, 62714, 61705, 60547,
	59243, 57797, 56212, 54491, 52639, 50660, 48558, 46340,
	44011, 41575, 39039, 36409, 33692, 30893, 28020, 25079,
	22078, 19024, 15923, 12785, 9616, 6423, 3215, 0,
	-3215, -6423, -9616, -12785, -15923, -19024, -22078, -25079,
	-28020, -30893, -33692, -36409, -39039, -41575, -44011, -46340,
	-48558, -50660, -52639, -54491, -56212, -57797, -59243, -60547,
	-61705, -62714, -63571, -64276, -64826, -65220, -65457, -65536,
	-65457, -65220, -64826, -64276, -63571, -62714, -61705, -60547,
	-59243, -57797, -56212, -54491, -52639, -50660, -48558, -46340,
	-44011, -41575, -39039, -36409, -33692, -30893, -28020, -25079,
	-22078, -19024, -15923, -12785, -9616, -6423, -3215
};
