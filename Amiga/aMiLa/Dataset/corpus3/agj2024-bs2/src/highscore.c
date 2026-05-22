#include "highscore.h"

static tView *s_pView;
static tVPort *s_pViewport;
static tSimpleBufferManager *s_pBuffer;

static tFont *s_pFont;
static tPtplayerMod *s_pMusic;
static tBitMap *s_tTitleImage;
static tTextBitMap *s_pScoreText;
static tTextBitMap *s_pPressFireText;
static tTextBitMap *s_pGreetsText[GREETS_MAX];

static UWORD s_uwFadePalette[16][32] = {0};
static UBYTE s_ubDimLevel = 0;
static UBYTE s_ubFadeIn = TRUE;
static UBYTE s_ubDisplayCredits = FALSE;
static UWORD s_uwHighScoreTimer = 0;
static UBYTE s_ubEnterInitials = FALSE;
static UBYTE s_ubSaveHighscore = FALSE;
static UBYTE s_ubInitialsYPos = 0;
static char s_cInitialsInput[4] = {0};
static char s_cGreets[GREETS_MAX][32] = {{"  ART:  RCK015              "},
                                         {" CODE:  BITWISE             "},
                                         {"MUSIC:  H0FFMAN             "},
                                         {"                            "},                                                                                  
                                         {"  AN AMIGAMEJAM 2024 ENTRY  "},
                                         {"    GREETS TO ALL IN TTE    "},
                                         {"BIG THANKS TO AGJ ORGANIZERS"},
                                         {"                            "},
                                         {"      ACE LOGO BY THAY      "},
                                         {"AUDIO MIXER BY DUTCHRETROGUY"},
                                         {"  SPECIAL THANKS TO KAIN!   "}};

static UBYTE s_ubInitialsIndex = 0;
static UBYTE s_ubTableIndex = 0;
static tHighScore s_tHighScores[HIGHSCORE_MAX] = {0};
static UWORD s_uwGradient[] = {0xff3,0xfd3,0xea2,0xd82,0xc61,0xc31,0xb10};

static UWORD s_uwPulse[] = {0x111, 0x222, 0x333, 0x444, 0x555, 0x666, 0x777, 0x888, 0x999, 0xaaa, 0xbbb, 0xccc, 0xddd, 0xeee, 0xfff, 0xfff, 0xeee, 0xddd, 0xccc, 0xbbb, 0xaaa, 0x999, 0x888, 0x777, 0x666, 0x555, 0x444, 0x333, 0x222};
static UBYTE s_ubPulseIdx = 0;

