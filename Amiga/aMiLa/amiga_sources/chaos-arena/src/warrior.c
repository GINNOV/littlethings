/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "warrior.h"
#include <ace/managers/key.h>
#include <ace/managers/sprite.h>
#include "chaos_arena.h"
#include "assets.h"
#include "display.h"
#include "tile.h"
#include "menu.h"
#include "sfx.h"

//---------------------------------------------------------------------- DEFINES

#define WARRIOR_COUNT 12
#define WARRIORS_PER_ROW 8
#define WARRIOR_FRAME_WIDTH 16
#define WARRIOR_FRAME_HEIGHT 16
#define BYTES_PER_FRAME ((WARRIOR_FRAME_WIDTH / 8) * WARRIOR_FRAME_HEIGHT * DISPLAY_BPP)
#define MAX_ANIM_FRAMES 4
#define FRAME_COOLDOWN 5
#define DIR_ID(dX, dY) ((dX + 1) | ((dY + 1) << 2))
#define BOB_OFFSET_X (WARRIOR_FRAME_WIDTH / 2)
#define BOB_OFFSET_Y (WARRIOR_FRAME_HEIGHT)
#define WARRIOR_PUSH_DELTA 2
#define THUNDER_ACTIVATE_COOLDOWN 100
#define THUNDER_COLOR_COOLDOWN 3

// Must be power of 2!
#define LOOKUP_TILE_SIZE 8

#define LOOKUP_TILE_WIDTH (DISPLAY_WIDTH / LOOKUP_TILE_SIZE)
#define LOOKUP_TILE_HEIGHT (DISPLAY_HEIGHT / LOOKUP_TILE_SIZE)

//------------------------------------------------------------------------ TYPES

typedef struct tFrameOffsets {
	UBYTE *pBitmap;
	UBYTE *pMask;
} tFrameOffsets;

typedef struct tThunder {
	tUwCoordYX sAttackPos; ///< In viewport coords
	UBYTE ubActivateCooldown;
	UBYTE ubCurrentColor;
	UBYTE ubColorCooldown;
	UBYTE ubNextFrame;
	tSprite *pSpriteThunder;
	tSprite *pSpriteCross;
} tThunder;

//----------------------------------------------------------------- PRIVATE VARS

static tWarrior *s_pWarriors[WARRIOR_COUNT];
static tWarrior *s_pWarriorLookup[LOOKUP_TILE_WIDTH][LOOKUP_TILE_HEIGHT];
static tFrameOffsets s_pFrameOffsets[ANIM_DIRECTION_COUNT][ANIM_COUNT][MAX_ANIM_FRAMES];
static tThunder s_sThunder;

static const tAnimDirection s_pDirIdToAnimDir[] = {
	[DIR_ID(-1, -1)] = ANIM_DIRECTION_NW,
	[DIR_ID(-1,  0)] = ANIM_DIRECTION_W,
	[DIR_ID(-1,  1)] = ANIM_DIRECTION_SW,
	[DIR_ID( 0, -1)] = ANIM_DIRECTION_N,
	[DIR_ID( 0,  0)] = ANIM_DIRECTION_S, // whatever
	[DIR_ID( 0,  1)] = ANIM_DIRECTION_S,
	[DIR_ID( 1, -1)] = ANIM_DIRECTION_NE,
	[DIR_ID( 1,  0)] = ANIM_DIRECTION_E,
	[DIR_ID( 1,  1)] = ANIM_DIRECTION_SE,
};

static const tBCoordYX s_pAnimDirToAttackDelta[ANIM_DIRECTION_COUNT] = {
	[ANIM_DIRECTION_S] =  {.bX =                 0, .bY =  LOOKUP_TILE_SIZE},
	[ANIM_DIRECTION_SE] = {.bX =  LOOKUP_TILE_SIZE, .bY =  LOOKUP_TILE_SIZE},
	[ANIM_DIRECTION_E] =  {.bX =  LOOKUP_TILE_SIZE, .bY =                 0},
	[ANIM_DIRECTION_NE] = {.bX =  LOOKUP_TILE_SIZE, .bY = -LOOKUP_TILE_SIZE},
	[ANIM_DIRECTION_N] =  {.bX =                 0, .bY = -LOOKUP_TILE_SIZE},
	[ANIM_DIRECTION_NW] = {.bX = -LOOKUP_TILE_SIZE, .bY = -LOOKUP_TILE_SIZE},
	[ANIM_DIRECTION_W] =  {.bX = -LOOKUP_TILE_SIZE, .bY =                 0},
	[ANIM_DIRECTION_SW] = {.bX = -LOOKUP_TILE_SIZE, .bY = LOOKUP_TILE_SIZE},
};

