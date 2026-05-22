#ifndef GUARD_OF_GAMESTATES_GAME_EXPLOSIONS_H
#define GUARD_OF_GAMESTATES_GAME_EXPLOSIONS_H

#include <ace/types.h>
#include <ace/utils/bitmap.h>
#include <ace/managers/viewport/simplebuffer.h>

#define EXPLOSIONS_MAX 8

void explosionsAdd(UWORD uwX, UWORD uwY);

void explosionsCreate(void);

void explosionsDestroy(void);

void explosionsProcess(void);

#endif // GUARD_OF_GAMESTATES_GAME_EXPLOSIONS_H
