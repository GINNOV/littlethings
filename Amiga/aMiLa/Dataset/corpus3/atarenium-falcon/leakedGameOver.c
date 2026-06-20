#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/joy.h>
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/managers/game.h>
#include <ace/utils/palette.h>
#include <stdio.h>
#include <ace/managers/state.h>
#include <ace/managers/blit.h>
#include <ace/utils/font.h>
#include "enum.h"

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;

extern tState g_sStateMenu;
extern tStateManager *g_pStateMachineGame;

extern BYTE startingCoal;

static tFont *s_pFont;
static tTextBitMap *s_pBmText;

#define TXT_LINE_COUNT 9

const char *s_pLines3[TXT_LINE_COUNT] = {
    "if (leaked capacitor == 2){",
    "amigaModeDestroy(); ",
    "}",
    "// WTF   N N N N N",
    "NO AMIGA SPIRIT FROM YOU I SMELL.",
    "LEAKED CAPACITOR NO GOOD IMPROVEMENT IS.",
    "SPACESHIP WICHER OF OURS YOU DESTROYED.",
    "MAY THE WEAKNESS OF ATARI BE WITH YOU.",
    "CHEATER. EAT COAL."};

void waitFrames();

extern BYTE youWin;
extern BYTE capacitors;
extern BYTE excesscoal;


extern tAmigaMode amigaMode;

void clearTiles();

void stateLeakedGameOverCreate(void){

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


s_pVpManager = simpleBufferCreate(0,
    TAG_SIMPLEBUFFER_VPORT, s_pVp,
    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
    TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
    TAG_END
);

s_pFont = fontCreate("data/topaz.fnt");
s_pBmText = fontCreateTextBitMap(TEXT_BITMAP_WIDTH, s_pFont->uwHeight);


systemUnuse();
joyOpen();
keyCreate();

blitRect(s_pVpManager->pBack, 0, 0, 320, 128, 21);
blitRect(s_pVpManager->pBack, 0, 128, 320, 128, 21);

  for (UBYTE i = 0; i < TXT_LINE_COUNT; ++i)
  {
    fontFillTextBitMap(s_pFont, s_pBmText, s_pLines3[i]);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 10, (i * 9) + 10, 23, FONT_COOKIE);
  }

viewLoad(s_pView);

}

void stateLeakedGameOverLoop(void){
	joyProcess();
	keyProcess();

	if(joyUse(JOY1_FIRE) || keyUse(KEY_RETURN)) {
    clearTiles();
		stateChange(g_pStateMachineGame, &g_sStateMenu);
		return;
  }

	viewProcessManagers(s_pView);
	copProcessBlocks();
	waitFrames(s_pVp, 1, 200);
}

void stateLeakedGameOverDestroy(void){
	systemUse();
	joyClose();
	keyDestroy();
	
  viewDestroy(s_pView);
}


tState g_sStateLeakedGameOver = {
  .cbCreate = stateLeakedGameOverCreate,
  .cbLoop = stateLeakedGameOverLoop,
  .cbDestroy = stateLeakedGameOverDestroy,
  .cbSuspend = 0,
  .cbResume = 0,
  .pPrev = 0
};
