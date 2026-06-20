#ifndef _LD40_GAMESTATES_GAME_GAME_H
#define _LD40_GAMESTATES_GAME_GAME_H

#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/state.h>

#define GAME_MAIN_VPORT_HEIGHT 224

void hudUpdate(void);

extern tState g_sStateGame;

extern UBYTE g_ubGameOver;
extern UBYTE g_ubStartX, g_ubStartY;
extern UBYTE g_isExit, g_isHard;
extern UWORD g_uwScore, g_uwHiScore, g_uwLoScore;

#endif // _LD40_GAMESTATES_GAME_GAME_H
