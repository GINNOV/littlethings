#include "gamestates/game/hud.h"
#include <ace/managers/blit.h>
#include <ace/managers/viewport/simplebuffer.h>
#include <ace/utils/bitmap.h>
#include <ace/utils/custom.h>
#include "gamestates/game/game.h"
#include "gamestates/game/player.h"
#include "gamestates/game/console.h"
#include "vehicletypes.h"

static tVPort *s_pHudVPort;
tSimpleBufferManager *g_pHudBfr;
static tBitMap *s_pHudPanels[2];
static FUBYTE s_fubHudState, s_fubHudPrevState;
static tFont *s_pHudFont;
static tTextBitMap *s_pSpawnTextBfr;

static UWORD s_uwPrevTickets[2];
static FUBYTE s_fubFrame;

void hudCreate(tFont *pFont) {
	s_pHudVPort = vPortCreate(0,
		TAG_VPORT_VIEW,	g_pWorldView,
		TAG_VPORT_BPP, WORLD_BPP,
		TAG_VPORT_OFFSET_TOP, 1,
		TAG_DONE
	);
	g_pHudBfr = simpleBufferCreate(0,
		TAG_SIMPLEBUFFER_VPORT, s_pHudVPort,
		TAG_SIMPLEBUFFER_COPLIST_OFFSET, WORLD_COP_VPHUD_POS,
		TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_INTERLEAVED,
		TAG_DONE
	);
	s_pHudFont = pFont;
	s_pSpawnTextBfr = fontCreateTextBitMap(32, pFont->uwHeight);

	tCopCmd *pCopList = g_pWorldView->pCopList->pBackBfr->pList;
	copSetWait(
		&pCopList[WORLD_COP_VPHUD_DMAOFF_POS+0].sWait,
		0x04,
		pCopList[WORLD_COP_VPHUD_POS].sWait.bfWaitY
	);
	copSetMove(
		&pCopList[WORLD_COP_VPHUD_DMAOFF_POS+1].sMove,
		&g_pCustom->dmacon, BITCLR | DMAF_RASTER | DMAF_SPRITE
	);
	copSetMove(
		&pCopList[WORLD_COP_VPHUD_DMAON_POS].sMove,
		&g_pCustom->dmacon, BITSET|DMAF_RASTER
	);
	// Same for front bfr
	CopyMemQuick(
		&g_pWorldView->pCopList->pBackBfr->pList[WORLD_COP_VPHUD_DMAOFF_POS],
		&g_pWorldView->pCopList->pFrontBfr->pList[WORLD_COP_VPHUD_DMAOFF_POS],
		2*sizeof(tCopCmd)
	);
	CopyMemQuick(
		&g_pWorldView->pCopList->pBackBfr->pList[WORLD_COP_VPHUD_DMAON_POS],
		&g_pWorldView->pCopList->pFrontBfr->pList[WORLD_COP_VPHUD_DMAON_POS],
		1*sizeof(tCopCmd)
	);

	// Initial draw on buffer
	bitmapLoadFromFile(g_pHudBfr->pBack, "data/hud/blank.bm", 0, 0);
	s_pHudPanels[HUD_STATE_DRIVING] = bitmapCreateFromFile("data/hud/driving.bm");
	s_pHudPanels[HUD_STATE_SELECTING] = bitmapCreateFromFile("data/hud/selecting.bm");

	s_fubHudPrevState = 0xFF;
	s_fubFrame = 0;
	consoleCreate(s_pHudFont);
}

void hudChangeState(FUBYTE fubState) {

	s_fubHudState = fubState;

	UWORD uwDmaCon;
	volatile UWORD * pCrossCtl;
	tCopCmd *pFrontList = g_pWorldView->pCopList->pFrontBfr->pList;
	tCopCmd *pBackList = g_pWorldView->pCopList->pBackBfr->pList;
	if(fubState == HUD_STATE_DRIVING) {
		pCrossCtl = &g_pCustom->spr[2].ctl;
		uwDmaCon = BITCLR | DMAF_RASTER | DMAF_SPRITE;
	}
	else {
		pCrossCtl = &g_pCustom->spr[0].ctl;
		uwDmaCon = BITCLR | DMAF_RASTER;
	}
	// Disable/enable sprite DMA during hud
	copSetMove(&pBackList[WORLD_COP_VPHUD_DMAOFF_POS+1].sMove, &g_pCustom->dmacon, uwDmaCon);
	copSetMove(&pFrontList[WORLD_COP_VPHUD_DMAOFF_POS+1].sMove, &g_pCustom->dmacon, uwDmaCon);
	// Disable/enable crosshair sprite during hud
	copSetMove(&pBackList[WORLD_COP_VPHUD_DMAOFF_POS+2].sMove, pCrossCtl, 0);
	copSetMove(&pFrontList[WORLD_COP_VPHUD_DMAOFF_POS+2].sMove, pCrossCtl, 0);
}

