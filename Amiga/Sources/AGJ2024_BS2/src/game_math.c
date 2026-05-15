/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "main.h"
#include "game_math.h"
#include <ace/generic/screen.h>
#include <ace/managers/system.h>
#include <ace/utils/file.h>

static WORD s_pAtan2[SCREEN_PAL_HEIGHT / GAME_MATH_ATAN2_SCALE][SCREEN_PAL_WIDTH / GAME_MATH_ATAN2_SCALE];

UBYTE getAngleBetweenPoints(
	UWORD uwSrcX, UWORD uwSrcY, UWORD uwDstX, UWORD uwDstY
) {
	WORD wDx = uwDstX - uwSrcX;
	WORD wDy = uwDstY - uwSrcY;
	UBYTE ubAngle = catan2(wDy, wDx);
	if(ubAngle >= ANGLE_360) {
		ubAngle -= ANGLE_360;
	}
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

WORD catan2(WORD wDy, WORD wDx) {
	return
		wDx >= 0 && wDy >= 0 ? s_pAtan2[wDy / GAME_MATH_ATAN2_SCALE][wDx / GAME_MATH_ATAN2_SCALE] :
		wDx >= 0 && wDy < 0 ? (ANGLE_360 - s_pAtan2[((UWORD)-wDy) / GAME_MATH_ATAN2_SCALE][wDx / GAME_MATH_ATAN2_SCALE]) :
		wDx < 0 && wDy >= 0 ? (ANGLE_180 - s_pAtan2[wDy / GAME_MATH_ATAN2_SCALE][((UWORD)-wDx) / GAME_MATH_ATAN2_SCALE]) :
		/* wDx < 0 && wDy < 0 ? */ (ANGLE_180 + s_pAtan2[((UWORD)-wDy) / GAME_MATH_ATAN2_SCALE][((UWORD)-wDx) / GAME_MATH_ATAN2_SCALE]);
}

UWORD fastMagnitude(UWORD uwDx, UWORD uwDy) {
	// Get approximate distance |(xo,yo)| using aMin+bMax with a=15/16 and b=15/32
	// Average error is around 1.8%
	// |(dx,dy)| ~= (P+0.5Q) - ((P+0.5Q) >> 4)
	// P = max(|dx|,|dy|)
	// Q = min(|dx|,|dy|)
	UWORD uwP, uwQ;
	if(uwDx > uwDy) {
		uwP = uwDx;
		uwQ = uwDy;
	}
	else {
		uwP = uwDy;
		uwQ = uwDx;
	}
	UWORD uwHalfQ = uwQ / 2;
	UWORD uwPPlusHalfQ = uwP + uwHalfQ;
	return uwPPlusHalfQ - (uwPPlusHalfQ >> 4);
}

void gameMathInit(void) {
#if defined(GAME_MATH_PRECALCULATED)
	systemUse();
	tFile *pFile = pakFileGetFile(g_pPakFile, "math.dat");
	fileRead(pFile, s_pAtan2, sizeof(s_pAtan2));
	fileRead(pFile, g_pSin, sizeof(g_pSin));
	fileClose(pFile);
	systemUnuse();
#else
	for(UWORD uwY = 0; uwY < SCREEN_PAL_HEIGHT / GAME_MATH_ATAN2_SCALE; ++uwY) {
		for(UWORD uwX = 0; uwX < SCREEN_PAL_WIDTH / GAME_MATH_ATAN2_SCALE; ++uwX) {
			s_pAtan2[uwY][uwX] = fix16_to_int(fix16_one/2 + fix16_div(ANGLE_180 * fix16_atan2(fix16_from_int(uwY), fix16_from_int(uwX)), fix16_pi));
			if(s_pAtan2[uwY][uwX] >= ANGLE_360) {
				s_pAtan2[uwY][uwX] -= ANGLE_360;
			}
		}
	}
	s_pAtan2[0][0] = ANGLE_0;

	for(UWORD uwAngle = 0; uwAngle < GAME_MATH_ANGLE_COUNT; ++uwAngle) {
		g_pSin[uwAngle] = fix16_sin((uwAngle * 2 * fix16_pi) / GAME_MATH_ANGLE_COUNT);
	}

#if defined(GAME_MATH_SAVE_PRECALC)
	//systemUse();
	tFile *pFile = fileOpen("game_math.dat", "wb");
	fileWrite(pFile, s_pAtan2, sizeof(s_pAtan2));
	fileWrite(pFile, g_pSin, sizeof(g_pSin));
	//systemUnuse();
#endif
#endif
}

fix16_t g_pSin[GAME_MATH_ANGLE_COUNT];
