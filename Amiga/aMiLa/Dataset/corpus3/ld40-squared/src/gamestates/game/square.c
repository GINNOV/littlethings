#include "gamestates/game/square.h"
#include <ace/managers/blit.h>
#include <ace/managers/key.h>
#include <ace/managers/joy.h>
#include <ace/utils/chunky.h>
#include "maths.h"
#include "gamestates/game/game.h"
#include "gamestates/game/map.h"

typedef enum tProcessTileResult {
	PROCESS_TILE_CONTINUE = 0,
	PROCESS_TILE_EXIT = 1,
	PROCESS_TILE_DEAD = 2,
} tProcessTileResult;

UBYTE g_ubSquareCount;
tSquare *g_pSquareFirst, *g_pSquareDisplayFirst;

static tBitMap *s_pSquareBitmap, *s_pSquareBg;

static void squareBitmapGenerate(void) {
	s_pSquareBitmap = bitmapCreate(8, 8*256, 3, BMF_INTERLEAVED | BMF_CLEAR);
	tBitMap *pSource = bitmapCreate(16,16, 3, BMF_INTERLEAVED);
	tBitMap *pRotated = bitmapCreate(16,16, 3, BMF_INTERLEAVED);
	blitRect(pSource, 0, 0, 16, 16, 1);
	blitRect(pSource, 8-2, 16/2 - 3, 1, 5, 0);
	blitRect(pSource, 8-1, 16/2 - 2, 1, 3, 0);
	blitRect(pSource, 8-0, 16/2 - 1, 1, 1, 0);

	UBYTE pChunkySource[16*16], pChunkyRotated[16*16];
	for(UBYTE y = 0; y < 16; ++y) {
		chunkyFromPlanar16(pSource, 0, y, &pChunkySource[16*y]);
	}
	for(UWORD i = 0; i < 256; ++i) {
		chunkyRotate(pChunkySource, pChunkyRotated,	cSin(i), cCos(i), 0, 16, 16);
		for(UBYTE y = 0; y < 16; ++y) {
			chunkyToPlanar16(&pChunkyRotated[16*y], 0, y, pRotated);
		}
		blitCopy(pRotated, 4, 4, s_pSquareBitmap, 0, i*8, 8, 8, MINTERM_COOKIE);
	}
	bitmapDestroy(pSource);
	bitmapDestroy(pRotated);

	bitmapSave(s_pSquareBitmap, "data/square.bm");
}

static void squareBitmapLoad(void) {
	s_pSquareBitmap = bitmapCreateFromFile("data/square.bm", 0);
}

// Shameless copy from OpenFire's gamemath.h
static UBYTE getAngleBetweenPoints(
	tUwCoordYX *pSrc, tUwCoordYX *pDst
) {
	WORD wDx = pDst->uwX - pSrc->uwX;
	WORD wDy = pDst->uwY - pSrc->uwY;
	// calc: ubAngle = ((pi + atan2(uwDy, uwDx)) * 128)/pi
	static const fix16_t fPiHalf = fix16_pi >> 1;
	UBYTE ubAngle = fix16_to_int(
		fix16_div(
			fix16_mul(
				fix16_atan2(fix16_from_int(-wDy), fix16_from_int(wDx)),
				fix16_from_int(64)
			),
			fPiHalf
		)
	);
	return ubAngle;
}

static UBYTE moveAngleTowards(UBYTE ubAngleFrom, UBYTE ubAngleTo, UBYTE ubStep) {
	WORD wDeltaCcw = (WORD)ubAngleTo - ubAngleFrom;
	if(wDeltaCcw < 0) {
		wDeltaCcw += 255;
	}

	if(wDeltaCcw <= 128) {
		// Going CCW - add
		UBYTE ubNewAngle = ubAngleFrom + MIN(ubStep, wDeltaCcw);
		return ubNewAngle;
	}

	// Going CW - subtract
	UBYTE ubNewAngle = ubAngleFrom - MIN(ubStep, 255 - wDeltaCcw);
	return ubNewAngle;
}

static void squareRemove(tSquare *pSquare) {
	// Detach from list
	pSquare->pNext->pPrev = pSquare->pPrev;
	if(pSquare->pPrev) {
		pSquare->pPrev->pNext = pSquare->pNext;
	}
	else {
		g_pSquareFirst = pSquare->pNext;
	}
	// TODO remove all next squares instead?

	// Free mem
	memFree(pSquare, sizeof(tSquare));
	--g_ubSquareCount;
}

void squaresManagerCreate(void) {
	logBlockBegin("squaresManagerCreate()");
	g_ubSquareCount = 0;
	g_pSquareFirst = 0;
	g_pSquareDisplayFirst = 0;

	// squareBitmapGenerate();
	squareBitmapLoad();
	s_pSquareBg = bitmapCreate(8, 8, 3, BMF_INTERLEAVED | BMF_CLEAR);

	logBlockEnd("squaresManagerCreate()");
}

void squaresManagerClear(void) {
	while(g_pSquareFirst)
		squareRemove(g_pSquareFirst);
}

