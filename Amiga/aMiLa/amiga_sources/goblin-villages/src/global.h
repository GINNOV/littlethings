#ifndef GUARD_GLOBAL_H
#define GUARD_GLOBAL_H

#include "config.h"
#include "ACE:utils/font.h"
#include "ACE:utils/coord.h"
#include "ACE:managers/mouse.h"

#define POINTER_NW 0
#define POINTER_N  1
#define POINTER_NE 2
#define POINTER_E  3
#define POINTER_SE 4
#define POINTER_S  5
#define POINTER_SW 6
#define POINTER_W  7
#define PLAYER_COUNT 8

typedef struct _tPlayer {
	UBYTE ubIdx;
	UWORD uwScore;
	UBYTE ubPawnsLeft;
	struct _tPlayer *pPrev;
	struct _tPlayer *pNext;
} tPlayer;

typedef struct _tPawn {
	tCoord sTileCoord;
	UBYTE ubLogicDataIdx;
	tPlayer *pPlayer;
	struct _tPawn *pPrev;
	struct _tPawn *pNext;
} tPawn;

typedef struct {
	UBYTE pPlayersSelected[PLAYER_COUNT];
	UBYTE ubPlayerCount;
	tPlayer *pPlayerFirst;
	UBYTE ubPawnsPerPlayer;
	UBYTE ubPawnCount;
	tPawn *pPawnFirst;
} tGameConfig;

extern tFont *g_pFont;
extern struct BitMap *g_pCharactersBitMap;

extern __chip UWORD g_pCursorData[288];
extern __chip UWORD g_pPawnCursorData[36];
extern WORD g_pPointerSpots[8][2];
extern BYTE g_pPointerDirs[3][3];

extern tGameConfig g_sGameConfig;
extern UBYTE g_pPlayerColors[PLAYER_COUNT][2];

void globalCreate(void);
void globalDestroy(void);

#endif