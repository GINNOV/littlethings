
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

// #include <time.h>
#include <stdlib.h>
#include "starfield.h"
#include <ace/managers/key.h>                   // Keyboard processing
#include <ace/managers/game.h>                  // For using gameClose
#include <ace/managers/system.h>                // For systemUnuse and systemUse
#include <ace/managers/viewport/simplebuffer.h> // Simple buffer
#include <ace/utils/font.h> // needed for tFont and font stuff
#include <ace/utils/sprite.h>
#include <ace/utils/custom.h>
#include <ace/managers/rand.h>

#include "../_res/VampireItalialogo.h"
#include "../_res/VampireItalialogopalette.h"

#include "../_res/uni54.h"

#define ACE_SPRITE_MIN_VPOSITION 0x30
#define ACE_SPRITE_MIN_HPOSITION 0x40
#define ACE_SPRITE_MAX_HPOSITION 0xf0
#define SPRITE_REQ_BYTES(var) 8 * var + 4

#define ACE_SET_SPRITE_COUPLE_1_COLORS(var, var1, var2, var3) \
  var->pPalette[17] = var1;                                   \
  var->pPalette[18] = var2;                                   \
  var->pPalette[19] = var3;
#define ACE_SET_SPRITE_COUPLE_2_COLORS(var, var1, var2, var3) \
  var->pPalette[21] = var1;                                   \
  var->pPalette[22] = var2;                                   \
  var->pPalette[23] = var3;
#define ACE_SET_SPRITE_COUPLE_3_COLORS(var, var1, var2, var3) \
  var->pPalette[25] = var1;                                   \
  var->pPalette[26] = var2;                                   \
  var->pPalette[27] = var3;
#define ACE_SET_SPRITE_COUPLE_4_COLORS(var, var1, var2, var3) \
  var->pPalette[29] = var1;                                   \
  var->pPalette[30] = var2;                                   \
  var->pPalette[31] = var3;

#define ACE_SET_PLAYFIELD_PRIORITY_0 g_pCustom->bplcon2=0x0000;
#define ACE_SET_PLAYFIELD_PRIORITY_1 g_pCustom->bplcon2=0x0009;
#define ACE_SET_PLAYFIELD_PRIORITY_2 g_pCustom->bplcon2=0x0012;
#define ACE_SET_PLAYFIELD_PRIORITY_3 g_pCustom->bplcon2=0x001b;
#define ACE_SET_PLAYFIELD_PRIORITY_4 g_pCustom->bplcon2=0x0024;

#define ACE_MAXSPRITES 8

typedef struct _tAceSprite
{
  UBYTE *pSpriteData;
  ULONG ulSpriteSize;
  BYTE bTrailingSpriteIndex;
  UWORD uwSpriteHeight; // Height of the sprite in pixel (ulSpriteSize/4)
  UWORD uwSpriteCenter; // value 8 for single sprite (since a sprite is 16 bits wide) or 16 for side by side sprite

  int iBounceBottomLimit;
  int iBounceRightLimit;

} tAceSprite;
tAceSprite s_pAceSprites[ACE_MAXSPRITES];
#define STAR_SPRITE_INDEX 7 /* In this demo we will use sprite number 7 for the starfield                                      \
                             because sprite 8 is not available for DMA access hence sprite 7 is the higher index available     \
                            We want to use high sprite indexed because we want the star field to be drawn behind the playfield \
                            and not over it*/

// Global variables
static tView *s_pView;    // View containing all the viewports
static tVPort *s_pVpMain; // Viewport for playfield
static tSimpleBufferManager *s_pMainBuffer;
static tCopBlock *starSprite;
static tFont *s_pFontUI;
static tTextBitMap *s_pGlyph;

// My functions protos
tCopBlock *copBlockEnableSpriteRecycled(tCopList *, FUBYTE, UBYTE *, ULONG);
void copBlockSpritesFree();
void initRandStars(UBYTE *, const UBYTE, const UBYTE);
void moveStars();