static const UBYTE s_pFrameCountForAnim[ANIM_COUNT] = {
	[ANIM_IDLE] = 2,
	[ANIM_WALK] = 3,
	[ANIM_ATTACK] = 4,
	[ANIM_HURT] = 3,
	[ANIM_FALLING] = 1,
};

static UBYTE s_ubAliveCount;
static UBYTE s_ubAlivePlayerCount;
static UBYTE s_isMoveEnabled;

//------------------------------------------------------------------ PUBLIC VARS

const tBCoordYX g_pAnimDirToPushDelta[ANIM_DIRECTION_COUNT] = {
	[ANIM_DIRECTION_S] =  {.bX =                   0, .bY =  WARRIOR_PUSH_DELTA},
	[ANIM_DIRECTION_SE] = {.bX =  WARRIOR_PUSH_DELTA, .bY =  WARRIOR_PUSH_DELTA},
	[ANIM_DIRECTION_E] =  {.bX =  WARRIOR_PUSH_DELTA, .bY =                   0},
	[ANIM_DIRECTION_NE] = {.bX =  WARRIOR_PUSH_DELTA, .bY = -WARRIOR_PUSH_DELTA},
	[ANIM_DIRECTION_N] =  {.bX =                   0, .bY = -WARRIOR_PUSH_DELTA},
	[ANIM_DIRECTION_NW] = {.bX = -WARRIOR_PUSH_DELTA, .bY = -WARRIOR_PUSH_DELTA},
	[ANIM_DIRECTION_W] =  {.bX = -WARRIOR_PUSH_DELTA, .bY =                  0},
	[ANIM_DIRECTION_SW] = {.bX = -WARRIOR_PUSH_DELTA, .bY = WARRIOR_PUSH_DELTA},
};

//------------------------------------------------------------------ PRIVATE FNS

static inline UBYTE getFrameCountForAnim(tAnim eAnim) {
	return s_pFrameCountForAnim[eAnim];
}

static void initFrameOffsets(void) {
	ULONG ulByteOffs = 0;
	for(tAnimDirection eDir = 0; eDir < ANIM_DIRECTION_COUNT; ++eDir) {
		for(tAnim eAnim = 0; eAnim < ANIM_COUNT; ++eAnim) {
			if(eAnim == ANIM_FALLING) {
				continue;
			}

			UBYTE ubFramesInAnim = getFrameCountForAnim(eAnim);
			for(UBYTE ubFrame = 0; ubFrame < ubFramesInAnim; ++ubFrame) {
				if(eAnim == ANIM_WALK && ubFrame == 2) {
					continue;
				}
				s_pFrameOffsets[eDir][eAnim][ubFrame] = (tFrameOffsets) {
					.pBitmap = &g_pWarriorFrames->Planes[0][ulByteOffs],
					.pMask = &g_pWarriorMasks->Planes[0][ulByteOffs]
				};
				ulByteOffs += BYTES_PER_FRAME;
			}
		}
	}

	for(tAnimDirection eDir = 0; eDir < ANIM_DIRECTION_COUNT; ++eDir) {
		s_pFrameOffsets[eDir][ANIM_FALLING][0] = s_pFrameOffsets[eDir][ANIM_HURT][2];
		s_pFrameOffsets[eDir][ANIM_WALK][2] = s_pFrameOffsets[eDir][ANIM_WALK][1];
		s_pFrameOffsets[eDir][ANIM_WALK][1] = s_pFrameOffsets[eDir][ANIM_IDLE][1];
	}
}

static void resetWarriorLookup(void) {
	tWarrior **pBegin = &s_pWarriorLookup[0][0];
	tWarrior **pEnd = &s_pWarriorLookup[LOOKUP_TILE_WIDTH - 1][LOOKUP_TILE_HEIGHT - 1 + 1];
	for(tWarrior **pEntry = pBegin; pEntry != pEnd; ++pEntry) {
		*pEntry = 0;
	}
}

static UBYTE isPositionCollidingWithWarrior(
	tUwCoordYX sPos, const tWarrior *pWarrior
) {
	return (
		sPos.uwX < pWarrior->sPos.uwX + LOOKUP_TILE_SIZE &&
		sPos.uwX + LOOKUP_TILE_SIZE > pWarrior->sPos.uwX &&
		sPos.uwY < pWarrior->sPos.uwY + LOOKUP_TILE_SIZE &&
		sPos.uwY + LOOKUP_TILE_SIZE > pWarrior->sPos.uwY
	);
}