void squaresManagerDestroy(void) {
	logBlockBegin("squaresManagerDestroy()");
	squaresManagerClear();

	bitmapDestroy(s_pSquareBg);
	bitmapDestroy(s_pSquareBitmap);

	logBlockEnd("squaresManagerDestroy()");
}

tSquare *squareAdd(UWORD uwX, UWORD uwY) {
	const fix16_t fSpeedMul = fix16_div(fix16_from_int(4), fix16_from_int(5));
	// Create a square
	tSquare *pSquare = memAllocFast(sizeof(tSquare));
	pSquare->fX = fix16_from_int(uwX);
	pSquare->fY = fix16_from_int(uwY);
	pSquare->sCoord.uwX = uwX;
	pSquare->sCoord.uwY = uwY;
	pSquare->sPrevCoord.ulYX = pSquare->sCoord.ulYX;
	pSquare->pDisplayNext = 0;
	pSquare->pNext = 0;

	// Attach to list
	if(!g_pSquareFirst) {
		g_pSquareFirst = pSquare;
		pSquare->pPrev = 0;
		pSquare->fSpeed = fix16_one;
	}
	else {
		tSquare *pPrev = g_pSquareFirst;
		while(pPrev->pNext)
			pPrev = pPrev->pNext;
		pPrev->pNext = pSquare;
		pSquare->pPrev = pPrev;
		pSquare->fSpeed = fSpeedMul;
	}

	//  Set angle to target
	pSquare->ubAngle = getAngleBetweenPoints(
		&pSquare->sCoord, &pSquare->pPrev->sCoord
	);

	++g_ubSquareCount;
	return pSquare;
}

static tProcessTileResult processSquareAtTile(
	tSquare *pSquare, UWORD uwTileX, UWORD uwTileY
) {
	switch(g_pMap[uwTileX][uwTileY]) {
		case MAP_TILE_PICKUP:
			squareAdd(uwTileX << 3, uwTileY << 3);
			g_pMap[uwTileX][uwTileY] = MAP_TILE_FREE;
			break;
		case MAP_TILE_BEB:
			squareRemove(pSquare);
			return PROCESS_TILE_DEAD;
		case MAP_TILE_EXIT:
			if(pSquare == g_pSquareFirst) {
				g_isExit = 1;
				return PROCESS_TILE_EXIT;
			}

			// Other square has reached the exit - add point for it and remove from map
			g_uwScore += 1;
			squareRemove(pSquare);
			break;
	}
	return PROCESS_TILE_CONTINUE;
}

static UBYTE squareMove(tSquare *pSquare) {
	pSquare->fX = fix16_add(pSquare->fX, cCos(pSquare->ubAngle));
	pSquare->fY = fix16_sub(pSquare->fY, cSin(pSquare->ubAngle));
	pSquare->sCoord.uwX = fix16_to_int(pSquare->fX);
	pSquare->sCoord.uwY = fix16_to_int(pSquare->fY);

	const tUwCoordYX *pPos = &pSquare->sCoord;

	// Pickups & exit & death
	UWORD uwTileX = pPos->uwX >> 3;
	UWORD uwTileY = pPos->uwY >> 3;
	tProcessTileResult eResult = processSquareAtTile(pSquare, uwTileX, uwTileY);
	if(eResult == PROCESS_TILE_EXIT) {
		return 1;
	}
	else if(eResult == PROCESS_TILE_DEAD) {
		return 0;
	}

	uwTileY = (pPos->uwY+7) >> 3;
	eResult = processSquareAtTile(pSquare, uwTileX, uwTileY);
	if(eResult == PROCESS_TILE_EXIT) {
		return 1;
	}
	else if(eResult == PROCESS_TILE_DEAD) {
		return 0;
	}

	uwTileX = (pPos->uwX+7) >> 3;
	eResult = processSquareAtTile(pSquare, uwTileX, uwTileY);
	if(eResult == PROCESS_TILE_EXIT) {
		return 1;
	}
	else if(eResult == PROCESS_TILE_DEAD) {
		return 0;
	}

	uwTileY = pPos->uwY >> 3;
	eResult = processSquareAtTile(pSquare, uwTileX, uwTileY);
	if(eResult == PROCESS_TILE_EXIT) {
		return 1;
	}
	else if(eResult == PROCESS_TILE_DEAD) {
		return 0;
	}

	return 1;
}

static void setGameOver(void) {
	g_ubGameOver = 1;
	logWrite("BEB\n");
}

