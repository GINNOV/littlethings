#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/joy.h>
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/managers/game.h>
#include <ace/utils/palette.h>
#include <ace/utils/font.h>
#include <stdio.h>
#include <ace/managers/rand.h>
#include <ace/managers/state.h>
#include <ace/utils/custom.h>
#include <ace/managers/ptplayer.h>
#include <ace/utils/file.h>
#include "enum.h"
#include "levels.h"
#include "structures.h"

//------------------------------------------------------- gdzie� przed funkcjami
// zmienne trzymaj�ce adresy do viewa, viewporta, simple buffer managera
static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;
static tBitMap *s_pTiles;
static tBitMap *s_pTilesMask;
static tBitMap *s_pBg;
static tBitMap *s_pBgWithTile;
static tBitMap *s_pBgPortalGlow;
static tBitMap *s_pHUD;
static tBitMap *s_pAmiHUDblinkGreen;
static tBitMap *s_pAmiHUDblinkYellow;
static tBitMap *s_pFalconBg;
static tBitMap *s_pAnimBg;
static tBitMap *s_pRobbo;
static tBitMap *s_pRobboAnim;
static tBitMap *s_pSabermanTribute;
static tBitMap *s_pSabermanTributeMask;
static tPtplayerSfx *s_pFalkonEngineSound;
static tPtplayerSfx *s_pWicherEngineSound;
static tPtplayerSfx *s_pLadujWegiel;
static tPtplayerSfx *s_pPortal8000;
static tPtplayerSfx *s_pRobbo8000;
static tPtplayerSfx *s_pCapacitorSFX;
static tPtplayerSfx *s_pAtariExcessCoalTickSound;
static tCopBlock *copBlockBeforeHud, *copBlockAfterHud;

static tPtplayerMod *s_pMod;
static tPtplayerMod *s_pModAmbient;

static tFont *s_pFont;
static tFont *s_pGotekFont;
static tTextBitMap *s_pBmText;

static UWORD s_pPalette[32];

extern tStateManager *g_pStateMachineGame;
extern tState g_sStateMenu;
extern tState g_sStateGameOver;
extern tState g_sStateScore;
extern tState g_sStateGuruMastah;
extern tState g_sStateLeakedGameOver;

#define MAP_TILE_HEIGHT 7
#define MAP_TILE_WIDTH 10
#define FALCON_HEIGHT 32
#define ANIM_FRAME_COUNT 8

#define LAST_LEVEL_NUMBER 32

#define STARTING_COAL 10

char szMsg[50];  // do wyswietlania wegla na HUD
char szMsg2[50]; // do wyswietlania kondkow na HUD
char szMsg3[50];
char szMsg4[50];

char szLvl[50];

char *lineToPass1[50];
char *lineToPass2[50];
char szBuffer[50];

char szRobboMsg[80];
char *szRobbo1stLine = "ROBBO says:";
char *szCollisionMsg1stLine = "Collision course detected, ESP enabled.";
char *szCollisionMsg2ndLine = "1T of fuel used, danger avioded. Over.";
char *szTribute1stLine = "Golden Gumboot with BASIC Code strings for";
char *szTribute2ndLine = "Saberman - Great Atariman of the Galaxy.";

tMusicState musicPlay;
tAmigaMode amigaMode;

UBYTE kamyki[10][7];
UBYTE collectiblesAnim[10][7];

// managing the tiles position for blitting
UWORD pAnim[] = {0, 32, 64, 96, 128, 160, 192, 224};

struct collected col;
struct anim anim;
struct moveControls move;
struct coordinates coord;
struct flyingAnim flying;
struct stateControls state;
struct db db;
struct misc misc;

extern UBYTE cheatmodeEnablerWhenEqual3;
extern UBYTE secondCheatEnablerWhenEqual3;
extern UBYTE thirdCheatEnablerWhenEqual3;
extern BOOL tutorialLevelsSkip;
extern BOOL continueCheck;
extern UBYTE amigaModeForContinueCheck;

// HACKS
BOOL gameOverWhenAnotherCollisionHack = FALSE;
BOOL noFlyingWhenCountingCoalInPortalHack = FALSE;
BOOL noCheatLevelSkipWhenRobboMessageOn = FALSE;

BOOL robbo1stLineExceptionModificator = FALSE;
BOOL setGameOverInNextLoopIter = FALSE;

BOOL hudFullyUp = FALSE;


void initialSetupDeclarationOfData(void)
{
  state.falkonIdleControl = TRUE;
  state.stonehitAnimControl = FALSE; // if true then handling animation for stone and frame collision
  state.flyingAnimControl = FLY_OFF;
  state.hudScrollingControl = FALSE;
  state.levelScoreControl = LEVEL_SCORE_OFF;
  state.youWin = OFF;
  state.robboMsgCtrl = PRINT_ON_HUD;

  coord.falkonx = 0;
  coord.falkony = 0;
  coord.krawedzx = 0;
  coord.krawedzy = 0;
  coord.falkonFace = 0;

  move.kierunek = 0;
  move.kierunekHold = 0;
  move.stoneHit = FALSE;
  move.frameHit = FALSE;
  move.anotherHit = 0;

  flying.uwPosX = 0;
  flying.uwPosY = 0;
  flying.uwPreviousX = 0;
  flying.uwPreviousY = 0;
  flying.newPosX = 0;
  flying.newPosY = 0;
  flying.HitPosX = 0;
  flying.HitPosY = 0;
  flying.tempX = 0;
  flying.tempY = 0;

  misc.level = 1;
  misc.doubleBufferFrameControl = 2;
  misc.audioFadeIn = 0;
  misc.robboMsgNr = 0;
  misc.HUDfontColor = HUD_FONT_COLOR;
  misc.HUDcollisionMsg = 0;

  setGameOverInNextLoopIter = FALSE;
  gameOverWhenAnotherCollisionHack = FALSE;

  amigaMode = AMIGA_MODE_OFF;
  musicPlay = MUSIC_HEAVY;

  col.coal = STARTING_COAL;
  col.excesscoal = 0;
  col.capacitors = 0;
  col.robboMsgCount = 0;

  anim.robboFrame = 0;
  anim.robboTick = 0;
  anim.robboTempo = 24;

  anim.portalGlowTick = 0;
  anim.portalGlowFrame = 0;
  anim.portalGlowX = 0;
  anim.portalGlowY = 0;
  anim.portalTickTempo = PORTAL_TICK_TEMPO;

  anim.tickTempo = 8;
  anim.redCapacitorsAnimTileCheck = 0;
  anim.redCapacitorsAnimTick = 0;
  anim.blueCapacitorsAnimTileCheck = 0;
  anim.blueCapacitorsAnimTick = 0;

  anim.stonehitAnimTick = 0;
  anim.stonehitAnimFrame = 0;

  anim.flyingFrame = 0;
  anim.flyingTick = 0;
  anim.falkonIdle = 0;
  anim.idleFrame = 0;
  anim.falkonIdleTempo = 12;

  anim.hudTickTempo = AMIGA_HUD_TICK_TEMPO;
  anim.hudAnimTick = 0;
  anim.hudTickFrame = 0;
  
  anim.hudScrollingTick = 0;

  anim.levelScoreTick = 0;
  anim.levelAnimFrame = 0;
  anim.levelScoreTempo = LEVEL_SCORE_TEMPO;

  db.levelScoreDB = FALSE;
  db.portalGlowDB = FALSE;
  db.robbo = FALSE;
  db.hudAnimDB = FALSE;
}

void waitFrames(tVPort *pVPort, UBYTE ubHowMany)
{
  for (UBYTE i = 0; i < ubHowMany; ++i)
  {
    viewProcessManagers(pVPort->pView);
    copProcessBlocks();
    vPortWaitForEnd(pVPort);
  }
}

void portalGlowAnim(void) // animacja portalu na planszy
{
  blitCopy(s_pBg, anim.portalGlowX * 32, anim.portalGlowY * 32, s_pBgPortalGlow, 0, 0, 32, 32, MINTERM_COOKIE);                 // wytnij tlo w miejscu gdzie jest portal do s_pBgPortalGlow
  blitCopyMask(s_pTiles, anim.portalGlowFrame * 32, 352, s_pBgPortalGlow, 0, 0, 32, 32, (UWORD *)s_pTilesMask->Planes[0]); // wytnij klatke tile'a i doklej do s_pBgPortalGlow z zachowaniem transparentnosci - maska
  blitCopy(s_pBgPortalGlow, 0, 0, s_pVpManager->pBack, anim.portalGlowX * 32, anim.portalGlowY * 32, 32, 32, MINTERM_COPY);     // wrzuc gotowe s_pBgPortalGlow na ekran pBack
}

void endLevelFadeOut(void)
{
  UBYTE bRatioGame = 15; // zmienna do krokowego przyciszania muzyki i wygaszania ekranu

  for (UBYTE i = 0; i < 16; ++i) // 16 razy:
  {
    if (musicPlay == MUSIC_HEAVY) // jesli gra muzyka
    {
      ptplayerSetMasterVolume(bRatioGame * 4); // ustaw volume na wyliczony - zmienna bedzie sie zmiejszac wiec bedzie coraz ciszej
    }
    paletteDim(s_pPalette, s_pVp->pPalette, 32, bRatioGame); // przyciemnij palete o wartosc zmiennej
    viewUpdateCLUT(s_pView);                                 // aktualizuj ekran
    --bRatioGame;                                            // zmiejsz zmienna
    waitFrames(s_pVp, 4);            // zaczekaj 10 klatek
  }
}

