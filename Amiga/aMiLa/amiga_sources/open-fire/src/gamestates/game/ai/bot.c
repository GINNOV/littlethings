#include "gamestates/game/ai/bot.h"
#include <fixmath/fix16.h>
#include "gamestates/game/spawn.h"
#include "gamestates/game/ai/astar.h"

#define AI_BOT_STATE_IDLE           0
#define AI_BOT_STATE_MOVING_TO_NODE 1
#define AI_BOT_STATE_NODE_REACHED   2
#define AI_BOT_STATE_HOLDING_POS    3
#define AI_BOT_STATE_BLOCKED        4

static tBot *s_pBots;
static FUBYTE s_fubBotCount;
static FUBYTE s_fubBotLimit;

#define BOT_TARGETING_SIZE 5
#define BOT_TARGETING_FLAT_SIZE 15

// 0 - don't check, 1 is highest priority
// TODO: this pattern could be bot-specific and be used in genethic algo
// to hone bot skills
// Only 90deg rotations are nice, so there's need to be 0deg and 45deg sources
static UBYTE s_ubTargetingOrderE[BOT_TARGETING_SIZE][BOT_TARGETING_SIZE] = {
	{ 0,  0, 14,  9, 10},
	{ 0,  0, 12,  3,  6},
	{ 0,  0,  1,  2,  5},
	{ 0,  0, 13,  4,  7},
	{ 0,  0, 15,  8, 11}
};
static UBYTE s_ubTargetingOrderSE[BOT_TARGETING_SIZE][BOT_TARGETING_SIZE] = {
	{ 0,  0,  0,  0, 14}, // TODO proper
	{ 0,  0,  0, 12, 10},
	{ 0,  0,  1,  3,  8},
	{ 0, 13,  4,  2,  6},
	{15, 11,  9,  7,  5}
};

// Octants: E, SE, S, SW, W, NW, N, NE
static tBCoordYX s_pTargetingOrders[8][BOT_TARGETING_FLAT_SIZE] = {{{0}}};

static void botTargetingOrderFlatten() {
	const BYTE pZin[4] = {0, 1, 0, -1};
	const BYTE pCoz[4] = {1, 0, -1, 0};
	for(UBYTE y = 0; y < BOT_TARGETING_SIZE; ++y) {
		for (UBYTE x = 0; x < BOT_TARGETING_SIZE; ++x) {
			if(s_ubTargetingOrderE[y][x]) {
				UBYTE ubFoundOrderOdd = s_ubTargetingOrderE[y][x]-1;
				for(UBYTE i = 0; i < 4; ++i) {
					s_pTargetingOrders[i<<1][ubFoundOrderOdd].bX = pCoz[i]*(x-2) - pZin[i]*(y-2);
					s_pTargetingOrders[i<<1][ubFoundOrderOdd].bY = pZin[i]*(x-2) + pCoz[i]*(y-2);
				}
			}
			if(s_ubTargetingOrderSE[y][x]) {
				UBYTE ubFoundOrderEven = s_ubTargetingOrderSE[y][x]-1;
				for(UBYTE i = 0; i < 4; ++i) {
					s_pTargetingOrders[(i<<1)+1][ubFoundOrderEven].bX = pCoz[i]*(x-2) - pZin[i]*(y-2);
					s_pTargetingOrders[(i<<1)+1][ubFoundOrderEven].bY = pZin[i]*(x-2) + pCoz[i]*(y-2);
				}
			}
		}
	}
}

static void botSay(tBot *pBot, char *szFmt, ...) {
#ifdef AI_BOT_DEBUG
	char szBfr[100];
	va_list vArgs;
	va_start(vArgs, szFmt);
	vsprintf(szBfr, szFmt, vArgs);
	playerSay(pBot->pPlayer, szBfr, 0);
	va_end(vArgs);
#endif // #ifdef AI_BOT_DEBUG
}

