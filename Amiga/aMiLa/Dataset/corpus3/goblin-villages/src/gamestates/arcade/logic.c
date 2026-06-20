#include "logic.h"

/* Globals */
tLogicList g_sLogicList;
BYTE g_pLogicTileDirs[LOGIC_TILE_DIRS][2] = {
	{-1, -1}, {0, -1}, {1, -1},
	{-1,  0}, {0,  0}, {1,  0},
	{-1,  1}, {0,  1}, {1,  1}
};

/* Functions */
void logicListCreate(void) {
	g_sLogicList.pItems = allocFastFirstClear(sizeof(tLogicListItem) * g_sTileList.uwLength * 5);
	g_sLogicList.uwPos = 0;
	g_sLogicList.uwLength = g_sTileList.uwLength;
}

void logicListDestroy(void) {
	freeMem(g_sLogicList.pItems, sizeof(tLogicListItem) * g_sLogicList.uwLength * 5);
}

void logicCountPoints(void) {
	UBYTE ubTileLogicDataIdx = 9;

	while (ubTileLogicDataIdx--) {
		/* TODO
			pVisitedLogicIdx = tablica, która pamiêta logicDataIdx lastTile'a
			by nie triggerowaæ na nich crawlera
			jest w logicList
		*/
		switch (g_pTileDefs[g_pTileBuffer->pTileData[g_sLastTileCoord.uwX][g_sLastTileCoord.uwY]].pLogicData[ubTileLogicDataIdx]) {
			case LOGIC_ROAD:
				logWrite("Crawling ROAD at %dx%d:%d\n", g_sLastTileCoord.uwX, g_sLastTileCoord.uwY, ubTileLogicDataIdx);
				logicWalkRoad(g_sLastTileCoord.uwX, g_sLastTileCoord.uwY, ubTileLogicDataIdx);
				break;
			case LOGIC_VILLAGE:
				logWrite("Crawling VILLAGE at %dx%d:%d\n", g_sLastTileCoord.uwX, g_sLastTileCoord.uwY, ubTileLogicDataIdx);
				logicWalkVillage(g_sLastTileCoord.uwX, g_sLastTileCoord.uwY, ubTileLogicDataIdx);
				break;
			default:
				logWrite("Crawling NOTHING at %dx%d:%d\n", g_sLastTileCoord.uwX, g_sLastTileCoord.uwY, ubTileLogicDataIdx);
				continue;
		}

		logicSumWalkerResults();
	}

	// case LOGIC_SWAMP:
	UWORD uwX, uwY;

	ubTileLogicDataIdx = LOGIC_TILE_DIRS;
	while (ubTileLogicDataIdx--) {
		uwX = g_sLastTileCoord.uwX + g_pLogicTileDirs[ubTileLogicDataIdx][0];
		uwY = g_sLastTileCoord.uwY + g_pLogicTileDirs[ubTileLogicDataIdx][1];

		if (g_pTileDefs[g_pTileBuffer->pTileData[uwX][uwY]].pLogicData[4] == LOGIC_SWAMP) {
			logWrite("Crawling SWAMP at %dx%d:%d\n", uwX, uwY, 4);
			logicWalkSwamp(uwX, uwY, 4);
			logicSumWalkerResults();
		}
	}
}

void logicSumWalkerResults(void) {
	if (g_sLogicList.ubClosed) {
		logWrite("Structure closed\n");
		UBYTE pPlayerPawnsCount[PLAYER_COUNT] = {0};

		UWORD uwItem = g_sLogicList.uwPos;
		while (uwItem--) {
			tPawn *pPawn = g_sGameConfig.pPawnFirst;
			while (pPawn) {
				if (coordEqual(pPawn->sTileCoord, g_sLogicList.pItems[uwItem].sTileCoord) && (pPawn->ubLogicDataIdx == g_sLogicList.pItems[uwItem].ubLogicDataIdx)) {
					++pPlayerPawnsCount[pPawn->pPlayer->ubIdx];

					pawnRemove(pPawn);
				}

				pPawn = pPawn->pNext;
			}
		}

		logWrite("Structure unzipped %d\n", g_sLogicList.uwPos);
		logicListMakeDistinct();
		logWrite("Structure zipped to %d\n", g_sLogicList.uwPos);

		logicAssignPoints(pPlayerPawnsCount);

		uwItem = g_sLogicList.uwPos;
		while (uwItem--) {
			tileBufferDrawXY(g_pTileBuffer, g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY);
		}
	}
	else {
		logWrite("Structure still open with dataidx count %d\n", g_sLogicList.uwPos);
	}
}

