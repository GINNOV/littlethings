#include "gamestates/game/team.h"
#include <ace/managers/log.h>

void teamsInit(void) {
	g_pTeams[TEAM_BLUE].uwTicketsLeft = 50;
	g_pTeams[TEAM_RED].uwTicketsLeft = 50;
}

tTeam g_pTeams[TEAM_COUNT];
