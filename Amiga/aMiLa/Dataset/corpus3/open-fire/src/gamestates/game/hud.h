#ifndef GUARD_OF_GAMESTATES_GAME_HUD_H
#define GUARD_OF_GAMESTATES_GAME_HUD_H

#include <ace/types.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/utils/font.h>

#define HUD_STATE_SELECTING 0
#define HUD_STATE_DRIVING 1

void hudChangeState(FUBYTE fubState);

void hudCreate(tFont *pFont);
void hudDestroy(void);
void hudUpdate(void);

extern tSimpleBufferManager *g_pHudBfr;

#endif // GUARD_OF_GAMESTATES_GAME_HUD_H