void gameGsCreate(void)
{
  // Create a view - first arg is always zero, then it's option-value
  s_pView = viewCreate(0,
                       TAG_VIEW_GLOBAL_PALETTE, 1, // Same Color LookUp Table for all viewports
                       TAG_END);                // Must always end with TAG_END or synonym: TAG_DONE

  // Now let's do the same for main playfield
  s_pVpMain = vPortCreate(0,
                          TAG_VPORT_VIEW, s_pView,
                          TAG_VPORT_BPP, 3, // 3 bits per pixel, 8 colors
                          // We won't specify height here - viewport will take remaining space.
                          TAG_END);
  s_pMainBuffer = simpleBufferCreate(0,
                                     TAG_SIMPLEBUFFER_VPORT, s_pVpMain, // Required: parent viewport
                                     TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR,
                                     TAG_END);

  // Copy image palette to Amiga color registers
  for (UBYTE ubColorCounter = 0; ubColorCounter < 8; ubColorCounter++)
    s_pVpMain->pPalette[ubColorCounter] = vampireitaliapalette_data[ubColorCounter];

  // Set color blu for the star (actually only the first param is used in this demo)
  ACE_SET_SPRITE_COUPLE_4_COLORS(s_pVpMain, 0x000F, 0x000F, 0x000F)

  systemUnuse();

  // Load the view
  viewLoad(s_pView);

  // Load fonts
  s_pFontUI = fontCreateFromMem((UBYTE*)uni54_data);
  if (s_pFontUI==NULL) return;

  s_pGlyph = fontCreateTextBitMap(256, s_pFontUI->uwHeight);

  fontDrawStr(s_pFontUI, s_pMainBuffer->pBack, 10,10," Press 'O' TO paint starfield OVER the playfield",3, FONT_LAZY, s_pGlyph);
  fontDrawStr(s_pFontUI, s_pMainBuffer->pBack, 10,20," Press 'U' TO paint starfield UNDER the playfield",3, FONT_LAZY, s_pGlyph);

  // Copy 320X224 vampireitalialogo to bitplanes

  // Bitplane 1
  memcpy(
      (UBYTE *)((ULONG)s_pMainBuffer->pBack->Planes[0] + (40 * 32)),
      &vampireitalialogo_data[0 * 40 * 224],
      40 * 224);

  // Bitplane 2
  memcpy(
      (UBYTE *)((ULONG)s_pMainBuffer->pBack->Planes[1] + (40 * 32)),
      &vampireitalialogo_data[1 * 40 * 224],
      40 * 224);

  // Bitplane 3
  memcpy(
      (UBYTE *)((ULONG)s_pMainBuffer->pBack->Planes[2] + (40 * 32)),
      &vampireitalialogo_data[2 * 40 * 224],
      40 * 224);

  // Allocate the recycled sprite raw data memory for 111 stars (max 127 to fill the whole 256 vertical resolution)
  const UBYTE ubNumStars = 111;
  UBYTE ubStarDataArray[SPRITE_REQ_BYTES(ubNumStars)];

  // Fill the array with star positions and data, each star will have a random x position and a unique y position starting from 32th row
  initRandStars(ubStarDataArray, +32, ubNumStars);

  // Load the sprite data into sprite register, DMA will take care of the rest, use sprite7 registers (as defined in STAR_SPRITE_INDEX)
  starSprite = copBlockEnableSpriteRecycled(s_pView->pCopList, STAR_SPRITE_INDEX, (UBYTE *)ubStarDataArray, sizeof(ubStarDataArray));

  // Set last couple of sprite BEHIND bitplane, to do this set bplcon2 to 011
  ACE_SET_PLAYFIELD_PRIORITY_3

  // Install copperlist
  copProcessBlocks();
}

void gameGsLoop(void)
{
  // If key O is pressed the starfield is OVER the playfield
  if (keyCheck(KEY_O))
  {
    ACE_SET_PLAYFIELD_PRIORITY_4
  }

  if (keyCheck(KEY_U))
  {
    ACE_SET_PLAYFIELD_PRIORITY_3
  }

  // If esc is pressed exit the demo
  if (keyCheck(KEY_ESCAPE))
  {
    gameExit();
    return;
  }

  // To slow down the stars we move them only if the frame is even
  static UBYTE ubFrame = 0;

  // Move stars to the right, the speed (pixel per seconds) is calculated based on the row number
  if (!ubFrame++)
    moveStars();

  // Reset frame counter
  if (ubFrame > 1)
    ubFrame = 0;

  vPortWaitForEnd(s_pVpMain);
}

