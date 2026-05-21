#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/joy.h>
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/managers/game.h>
#include <ace/utils/palette.h>
#include <ace/utils/font.h>
#include <stdio.h>
#include <ace/managers/state.h>
#include <ace/utils/chunky.h>
#include <ace/managers/blit.h>
#include <ace/managers/rand.h>
#include <fixmath/fix16.h>

typedef struct {
	WORD wX;
	WORD wY;
	UWORD uwScreenX;
	UWORD uwScreenY;
	UBYTE ubStep;
	UBYTE *pClearPos;
} tStar;

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManagerMenu;

#define STAR_COUNT 60
#define STAR_STEPS 64

extern tState g_sStateIntro;
extern tStateManager *g_pStateMachineGame;

UBYTE cheatmodeEnablerWhenEqual3 = 0;
UBYTE secondCheatEnablerWhenEqual3 = 0;
UBYTE thirdCheatEnablerWhenEqual3 = 0;
UBYTE cheatModeStarColor = 0;
BOOL tutorialLevelsSkip = FALSE;
BOOL continueCheck = FALSE;
UBYTE amigaModeForContinueCheck = FALSE;

UBYTE pxColor[] = {1, 2, 3, 4, 5};
UBYTE bgColor = 0;

tStar s_pStars[STAR_COUNT];

static void starInit(void) {
	for(UBYTE i = 0; i < STAR_COUNT; ++i) {
		fix16_t fAngle = (2 * fix16_pi * i) / STAR_COUNT; // angle in rads: 2pi is 360deg
		s_pStars[i].wX = fix16_to_int(fix16_mul(fix16_sin(fAngle), fix16_from_int(150)));
		s_pStars[i].wY = fix16_to_int(fix16_mul(fix16_cos(fAngle), fix16_from_int(110)));
		s_pStars[i].ubStep = uwRandMax(STAR_STEPS - 1);
		s_pStars[i].uwScreenX = 160 + (s_pStars[i].wX * s_pStars[i].ubStep) / STAR_STEPS;
		s_pStars[i].uwScreenY = 128 + (s_pStars[i].wY * s_pStars[i].ubStep) / STAR_STEPS;
		s_pStars[i].pClearPos = &s_pVpManagerMenu->pBack->Planes[2][0];
	}
}

static void starUpdate(tStar *pStar) {
	pStar->ubStep += 1;
	pStar->uwScreenX = 160 + (pStar->wX * pStar->ubStep) / STAR_STEPS;
	pStar->uwScreenY = 128 + (pStar->wY * pStar->ubStep) / STAR_STEPS;
	if(pStar->uwScreenX < 320 && pStar->uwScreenY <= 238) {
		return;
	}
	pStar->ubStep = uwRandMax(STAR_STEPS - 1);
	pStar->uwScreenX = 160 + (pStar->wX * pStar->ubStep) / STAR_STEPS;
	pStar->uwScreenY = 128 + (pStar->wY * pStar->ubStep) / STAR_STEPS;
}

static void starProcess(void) {
	// delay for a500
	static UBYTE ubTick = 0;
	if(ubTick == 0) {
		ubTick = 1;
		return;
	}

	ubTick = 0;
	UWORD uwBpr = s_pVpManagerMenu->pBack->BytesPerRow;
	// clear bg below all stars
	for(tStar *pStar = &s_pStars[0]; pStar < &s_pStars[STAR_COUNT]; ++pStar) {
		starUpdate(pStar);
		*pStar->pClearPos = 0;
	}
	// draw and advance stars
	UBYTE *pPlane = s_pVpManagerMenu->pBack->Planes[2];
	for(tStar *pStar = &s_pStars[0]; pStar < &s_pStars[STAR_COUNT]; ++pStar) {
		pStar->pClearPos = &pPlane[pStar->uwScreenX / 8 + pStar->uwScreenY * uwBpr];
		*pStar->pClearPos |= 1 << (7 - (pStar->uwScreenX & 0x7));
	}
}

void cheatcodesCleanUp (void){      // can't clean up in game.c initialSetupDeclarationOfData()
	cheatmodeEnablerWhenEqual3 = 0;   // because it will turn off used cheats !
	secondCheatEnablerWhenEqual3 = 0;
	thirdCheatEnablerWhenEqual3 = 0;
}