static UBYTE areWarriorsColliding(
	const tWarrior *pWarrior1, const tWarrior *pWarrior2
) {
	return isPositionCollidingWithWarrior(pWarrior1->sPos, pWarrior2);
}

static inline tWarrior *warriorGetNearPos(
	UWORD uwPosX, BYTE bLookupAddX, UWORD uwPosY, BYTE bLookupAddY
) {
	UWORD uwLookupX = uwPosX / LOOKUP_TILE_SIZE + bLookupAddX;
	UWORD uwLookupY = uwPosY / LOOKUP_TILE_SIZE + bLookupAddY;
	return s_pWarriorLookup[uwLookupX][uwLookupY];
}

static void warriorUpdateBobPosition(tWarrior *pWarrior) {
	pWarrior->sBob.sPos.uwX = pWarrior->sPos.uwX - BOB_OFFSET_X;
	pWarrior->sBob.sPos.uwY = pWarrior->sPos.uwY - BOB_OFFSET_Y;

	if (pWarrior->sBob.sPos.uwX > DISPLAY_WIDTH || pWarrior->sBob.sPos.uwY > DISPLAY_HEIGHT) {
		logWrite("ERR: warrior %p bob out of bounds", pWarrior);
	}
}

static void warriorTryMoveBy(tWarrior *pWarrior, BYTE bDeltaX, BYTE bDeltaY) {
	if(!s_isMoveEnabled) {
		return;
	}

	UBYTE ubOldLookupX = pWarrior->sPos.uwX / LOOKUP_TILE_SIZE;
	UBYTE ubOldLookupY = pWarrior->sPos.uwY / LOOKUP_TILE_SIZE;
	UBYTE isMoved = 0;

	if (bDeltaX) {
		tUwCoordYX sOldPos = {.ulYX = pWarrior->sPos.ulYX};
		pWarrior->sPos.uwX += bDeltaX;
		UBYTE isColliding = (bDeltaX > 0 ?
			pWarrior->sPos.uwX >= DISPLAY_WIDTH - BOB_OFFSET_X :
			pWarrior->sPos.uwX <= BOB_OFFSET_X
		);

		// collision with upper corner
		if(!isColliding) {
			tWarrior *pUp = warriorGetNearPos(sOldPos.uwX, SGN(bDeltaX), sOldPos.uwY, 0);
			if(pUp && pUp != pWarrior) {
				isColliding = areWarriorsColliding(pWarrior, pUp);
			}
		}

		// collision with lower corner
		if (!isColliding && (sOldPos.uwY & (LOOKUP_TILE_SIZE - 1))) {
			tWarrior *pDown = warriorGetNearPos(sOldPos.uwX, SGN(bDeltaX), sOldPos.uwY, +1);
			if(pDown && pDown != pWarrior) {
				isColliding = areWarriorsColliding(pWarrior, pDown);
			}
		}

		if(!isColliding) {
			isMoved = 1;
		}
		else {
			pWarrior->sPos.ulYX = sOldPos.ulYX;
		}
	}

	if (bDeltaY) {
		tUwCoordYX sOldPos = {.ulYX = pWarrior->sPos.ulYX};
		pWarrior->sPos.uwY += bDeltaY;
		UBYTE isColliding = (bDeltaY > 0 ?
			pWarrior->sPos.uwY >= DISPLAY_HEIGHT - BOB_OFFSET_Y :
			pWarrior->sPos.uwY <= BOB_OFFSET_Y
		);

		// collision with left corner
		if(!isColliding) {
			tWarrior *pLeft = warriorGetNearPos(sOldPos.uwX, 0, sOldPos.uwY, SGN(bDeltaY));
			if(pLeft && pLeft != pWarrior) {
				isColliding = areWarriorsColliding(pWarrior, pLeft);
			}
		}

		// collision with right corner
		if (!isColliding && (sOldPos.uwX & (LOOKUP_TILE_SIZE - 1))) {
			tWarrior *pRight = warriorGetNearPos(sOldPos.uwX, +1, sOldPos.uwY, SGN(bDeltaY));
			if(pRight && pRight != pWarrior) {
				isColliding = areWarriorsColliding(pWarrior, pRight);
			}
		}

		if(!isColliding) {
			isMoved = 1;
		}
		else {
			pWarrior->sPos.ulYX = sOldPos.ulYX;
		}
	}

	if(isMoved) {
		warriorUpdateBobPosition(pWarrior);

		// Update lookup
		if(
			s_pWarriorLookup[ubOldLookupX][ubOldLookupY] &&
			s_pWarriorLookup[ubOldLookupX][ubOldLookupY] != pWarrior
		) {
			logWrite(
				"ERR: Erasing other warrior %p\n",
				s_pWarriorLookup[ubOldLookupX][ubOldLookupY]
			);
		}
		s_pWarriorLookup[ubOldLookupX][ubOldLookupY] = 0;

		UBYTE ubNewLookupX = pWarrior->sPos.uwX / LOOKUP_TILE_SIZE;
		UBYTE ubNewLookupY = pWarrior->sPos.uwY / LOOKUP_TILE_SIZE;
		if(s_pWarriorLookup[ubNewLookupX][ubNewLookupY]) {
			logWrite(
				"ERR: Overwriting other warrior %p in lookup with %p\n",
				s_pWarriorLookup[ubNewLookupX][ubNewLookupY], pWarrior
			);
		}
		s_pWarriorLookup[ubNewLookupX][ubNewLookupY] = pWarrior;
	}
}