void printOnHUD(void)
{
  if (amigaMode != AMIGA_MODE_OFF)
  {
    return;
  }

  blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 32, 32, MINTERM_COOKIE);
  sprintf(szMsg, "%d", col.coal);
  fontFillTextBitMap(s_pFont, s_pBmText, szMsg);
  fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 232, misc.HUDfontColor, FONT_COOKIE);
  blitCopy(s_pHUD, 188, 0, s_pVpManager->pBack, 188, 224, 32, 32, MINTERM_COOKIE);
  sprintf(szMsg2, "%d", col.capacitors);
  fontFillTextBitMap(s_pFont, s_pBmText, szMsg2);
  fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 190, 236, misc.HUDfontColor, FONT_COOKIE);
  blitCopy(s_pHUD, 128, 0, s_pVpManager->pBack, 128, 224, 32, 32, MINTERM_COOKIE);
  sprintf(szMsg3, "%d", col.excesscoal);
  fontFillTextBitMap(s_pFont, s_pBmText, szMsg3);
  fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 130, 232, misc.HUDfontColor, FONT_COOKIE);
  blitCopy(s_pHUD, 248, 0, s_pVpManager->pBack, 248, 224, 32, 32, MINTERM_COOKIE);
  sprintf(szMsg4, "%d", col.robboMsgCount);
  fontFillTextBitMap(s_pFont, s_pBmText, szMsg4);
  fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 250, 236, misc.HUDfontColor, FONT_COOKIE);
  // PRINTING LEVEL NUMBER TO BE DELETED !!!!
  //blitCopy(s_pHUD, 288, 0, s_pVpManager->pBack, 288, 224, 32, 32, MINTERM_COOKIE);
  //sprintf(szLvl, "%d", misc.level);
  //fontFillTextBitMap(s_pFont, s_pBmText, szLvl);
  //fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 290, 236, misc.HUDfontColor, FONT_COOKIE);
}

void gameOnResume(void)
{
  viewLoad(s_pView);
}

void drawTiles(void)
{

  BYTE x = 0;
  BYTE y = 0;
  BYTE endlineCounter = 0;

  coord.falkonx = 0;
  coord.falkony = 0;
  coord.krawedzx = 0;
  coord.krawedzy = 0;
  move.kierunek = 0;

  for (BYTE i = 0; i < 72; ++i)
  {
    ++endlineCounter;
    if (gameLevels[misc.level][i] == EMPTY_TILE) // ONLY BG 0x30
    {
      kamyki[x][y] = EMPTY_TILE_INT;
      blitCopy(s_pBg, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBg, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }

    else if (gameLevels[misc.level][i] == METEORITE) // RANDOM 1-3 METEORITE 0x33
    {
      kamyki[x][y] = METEORITE_INT;
      UBYTE ubStoneImg = ulRandMinMax(0, 2);
      blitCopy(s_pBg, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBg, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopyMask(s_pTiles, ubStoneImg * 32, 0, s_pVpManager->pBack, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
      blitCopyMask(s_pTiles, ubStoneImg * 32, 0, s_pVpManager->pFront, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
    }
    else if (gameLevels[misc.level][i] == COAL_2) // 2 COAL 0x34
    {
      kamyki[x][y] = COAL_2_INT;
      blitCopyMask(s_pTiles, 96, 0, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }

    else if (gameLevels[misc.level][i] == COAL_3) // 3 COAL  0x35
    {
      kamyki[x][y] = COAL_3_INT;
      blitCopyMask(s_pTiles, 128, 0, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }

    else if (gameLevels[misc.level][i] == COAL_4) // 4 COAL 0x36
    {
      kamyki[x][y] = COAL_4_INT;
      blitCopyMask(s_pTiles, 160, 0, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == COAL_5) // 5 COAL 0x37
    {
      kamyki[x][y] = COAL_5_INT;
      blitCopyMask(s_pTiles, 192, 0, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == CAPACITOR_BLUE) // BLUE CAPACITOR 0x38
    {
      kamyki[x][y] = CAPACITOR_BLUE_INT;
      collectiblesAnim[x][y] = CAPACITOR_BLUE_INT;
      blitCopyMask(s_pTiles, 0, 256, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == CAPACITOR_RED) // RED CAPACITOR 0x39
    {
      kamyki[x][y] = CAPACITOR_RED_INT;
      collectiblesAnim[x][y] = CAPACITOR_RED_INT;
      blitCopyMask(s_pTiles, 0, 288, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == PORTAL) // PORTAL 0x45
    {
      kamyki[x][y] = PORTAL_INT;
      anim.portalGlowX = x;
      anim.portalGlowY = y;
      blitCopyMask(s_pTiles, 0, 352, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == ROBBO) // ROBBO  0x52
    {
      kamyki[x][y] = ROBBO_INT;
      collectiblesAnim[x][y] = 11;
      blitCopyMask(s_pTiles, 0, 32, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == CAPACITOR_BROKEN) // BROKEN CAPACITOR 0x42
    {
      kamyki[x][y] = CAPACITOR_BROKEN_INT;
      blitCopyMask(s_pTiles, 224, 0, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == SABERMANS_GUMBOOT) // S -  SABERMAN TRIBUTE BOOT OF GLORY   0x53 
    {
      kamyki[x][y] = SABERMANS_GUMBOOT_INT;
      blitCopyMask(s_pSabermanTribute, 0, 0, s_pBgWithTile, x * 32, y * 32, 32, 32, (UWORD *)s_pSabermanTributeMask->Planes[0]);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pBack, x * 32, y * 32, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, x * 32, y * 32, s_pVpManager->pFront, x * 32, y * 32, 32, 32, MINTERM_COPY);
    }
    else if (gameLevels[misc.level][i] == FALCON_START_POSITION) // FALCON START POSITION 0x31
    {
      kamyki[x][y] = FALCON_START_POSITION_INT;
      coord.falkonx = x;
      coord.falkony = y;
      coord.krawedzx = x;
      coord.krawedzy = y;
      flying.uwPosX = coord.falkonx * 32;
      flying.uwPosY = coord.falkony * 32;
      flying.tempX = coord.falkonx;
      flying.tempY = coord.falkony;
    }

    ++x;
    if (endlineCounter == MAP_TILE_WIDTH)
    {
      endlineCounter = 0;
      x = 0;
      ++y;
    }
  }
  paletteDim(s_pPalette, s_pVp->pPalette, 32, 15);
  viewUpdateCLUT(s_pView);
}

void clearTiles(void) // czyszczenie planszy z tile'ow na koniec kazdego etapu zeby nie zostaly smieci
{
  blitCopy(s_pBg, 0, 0, s_pBgWithTile, 0, 0, 320, 128, MINTERM_COPY);    // podlozenie defaultowego tla do zmiennej
  blitCopy(s_pBg, 0, 128, s_pBgWithTile, 0, 128, 320, 96, MINTERM_COPY); // gdzie wklejam potem tile  -NIE KASOWAC KURWA !1
  for (UBYTE y = 0; y < MAP_TILE_HEIGHT; ++y)                            // w kazdym kolejnym rzedzie poziomym od gory
  {
    for (UBYTE x = 0; x < MAP_TILE_WIDTH; ++x) // na kazdej kolejnej pozycji od lewej do prawej
    {
      kamyki[x][y] = 0;           // wyczysc (wyzeruj) miejsce w tablicy trzymajace dana pozycje
      collectiblesAnim[x][y] = 0; // J.W. miejsce w tablicy kontrolujacej czy i jaki element jest animowany
    }
  }
}

void nextLevel(void) // ladowanie kolejnego levela
{
  noFlyingWhenCountingCoalInPortalHack = FALSE;  // release no fly hack !
  col.coal = 1;        // wegiel na start
  misc.audioFadeIn = 0; // zmienna do wlaczenia muzyki po wyciszeniu

  switch (misc.level)
  {

  case 5:                                                    // na 4 levelu:
    bitmapDestroy(s_pBg);                                    // usun dotychczasowe tlo
    bitmapDestroy(s_pBgWithTile);                            // JW. tlo z doklejonymi tile'ami
    s_pBg = bitmapCreateFromFile("data/tlo2.bm", 0);         // wczytaj nowe tlo
    s_pBgWithTile = bitmapCreateFromFile("data/tlo2.bm", 0); // JW dla zmiennej gdzie beda doklejane tile
    break;

  case 10: // calosc JW na 8 levelu
    bitmapDestroy(s_pBg);
    bitmapDestroy(s_pBgWithTile);
    s_pBg = bitmapCreateFromFile("data/tlo3.bm", 0);
    s_pBgWithTile = bitmapCreateFromFile("data/tlo3.bm", 0);
    break;

  case 15: // calosc JW na 12 levelu
    bitmapDestroy(s_pBg);
    bitmapDestroy(s_pBgWithTile);
    s_pBg = bitmapCreateFromFile("data/tlo4.bm", 0);
    s_pBgWithTile = bitmapCreateFromFile("data/tlo4.bm", 0);
    break;

  case 20: // calosc JW na 17 levelu
    bitmapDestroy(s_pBg);
    bitmapDestroy(s_pBgWithTile);
    s_pBg = bitmapCreateFromFile("data/tlo5.bm", 0);
    s_pBgWithTile = bitmapCreateFromFile("data/tlo5.bm", 0);
    break;
  case 25: // calosc JW na 22 levelu
    bitmapDestroy(s_pBg);
    bitmapDestroy(s_pBgWithTile);
    s_pBg = bitmapCreateFromFile("data/tlo6.bm", 0);
    s_pBgWithTile = bitmapCreateFromFile("data/tlo6.bm", 0);
    break;

  case LAST_LEVEL_NUMBER - 1: // jesli level jest przedostatni

    misc.robboMsgNr = LAST_LEVEL_NUMBER - 1; // robbo ma dac konkretna, przedostantnia informacje
    break;

  case LAST_LEVEL_NUMBER: // jesli level jest ostatni

    misc.robboMsgNr = LAST_LEVEL_NUMBER; // robbo ma dac ostatnia informacje
    break;
  }
  clearTiles();                                                                // czyszczenie planszy z tajli
  blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COPY);  // narysowanie huda
  blitCopy(s_pHUD, 0, 0, s_pVpManager->pFront, 0, 224, 320, 32, MINTERM_COPY); // jw drugi raz zeby nie mrygalo
  printOnHUD();                                                                // wyswietlenie cyfr na hudzie
  misc.doubleBufferFrameControl = 2;
  drawTiles(); // narysowanie tile'ow na planszy
}

void levelScoreDBredraw(void) // odrysowanie tego co w levelScore ale bez obliczen, tylko dla podwojnego buforowania
{
  if (amigaMode == AMIGA_MODE_OFF && state.levelScoreControl == LEVEL_SCORE_COUNT)
  {
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 32, 32, MINTERM_COOKIE);
    sprintf(szMsg, "%d", col.coal);
    fontFillTextBitMap(s_pFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 232, misc.HUDfontColor, FONT_COOKIE);
    blitCopy(s_pHUD, 128, 0, s_pVpManager->pBack, 128, 224, 32, 32, MINTERM_COOKIE);
    sprintf(szMsg3, "%d", col.excesscoal);
    fontFillTextBitMap(s_pFont, s_pBmText, szMsg3);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 130, 232, misc.HUDfontColor, FONT_COOKIE);
  }
  if (amigaMode != AMIGA_MODE_OFF && state.levelScoreControl == LEVEL_SCORE_COUNT)
  {
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg3, "RESERVE %d", col.excesscoal);
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg3);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
  }
  if (state.levelScoreControl == LEVEL_SCORE_PORTAL_OPEN)
  {
    blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, 32 * anim.levelAnimFrame, 320, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
    blitCopyMask(s_pTiles, 32, 192 + coord.falkonFace, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
  }
  if (state.levelScoreControl == LEVEL_SCORE_PORTAL_ANIM)
  {
    blitCopy(s_pBg, flying.uwPosX, flying.uwPosY, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, anim.levelAnimFrame * 32, 128 + coord.falkonFace, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
  }
  if (state.levelScoreControl == LEVEL_SCORE_PORTAL_CLOSE)
  {

    blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, 224 - (32 * anim.levelAnimFrame), 320, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
  }
  if (amigaMode == AMIGA_MODE_OFF && state.levelScoreControl == LEVEL_SCORE_NOCOAL)
  {
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 32, 32, MINTERM_COOKIE);
    sprintf(szMsg, "%d", col.coal);
    fontFillTextBitMap(s_pFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 232, misc.HUDfontColor, FONT_COOKIE);
    --misc.HUDfontColor;
  }
  if (amigaMode != AMIGA_MODE_OFF && state.levelScoreControl == LEVEL_SCORE_NOCOAL)
  {
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg3, "NO COAL");
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg3);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
    --misc.HUDfontColor;
  }
}

void levelScore(void) // WITH PORTAL OPEN AND FALKON IN PORTAL ANIM !!!
{
  if (state.levelScoreControl == LEVEL_SCORE_OFF)
  {
    return;
  }
  if (gameOverWhenAnotherCollisionHack == TRUE)
  {
    return;
  }
  if (col.coal == 1 && state.levelScoreControl == LEVEL_SCORE_COUNT)
  {
    state.levelScoreControl = LEVEL_SCORE_PORTAL_OPEN;
    state.falkonIdleControl = FALSE;
  }

  if (amigaMode == AMIGA_MODE_OFF && anim.levelScoreTick == anim.levelScoreTempo && state.levelScoreControl == LEVEL_SCORE_COUNT)
  {
    anim.levelScoreTick = 0;
    --col.coal;
    ++col.excesscoal;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pAtariExcessCoalTickSound, 3, 64, 100);
    }
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 32, 32, MINTERM_COOKIE);
    sprintf(szMsg, "%d", col.coal);
    fontFillTextBitMap(s_pFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 232, misc.HUDfontColor, FONT_COOKIE);
    blitCopy(s_pHUD, 128, 0, s_pVpManager->pBack, 128, 224, 32, 32, MINTERM_COOKIE);
    sprintf(szMsg3, "%d", col.excesscoal);
    fontFillTextBitMap(s_pFont, s_pBmText, szMsg3);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 130, 232, misc.HUDfontColor, FONT_COOKIE);
    
  }


  if (amigaMode != AMIGA_MODE_OFF && anim.levelScoreTick == anim.levelScoreTempo && state.levelScoreControl == LEVEL_SCORE_COUNT)
  {
    anim.levelScoreTick = 0;
    --col.coal;
    ++col.excesscoal;
    //blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    //sprintf(szMsg, "COAL %d", col.coal);
    //fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg);
    //fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, HUDfontColor, FONT_COOKIE);

    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg3, "RESERVE %d", col.excesscoal);
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg3);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
  }

  if (anim.levelScoreTick == anim.portalTickTempo && state.levelScoreControl == LEVEL_SCORE_PORTAL_OPEN)
  {
    anim.levelScoreTick = 0;
    blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, 32 * anim.levelAnimFrame, 320, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
    blitCopyMask(s_pTiles, 32, 192 + coord.falkonFace, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
    ++anim.levelAnimFrame;
    if (anim.levelAnimFrame == 8)
    {
      anim.levelAnimFrame = 0;
      state.levelScoreControl = LEVEL_SCORE_PORTAL_ANIM;
      if (musicPlay == MUSIC_AMBIENT_SFX){
      ptplayerSfxPlay(s_pPortal8000, 3, 64, 70);
      }
    }
  }

  if (anim.levelScoreTick == anim.portalTickTempo && state.levelScoreControl == LEVEL_SCORE_PORTAL_ANIM)
  {
    anim.levelScoreTick = 0;
    blitCopy(s_pBg, flying.uwPosX, flying.uwPosY, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, anim.levelAnimFrame * 32, 128 + coord.falkonFace, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);

    ++anim.levelAnimFrame;
    if (anim.levelAnimFrame == 8)
    {
      anim.levelAnimFrame = 0;
      state.levelScoreControl = LEVEL_SCORE_PORTAL_CLOSE;
    }
  }
  if (anim.levelScoreTick == anim.portalTickTempo && state.levelScoreControl == LEVEL_SCORE_PORTAL_CLOSE)
  {
    anim.levelScoreTick = 0;
    blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, 224 - (32 * anim.levelAnimFrame), 320, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
    ++anim.levelAnimFrame;
    if (anim.levelAnimFrame == 8)
    {
      anim.levelAnimFrame = 0;
      state.levelScoreControl = LEVEL_SCORE_END;
    }
  }

  if (amigaMode == AMIGA_MODE_OFF && anim.levelScoreTick == 64 && state.levelScoreControl == LEVEL_SCORE_NOCOAL)
  {
    anim.levelScoreTick = 0;
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 32, 32, MINTERM_COOKIE);
    sprintf(szMsg, "%d", col.coal);
    fontFillTextBitMap(s_pFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 232, misc.HUDfontColor, FONT_COOKIE);
    ++anim.levelAnimFrame;

    if (anim.levelAnimFrame == 2)
    {
      state.youWin = GAME_OVER;
      misc.HUDfontColor = HUD_FONT_COLOR;
      anim.levelAnimFrame = 0;
      state.levelScoreControl = LEVEL_SCORE_OFF;
      ptplayerStop();
    }
  }  

  if (amigaMode != AMIGA_MODE_OFF && state.levelScoreControl == LEVEL_SCORE_NOCOAL)
  {
    if (anim.levelScoreTick >= 0 && anim.levelScoreTick < 32){
      blitCopy(s_pAmiHUDblinkGreen, 0, 0, s_pVpManager->pBack, 288, 224, 32, 32, MINTERM_COOKIE);
    }
    if (anim.levelScoreTick >= 32 && anim.levelScoreTick < 64){
      blitCopy(s_pHUD, 288, 0, s_pVpManager->pBack, 288, 224, 32, 32, MINTERM_COOKIE);
      blitCopy(s_pAmiHUDblinkYellow, 0, 0, s_pVpManager->pBack, 288, 224, 32, 32, MINTERM_COOKIE);
      //blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);  // to byly standardowe swiatelka
      sprintf(szMsg3, "NO COAL");
      fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg3);
      fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
    }
    if (anim.levelScoreTick >= 64){
    anim.levelScoreTick = 0;
    ++anim.levelAnimFrame;
    }
    if (anim.levelAnimFrame == 4)
    {
      state.youWin = GAME_OVER;
      misc.HUDfontColor = HUD_FONT_COLOR;
      anim.levelAnimFrame = 0;
      state.levelScoreControl = LEVEL_SCORE_OFF;
      ptplayerStop();
    }
  }

  if (state.levelScoreControl == LEVEL_SCORE_END)
  {
    state.levelScoreControl = LEVEL_SCORE_OFF;
    endLevelFadeOut();
    state.falkonIdleControl = TRUE;

    ++misc.level;
    misc.holdLastLevelForContinue = misc.level;
    if (misc.level == LAST_LEVEL_NUMBER + 1)
    {
      ptplayerStop();
      state.youWin = END;
    }
    else
    {
      nextLevel();
    }
  }
}

