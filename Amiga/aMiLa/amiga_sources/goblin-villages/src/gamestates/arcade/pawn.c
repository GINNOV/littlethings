#include "pawn.h"

/* Globals */
struct BitMap *g_pPawnsBitMap;
UWORD *s_pPawnMask;

/* Functions */
void pawnCreate(void) {
	// wczytanie pionków
	g_pPawnsBitMap = bitmapCreateFromFile("data/bitmaps/pawns.bm");
	s_pPawnMask = allocChip(80*sizeof(UWORD));

	FILE *pFile = fopen("data/pawns.msk", "rb");
	fread(s_pPawnMask, 80, sizeof(UWORD), pFile);
	fclose(pFile);

	// init listy pionów
	g_sGameConfig.ubPawnCount = 0;
	g_sGameConfig.pPawnFirst = 0;
}

void pawnDestroy(void) {
	freeMem(s_pPawnMask, 160);
	bitmapDestroy(g_pPawnsBitMap);
	tPawn *pPawn = g_sGameConfig.pPawnFirst;
	tPawn *pNext;
	// while(pPawn) {
		// pNext = pPawn->pNext;
		// freeMem(pPawn, sizeof(tPawn));
		// pPawn = pNext;
	// }
	// g_sGameConfig.pPawnFirst = 0;
	while (g_sGameConfig.ubPawnCount) {
		pawnRemove(g_sGameConfig.pPawnFirst);
	}
}

UBYTE pawnIsPlaceable(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx) {
	// Próba postawienia nie na najœwie¿szym kaflu
	if ((g_sLastTileCoord.uwX != uwTileX) || (g_sLastTileCoord.uwY != uwTileY)) {
		return 0;
	}
	// Próba postawienia na naro¿ach
	if (((ubLogicDataIdx & 1) == 0) && ubLogicDataIdx != 4) {
		return 0;
	}
	// Próba postawienia na trawie
	if (g_pTileDefs[g_pTileBuffer->pTileData[uwTileX][uwTileY]].pLogicData[ubLogicDataIdx] == LOGIC_GRASS) {
		return 0;
	}
	// Próba postawienia na cudzej konstrukcji
	if (logicIsStructureOccupied(uwTileX, uwTileY, ubLogicDataIdx)) {
		return 0;
	}

	return 1;
}

void pawnPlace(UWORD uwTileX, UWORD uwTileY, UBYTE ubLogicDataIdx, tPlayer *pPlayer) {
	tPawn *pPawn = allocFastFirst(sizeof(tPawn));
	logWrite("Created pawn @addr: %p\n", pPawn);
	pPawn->sTileCoord.uwX = uwTileX;
	pPawn->sTileCoord.uwY = uwTileY;
	pPawn->ubLogicDataIdx = ubLogicDataIdx;
	pPawn->pPlayer = pPlayer;
	pPawn->pPrev = 0;
	pPawn->pNext = g_sGameConfig.pPawnFirst;

	if (g_sGameConfig.pPawnFirst) {
		g_sGameConfig.pPawnFirst->pPrev = pPawn;
	}
	g_sGameConfig.pPawnFirst = pPawn;

	++g_sGameConfig.ubPawnCount;
	--pPlayer->ubPawnsLeft;
	logWrite("Placed pawn @logicIdx %u on tile %ux%u\n", ubLogicDataIdx, uwTileX, uwTileY);

	UWORD uwTileOffsX = (uwTileX * g_pTileBuffer->ubTileSize) % ((g_pTileBuffer->ubTileSize * 4) + WINDOW_SCREEN_WIDTH);
	UWORD uwTileOffsY = (uwTileY * g_pTileBuffer->ubTileSize) % g_pTileBuffer->pScrollManager->uwBmAvailHeight;
	UBYTE ubAddY = (uwTileX * g_pTileBuffer->ubTileSize) / ((g_pTileBuffer->ubTileSize * 4) + WINDOW_SCREEN_WIDTH);

	blitCopyMask(
		g_pPawnsBitMap, 0, g_pCurrPlayer->ubIdx * 10,
		g_pTileBuffer->pVPort->sVPort.RasInfo->BitMap,
		uwTileOffsX + (10 * (ubLogicDataIdx % 3)) + 1,
		uwTileOffsY + ubAddY + (10 * (ubLogicDataIdx / 3)) + 1,
		10, 10,
		s_pPawnMask
	);
}

void pawnRemove(tPawn *pPawn) {
	if (pPawn->pPrev) {
		pPawn->pPrev->pNext = pPawn->pNext;
	}
	else {
		g_sGameConfig.pPawnFirst = pPawn->pNext;
	}

	if (pPawn->pNext) {
		pPawn->pNext->pPrev = pPawn->pPrev;
	}

	--g_sGameConfig.ubPawnCount;
	++pPawn->pPlayer->ubPawnsLeft;

	logWrite("Freed pawn @addr: %p", pPawn);
	freeMem(pPawn, sizeof(tPawn));
}

void pawnRedrawCallback(UWORD uwTileX, UWORD uwTileY, struct BitMap *pBmDest, UWORD uwBitMapX, UWORD uwBitMapY) {
	if (!g_pTileBuffer->pTileData[uwTileX][uwTileY]) {
		return; // ANTYMU£: nie rób nic jeœli kafel jest zerowy
	}

	tPawn *pPawn = g_sGameConfig.pPawnFirst;
	while (pPawn) {
		if ((pPawn->sTileCoord.uwX == uwTileX) && (pPawn->sTileCoord.uwY == uwTileY)) {
			blitCopyMask(
				g_pPawnsBitMap, 0, pPawn->pPlayer->ubIdx * 10,
				g_pTileBuffer->pVPort->sVPort.RasInfo->BitMap,
				uwBitMapX + (10 * (pPawn->ubLogicDataIdx % 3)) + 1,
				uwBitMapY + (10 * (pPawn->ubLogicDataIdx / 3)) + 1,
				10, 10,
				s_pPawnMask
			);

			// return; // wcale nie return bo nie tylko 1 pawn per kafel
		}

		pPawn = pPawn->pNext;
	}
}