#include "hud.h"

/* Globals */
static struct BitMap *g_pPawnsLarge;
tHudManager g_sHudManager;

/* Functions */
void hudCreate(tExtView *pExtView) {
	UBYTE i;

	g_sHudManager.pExtView = pExtView;
	g_sHudManager.pMainVPort = (tExtVPort*)pExtView->sView.ViewPort;
	g_sHudManager.pHudVPort = (tExtVPort*)g_sHudManager.pMainVPort->sVPort.Next;
	g_sHudManager.ubExpanded = 0;
	
	g_pPawnsLarge = bitmapCreateFromFile("data/bitmaps/pawnsLarge.bm");
	g_sHudManager.pRectBfr = rectCreateBfr(g_sHudManager.pHudVPort->sVPort.DWidth, 30, WINDOW_SCREEN_BPP);
	
	g_sHudManager.pPlayerCache = allocFastFirst(sizeof(tHudPlayerCache) * g_sGameConfig.ubPlayerCount);
	for (i = 0; i != g_sGameConfig.ubPlayerCount; ++i) {
		g_sHudManager.pPlayerCache[i].ubBgDrawn = 0;
	}
	
	hudRedrawAll();
	// TODO: zast¹piæ kodem mened¿era skrolingu
	g_sHudManager.pHudVPort->sVPort.RasInfo->RyOffset = 32 * g_pCurrPlayer->ubIdx;
	MakeVPort(&g_sHudManager.pExtView->sView, &g_sHudManager.pHudVPort->sVPort);
	WaitTOF();
}

void hudDestroy(void) {
	freeMem(g_sHudManager.pPlayerCache, sizeof(tHudPlayerCache) * g_sGameConfig.ubPlayerCount);
	bitmapDestroy(g_sHudManager.pRectBfr);
	bitmapDestroy(g_pPawnsLarge);
}

void hudRedrawAll(void) {
	UBYTE i;
	tPlayer *pPlayer;
	pPlayer = g_sGameConfig.pPlayerFirst;
	for (i = g_sGameConfig.ubPlayerCount; i--;) {
		hudRedrawPlayer(pPlayer);
		pPlayer = pPlayer->pNext;
	}
}

void hudRedrawPlayer(tPlayer *pPlayer) {
	char szBfr[128];
	UBYTE ubPlayerOffs;
	UBYTE ubBgFresh = 0;
	struct BitMap *pHudBitMap;
	
	pHudBitMap = g_sHudManager.pHudVPort->sVPort.RasInfo->BitMap;
	ubPlayerOffs = pPlayer->ubIdx * 32;
	
	if (!g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubBgDrawn) {
		// czyszczenie t³a
		rectFill(
			g_sHudManager.pRectBfr, pHudBitMap,
			0, ubPlayerOffs,
			g_sHudManager.pHudVPort->sVPort.DWidth, 30, g_pPlayerColors[pPlayer->ubIdx][1]
		);
		ubBgFresh = 1;
		// odrysowanie ryja
		blitCopy(
			g_pCharactersBitMap, ubPlayerOffs + 2, 32 + 2,
			pHudBitMap, 1, ubPlayerOffs + 1, 28, 28,
			MINTERM_COPY, 0xff
		);
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubBgDrawn = 1;
		// wymuszenie odrysowania reszty
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubTileErased = 0;
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubPrevPawns = 0xFF;
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].wPrevScore = -1;
	}
	
	if (g_sHudManager.pPlayerCache[pPlayer->ubIdx].wPrevScore != pPlayer->uwScore) {
		// odrysowanie t³a score'a
		if (!ubBgFresh) {
			rectFill(
				g_sHudManager.pRectBfr, pHudBitMap,
				35, ubPlayerOffs + 7,
				130, 15, g_pPlayerColors[pPlayer->ubIdx][1]
			);
		}
		// odrysowanie licznika score'a
		sprintf(szBfr, "Score: %u", pPlayer->uwScore);
		fontDrawStr(pHudBitMap, g_pFont, 35, ubPlayerOffs + 7, szBfr, COLOR_DRKGREEN, FONT_COOKIE | FONT_SHADOW);
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].wPrevScore = pPlayer->uwScore;
	}
	
	// odrysowanie t³a licznika pionów
	if (g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubPrevPawns != pPlayer->ubPawnsLeft) {
		if (!ubBgFresh) {
			rectFill(
				g_sHudManager.pRectBfr, pHudBitMap,
				165, ubPlayerOffs + 7,
				125, 15, g_pPlayerColors[pPlayer->ubIdx][1]
			);
		}
		// odrysowanie licznika pionów
		sprintf(szBfr, "Goblins: %hhu", pPlayer->ubPawnsLeft);
		fontDrawStr(pHudBitMap, g_pFont, 165, ubPlayerOffs + 7, szBfr, COLOR_DRKGREEN, FONT_COOKIE | FONT_SHADOW);
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubPrevPawns = pPlayer->ubPawnsLeft;
	}
	
	// odrysowanie kafla
	if (pPlayer == g_pCurrPlayer) {
		if (g_ubTurnStep == TURN_PAWN) {
			blitCopy(
				g_pPawnsLarge, 0, 28*pPlayer->ubIdx,
				g_sHudManager.pHudVPort->sVPort.RasInfo->BitMap, 291, pPlayer->ubIdx*32 + 1, 28, 28,
				MINTERM_COPY, 0xFF
			);
		}
		else if (g_ubTurnStep == TURN_TILE) {
			blitCopy(
				g_pTileBuffer->pTileSet, 2, 2 + g_sTileList.pTileIdx[g_sTileList.uwPos] * g_pTileBuffer->ubTileSize,
				pHudBitMap, 291, ubPlayerOffs + 1, 28, 28,
				MINTERM_COPY, 0xFF
			);
		}
	}
	else if (!g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubTileErased || !ubBgFresh) {
		rectFill(
			g_sHudManager.pRectBfr, pHudBitMap,
			291, ubPlayerOffs + 1,
			28, 28, g_pPlayerColors[pPlayer->ubIdx][1]
		);
	}
	else {
		g_sHudManager.pPlayerCache[pPlayer->ubIdx].ubTileErased = 1;
	}
}