void squareProcessPlayer(void) {
	tSquare *pSquare = g_pSquareFirst;
	UBYTE ubDestAngle = 0xFF;

	// NOTE: This is nasty but I guess it's quickest, think of something better?
	if(keyCheck(KEY_W) || joyCheck(JOY1_UP)) {
		if(keyCheck(KEY_A) || joyCheck(JOY1_LEFT))
			ubDestAngle = 96;
		else if(keyCheck(KEY_D) || joyCheck(JOY1_RIGHT))
			ubDestAngle = 32;
		else
			ubDestAngle = 64;
	}
	else if(keyCheck(KEY_S) || joyCheck(JOY1_DOWN)) {
		if(keyCheck(KEY_A) || joyCheck(JOY1_LEFT))
			ubDestAngle = 160;
		else if(keyCheck(KEY_D) || joyCheck(JOY1_RIGHT))
			ubDestAngle = 224;
		else
			ubDestAngle = 192;
	}
	else if(keyCheck(KEY_A) || joyCheck(JOY1_LEFT))
		ubDestAngle = 128;
	else if(keyCheck(KEY_D) || joyCheck(JOY1_RIGHT))
		ubDestAngle = 0;

	if(ubDestAngle != 0xFF) {
		if(pSquare->ubAngle != ubDestAngle) {
			pSquare->ubAngle = moveAngleTowards(pSquare->ubAngle, ubDestAngle, 5);
		}
		if(!squareMove(pSquare)) {
			setGameOver();
		}
	}
}

void squareProcessAi(void) {
	if(!g_pSquareFirst)
		return;
	tSquare *pSquare = g_pSquareFirst->pNext;
	while(pSquare) {
		tSquare *pTarget = pSquare->pPrev;
		if(!pTarget)
			continue;

		// Update angle
		WORD wDx = pTarget->sCoord.uwX - pSquare->sCoord.uwX;
		WORD wDy = pTarget->sCoord.uwY - pSquare->sCoord.uwY;
		UBYTE ubDestAngle = getAngleBetweenPoints(&pSquare->sCoord, &pTarget->sCoord);
		pSquare->ubAngle = moveAngleTowards(pSquare->ubAngle, ubDestAngle, 4);

		// Current may cease to exist during movement - save 'next' for continuing
		tSquare *pNext = pSquare->pNext;

		// Move if too far
		if(ABS(wDx) > 9 || ABS(wDy) > 9) {
			UBYTE isAlive = squareMove(pSquare);
			if(!isAlive) {
				logWrite("Square destroyed\n");
				if(g_isHard) {
					setGameOver();
				}
			}
		}

		// Process next
		pSquare = pNext;
	}
}

UWORD squaresOrderForDraw(void) {
	// Clear display order
	g_pSquareDisplayFirst = 0;
	tSquare *pSquare = g_pSquareFirst;
	while(pSquare) {
		pSquare->pDisplayNext = 0;
		pSquare = pSquare->pNext;
	}

	// Create new order
	pSquare = g_pSquareFirst;
	tSquare *pLastToDraw = pSquare;
	while(pSquare) {
		// First one?
		if(!g_pSquareDisplayFirst) {
			g_pSquareDisplayFirst = pSquare;
			pSquare = pSquare->pNext;
			pLastToDraw = g_pSquareFirst;
			continue;
		}

		// Find Last or one that's lower on screen
		tSquare *pPrevSquare = 0;
		tSquare *pOtherSquare = g_pSquareDisplayFirst;
		while(pOtherSquare && pOtherSquare->sCoord.ulYX < pSquare->sCoord.ulYX) {
			pPrevSquare = pOtherSquare;
			pOtherSquare = pOtherSquare->pDisplayNext;
		}

		if(!pPrevSquare) {
			// Stopped on first search iteration, so other square
			// is definitely higher on screen. Swap and place old first as next.
			pSquare->pDisplayNext = g_pSquareDisplayFirst;
			g_pSquareDisplayFirst = pSquare;
		}
		else if(pOtherSquare) {
			// Other square is lower on screen. Attach this one above it.
			pSquare->pDisplayNext = pPrevSquare->pDisplayNext;
			pPrevSquare->pDisplayNext = pSquare;
		}
		else {
			// List has ended - all are higher on screen. Attaching on end.
			pPrevSquare->pDisplayNext = pSquare;
			pLastToDraw = pSquare;
		}

		pSquare = pSquare->pNext;
	}

	return pLastToDraw->sCoord.uwY;
}

void squaresUndraw(tBitMap *pBuffer) {
	// Direction arrow
	tSquare *pSquare = g_pSquareFirst;
	while(pSquare) {
		blitCopy(
			s_pSquareBg, 0, 0,
			pBuffer, pSquare->sPrevCoord.uwX, pSquare->sPrevCoord.uwY,
			8, 8, MINTERM_COOKIE
		);
		pSquare = pSquare->pNext;
	}
}

void squaresDraw(tBitMap *pBuffer) {
	// Draw with direction arrows
	tSquare *pSquare = g_pSquareDisplayFirst;
	while(pSquare) {
		blitCopy(
			s_pSquareBitmap, 0, pSquare->ubAngle << 3,
			pBuffer, pSquare->sCoord.uwX, pSquare->sCoord.uwY,
			8, 8, MINTERM_COOKIE
		);
		pSquare->sPrevCoord.ulYX = pSquare->sCoord.ulYX;
		pSquare = pSquare->pDisplayNext;
	}
}
