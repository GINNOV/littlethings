#ifndef GUARD_GAMESTATE_ARCADE_PAWN_H
#define GUARD_GAMESTATE_ARCADE_PAWN_H


#include "ACE:utils/bitmap.h"
#include "ACE:managers/blit.h"
#include "ACE:managers/window.h"

#include "config.h"
#include "gamestates/arcade/arcade.h"
#include "gamestates/arcade/logic.h"

/* Types */

/* Globals */
extern struct BitMap *g_pPawnsBitMap;
extern UBYTE *g_pPawnMask;

/* Functions */
void pawnCreate(void);

void pawnDestroy(void);

UBYTE pawnIsPlaceable(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN UBYTE ubLogicDataIdx
);

void pawnPlace(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN UBYTE ubLogicDataIdx,
	IN tPlayer *pPlayer
);

void pawnRemove(
	IN tPawn *pPawn
);

void pawnRedrawCallback(
	IN UWORD uwTileX,
	IN UWORD uwTileY,
	IN struct BitMap *pBmDest,
	IN UWORD uwBitMapX,
	IN UWORD uwBitMapY
);

#endif