static void warriorAdd(
	tWarrior *pWarrior, UWORD uwSpawnX, UWORD uwSpawnY, tSteerMode eSteerMode,
	UBYTE ubIndex
) {
	pWarrior->sPos = (tUwCoordYX){.uwX = uwSpawnX, .uwY = uwSpawnY};
	bobInit(
		&pWarrior->sBob, WARRIOR_FRAME_WIDTH, WARRIOR_FRAME_HEIGHT, 1,
		g_pWarriorFrames->Planes[0], g_pWarriorMasks->Planes[0],
		pWarrior->sPos.uwX - BOB_OFFSET_X, pWarrior->sPos.uwY - BOB_OFFSET_Y
	);
	pWarrior->ubAnimFrame = 0;
	pWarrior->ubFrameCooldown = FRAME_COOLDOWN;
	pWarrior->ubStunCooldown = 0;
	pWarrior->isDead = 0;
	pWarrior->eAnim = ANIM_IDLE;
	pWarrior->eDirection = ANIM_DIRECTION_S;
	pWarrior->sSteer = steerInitFromMode(eSteerMode, pWarrior);
	pWarrior->ubIndex = ubIndex;
	s_pWarriorLookup[uwSpawnX / LOOKUP_TILE_SIZE][uwSpawnY / LOOKUP_TILE_SIZE] = pWarrior;
	++s_ubAliveCount;
	if(steerIsPlayer(&pWarrior->sSteer)) {
		++s_ubAlivePlayerCount;
	}
	logWrite("Spawned warrior %p at %hu,%hu", pWarrior, uwSpawnX, uwSpawnY);
}

static void warriorSetAnim(tWarrior *pWarrior, tAnim eAnim) {
	pWarrior->eAnim = eAnim;
	pWarrior->ubAnimFrame = 0;
	pWarrior->ubFrameCooldown = FRAME_COOLDOWN;
}

static void warriorSetAnimOnce(tWarrior *pWarrior, tAnim eAnim) {
	if(pWarrior->eAnim != eAnim) {
		warriorSetAnim(pWarrior, eAnim);
	}
}

static UBYTE warriorStrike(const tWarrior *pWarrior) {
	tWarrior *pTarget = warriorGetStrikeTarget(pWarrior, pWarrior->eDirection);
	if(pTarget) {
		warriorSetAnim(pTarget, ANIM_HURT);
		pTarget->sPushDelta = g_pAnimDirToPushDelta[pWarrior->eDirection];
		return 1;
	}
	return 0;
}

static UBYTE warriorIsInAir(const tWarrior *pWarrior) {
	UWORD uwX = pWarrior->sPos.uwX - LOOKUP_TILE_SIZE / 2;
	UWORD uwY = pWarrior->sPos.uwY - LOOKUP_TILE_SIZE / 2;
	if(tileIsSolid(uwX / MAP_TILE_SIZE, uwY / MAP_TILE_SIZE)) {
		return 0;
	}

	uwX = pWarrior->sPos.uwX + LOOKUP_TILE_SIZE / 2;
	uwY = pWarrior->sPos.uwY + LOOKUP_TILE_SIZE / 2;
	if(tileIsSolid(uwX / MAP_TILE_SIZE, uwY / MAP_TILE_SIZE)) {
		return 0;
	}

	return 1;
}