void highscoreGsCreate(void) {
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

    spriteManagerCreate(s_pView, 0);
    systemSetDmaBit(DMAB_SPRITE, 0);

    // Load music.
    ptplayerCreate(1);
    ptplayerSetChannelsForPlayer(0b1111);
    ptplayerSetMasterVolume(24);
    s_pMusic = ptplayerModCreateFromFd(pakFileGetFile(g_pPakFile, "intro.mod"));
    ptplayerLoadMod(s_pMusic, 0, 0);
    ptplayerEnableMusic(1);

    // Load font and create text bitmaps.
    s_pFont = fontCreateFromFd(pakFileGetFile(g_pPakFile, "hudfont.fnt"));
    s_pScoreText = fontCreateTextBitMap(96, 8);
    s_pPressFireText = fontCreateTextBitMap(128, 8);
    for (UBYTE i=0; i<GREETS_MAX; i++) {
        s_pGreetsText[i] = fontCreateTextBitMap(GREETS_WIDTH, GREETS_HEIGHT);
        fontFillTextBitMap(s_pFont, s_pGreetsText[i], s_cGreets[i]);
    }
    
    // Load palette.
    paletteLoadFromFd(pakFileGetFile(g_pPakFile, "game.plt"), s_uwFadePalette[15], 32);
    s_uwFadePalette[15][1] = 0x213;
    s_uwFadePalette[15][PULSE_COLOR] = 0xFFF;
    for (UBYTE i=0; i<16; i++) {
        paletteDim(s_uwFadePalette[15], s_uwFadePalette[i], 32, i);
    }

    // Blit title image.
    s_tTitleImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_title.bm"), 0);
    blitCopy(s_tTitleImage, 0, 0, s_pBuffer->pBack, 48, 16, 224, 80, MINTERM_COOKIE);

    // Reset values
    s_ubDimLevel = 0;
    s_ubFadeIn = TRUE;
    s_ubDisplayCredits = FALSE;
    s_uwHighScoreTimer = 0;
    s_ubEnterInitials = FALSE;
    s_ubSaveHighscore = FALSE;
    s_ubInitialsYPos = 0;
    s_ubInitialsIndex = 0;
    s_ubTableIndex = 0;

    // Load highscore data.
	tFile *pReadFile = diskFileOpen("highscore.dat", "rb");
	fileRead(pReadFile, s_tHighScores, sizeof(s_tHighScores));
    fileClose(pReadFile);

    // Clamp score
    if (g_ulPlayerScore > HIGHSCORE_VALUE_MAX) { g_ulPlayerScore = HIGHSCORE_VALUE_MAX; }

    // Check player score against high score table
    for (UBYTE tableIdx=0; tableIdx<HIGHSCORE_MAX; tableIdx++) {
        if (g_ulPlayerScore > s_tHighScores[tableIdx].ulScore) {
            // Shift down
            for (UBYTE shiftIdx=HIGHSCORE_MAX-1; shiftIdx > tableIdx; shiftIdx--) {
                s_tHighScores[shiftIdx] = s_tHighScores[shiftIdx-1];
            }

            s_ubEnterInitials = TRUE; // Player has a high score.
            s_ubInitialsYPos = HIGHSCORE_YPOS + (HIGHSCORE_SPACING * tableIdx); // Text offset.
            s_ubTableIndex = tableIdx;
            memset(s_tHighScores[tableIdx].cInitials, 0, sizeof(s_tHighScores[tableIdx].cInitials));
            s_tHighScores[tableIdx].ulScore = g_ulPlayerScore;
            s_ubSaveHighscore = TRUE;
            break;
        }
    }

    // Setup score text gradient
    UWORD uwGradientYPos = 128;
    tCopBlock *colorCopBlock = copBlockCreate(s_pView->pCopList, 1, 0, uwGradientYPos);
    while (uwGradientYPos < 276) {
        UWORD uwYPos = uwGradientYPos;
        
        for (UBYTE i=0; i<GRADIENT_LENGTH; i++) {
            copMove(s_pView->pCopList, colorCopBlock, &g_pCustom->color[HIGHSCORE_COLOR], s_uwGradient[i]);
            uwYPos++;
            colorCopBlock = copBlockCreate(s_pView->pCopList, 1, 0, uwYPos);
        }

        uwGradientYPos += 12;
    }
    colorCopBlock = copBlockCreate(s_pView->pCopList, 1, 0, uwGradientYPos);
    copMove(s_pView->pCopList, colorCopBlock, &g_pCustom->color[HIGHSCORE_COLOR], 0xfff);

    renderText();
    systemUnuse();
    viewLoad(s_pView);
}