void hudShowPlayer(tPlayer *pPlayer) {
	UBYTE steps[20] = {0, 3, 5, 7, 10, 12, 15, 17, 19, 21, 23, 24, 26, 27, 29, 30, 30, 31, 32, 32};
	UBYTE ubStart = g_sHudManager.pHudVPort->sVPort.RasInfo->RyOffset;
	UBYTE ubEnd = 32 * pPlayer->ubIdx;
	UBYTE i;
	
	for (i = 0; i != 20; ++i) {
		g_sHudManager.pHudVPort->sVPort.RasInfo->RyOffset = ubStart + ((ubEnd - ubStart) * steps[i]) / 32;
		ScrollVPort(&g_sHudManager.pHudVPort->sVPort);
		WaitTOF();
	}
}

void hudAnimate(UBYTE ubStart, UBYTE ubStop) {
	UBYTE stepRatios[42] = {0, 0, 10, 20, 30, 40, 50, 60, 69, 79, 88, 98, 107, 116, 125, 133, 142, 150, 158, 166, 173, 180, 187, 194, 200, 206, 212, 217, 222, 227, 232, 236, 239, 243, 245, 248, 250, 252, 253, 254, 255, 255};
	UBYTE i;
	UBYTE ubStep, ubStepValue;
	if (ubStart > ubStop) {
		ubStep = -1;
	}
	else {
		ubStep = 1;
	}
	for (i = ubStart; i != ubStop; i += ubStep) {
		ubStepValue = ( ( ( (g_sGameConfig.ubPlayerCount - 1) << 5 ) * stepRatios[i] ) >> 8);
		g_sHudManager.pMainVPort->sVPort.DHeight = 223 - ubStepValue;
		g_sHudManager.pHudVPort->sVPort.DyOffset = g_sHudManager.pMainVPort->sVPort.DHeight+2;
		g_sHudManager.pHudVPort->sVPort.DHeight = WINDOW_SCREEN_HEIGHT - g_sHudManager.pHudVPort->sVPort.DyOffset;
		if(ubStepValue < g_pCurrPlayer->ubIdx << 5) {
			g_sHudManager.pHudVPort->sVPort.RasInfo->RyOffset = (g_pCurrPlayer->ubIdx << 5) - ubStepValue;
		}
		else {
			g_sHudManager.pHudVPort->sVPort.RasInfo->RyOffset = 0;
		}
		MakeVPort(&g_sHudManager.pExtView->sView, &g_sHudManager.pMainVPort->sVPort);
		MakeVPort(&g_sHudManager.pExtView->sView, &g_sHudManager.pHudVPort->sVPort);
		extViewProcessManagers(g_sHudManager.pExtView); // wywo³anie scrollBufferProcess
	}
}