void czyRamka(void)
{
  // tu jest funkcja sprawdzajaca czy sie chcemy wypierdolic za ekran i nie pozwalajaca na to
  switch (move.kierunek)
  {
  case 1:                    // gdy w prawo
    coord.krawedzx = coord.krawedzx + 1; // pole docelowe
    if (coord.krawedzx == 10)      // jesli za ekranem (bo fruwamy od 0 do 9)
    {
      coord.krawedzx = 9; // ustaw znow na 9
      coord.falkonx = 9;  // zatrzymaj falkona tez na 9
      move.frameHit = TRUE; // oznacz ze chciales walnac w ramke dla dalszego procesowania, animka i tak dalej
    }
    break;
  case 2: // JW w lewo
    coord.krawedzx = coord.krawedzx - 1;
    if (coord.krawedzx == -1)
    {
      coord.krawedzx = 0;
      coord.falkonx = 0;
      move.frameHit = TRUE;
    }
    break;
  case 3: // JW w gore
    coord.krawedzy = coord.krawedzy - 1;
    if (coord.krawedzy == -1)
    {
      coord.krawedzy = 0;
      coord.falkony = 0;
      move.frameHit = TRUE;
    }
    break;
  case 4: // JW w dol
    coord.krawedzy = coord.krawedzy + 1;
    if (coord.krawedzy == 7)
    {
      coord.krawedzy = 6;
      coord.falkony = 6;
      move.frameHit = TRUE;
    }
    break;
  }
}

void isThisStone(void)
{
  // funkcja sprawdzajaca przed wykonaniem ruchu czy chcemy wleciec w kamien

  BYTE stoneX = 0; // tu utrzymamy wspolrzedne docelowe
  BYTE stoneY = 0; // i porownamy czy jest na nich kamien

  switch (move.kierunek)
  {
  case 1:                             // gdy w prawo
    stoneX = coord.falkonx + 1;             // przypisz do stoneX docelowa wspolrzedna
    if (kamyki[stoneX][coord.falkony] == METEORITE_INT) // jesli pole docelowe to 3 (kamien)
    {
      move.stoneHit = TRUE; // oznacz ze chciales walnac w kamyk dla dalszego procesowania
    }
    break;
  case 2: // i tak dalej dla reszty kierunkow
    stoneX = coord.falkonx - 1;
    if (kamyki[stoneX][coord.falkony] == METEORITE_INT)
    {
      move.stoneHit = TRUE;
    }
    break;
  case 3:
    stoneY = coord.falkony - 1;
    if (kamyki[coord.falkonx][stoneY] == METEORITE_INT)
    {
      move.stoneHit = TRUE;
    }
    break;
  case 4:
    stoneY = coord.falkony + 1;
    if (kamyki[coord.falkonx][stoneY] == METEORITE_INT)
    {
      move.stoneHit = TRUE;
    }
    break;
  }
}

