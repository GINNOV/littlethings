#ifndef GUARD_GAMESTATE_ARCADE_HUD_H
#define GUARD_GAMESTATE_ARCADE_HUD_H

#include "ACE:utils/extview.h"
#include "ACE:utils/rect.h"
#include "ACE:utils/font.h"

#include "config.h"
#include "gamestates/arcade/arcade.h"
#include "gamestates/arcade/tile.h"

/* Types */

typedef struct {
	// redraw-specific
	UBYTE ubBgDrawn;
	UBYTE ubTileErased;
	// common with tPlayer
	UBYTE ubPrevPawns;
	WORD wPrevScore;
} tHudPlayerCache;

typedef struct {
	UBYTE ubExpanded;
	struct BitMap *pRectBfr;
	tExtView *pExtView;
	tExtVPort *pMainVPort;
	tExtVPort *pHudVPort;
	tHudPlayerCache *pPlayerCache;
} tHudManager;

/* Globals */
extern tHudManager g_sHudManager;

/* Functions */
void hudCreate(
	IN tExtView *pExtView
);

void hudDestroy(void);

void hudRedrawAll(void);

void hudRedrawPlayer(
	IN tPlayer *pPlayer
);

void hudDrawLargePawn(
	IN tPlayer *pPlayer
);

void hudShowPlayer(
	IN tPlayer *pPlayer
);

void hudExpand(void);

void hudMinimize(void);

void hudShow(void);

void hudHide(void);

void hudSummary(void);

#endif