void hudExpand(void) {
	mouseSetPointer(&g_pCursorData[g_ubPointerIdx * 36], 16, 16, g_pPointerSpots[g_ubPointerIdx][0], g_pPointerSpots[g_ubPointerIdx][1]);
	g_sHudManager.ubExpanded = 1;

	hudAnimate(1, 41);
	// hudAnimate(40, 41); // no anim dbg
}

void hudMinimize(void) {
	g_sHudManager.ubExpanded = 0;

	hudAnimate(40, 0);
	// hudAnimate(1, 0); // no anim dbg
}

void hudSummary(void) {
	char pPlaceStrings[8][4] = {"1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"};
	UWORD *pPlayerScores;
	UBYTE *pPlayerNumbers;
	UBYTE ubPlayer, ubDone, ubPlace;
	UWORD uwTmp, uwPrevScore;
	tPlayer *pTmpCurr;

	// numery graczy i score'y do sortowania
	pPlayerScores = allocFastFirst(g_sGameConfig.ubPlayerCount * sizeof(UWORD));
	pPlayerNumbers = allocFastFirst(g_sGameConfig.ubPlayerCount);
	// wype³nij
	pTmpCurr = g_sGameConfig.pPlayerFirst;
	for (ubPlayer = 0; ubPlayer != g_sGameConfig.ubPlayerCount; ++ubPlayer) {
		pPlayerScores[ubPlayer] = pTmpCurr->uwScore;
		pPlayerNumbers[ubPlayer] = ubPlayer;
		pTmpCurr = pTmpCurr->pNext;
	}

	// przesortuj
	do {
		ubDone = 1;
		for (ubPlayer = g_sGameConfig.ubPlayerCount; --ubPlayer;) {
			if (pPlayerScores[ubPlayer] > pPlayerScores[ubPlayer-1]) {
				ubDone = 0;
				// swap punktów
				uwTmp = pPlayerScores[ubPlayer-1];
				pPlayerScores[ubPlayer-1] = pPlayerScores[ubPlayer];
				pPlayerScores[ubPlayer] = uwTmp;
				// swap graczy
				uwTmp = pPlayerNumbers[ubPlayer-1];
				pPlayerNumbers[ubPlayer-1] = pPlayerNumbers[ubPlayer];
				pPlayerNumbers[ubPlayer] = uwTmp;
			}
		}
	} while (!ubDone);
	
	// Odrysuj ca³y HUD bez zaznaczania aktywnego gracza
	pTmpCurr = g_pCurrPlayer;
	g_pCurrPlayer = 0; // ¿eby nie odrysowa³ nigdzie kafla
	hudRedrawAll();
	g_pCurrPlayer = pTmpCurr;
	
	// Wypisz numery zajêtych miejsc
	uwPrevScore = 0;
	ubPlace = 0;
	for (ubPlayer = 0; ubPlayer != g_sGameConfig.ubPlayerCount; ++ubPlayer) {
		// Jeœli gorszy wynik to ni¿sze miejsce - za³atwia ex aequo
		if (uwPrevScore > pPlayerScores[ubPlayer]) {
			++ubPlace;
		}
		fontDrawStr(
			g_sHudManager.pHudVPort->sVPort.RasInfo->BitMap, g_pFont,
			280, pPlayerNumbers[ubPlayer]*32+7,
			pPlaceStrings[ubPlace], COLOR_DRKGREEN, FONT_COOKIE | FONT_SHADOW
		);
		uwPrevScore = pPlayerScores[ubPlayer];
	}
	
	freeMem(pPlayerScores, g_sGameConfig.ubPlayerCount * sizeof(UWORD));
	freeMem(pPlayerNumbers, g_sGameConfig.ubPlayerCount);
	
	hudExpand();
}