void robboScrollUp(void)
{
  if (state.robboMsgCtrl != HUD_SCROLL_UP || col.coal == 0)
  {
    return;
  }

  misc.doubleBufferFrameControl = 2;

  if (move.anotherHit >= 2 && hudFullyUp == TRUE)
  {
    state.robboMsgCtrl = HUD_ROBBO_MSG;
    state.hudScrollingControl = FALSE;
    anim.hudScrollingTick = 0;
    return;
  }

  if (state.hudScrollingControl == TRUE)
  {

    if (anim.hudScrollingTick == 0 || anim.hudScrollingTick == 1)
    {
      printOnHUD(); // HACK SIMILAR TO L.1979 - HUD DOUBLE BUFFER DISPLAY
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 248, 320, 8, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 4 || anim.hudScrollingTick == 5)
    {
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 240, 320, 16, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 8 || anim.hudScrollingTick == 9)
    {
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 232, 320, 24, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 12 || anim.hudScrollingTick == 13)
    {
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 16)
    {
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
      state.robboMsgCtrl = HUD_ROBBO_MSG;
      state.hudScrollingControl = FALSE;
      anim.hudScrollingTick = 0;
      hudFullyUp = TRUE;
    }
  }
}

void robboScrollDown(void)
{
  if (state.robboMsgCtrl != HUD_SCROLL_DOWN)
  {
    return;
  }

  hudFullyUp = FALSE;
  misc.doubleBufferFrameControl = 2;
  if (state.hudScrollingControl == TRUE)
  {

    if (anim.hudScrollingTick == 0 || anim.hudScrollingTick == 1)
    {
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 8, MINTERM_COOKIE);
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 232, 320, 24, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 4 || anim.hudScrollingTick == 5)
    {
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 16, MINTERM_COOKIE);
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 240, 320, 16, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 8 || anim.hudScrollingTick == 9)
    {
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
      blitCopy(s_pRobbo, 0, 0, s_pVpManager->pBack, 0, 248, 320, 8, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 12 || anim.hudScrollingTick == 13)
    {
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
    }
    else if (anim.hudScrollingTick == 16)
    {
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
      state.robboMsgCtrl = PRINT_ON_HUD;
      anim.hudScrollingTick = 0;
      state.hudScrollingControl = FALSE;
      misc.HUDcollisionMsg = 2;
      gameOverWhenAnotherCollisionHack = FALSE;
      printOnHUD();
    }
  }
}

void printRobboMsgOnHUD(char *lineToPass1, char *lineToPass2){
        sprintf(szBuffer, lineToPass1);
        fontFillTextBitMap(s_pFont, s_pBmText, szBuffer);
        fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 8, 230, 23, FONT_COOKIE);
        sprintf(szBuffer, lineToPass2);
        fontFillTextBitMap(s_pFont, s_pBmText, szBuffer);
        fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 8, 240, 23, FONT_COOKIE);
    }

void robboSays(void)
{

  if (amigaMode == AMIGA_MODE_CHECK && misc.HUDcollisionMsg != 1)
  {
    sprintf(szRobboMsg, "Traitor! Burn in hell!");
  }

  else if (amigaMode != AMIGA_MODE_CHECK && misc.HUDcollisionMsg != 1)
  {
    switch (misc.level)
    {
    case 1:
      sprintf(szRobboMsg, "Follow the Atari portal.");
      break;
    case 2:
      sprintf(szRobboMsg, "Keep an eye on your coal supplies.");
      break;
    case 3:
      sprintf(szRobboMsg, "Don't waste our coal hitting the meteorites.");
      break;
    case 4:
      sprintf(szRobboMsg, "Try to steal some red and blue capacitors.");
      break;
    case 5:
      sprintf(szRobboMsg, "Infiltrate the Amigans territory.");
      break;
    case 6:
      sprintf(szRobboMsg, "Find the coal warehouse and reclaim it.");
      break;
    case 7:
      sprintf(szRobboMsg, "Amigans call that place Magazyn.");  // 
      break;
    case 8:
      sprintf(szRobboMsg, "Training completed, skip it with X in menu.");
      break;
    case 9:
      robbo1stLineExceptionModificator = TRUE;
      break;
    case 10:
      sprintf(szRobboMsg, "If you fail, try to C-ontinue in menu.");  // Minister Renton is counting on you, Sir.
      break;
    case 11:
      sprintf(szRobboMsg, "Have you played Aminer yet?"); 
      break;
    case 12:
      sprintf(szRobboMsg, "Try new economic LSA 68090 engine in menu.");
      break;
    case 15:
      sprintf(szRobboMsg, "Please clean up here, I found some GermZ."); 
      break;
    case 21:
      sprintf(szRobboMsg, "Beware of VamPiRes, or you become one!"); 
      break;
    case 22:
      sprintf(szRobboMsg, "You like Paula? I love Laura!");
      break;
    case 23:
      sprintf(szRobboMsg, "How to double the value of your Atari...?");
      break;
    case 24:
      sprintf(szRobboMsg, "...Just insert the cassette into tape drive.");
      break;
    case 25:
      sprintf(szRobboMsg, "Make River Raid not Bridge Strike!");
      break;
    case 27:
      sprintf(szRobboMsg, "Drop me out at LK Avalon please.");
      break;
    case 28:
      sprintf(szRobboMsg, "Cytadela is better than Doom.");
      break;
    case 30:
      sprintf(szRobboMsg, "Did you choose the right path?");
      break;
    case LAST_LEVEL_NUMBER - 1:
      sprintf(szRobboMsg, "We're close, I feel it in my DSP.");
      break;
    case LAST_LEVEL_NUMBER:
      sprintf(szRobboMsg, "Well done! Now collect the coal and GTFO !!!");
      break;
    }
  }
  if (robbo1stLineExceptionModificator == FALSE && misc.HUDcollisionMsg != 1)
  {
    printRobboMsgOnHUD(szRobbo1stLine, szRobboMsg);
  }
  else if (robbo1stLineExceptionModificator == TRUE && misc.HUDcollisionMsg == 0)
  {
    printRobboMsgOnHUD(szTribute1stLine, szTribute2ndLine);
    robbo1stLineExceptionModificator = FALSE;
  }
  if (misc.HUDcollisionMsg == 1)
  {
    printRobboMsgOnHUD(szCollisionMsg1stLine, szCollisionMsg2ndLine);
    noCheatLevelSkipWhenRobboMessageOn = TRUE;
  }
}

void coalAndCollect(void)
{
  //funkcja do zbierania zasobu jesli jest na danym tajlu

  BYTE pickSthX = 0;
  BYTE pickSthY = 0;

  pickSthX = coord.falkonx;
  pickSthY = coord.falkony;

  BYTE what = kamyki[pickSthX][pickSthY];
  kamyki[pickSthX][pickSthY] = EMPTY_TILE_INT;
  collectiblesAnim[pickSthX][pickSthY] = EMPTY_TILE_INT;

  //--coal;

  switch (what)
  {
  case 4:
    col.coal = col.coal + 2;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pLadujWegiel, 2, 64, 100);
    }
    break;

  case 5:
    col.coal = col.coal + 3;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pLadujWegiel, 2, 64, 100);
    }
    break;

  case 6:
    col.coal = col.coal + 4;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pLadujWegiel, 2, 64, 100);
    }
    break;

  case 7:
    col.coal = col.coal + 5;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pLadujWegiel, 2, 64, 100);
    }
    break;

  case 8:
    col.capacitors = col.capacitors + 2;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pCapacitorSFX, 3, 64, 100);
    }
    //blitCopy(s_pHUD, 188, 0, s_pVpManager->pBack, 188, 224, 32, 32, MINTERM_COOKIE);
    //sprintf(szMsg2, "%d", col.capacitors);
    //fontFillTextBitMap(s_pFont, s_pBmText, szMsg2);
    //fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 190, 236, HUDfontColor, FONT_COOKIE);
    break;

  case 9:
    col.capacitors = col.capacitors + 4;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pCapacitorSFX, 3, 64, 100);
    }
    //blitCopy(s_pHUD, 188, 0, s_pVpManager->pBack, 188, 224, 32, 32, MINTERM_COOKIE);
    //sprintf(szMsg2, "%d", col.capacitors);
    //fontFillTextBitMap(s_pFont, s_pBmText, szMsg2);
    //fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 190, 236, HUDfontColor, FONT_COOKIE);
    break;

  case 10:
    noFlyingWhenCountingCoalInPortalHack = TRUE;
    state.levelScoreControl = LEVEL_SCORE_COUNT;
    state.falkonIdleControl = TRUE;
    //portalAnimControl = 1;
    break;

  case 11:
    noCheatLevelSkipWhenRobboMessageOn = TRUE;  // LEVEL SKIP HACK
    ++misc.robboMsgNr;
    ++col.robboMsgCount;
    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      ptplayerSfxPlay(s_pRobbo8000, 2, 32, 100);
    }
    state.robboMsgCtrl = HUD_SCROLL_UP;
    state.hudScrollingControl = TRUE;
    break;

  case 12:
    if (thirdCheatEnablerWhenEqual3 == 3)
    {
      state.youWin = CHEATER_GAME_OVER;
      return;
    }
    if (thirdCheatEnablerWhenEqual3 != 3)
    {
      amigaMode = AMIGA_MODE_ON;
      ptplayerSetMasterVolume(0);
      if (amigaMode == AMIGA_MODE_ON)
      {                               // jesli zebralem ami-kondka to wyswietlam ekran z plot twistem
        amigaMode = AMIGA_MODE_CHECK; // ustawiam dla sprawdzenia na koniec czy bedzie alternatywne zakonczenie
        amigaModeForContinueCheck = amigaMode;
        statePush(g_pStateMachineGame, &g_sStateGuruMastah);
      }

      misc.HUDfontColor = 5;

      bitmapDestroy(s_pTiles);
      bitmapDestroy(s_pTilesMask);
      s_pTiles = bitmapCreateFromFile("data/tileset2.bm", 0);
      s_pTilesMask = bitmapCreateFromFile("data/tileset_mask2.bm", 0);
      bitmapDestroy(s_pHUD);
      s_pHUD = bitmapCreateFromFile("data/amiHUD.bm", 0);
      s_pAmiHUDblinkGreen = bitmapCreateFromFile("data/amiHUD_LED_OFF_green.bm", 0);
      s_pAmiHUDblinkYellow = bitmapCreateFromFile("data/amiHUD_LED_OFF_yellow.bm", 0);
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
      blitCopy(s_pHUD, 0, 0, s_pVpManager->pFront, 0, 224, 320, 32, MINTERM_COOKIE);

      blitCopy(s_pBg, 288, 0, s_pBgWithTile, 288, 0, 32, 32, MINTERM_COPY);
      //blitCopy(s_pBg, 288, 0, s_pVpManager->pFront, 288, 0, 32, 32, MINTERM_COPY);
      blitCopyMask(s_pTiles, 64, 32, s_pBgWithTile, 288, 0, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
      //blitCopyMask(s_pTiles, 64, 32, s_pBgWithTile, 288, 0, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
      blitCopy(s_pBgWithTile, 288, 0, s_pVpManager->pBack, 288, 0, 32, 32, MINTERM_COPY);
      blitCopy(s_pBgWithTile, 288, 0, s_pVpManager->pFront, 288, 0, 32, 32, MINTERM_COPY);
      portalGlowAnim();
      //portalGlowAnim();
      //printOnHUD();
      copBlockEnable(s_pView->pCopList, copBlockBeforeHud);
      copBlockEnable(s_pView->pCopList, copBlockAfterHud);
      copProcessBlocks();
    }
    break;

  case 13:
    // if (musicPlay == MUSIC_AMBIENT_SFX)
    // {
    //   ptplayerSfxPlay(s_pRobbo8000, 3, 32, 100);
    // }
    state.robboMsgCtrl = HUD_SCROLL_UP;
    state.hudScrollingControl = TRUE;
    break;
  }
  printOnHUD();
}

