#include "menu.h"

/* Globals */
static tExtView *s_pMenuExtView;
static tExtVPort *s_pMenuExtVPort;
static struct BitMap *s_pSplashBitMap;
static struct BitMap *s_pGrassBitMap;

/* Functions */
void gsMenuCreate(void) {
	logWrite("gsMenuCreate begin\n");
	logPushIndent();
	
	s_pMenuExtView = extViewCreate(0, 0, 0);
	s_pMenuExtVPort = extViewAddVPort(s_pMenuExtView, WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT, WINDOW_SCREEN_BPP);
	simpleBufferManagerCreate(s_pMenuExtVPort, WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT);
	
	paletteCreateToExtView("data/palettes/selur_v1.plt", s_pMenuExtView);
	LoadRGB4(&s_pMenuExtVPort->sVPort, s_pMenuExtVPort->pPalette, 32);
	MakeVPort(&s_pMenuExtView->sView, &s_pMenuExtVPort->sVPort);

	s_pGrassBitMap = bitmapCreateFromFile("data/bitmaps/grass.bm");
	
	// Splash
	s_pSplashBitMap = bitmapCreateFromFile("data/bitmaps/splash.bm");
	UBYTE i;
	// TEST - srcX niepodzielne, dstX podzielne
	for(i = 0; i != 7; ++i) {
		blitCopy(
			g_pCharactersBitMap, 2*i, 32,
			s_pSplashBitMap, 16, (1+32)*i,
			32, 32,
			MINTERM_A, 0xFF
		);
	}
	// TEST - srcX podzielne, dstX niepodzielne
	for(i = 0; i != 7; ++i) {
		blitCopy(
			g_pCharactersBitMap, 32, 32,
			s_pSplashBitMap, 80+2*i, (1+32)*i,
			32, 32,
			MINTERM_A, 0xFF
		);
	}
	// TEST - srcX niepodzielne, dstX niepodzielne, srcDelta == dstDelta
	for(i = 0; i != 7; ++i) {
		blitCopy(
			g_pCharactersBitMap, 32+2*i, 32,
			s_pSplashBitMap, 144+2*i, (1+32)*i,
			32, 32,
			MINTERM_A, 0xFF
		);
	}
	// TEST - srcX niepodzielne, dstX niepodzielne, srcDelta > dstDelta
	for(i = 0; i != 7; ++i) {
		blitCopy(
			g_pCharactersBitMap, 32+4*i, 32,
			s_pSplashBitMap, 208+2*i, (1+32)*i,
			32, 32,
			MINTERM_A, 0xFF
		);
	}
	
	fontDrawStr(s_pSplashBitMap, g_pFont, WINDOW_SCREEN_WIDTH >> 1, 180, "Click to start", COLOR_DRKGREEN, FONT_CENTER | FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pSplashBitMap, g_pFont, WINDOW_SCREEN_WIDTH >> 1, 215, "All rights reserved 2014", COLOR_DRKGREEN, FONT_CENTER | FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pSplashBitMap, g_pFont, WINDOW_SCREEN_WIDTH >> 1, 230, "KaiN, Proxy, Selur, JnR", COLOR_DRKGREEN, FONT_CENTER | FONT_COOKIE | FONT_SHADOW);

	MrgCop(&s_pMenuExtView->sView);
	windowLoadExtView(s_pMenuExtView);

	g_sGameManager.pStateFirst->pLoopCallback();
	
	logPopIndent();
	logWrite("gsMenuCreate end\n");
}

void gsMenuSplashSetup(void) {
	// blitCopyAligned(
		// s_pSplashBitMap, 0, 0,
		// s_pMenuExtVPort->sVPort.RasInfo->BitMap, 0, 0,
		// WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT
	// );
	blitCopy(
		s_pSplashBitMap, 0, 0,
		s_pMenuExtVPort->sVPort.RasInfo->BitMap, 0, 0,
		WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT, MINTERM_COOKIE, 0xFF
	);
	mouseSetPointer(g_sMouseManager.pBlankCursor, 1, 16, 0, 0);
	
	gameChangeLoop(gsMenuSplashLoop);
}

void gsMenuSplashLoop(void) {
	if (keyUse(KEY_ESCAPE)) {
		gameClose();
		return;
	}

	if (mouseUse(MOUSE_LMB)) {
		extViewFadeOut(s_pMenuExtView);
		gsMenuLobbySetup();
		extViewFadeIn(s_pMenuExtView);

		return;
	}
}

void gsMenuLobbySetup(void) {
	gsMenuDrawBg();
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, 160, 50, "Players", COLOR_DRKGREEN, FONT_CENTER | FONT_COOKIE | FONT_SHADOW);

	UBYTE ubPlayer = PLAYER_COUNT;
	while (ubPlayer--) {
		blitCopyAligned(
			g_pCharactersBitMap, (32 * ubPlayer), 32 * g_sGameConfig.pPlayersSelected[ubPlayer],
			s_pMenuExtVPort->sVPort.RasInfo->BitMap, 32 + (32 * ubPlayer), 70,
			32, 32
		);
	}

	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, 64, 120, "Game mode", COLOR_DRKGREEN, FONT_COOKIE | FONT_SHADOW); 
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 120, "[                 ]", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 120, "classic", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);

	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, 64, 140, "Pawn count", COLOR_DRKGREEN, FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 140, "[                 ]", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);
	char szPawnCount[3];
	sprintf(szPawnCount, "%hhu", g_sGameConfig.ubPawnsPerPlayer);
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 140, szPawnCount, COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);

	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, 64, 160, "Tile set", COLOR_DRKGREEN, FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 160, "[                 ]", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 160, "goblins", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);

	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH >> 1, 200, "[       play       ]", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);
	fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH >> 1, 220, "[    how to play   ]", COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);

	mouseSetPointer(g_pCursorData, 16, 16, 0, 0);
	gameChangeLoop(gsMenuLobbyLoop);
}

