#include "ai.h"
#include "tile.h"
#include "chaos_arena.h"
#include "warrior.h"
#include "game.h"

#define AI_MOVEMENT_COOLDOWN 50

static const tDirection s_pAnimDirectionToSteerDirection[ANIM_DIRECTION_COUNT] = {
	[ANIM_DIRECTION_S]  = DIRECTION_DOWN,
	[ANIM_DIRECTION_SE] = DIRECTION_DOWN | DIRECTION_RIGHT,
	[ANIM_DIRECTION_E]  = DIRECTION_RIGHT,
	[ANIM_DIRECTION_NE] = DIRECTION_UP | DIRECTION_RIGHT,
	[ANIM_DIRECTION_N]  = DIRECTION_UP,
	[ANIM_DIRECTION_NW] = DIRECTION_UP | DIRECTION_LEFT,
	[ANIM_DIRECTION_W]  = DIRECTION_LEFT,
	[ANIM_DIRECTION_SW] = DIRECTION_DOWN | DIRECTION_LEFT,
};

static const tBCoordYX s_pAnimDirectionToMoveDelta[ANIM_DIRECTION_COUNT] = {
	[ANIM_DIRECTION_S]  = (tBCoordYX){.bY =  1, .bX =  0},
	[ANIM_DIRECTION_SE] = (tBCoordYX){.bY =  1, .bX =  1},
	[ANIM_DIRECTION_E]  = (tBCoordYX){.bY =  0, .bX =  1},
	[ANIM_DIRECTION_NE] = (tBCoordYX){.bY = -1, .bX =  1},
	[ANIM_DIRECTION_N]  = (tBCoordYX){.bY = -1, .bX =  0},
	[ANIM_DIRECTION_NW] = (tBCoordYX){.bY = -1, .bX = -1},
	[ANIM_DIRECTION_W]  = (tBCoordYX){.bY =  0, .bX = -1},
	[ANIM_DIRECTION_SW] = (tBCoordYX){.bY =  1, .bX = -1},
};

void aiInit(tAi *pAi, tWarrior* pWarrior) {
	pAi->pWarrior = pWarrior;
	pAi->eNextAttackDirection = ANIM_DIRECTION_S;
	pAi->eNextMovementDirection = ANIM_DIRECTION_S;
	pAi->eState = AI_STATE_MOVING;
	pAi->ubMovementCooldown = AI_MOVEMENT_COOLDOWN;
}

UBYTE aiIsEnemyNearInCurrentScanDirection(tAi *pAi) {
	tWarrior *pTarget = warriorGetStrikeTarget(pAi->pWarrior, pAi->eNextAttackDirection);
	if(pTarget) {
		return 1;
	}
	return 0;
}

tDirection aiProcess(tAi *pAi) {
	if(gameIsCountdownActive()) {
		return DIRECTION_COUNT;
	}

	// Don't do a thing if it's not idling/moving
	if(pAi->pWarrior->isDead || pAi->pWarrior->eAnim > ANIM_WALK) {
		return DIRECTION_COUNT;
	}

	switch(pAi->eState) {
		case AI_STATE_MOVING:
			// Finding next target needs to be done while moving or warrior will stop
			// every second frame.
			if(aiIsEnemyNearInCurrentScanDirection(pAi)) {
				pAi->eState = AI_STATE_ATTACKING;
				return s_pAnimDirectionToSteerDirection[pAi->eNextAttackDirection];
			}
			pAi->eNextAttackDirection += 2; // skip mixed coords
			if(pAi->eNextAttackDirection >= ANIM_DIRECTION_COUNT) {
				pAi->eNextAttackDirection = ANIM_DIRECTION_S;
			}

			// Move along current path until near the abyss, find next movement tile
			const tBCoordYX *pDelta = &s_pAnimDirectionToMoveDelta[pAi->eNextMovementDirection];
			if(
				--pAi->ubMovementCooldown == 0 ||
				!tileIsSolid(
					(pAi->pWarrior->sPos.uwX / MAP_TILE_SIZE) + pDelta->bX,
					(pAi->pWarrior->sPos.uwY / MAP_TILE_SIZE) + pDelta->bY
				)
			) {
				// Skip odd directions to prevent oging diagonally
				pAi->eNextMovementDirection = randUw(&g_sRandManager) & 0b110;
				pAi->ubMovementCooldown = AI_MOVEMENT_COOLDOWN;
			}
			else {
				return s_pAnimDirectionToSteerDirection[pAi->eNextMovementDirection];
			}
			break;
		case AI_STATE_ATTACKING:
			// Attack in current direction and continue movement
			pAi->eState = AI_STATE_MOVING;
			pAi->eNextMovementDirection = pAi->eNextAttackDirection;
			pAi->ubMovementCooldown = AI_MOVEMENT_COOLDOWN;
			return DIRECTION_FIRE;
		default:
			break;
	}
	return DIRECTION_COUNT;
}
