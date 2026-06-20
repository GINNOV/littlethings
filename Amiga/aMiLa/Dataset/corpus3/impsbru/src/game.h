#ifndef GUARD_IMPSBRU_GAME_H
#define GUARD_IMPSBRU_GAME_H

#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/state.h>

#include <ace/utils/extview.h>

#define GAME_STATE_MENU 0
#define GAME_STATE_EDITOR 1
#define GAME_STATE_COUNT 2

extern const UWORD WINDOW_SCREEN_WIDTH;
extern const UWORD WINDOW_SCREEN_HEIGHT;
extern const UWORD WINDOW_SCREEN_BPP;

extern tView *g_pView;
extern tVPort *g_pVPort;
extern tSimpleBufferManager *g_pBufferManager;
extern tStateManager *g_pGameStateManager;
extern tState *g_pGameStates[];

void createGameStates();
void destroyGameStates();

void swapBuffers();
void copyBuffer();
void clearBuffer();

#endif