static void warriorKill(tWarrior *pWarrior) {
	pWarrior->isDead = 1;
	--s_ubAliveCount;
	if (steerIsPlayer(&pWarrior->sSteer)) {
		--s_ubAlivePlayerCount;
		if(menuAreThundersEnabled()) {
			spriteSetEnabled(s_sThunder.pSpriteCross, 1);
		}
	}
}

static void warriorProcessState(tWarrior *pWarrior) {
	if(pWarrior->eAnim == ANIM_FALLING) {
		pWarrior->sPos.uwY += 4;
		warriorUpdateBobPosition(pWarrior);
		WORD wBobTop = pWarrior->sBob.sPos.uwY;
		UWORD uwBobBottom = wBobTop + pWarrior->sBob.uwHeight;
		if(tileIsSolid(pWarrior->sPos.uwX / MAP_TILE_SIZE, uwBobBottom / MAP_TILE_SIZE)) {
			WORD wOccluderTop = (uwBobBottom / MAP_TILE_SIZE) * MAP_TILE_SIZE;
			WORD wNewSize = wOccluderTop - wBobTop;
			if (wNewSize <= 0) {
				warriorKill(pWarrior);
			}
			else {
				pWarrior->sBob.uwHeight = wNewSize;
			}
		}
		if(pWarrior->sPos.uwY >= DISPLAY_HEIGHT - 16) {
			warriorKill(pWarrior);
		}
		return;
	}

	if(pWarrior->eAnim == ANIM_HURT && pWarrior->ubAnimFrame != getFrameCountForAnim(ANIM_HURT) - 1) {
		// Pushback
		warriorTryMoveBy(pWarrior, pWarrior->sPushDelta.bX, pWarrior->sPushDelta.bY);
		return;
	}

	if(pWarrior->eAnim == ANIM_ATTACK && pWarrior->ubAnimFrame != getFrameCountForAnim(ANIM_ATTACK) - 1) {
		warriorTryMoveBy(pWarrior, pWarrior->sPushDelta.bX, pWarrior->sPushDelta.bY);
		if(pWarrior->ubAnimFrame == getFrameCountForAnim(ANIM_ATTACK) - 2) {
			// Do the actual hit
			UBYTE isHit = warriorStrike(pWarrior);
			if(isHit) {
				ptplayerSfxPlay(g_pSfxSwipeHit, 3, 64, SFX_PRIORITY_HIT);
			}
			else {
				ptplayerSfxPlay(g_pSfxSwipes[randUw(&g_sRandManager) & 1], 3, 64, SFX_PRIORITY_SWIPE);
			}
		}
		return;
	}

	if(warriorIsInAir(pWarrior)) {
		warriorSetAnim(pWarrior, ANIM_FALLING);
		ptplayerSfxPlay(g_pSfxNo, 2, 64, SFX_PRIORITY_FALL);

		// stop collision of warrior
		UBYTE ubTileX = pWarrior->sPos.uwX / LOOKUP_TILE_SIZE;
		UBYTE ubTileY = pWarrior->sPos.uwY / LOOKUP_TILE_SIZE;
		if(s_pWarriorLookup[ubTileX][ubTileY] != pWarrior) {
			logWrite(
				"ERR: Clearing warrior %p when falling %p",
				s_pWarriorLookup[ubTileX][ubTileY], pWarrior
			);
		}

		s_pWarriorLookup[ubTileX][ubTileY] = 0;
		return;
	}

	if(steerDirCheck(&pWarrior->sSteer, DIRECTION_FIRE)) {
		// Start swinging
		warriorSetAnim(pWarrior, ANIM_ATTACK);
		pWarrior->sPushDelta = g_pAnimDirToPushDelta[pWarrior->eDirection];
		return;
	}

	BYTE bDeltaX = 0, bDeltaY = 0;
	if (steerDirCheck(&pWarrior->sSteer, DIRECTION_UP)) {
		--bDeltaY;
	}
	if (steerDirCheck(&pWarrior->sSteer, DIRECTION_DOWN)) {
		++bDeltaY;
	}
	if (steerDirCheck(&pWarrior->sSteer, DIRECTION_LEFT)) {
		--bDeltaX;
	}
	if (steerDirCheck(&pWarrior->sSteer, DIRECTION_RIGHT)) {
		++bDeltaX;
	}

	UBYTE ubDirId = DIR_ID(bDeltaX, bDeltaY);
	if(ubDirId != DIR_ID(0, 0)) {
		pWarrior->eDirection = s_pDirIdToAnimDir[ubDirId];
		warriorSetAnimOnce(pWarrior, ANIM_WALK);
		warriorTryMoveBy(pWarrior, bDeltaX, bDeltaY);
	}
	else {
		warriorSetAnimOnce(pWarrior, ANIM_IDLE);
	}
}

