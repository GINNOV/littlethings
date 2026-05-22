#include "tile.h"

/* Globals */
tTile g_pTileDefs[TILE_VARIANTS];
tTileList g_sTileList;

/* Functions */
void tileStackCreate(void) {	
	FILE *pFile = fopen("data/tiles.dat", "rb");

	UWORD i;
	for (i = 0; i != TILE_VARIANTS; ++i) {
		fseek(pFile, 1, SEEK_CUR);
		fread(&g_pTileDefs[i].ubCount, 1, 1, pFile);
		fread(g_pTileDefs[i].pLogicData, 9, 1, pFile);
	}
	fclose(pFile);
	
	g_sTileList.uwPos = 0;
	g_sTileList.uwLength = TILE_VARIANTS;
	
	logWrite("tileStackCreate begin\n");
	logPushIndent();
	
	// zlicz kafle
	UBYTE ubTile;
	for (ubTile = 1; ubTile != TILE_TYPES; ++ubTile) {
		i = g_pTileDefs[ubTile].ubCount;
		while (i--) {
			++g_sTileList.uwPos;
		}
	}
	g_sTileList.uwLength = g_sTileList.uwPos;
	logWrite("Tile stack size: %u\n", g_sTileList.uwLength);
	g_sTileList.pTileIdx = allocFastFirst(g_sTileList.uwLength);
	
	// generuj stos bez szuflowania
	g_sTileList.uwPos = 0;
	for (ubTile = 1; ubTile != TILE_TYPES; ++ubTile) {
		// logWrite("Tile: %u, count: %u\n", ubTile, g_pTileDefs[ubTile].ubCount);
		i = g_pTileDefs[ubTile].ubCount;
		while (i--) {
			g_sTileList.pTileIdx[g_sTileList.uwPos] = ubTile + ubRandMinMax(0, 3) * TILE_TYPES;
			// logWrite("Stack %u: %u\n", g_sTileList.uwPos, g_sTileList.pTileIdx[g_sTileList.uwPos]);
			++g_sTileList.uwPos;
		}
	}
	
	// poszufluj
	for (g_sTileList.uwPos = 0; g_sTileList.uwPos != g_sTileList.uwLength - 1; ++g_sTileList.uwPos) {
		// indeks dalszego kafla do zamiany
		i = uwRandMinMax(g_sTileList.uwPos + 1, g_sTileList.uwLength - 1);
		// swap wartoœci
		ubTile = g_sTileList.pTileIdx[g_sTileList.uwPos];
		g_sTileList.pTileIdx[g_sTileList.uwPos] = g_sTileList.pTileIdx[i];
		g_sTileList.pTileIdx[i] = ubTile;
	}
	
	g_sTileList.uwPos = 0;
	
	logPopIndent();
	logWrite("tileStackCreate destroy\n");
}

void tileStackDestroy(void) {
	freeMem(g_sTileList.pTileIdx, g_sTileList.uwLength);
	g_sTileList.uwLength = 0;
	g_sTileList.uwPos = 0;
}

UBYTE tileIsPlaceable(UWORD uwTileX, UWORD uwTileY, tTile *pTile) {
	// Bounds
	if (!uwTileX || !uwTileY || (g_pTileBuffer->sTileBounds.uwX - 1 <= uwTileX) || (g_pTileBuffer->sTileBounds.uwY - 1 <= uwTileY)) {
		return 0;
	}

	// Occupied
	if (g_pTileBuffer->pTileData[uwTileX][uwTileY]) {
		return 0;
	}

	// Neigbours
	if (!g_pTileBuffer->pTileData[uwTileX][uwTileY - 1] && !g_pTileBuffer->pTileData[uwTileX][uwTileY + 1] && !g_pTileBuffer->pTileData[uwTileX - 1][uwTileY] && !g_pTileBuffer->pTileData[uwTileX + 1][uwTileY]) {
		return 0;
	}

	// N
	if (g_pTileBuffer->pTileData[uwTileX][uwTileY - 1] && (g_pTileDefs[g_pTileBuffer->pTileData[uwTileX][uwTileY - 1]].pLogicData[7] != pTile->pLogicData[1])) {
		return 0;
	}

	// S
	if (g_pTileBuffer->pTileData[uwTileX][uwTileY + 1] && (g_pTileDefs[g_pTileBuffer->pTileData[uwTileX][uwTileY + 1]].pLogicData[1] != pTile->pLogicData[7])) {
		return 0;
	}

	// W
	if (g_pTileBuffer->pTileData[uwTileX - 1][uwTileY] && (g_pTileDefs[g_pTileBuffer->pTileData[uwTileX - 1][uwTileY]].pLogicData[5] != pTile->pLogicData[3])) {
		return 0;
	}

	// E
	if (g_pTileBuffer->pTileData[uwTileX + 1][uwTileY] && (g_pTileDefs[g_pTileBuffer->pTileData[uwTileX + 1][uwTileY]].pLogicData[3] != pTile->pLogicData[5])) {
		return 0;
	}

	return 1;
}

void tilePlace(UWORD uwTileX, UWORD uwTileY, tTile *pTile) {
	// wstaw kafel do tilemapy
	g_pTileBuffer->pTileData[uwTileX][uwTileY] = g_sTileList.pTileIdx[g_sTileList.uwPos];
	g_sLastTileCoord.uwX = uwTileX;
	g_sLastTileCoord.uwY = uwTileY;
	
	// odblituj kafel
	tileBufferDrawXY(g_pTileBuffer, uwTileX, uwTileY);
}

void tileRotate(void) {
	g_sTileList.pTileIdx[g_sTileList.uwPos] = (g_sTileList.pTileIdx[g_sTileList.uwPos] + TILE_TYPES) % TILE_VARIANTS;
	hudRedrawPlayer(g_pCurrPlayer);
}