void highscoreGsLoop(void) {
    // Fade in
    if (s_ubFadeIn == TRUE && s_ubDimLevel < 15) {
        s_ubDimLevel++;
        if (s_ubDimLevel == 15) { s_ubFadeIn = FALSE; }

        updatePalette(s_ubDimLevel);
        viewProcessManagers(s_pView);
        copProcessBlocks();
        systemIdleBegin();
        vPortWaitForEnd(s_pViewport);
        systemIdleEnd();          
        return;
    }

    // Input
    if(keyCheck(KEY_ESCAPE)) {
        ptplayerSetMasterVolume(0);
        ptplayerStop();
        gameExit();
    }

    // Start game.
    if (s_ubEnterInitials == FALSE && s_ubFadeIn == FALSE) {
        if (keyUse(KEY_SPACE) || joyCheck(JOY1_FIRE)) {
            ptplayerSetMasterVolume(0);
            ptplayerStop();
            stateChange(g_pGameStateManager, &g_pGameStates[STATE_GAME]);
            return;
        }
    }

    // Enter high score initials
    if (s_ubEnterInitials == TRUE && s_ubInitialsIndex < 3 && s_ubFadeIn == FALSE) {
        if (keyUse(KEY_BACKSPACE)) {
            if (s_ubInitialsIndex > 0) { s_ubInitialsIndex--; }
        }

        if(keyUse(g_sKeyManager.ubLastKey)) {
            UBYTE ubInput = g_pToAscii[g_sKeyManager.ubLastKey];
            ubInput -= 'a' - 'A';
            if (ubInput >= 'A' && ubInput <= 'Z') {
                s_cInitialsInput[s_ubInitialsIndex] = ubInput;
                logWrite("INPUT: %c / %c%c%c", ubInput, s_cInitialsInput[0], s_cInitialsInput[1], s_cInitialsInput[2]);

                char cHighscoreText[16];
                sprintf(cHighscoreText, "%c%c%c", s_cInitialsInput[0], s_cInitialsInput[1], s_cInitialsInput[2]);
                fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+1, s_ubInitialsYPos+1, cHighscoreText, 1, 0, s_pScoreText); // Drop shadow
                fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L, s_ubInitialsYPos, cHighscoreText, HIGHSCORE_COLOR, FONT_COOKIE, s_pScoreText);

                s_ubInitialsIndex++;
                if (s_ubInitialsIndex == 3) {
                    memcpy(s_tHighScores[s_ubTableIndex].cInitials, s_cInitialsInput, sizeof(s_tHighScores[s_ubTableIndex].cInitials));
                    blitRect(s_pBuffer->pBack, HIGHSCORE_OFFSET_L+10, HIGHSCORE_YPOS+((HIGHSCORE_SPACING*HIGHSCORE_MAX)+(HIGHSCORE_SPACING+4)), 128, 10, 0);
                    fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+11, (HIGHSCORE_YPOS+((HIGHSCORE_SPACING*HIGHSCORE_MAX)+(HIGHSCORE_SPACING+4)))+1, "  PRESS FIRE", 1, 0, s_pPressFireText);
                    fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+10, HIGHSCORE_YPOS+((HIGHSCORE_SPACING*HIGHSCORE_MAX)+(HIGHSCORE_SPACING+4)), "  PRESS FIRE", PULSE_COLOR, FONT_COOKIE, s_pPressFireText);
                    s_ubEnterInitials = FALSE;
                }                
            } else {
                logWrite("Invalid input!");
            }
        }
    }

    // Cycle between high scores and credits.
    if (s_ubEnterInitials == FALSE) {
        s_uwHighScoreTimer++;
        if (s_uwHighScoreTimer >= HIGHSCORE_TIMER) {
            s_uwHighScoreTimer = 0;
            s_ubDisplayCredits = !s_ubDisplayCredits;

            if (s_ubDisplayCredits == TRUE) {
                blitRect(s_pBuffer->pBack, HIGHSCORE_OFFSET_L, CREDITS_YPOS, 208, 128, 0); // Clear scores.
                //blitCopy(s_tCreditsImage, 0, 0, s_pBuffer->pBack, CREDITS_XPOS, CREDITS_YPOS, CREDITS_WIDTH, CREDITS_HEIGHT, MINTERM_COOKIE);
                UBYTE ubGreetsOffset = GREETS_YPOS;
                for (UBYTE i=0; i<GREETS_MAX; i++) {
                    fontDrawTextBitMap(s_pBuffer->pBack, s_pGreetsText[i], GREETS_XPOS+1, ubGreetsOffset+1, 1, 0);
                    fontDrawTextBitMap(s_pBuffer->pBack, s_pGreetsText[i], GREETS_XPOS, ubGreetsOffset, HIGHSCORE_COLOR, FONT_COOKIE);
                    ubGreetsOffset += HIGHSCORE_SPACING;
                }
            } else {
                //blitRect(s_pBuffer->pBack, CREDITS_XPOS, CREDITS_YPOS, CREDITS_WIDTH, CREDITS_HEIGHT, 0); // Clear credits.
                blitRect(s_pBuffer->pBack, GREETS_XPOS, GREETS_YPOS, GREETS_WIDTH, 128, 0); // Clear greets.
                renderText();
            }            
        }
    }

    s_ubPulseIdx++;
    if (s_ubPulseIdx >= PULSE_LENGTH) { s_ubPulseIdx = 0; }
    g_pCustom->color[PULSE_COLOR] = s_uwPulse[s_ubPulseIdx];
    //s_pViewport->pPalette[PULSE_COLOR] = s_uwPulse[s_ubPulseIdx];
    //viewUpdateGlobalPalette(s_pView);

    viewProcessManagers(s_pView);
    copProcessBlocks();
    systemIdleBegin();
    vPortWaitForEnd(s_pViewport);
    systemIdleEnd();  
}

