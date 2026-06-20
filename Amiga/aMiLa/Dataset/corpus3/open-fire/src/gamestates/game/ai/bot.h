#ifndef GUARD_OF_GAMESTATES_GAME_AI_BOT_H
#define GUARD_OF_GAMESTATES_GAME_AI_BOT_H

#include <ace/types.h>
#include "gamestates/game/player.h"
#include "gamestates/game/ai/ai.h"
#include "gamestates/game/ai/astar.h"

#define AI_BOT_DEBUG

typedef struct _tBot {
	tPlayer *pPlayer;
	tAstarData *pNavData;
	UBYTE ubState;
	UBYTE ubTick;
	// Node-related fields
	UBYTE ubNextAngle;
	UWORD uwNextX;
	UWORD uwNextY;
	// Targeting-related fields
	UBYTE ubNextTargetAngle;
} tBot;

void botManagerCreate(FUBYTE fubBotLimit);

void botManagerDestroy(void);

void botAdd(const char *szName, UBYTE ubTeam);

void botProcess(void);

void botRemoveByPtr(tBot *pBot);

void botRemoveByName(const char *szName);

#endif // GUARD_OF_GAMESTATES_GAME_AI_BOT_H