void gameGsDestroy(void)
{
  copBlockSpritesFree();

  // Cleanup when leaving this gamestate
  systemUse();

  // This will also destroy all associated viewports and viewport managers
  viewDestroy(s_pView);
}

void copBlockSpritesFree()
{
  // Reset tAceSprite array
  for (UBYTE ubIterator = 0; ubIterator < ACE_MAXSPRITES; ubIterator++)
  {
    if (s_pAceSprites[ubIterator].pSpriteData)
      memFree(s_pAceSprites[ubIterator].pSpriteData, s_pAceSprites[ubIterator].ulSpriteSize);
  }
}

tCopBlock *copBlockEnableSpriteRecycled(tCopList *pList, FUBYTE fubSpriteIndex, UBYTE *pSpriteData, ULONG ulSpriteSize)
{
  static tCopBlock *pBlockSprites = NULL;
  tCopMoveCmd *pMoveCmd = NULL;

  if (pBlockSprites == NULL)
  {
    pBlockSprites = spriteDisableInCopBlockMode(pList, 0xFF);
    systemSetDmaBit(DMAB_SPRITE, 1);

    // Reset tAceSprite array
    for (UBYTE ubIterator = 0; ubIterator < ACE_MAXSPRITES; ubIterator++)
    {
      s_pAceSprites[ubIterator].pSpriteData = NULL;
      s_pAceSprites[ubIterator].ulSpriteSize = 0;
      s_pAceSprites[ubIterator].bTrailingSpriteIndex = -1;
      s_pAceSprites[ubIterator].uwSpriteHeight = 0;
      s_pAceSprites[ubIterator].uwSpriteCenter = 0;
      s_pAceSprites[ubIterator].iBounceBottomLimit = 0;
      s_pAceSprites[ubIterator].iBounceRightLimit = 0;
    }
  }
  if (s_pAceSprites[fubSpriteIndex].pSpriteData)
  {
    memFree(s_pAceSprites[fubSpriteIndex].pSpriteData, s_pAceSprites[fubSpriteIndex].ulSpriteSize);
    s_pAceSprites[fubSpriteIndex].pSpriteData = NULL;
    s_pAceSprites[fubSpriteIndex].ulSpriteSize = 0;
    s_pAceSprites[fubSpriteIndex].bTrailingSpriteIndex = -1;
    s_pAceSprites[fubSpriteIndex].uwSpriteHeight = 0;
    s_pAceSprites[fubSpriteIndex].uwSpriteCenter = 0;
    s_pAceSprites[fubSpriteIndex].iBounceBottomLimit = 0;
    s_pAceSprites[fubSpriteIndex].iBounceRightLimit = 0;
  }

  // Bounce limits
  s_pAceSprites[fubSpriteIndex].iBounceBottomLimit = 255 - ulSpriteSize / 4;
  s_pAceSprites[fubSpriteIndex].iBounceRightLimit = 319 - 16;

  s_pAceSprites[fubSpriteIndex].uwSpriteHeight = (ulSpriteSize - 4) / 8;
  s_pAceSprites[fubSpriteIndex].uwSpriteCenter = 8;

  s_pAceSprites[fubSpriteIndex].ulSpriteSize = ulSpriteSize;
  s_pAceSprites[fubSpriteIndex].pSpriteData = (UBYTE *)memAlloc(ulSpriteSize, MEMF_CHIP);
  memcpy(s_pAceSprites[fubSpriteIndex].pSpriteData, (void *)pSpriteData, ulSpriteSize);

  ULONG ulAddr = (ULONG)s_pAceSprites[fubSpriteIndex].pSpriteData;
  if (fubSpriteIndex < ACE_MAXSPRITES)
  {
    pMoveCmd = (tCopMoveCmd *)&pBlockSprites->pCmds[fubSpriteIndex * 2];
    pMoveCmd->bfValue = ulAddr >> 16;

    pMoveCmd = (tCopMoveCmd *)&pBlockSprites->pCmds[1 + fubSpriteIndex * 2];
    pMoveCmd->bfValue = ulAddr & 0xFFFF;
  }
  return pBlockSprites;
}