void botManagerCreate(FUBYTE fubBotLimit) {
	logBlockBegin("botManagerCreate(fubBotLimit: %"PRI_FUBYTE")", fubBotLimit);
	s_fubBotCount = 0;
	s_pBots = memAllocFastClear(sizeof(tBot) * fubBotLimit);
	s_fubBotLimit = fubBotLimit;
	botTargetingOrderFlatten();
	logBlockEnd("botManagerCreate()");
}

void botManagerDestroy(void) {
	logBlockBegin("botManagerDestroy()");
	for(UBYTE i = s_fubBotCount; i--;) {
		astarDestroy(s_pBots[i].pNavData);
	}
	memFree(s_pBots, sizeof(tBot) * s_fubBotLimit);
	logBlockEnd("botManagerDestroy()");
}

void botAdd(const char *szName, UBYTE ubTeam) {
	tBot *pBot = &s_pBots[s_fubBotCount];
	pBot->pPlayer = playerAdd(szName, ubTeam);
	if(!pBot->pPlayer) {
		logWrite("ERR: No more room for bots\n");
		return;
	}
	pBot->pPlayer->isBot = 1;
	pBot->ubState = AI_BOT_STATE_IDLE;
	pBot->ubTick = 0;
	pBot->uwNextX = 0;
	pBot->uwNextY = 0;
	pBot->ubNextAngle = 0;
	++s_fubBotCount;
	pBot->pNavData = astarCreate();
	pBot->pNavData->sRoute.ubCurrNode = 0;

	botSay(pBot, "Ich bin ein computer");
}

void botRemoveByPtr(tBot *pBot) {
	astarDestroy(pBot->pNavData);
}

void botRemoveByName(const char *szName) {
	for(UBYTE i = 0; i < s_fubBotCount; ++i) {
		if(!strcmp(s_pBots[i].pPlayer->szName, szName)) {
			botRemoveByPtr(&s_pBots[i]);
			return;
		}
	}
}

/**
 * Finds next destination for AI's vehicle and sets up pathfinding data.
 * @param pBot  Pointer to bot.
 * @param pDestToEvade Node which shouldn't be used as next destination.
 * @return Pointer to first node on new route.
 */
static tAiNode *botFindNewTarget(tBot *pBot, tAiNode *pDestToEvade) {
	// Find capture point which is neutral or needs defending or being
	// attacked or nearest to attack
	// TODO remaining variants, prioritize
	for(FUBYTE i = 0; i != g_fubCaptureNodeCount; ++i) {
		if(
			g_pCaptureNodes[i] != pDestToEvade &&
			g_pCaptureNodes[i]->pControlPoint->fubTeam != pBot->pPlayer->ubTeam
		) {
			tAiNode *pRouteEnd = g_pCaptureNodes[i];
			botSay(
				pBot, "New target at %"PRI_FUBYTE",%"PRI_FUBYTE,
				pRouteEnd->fubX, pRouteEnd->fubY
			);
			tAiNode *pRouteStart = aiFindClosestNode(
				pBot->pPlayer->sVehicle.uwX >> MAP_TILE_SIZE,
				pBot->pPlayer->sVehicle.uwY >> MAP_TILE_SIZE
			);
			astarStart(pBot->pNavData, pRouteStart, pRouteEnd);
			return pRouteStart;
		}
	}

	// Found nothing else - try one to be evaded
	if(pDestToEvade->pControlPoint->fubTeam != pBot->pPlayer->ubTeam) {
		tAiNode *pRouteEnd = pDestToEvade;
		botSay(
			pBot, "New target at %"PRI_FUBYTE",%"PRI_FUBYTE,
			pRouteEnd->fubX, pRouteEnd->fubY
		);
		tAiNode *pRouteStart = aiFindClosestNode(
			pBot->pPlayer->sVehicle.uwX >> MAP_TILE_SIZE,
			pBot->pPlayer->sVehicle.uwY >> MAP_TILE_SIZE
		);
		astarStart(pBot->pNavData, pRouteStart, pRouteEnd);
		return pRouteStart;
	}
	return 0;
}

