/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "player.h"
#include "game.h"
#include "assets.h"

//---------------------------------------------------------------------- DEFINES

#define PLAYER_COUNT_MAX 4

//------------------------------------------------------------------------ TYPES

typedef struct tCursorField {
	tUbCoordYX sPosTile;
	UBYTE ubCurrentCursor;
	UBYTE ubCursorCount;
	UBYTE ubFrameCounter;
	tBobNew *pBobs[PLAYER_COUNT_MAX];
} tCursorField;

//----------------------------------------------------------------- PRIVATE VARS

tPlayer s_pPlayers[PLAYER_COUNT_MAX];
static tCursorField s_pCursorFields[4];

//------------------------------------------------------------------ PRIVATE FNS

static void playerSetCursorPos(tPlayer *pPlayer, tNode *pNode) {
		pPlayer->pNodeCursor = pNode;
		pPlayer->pBobCursor->sPos.uwX = pNode->sPosTile.ubX * MAP_TILE_SIZE;
		pPlayer->pBobCursor->sPos.uwY = pNode->sPosTile.ubY * MAP_TILE_SIZE;
}

static UBYTE playerSpawnPlep(tPlayer *pPlayer, tDirection eDir) {
	// TODO: store last index, add starting from it
	WORD wPlepCharges = pPlayer->pNodePlepSrc->wCharges / 2;
	if(
		!wPlepCharges || eDir >= DIRECTION_FIRE ||
		!pPlayer->pNodePlepSrc->pNeighbors[eDir]
	) {
		return 0;
	}
	for(UBYTE i = 0; i < PLEPS_PER_PLAYER; ++i) {
		tPlep *pPlep = &pPlayer->pPleps[i];
		if(!pPlep->isActive && pPlayer->pNodePlepSrc->pPlayer == pPlayer) {
			plepSpawn(pPlep, wPlepCharges, eDir);
			pPlayer->pNodePlepSrc->wCharges -= wPlepCharges;
			logWrite(
				"Spawned plep %hhu on player %d: blob %hhu,%hhu -> %hhu,%hhu\n",
				i, playerToIdx(pPlayer),
				pPlayer->pNodePlepSrc->sPosTile.ubX, pPlayer->pNodePlepSrc->sPosTile.ubY,
				pPlep->pDestination->sPosTile.ubX, pPlep->pDestination->sPosTile.ubY
			);
			return 1;
		}
	}
	return 0;
}

//------------------------------------------------------------------- PUBLIC FNS

void playerCreate(void) {
	logBlockBegin("playerCreate()");
	plepCreate();
	logBlockEnd("playerCreate()");
}

void playerDestroy(void) {
	plepDestroy();
}

void playerReset(tPlayerIdx eIdx, tNode *pStartNode) {
	tPlayer *pPlayer = playerFromIdx(eIdx);
	pPlayer->pBobCursor = gameGetCursorBob(eIdx);
	for(UBYTE ubPlep = 0; ubPlep < PLEPS_PER_PLAYER; ++ubPlep) {
		plepReset(&pPlayer->pPleps[ubPlep], pPlayer);
	}
	logWrite(
		"Player %d start pos: %hhu,%hhu\n",
		eIdx, pStartNode->sPosTile.ubX, pStartNode->sPosTile.ubY
	);
	playerSetCursorPos(pPlayer, pStartNode);
	pPlayer->isSelectingDestination = 0;
	pPlayer->pSteer = gameGetSteerForPlayer(eIdx);
	pPlayer->isDead = 0;
	pPlayer->bNodeCount = 0;
	pPlayer->pNodeTypeCounts[NODE_TYPE_NORMAL] = 0;
	pPlayer->pNodeTypeCounts[NODE_TYPE_SUPER_CAP] = 0;
	pPlayer->pNodeTypeCounts[NODE_TYPE_SUPER_TICK] = 0;
	pPlayer->pNodeTypeCounts[NODE_TYPE_SUPER_ATK] = 0;
	pPlayer->ulRepeatCounter = timerGet();
	pPlayer->pTeamMate = 0;

	for(UBYTE ubPlep = 0; ubPlep < PLEPS_PER_PLAYER; ++ubPlep) {
		plepInitBob(&pPlayer->pPleps[ubPlep]);
	}
}