void stateMenuCreate(void)
{
	cheatcodesCleanUp();
	tutorialLevelsSkip = FALSE;
	s_pView = viewCreate(0,
						 TAG_VIEW_COPLIST_MODE, COPPER_MODE_BLOCK,
						 TAG_VIEW_GLOBAL_CLUT, 1,
						 TAG_END);
	s_pVp = vPortCreate(0,
						TAG_VPORT_VIEW, s_pView,
						TAG_VPORT_BPP, 5,
						TAG_END);

	// Paleta z falkona
	paletteLoad("data/falkon.plt", s_pVp->pPalette, 32);

	s_pVpManagerMenu = simpleBufferCreate(0,
									  TAG_SIMPLEBUFFER_VPORT, s_pVp,
									  TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
									  TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
									  TAG_END);

	blitRect(s_pVpManagerMenu->pBack, 0, 0, 320, 128, 0);
    blitRect(s_pVpManagerMenu->pBack, 0, 128, 320, 128, 0);

  // logo starting 80 32
  // options       80 112
  //  lmc          80 240

	bitmapLoadFromFile(s_pVpManagerMenu->pBack, "data/menulogo.bm", 80, 32);
	bitmapLoadFromFile(s_pVpManagerMenu->pBack, "data/menuoptions.bm", 80, 112);
	bitmapLoadFromFile(s_pVpManagerMenu->pBack, "data/menulmc.bm", 80, 240);

	joyOpen();
	keyCreate();
	randInit(2184);
	starInit();
	systemUnuse();
	viewLoad(s_pView);

}

void stateMenuLoop(void)
{
	joyProcess();
	keyProcess();
	starProcess();

	if (keyUse(KEY_ESCAPE))
	{
		gameExit();
		return;
	}

	if (joyUse(JOY1_FIRE) || keyUse(KEY_RETURN))
	{
		stateChange(g_pStateMachineGame, &g_sStateIntro);
		return;
	}

	/*
	if (keyUse(KEY_I))
	{
		stateChange(g_pStateMachineGame, &g_sStateIntro);
		return;
	}
	if (keyUse(KEY_C))
	{
		stateChange(g_pStateMachineGame, &g_sStateCredits);
		return;
	}
	*/

	if (keyUse(KEY_W) && cheatmodeEnablerWhenEqual3 == 0){
		++cheatmodeEnablerWhenEqual3;
	}
	if (keyUse(KEY_T) && cheatmodeEnablerWhenEqual3 == 1){
		++cheatmodeEnablerWhenEqual3;
	}
	if (keyUse(KEY_F) && cheatmodeEnablerWhenEqual3 == 2){
		++cheatmodeEnablerWhenEqual3;
		cheatModeStarColor += 6 ;
	}
	if (keyUse(KEY_L) && secondCheatEnablerWhenEqual3 == 0){
		++secondCheatEnablerWhenEqual3;
	}
	if (keyUse(KEY_S) && secondCheatEnablerWhenEqual3 == 1){
		++secondCheatEnablerWhenEqual3;
	}
	if (keyUse(KEY_A) && secondCheatEnablerWhenEqual3 == 2){
		++secondCheatEnablerWhenEqual3;
		cheatModeStarColor += 6;
	}
	if (keyUse(KEY_V) && thirdCheatEnablerWhenEqual3 == 0){
		++thirdCheatEnablerWhenEqual3;
	}
	if (keyUse(KEY_P) && thirdCheatEnablerWhenEqual3 == 1){
		++thirdCheatEnablerWhenEqual3;
	}
	if (keyUse(KEY_R) && thirdCheatEnablerWhenEqual3 == 2){
		++thirdCheatEnablerWhenEqual3;
	}
	if (keyUse(KEY_X) && tutorialLevelsSkip == FALSE){
		tutorialLevelsSkip = TRUE;
	}
	if (keyUse(KEY_C) && continueCheck == FALSE){
		continueCheck = TRUE;
	}


	viewProcessManagers(s_pView);
	copProcessBlocks();
	vPortWaitForEnd(s_pVp);
}

void stateMenuDestroy(void)
{
	systemUse();
	viewDestroy(s_pView);
	joyClose();
	keyDestroy();
}

tState g_sStateMenu = {
	.cbCreate = stateMenuCreate,
	.cbLoop = stateMenuLoop,
	.cbDestroy = stateMenuDestroy,
	.cbSuspend = 0,
	.cbResume = 0,
	.pPrev = 0};
