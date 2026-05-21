/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#include "plep.h"

//---------------------------------------------------------------------- DEFINES

#define PLEP_SIZE 16

//----------------------------------------------------------------- PRIVATE VARS

static tBitMap *s_pBmPleps[4][4];
static tBitMap *s_pBmPlepMasks[4];

// For right direction, left must have sign reversed
static const BYTE s_pAnimOffsets[] = {
	6, 7, 9, 11, // Born
	-5, -4, -2, 0, 2, 4, 6, 10, // Move
	-5, -3, 0, 4, // Win
	-5, -2, 0, 1, 2, 3, 4, 5 // Lose
};

static const UBYTE s_pAnimFrameStart[PLEP_ANIM_COUNT] = {0, 4, 12, 16};
static const UBYTE s_pAnimFrameEnd[PLEP_ANIM_COUNT] = {3, 11, 15, 23};
static const tBCoordYX s_pPlepMoveDelta[4] = {
	[DIRECTION_UP] = {.bX = 0, .bY = -16},
	[DIRECTION_DOWN] = {.bX = 0, .bY = 16},
	[DIRECTION_LEFT] = {.bX = -16, .bY = 0},
	[DIRECTION_RIGHT] = {.bX = 16, .bY = 0},
};

//------------------------------------------------------------------ PRIVATE FNS

static UBYTE plepSinkInNode(tPlep *pPlep) {
	tNode *pNode = pPlep->pDestination;
	UBYTE isCaptureSuccess = 0;
	if(pNode->pPlayer == pPlep->pPlayer || (
		pNode->pPlayer && pNode->pPlayer == pPlep->pPlayer->pTeamMate
	)) {
		// logWrite("Power up! %hd %hd\n", pNode->wCharges, pPlep->wCharges);
		// Power up blob with plep's charges
		pNode->wCharges = MIN(pNode->wCharges + pPlep->wCharges, 999);
		isCaptureSuccess = 1;
	}
	else {
		// logWrite("Attacking blob %hd with plep %hd\n", pNode->wCharges, pPlep->wCharges);
		// Attack with plep's charges! Attack bonus only helps in bringing to neutral
		UBYTE ubPower = pPlep->pPlayer->pMods->ubPower;
		WORD wDefenderCharges = pNode->wCharges;
		pNode->wCharges -= pPlep->wCharges + ubPower;
		if(pNode->wCharges <= 0) {
			// Negative charge - omit power bonus and check if blob is really captured
			if(wDefenderCharges >= pPlep->wCharges) {
				// Blob alone is stronger than plep -> make it neutral
				pNode->wCharges = 0;
				if(pNode->pPlayer) {
					// logWrite("Draw! To neutral\n");
					nodeChangeOwnership(pNode, 0);
					// TODO: if player is selecting from that blob, remove selection - test it!
				}
			}
			else {
				// Blob captured
				pNode->wCharges = -pNode->wCharges;
				nodeChangeOwnership(pNode, pPlep->pPlayer);
				isCaptureSuccess = 1;
				// logWrite("Capture! %hd\n", pNode->wCharges);
			}
		}
	}

	// Plep capture / power up failed
	return isCaptureSuccess;
}

//------------------------------------------------------------------- PUBLIC FNS

void plepCreate(void) {
	logBlockBegin("plepCreate()");
	static const char *szDirNames[] = {"up", "down", "left", "right"};
	for(UBYTE ubDir = 0; ubDir < 4; ++ubDir) {
		char szName[30];
		for(UBYTE ubPlayer = 0; ubPlayer < 4; ++ubPlayer) {
			sprintf(szName, "data/plep%hhu_%s.bm", ubPlayer, szDirNames[ubDir]);
			s_pBmPleps[ubPlayer][ubDir] = bitmapCreateFromFile(szName, 0);
		}
		sprintf(szName, "data/plep_%s_mask.bm", szDirNames[ubDir]);
		s_pBmPlepMasks[ubDir] = bitmapCreateFromFile(szName, 0);
	}
	logBlockEnd("plepCreate()");
}

void plepInitBob(tPlep *pPlep) {
	bobNewInit(
		&pPlep->sBob, PLEP_SIZE, PLEP_SIZE, 1,
		s_pBmPleps[0][0], s_pBmPlepMasks[0], 0, 0
	);
}

void plepDestroy(void) {
	logBlockBegin("plepDestroy()");
	for(UBYTE ubDir = 0; ubDir < 4; ++ubDir) {
		for(UBYTE ubPlayer = 0; ubPlayer < 4; ++ubPlayer) {
			bitmapDestroy(s_pBmPleps[ubPlayer][ubDir]);
		}
		bitmapDestroy(s_pBmPlepMasks[ubDir]);
	}
	logBlockEnd("plepDestroy()");
}

void plepReset(tPlep *pPlep, tPlayer *pPlayer) {
	pPlep->isActive = 0;
	pPlep->pPlayer = pPlayer;
}

