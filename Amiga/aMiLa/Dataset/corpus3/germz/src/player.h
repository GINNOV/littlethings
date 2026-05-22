/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#ifndef GERMZ_PLAYER_H
#define GERMZ_PLAYER_H

#include "bob_new.h"
#include "map.h"
#include "plep.h"
#include "steer.h"

#define PLEPS_PER_PLAYER 3

typedef enum tPlayerIdx {
	PLAYER_1,
	PLAYER_2,
	PLAYER_3,
	PLAYER_4,
	PLAYER_NONE,
} tPlayerIdx;

typedef struct tPlayer {
	tBobNew *pBobCursor;
	ULONG ulRepeatCounter;
	struct tPlayer *pTeamMate;
	struct tSteer *pSteer;
	struct tNode *pNodeCursor;
	struct tNode *pNodePlepSrc;
	struct tPlep pPleps[PLEPS_PER_PLAYER];
	BYTE bNodeCount;
	BYTE pNodeTypeCounts[NODE_TYPE_COUNT];
	UBYTE isSelectingDestination;
	UBYTE isDead;
	tPlayerMapModifiers *pMods;
} tPlayer;

void playerCreate(void);

void playerDestroy(void);

void playerReset(tPlayerIdx eIdx, struct tNode *pStartNode);

/**
 * @brief
 *
 * @return Number of players alive.
 */
UBYTE playerProcess(void);

tPlayer *playerFromTile(enum tTile eTile);

tPlayerIdx playerToIdx(const tPlayer *pPlayer);

tPlayerIdx playerIdxFromTile(tTile eTile);

tPlayer *playerFromIdx(tPlayerIdx eIdx);

void playerUpdateDead(tPlayer *pPlayer);

void playerAllDead(void);

void playerPushCursors(void);

UBYTE playerHasFreePlep(const tPlayer *pPlayer);

#endif // GERMZ_PLAYER_H