static void hudDrawBar(
	UWORD uwBarY, UWORD uwValue, UWORD uwMaxValue, UBYTE ubColor
) {
	// TODO draw rects on only one bitplane
	const UWORD uwBarHeight = 4;
	const UWORD uwBarX = 71;
	const UWORD uwMaxBarWidth = 32;

	// Calculate color length
	UWORD uwCurrBarWidth = (uwMaxBarWidth*uwValue)/ uwMaxValue;

	// Black part of bar
	if(uwCurrBarWidth != uwMaxBarWidth) {
		blitRect(
			g_pHudBfr->pBack,	(WORD)(uwBarX + uwCurrBarWidth), (WORD)uwBarY,
			(WORD)(uwMaxBarWidth - uwCurrBarWidth), uwBarHeight, 0
		);
	}

	// Colored part of bar
	if(uwCurrBarWidth) {
		blitRect(
			g_pHudBfr->pBack, (WORD)uwBarX, (WORD)uwBarY,
			(WORD)uwCurrBarWidth, (WORD)uwBarHeight, ubColor
		);
	}
}

static void hudDrawTeamScore(FUBYTE fubTeam) {
	const UWORD uwTicketX = 2+72+2;
	const UWORD uwTicketY[2] = {2+35+3, 2+35+3+5+4};
	const UBYTE pTeamColors[2] = {12, 10};
	char szSpawnBfr[6];
	blitRect(g_pHudBfr->pBack, (WORD)uwTicketX, (WORD)uwTicketY[fubTeam], 26, 5, 0);
	sprintf(szSpawnBfr, "%5hu", g_pTeams[fubTeam].uwTicketsLeft);
	fontFillTextBitMap(s_pHudFont, s_pSpawnTextBfr, szSpawnBfr);
	fontDrawTextBitMap(
		g_pHudBfr->pBack, s_pSpawnTextBfr, uwTicketX, uwTicketY[fubTeam],
		pTeamColors[fubTeam], FONT_COOKIE | FONT_LAZY
	);
	s_uwPrevTickets[fubTeam] = g_pTeams[fubTeam].uwTicketsLeft;
}

void hudUpdate(void) {
	if(s_fubHudState != s_fubHudPrevState) {
		blitCopy(
			s_pHudPanels[s_fubHudState], 0, 0, g_pHudBfr->pBack, 2, 2,
			104, (WORD)s_pHudPanels[0]->Rows, MINTERM_COOKIE, 0xFF
		);
	}
	if(s_fubHudState == HUD_STATE_DRIVING) {
		// TODO one thing per frame, HP - always
		tVehicle *pVehicle = &g_pLocalPlayer->sVehicle;
		tVehicleType *pType = &g_pVehicleTypes[g_pLocalPlayer->ubCurrentVehicleType];

		// Draw bars
		const UWORD uwBarLifeY = 5;
		const UWORD uwBarAmmoY = 13;
		const UWORD uwBarFuelY = 21;
		hudDrawBar(uwBarLifeY, pVehicle->ubLife, pType->ubMaxLife, 4);
		if(s_fubHudPrevState != s_fubHudState) {
			hudDrawBar(uwBarAmmoY, pVehicle->ubBaseAmmo, pType->ubMaxBaseAmmo, 8);
			hudDrawBar(uwBarFuelY, pVehicle->ubFuel, pType->ubMaxFuel, 11);
		}
		else if(s_fubFrame == 0 || s_fubFrame == 25) {
			hudDrawBar(uwBarAmmoY, pVehicle->ubBaseAmmo, pType->ubMaxBaseAmmo, 8);
		}
		else if(s_fubFrame == 1 || s_fubFrame == 26) {
			hudDrawBar(uwBarFuelY, pVehicle->ubFuel, pType->ubMaxFuel, 11);
		}
	}

	// Update ticket count
	if(s_fubHudPrevState != s_fubHudState) {
		hudDrawTeamScore(TEAM_BLUE);
		hudDrawTeamScore(TEAM_RED);
	}
	else {
		if(s_fubFrame == 30 && s_uwPrevTickets[TEAM_BLUE] != g_pTeams[TEAM_BLUE].uwTicketsLeft) {
			hudDrawTeamScore(TEAM_BLUE);
		}
		else if(s_fubFrame == 40 && s_uwPrevTickets[TEAM_RED] != g_pTeams[TEAM_RED].uwTicketsLeft) {
			hudDrawTeamScore(TEAM_RED);
		}
	}
	if(s_fubFrame == 2 || s_fubFrame == 27) {
		consoleUpdate();
	}

	s_fubHudPrevState = s_fubHudState;
	++s_fubFrame;
	if(s_fubFrame >= 50) {
		s_fubFrame = 0;
	}
}

void hudDestroy(void) {
	consoleDestroy();
	fontDestroyTextBitMap(s_pSpawnTextBfr);

	bitmapDestroy(s_pHudPanels[HUD_STATE_DRIVING]);
	bitmapDestroy(s_pHudPanels[HUD_STATE_SELECTING]);
	// VPort & simpleBuffer are destroyed by g_pGameView
}
