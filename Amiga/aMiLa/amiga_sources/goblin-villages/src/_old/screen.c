#include "screen.h"


/* Globals */
struct UCopList *g_pCopArcadeList;
UWORD g_uwBfrWidth;
UWORD g_uwBfrHeight;

/* Functions */
tExtView *villagesExtViewCreate(void) {
	UWORD uwMainVPWidth = WINDOW_SCREEN_WIDTH;
	UWORD uwMainVPHeight = WINDOW_SCREEN_HEIGHT - 32;
	UWORD uwMainBufWidth = 100 * 32;
	UWORD uwMainBufHeight = 100 * 32;
	UWORD uwMainBPP = 5;
	UWORD uwAuxVPWidth = WINDOW_SCREEN_WIDTH;
	UWORD uwAuxVPHeight = 30;
	UWORD uwAuxBPP = 5;
	tExtView *pExtView;
	struct View *pView;
	struct ViewPort *pMainViewPort = 0;
	struct ViewPort *pAuxViewPort = 0;
		
	logWrite("Create villages extView begin\n");
	logPushIndent();
	
	pExtView = allocFastFirst(sizeof(tExtView));
	
	// View
	pView = allocFastFirst(sizeof(struct View));
	InitView(pView);
	// pView->Modes |= EXTRA_HALFBRITE;
	pExtView->pView = pView;
	
	// Viewport g³ówny
	logWrite("MAIN: ");
	pMainViewPort = windowCreateViewPort(uwMainVPWidth, uwMainVPHeight, 0, 0);
	pView->ViewPort = pMainViewPort;
	pExtView->pMainViewPort = pMainViewPort;
	
	// Wstêpne czyszczenie palety
	UWORD pPalette[32];
	UBYTE i;
	for(i = 0; i != 32; ++i) {
		pPalette[i] = 0;
	}
	LoadRGB4(pMainViewPort, pPalette, 1 << uwMainBPP);
	
	// Viewport dodatkowy - HUD
	logWrite("AUX: ");
	pAuxViewPort = windowCreateViewPort(uwAuxVPWidth, uwAuxVPHeight, 0, 0);

	// Poprawne u³o¿enie listy jednokierunkowej viewportów
	pMainViewPort->Next = pAuxViewPort;
	pAuxViewPort->DyOffset = 2 + uwMainVPHeight;

	// Bufor dodatkowego viewporta - zawsze single i zawsze wymiar viewporta
	pAuxViewPort->RasInfo->BitMap = bitmapCreate(WINDOW_SCREEN_WIDTH, WINDOW_SCREEN_HEIGHT, uwAuxBPP, BMF_CLEAR);
	MakeVPort(pView, pAuxViewPort);
	pExtView->pAuxViewPort = pAuxViewPort;
	LoadRGB4(pAuxViewPort, pPalette, 1 << uwAuxBPP);
	
	// Bufor g³ównego viewporta
	g_uwBfrWidth = uwMainVPWidth + (32 * 4);
	g_uwBfrHeight = uwMainVPHeight + (32 * 4);
	extViewCreateSingleBuffering(pExtView, g_uwBfrWidth, g_uwBfrHeight + (((uwMainBufWidth + (uwMainVPWidth - 1)) / uwMainVPWidth) - 1), uwMainBPP);
	
	logPopIndent();
	logWrite("Create villages extView end\n");	
	
	return pExtView;
}

void screenScroll(tExtView *pExtView, UBYTE ubForce) {
	UWORD uwVpHeight;
	UBYTE i;
	UWORD uwScrollX, uwScrollY;
	ULONG ulPlaneAddr;
	UWORD uwModulo;
	UWORD *pBlitterPlanes = (UWORD *) custom.bplpt;
	struct BitMap *pBmBfr = pExtView->pBackScreenBuffer->pBitMap;
	UWORD uwOffsX;
	
	
	if (cameraIsMoved() || ubForce) {
		uwVpHeight = pExtView->pMainViewPort->DHeight;
		uwScrollX = g_sCameraManager.sCoord.uwX;
		uwScrollY = (g_sCameraManager.sCoord.uwY % g_uwBfrHeight);
		uwModulo = pBmBfr->BytesPerRow - (pExtView->pMainViewPort->DWidth >> 3) - 3;
		
		// fine tune
		uwOffsX = 15 - (uwScrollX & 15);
		uwOffsX = (uwOffsX << 4) | uwOffsX;
		windowSeekUCopList(g_pCopArcadeList, 0, CPR_SEEK_SET);
		// pocz¹tkowy
		CWAIT(g_pCopArcadeList, 0, 0);
		// CMOVE(g_pCopArcadeList, custom.color, 0x0F00); // DEBUG
		for (i = 0; i != WINDOW_SCREEN_BPP; ++i) {
			// copper dzia³a na 16-bitowych wartoœciach - split assigna 32-bitowego
			ulPlaneAddr = (ULONG) (pBmBfr->Planes[i]) + (uwScrollX >> 3) + (pBmBfr->BytesPerRow*uwScrollY);
			CMOVE(g_pCopArcadeList, pBlitterPlanes[(i << 1) + 1], ulPlaneAddr & 0xFFFF);
			CMOVE(g_pCopArcadeList, pBlitterPlanes[(i << 1) + 0], (ulPlaneAddr >> 16));
		}
		CMOVE(g_pCopArcadeList, custom.bplcon1, uwOffsX);
		CMOVE(g_pCopArcadeList, custom.ddfstrt, 0x30);
		CMOVE(g_pCopArcadeList, custom.bpl1mod, uwModulo);
		CMOVE(g_pCopArcadeList, custom.bpl2mod, uwModulo);
		// CMOVE(g_pCopArcadeList, custom.color, 0x0000); // DEBUG
		if (g_uwBfrHeight - uwScrollY <= uwVpHeight) {
			// prze³amanie
			CWAIT(g_pCopArcadeList, pExtView->pMainViewPort->DyOffset + g_uwBfrHeight - uwScrollY, 0);
			CMOVE(g_pCopArcadeList, custom.bplcon1, uwOffsX);
			// CMOVE(g_pCopArcadeList, custom.ddfstrt, 0x30);
			// CMOVE(g_pCopArcadeList, custom.bpl1mod, uwModulo);
			// CMOVE(g_pCopArcadeList, custom.bpl2mod, uwModulo);
			for (i = 0; i != WINDOW_SCREEN_BPP; ++i) {
				// copper dzia³a na 16-bitowych wartoœciach - split assigna 32-bitowego
				ulPlaneAddr = (ULONG) (pBmBfr->Planes[i]) + (uwScrollX >> 3);
				CMOVE(g_pCopArcadeList, pBlitterPlanes[(i << 1) + 1], ulPlaneAddr & 0xFFFF);
				CMOVE(g_pCopArcadeList, pBlitterPlanes[(i << 1) + 0], (ulPlaneAddr >> 16));
			}
			// CMOVE(g_pCopArcadeList, custom.color, 0x0000); // DEBUG
		}
		CEND(g_pCopArcadeList);
		WaitTOF();
		MrgCop(pExtView->pView); // zakomentowaæ ¿eby wy³¹czyæ copperlistê
		LoadView(pExtView->pView);
	}
}