tPlayer *playerFromTile(tTile eTile) {
	tPlayer *pPlayer = 0;
	switch(eTile) {
		case TILE_BLOB_P1:
		case TILE_SUPER_CAP_P1:
		case TILE_SUPER_TICK_P1:
		case TILE_SUPER_ATK_P1:
			pPlayer = &s_pPlayers[PLAYER_1];
			break;
		case TILE_BLOB_P2:
		case TILE_SUPER_CAP_P2:
		case TILE_SUPER_TICK_P2:
		case TILE_SUPER_ATK_P2:
			pPlayer = &s_pPlayers[PLAYER_2];
			break;
		case TILE_BLOB_P3:
		case TILE_SUPER_CAP_P3:
		case TILE_SUPER_TICK_P3:
		case TILE_SUPER_ATK_P3:
			pPlayer = &s_pPlayers[PLAYER_3];
			break;
		case TILE_BLOB_P4:
		case TILE_SUPER_CAP_P4:
		case TILE_SUPER_TICK_P4:
		case TILE_SUPER_ATK_P4:
			pPlayer = &s_pPlayers[PLAYER_4];
			break;
		default:
			pPlayer = 0;
	}
	return pPlayer;
}

tPlayerIdx playerToIdx(const tPlayer *pPlayer) {
	tPlayerIdx eIdx = PLAYER_NONE;
	if(pPlayer) {
		eIdx = pPlayer - &s_pPlayers[0];
	}
	return eIdx;
}

tPlayerIdx playerIdxFromTile(tTile eTile) {
	while(eTile > TILE_BLOB_NEUTRAL) {
		eTile -= TILE_BLOB_NEUTRAL + 1;
	}
	return (tPlayerIdx)eTile;
}

tPlayer *playerFromIdx(tPlayerIdx eIdx) {
	tPlayer *pPlayer = 0;
	if(eIdx != PLAYER_NONE) {
		pPlayer = &s_pPlayers[eIdx];
	}
	return pPlayer;
}

UBYTE playerProcess(void) {
	for(UBYTE i = 0; i < PLAYER_COUNT_MAX; ++i) {
		s_pCursorFields[i].ubCursorCount = 0;
		s_pCursorFields[i].sPosTile.uwYX = 0;
	}

	UBYTE ubAliveCount = 0;
	for(UBYTE i = 0; i < PLAYER_COUNT_MAX; ++i) {
		tPlayer *pPlayer = &s_pPlayers[i];
		if(pPlayer->isDead) {
			continue;
		}
		++ubAliveCount;

		steerProcess(pPlayer->pSteer);

		if(
			steerDirUse(pPlayer->pSteer, DIRECTION_FIRE) &&
			pPlayer->pNodeCursor->pPlayer == pPlayer
		) {
			// Pressed fire button - setup targeting mode
			pPlayer->pNodePlepSrc = pPlayer->pNodeCursor;
			pPlayer->isSelectingDestination = 1;
			ptplayerSfxPlay(g_pSfxPlep1, 3, PTPLAYER_VOLUME_MAX, 1);
		}
		else if(steerDirCheck(pPlayer->pSteer, DIRECTION_FIRE)) {
			if(pPlayer->isSelectingDestination) {
				// Holding fire button - process targeting mode
				tDirection eDir = steerGetPressedDir(pPlayer->pSteer);
				if(steerDirUse(pPlayer->pSteer, eDir) && playerSpawnPlep(pPlayer, eDir)) {
					ptplayerSfxPlay(g_pSfxPlep2, 3, PTPLAYER_VOLUME_MAX, 2);
				}
			}
		}
		else {
			// Released fire button - clean up targeting mode
			pPlayer->isSelectingDestination = 0;

			// Process regular navigation
			tDirection eDir = steerGetPressedDir(pPlayer->pSteer);
			if(eDir != DIRECTION_COUNT && pPlayer->pNodeCursor->pNeighbors[eDir]) {
				// Direction button pressed - check if first time or is it repeat
				ULONG ulNow = timerGet();
				UBYTE isRepeat = timerGetDelta(pPlayer->ulRepeatCounter, ulNow) >= 10;
				if(
					steerDirUse(pPlayer->pSteer, eDir) ||
					(isRepeat && steerDirCheck(pPlayer->pSteer, eDir))
				) {
					playerSetCursorPos(pPlayer, pPlayer->pNodeCursor->pNeighbors[eDir]);
					pPlayer->ulRepeatCounter = ulNow;
				}
			}
		}

		for(UBYTE i = 0; i < PLEPS_PER_PLAYER; ++i) {
			if(pPlayer->pPleps[i].isActive) {
				plepProcess(&pPlayer->pPleps[i]);
			}
		}

		tCursorField *pField;
		for(
			pField = &s_pCursorFields[0];
			pField < &s_pCursorFields[PLAYER_COUNT_MAX - 1]; ++pField
		) {
			if(pField->sPosTile.uwYX == 0) {
				pField->sPosTile.uwYX = pPlayer->pNodeCursor->sPosTile.uwYX;
				break;
			}
			if(pField->sPosTile.uwYX == pPlayer->pNodeCursor->sPosTile.uwYX) {
				break;
			}
		}
		pField->pBobs[pField->ubCursorCount++] = pPlayer->pBobCursor;
	}
	return ubAliveCount;
}