static void thunderProcessInput(tSteer *pSteer) {
	steerProcess(pSteer);
	BYTE bDx = 0, bDy = 0;
	if(steerDirCheck(pSteer, DIRECTION_LEFT)) {
		bDx -= 1;
	}
	if(steerDirCheck(pSteer, DIRECTION_RIGHT)) {
		bDx += 1;
	}
	if(steerDirCheck(pSteer, DIRECTION_UP)) {
		bDy -= 1;
	}
	if(steerDirCheck(pSteer, DIRECTION_DOWN)) {
		bDy += 1;
	}

	if(bDx) {
		s_sThunder.sAttackPos.uwX = CLAMP(
			s_sThunder.sAttackPos.uwX + bDx,
			DISPLAY_MARGIN_SIZE, DISPLAY_WIDTH - DISPLAY_MARGIN_SIZE
		);
	}
	if(bDy) {
		s_sThunder.sAttackPos.uwY = CLAMP(
			s_sThunder.sAttackPos.uwY + bDy,
			DISPLAY_MARGIN_SIZE, DISPLAY_HEIGHT - DISPLAY_MARGIN_SIZE
		);
	}
}

static void warriorProcess(tWarrior *pWarrior) {
	if(pWarrior->isDead) {
		if(steerIsPlayer(&pWarrior->sSteer)) {
			thunderProcessInput(&pWarrior->sSteer);
		}
		return;
	}

	steerProcess(&pWarrior->sSteer);
	warriorProcessState(pWarrior);

	--pWarrior->ubFrameCooldown;
	if (!pWarrior->ubFrameCooldown) {
		if (++pWarrior->ubAnimFrame >= getFrameCountForAnim(pWarrior->eAnim)) {
			pWarrior->ubAnimFrame = 0;
		}
		pWarrior->ubFrameCooldown = FRAME_COOLDOWN;
		tFrameOffsets *pOffsets = &s_pFrameOffsets[pWarrior->eDirection][pWarrior->eAnim][pWarrior->ubAnimFrame];
		bobSetFrame(&pWarrior->sBob, pOffsets->pBitmap, pOffsets->pMask);
	}

	if(!pWarrior->isDead) {
		bobPush(&pWarrior->sBob);
	}
}

//------------------------------------------------------------------- PUBLIC FNS

void warriorsDrawLookup(tBitMap *pBuffer) {
	for(UBYTE ubY = 0; ubY < LOOKUP_TILE_HEIGHT; ++ubY) {
		for(UBYTE ubX = 0; ubX < LOOKUP_TILE_WIDTH; ++ubX) {
			if (s_pWarriorLookup[ubX][ubY]) {
				blitRect(
					pBuffer, ubX * LOOKUP_TILE_SIZE, ubY * LOOKUP_TILE_SIZE,
					LOOKUP_TILE_SIZE, LOOKUP_TILE_SIZE, 6
				);
			}
		}
	}
}