void falkonHittingStone(void)
{
  if (state.stonehitAnimControl != TRUE)
  {
    return;
  }

  flying.HitPosX = coord.falkonx * 32;
  flying.HitPosY = coord.falkony * 32;

  if (state.stonehitAnimControl == TRUE)
  {
    if (anim.stonehitAnimTick == anim.falkonIdleTempo * 1)
    {
      anim.stonehitAnimFrame  = 0;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 2)
    {
      anim.stonehitAnimFrame  = 1;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 3)
    {
      anim.stonehitAnimFrame  = 2;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 4)
    {
      anim.stonehitAnimFrame  = 3;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 5)
    {
      anim.stonehitAnimFrame  = 4;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 6)
    {
      anim.stonehitAnimFrame  = 5;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 7)
    {
      anim.stonehitAnimFrame  = 6;
      //hittingStoneDirection();
    }
    else if (anim.stonehitAnimTick == anim.falkonIdleTempo * 8)
    {
      //hittingStoneDirection();
      anim.stonehitAnimFrame  = 7;
      anim.stonehitAnimTick = 0;
      state.stonehitAnimControl = FALSE;
      state.falkonIdleControl = TRUE;
    }

    
    blitCopy(s_pBg, flying.HitPosX, flying.HitPosY, s_pFalconBg, 0, 0, 32, 32, MINTERM_COOKIE);
    blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, flying.HitPosX, flying.HitPosY, 32, 32, MINTERM_COOKIE);
    blitCopyMask(s_pTiles, pAnim[anim.stonehitAnimFrame ], 64 + coord.falkonFace, s_pVpManager->pBack, flying.HitPosX, flying.HitPosY, 32, 32, (UWORD *)s_pTilesMask->Planes[0]); // rysuje falkona
  }
}

void prepareFalconFlying(void)
{
  flying.uwPreviousX = flying.uwPosX;
  flying.uwPreviousY = flying.uwPosY;
  flying.newPosX = flying.uwPosX;
  flying.newPosY = flying.uwPosY;

  switch (move.kierunekHold)
  {
  case 1:
    flying.tempX = coord.falkonx + 1;
    flying.uwPosX = flying.tempX * 32;
    break;

  case 2:
    flying.tempX = coord.falkonx - 1;
    flying.uwPosX = flying.tempX * 32;
    break;

  case 3:
    flying.tempY = coord.falkony - 1;
    flying.uwPosY = flying.tempY * 32;
    break;

  case 4:
    flying.tempY = coord.falkony + 1;
    flying.uwPosY = flying.tempY * 32;
    break;
  }
}

void endFalconFlying(void)
{

  blitCopy(s_pBg, flying.newPosX, flying.newPosY, s_pBgWithTile, flying.newPosX, flying.newPosY, 32, 32, MINTERM_COOKIE);

  switch (move.kierunekHold)
  {
  case 1:
    coord.falkonx = coord.falkonx + 1;
    break;

  case 2:
    coord.falkonx = coord.falkonx - 1;
    break;

  case 3:
    coord.falkony = coord.falkony - 1;
    break;

  case 4:
    coord.falkony = coord.falkony + 1;
    break;
  }
  // blitCopy(s_pBg, coord.falkonx * 32, falkony * 32, s_pVpManager->pBack, coord.falkonx * 32, falkony * 32, 32, 32, MINTERM_COOKIE);
}