static tTurret *botTargetNearbyTurret(tBot *pBot, UBYTE ubEnemyTeam) {
	UWORD uwBotTileX = pBot->pPlayer->sVehicle.uwX >> MAP_TILE_SIZE;
	UWORD uwBotTileY = pBot->pPlayer->sVehicle.uwY >> MAP_TILE_SIZE;
	UBYTE ubOctant = ((pBot->pPlayer->sVehicle.ubTurretAngle+8) & ANGLE_LAST) >> 4;

	tBCoordYX *pTargetingOrder = s_pTargetingOrders[ubOctant];
	for(UBYTE i = 0; i != BOT_TARGETING_FLAT_SIZE; ++i) {
		UWORD uwTurretX = (UWORD)(uwBotTileX + pTargetingOrder[i].bX);
		UWORD uwTurretY = (UWORD)(uwBotTileY + pTargetingOrder[i].bY);
		if(g_pTurretTiles[uwTurretX][uwTurretY] == TURRET_INVALID)
			continue;
		tTurret *pTurret = &g_pTurrets[g_pTurretTiles[uwTurretX][uwTurretY]];
		if(pTurret->ubTeam != ubEnemyTeam)
			continue;
		return pTurret;
	}

	return 0;
}

static UBYTE botTarget(tBot *pBot) {
	UBYTE ubEnemyTeam = pBot->pPlayer->ubTeam == TEAM_BLUE ? TEAM_RED : TEAM_BLUE;

	// Should be checked quite often since player/turrent may fall out of range
	// Also needs destination angle updates
	// TODO: Don't target stuff through walls?

	// Player, turret or wall
	tPlayer *pTargetPlayer = playerGetClosestInRange(
		pBot->pPlayer->sVehicle.uwX, pBot->pPlayer->sVehicle.uwY,
		PROJECTILE_RANGE, ubEnemyTeam
	);
	if(pTargetPlayer) {
		// botSay(pBot, "Player target");
		pBot->pPlayer->sSteerRequest.ubDestAngle = getAngleBetweenPoints(
			pBot->pPlayer->sVehicle.uwX, pBot->pPlayer->sVehicle.uwY,
			pTargetPlayer->sVehicle.uwX, pTargetPlayer->sVehicle.uwY
		);
		return 1;
	}

	tTurret *pTurret = botTargetNearbyTurret(pBot, ubEnemyTeam);
	if(pTurret) {
		pBot->pPlayer->sSteerRequest.ubDestAngle = getAngleBetweenPoints(
			pBot->pPlayer->sVehicle.uwX, pBot->pPlayer->sVehicle.uwY,
			pTurret->uwCenterX, pTurret->uwCenterY
		);
		return 1;
	}

	pBot->pPlayer->sSteerRequest.ubDestAngle = pBot->pPlayer->sVehicle.ubBodyAngle;
	return 0;
}