void warriorsCreate(UBYTE isExtraEnemiesEnabled) {
	initFrameOffsets();
	resetWarriorLookup();
	tileShuffleSpawns();
	s_ubAliveCount = 0;
	s_ubAlivePlayerCount = 0;
	s_isMoveEnabled = 0;

	UBYTE ubPlayers = 0;
	for(UBYTE i = 0; i < WARRIOR_COUNT; ++i) {
		tSteerMode eSteerMode = menuGetSteerModeForPlayer(i);
		if(eSteerMode < STEER_MODE_AI) {
			++ubPlayers;
		}
	}

	if(ubPlayers < 2) {
		isExtraEnemiesEnabled = 1;
	}

	for(UBYTE i = 0; i < WARRIOR_COUNT; ++i) {
		s_pWarriors[i] = memAllocFast(sizeof(*s_pWarriors[i]));
		const tUwCoordYX *pSpawn = tileGetSpawn(i);
		tSteerMode eSteerMode = menuGetSteerModeForPlayer(i);
		warriorAdd(s_pWarriors[i], pSpawn->uwX, pSpawn->uwY, eSteerMode, i);
		if(!isExtraEnemiesEnabled &&  (
			eSteerMode == STEER_MODE_AI || eSteerMode == STEER_MODE_IDLE ||
			eSteerMode == STEER_MODE_OFF
		)) {
			warriorKill(s_pWarriors[i]);
			UBYTE ubTileX = s_pWarriors[i]->sPos.uwX / LOOKUP_TILE_SIZE;
			UBYTE ubTileY = s_pWarriors[i]->sPos.uwY / LOOKUP_TILE_SIZE;
			s_pWarriorLookup[ubTileX][ubTileY] = 0;
			warriorGetNearPos(s_pWarriors[i]->sPos.uwX, 0, s_pWarriors[i]->sPos.uwY, 0);
		}
	}

	s_sThunder.pSpriteThunder = spriteAdd(DISPLAY_SPRITE_CHANNEL_THUNDER, g_pFramesThunder[0]);
	s_sThunder.pSpriteCross = spriteAdd(DISPLAY_SPRITE_CHANNEL_CURSOR, g_pFramesCross);
	spriteSetEnabled(s_sThunder.pSpriteThunder, 0);
	spriteSetEnabled(s_sThunder.pSpriteCross, 0);
	s_sThunder.sAttackPos.ulYX = (tUwCoordYX){
		.uwX = DISPLAY_WIDTH / 2, .uwY = DISPLAY_HEIGHT / 2
	}.ulYX;
	s_sThunder.ubActivateCooldown = THUNDER_ACTIVATE_COOLDOWN;
	s_sThunder.ubCurrentColor = 0;
	s_sThunder.ubColorCooldown = 0;
	s_sThunder.ubNextFrame = 0;
}

void warriorsProcess(void) {

	for(UBYTE i = 0; i < WARRIOR_COUNT; ++i) {
		warriorProcess(s_pWarriors[i]);
	}

	if(s_sThunder.pSpriteCross->isEnabled) {
		if(s_sThunder.ubColorCooldown) {
			if(--s_sThunder.ubColorCooldown == 0) {
				if(++s_sThunder.ubCurrentColor < 8) {
					s_sThunder.ubColorCooldown = THUNDER_COLOR_COOLDOWN;
					displaySetThunderColor(s_sThunder.ubCurrentColor);
				}
				else {
					spriteSetEnabled(s_sThunder.pSpriteThunder, 0);
				}
			}
		}
		if(--s_sThunder.ubActivateCooldown == 0) {
			spriteSetEnabled(s_sThunder.pSpriteThunder, 1);
			spriteSetBitmap(s_sThunder.pSpriteThunder, g_pFramesThunder[s_sThunder.ubNextFrame]);
			s_sThunder.ubNextFrame = !s_sThunder.ubNextFrame;
			s_sThunder.pSpriteThunder->wX = s_sThunder.sAttackPos.uwX - DISPLAY_MARGIN_SIZE - 8;
			s_sThunder.pSpriteThunder->wY = 0;
			spriteSetHeight(s_sThunder.pSpriteThunder, s_sThunder.sAttackPos.uwY - DISPLAY_MARGIN_SIZE);
			s_sThunder.ubActivateCooldown = THUNDER_ACTIVATE_COOLDOWN;
			warriorAttackWithLightning(s_sThunder.sAttackPos);
			s_sThunder.ubCurrentColor = 0;
			displaySetThunderColor(0);
			s_sThunder.ubColorCooldown = THUNDER_COLOR_COOLDOWN;
			ptplayerSfxPlay(g_pSfxThunder, 2, 64, SFX_PRIORITY_THUNDER);
		}

		s_sThunder.pSpriteCross->wX = s_sThunder.sAttackPos.uwX - DISPLAY_MARGIN_SIZE - 8;
		s_sThunder.pSpriteCross->wY = s_sThunder.sAttackPos.uwY - DISPLAY_MARGIN_SIZE - 8;
		spriteRequestMetadataUpdate(s_sThunder.pSpriteCross);
	}

	spriteProcess(s_sThunder.pSpriteThunder);
	spriteProcess(s_sThunder.pSpriteCross);

	tWarrior **pPrev = &s_pWarriors[0];
	for(UBYTE i = 1; i < WARRIOR_COUNT; ++i) {
		if(s_pWarriors[i]->sPos.ulYX < (*pPrev)->sPos.ulYX) {
			tWarrior *pTemp = *pPrev;
			*pPrev = s_pWarriors[i];
			s_pWarriors[i] = pTemp;
		}
		pPrev = &s_pWarriors[i];
	}
}

