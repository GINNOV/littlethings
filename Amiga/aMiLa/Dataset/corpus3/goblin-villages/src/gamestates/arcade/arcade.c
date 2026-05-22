#include "arcade.h"

/* Globals */
// Ekran
tExtView *s_pExtView;
tExtVPort *s_pMainVPort;
tExtVPort *s_pHudVPort;
tTileBufferManager *g_pTileBuffer; // extern

// Stan gry
UBYTE g_ubTurnStep;
tPlayer *g_pCurrPlayer;
tCoord g_sLastTileCoord;
UBYTE g_ubScrollSpeed = 2; // TODO: wjebaæ do konfiga

// Indeks kursora - obecny i poprzedni
UBYTE g_ubPointerIdx;
UBYTE g_ubPrevPointerIdx;

// Pamiêæ dla sprawdzania na hoverze
UBYTE g_pTileIsPlacable[9];
UBYTE g_ubPrevLogicDataIdx;

/* Functions */

// ustawia kolory kursora na dwa wskazane indeksy z palety
void setPointerColors(UBYTE *pColorIdx) {
	tExtVPort *pVPort = (tExtVPort *)s_pExtView->sView.ViewPort;
	while(pVPort) {
		paletteSetVPColor(pVPort, 19, pVPort->pPalette[pColorIdx[0]]);
		paletteSetVPColor(pVPort, 18, pVPort->pPalette[pColorIdx[1]]);
		pVPort = (tExtVPort*)pVPort->sVPort.Next;
	}
}

void gsArcadeCreate(void) {
	logWrite("gsArcadeCreate begin\n");
	logPushIndent();
	
	// ekran
	s_pExtView = extViewCreate(0, 0, 0);
	// obszar g³ówny
	s_pMainVPort = extViewAddVPort(s_pExtView, WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT -32 -1, WINDOW_SCREEN_BPP);
	g_pTileBuffer = tileBufferManagerCreate(s_pMainVPort, TILEMAP_WIDTH, TILEMAP_HEIGHT, 32, "data/tiles/selur_v1.bm", pawnRedrawCallback);
	// hud
	s_pHudVPort = extViewAddVPort(s_pExtView, WINDOW_SCREEN_WIDTH, 32, WINDOW_SCREEN_BPP);
	simpleBufferManagerCreate(s_pHudVPort, WINDOW_SCREEN_WIDTH, 32*g_sGameConfig.ubPlayerCount);
	// palety
	paletteCreateToExtView("data/palettes/selur_v1.plt", s_pExtView);
	LoadRGB4(&s_pMainVPort->sVPort, s_pMainVPort->pPalette, 32);
	MakeVPort(&s_pExtView->sView, &s_pMainVPort->sVPort);
	LoadRGB4(&s_pHudVPort->sVPort, s_pHudVPort->pPalette, 32);
	MakeVPort(&s_pExtView->sView, &s_pHudVPort->sVPort);
	
	// Gracze, pionki, logika
	pawnCreate();
	playerListCreate();
	g_pCurrPlayer = g_sGameConfig.pPlayerFirst;
	setPointerColors(g_pPlayerColors[g_pCurrPlayer->ubIdx]);
	tileStackCreate();
	logicListCreate();
	hudCreate(s_pExtView);
	g_ubPointerIdx = POINTER_NW;
	g_ubPrevPointerIdx = POINTER_NW;
	g_ubTurnStep = TURN_TILE;

	// kafel startowy
	g_pTileBuffer->pTileData[TILEMAP_WIDTH >> 1][TILEMAP_HEIGHT >> 1] = 4 + ubRandMinMax(0, 3) * TILE_TYPES;	
	// Pocz¹tkowe przygotowanie ekranu
	cameraResetCoord(
		g_pTileBuffer->pCameraManager, s_pMainVPort,
		(((TILEMAP_WIDTH * g_pTileBuffer->ubTileSize) - s_pMainVPort->sVPort.DWidth) >> 1) + (g_pTileBuffer->ubTileSize >> 1),
		(((TILEMAP_HEIGHT * g_pTileBuffer->ubTileSize) - s_pMainVPort->sVPort.DHeight) >> 1) + (g_pTileBuffer->ubTileSize >> 1),
		TILEMAP_WIDTH * g_pTileBuffer->ubTileSize, TILEMAP_HEIGHT * g_pTileBuffer->ubTileSize
	);
	tileBufferRedraw(g_pTileBuffer);
	g_sGameManager.pStateFirst->pLoopCallback(); // TODO: Potrzebne?

	// Copperlista dla scrollingu
	MrgCop(&s_pExtView->sView);
	windowLoadExtView(s_pExtView);
	scrollBufferManagerProcess(g_pTileBuffer->pScrollManager); // TODO: Potrzebne?
	
	logPopIndent();
	logWrite("gsArcadeCreate end\n");
}