static void botProcessDriving(tBot *pBot) {
	switch(pBot->ubState) {
		case AI_BOT_STATE_IDLE:
			if(pBot->pNavData->ubState == ASTAR_STATE_OFF) {
				botFindNewTarget(pBot, pBot->pNavData->sRoute.pNodes[0]);
			}
			else {
				if(!astarProcess(pBot->pNavData))
					break;
				tAiNode *pNextNode = pBot->pNavData->sRoute.pNodes[pBot->pNavData->sRoute.ubCurrNode];
				pBot->uwNextX = (UWORD)((pNextNode->fubX << MAP_TILE_SIZE) + MAP_HALF_TILE);
				pBot->uwNextY = (UWORD)((pNextNode->fubY << MAP_TILE_SIZE) + MAP_HALF_TILE);
				botSay(pBot, "Going to %hu,%hu", pNextNode->fubX, pNextNode->fubY);
				pBot->ubTick = 10;
				pBot->ubState = AI_BOT_STATE_MOVING_TO_NODE;
			}
			break;
		case AI_BOT_STATE_MOVING_TO_NODE: {
			// Update target angle
			if(pBot->ubTick == 10) {
				pBot->ubTick = 0;
				pBot->ubNextAngle = getAngleBetweenPoints(
					pBot->pPlayer->sVehicle.uwX, pBot->pPlayer->sVehicle.uwY,
					pBot->uwNextX, pBot->uwNextY
				);
			}
			else
				++pBot->ubTick;
			// Check if in destination
			if(
				ABS(pBot->uwNextX - pBot->pPlayer->sVehicle.uwX) < (MAP_HALF_TILE/2) &&
				ABS(pBot->uwNextY - pBot->pPlayer->sVehicle.uwY) < (MAP_HALF_TILE/2)
			) {
				pBot->pPlayer->sSteerRequest.ubForward = 0;
				pBot->pPlayer->sSteerRequest.ubBackward = 0;
				pBot->pPlayer->sSteerRequest.ubLeft = 0;
				pBot->pPlayer->sSteerRequest.ubRight = 0;
				pBot->ubState = AI_BOT_STATE_NODE_REACHED;
				break;
			}

			// Steer to proper angle
			BYTE bDir = (BYTE)getDeltaAngleDirection(
				pBot->pPlayer->sVehicle.ubBodyAngle, pBot->ubNextAngle, 1
			);
			if(bDir) {
				if(bDir > 0) {
					pBot->pPlayer->sSteerRequest.ubLeft = 0;
					pBot->pPlayer->sSteerRequest.ubRight = 1;
				}
				else if(bDir < 0) {
					pBot->pPlayer->sSteerRequest.ubLeft = 1;
					pBot->pPlayer->sSteerRequest.ubRight = 0;
				}
				break;
			}

			// Check field in front for collisions
			pBot->pPlayer->sSteerRequest.ubLeft = 0;
			pBot->pPlayer->sSteerRequest.ubRight = 0;
			UWORD uwChkX = (UWORD)(pBot->pPlayer->sVehicle.uwX + fix16_to_int(
				MAP_FULL_TILE * ccos(pBot->pPlayer->sVehicle.ubBodyAngle)
			));
			UWORD uwChkY = (UWORD)(pBot->pPlayer->sVehicle.uwY + fix16_to_int(
				MAP_FULL_TILE * csin(pBot->pPlayer->sVehicle.ubBodyAngle)
			));
			if(playerAnyNearPoint(uwChkX, uwChkY, MAP_HALF_TILE)) {
				pBot->ubState = AI_BOT_STATE_BLOCKED;
				pBot->ubTick = 0;
				pBot->pPlayer->sSteerRequest.ubForward = 0;
				break;
			}

			// Move until close to node
			pBot->pPlayer->sSteerRequest.ubForward = 1;
		} break;
		case AI_BOT_STATE_NODE_REACHED:
			if(!pBot->pNavData->sRoute.ubCurrNode) {
				// Last node from route - hold pos
				pBot->ubTick = 0;
				pBot->ubState = AI_BOT_STATE_HOLDING_POS;
				botSay(pBot, "Destination reached - holding pos");
			}
			else {
				// Get next node from route
				--pBot->pNavData->sRoute.ubCurrNode;
				tAiNode *pNextNode = pBot->pNavData->sRoute.pNodes[pBot->pNavData->sRoute.ubCurrNode];
				pBot->uwNextX = (UWORD)((pNextNode->fubX << MAP_TILE_SIZE) + MAP_HALF_TILE);
				pBot->uwNextY = (UWORD)((pNextNode->fubY << MAP_TILE_SIZE) + MAP_HALF_TILE);
				pBot->ubTick = 10;
				pBot->ubState = AI_BOT_STATE_MOVING_TO_NODE;
				botSay(
					pBot, "Moving to next pos: %hu, %hu",
					pNextNode->fubX, pNextNode->fubY
				);
			}
			break;
		case AI_BOT_STATE_HOLDING_POS:
			// Move to tile next to it to prevent blocking other players/bots
			// If point has been captured start measuring ticks
			if(pBot->ubTick >= 200) {
				tAiNode *pLastNode = pBot->pNavData->sRoute.pNodes[0];
				// After some ticks check if work is done on this point
				if(pLastNode->pControlPoint->fubTeam == pBot->pPlayer->ubTeam) {
					// If so, go to next point
					botFindNewTarget(pBot, 0);
					pBot->ubState = AI_BOT_STATE_IDLE;
				}
				else
					botSay(pBot, "capturing...");
				pBot->ubTick = 0;
			}
			else
				++pBot->ubTick;
			break;
		case AI_BOT_STATE_BLOCKED: {
			UWORD uwChkX = (UWORD)(pBot->pPlayer->sVehicle.uwX + fix16_to_int(
				(3*MAP_FULL_TILE)/2 * ccos(pBot->pPlayer->sVehicle.ubBodyAngle)
			));
			UWORD uwChkY = (UWORD)(pBot->pPlayer->sVehicle.uwY + fix16_to_int(
				(3*MAP_FULL_TILE)/2 * csin(pBot->pPlayer->sVehicle.ubBodyAngle)
			));
			if(playerAnyNearPoint(uwChkX, uwChkY, MAP_FULL_TILE)) {
				if(pBot->ubTick == 50) {
					// Change target & route
					botFindNewTarget(pBot, pBot->pNavData->sRoute.pNodes[0]);
					pBot->ubState = AI_BOT_STATE_IDLE;
				}
				else
					++pBot->ubTick;
			}
			else {
				// Continue your route
				pBot->ubState = AI_BOT_STATE_MOVING_TO_NODE;
				pBot->ubTick = 0;
			}
		} break;
	}
}