void robboAnimBlit(void)
{
  UBYTE i = 0, k = 0;
  for (i = 0; i < 10; ++i)
  {
    for (k = 0; k < 7; ++k)
    {
      if (collectiblesAnim[i][k] == 11)
      {
        blitCopy(s_pBg, i * 32, k * 32, s_pRobboAnim, 0, 0, 32, 32, MINTERM_COOKIE);
        blitCopyMask(s_pTiles, anim.robboFrame * 32, 32, s_pRobboAnim, 0, 0, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
        blitCopy(s_pRobboAnim, 0, 0, s_pVpManager->pBack, i * 32, k * 32, 32, 32, MINTERM_COPY);
      }
    }
  }
}

void blitFlyingAnimFrame(void)
{
  blitCopy(s_pBg, flying.uwPreviousX, flying.uwPreviousY, s_pVpManager->pBack, flying.uwPreviousX, flying.uwPreviousY, 32, 32, MINTERM_COOKIE);
  if (kamyki[flying.tempX][flying.tempY] > 3 && kamyki[flying.tempX][flying.tempY] != 10 && kamyki[flying.tempX][flying.tempY] != 11)
  {
    blitCopy(s_pBgWithTile, flying.newPosX, flying.newPosY, s_pVpManager->pBack, flying.newPosX, flying.newPosY, 32, 32, MINTERM_COOKIE);
  }
  if (kamyki[flying.tempX][flying.tempY] == ROBBO_INT)
  {
    robboAnimBlit();
  }

  else if (kamyki[flying.tempX][flying.tempY] < 4)
  {
    UWORD uwPrevPosX = flying.uwPosX;
    UWORD uwPrevPosY = flying.uwPosY;
    switch (move.kierunekHold)
    {
    case 1:
      --uwPrevPosX;
      --uwPrevPosX;
      break;
    case 2:
      ++uwPrevPosX;
      ++uwPrevPosX;
      break;
    case 3:
      ++uwPrevPosY;
      ++uwPrevPosY;
      break;
    case 4:
      --uwPrevPosY;
      --uwPrevPosY;
      break;
    }
    blitCopy(s_pBg, uwPrevPosX, uwPrevPosY, s_pVpManager->pBack, uwPrevPosX, uwPrevPosY, 32, 32, MINTERM_COOKIE);
    //blitCopy(s_pBg, uwPrevPosX, uwPrevPosY, s_pVpManager->pFront, uwPrevPosX, uwPrevPosY, 32, 32, MINTERM_COOKIE);
    blitCopy(s_pBg, flying.newPosX, flying.newPosY, s_pVpManager->pBack, flying.newPosX, flying.newPosY, 32, 32, MINTERM_COOKIE);
  }
  blitCopyMask(s_pTiles, pAnim[anim.flyingFrame], 64 + coord.falkonFace, s_pVpManager->pBack, flying.newPosX, flying.newPosY, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
}

void falkonFlying2Db(void)
{
  state.flyingAnimControl = FLY_PROCEED;
  blitFlyingAnimFrame();
}

void falconCollisionCheck(void)
{

  // jesli byl kamien to brak ruchu
  if (move.stoneHit == TRUE)
  {
    ++move.anotherHit;
    //--col.coal;
    state.stonehitAnimControl = TRUE;
    state.falkonIdleControl = FALSE;
    state.robboMsgCtrl = HUD_SCROLL_UP;
    state.hudScrollingControl = TRUE;
    misc.HUDcollisionMsg = 1;

    switch (move.kierunek)
    {
    case 1:
      coord.krawedzx = coord.krawedzx - 1;
      break;
    case 2:
      coord.krawedzx = coord.krawedzx + 1;
      break;
    case 3:
      coord.krawedzy = coord.krawedzy + 1;
      break;
    case 4:
      coord.krawedzy = coord.krawedzy - 1;
      break;
    }

    move.stoneHit = FALSE;
    //printOnHUD();
    return;
  }

  if (move.frameHit == TRUE)
  {
    ++move.anotherHit;
    //--col.coal;
    state.stonehitAnimControl = TRUE;
    state.falkonIdleControl = FALSE;
    move.frameHit = FALSE;
    state.robboMsgCtrl = HUD_SCROLL_UP;
    state.hudScrollingControl = TRUE;
    misc.HUDcollisionMsg = 1;
    //printOnHUD();
    return;
  }
  prepareFalconFlying();
  state.flyingAnimControl = FLY_PREP;
  move.anotherHit = 0;
  misc.HUDcollisionMsg = 0;
}

void falconIdleAnimation(void)  // AND pyr pyr SFX if IN SFX AUDIO MODE 
{
  if (state.falkonIdleControl != TRUE)
  {
    return;
  }

  if (move.kierunek != 0 && move.stoneHit == FALSE)
  {
    return;
  }

  if (anim.falkonIdle == anim.falkonIdleTempo * 1)
  {
    anim.idleFrame = 0;
  }
  else if (anim.falkonIdle == anim.falkonIdleTempo * 2)
  {
    anim.idleFrame = 1;
  }
  else if (anim.falkonIdle == anim.falkonIdleTempo * 3)
  {
    anim.idleFrame = 2;
  }
  else if (anim.falkonIdle == anim.falkonIdleTempo * 4)
  {
    anim.idleFrame = 3;
  }
  else if (anim.falkonIdle == anim.falkonIdleTempo * 5)
  {
    anim.idleFrame = 4;
  }
  else if (anim.falkonIdle == anim.falkonIdleTempo * 6)
  {
    anim.idleFrame = 5;
  }
  else if (anim.falkonIdle == anim.falkonIdleTempo * 7)
  {
    anim.idleFrame = 6;
  }
  else if (anim.falkonIdle >= anim.falkonIdleTempo * 8)
  {
    anim.idleFrame = 7;
    anim.falkonIdle = 0;
  }

  if (musicPlay == MUSIC_AMBIENT_SFX)
  {
    
    if (anim.idleFrame == 0 || anim.idleFrame == 2 || anim.idleFrame == 4 || anim.idleFrame == 6)
    {
      if (amigaMode == AMIGA_MODE_OFF){
      ptplayerSfxPlay(s_pFalkonEngineSound, 3, 64, 50);
      }
      else if (amigaMode == AMIGA_MODE_ON || amigaMode == AMIGA_MODE_CHECK){
      ptplayerSfxPlay(s_pWicherEngineSound, 3, 64, 50);  
      }

    }
    /*
    else if (anim.idleFrame == 1 || anim.idleFrame == 3 || anim.idleFrame == 5)
    {
      if (amigaMode == AMIGA_MODE_OFF){
      ptplayerSfxPlay(s_pFalkonEngineSound, 3, 0, 50);
      }
      else if (amigaMode == AMIGA_MODE_ON || amigaMode == AMIGA_MODE_CHECK){
      ptplayerSfxPlay(s_pWicherEngineSound, 3, 0, 50);  
      }
    }
    */
  }

  UWORD uwPrevPosX = flying.uwPosX;
  UWORD uwPrevPosY = flying.uwPosY;
  switch (move.kierunekHold)
  {
  case 1:
    if (uwPrevPosX >= 2)
    {
      --uwPrevPosX;
      --uwPrevPosX;
    }
    break;
  case 2:
    if (uwPrevPosX <= 318)
    {
      ++uwPrevPosX;
      ++uwPrevPosX;
    }
    break;
  case 3:
    if (uwPrevPosY <= 190)
    {
      ++uwPrevPosY;
      ++uwPrevPosY;
    }
    break;
  case 4:
    if (uwPrevPosY >= 2)
    {
      --uwPrevPosY;
      --uwPrevPosY;
    }
    break;
  }
  blitCopy(s_pBg, uwPrevPosX, uwPrevPosY, s_pVpManager->pBack, uwPrevPosX, uwPrevPosY, 32, 32, MINTERM_COOKIE);
  blitCopy(s_pBg, flying.uwPosX, flying.uwPosY, s_pFalconBg, 0, 0, 32, 32, MINTERM_COOKIE);
  blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, flying.uwPosX, flying.uwPosY, 32, 32, MINTERM_COOKIE);
  blitCopyMask(s_pTiles, anim.idleFrame * 32, 192 + coord.falkonFace, s_pVpManager->pBack, coord.falkonx * 32, coord.falkony * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
}

void falkonFlying(void)
{
  if (state.flyingAnimControl == FLY_OFF)
  {
    return;
  }

  if (state.flyingAnimControl == FLY_PREP)
  {
    state.falkonIdleControl = FALSE;
    state.flyingAnimControl = FLY_DB;

    switch (move.kierunekHold)
    {
    case 1:
      flying.newPosX += 1;
      break;
    case 2:
      flying.newPosX -= 1;
      break;
    case 3:
      flying.newPosY -= 1;
      break;
    case 4:
      flying.newPosY += 1;
      break;
    }

    if (anim.flyingTick == 4)
    {
      anim.flyingFrame = 0;
    }
    else if (anim.flyingTick == 8 || anim.flyingTick == 12 || anim.flyingTick == 16 || anim.flyingTick == 20 ||
             anim.flyingTick == 24 || anim.flyingTick == 28 || anim.flyingTick == 32)
    {
      ++anim.flyingFrame;
    }

    blitFlyingAnimFrame();

    if (anim.flyingTick >= 32)
    {
      anim.flyingTick = 0;
      state.flyingAnimControl = FLY_ENDING;
      //falkonIdleControl = TRUE;
    }
  }

  else if (state.flyingAnimControl == FLY_ENDING)
  {
    blitCopy(s_pBg, flying.uwPreviousX, flying.uwPreviousY, s_pVpManager->pBack, flying.uwPreviousX, flying.uwPreviousY, 32, 32, MINTERM_COOKIE);
    endFalconFlying();
    misc.doubleBufferFrameControl = 2;
    coalAndCollect();
    state.flyingAnimControl = FLY_OFF;
    state.falkonIdleControl = TRUE;
  }

  if (state.robboMsgCtrl == HUD_ROBBO_MSG)
  {
    state.robboMsgCtrl = HUD_SCROLL_DOWN;
    state.hudScrollingControl = TRUE;
  }
}

void redCapacitorsAnimation(void)
{
  UBYTE i = 0, k = 0;

  if (anim.redCapacitorsAnimTick == anim.tickTempo)
  {

    for (i = 0; i < 10; ++i)
    {
      for (k = 0; k < 7; ++k)
      {
        if (collectiblesAnim[i][k] == 9)
        {
          blitCopy(s_pBg, i * 32, k * 32, s_pAnimBg, 0, 0, 32, 32, MINTERM_COOKIE);
          blitCopy(s_pAnimBg, 0, 0, s_pVpManager->pBack, i * 32, k * 32, 32, 32, MINTERM_COOKIE);
          blitCopyMask(s_pTiles, anim.redCapacitorsAnimTileCheck * 32, 288, s_pVpManager->pBack, i * 32, k * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
        }
      }
    }
    ++anim.redCapacitorsAnimTileCheck;
    if (anim.redCapacitorsAnimTileCheck == 7)
    {
      anim.redCapacitorsAnimTileCheck = 0;
    }
  }
}

void blueCapacitorsAnimation(void)
{

  if (anim.blueCapacitorsAnimTick == anim.tickTempo)
  {

    for (UBYTE i = 0; i < 10; ++i)
    {
      for (UBYTE k = 0; k < 7; ++k)
      {
        if (collectiblesAnim[i][k] == 8)
        {
          blitCopy(s_pBg, i * 32, k * 32, s_pAnimBg, 0, 0, 32, 32, MINTERM_COOKIE);
          blitCopy(s_pAnimBg, 0, 0, s_pVpManager->pBack, i * 32, k * 32, 32, 32, MINTERM_COOKIE);
          blitCopyMask(s_pTiles, anim.blueCapacitorsAnimTileCheck * 32, 256, s_pVpManager->pBack, i * 32, k * 32, 32, 32, (UWORD *)s_pTilesMask->Planes[0]);
        }
      }
    }
    ++anim.blueCapacitorsAnimTileCheck;
    if (anim.blueCapacitorsAnimTileCheck == 7)
    {
      anim.blueCapacitorsAnimTileCheck = 0;
    }
  }
}

void hudAnim(void)
{
  BYTE msgType;

  if (state.hudScrollingControl > 0 || state.robboMsgCtrl > PRINT_ON_HUD)
  {
    return;
  }

  switch (anim.hudTickFrame)
  {
  case 1:
    msgType = col.coal;
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg, "COAL %d", msgType);
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
    break;
  case 2:
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    break;
  case 3:
    msgType = col.capacitors;
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg, "CAPACITORS %d", msgType);
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
    break;
  case 4:
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    break;
  case 5:
    msgType = col.excesscoal;
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg, "RESERVE %d", msgType);
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
    break;
  case 6:
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    break;
  case 7:
    msgType = col.robboMsgCount;
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    sprintf(szMsg, "ROBBO %d", msgType);
    fontFillTextBitMap(s_pGotekFont, s_pBmText, szMsg);
    fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 42, 239, misc.HUDfontColor, FONT_COOKIE);
    break;
  case 8:
    blitCopy(s_pHUD, 32, 0, s_pVpManager->pBack, 32, 224, 96, 32, MINTERM_COOKIE);
    break;
  }
}

void robboAnimCounter(void)
{
  if (anim.robboTick > anim.robboTempo)
  {
    db.robbo = TRUE;
    ++anim.robboFrame;
    anim.robboTick = 0;
    if (anim.robboFrame == 8)
    {
      anim.robboFrame = 0;
    }
    robboAnimBlit();
  }
}

void doubleBufferingHandler(void)
{
  // if (db.flyingAnimFrame == 1)
  // {
  //   //blitBackground();
  //   db.flyingAnimFrame = 0;
  // }
  // if (db.portal == 1)
  // {
  //   //portalAnimBlit();
  //   db.portal = 0;
  // }
  // if (db.blueCap == 1)
  // {
  //   //blueCapacitorsAnimation();
  //   db.blueCap = 0;
  // }
  // if (db.redCap == 1)
  // {
  //   //redCapacitorsAnimation();
  //   db.redCap = 0;
  // }
  if (db.robbo == TRUE)
  {
    robboAnimBlit();
    db.robbo = FALSE;
  }
}