void logicAssignPoints(UBYTE *pPlayerPawnsCount) {
	UBYTE ubPawnLimit = 0;
	logWrite("Counting pawnlimit\n");

	tPlayer *pPlayer = g_sGameConfig.pPlayerFirst;
	while (pPlayer) {
		if (ubPawnLimit < pPlayerPawnsCount[pPlayer->ubIdx]) {
			ubPawnLimit = pPlayerPawnsCount[pPlayer->ubIdx];
		}

		pPlayer = pPlayer->pNext;
	}

	if (ubPawnLimit) {
		UWORD uwScore = 0;
		logWrite("pawnlimit %d\n", ubPawnLimit);

		switch (g_sLogicList.ubType) {
			case LOGIC_ROAD:
			case LOGIC_SWAMP:
				uwScore = g_sLogicList.uwPos * 1;
				break;
			case LOGIC_VILLAGE:
				uwScore = g_sLogicList.uwPos * 2;
				break;
		}

		logWrite("score %d\n", uwScore);

		pPlayer = g_sGameConfig.pPlayerFirst;
		while (pPlayer) {
			if (pPlayerPawnsCount[pPlayer->ubIdx] == ubPawnLimit) {
				pPlayer->uwScore += uwScore;
				logWrite("player %d got scored\n", pPlayer->uwScore);
			}

			pPlayer = pPlayer->pNext;
		}
	}
}

UBYTE logicIsStructureOccupied(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx) {
	g_sLogicList.uwPos = 0;

	switch (g_pTileDefs[g_pTileBuffer->pTileData[uwTileX][uwTileY]].pLogicData[ubLogicDataIdx]) {
		case LOGIC_ROAD:
			logicWalkRoad(uwTileX, uwTileY, ubLogicDataIdx);
			break;
		case LOGIC_VILLAGE:
			logicWalkVillage(uwTileX, uwTileY, ubLogicDataIdx);
			break;
	}

	if (g_sLogicList.uwPos) {
		UBYTE ubPawn;
		UBYTE ubPlayer;


		UWORD uwItem = g_sLogicList.uwPos;
		while (uwItem--) {
			tPawn *pPawn = g_sGameConfig.pPawnFirst;
			while (pPawn) {
				if (coordEqual(pPawn->sTileCoord, g_sLogicList.pItems[uwItem].sTileCoord) && (pPawn->ubLogicDataIdx == g_sLogicList.pItems[uwItem].ubLogicDataIdx)) {
					return 1;
				}

				pPawn = pPawn->pNext;
			}
		}
	}

	return 0;
}

void logicListMakeDistinct(void) {
	UWORD uwDistinctPos = 0; 

	UWORD uwItem;
	for (uwItem = 0; uwItem < g_sLogicList.uwPos; ++uwItem) {
		UBYTE ubFound = 0;
		UWORD uwDistinctItem = uwDistinctPos;
		while (uwDistinctItem--) {
			if (coordEqual(g_sLogicList.pItems[uwItem].sTileCoord, g_sLogicList.pItems[uwDistinctItem].sTileCoord)) {
				ubFound = 1;
				break;
			}
		}

		if (!ubFound) {
			g_sLogicList.pItems[uwDistinctPos].sTileCoord.uwX = g_sLogicList.pItems[uwItem].sTileCoord.uwX;
			g_sLogicList.pItems[uwDistinctPos].sTileCoord.uwY = g_sLogicList.pItems[uwItem].sTileCoord.uwY;
			g_sLogicList.pItems[uwDistinctPos].ubLogicDataIdx = LOGIC_TILE_DIRS;

			++uwDistinctPos;
		}
	}

	g_sLogicList.uwPos = uwDistinctPos;
}

void logicWalkMakeStep(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx) {
	UWORD uwItem = g_sLogicList.uwPos;
	while (uwItem--) {
		if ((g_sLogicList.pItems[uwItem].sTileCoord.uwX == uwTileX) && (g_sLogicList.pItems[uwItem].sTileCoord.uwY == uwTileY) && (g_sLogicList.pItems[uwItem].ubLogicDataIdx == ubLogicDataIdx)) {
			return;
		}
	}

	g_sLogicList.pItems[g_sLogicList.uwPos].sTileCoord.uwX = uwTileX;
	g_sLogicList.pItems[g_sLogicList.uwPos].sTileCoord.uwY = uwTileY;
	g_sLogicList.pItems[g_sLogicList.uwPos].ubLogicDataIdx = ubLogicDataIdx;

	++g_sLogicList.uwPos;
}

