#include "intro.h"

static tView *s_pView;
static tVPort *s_pViewport;
static tSimpleBufferManager *s_pBuffer;

static tBitMap *s_pBrainsImage;
static tBitMap *s_pAceImage;
static tBitMap *s_pTitlescreenImage;
static tBitMap *s_pPowerupsImage;
static tBitMap *s_pPowerupsMask;
static tTextBitMap *s_pIntroText;
static tFont *s_pFont;
static tPtplayerMod *s_pIntroMusic;

static tIntroStage s_eIntroStage = INTRO_BRAINS;
static UBYTE s_ubFrameCounter = 0;
static UWORD s_uwWaitTimer = INTRO_WAIT_TIME;
static UBYTE s_ubDimLevel = 0;
static UBYTE s_ubFadeInComplete = FALSE;
static UBYTE s_ubFadeOutComplete = FALSE;
static UBYTE s_ubProcessFade = TRUE;
static UBYTE s_ubAllowSkip = FALSE;
static UBYTE s_ubWaitForFire = FALSE;
static UWORD s_uwAcePalette[32] = {0};
static UWORD s_uwTitlescreenPalette[32] = {0};
static UWORD s_uwFadePalette[16][32] = {0};
static UWORD s_uwGradient[] = {0xff3,0xfd3,0xea2,0xd82,0xc61,0xc31,0xb10,0xff3};

static const char s_cIntroText[] = " ONE HUNDRED AND TWENTY EIGHT\n  YEARS AFTER THEIR INVASION\nFLEET WAS DESTROYED A LONE\nBATTLESHIP OF THE BARRIX EMPIRE\n APPEARS IN OUR SOLAR SYSTEM,\n  THE RESULT OF AN FTL DRIVE\nMALFUNCTION THAT DELAYED THEIR\n          ARRIVAL.\n  HEAVILY DAMAGED BY ORBITAL\nPLATFORMS THE BATTLESHIP RACES\n       TOWARDS EARTH,\n IT IS UP TO YOU TO BOARD THE\n EXPERIMENTAL TTE1337 FIGHTER\n AND DEFEAT THE BARRIX EMPIRE\n      ONCE AND FOR ALL!\n\n          PRESS FIRE";
static const char s_cGuideText[] = "   AN AMIGAMEJAM 2024 ENTRY\n\n  ART: RCK015\n CODE: BITWISE\nMUSIC: H0FFMAN\n\nJOYSTICK OR ARROW TO MOVE\nBUTTON 1 OR SPACE TO FIRE\nBUTTON 2 OR B FOR SPECIAL\n\n    EXTRA LIFE\n\n    SPECIAL BOMB\n\n    WEAPON UPGRADE\n\n     PRESS FIRE TO START";