static void plepUpdateAnimFrame(tPlep *pPlep) {
	BYTE bDelta = s_pAnimOffsets[pPlep->ubAnimFrame];
	if(dirIsVertical(pPlep->eDir)) {
		if(pPlep->eDir == DIRECTION_UP) {
			bDelta = -bDelta;
		}
		pPlep->sBob.sPos.uwX = pPlep->sAnimAnchor.uwX;
		pPlep->sBob.sPos.uwY = pPlep->sAnimAnchor.uwY + bDelta;
	}
	else {
		if(pPlep->eDir == DIRECTION_LEFT) {
			bDelta = -bDelta;
		}
		pPlep->sBob.sPos.uwX = pPlep->sAnimAnchor.uwX + bDelta;
		pPlep->sBob.sPos.uwY = pPlep->sAnimAnchor.uwY;
	}
	bobNewSetBitMapOffset(&pPlep->sBob, pPlep->ubAnimFrame * 16);
}

void plepProcess(tPlep *pPlep) {
	if(!pPlep->isActive) {
		return;
	}

	if(++pPlep->ubAnimTick >= 5) {
		if(pPlep->ubAnimFrame >= s_pAnimFrameEnd[pPlep->eAnim]) {
			// end of anim
			// logWrite(
			// 	"End of anim %d (%hu,%hu dir %d)\n",
			// 	pPlep->eAnim, pPlep->sAnimAnchor.uwX, pPlep->sAnimAnchor.uwY, pPlep->eDir
			// );
			switch(pPlep->eAnim) {
				case PLEP_ANIM_BORN:
				case PLEP_ANIM_MOVE:
					pPlep->sAnimAnchor.uwX += s_pPlepMoveDelta[pPlep->eDir].bX;
					pPlep->sAnimAnchor.uwY += s_pPlepMoveDelta[pPlep->eDir].bY;
					tTile eNextTile = g_sMapData.pTiles[pPlep->sAnimAnchor.uwX / 16][pPlep->sAnimAnchor.uwY / 16];
					if(eNextTile >= TILE_BLOB_COUNT) {
						// We're at non-blob tile
						pPlep->eAnim = PLEP_ANIM_MOVE;
					}
					else {
						// We're at blob tile - win or lose against blob
						if(plepSinkInNode(pPlep)) {
							pPlep->eAnim = PLEP_ANIM_WIN;
						}
						else {
							pPlep->eAnim = PLEP_ANIM_LOSE;
						}
					}
					break;
				case PLEP_ANIM_WIN:
				case PLEP_ANIM_LOSE:
				default:
					// end of anim - end of plep
					pPlep->isActive = 0;
					playerUpdateDead(pPlep->pPlayer);
					break;
			}
			pPlep->sBob.pBitmap = s_pBmPleps[playerToIdx(pPlep->pPlayer)][pPlep->eDir];
			pPlep->sBob.pMask = s_pBmPlepMasks[pPlep->eDir];
			pPlep->ubAnimFrame = s_pAnimFrameStart[pPlep->eAnim];
			// logWrite(
			// 	"Next anim: %d (%hu,%hu), active: %hhu\n",
			// 	pPlep->eAnim, pPlep->sAnimAnchor.uwX, pPlep->sAnimAnchor.uwY, pPlep->isActive
			// );
		}
		// Advance frame & anim
		plepUpdateAnimFrame(pPlep);
		++pPlep->ubAnimFrame;
		pPlep->ubAnimTick = 0;
	}
	if(pPlep->isActive) {
		bobNewPush(&pPlep->sBob); // No bob changing past this point
	}
	// gameDumpFrame();
}

void plepSpawn(tPlep *pPlep, WORD wCharges, tDirection eDir) {
	const tNode *pSrc = pPlep->pPlayer->pNodePlepSrc;
	pPlep->pDestination = pSrc->pNeighbors[eDir];
	pPlep->isActive = 1;
	pPlep->wCharges = wCharges;
	pPlep->sBob.sPos.uwX = pSrc->sPosTile.ubX * MAP_TILE_SIZE;
	pPlep->sBob.sPos.uwY = pSrc->sPosTile.ubY * MAP_TILE_SIZE;
	pPlep->eDir = eDir;

	// Init anim
	pPlep->eAnim = PLEP_ANIM_BORN;
	pPlep->sBob.pBitmap = s_pBmPleps[playerToIdx(pPlep->pPlayer)][pPlep->eDir];
	pPlep->sBob.pMask = s_pBmPlepMasks[pPlep->eDir];
	pPlep->ubAnimFrame = s_pAnimFrameStart[pPlep->eAnim];
	pPlep->ubAnimTick = 0;
	pPlep->sAnimAnchor.uwX = pSrc->sPosTile.ubX * MAP_TILE_SIZE;
	pPlep->sAnimAnchor.uwY = pSrc->sPosTile.ubY * MAP_TILE_SIZE;
	plepUpdateAnimFrame(pPlep);

	bobNewSetBitMapOffset(&pPlep->sBob, 0);
}
