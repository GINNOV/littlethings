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
#include <ace/managers/ptplayer.h>

#define FLASH_START_FRAME_A 1
#define FLASH_START_FRAME_C 10
#define FLASH_START_FRAME_E 30
#define FLASH_START_FRAME_PWR 50
#define FLASH_RATIO_INACTIVE -1
#define LMC_COLOR_COUNT 5

enum StatesLmcAce
{
  STATE_LMC_FADE_IN,
  STATE_LMC_WAIT,
  STATE_LMC_FADE_OUT,
  STATE_ACE_FLASH,
  STATE_ACE_FADE_OUT,
};

static enum StatesLmcAce s_eState;

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;

static tBitMap *s_pLMC;
static tBitMap *s_pACE;

static tPtplayerSfx *s_pACEsfx;
static tPtplayerSfx *s_pLMCsfx;

//extern tState g_sStateMenu;
extern tStateManager *g_pStateMachineGame;
extern tState g_sStateWungiel;

static UWORD s_pPaletteLMC_ACE[LMC_COLOR_COUNT];

extern UBYTE creditsControl;

static tCopBlock *s_pAceBlocks[30];

static const UWORD s_pAceColors[] = {
  0xA00, 0xA00,
  0xC00, 0xC00, 0xC00,
  0xD40, 0xD40,
  0xE80, 0xE80, 0xE80,
  0xFB2, 0xFB2,
  0xFE5, 0xFE5, 0xFE5,
  0xCC2, 0xCC2,
  0x990, 0x990, 0x990,
  0x494, 0x494,
  0x099, 0x099, 0x099,
  0x077, 0x077,
  0x055, 0x055,
  0x055
};

static const UWORD s_uwColorPowered = 0x343;
static UWORD s_uwFlashFrame;
static BYTE s_bRatioFade = 0;
static BYTE s_bRatioFlashA;
static BYTE s_bRatioFlashC;
static BYTE s_bRatioFlashE;
static BYTE s_bRatioFlashPwr;

UBYTE waitTime = 0;
UBYTE isDrawnOnce = FALSE;  // to draw gfx one time and then do fades in loop
                            // at 0 draw LMC, at 1 draw ACE

void blitBlackBacground(void)
{
  blitRect(s_pVpManager->pBack, 0, 0, 320, 128, 0);
  blitRect(s_pVpManager->pBack, 0, 128, 320, 128, 0);
}

void stateLmcAceCreate(void)
{

  s_pView = viewCreate(0,
                       TAG_VIEW_COPLIST_MODE, COPPER_MODE_BLOCK,
                       TAG_VIEW_GLOBAL_CLUT, 1,
                       TAG_END);

  s_pVp = vPortCreate(0,
                      TAG_VPORT_VIEW, s_pView,
                      TAG_VPORT_BPP, 3,
                      TAG_END);

  s_pVpManager = simpleBufferCreate(0,
                                    TAG_SIMPLEBUFFER_VPORT, s_pVp,
                                    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
                                    TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
                                    TAG_END);

  for(UBYTE i = 0; i < 30; ++i) {
    s_pAceBlocks[i] = copBlockCreate(s_pView->pCopList, 3, 0, s_pView->ubPosY + 95 + i * 2);
    copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[1], 0x000);
    copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[2], 0x000);
    copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[3], 0x000);
    copBlockDisable(s_pView->pCopList, s_pAceBlocks[i]);
  }

  systemUnuse();
  joyOpen();
  keyCreate();
  viewLoad(s_pView);
  ptplayerCreate(1);

  s_bRatioFade = 0;
  waitTime = 0;
  isDrawnOnce = FALSE;

  s_eState = STATE_LMC_FADE_IN;

  paletteLoad("data/lmcpalette.plt", s_pPaletteLMC_ACE, LMC_COLOR_COUNT);

  s_pLMC = bitmapCreateFromFile("data/LMC.bm", 0);
  s_pACE = bitmapCreateFromFile("data/ACE.bm", 0);

  s_pACEsfx = ptplayerSfxCreateFromFile("data/AceSample.sfx");
  s_pLMCsfx = ptplayerSfxCreateFromFile("data/Morse_LMC8000.sfx");
}