void introGsCreate(void) {
    s_pView = viewCreate(0,
        TAG_VIEW_GLOBAL_PALETTE, 1,
    TAG_DONE);

    s_pViewport = vPortCreate(0,
        TAG_VPORT_VIEW, s_pView,
        TAG_VPORT_BPP, GAME_BPP,
    TAG_DONE);

    s_pBuffer = simpleBufferCreate(0,
        TAG_SIMPLEBUFFER_VPORT, s_pViewport,
        TAG_SIMPLEBUFFER_USE_X_SCROLLING, 0,
        TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
        TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR,
    TAG_DONE);

    // Load music
    ptplayerCreate(1);
    ptplayerSetChannelsForPlayer(0b1111);
    ptplayerSetMasterVolume(56);
    s_pIntroMusic = ptplayerModCreateFromFd(pakFileGetFile(g_pPakFile, "intro.mod"));
    ptplayerLoadMod(s_pIntroMusic, 0, 0);
    ptplayerEnableMusic(1);

    // Load assets
    s_pFont = fontCreateFromFd(pakFileGetFile(g_pPakFile, "hudfont.fnt"));
    s_pIntroText = fontCreateTextBitMap(288, 136);
    s_pBrainsImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "splash_brains.bm"), 0);
    s_pAceImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "splash_ace.bm"), 0);
    s_pTitlescreenImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_title.bm"), 0);
    s_pPowerupsImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "powerups_square.bm"), 0);
    s_pPowerupsMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "powerups_square_mask.bm"), 0);

    // Generate fade palette lookup
    paletteLoadFromFd(pakFileGetFile(g_pPakFile, "game.plt"), s_uwTitlescreenPalette, 32);
    s_uwTitlescreenPalette[1] = 0x213;
    paletteLoadFromFd(pakFileGetFile(g_pPakFile, "splash_ace.plt"), s_uwAcePalette, 32);
    paletteLoadFromFd(pakFileGetFile(g_pPakFile, "splash_brains.plt"), s_uwFadePalette[15], 32);
    for (UBYTE i=0; i<16; i++) {
        paletteDim(s_uwFadePalette[15], s_uwFadePalette[i], 32, i);
    }

    // Setup score text gradient
    UWORD uwGradientYPos = 143;
    tCopBlock *colorCopBlock = copBlockCreate(s_pView->pCopList, 1, 0, uwGradientYPos);
    while (uwGradientYPos < 276) {
        UWORD uwYPos = uwGradientYPos;
        
        for (UBYTE i=0; i<8; i++) {
            copMove(s_pView->pCopList, colorCopBlock, &g_pCustom->color[31], s_uwGradient[i]);
            uwYPos++;
            colorCopBlock = copBlockCreate(s_pView->pCopList, 1, 0, uwYPos);
        }

        uwGradientYPos += 8;
    }
    colorCopBlock = copBlockCreate(s_pView->pCopList, 1, 0, uwGradientYPos);
    copMove(s_pView->pCopList, colorCopBlock, &g_pCustom->color[31], 0xfff);

    // Blit first logo
    blitCopy(s_pBrainsImage, 0, 0, s_pBuffer->pBack, 113, 58, 96, 142, MINTERM_COOKIE);
    viewLoad(s_pView);
    systemUnuse();

    logWrite("State Start: INTRO_BRAINS");
    s_eIntroStage = INTRO_BRAINS;
}