void logicWalkRoad(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx) {
	g_sLogicList.uwPos = 0;
	g_sLogicList.ubClosed = 1;
	g_sLogicList.ubType = LOGIC_ROAD;

	logicWalkMakeStep(uwTileX, uwTileY, ubLogicDataIdx);

	UBYTE ubTileIdx;
	UWORD uwItem = 0;
	do {
		switch (g_sLogicList.pItems[uwItem].ubLogicDataIdx) {
			case 1:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY - 1];
				if (ubTileIdx && (g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_ROAD)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY - 1, 7);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];
				if (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}
				break;
			case 3:
				if ((ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX - 1][g_sLogicList.pItems[uwItem].sTileCoord.uwY]) && (g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_ROAD)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX - 1, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 5);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];
				if (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}
				break;
			case 4:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];

				if (g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 1);
				}

				if (g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 3);
				}

				if (g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 5);
				}

				if (g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 7);
				}
				break;
			case 5:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX + 1][g_sLogicList.pItems[uwItem].sTileCoord.uwY];;
				if (ubTileIdx && (g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_ROAD)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX + 1, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 3);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];
				if (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}
				break;
			case 7:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY + 1];
				if (ubTileIdx && (g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_ROAD)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY + 1, 1);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];
				if (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_ROAD) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}
				break;
		}
	} while (++uwItem < g_sLogicList.uwPos);
}

void logicWalkVillage(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx) {
	g_sLogicList.uwPos = 0;
	g_sLogicList.ubClosed = 1;
	g_sLogicList.ubType = LOGIC_VILLAGE;

	logicWalkMakeStep(uwTileX, uwTileY, ubLogicDataIdx);

	UBYTE ubTileIdx;
	UWORD uwItem = 0;
	do {
		switch (g_sLogicList.pItems[uwItem].ubLogicDataIdx) {
			case 1:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY - 1];
				if (ubTileIdx && ((g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY - 1, 7);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];

				if (((g_pTileDefs[ubTileIdx].pLogicData[0] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[0] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 3);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}

				if (((g_pTileDefs[ubTileIdx].pLogicData[2] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[2] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 5);
				}
				break;
			case 3:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX - 1][g_sLogicList.pItems[uwItem].sTileCoord.uwY];
				if (ubTileIdx && ((g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX - 1, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 5);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];

				if (((g_pTileDefs[ubTileIdx].pLogicData[0] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[0] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 1);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}

				if (((g_pTileDefs[ubTileIdx].pLogicData[6] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[6] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 7);
				}
				break;
			case 4:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];

				if ((g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 1);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 3);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 5);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 7);
				}
				break;
			case 5:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX + 1][g_sLogicList.pItems[uwItem].sTileCoord.uwY];
				if (ubTileIdx && ((g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX + 1, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 3);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];

				if (((g_pTileDefs[ubTileIdx].pLogicData[2] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[2] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 1);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}

				if (((g_pTileDefs[ubTileIdx].pLogicData[8] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[8] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[7] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 7);
				}
				break;
			case 7:
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY + 1];
				if (ubTileIdx && ((g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[1] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY + 1, 1);
				}
				else {
					g_sLogicList.ubClosed = 0;
				}
				
				ubTileIdx = g_pTileBuffer->pTileData[g_sLogicList.pItems[uwItem].sTileCoord.uwX][g_sLogicList.pItems[uwItem].sTileCoord.uwY];

				if (((g_pTileDefs[ubTileIdx].pLogicData[6] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[6] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[3] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 3);
				}

				if ((g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[4] == LOGIC_BONUS)) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 4);
				}

				if (((g_pTileDefs[ubTileIdx].pLogicData[8] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[8] == LOGIC_BONUS)) && ((g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_VILLAGE) || (g_pTileDefs[ubTileIdx].pLogicData[5] == LOGIC_BONUS))) {
					logicWalkMakeStep(g_sLogicList.pItems[uwItem].sTileCoord.uwX, g_sLogicList.pItems[uwItem].sTileCoord.uwY, 5);
				}
				break;
		}
	} while (++uwItem < g_sLogicList.uwPos);
}

void logicWalkSwamp(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx) {
	g_sLogicList.uwPos = 0;
	g_sLogicList.ubClosed = 1;
	g_sLogicList.ubType = LOGIC_SWAMP;

	logicWalkMakeStep(uwTileX, uwTileY, ubLogicDataIdx);

	if (g_pTileBuffer->pTileData[uwTileX - 1][uwTileY - 1]) {
		logicWalkMakeStep(uwTileX - 1, uwTileY - 1, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX][uwTileY - 1]) {
		logicWalkMakeStep(uwTileX, uwTileY - 1, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX + 1][uwTileY - 1]) {
		logicWalkMakeStep(uwTileX + 1, uwTileY - 1, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX - 1][uwTileY]) {
		logicWalkMakeStep(uwTileX - 1, uwTileY, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX + 1][uwTileY]) {
		logicWalkMakeStep(uwTileX + 1, uwTileY, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX - 1][uwTileY + 1]) {
		logicWalkMakeStep(uwTileX - 1, uwTileY + 1, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX][uwTileY + 1]) {
		logicWalkMakeStep(uwTileX, uwTileY + 1, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}

	if (g_pTileBuffer->pTileData[uwTileX + 1][uwTileY + 1]) {
		logicWalkMakeStep(uwTileX + 1, uwTileY + 1, LOGIC_TILE_DIRS);
	}
	else {
		g_sLogicList.ubClosed = 0;
	}
}