#ifndef _LD40_GAMESTATES_MENU_MENU_H
#define _LD40_GAMESTATES_MENU_MENU_H

#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/state.h>

void menuDraw(void);

extern tSimpleBufferManager *g_pMenuBfrMgr;
extern tState g_sStateMenu;

#endif // _LD40_GAMESTATES_MENU_MENU_H
