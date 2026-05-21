#include <ace/managers/viewport/simplebuffer.h>
#include <ace/managers/joy.h>
#include <ace/managers/key.h>
#include <ace/managers/system.h>
#include <ace/managers/game.h>
#include <ace/utils/palette.h>
#include <ace/utils/string.h>
#include <stdio.h>
#include <ace/managers/state.h>
#include <ace/managers/blit.h>
#include <ace/utils/font.h>
#include <ace/managers/ptplayer.h>
#include <ace/managers/rand.h>
#include "enum.h"

static tView *s_pView;
static tVPort *s_pVp;
static tSimpleBufferManager *s_pVpManager;

//extern tState g_sStateIntro;
extern tStateManager *g_pStateMachineGame;
//extern tState g_sStateMenu;
extern tState g_sStateCredits;

void waitFrames();

static tFont *s_pFont;
static tTextBitMap *s_pBmText;

static tPtplayerSfx *s_pAtari;

UBYTE typingRandomizer = 0;

#define LOAD 1
#define RUN 2

char szWungiel[50];
char lineToPass[50];

static const char *lines[5] = {
    "",
    "if (system.hacked == TRUE){",
    "atariMode = ON; }",
    "",
    "READY",
};

const char load1[] = "LOAD ATARENIUM FALCON";
const char *w2 = "ERROR - INSERT WINCY WUNGLA TO DF0:";
const char dots[] = "...";
const char *w3 = "WUNGIEL DETECTED";
const char *w4 = "DONE";
const char run[] = "RUN";

void blitBlueAtariScreen(void){
    blitRect(s_pVpManager->pBack, 0, 0, 320, 128, 21);
    blitRect(s_pVpManager->pBack, 0, 128, 320, 128, 21);
}

void printLineOfAtariText(const char *lineToPass, UBYTE textPositionY){
        sprintf(szWungiel, lineToPass);
        fontFillTextBitMap(s_pFont, s_pBmText, szWungiel);
        fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, 10, textPositionY, 23, FONT_COOKIE);
}

void printThreeDots(UBYTE dotsPositionY){
    for (BYTE i = 0; i < 3; ++i) {
        sprintf(szWungiel, "%c", dots[i]);
        fontFillTextBitMap(s_pFont, s_pBmText, szWungiel);
        fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, (i * 7) + 10, dotsPositionY, 23, FONT_COOKIE);
        waitFrames(s_pVp, 50, 200);
    }
}

void typingAtariLineWithSound(UBYTE line, UBYTE typingPositionY){
    UWORD uwX = 10;
    switch (line){
        case LOAD:
            for (UBYTE i = 0; i < strlen(load1); ++i) {
                sprintf(szWungiel, "%c", load1[i]);
                fontFillTextBitMap(s_pFont, s_pBmText, szWungiel); 
                fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, uwX, typingPositionY, 23, FONT_COOKIE);
                uwX += fontGlyphWidth(s_pFont, load1[i]) + 1;
                ptplayerSfxPlay(s_pAtari, 3, 64, 100);
                typingRandomizer = ulRandMinMax(10, 20);
                waitFrames(s_pVp, typingRandomizer, 200);
            }
            break;
        case RUN:
            for (BYTE i = 0; i < 3; ++i) {
                sprintf(szWungiel, "%c", run[i]);
                fontFillTextBitMap(s_pFont, s_pBmText, szWungiel);
                fontDrawTextBitMap(s_pVpManager->pBack, s_pBmText, (i * 7) + 10, 120, 23, FONT_COOKIE);
                ptplayerSfxPlay(s_pAtari, 3, 64, 100);
                typingRandomizer = ulRandMinMax(10, 20);
                waitFrames(s_pVp, typingRandomizer, 200);
            }
            break;
    }
}

void stateWungielCreate(void)
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

    randInit(476);
    

    ptplayerCreate(1);
    s_pAtari = ptplayerSfxCreateFromFile("data/Atari.sfx");

    s_pFont = fontCreate("data/topaz.fnt");
    s_pBmText = fontCreateTextBitMap(TEXT_BITMAP_WIDTH, s_pFont->uwHeight);

    blitBlueAtariScreen();

    for(UBYTE i = 1; i < 5; ++i) {
        if (!stringIsEmpty(lines[i])){
            printLineOfAtariText(lines[i], i * 10);
        }
    }
    waitFrames(s_pVp, 50, 200);

    typingAtariLineWithSound(LOAD, 50);
    waitFrames(s_pVp, 50, 200);

    printLineOfAtariText(w2, 60);   // 'insert wincy wungla' ...
    waitFrames(s_pVp, 50, 200);

    printThreeDots(70);
    
    printLineOfAtariText(w3, 80);  // 'wungiel detected'
    waitFrames(s_pVp, 50, 200);

    typingAtariLineWithSound(LOAD, 90);

    printThreeDots(100);

    printLineOfAtariText(w4, 110);  // 'done'
    waitFrames(s_pVp, 50, 200);

    typingAtariLineWithSound(RUN, 120);

    printThreeDots(130);

}

void stateWungielLoop(void)
{
    stateChange(g_pStateMachineGame, &g_sStateCredits);
    return;
}

void stateWungielDestroy(void)
{
    systemUse();
    ptplayerSfxDestroy(s_pAtari);
    ptplayerDestroy();
    fontDestroy(s_pFont);
    fontDestroyTextBitMap(s_pBmText);
    joyClose();
    keyDestroy();
    viewDestroy(s_pView);
}

tState g_sStateWungiel ={
    .cbCreate = stateWungielCreate,
    .cbLoop = stateWungielLoop,
    .cbDestroy = stateWungielDestroy,
    .cbSuspend = 0,
    .cbResume = 0,
    .pPrev = 0 };
