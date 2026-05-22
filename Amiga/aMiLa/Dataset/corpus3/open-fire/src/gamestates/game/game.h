#ifndef GUARD_OF_GAMESTATES_GAME_GAME_H
#define GUARD_OF_GAMESTATES_GAME_GAME_H

#include <ace/managers/viewport/simplebuffer.h>
#include <gamestates/game/bob_new.h>

#define WORLD_BPP 4

// Copperlist offsets
// Simple buffer for simplebuffer main: 6+4*2 = 14, hud: same
// Copperlist for turrets: 6*5*16 per turret row, max turret lines: 4
// 1920 for turrets, 2 for init, 2 for cleanup, total 1924 cmds
// Wait+MOVE for bitplane DMA off & on between vports, so +4 cmds
#define WORLD_COP_SPRITEEN_POS     0
#define WORLD_COP_CROSS_POS        (WORLD_COP_SPRITEEN_POS+1+7*2)
#define WORLD_COP_VPMAIN_POS       (WORLD_COP_CROSS_POS + 2)
#define WORLD_COP_VPHUD_DMAOFF_POS (WORLD_COP_VPMAIN_POS+14)
#define WORLD_COP_VPHUD_POS        (WORLD_COP_VPHUD_DMAOFF_POS+3)
#define WORLD_COP_VPHUD_DMAON_POS  (WORLD_COP_VPHUD_POS+14)
#define WORLD_COP_SIZE             (WORLD_COP_VPHUD_DMAON_POS+1)

/**
 * Viewport dimensions.
 * WORLD_VPORT_* refer to main world's VPort size.
 * WORLD_VPORT_BEGIN_* refer to actual PAL pixels with overscan taken
 * into account.
 */
#define WORLD_VPORT_WIDTH     320
#define WORLD_VPORT_HEIGHT    (256-64)
#define WORLD_VPORT_BEGIN_X 126
#define WORLD_VPORT_BEGIN_Y 0x2C

extern tView *g_pWorldView;
extern tSimpleBufferManager *g_pWorldMainBfr;

extern tCameraManager *g_pWorldCamera;

extern ULONG g_ulGameFrame;
extern UBYTE g_isLocalBot;

void gsGameCreate(void);
void gsGameLoop(void);
void gsGameDestroy(void);

void displayPrepareLimbo(void);
void displayPrepareDriving(void);

#endif