void warriorsDestroy(void) {
	for(UBYTE i = 0; i < WARRIOR_COUNT; ++i) {
		memFree(s_pWarriors[i], sizeof(*s_pWarriors[i]));
	}
	spriteRemove(s_sThunder.pSpriteThunder);
	spriteRemove(s_sThunder.pSpriteCross);
}

UBYTE warriorsGetAliveCount(void) {
	return s_ubAliveCount;
}

UBYTE warriorsGetAlivePlayerCount(void) {
	return s_ubAlivePlayerCount;
}

UBYTE warriorsGetLastAliveIndex(void) {
	for(UBYTE i = 0; i < WARRIOR_COUNT; ++i) {
		if(!s_pWarriors[i]->isDead && s_pWarriors[i]->ubIndex < PLAYER_MAX_COUNT) {
			return s_pWarriors[i]->ubIndex;
		}
	}
	return WARRIOR_LAST_ALIVE_INDEX_INVALID;
}

void warriorsEnableMove(UBYTE isEnabled) {
	s_isMoveEnabled = isEnabled;
}

void warriorAttackWithLightning(tUwCoordYX sAttackPos) {
	tWarrior *pTarget;

	pTarget = warriorGetNearPos(sAttackPos.uwX, 0, sAttackPos.uwY, 0);
	if(pTarget && isPositionCollidingWithWarrior(sAttackPos, pTarget)) {
		warriorSetAnim(pTarget, ANIM_HURT);
		pTarget->sPushDelta = g_pAnimDirToPushDelta[randUw(&g_sRandManager) & 7];
		return;
	}

	pTarget = warriorGetNearPos(sAttackPos.uwX, 1, sAttackPos.uwY, 0);
	if(pTarget && isPositionCollidingWithWarrior(sAttackPos, pTarget)) {
		warriorSetAnim(pTarget, ANIM_HURT);
		pTarget->sPushDelta = g_pAnimDirToPushDelta[randUw(&g_sRandManager) & 7];
		return;
	}

	pTarget = warriorGetNearPos(sAttackPos.uwX, 0, sAttackPos.uwY, 1);
	if(pTarget && isPositionCollidingWithWarrior(sAttackPos, pTarget)) {
		warriorSetAnim(pTarget, ANIM_HURT);
		pTarget->sPushDelta = g_pAnimDirToPushDelta[randUw(&g_sRandManager) & 7];
		return;
	}

	pTarget = warriorGetNearPos(sAttackPos.uwX, 1, sAttackPos.uwY, 1);
	if(pTarget && isPositionCollidingWithWarrior(sAttackPos, pTarget)) {
		warriorSetAnim(pTarget, ANIM_HURT);
		pTarget->sPushDelta = g_pAnimDirToPushDelta[randUw(&g_sRandManager) & 7];
		return;
	}
}

tWarrior *warriorGetStrikeTarget(
	const tWarrior *pWarrior, tAnimDirection eDirection
) {
	const tBCoordYX *pDelta = &s_pAnimDirToAttackDelta[eDirection];
	tUwCoordYX sAttackPos = (tUwCoordYX) {
		.uwX = pWarrior->sPos.uwX + pDelta->bX,
		.uwY = pWarrior->sPos.uwY + pDelta->bY
	};
	tWarrior *pOther;

	pOther = warriorGetNearPos(sAttackPos.uwX, 0, sAttackPos.uwY, 0);
	if(pOther && pOther != pWarrior && isPositionCollidingWithWarrior(sAttackPos, pOther)) {
		return pOther;
	}

	pOther = warriorGetNearPos(sAttackPos.uwX, 1, sAttackPos.uwY, 0);
	if(pOther && pOther != pWarrior && isPositionCollidingWithWarrior(sAttackPos, pOther)) {
		return pOther;
	}

	pOther = warriorGetNearPos(sAttackPos.uwX, 0, sAttackPos.uwY, 1);
	if(pOther && pOther != pWarrior && isPositionCollidingWithWarrior(sAttackPos, pOther)) {
		return pOther;
	}

	pOther = warriorGetNearPos(sAttackPos.uwX, 1, sAttackPos.uwY, 1);
	if(pOther && pOther != pWarrior && isPositionCollidingWithWarrior(sAttackPos, pOther)) {
		return pOther;
	}

	return 0;
}
