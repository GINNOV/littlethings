#ifndef GUARD_OF_GAMESTATES_GAME_TEAM_H
#define GUARD_OF_GAMESTATES_GAME_TEAM_H

#include "gamestates/game/spawn.h"

#define TEAM_COUNT 2
#define TEAM_BLUE 0
#define TEAM_RED 1
#define TEAM_NONE  2

typedef struct _tTeam {
	UWORD uwTicketsLeft; ///< In conquest mode
} tTeam;

void teamsInit(void);

extern tTeam g_pTeams[TEAM_COUNT];

#endif // GUARD_OF_GAMESTATES_GAME_TEAM_H