void stateGameCreate(void)
{
  clearTiles();
  initialSetupDeclarationOfData();
  if (tutorialLevelsSkip == TRUE){
    misc.level = 9;
    col.coal = 1;
  }
  if (continueCheck == FALSE){
    amigaModeForContinueCheck = AMIGA_MODE_OFF;
  }
  if (continueCheck == TRUE){
    misc.level = misc.holdLastLevelForContinue;
    continueCheck = FALSE;
    if (misc.level > 1){
    col.coal = 1;
    }
  }
  // Here goes your startup code
  //-------------------------------------------------------------- gdzie� w create
  s_pView = viewCreate(0,
                       TAG_VIEW_COPLIST_MODE, COPPER_MODE_BLOCK, // spos�b u�ywania coppera - ten jest najprostszy bo nic z nim nie musisz wi�cej robi�
                       TAG_VIEW_GLOBAL_CLUT, 1,                  // globalna paleta dla wszystkich viewport�w
                       TAG_END                                   // wi�cej argument�w nie ma
  );

  s_pVp = vPortCreate(0,
                      TAG_VPORT_VIEW, s_pView, // parent view
                      TAG_VPORT_BPP, 5,        // bits per pixel: 4bpp = 16col, 5pp = 32col, etc.
                      TAG_END);

  // kolory do zmiany nowy hud
  // 102  85  51 Index 6    0x653
  //  119 102  68 Index 7   0x764
  //  136 119  85 Index 8   0x875
  //  170 153 119 Index 9   0xA97
  //  187 170 136 Index 10  0xBA8

  copBlockBeforeHud = copBlockCreate(s_pView->pCopList, 5, 0xE2, s_pView->ubPosY + 224 - 1);
  copBlockAfterHud = copBlockCreate(s_pView->pCopList, 5, 0xE2, s_pView->ubPosY + 256 - 1);

  copMove(s_pView->pCopList, copBlockBeforeHud, &g_pCustom->color[6], 0x653);
  copMove(s_pView->pCopList, copBlockBeforeHud, &g_pCustom->color[7], 0x764);
  copMove(s_pView->pCopList, copBlockBeforeHud, &g_pCustom->color[8], 0x875);
  copMove(s_pView->pCopList, copBlockBeforeHud, &g_pCustom->color[9], 0xA97);
  copMove(s_pView->pCopList, copBlockBeforeHud, &g_pCustom->color[10], 0xBA8);

  // kolory do zmiany bazowe
  //  153  34   0 Index 6   0x920
  //  187  51   0 Index 7   0xB30
  //  204  68  17 Index 8   0xC41
  //  238 102  34 Index 9   0xE62
  //  255 119  51 Index 10  0xF73

  copMove(s_pView->pCopList, copBlockAfterHud, &g_pCustom->color[6], 0x920);
  copMove(s_pView->pCopList, copBlockAfterHud, &g_pCustom->color[7], 0xB30);
  copMove(s_pView->pCopList, copBlockAfterHud, &g_pCustom->color[8], 0xC41);
  copMove(s_pView->pCopList, copBlockAfterHud, &g_pCustom->color[9], 0xE62);
  copMove(s_pView->pCopList, copBlockAfterHud, &g_pCustom->color[10], 0xF73);

  copBlockDisable(s_pView->pCopList, copBlockBeforeHud);
  copBlockDisable(s_pView->pCopList, copBlockAfterHud);

  ptplayerCreate(1);
  s_pMod = ptplayerModCreate("data/mod.falkon");
  s_pModAmbient = ptplayerModCreate("data/mod.falkon-ambient2");
  //s_pModAmbient = ptplayerModCreate("data/mod.falkon-ambient");
  ptplayerLoadMod(s_pMod, 0, 0);

  s_pFalkonEngineSound = ptplayerSfxCreateFromFile("data/falkonEngine.sfx");
  s_pWicherEngineSound = ptplayerSfxCreateFromFile("data/wicherEngine.sfx");
  s_pLadujWegiel = ptplayerSfxCreateFromFile("data/LadujWegiel.sfx");
  s_pPortal8000 = ptplayerSfxCreateFromFile("data/portalSfx8000.sfx");
  s_pRobbo8000 = ptplayerSfxCreateFromFile("data/robbo8000.sfx");
  s_pCapacitorSFX = ptplayerSfxCreateFromFile("data/cap11025.sfx");
  s_pAtariExcessCoalTickSound = ptplayerSfxCreateFromFile("data/Atari.sfx");

  // Paleta z falkona
  paletteLoad("data/falkon.plt", s_pVp->pPalette, 32);
  paletteLoad("data/falkon.plt", s_pPalette, 32);

  //g_pCustom->color[0] = 0x0FFF; // zmie� kolor zero aktualnie u�ywanej palety na 15,15,15

  if ((thirdCheatEnablerWhenEqual3 != 3 && amigaModeForContinueCheck == AMIGA_MODE_OFF) || (amigaModeForContinueCheck != AMIGA_MODE_OFF && misc.level == 16))
  {
    s_pTiles = bitmapCreateFromFile("data/tileset.bm", 0);          // z pliku tileset.bm, nie lokuj bitmapy w pami�ci FAST
    s_pTilesMask = bitmapCreateFromFile("data/tileset_mask.bm", 0); // z pliku tileset_mask.bm, nie lokuj bitmapy w pami�ci FAST
    s_pHUD = bitmapCreateFromFile("data/HUD.bm", 0);
    copProcessBlocks();
  }
  else if (thirdCheatEnablerWhenEqual3 == 3 || (amigaModeForContinueCheck != AMIGA_MODE_OFF && misc.level != 16))
  {
    //amigaModeForContinueCheck = AMIGA_MODE_OFF;
    amigaMode = AMIGA_MODE_CHECK;
    misc.HUDfontColor = 5;
    s_pTiles = bitmapCreateFromFile("data/tileset2.bm", 0);
    s_pTilesMask = bitmapCreateFromFile("data/tileset_mask2.bm", 0);
    s_pHUD = bitmapCreateFromFile("data/amiHUD.bm", 0);
    s_pAmiHUDblinkGreen = bitmapCreateFromFile("data/amiHUD_LED_OFF_green.bm", 0);
    s_pAmiHUDblinkYellow = bitmapCreateFromFile("data/amiHUD_LED_OFF_yellow.bm", 0);
    copBlockEnable(s_pView->pCopList, copBlockBeforeHud);
    copBlockEnable(s_pView->pCopList, copBlockAfterHud);
  }

  s_pBg = bitmapCreateFromFile("data/tlo1.bm", 0);
  s_pBgWithTile = bitmapCreateFromFile("data/tlo1.bm", 0); // fragmenty tla do podstawiania po ruchu
  s_pRobbo = bitmapCreateFromFile("data/falkon_robbo.bm", 0);
  s_pSabermanTribute = bitmapCreateFromFile("data/saberman.bm", 0);
  s_pSabermanTributeMask = bitmapCreateFromFile("data/saberman_mask.bm", 0);
  s_pFalconBg = bitmapCreate(48, 32, 5, BMF_INTERLEAVED);
  s_pAnimBg = bitmapCreate(48, 32, 5, BMF_INTERLEAVED);
  s_pBgPortalGlow = bitmapCreate(48, 32, 5, BMF_INTERLEAVED);
  s_pRobboAnim = bitmapCreate(48, 32, 5, BMF_INTERLEAVED);
  s_pFont = fontCreate("data/topaz.fnt");
  s_pGotekFont = fontCreate("data/gotekFont.fnt");

  s_pBmText = fontCreateTextBitMap(TEXT_BITMAP_WIDTH, s_pFont->uwHeight); // bitmapa robocza długa na 200px, wysoka na jedną linię tekstu

  // proste wy�wietlanie bitmapy na viewporcie
  s_pVpManager = simpleBufferCreate(0,
                                    TAG_SIMPLEBUFFER_VPORT, s_pVp,                              // parent viewport
                                    TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED, // wst�pne czyszczenie bitmapy, przyspieszenie rysowania grafiki
                                    TAG_SIMPLEBUFFER_IS_DBLBUF, 1,                              // nie potrzebujemy double buffering
                                    TAG_SIMPLEBUFFER_BOUND_WIDTH, 320 + 16,
                                    TAG_END);

  cameraSetCoord(s_pVpManager->pCamera, 0, 0);

  // po zrobieniu simpleBufferCreate()
  bitmapLoadFromFile(s_pVpManager->pBack, "data/tlo1.bm", 0, 0); // wczytaj zawarto�� bg1.bm bezpo�rednio do bitmapy bufora ekranu, zaczynaj�c od pozycji 0,0
  bitmapLoadFromFile(s_pVpManager->pFront, "data/tlo1.bm", 0, 0);
  blitCopy(s_pHUD, 0, 0, s_pVpManager->pBack, 0, 224, 320, 32, MINTERM_COOKIE);
  blitCopy(s_pHUD, 0, 0, s_pVpManager->pFront, 0, 224, 320, 32, MINTERM_COOKIE);
  joyOpen(); // b�dziemy u�ywa� d�oja w grze
  keyCreate();
  // na koniec create:

  randInit(1337);

  printOnHUD();
  misc.doubleBufferFrameControl = 2;

  viewProcessManagers(s_pView);
  viewLoad(s_pView);

  blitCopy(s_pBg, 0, 0, s_pFalconBg, 0, 0, 48, 32, MINTERM_COOKIE);
  blitCopy(s_pFalconBg, 0, 0, s_pVpManager->pBack, 0, 0, 33, 32, MINTERM_COOKIE);

  drawTiles();
  ptplayerEnableMusic(1);
  systemUnuse(); // system w trakcie loop nie jest nam potrzebny
}