static UWORD blendColors(UWORD uwColorSrc, UWORD uwColorDst, UBYTE ubRatio)
{
  BYTE bSrcR = (uwColorSrc >> 8);
  BYTE bSrcG = ((uwColorSrc >> 4) & 0xF);
  BYTE bSrcB = ((uwColorSrc >> 0) & 0xF);
  BYTE bDstR = (uwColorDst >> 8);
  BYTE bDstG = ((uwColorDst >> 4) & 0xF);
  BYTE bDstB = ((uwColorDst >> 0) & 0xF);
  UBYTE ubCurrentR = bSrcR + ((bDstR - bSrcR) * ubRatio) / 15;
  UBYTE ubCurrentG = bSrcG + ((bDstG - bSrcG) * ubRatio) / 15;
  UBYTE ubCurrentB = bSrcB + ((bDstB - bSrcB) * ubRatio) / 15;
  UWORD uwColorOut = (ubCurrentR << 8) | (ubCurrentG << 4) | ubCurrentB;
  return uwColorOut;
}

void stateLmcAceLoop(void)
{
  joyProcess();
  keyProcess();

  switch (s_eState)
  {
  case STATE_LMC_FADE_IN:
    if (isDrawnOnce == FALSE)  // draw gfx and then continue with fade in
    {
      isDrawnOnce = TRUE;
      paletteDim(s_pPaletteLMC_ACE, s_pVp->pPalette, LMC_COLOR_COUNT, 0); // 0 - czarno, 15 - pe�na paleta
      viewUpdateCLUT(s_pView);

      ptplayerSfxPlay(s_pLMCsfx, -1, 64, 100);
      blitBlackBacground();
      blitCopy(
        s_pLMC, 0, 0, s_pVpManager->pBack, 104, 40,
        bitmapGetByteWidth(s_pLMC) * 8, s_pLMC->Rows, MINTERM_COOKIE
      );
    }

    paletteDim(s_pPaletteLMC_ACE, s_pVp->pPalette, LMC_COLOR_COUNT, s_bRatioFade); // 0 - czarno, 15 - pe?na paleta
    viewUpdateCLUT(s_pView);                             // we? palet? z viewporta i wrzu? j? na ekran
    ++s_bRatioFade;
    if (s_bRatioFade > 15)
    {
      s_eState = STATE_LMC_WAIT;
    }
    break;

  case STATE_LMC_WAIT:
    ++waitTime;
    if (waitTime == 200)
    {
      waitTime = 0;
      s_eState = STATE_LMC_FADE_OUT;
    }
    break;

  case STATE_LMC_FADE_OUT:
    paletteDim(s_pPaletteLMC_ACE, s_pVp->pPalette, LMC_COLOR_COUNT, s_bRatioFade); // 0 - czarno, 15 - pe?na paleta
    viewUpdateCLUT(s_pView);                             // we? palet? z viewporta i wrzu? j? na ekran
    --s_bRatioFade;
    if (s_bRatioFade == 0)
    {
      isDrawnOnce = FALSE;
      s_eState = STATE_ACE_FLASH;
    }
    break;

  case STATE_ACE_FLASH:
    if (isDrawnOnce == FALSE)
    {
      s_uwFlashFrame = 1;
      s_bRatioFlashA = FLASH_RATIO_INACTIVE;
      s_bRatioFlashC = FLASH_RATIO_INACTIVE;
      s_bRatioFlashE = FLASH_RATIO_INACTIVE;
      s_bRatioFlashPwr = FLASH_RATIO_INACTIVE;
      for(UBYTE i = 0; i < 30; ++i) {
        s_pAceBlocks[i]->uwCurrCount = 0;
        copBlockEnable(s_pView->pCopList, s_pAceBlocks[i]);
      }
      isDrawnOnce = TRUE;
      ptplayerSfxPlay(s_pACEsfx, -1, 64, 100);
      blitBlackBacground();
      blitCopy(
        s_pACE, 0, 0, s_pVpManager->pBack, 80, 95,
        bitmapGetByteWidth(s_pACE) * 8, s_pACE->Rows, MINTERM_COOKIE
      );
    }
    else {
      ++s_uwFlashFrame;
    }

    if(s_uwFlashFrame >= FLASH_START_FRAME_A) {
      s_bRatioFlashA = MIN(15, s_bRatioFlashA + 1);
    }
    if(s_uwFlashFrame >= FLASH_START_FRAME_C) {
      s_bRatioFlashC = MIN(15, s_bRatioFlashC + 1);
    }
    if(s_uwFlashFrame >= FLASH_START_FRAME_E) {
      s_bRatioFlashE = MIN(15, s_bRatioFlashE + 1);
    }
    if(s_uwFlashFrame >= FLASH_START_FRAME_PWR) {
      s_bRatioFlashPwr = MIN(15, s_bRatioFlashPwr + 1);
    }
    if (s_uwFlashFrame >= 215) {
      s_bRatioFade = 15;
      s_eState = STATE_ACE_FADE_OUT;
    }

    for(UBYTE i = 0; i < 30; ++i) {
      s_pAceBlocks[i]->uwCurrCount = 0;
      if(s_bRatioFlashA != FLASH_RATIO_INACTIVE) {
        copMove(
          s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[1],
          blendColors(0xFFF, s_pAceColors[i], s_bRatioFlashA)
        );
      }
      if(s_bRatioFlashC != FLASH_RATIO_INACTIVE) {
        copMove(
          s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[2],
          blendColors(0xFFF, s_pAceColors[i], s_bRatioFlashC)
        );
      }
      if(i < 9) {
        // Watch out for "E" flash interfering here
        UWORD uwColor = (
          s_bRatioFlashPwr != FLASH_RATIO_INACTIVE ?
          blendColors(0xFFF, s_uwColorPowered, s_bRatioFlashPwr) : 0
        );
        copMove(s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[3], uwColor);
      }
      else {
        if(s_bRatioFlashE != FLASH_RATIO_INACTIVE) {
          copMove(
            s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[3],
            blendColors(0xFFF, s_pAceColors[i], s_bRatioFlashE)
          );
        }
      }
    }
    break;

  case STATE_ACE_FADE_OUT:
    for(UBYTE i = 0; i < 30; ++i) {
      s_pAceBlocks[i]->uwCurrCount = 0;
      copMove(
        s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[1],
        blendColors(0x000, s_pAceColors[i], s_bRatioFade)
      );
      copMove(
        s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[2],
        blendColors(0x000, s_pAceColors[i], s_bRatioFade)
      );
      copMove(
        s_pView->pCopList, s_pAceBlocks[i], &g_pCustom->color[3],
        blendColors(0x000, i < 9 ? s_uwColorPowered : s_pAceColors[i], s_bRatioFade)
      );
    }

    --s_bRatioFade;
    if (s_bRatioFade == 0)
    {
      isDrawnOnce = FALSE;
      stateChange(g_pStateMachineGame, &g_sStateWungiel);
      return;
    }
    break;
  }

  if (joyUse(JOY1_FIRE) || keyUse(KEY_RETURN)){
    //if (creditsControl == 0)
    //{
      //stateChange(g_pStateMachineGame, &g_sStateIntro);
      //return;
    //}
    //else if (creditsControl == 1)
    //{
      stateChange(g_pStateMachineGame, &g_sStateWungiel);
      return;
    //}
  }

  viewProcessManagers(s_pView);
  copProcessBlocks();
  vPortWaitForEnd(s_pVp);
}

void stateLmcAceDestroy(void)
{
  systemUse();
  bitmapDestroy(s_pLMC);
  bitmapDestroy(s_pACE);
  joyClose();
  keyDestroy();
  viewDestroy(s_pView);
  ptplayerSfxDestroy(s_pACEsfx);
  ptplayerSfxDestroy(s_pLMCsfx);

  ptplayerDestroy();
}

tState g_sStateLmcAce = {
    .cbCreate = stateLmcAceCreate,
    .cbLoop = stateLmcAceLoop,
    .cbDestroy = stateLmcAceDestroy,
    .cbSuspend = 0,
    .cbResume = 0,
    .pPrev = 0};