void introGsLoop(void) {
    ptplayerProcess();

    if(keyCheck(KEY_ESCAPE)) {
        ptplayerSetMasterVolume(0);
        ptplayerStop();        
        gameExit();
    }

	if (keyUse(KEY_SPACE) || joyCheck(JOY1_FIRE)) {
        if (s_ubWaitForFire == TRUE) {
            s_ubWaitForFire = FALSE;
        }

        if (s_ubAllowSkip == TRUE) {
            ptplayerSetMasterVolume(0);
            ptplayerStop();
            stateChange(g_pGameStateManager, &g_pGameStates[STATE_GAME]);
            return;
        }
	}

    if (s_ubProcessFade == TRUE) {
        // Only process every 5 frames.
        if (s_ubFrameCounter >=5) {
            s_ubFrameCounter = 0;
            updatePalette(s_ubDimLevel);
            
            // Fade in finished?
            if (s_ubFadeInComplete == FALSE && s_ubDimLevel == 15) {
                logWrite("FadeIn Complete");
                s_ubFadeInComplete = TRUE;
            }

            // Fade out finished?
            if (s_ubFadeInComplete == TRUE && s_ubFadeOutComplete == FALSE && s_ubDimLevel == 0) {
                logWrite("FadeOut Complete");
                s_ubFadeOutComplete = TRUE;
                s_uwWaitTimer = INTRO_WAIT_TIME;
            }

            if (s_ubFadeInComplete == FALSE && s_ubDimLevel < 15) {
                logWrite("Fadein: %d", s_ubDimLevel);
                s_ubDimLevel++;
            }

            if (s_ubFadeInComplete == TRUE && s_ubDimLevel > 0 && s_uwWaitTimer == 0 && s_ubWaitForFire == FALSE) {
                logWrite("Fadeout: %d", s_ubDimLevel);
                s_ubDimLevel--;
            }
            
            if (s_ubDimLevel == 15 && s_uwWaitTimer > 0) {
                logWrite("Wait: %d", s_uwWaitTimer);
                s_uwWaitTimer--;
            }
        }
    }

    if (s_ubFadeInComplete == TRUE && s_ubFadeOutComplete == TRUE) {
        s_ubFadeInComplete = FALSE;
        s_ubFadeOutComplete = FALSE;

        switch (s_eIntroStage) {
            case INTRO_BRAINS:
                logWrite("State End: INTRO_BRAINS");
                blitRect(s_pBuffer->pBack, 113, 58, 96, 142, 0); // Clear BitwiseBrains logo
                for (UBYTE i=0; i<16; i++) {
                    paletteDim(s_uwAcePalette, s_uwFadePalette[i], 32, i);
                }                
                blitCopy(s_pAceImage, 0, 0, s_pBuffer->pBack, 53, 73, 224, 114, MINTERM_COOKIE); // Blit ACE logo
                logWrite("State Start: INTRO_ACE");
                s_eIntroStage = INTRO_ACE;
                break;
            case INTRO_ACE:
                logWrite("State End: INTRO_ACE");
                blitRect(s_pBuffer->pBack, 53, 73, 224, 114, 0); // Clear ACE logo
                for (UBYTE i=0; i<16; i++) {
                    paletteDim(s_uwTitlescreenPalette, s_uwFadePalette[i], 32, i);
                }
                blitCopy(s_pTitlescreenImage, 0, 0, s_pBuffer->pBack, 48, 16, 224, 80, MINTERM_COOKIE); // Blit title
                logWrite("State Start: INTRO_TITLE");
                s_eIntroStage = INTRO_TITLE;
                break;
            case INTRO_TITLE:
                logWrite("State End: INTRO_TITLE");
                fontDrawStr(s_pFont, s_pBuffer->pBack, 29, 100, s_cIntroText, 1, 0, s_pIntroText); // Text shadow
                fontDrawStr(s_pFont, s_pBuffer->pBack, 28, 99, s_cIntroText, 31, FONT_COOKIE, s_pIntroText); // Text
                logWrite("State Start: INTRO_TEXT");
                s_eIntroStage = INTRO_TEXT;
                s_ubWaitForFire = TRUE;
                s_uwWaitTimer = 1;
                break;
            case INTRO_TEXT:
                logWrite("State End: INTRO_TEXT");
                blitRect(s_pBuffer->pBack, 28, 99, 280, 128, 0); // Clear text
                fontDrawStr(s_pFont, s_pBuffer->pBack, 29, 100, s_cGuideText, 1, 0, s_pIntroText); // Text shadow
                fontDrawStr(s_pFont, s_pBuffer->pBack, 28, 99, s_cGuideText, 31, FONT_COOKIE, s_pIntroText); // Text
                blitCopyMask(s_pPowerupsImage, 0,  0, s_pBuffer->pBack, 38, 175, 16, 16, s_pPowerupsMask->Planes[0]);
                blitCopyMask(s_pPowerupsImage, 0, 16, s_pBuffer->pBack, 38, 191, 16, 16, s_pPowerupsMask->Planes[0]);
                blitCopyMask(s_pPowerupsImage, 0, 32, s_pBuffer->pBack, 38, 207, 16, 16, s_pPowerupsMask->Planes[0]);
                logWrite("State Start: INTRO_GUIDE");
                s_eIntroStage = INTRO_FINISHED;
                s_ubWaitForFire = TRUE;
                s_ubAllowSkip = TRUE;
                s_uwWaitTimer = 1;
                break;
            case INTRO_FINISHED:
                logWrite("INTRO_FINISHED");
                ptplayerSetMasterVolume(0);
                ptplayerEnableMusic(0);
                stateChange(g_pGameStateManager, &g_pGameStates[STATE_GAME]);
                return;
        }
    }

    viewProcessManagers(s_pView);
    copProcessBlocks();
    systemIdleBegin();
    vPortWaitForEnd(s_pViewport);
    systemIdleEnd();
    s_ubFrameCounter++;
}

void introGsDestroy(void) {
    systemUse();
    bitmapDestroy(s_pBrainsImage);
    bitmapDestroy(s_pAceImage);
    bitmapDestroy(s_pTitlescreenImage);
    bitmapDestroy(s_pPowerupsImage);
    bitmapDestroy(s_pPowerupsMask);
    fontDestroyTextBitMap(s_pIntroText);
    fontDestroy(s_pFont);
    ptplayerModDestroy(s_pIntroMusic);
    ptplayerDestroy();
    viewDestroy(s_pView);
}

static void updatePalette(UBYTE ubIndex) {
    for (UBYTE i=0; i<32; i++) {
        s_pViewport->pPalette[i] = s_uwFadePalette[ubIndex][i];
    }

    viewUpdateGlobalPalette(s_pView);
}