static void botProcessAiming(tBot *pBot) {
	if(botTarget(pBot)) {
		pBot->pPlayer->sSteerRequest.ubAction1 = 1;
	}
	else {
		pBot->pPlayer->sSteerRequest.ubAction1 = 0;
	}
}

static void botProcessLimbo(tBot *pBot) {
	if(pBot->pNavData->ubState == ASTAR_STATE_OFF) {
		// Find some place to go - e.g. capture point
		tAiNode *pFirstNode = botFindNewTarget(pBot, 0);
		// Find nearest spawn point
		pBot->pPlayer->ubSpawnIdx = spawnGetNearest(
			pFirstNode->fubX, pFirstNode->fubY,
			pBot->pPlayer->ubTeam
		);
		// After arriving at surface, recalculate where bot is going
		pBot->ubState = AI_BOT_STATE_IDLE;
	}
	// Make sure noone from own team stands at spawn
	// TODO: spawn kill ppl from other team
	if(!pBot->pPlayer->uwCooldown && !spawnIsCoveredByAnyPlayer(pBot->pPlayer->ubSpawnIdx)) {
		playerSelectVehicle(pBot->pPlayer, VEHICLE_TYPE_TANK);
		memset(&pBot->pPlayer->sSteerRequest, 0, sizeof(tSteerRequest));
		botSay(pBot, "Surfacing...");
	}
}

void botProcess(void) {
	for(FUBYTE i = 0; i != s_fubBotCount; ++i) {
		tBot *pBot = &s_pBots[i];
		switch(pBot->pPlayer->ubState) {
			case PLAYER_STATE_DRIVING:
				botProcessDriving(pBot);
				botProcessAiming(pBot);
				break;
			case PLAYER_STATE_LIMBO:
				botProcessLimbo(pBot);
				break;
		}
	}
}
