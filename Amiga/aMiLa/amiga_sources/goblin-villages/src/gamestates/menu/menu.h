#ifndef GUARD_GAMESTATE_MENU_MENU_H
#define GUARD_GAMESTATE_MENU_MENU_H

#include <clib/exec_protos.h> // Amiga typedefs

#include "config.h"
#include "global.h"

#include "ACE:managers/game.h"
#include "ACE:managers/mouse.h"
#include "ACE:managers/timer.h"
#include "ACE:managers/log.h"
#include "ACE:managers/memlog.h"

#include "ACE:managers/viewport/simplebuffer.h"

#include "ACE:utils/extview.h"
#include "ACE:utils/font.h"
#include "ACE:utils/rect.h"
#include "ACE:utils/bitmap.h"
#include "ACE:utils/palette.h"

#include "gamestates/arcade/arcade.h"

/* Types */

/* Globals */

/* Functions */
void gsMenuCreate(void);

void gsMenuSplashSetup(void);

void gsMenuSplashLoop(void);

void gsMenuLobbySetup(void);

void gsMenuLobbyLoop(void);

void gsMenuDestroy(void);

void gsMenuDrawBg(void);

void gsMenuCharacterAction(
	IN UBYTE ubPlayer
);

void gsMenuPlayAction(void);

void gsMenuHowToAction(void);

#endif