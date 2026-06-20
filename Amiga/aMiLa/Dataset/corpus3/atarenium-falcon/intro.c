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

#define INTRO_LINE_COUNT 35

enum StatesIntro
{
  STATE_INTRO_PAGE1,
  STATE_INTRO_PAGE2,
  STATE_INTRO_WAIT,
};

static enum StatesIntro s_eState;

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;

extern tState g_sStateGame;
extern tStateManager *g_pStateMachineGame;

// TEMPORARY FOR SHORTCUT GAMEPLAY TESTING
void blitBlueAtariScreen2(void){
    blitRect(s_pVpManager->pBack, 0, 0, 320, 128, 21);
    blitRect(s_pVpManager->pBack, 0, 128, 320, 128, 21);
}

void blitBlueAtariScreen();

static tFont *s_pFont;
static tTextBitMap *s_pBmText;

BYTE page = 0;
BYTE lineCount = 0;
BYTE introWaitTime = 0;
BYTE page2CleanUp = 0;

const char *IntroContinue = "(Fire or Return to continue)";

const char *s_pLines[INTRO_LINE_COUNT] = {
    "Captain Tramiel, our planet was attacked by",
    "treacherous Great Miner and his race of",
    "Amigans. Almost all coal supplies for our",
    "Atari are gone.",
    "Renton - Minister of Mining is reporting",
    "that natural coal deposits are almost",
    "depleted and most of our miners fell to a",
    "strange disease and must remain qurantined.",
    "There is nobody left to work in mines.",
    "If we run out of coal for our Ataris we",
    "face the apocalypse of punch out tickets.",
    "Scouting ROBBOts we sent out into space",
    "did not return. ",
    "We need your help Captain Tramiel.",
    "You have to go to Amigans Space Sector",
    "(ASS), retrieve any surviving ROBBOts ",
    "and reclaim our coal supplies. ",
    "Beware of their secret weapon",
    "- 16bit processing power, 32-color graphics",
    "and 4-channel sound.",
    "Don't let them foul you.",

    "We are giving you masterpiece of our space",
    "engineery. Our newest spacecraft named",
    "ATARENIUM FALCON. ",
    "Fully automated. The core of the craft is",
    "Atari Falcon running on highly efficient ",
    "eco pea-coal. It is also equipped with",
    "external automated arm.",
    "This is experimental prototype. Now GO!",
    "One more thing Captain... While you traverse",
    "enemy territory try to collect as many",
    "capacitors as you can so the Amigans can't",
    "replace leaking ones in their Amigas.",
    "Let electrolyte eat out their PCBs.",
    "HAR! HAR! HAR!"};

void printIntroPage(UBYTE pageNr){ // p1:21 p2:14 
    UBYTE totalLines;
    UBYTE page2setup;
    switch (pageNr){
        case 1:
        totalLines = 21;
        page2setup = 0;
        break;
        case 2:
        totalLines = 14;
        page2setup = 21;
        break;
    }
    fontFillTextBitMap(s_pFont, s_pBmText, s_pLines[lineCount + page2setup]);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 10, (lineCount * 9) + 10, 23, FONT_COOKIE);
    ++lineCount;
    if (lineCount == totalLines)
    {
      lineCount = 0;
      fontFillTextBitMap(s_pFont, s_pBmText, IntroContinue);
      fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 10, 200, 23, FONT_COOKIE);
    }
    s_eState = STATE_INTRO_WAIT;
}

void stateIntroCreate(void)
{

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

  s_pVpManager = simpleBufferCreate(0,
                                    TAG_SIMPLEBUFFER_VPORT, s_pVp,
                                    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
                                    TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
                                    TAG_END);

  systemUnuse();
  joyOpen();
  keyCreate();
  viewLoad(s_pView);

  s_eState = STATE_INTRO_PAGE1;

  s_pFont = fontCreate("data/topaz.fnt");
  s_pBmText = fontCreateTextBitMap(TEXT_BITMAP_WIDTH, s_pFont->uwHeight);

  blitBlueAtariScreen2();
}

  void stateIntroLoop(void)
  {
    joyProcess();
    keyProcess();

    switch (s_eState)
    {

    case STATE_INTRO_PAGE1:
      printIntroPage(1);

    break;

  case STATE_INTRO_WAIT:
    ++introWaitTime;
    if (introWaitTime == 120 && page == 0)
    {
      introWaitTime = 0;
      s_eState = STATE_INTRO_PAGE1;
    }
    else if (introWaitTime == 120 && page == 1)
    {
      introWaitTime = 0;
      s_eState = STATE_INTRO_PAGE2;
    }
    break;

  case STATE_INTRO_PAGE2:
    if (page2CleanUp == 0)
    {
      page2CleanUp = 1;
      lineCount = 0;
      blitBlueAtariScreen2();
    }
    printIntroPage(2);
    break;
  }


  if (joyUse(JOY1_FIRE) || keyUse(KEY_RETURN))
  {
    if (page == 0)
    {
      ++page;
      lineCount = 0;
    }
    else if (page == 1)
    {
      page = 0;
      lineCount = 0;
      page2CleanUp = 0;
      stateChange(g_pStateMachineGame, &g_sStateGame);
      return;
    }

    viewProcessManagers(s_pView);
    copProcessBlocks();
    vPortWaitForEnd(s_pVp);
  }
  }

  void stateIntroDestroy(void)
  {
    systemUse();
    fontDestroy(s_pFont);
    fontDestroyTextBitMap(s_pBmText);
    joyClose();
    keyDestroy();
    viewDestroy(s_pView);
  }

  tState g_sStateIntro = {
      .cbCreate = stateIntroCreate,
      .cbLoop = stateIntroLoop,
      .cbDestroy = stateIntroDestroy,
      .cbSuspend = 0,
      .cbResume = 0,
      .pPrev = 0};
