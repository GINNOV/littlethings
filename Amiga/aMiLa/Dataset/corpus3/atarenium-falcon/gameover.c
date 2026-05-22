#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/joy.h>
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/managers/game.h>
#include <ace/utils/palette.h>
#include <stdio.h>
#include <ace/managers/state.h>
#include <ace/managers/blit.h>
#include "enum.h"

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;
static tBitMap *s_pGameOver;

extern tState g_sStateMenu;
extern tStateManager *g_pStateMachineGame;

void waitFrames();

void stateGameOverCreate(void){

s_pView = viewCreate(0,
    TAG_VIEW_COPLIST_MODE, COPPER_MODE_BLOCK,
    TAG_VIEW_GLOBAL_CLUT, 1,
    TAG_END
);

s_pVp = vPortCreate(0,
    TAG_VPORT_VIEW, s_pView,
    TAG_VPORT_BPP, 5,
    TAG_END
);
// Paleta z falkona
paletteLoad("data/falkon.plt", s_pVp->pPalette, 32);


s_pGameOver = bitmapCreateFromFile("data/gej_ower.bm", 0);

s_pVpManager = simpleBufferCreate(0,
    TAG_SIMPLEBUFFER_VPORT, s_pVp,
    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
    TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
    TAG_END
);

  blitRect(s_pVpManager->pBack, 0, 0, 320, 128, 0);
  blitRect(s_pVpManager->pBack, 0, 128, 320, 128, 0);

bitmapLoadFromFile(s_pVpManager->pBack, "data/gej_ower.bm", 75, 54);

systemUnuse();
joyOpen();
keyCreate();
viewLoad(s_pView);

}

void stateGameOverLoop(void){
	joyProcess();
	keyProcess();

	if(joyUse(JOY1_FIRE) || keyUse(KEY_RETURN)) {
		stateChange(g_pStateMachineGame, &g_sStateMenu);
		return;
  }

	viewProcessManagers(s_pView);
	copProcessBlocks();
	waitFrames(s_pVp, 1, 200);
}

void stateGameOverDestroy(void){
	systemUse();
	joyClose();
	keyDestroy();
	bitmapDestroy(s_pGameOver);
  viewDestroy(s_pView);
}


tState g_sStateGameOver = {
  .cbCreate = stateGameOverCreate,
  .cbLoop = stateGameOverLoop,
  .cbDestroy = stateGameOverDestroy,
  .cbSuspend = 0,
  .cbResume = 0,
  .pPrev = 0
};
