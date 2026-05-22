#ifndef GUARD_OF_GAMESTATES_GAME_SCORETABLE_H
#define GUARD_OF_GAMESTATES_GAME_SCORETABLE_H

#include <ace/types.h>
#include <ace/utils/extview.h>
#include <ace/utils/font.h>

void scoreTableCreate(tVPort *pHudVPort, tFont *pFont);

void scoreTableDestroy(void);

void scoreTableUpdate(void);

void scoreTableShow(void);

void scoreTableProcessView(void);

void scoreTableShowSummary(void);

#endif // GUARD_OF_GAMESTATES_GAME_SCORETABLE_H