void gsArcadeLoopSetup(void) {
	gameChangeLoop(gsArcadeLoop);
}

void endTurn(void) {
	logWrite("EndTurn\n");
	if (g_sTileList.uwPos >= g_sTileList.uwLength - 1) {
		hudSummary();
		gameChangeLoop(gsArcadeResultsLoop);
		return;
	}
	else {
		logicCountPoints();

		// zmieñ gracza
		if (g_pCurrPlayer->pNext) {
			g_pCurrPlayer = g_pCurrPlayer->pNext;
		}
		else {
			g_pCurrPlayer = g_sGameConfig.pPlayerFirst;
		}
		
		// kafel do przodu
		++g_sTileList.uwPos;
		g_ubTurnStep = TURN_TILE;
		
		// odrysuj HUD kolejnego gracza
		setPointerColors(g_pPlayerColors[g_pCurrPlayer->ubIdx]);
		hudRedrawAll();
		hudShowPlayer(g_pCurrPlayer);
	}
}

void arcadeProcessScroll(uwMouseX, uwMouseY){
	BYTE bScrollX, bScrollY;
	// X
	bScrollX = 0;
	if (uwMouseX == 0) {
		bScrollX = -1;
	}
	else if(uwMouseX == WINDOW_SCREEN_WIDTH-1) {
		bScrollX = 1;
	}
	// Y
	bScrollY = 0;
	if (uwMouseY == 0) {
		bScrollY = -1;
	}
	else if(uwMouseY == WINDOW_SCREEN_HEIGHT-1) {
		bScrollY = 1;
	}
	
	// Przesuñ kamerê
	cameraMove(g_pTileBuffer->pCameraManager, bScrollX*g_ubScrollSpeed, bScrollY*g_ubScrollSpeed);
	// Kursor
	g_ubPointerIdx = g_pPointerDirs[bScrollY+1][bScrollX+1];
	if (g_ubPointerIdx != g_ubPrevPointerIdx) {
		mouseSetPointer(&g_pCursorData[g_ubPointerIdx * 36], 16, 16, g_pPointerSpots[g_ubPointerIdx][0], g_pPointerSpots[g_ubPointerIdx][1]);
	}
	g_ubPrevPointerIdx = g_ubPointerIdx;
}

