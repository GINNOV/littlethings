#ifndef _LD40_GAMESTATES_GAME_SQUARE_H
#define _LD40_GAMESTATES_GAME_SQUARE_H

#include <ace/types.h>
#include <ace/utils/bitmap.h>
#include <fixmath/fixmath.h>

#define SQUARES_MAX 30

typedef struct _tSquare {
	struct _tSquare *pDisplayNext;
	struct _tSquare *pNext;
	struct _tSquare *pPrev;
	UBYTE ubAngle; // [0..255], CCW, 0 is right, 64 is top, etc.
	fix16_t fX;
	fix16_t fY;
	fix16_t fSpeed;
	tUwCoordYX sCoord;
	tUwCoordYX sPrevCoord;
} tSquare;

void squaresManagerCreate(void);

void squaresManagerClear(void);

void squaresManagerDestroy(void);

tSquare *squareAdd(UWORD uwX, UWORD uwY);

void squaresDraw(tBitMap *pBuffer);

void squaresUndraw(tBitMap *pBuffer);

UWORD squaresOrderForDraw(void);

void squareProcessPlayer(void);
void squareProcessAi(void);

extern tSquare *g_pSquareFirst, *g_pSquareDisplayFirst;
extern UBYTE g_ubSquareCount;

#endif // _LD40_GAMESTATES_GAME_SQUARE_H