void gsMenuLobbyLoop(void) {
	if (keyUse(KEY_ESCAPE)) {
		extViewFadeOut(s_pMenuExtView);
		gsMenuSplashSetup();
		extViewFadeIn(s_pMenuExtView);

		return;
	}

	if (mouseUse(MOUSE_LMB)) {
		UBYTE ubPlayer = PLAYER_COUNT;
		while (ubPlayer--) {
			if (mouseIsIntersects(32 + (32 * ubPlayer), 70, 32, 32)) { // Character
				gsMenuCharacterAction(ubPlayer);

				return;
			}
		}

		if (mouseIsIntersects(WINDOW_SCREEN_WIDTH - 115 - (95 >> 1), 140, 95, 15) && (g_sGameConfig.ubPawnsPerPlayer < 16)) { // Pawns
			char szPawnCount[3];
			sprintf(szPawnCount, "%hhu", g_sGameConfig.ubPawnsPerPlayer);
			fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 140, szPawnCount, COLOR_WHITE, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);

			g_sGameConfig.ubPawnsPerPlayer += 1;
			sprintf(szPawnCount, "%hhu", g_sGameConfig.ubPawnsPerPlayer);
			fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 140, szPawnCount, COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);
		}
		else if (mouseIsIntersects((WINDOW_SCREEN_WIDTH >> 1) - (109 >> 1), 200, 109, 15)) { // Play
			gsMenuPlayAction();

			return;
		}
		else if (mouseIsIntersects((WINDOW_SCREEN_WIDTH >> 1) - (109 >> 1), 220, 109, 15)) { // How to
			gsMenuHowToAction();

			return;
		}
	}

	if (mouseUse(MOUSE_RMB)) {
		if (mouseIsIntersects(WINDOW_SCREEN_WIDTH - 115 - (95 >> 1), 140, 95, 15) && (7 < g_sGameConfig.ubPawnsPerPlayer)) { // Pawns
			char szPawnCount[3];
			sprintf(szPawnCount, "%hhu", g_sGameConfig.ubPawnsPerPlayer);
			fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 140, szPawnCount, COLOR_WHITE, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);

			g_sGameConfig.ubPawnsPerPlayer -= 1;
			sprintf(szPawnCount, "%hhu", g_sGameConfig.ubPawnsPerPlayer);
			fontDrawStr(s_pMenuExtVPort->sVPort.RasInfo->BitMap, g_pFont, WINDOW_SCREEN_WIDTH - 115, 140, szPawnCount, COLOR_DRKGREEN, FONT_HCENTER | FONT_COOKIE | FONT_SHADOW);
		}
	}
}

void gsMenuDestroy(void) {
	logWrite("gsMenuDestroy begin\n");
	logPushIndent();
	
	LoadView(0);

	bitmapDestroy(s_pGrassBitMap);
	bitmapDestroy(s_pSplashBitMap);
	extViewDestroy(s_pMenuExtView);
	
	logPopIndent();
	logWrite("gsMenuDestroy end\n");
}

void gsMenuDrawBg(void) {
	UWORD uwX, uwY;
	// pierwszy wiersz
	for (uwX = 0; uwX < WINDOW_SCREEN_WIDTH; uwX += 32) {
		blitCopyAligned(
			s_pGrassBitMap, 0, 0,
			s_pMenuExtVPort->sVPort.RasInfo->BitMap, uwX, 0,
			32, 32
		);
	}
	// blitowanie wierszami
	for (uwY = 0; uwY < WINDOW_SCREEN_HEIGHT; uwY += 32) {
		blitCopyAligned(
			s_pMenuExtVPort->sVPort.RasInfo->BitMap, 0, 0,
			s_pMenuExtVPort->sVPort.RasInfo->BitMap, 0, uwY,
			WINDOW_SCREEN_WIDTH, 32
		);
	}
}

void gsMenuCharacterAction(UBYTE ubPlayer) {
	if (g_sGameConfig.pPlayersSelected[ubPlayer]) {
		if (2 < g_sGameConfig.ubPlayerCount) {
			g_sGameConfig.pPlayersSelected[ubPlayer] = 0;
			--g_sGameConfig.ubPlayerCount;
			
			blitCopyAligned(
				g_pCharactersBitMap, (32 * ubPlayer), 0,
				s_pMenuExtVPort->sVPort.RasInfo->BitMap, 32 + (32 * ubPlayer), 70,
				32, 32
			);
		}
	}
	else {
		g_sGameConfig.pPlayersSelected[ubPlayer] = 1;
		++g_sGameConfig.ubPlayerCount;

		blitCopyAligned(
			g_pCharactersBitMap, (32 * ubPlayer), 32,
			s_pMenuExtVPort->sVPort.RasInfo->BitMap, 32 + (32 * ubPlayer), 70,
			32, 32
		);
	}
}

void gsMenuPlayAction(void) {
	gameChangeState(gsArcadeCreate, gsArcadeLoopSetup, gsArcadeDestroy);
}

void gsMenuHowToAction(void) {
	// gameLoadState(gsHowToCreate, gsHowToLoop, gsHowToDestroy);
}