void playerUpdateDead(tPlayer *pPlayer) {
	// Check if player has some blobs or is dead already
	logWrite("playerUpdateDead: %p (%d) has %hhd blobs\n", pPlayer, playerToIdx(pPlayer), pPlayer->bNodeCount);
	if(pPlayer->isDead || pPlayer->bNodeCount > 0) {
		return;
	}

	// Check if player has any plep
	for(UBYTE i = 0; i < PLEPS_PER_PLAYER; ++i) {
		if(pPlayer->pPleps[i].isActive) {
			logWrite("has active pleps!\n");
			return;
		}
	}

	// Nothing more to check - player is dead
	logWrite("yep he ded\n");
	pPlayer->isDead = 1;
}

void playerAllDead(void) {
	for(UBYTE i = 0; i < PLAYER_COUNT_MAX; ++i) {
		s_pPlayers[i].isDead = 1;
	}
}

#define CURSOR_TICK_MAX 40

void playerPushCursors(void) {
	static const UBYTE pTickLimitsDivided[] = {
		CURSOR_TICK_MAX, CURSOR_TICK_MAX / 1, CURSOR_TICK_MAX / 2,
		CURSOR_TICK_MAX / 3, CURSOR_TICK_MAX / 4
	};
	for(
		tCursorField *pField = &s_pCursorFields[0];
		pField < &s_pCursorFields[4]; ++pField
	) {
		if(pField->ubCursorCount) {
			UBYTE ubTickLimit = pTickLimitsDivided[pField->ubCursorCount];
			if(++pField->ubFrameCounter >= ubTickLimit) {
				++pField->ubCurrentCursor;
				pField->ubFrameCounter = 0;
			}
			if(pField->ubCurrentCursor >= pField->ubCursorCount) {
				// Last cursor on field is drawn - restart displaying
				// This may also be the case when one of cursors leaves the area
				pField->ubCurrentCursor = 0;
			}
			bobNewPush(pField->pBobs[pField->ubCurrentCursor]);
		}
	}
}

UBYTE playerHasFreePlep(const tPlayer *pPlayer) {
	for(UBYTE i = 0; i < PLEPS_PER_PLAYER; ++i) {
		if(!pPlayer->pPleps[i].isActive) {
			return 1;
		}
	}
	return 0;
}