// Function to move all stars to the right
void moveStars()
{
  // Move each star by 2 pixels to the right and reset at 0xFF
  UBYTE *pStarPointer = (UBYTE *)s_pAceSprites[STAR_SPRITE_INDEX].pSpriteData + 1;

  UBYTE ubStarType = 0;
  for (UBYTE iStarCounter = 0; iStarCounter < s_pAceSprites[STAR_SPRITE_INDEX].uwSpriteHeight; iStarCounter++, pStarPointer += 8, ubStarType++)
  {
    UBYTE *pCtrlBit = pStarPointer + 2;
    if (ubStarType > 2)
      ubStarType = 0;

    // move if the star horizontal position is 0xF0, reset the position to the beginning of the line
    if ((*pStarPointer) >= ACE_SPRITE_MAX_HPOSITION)
    {
      (*pStarPointer) = ACE_SPRITE_MIN_HPOSITION;
      (*pCtrlBit) &= ~1UL;
      continue;
    }

    // If star index is more than zero move index per second (and always even positions)
    if (ubStarType)
    {
      (*pStarPointer) += ubStarType;
      continue;
    }

    // check if bit zero of fouth byte is 1, if yes reset it and add 1 to hpos
    if (*(pCtrlBit)&1U)
    {
      (*(pCtrlBit)) &= ~1UL;
      (*pStarPointer)++;
    }
    // else just set it to move sprite only 1px to the right
    else
      (*pCtrlBit) |= 1UL;
  }
}

tRandManager s_sRandManager;

// Init stars sprite data with random values on the horizontal position starting from ubStarFirstVerticalPosition
void initRandStars(UBYTE *pStarData2, const UBYTE ubStarFirstVerticalPosition, const UBYTE ubStarsCount)
{
  const UBYTE ubSingleSpriteHeight = 1;
  const UBYTE ubSingleSpriteGap = 1;
  // Generate random X position from 64 to 216 (where the sprite is ON SCREEN)
  randInit(&s_sRandManager, getRayPos().bfPosY, getRayPos().bfPosX);

  UWORD uwStarFirstVerticalPositionCounter = (UWORD)ubStarFirstVerticalPosition + ACE_SPRITE_MIN_VPOSITION;

  for (UBYTE ubStarCounter = 0; ubStarCounter < ubStarsCount; ubStarCounter++, pStarData2 += 8)
  {
    *pStarData2 = (UBYTE)(uwStarFirstVerticalPositionCounter & 0x00FF); // VSTART

    // Calculate HSTART
    UWORD uwRandomXPosition = (randUw(&s_sRandManager) % 153) + 64;
    *(pStarData2 + 1) = (UBYTE)uwRandomXPosition; // HSTART

    // Calculate VStop
    UWORD uwVStop = uwStarFirstVerticalPositionCounter + ubSingleSpriteHeight;
    *(pStarData2 + 2) = (UBYTE)(uwVStop & 0x00FF); // VStop

    UBYTE *pControl = pStarData2 + 3;

    // Set HStop least significant bit
    *(pStarData2 + 3) = (UBYTE)uwRandomXPosition & 1UL;

    // Set VStart msb
    if (uwStarFirstVerticalPositionCounter > 255)
      *pControl |= 0x04;
    else
      *pControl &= 0xFB;

    // Set VStop msb
    if (uwVStop > 255)
      *pControl |= 0x02;
    else
      *pControl &= 0xFD;

    *(pStarData2 + 4) = 0x10;
    *(pStarData2 + 5) = 0x00;
    *(pStarData2 + 6) = 0x00;
    *(pStarData2 + 7) = 0x00;

    uwStarFirstVerticalPositionCounter += (ubSingleSpriteHeight + ubSingleSpriteGap);
  }

  *(pStarData2 + 0) = 0x00;
  *(pStarData2 + 1) = 0x00;
  *(pStarData2 + 2) = 0x00;
  *(pStarData2 + 3) = 0x00;
  return;
}

tState g_sStateGame = {.cbCreate = gameGsCreate, .cbLoop = gameGsLoop, .cbDestroy = gameGsDestroy};