void stateGameLoop(void)
{
  doubleBufferingHandler();
  ++anim.robboTick;
  robboAnimCounter();
  // Here goes code done each game frame
  if (musicPlay == MUSIC_HEAVY && misc.audioFadeIn < 64)
  {
    ++misc.audioFadeIn;
    ptplayerSetMasterVolume(misc.audioFadeIn);
  }
  if (amigaMode != AMIGA_MODE_OFF)
  {
    if (db.hudAnimDB == TRUE)
    {
      hudAnim();
      db.hudAnimDB = FALSE;
      if (anim.hudTickFrame == 8)
      {
        anim.hudTickFrame = 0;
      }
    }

    ++anim.hudAnimTick;
    if (anim.hudAnimTick > anim.hudTickTempo)
    {
      ++anim.hudTickFrame;
      hudAnim();
      anim.hudAnimTick = 0;
      db.hudAnimDB = TRUE;
    }
  }

  if (db.portalGlowDB == TRUE)
  {
    portalGlowAnim();
    db.portalGlowDB = FALSE;
  }

  ++anim.portalGlowTick;
  if (anim.portalGlowTick > anim.portalTickTempo)
  {
    ++anim.portalGlowFrame;
    portalGlowAnim();
    anim.portalGlowTick = 0;
    db.portalGlowDB = TRUE;
    if (anim.portalGlowFrame == 7)
    {
      anim.portalGlowFrame = 0;
    }
  }

  ++anim.redCapacitorsAnimTick;
  if (anim.redCapacitorsAnimTick > anim.tickTempo)
  {
    anim.redCapacitorsAnimTick = 0;
  }
  ++anim.blueCapacitorsAnimTick;
  if (anim.blueCapacitorsAnimTick > anim.tickTempo)
  {
    anim.blueCapacitorsAnimTick = 0;
  }

  if (state.falkonIdleControl == TRUE)
  {
    ++anim.falkonIdle;
  }

  if (state.flyingAnimControl == FLY_PREP)
  {
    ++anim.flyingTick;
  }

  if (state.flyingAnimControl == FLY_ENDING)
  {
    falkonFlying();
    state.flyingAnimControl = FLY_OFF;
  }

  falkonHittingStone();
  redCapacitorsAnimation();
  blueCapacitorsAnimation();

  //portalAnim();

  if (state.flyingAnimControl == FLY_DB)
  {
    falkonFlying2Db();
  }

  falkonFlying();
  falconIdleAnimation();

  if (db.levelScoreDB == TRUE)
  {
    levelScoreDBredraw();
    db.levelScoreDB = FALSE;
  }
  if (state.levelScoreControl != LEVEL_SCORE_OFF)
  {
    ++anim.levelScoreTick;
    levelScore();
    db.levelScoreDB = TRUE;
  }

  if (state.flyingAnimControl == FLY_PROCEED)
  {
    state.flyingAnimControl = FLY_PREP;
  }

  if (state.hudScrollingControl == TRUE)
  {
    ++anim.hudScrollingTick;
  }

  if (state.stonehitAnimControl == TRUE)
  {
    ++anim.stonehitAnimTick;
  }

  if (hudFullyUp == TRUE && col.coal == 0)
  {
    state.robboMsgCtrl = HUD_SCROLL_DOWN;
    state.hudScrollingControl = TRUE;
    gameOverWhenAnotherCollisionHack = TRUE;
  }

  move.kierunek = 0;

  if (setGameOverInNextLoopIter == TRUE) // HACK FROM BELOW (L.1979) RESOLVING !
  {
    printOnHUD();
    state.levelScoreControl = LEVEL_SCORE_NOCOAL;
    setGameOverInNextLoopIter = FALSE;
  }

  if (col.coal == 0 && state.levelScoreControl != LEVEL_SCORE_NOCOAL && state.flyingAnimControl == FLY_OFF)
  {
    setGameOverInNextLoopIter = TRUE; // HACK FOR DOUBLE BUFFER WHEN GOING TO ROBBO ON 0 COAL
  }

  joyProcess();
  keyProcess();

if (col.coal > 0){

    if (joyUse(JOY1_RIGHT) || keyUse(KEY_D) || keyUse(KEY_RIGHT))
    {
      move.kierunek = 1;
      coord.falkonFace = 0;
    }
    else if (joyUse(JOY1_LEFT) || keyUse(KEY_A) || keyUse(KEY_LEFT))
    {
      move.kierunek = 2;
      coord.falkonFace = 32;
    }
    else if (joyUse(JOY1_UP) || keyUse(KEY_W) || keyUse(KEY_UP))
    {
      move.kierunek = 3;
    }
    else if (joyUse(JOY1_DOWN) || keyUse(KEY_S) || keyUse(KEY_DOWN))
    {
      move.kierunek = 4;
    }
    else if (keyUse(KEY_RETURN) && hudFullyUp == TRUE)
    {
      state.hudScrollingControl = TRUE;
      state.robboMsgCtrl = HUD_SCROLL_DOWN;
      robboScrollDown();
    }
    else if (keyUse(KEY_ESCAPE))
    {
      ptplayerStop();
      clearTiles();
      stateChange(g_pStateMachineGame, &g_sStateMenu);
      return;
    }
    else if (keyUse(KEY_N) && misc.level < LAST_LEVEL_NUMBER)
    {
      if (cheatmodeEnablerWhenEqual3 != 3)
      {
        return;
      }
      if (noCheatLevelSkipWhenRobboMessageOn == TRUE)
      {
        return;
      }
      if (state.falkonIdleControl != TRUE)
      {
      return;
      }
      if (musicPlay == MUSIC_AMBIENT_SFX)
      {
          ptplayerSfxPlay(s_pFalkonEngineSound, 3, 0, 50);
      }
      ++misc.level;
      misc.holdLastLevelForContinue = misc.level;
      nextLevel();
      return;
    }
    else if (keyUse(KEY_M)) // wczesniej wlaczony jest modek i gra
    {
      if (musicPlay == MUSIC_HEAVY) // stan domyslny
      {
        musicPlay = MUSIC_AMBIENT_SFX;
        ptplayerEnableMusic(0);
        ptplayerLoadMod(s_pModAmbient, 0, 0); // chce nowy modek
        ptplayerSetMasterVolume(64);
        ptplayerEnableMusic(1);
      }
      else if (musicPlay == MUSIC_OFF) // teraz wracam do pierwszego modka
      {
        musicPlay = MUSIC_HEAVY;
        ptplayerEnableMusic(0);
        ptplayerLoadMod(s_pMod, 0, 0);
        ptplayerEnableMusic(1);
        ptplayerSetMasterVolume(64); // modek gra tak na ucho w 2x szybszym tempie
      }
      else if (musicPlay == MUSIC_AMBIENT_SFX)
      {
        musicPlay = MUSIC_OFF;
        ptplayerSfxPlay(s_pFalkonEngineSound, 3, 0, 50);
        ptplayerStop();
        ptplayerSetMasterVolume(0); // cisza
        ptplayerEnableMusic(0);
      }
      //}
    }
}

  if (move.kierunek != 0)
  {
    if (state.flyingAnimControl != 0)
    {
      return;
    }
    if (noFlyingWhenCountingCoalInPortalHack == TRUE){ // no flying when in portal hack !
      return;
    }
    if (state.robboMsgCtrl == HUD_SCROLL_UP && hudFullyUp == FALSE)
    { // no fly when hud scrolling up hacks
      return;
    }
    if (noCheatLevelSkipWhenRobboMessageOn == TRUE){
      noCheatLevelSkipWhenRobboMessageOn = FALSE;  // no level skip when robbo display hack release
    }
    move.kierunekHold = move.kierunek;
    if (secondCheatEnablerWhenEqual3 == 3)
    {
      ++col.coal;
    }
    --col.coal;
    if (move.anotherHit < 1)
    {
      printOnHUD();
      misc.doubleBufferFrameControl = 2;
    }

    if (musicPlay == MUSIC_AMBIENT_SFX)
    {
      if (amigaMode == AMIGA_MODE_OFF){
      ptplayerSfxPlay(s_pFalkonEngineSound, 3, 64, 70);
      }
      else if (amigaMode == AMIGA_MODE_ON || amigaMode == AMIGA_MODE_CHECK){
      ptplayerSfxPlay(s_pWicherEngineSound, 3, 64, 70);  
      }
    }

    isThisStone();
    czyRamka();
    falconCollisionCheck();
  }

  robboScrollUp();
  robboScrollDown();

  if (misc.doubleBufferFrameControl > 0)
  {
    if (state.robboMsgCtrl == PRINT_ON_HUD)
    {
      printOnHUD();
    }
    else if (state.robboMsgCtrl == HUD_SCROLL_UP)
    {
      robboScrollUp();
    }
    else if (state.robboMsgCtrl == HUD_SCROLL_DOWN)
    {
      robboScrollDown();
    }

    if (state.robboMsgCtrl == HUD_ROBBO_MSG)
    {
      robboSays();
    }

    --misc.doubleBufferFrameControl;
  }

  if (state.youWin == END) // sprawdzenie ktore zakonczenie uruchomic
  {
    state.youWin = OFF;
    stateChange(g_pStateMachineGame, &g_sStateScore); // atari ending
  }
  else if (state.youWin == GAME_OVER)
  {
    state.youWin = OFF;
    stateChange(g_pStateMachineGame, &g_sStateGameOver);
    return;
  }
  else if (state.youWin == CHEATER_GAME_OVER)
  {
    state.youWin = OFF;
    stateChange(g_pStateMachineGame, &g_sStateLeakedGameOver);
    return;
  }

  viewProcessManagers(s_pView); // obliczenia niezb�dne do poprawnego dzia�ania viewport�w

  copProcessBlocks();     // obliczenia niezb�dne do poprawnego dzia�ania coppera
  vPortWaitForEnd(s_pVp); // r�wnowa�ne amosowemu wait vbl
}

void stateGameDestroy(void)
{
  // Here goes your cleanup code
  systemUse(); // w��cz grzecznie system
  ptplayerModDestroy(s_pMod);
  ptplayerModDestroy(s_pModAmbient);
  ptplayerSfxDestroy(s_pFalkonEngineSound);
  ptplayerSfxDestroy(s_pWicherEngineSound);
  ptplayerSfxDestroy(s_pLadujWegiel);
  ptplayerSfxDestroy(s_pRobbo8000);
  ptplayerSfxDestroy(s_pPortal8000);
  ptplayerSfxDestroy(s_pCapacitorSFX);
  ptplayerSfxDestroy(s_pAtariExcessCoalTickSound);
  ptplayerDestroy();
  bitmapDestroy(s_pTiles);
  bitmapDestroy(s_pTilesMask);
  bitmapDestroy(s_pBg);
  bitmapDestroy(s_pBgWithTile);
  bitmapDestroy(s_pHUD);
  if (thirdCheatEnablerWhenEqual3 == 3){
    bitmapDestroy(s_pAmiHUDblinkGreen);
    bitmapDestroy(s_pAmiHUDblinkYellow);
  }
  bitmapDestroy(s_pFalconBg);
  bitmapDestroy(s_pAnimBg);
  bitmapDestroy(s_pBgPortalGlow);
  bitmapDestroy(s_pRobbo);
  bitmapDestroy(s_pRobboAnim);
  bitmapDestroy(s_pSabermanTribute);
  bitmapDestroy(s_pSabermanTributeMask);

  fontDestroy(s_pFont);
  fontDestroy(s_pGotekFont);
  fontDestroyTextBitMap(s_pBmText);

  viewDestroy(s_pView); // zwolnij z pami�ci view, wszystkie do��czone do niego viewporty i wszystkie do��czone do nich mened�ery
  joyClose();
  keyDestroy();
}

// pod funkcjami bo kompilator czyta od g�ry do do�u i musi najpierw napotka� funkcje by wiedzie� �e istniej�
tState g_sStateGame = {
    .cbCreate = stateGameCreate,
    .cbLoop = stateGameLoop,
    .cbDestroy = stateGameDestroy,
    .cbSuspend = 0,
    .cbResume = gameOnResume,
    .pPrev = 0};