void highscoreGsDestroy(void) {
    // Reset global variables
    g_ubLoopIteration = 0;
    g_ubCurrentStage = 0;
    g_ulPlayerScore = 0;
    g_ubEquippedProjectileType = 0;
    g_ubPlayerLives = PLAYER_LIVES_START;
    g_ubPlayerSpecial = PLAYER_SPECIAL_START;

    systemUse();
    
    if (s_ubSaveHighscore == TRUE) {
        tFile *pWriteFile = diskFileOpen("highscore.dat", "wb");
        fileWrite(pWriteFile, s_tHighScores, sizeof(s_tHighScores));
        fileClose(pWriteFile);
    }

    fontDestroy(s_pFont);
    bitmapDestroy(s_tTitleImage);
    fontDestroyTextBitMap(s_pScoreText);
    fontDestroyTextBitMap(s_pPressFireText);
    for (UBYTE i=0; i<GREETS_MAX; i++) {
        fontDestroyTextBitMap(s_pGreetsText[i]);
    }
    
    ptplayerModDestroy(s_pMusic);
    ptplayerDestroy();
    spriteManagerDestroy();
    viewDestroy(s_pView);
}

static void updatePalette(UBYTE ubIndex) {
    for (UBYTE i=0; i<32; i++) {
        s_pViewport->pPalette[i] = s_uwFadePalette[ubIndex][i];
    }

    viewUpdateGlobalPalette(s_pView);
}

static void renderText(void) {
    // TODO: Render to bitmap instead of fontDrawStr.
    UWORD uwYOffset = HIGHSCORE_YPOS;
    for (UBYTE i=0; i<HIGHSCORE_MAX; i++) {
        char cHighscoreText[10] = {0};
        sprintf(cHighscoreText, "%09ld", s_tHighScores[i].ulScore);
        // Shadow
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+1, uwYOffset+1, s_tHighScores[i].cInitials, 1, 0, s_pScoreText);
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_R+1, uwYOffset+1, cHighscoreText, 1, 0, s_pScoreText);
        
        // Text
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L, uwYOffset, s_tHighScores[i].cInitials, HIGHSCORE_COLOR, FONT_COOKIE, s_pScoreText);
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_R, uwYOffset, cHighscoreText, HIGHSCORE_COLOR, FONT_COOKIE, s_pScoreText);
        uwYOffset += HIGHSCORE_SPACING;
    }

    uwYOffset += HIGHSCORE_SPACING+4;
    if (s_ubEnterInitials == TRUE) {
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+11, uwYOffset+1, "ENTER INITIALS", 1, 0, s_pPressFireText);
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+10, uwYOffset, "ENTER INITIALS", PULSE_COLOR, FONT_COOKIE, s_pPressFireText);
    } else {
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+11, uwYOffset+1, "  PRESS FIRE", 1, 0, s_pPressFireText);
        fontDrawStr(s_pFont, s_pBuffer->pBack, HIGHSCORE_OFFSET_L+10, uwYOffset, "  PRESS FIRE", PULSE_COLOR, FONT_COOKIE, s_pPressFireText);
    }
}