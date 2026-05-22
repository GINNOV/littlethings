#ifndef GUARD_GAMESTATE_ARCADE_SCREEN_H
#define GUARD_GAMESTATE_ARCADE_SCREEN_H

#include <hardware/custom.h> // Custom chip register addresses


#include "ACE:managers/window.h"
#include "ACE:managers/tilemap.h"

#include "config.h"
#include "gamestates/arcade/arcade.h"

/* Types */

/* Globals */
__far extern struct Custom custom;
extern struct UCopList *g_pCopArcadeList;

/* Functions */
tExtView *villagesExtViewCreate(void);
void screenScroll(
	IN tExtView *pExtView,
	IN UBYTE ubForce
);

#endif