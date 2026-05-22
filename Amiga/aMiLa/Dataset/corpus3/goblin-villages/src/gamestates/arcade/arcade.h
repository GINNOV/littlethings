#ifndef GUARD_GAMESTATE_ARCADE_ARCADE_H
#define GUARD_GAMESTATE_ARCADE_ARCADE_H

#include <clib/exec_protos.h> // Amiga typedefs
#include <hardware/custom.h> // Custom chip registry addresses
#include <graphics/gfxmacros.h> // CWAIT etc

#include "config.h"

#include "ACE:utils/extview.h"
#include "ACE:managers/game.h"
#include "ACE:managers/mouse.h"
#include "ACE:managers/timer.h"
#include "ACE:managers/log.h"
#include "ACE:managers/memlog.h"

#include "ACE:managers/viewport/tilebuffer.h"
#include "ACE:managers/viewport/simplebuffer.h"

#include "ACE:utils/font.h"
#include "ACE:utils/rect.h"
#include "ACE:utils/bitmap.h"
#include "ACE:utils/palette.h"

#include "gamestates/menu/menu.h"
#include "gamestates/arcade/tile.h"
#include "gamestates/arcade/hud.h"
#include "gamestates/arcade/logic.h"
#include "gamestates/arcade/pawn.h"
#include "gamestates/arcade/player.h"

/* Types */
#define TILEMAP_WIDTH 100
#define TILEMAP_HEIGHT 100

#define TURN_TILE 0
#define TURN_PAWN 1

/* Globals */
extern tExtView *g_pExtView;
extern tPlayer *g_pCurrPlayer;
extern tCoord g_sLastTileCoord;
extern UBYTE g_ubPointerIdx;
extern UBYTE g_ubTurnStep;
extern tTileBufferManager *g_pTileBuffer; // z niego korzysta te¿ hud.c, tile.c

/* Functions */
void gsArcadeCreate(void);

void gsArcadeLoopSetup(void);

void gsArcadeLoop(void);

void gsArcadeResultsLoop(void);

void gsArcadeDestroy(void);

#endif