void gsArcadeLoop(void) {
	UWORD uwMouseX = mouseGetX();
	UWORD uwMouseY = mouseGetY();
	
	if (keyUse(KEY_ESCAPE)) {
		hudSummary();
		gameChangeLoop(gsArcadeResultsLoop);
		return;
	}
	
	if (g_sHudManager.ubExpanded) {
		if (keyUse(KEY_SPACE) || mouseUse(MOUSE_LMB)) {
			hudMinimize();
		}
		return;
	}
	else {
		if (keyUse(KEY_SPACE) || (mouseCheck(MOUSE_LMB) && mouseIsIntersects(0, WINDOW_SCREEN_HEIGHT - 30, WINDOW_SCREEN_WIDTH, 30))) {
			mouseUse(MOUSE_LMB); // zu¿ycie klikniêcia
			hudExpand();
		}
	}

	switch (g_ubTurnStep) {
		case TURN_TILE: {
			if (mouseUse(MOUSE_LMB)) {
				UWORD uwTileX = (g_pTileBuffer->pCameraManager->sCoord.uwX + uwMouseX) / g_pTileBuffer->ubTileSize;
				UWORD uwTileY = (g_pTileBuffer->pCameraManager->sCoord.uwY + uwMouseY) / g_pTileBuffer->ubTileSize;

				if (tileIsPlaceable(uwTileX, uwTileY, &g_pTileDefs[g_sTileList.pTileIdx[g_sTileList.uwPos]])) {
					tilePlace(uwTileX, uwTileY, &g_pTileDefs[g_sTileList.pTileIdx[g_sTileList.uwPos]]);

					if (g_pCurrPlayer->ubPawnsLeft) {
						logWrite("Placed tile @%ux%u", uwTileX, uwTileY);
						g_ubTurnStep = TURN_PAWN;
						hudRedrawPlayer(g_pCurrPlayer);
						g_ubPrevLogicDataIdx = 0xff;

						UBYTE i = 9;
						while (i--) {
							g_pTileIsPlacable[i] = pawnIsPlaceable(uwTileX, uwTileY, i);
						}
					}
					else {
						endTurn();
					}
					return;
				}
			}

			if (mouseUse(MOUSE_RMB)) {
				tileRotate();
			}
		} break;
		case TURN_PAWN: {
			UWORD uwTileX = (g_pTileBuffer->pCameraManager->sCoord.uwX + uwMouseX) / g_pTileBuffer->ubTileSize;
			UWORD uwTileY = (g_pTileBuffer->pCameraManager->sCoord.uwY + uwMouseY) / g_pTileBuffer->ubTileSize;
			
			if ((uwTileX == g_sLastTileCoord.uwX) && (uwTileY == g_sLastTileCoord.uwY)) {
				UBYTE ubTileChunkX = (((g_pTileBuffer->pCameraManager->sCoord.uwX + uwMouseX) % g_pTileBuffer->ubTileSize) + (g_pTileBuffer->ubTileSize >> 2)) / (g_pTileBuffer->ubTileSize >> 1);
				UBYTE ubTileChunkY = (((g_pTileBuffer->pCameraManager->sCoord.uwY + uwMouseY) % g_pTileBuffer->ubTileSize) + (g_pTileBuffer->ubTileSize >> 2)) / (g_pTileBuffer->ubTileSize >> 1);

				UBYTE ubLogicDataIdx = (3 * ubTileChunkY) + ubTileChunkX;
				if (mouseUse(MOUSE_LMB)) {
					if (g_pTileIsPlacable[ubLogicDataIdx]) {
						pawnPlace(uwTileX, uwTileY, ubLogicDataIdx, g_pCurrPlayer);
						mouseSetPointer(&g_pCursorData[g_ubPointerIdx * 36], 16, 16, g_pPointerSpots[g_ubPointerIdx][0], g_pPointerSpots[g_ubPointerIdx][1]);
						endTurn();
					}
				}
				else if (ubLogicDataIdx != g_ubPrevLogicDataIdx) {
					g_ubPrevLogicDataIdx = ubLogicDataIdx;
					if (g_pTileIsPlacable[ubLogicDataIdx]) {
						mouseSetPointer(g_pPawnCursorData, 16, 16, -5, -5);
					}
					else {
						mouseSetPointer(&g_pCursorData[g_ubPointerIdx * 36], 16, 16, g_pPointerSpots[g_ubPointerIdx][0], g_pPointerSpots[g_ubPointerIdx][1]);
					}
				}
			}
			else if (g_ubPrevLogicDataIdx != 0xff) {
				mouseSetPointer(&g_pCursorData[g_ubPointerIdx * 36], 16, 16, g_pPointerSpots[g_ubPointerIdx][0], g_pPointerSpots[g_ubPointerIdx][1]);
				g_ubPrevLogicDataIdx = 0xff;
			}
			
			if (keyUse(KEY_RETURN)) {
				endTurn();
			}
		} break;
	}

	arcadeProcessScroll(uwMouseX, uwMouseY);
	
	// odrysuj kafle na marginesach lub caly ekran jesli offset za duzy
	extViewProcessManagers(s_pExtView);
	// WaitTOF();
}

void gsArcadeResultsLoop(void) {
	if (mouseUse(MOUSE_LMB) || keyUse(KEY_ESCAPE) || keyUse(KEY_SPACE) || keyUse(KEY_RETURN)) {
		gameChangeState(gsMenuCreate, gsMenuLobbySetup, gsMenuDestroy);
	}
}

void gsArcadeDestroy(void) {
	logWrite("gsArcadeDestroy begin\n");
	logPushIndent();
	
	LoadView(0);

	pawnDestroy();
	playerListDestroy();
	hudDestroy();
	logicListDestroy();
	tileStackDestroy();
	
	extViewDestroy(s_pExtView);
	
		
	logPopIndent();
	logWrite("gsArcadeDestroy end\n");
}