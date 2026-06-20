#include "game.h"
#include "game_math.h"
#include "projectile.h"
#include "player.h"
#include "enemy.h"
#include "explosion.h"
#include "paths.h"
#include "waves.h"
#include "boss.h"

// Display
static tView *s_pView; // View containing all the viewports
static tVPort *s_pGameViewport; // Viewport for playfield
static tVPort *s_pHudViewport; // Viewport for HUD
static tTileBufferManager *s_pTileBuffer;
static tSimpleBufferManager *s_pHudBuffer;
static tCameraManager *s_pCamera;
static tBitMap *s_pPristineBuffer;
static UWORD s_uwFadePalette[16][32] = {0};
static UBYTE s_ubDimLevel = 0;
static UBYTE s_ubFadeOut = FALSE;
static UBYTE s_ubFrameCounter = 0;
static UBYTE s_ubFlashTimer = 0;
static UBYTE s_ubFlashOn = FALSE;

// System
static UBYTE s_ubGamePaused = FALSE;
static UBYTE s_ubCyclicRngIdx = 0;

// Audio
static tPtplayerMod *s_pGameMusic;
static tPtplayerSamplePack *s_pSamplePack;
static tPtplayerSfx *s_pSfxPlayerShot[PLAYER_PROJECTILE_TYPES];
static tPtplayerSfx *s_pSfxExplosion;
static tPtplayerSfx *s_pSfxCollectPowerup;
static tPtplayerSfx *s_pSfxBossShot;

// Level
static tBitMap *s_pTiles;
static UBYTE s_ubCameraCanMove = FALSE;
static UBYTE s_ubMoveCameraCounter = 0;
static UWORD s_uwCameraStartYPos = 0;
static UWORD s_uwLevelData[MAP_TILES_COUNT] = {0};
static UWORD s_uwMapHeightInTiles = 0;
static UWORD s_uwTilesInLevel = 0;
static UBYTE s_ubLevelStart = TRUE;
static UBYTE s_ubLevelStartTimer = 128;
static UBYTE s_ubLevelEnd = FALSE;
static UBYTE s_ubLevelEndReached = FALSE;
static UBYTE s_ubLevelEndTimer = 255;
static UBYTE s_ubBossReached = FALSE;

// HUD
static tFont *s_pFont;
static tTextBitMap *s_pHudScoreText;
static tTextBitMap *s_pHudLivesText;
static tTextBitMap *s_pHudSpecialText;
static tTextBitMap *s_pHudPowerText;
static tBitMap *s_pHudIconsImage;
static tBitMap *s_pHudIconsMask;
static tBitMap *s_pStageCompleteBgImage;
static tBitMap *s_pStageCompleteBgMask;
static tTextBitMap *s_pStageCompleteText;
static tBob s_tStageCompleteBgBob;

static ULONG s_ulPlayerScore = 0;
static UBYTE s_ubPlayerLives = PLAYER_LIVES_START;
static UBYTE s_ubPlayerSpecial = PLAYER_SPECIAL_START;
static UBYTE s_ubUpdateScore = TRUE;
static UBYTE s_ubUpdatePower = TRUE;
static UBYTE s_ubUpdateLives = TRUE;
static UBYTE s_ubUpdateSpecial = TRUE;

// Player
static tUwCoordYX s_tPlayerPosition;
static tBob s_tPlayerBob;
static tBitMap *s_pPlayerImage;
static tBitMap *s_pPlayerMask;
static tBob s_tEngineBob;
static tBitMap *s_pEngineImage;
static tBitMap *s_pEngineMask;
static UBYTE s_ubEngineAnimFrame = 0;
static tBob s_tPlayerExplosionBob;
static UBYTE s_ubPlayerExplosionAnimFrame = 0;
static UBYTE s_ubPlayerExplosionActive = FALSE;
static UBYTE s_ubFireDelay = 0;
static UBYTE s_ubSpecialDelay = 0;
static UBYTE s_ubAudioDelay = 0;
static UBYTE s_ubEquippedProjectileType = 0;
static UBYTE s_ubPlayerAlive = FALSE;
static UBYTE s_ubPlayerMovedLeft = FALSE;
static UBYTE s_ubPlayerMovedRight = FALSE;
static UBYTE s_ubPlayerMovedOnY = FALSE;
static UBYTE s_ubDisplayPlayer = TRUE;
static UBYTE s_ubDisplayEngine = TRUE;
static UBYTE s_ubPlayerIsInvincible = FALSE;
static UBYTE s_ubPlayerInvincibleTimer = 0;
static UWORD s_uwPlayerKills = 0;
static UBYTE s_ubPlayerDeaths = 0;
static UBYTE s_ubPlayerMoveSpeed = 0;

// Enemies
static tEnemy s_tEnemy[ENEMY_MAX] = {0};
static tBitMap *s_pEnemyImage;
static tBitMap *s_pEnemyMask;
static tEnemyWave s_tNextWave = {0};
static UWORD s_uwWaveIndex = 0;
static UBYTE s_ubActiveEnemies = 0;

// Big enemy
static tBitMap *s_pBigEnemyImage;
static tBitMap *s_pBigEnemyMask;
static tBob s_tBigEnemyBob;
static UBYTE s_ubBigEnemyAlive = FALSE;

// Boss
static tBossTurret s_tBossTurrets[4] = {0};
static tBitMap *s_pBossDamageImage;
static tBitMap *s_pBossDamageMask;
static tBitMap *s_pBossShotImage;
static tBitMap *s_pBossShotMask;
static tBitMap *s_pBossHitFlashImage;
static tBitMap *s_pBossHitFlashMask;
static tBob s_tBossShotBob;
static UBYTE s_ubBossShotAlive = FALSE;
static UBYTE s_ubBossShotVisible = FALSE;
static UWORD s_uwBossShotTimer = 0;
static UBYTE s_ubBossFirstShot = TRUE;
static UBYTE s_ubBossTurretsAlive = 4;
static UBYTE s_ubBossDefeated = FALSE;
static UBYTE s_ubBossExplosionIdx = 0;

// Explosions
static tExplosion s_tExplosions[EXPLOSIONS_MAX] = {0};
static UBYTE s_ubActiveExplosions = 0;
static tBitMap *s_pSmallExplosionImage;
static tBitMap *s_pSmallExplosionMask;

// Big Explosion
static tBob s_tBigExplosionBob;
static UBYTE s_ubBigExplosionActive = 0;
static UBYTE s_ubBigExplosionFrame = 0;
static tBitMap *s_pBigExplosionImage;
static tBitMap *s_pBigExplosionMask;

// Powerups
static tBitMap *s_pPowerupsImage;
static tBitMap *s_pPowerupsMask;
static tBob s_tLifePowBob;
static tBob s_tSpecialPowBob;
static tBob s_tWeaponPowBob;
static UBYTE s_ubLifePowActive = FALSE;
static UBYTE s_ubSpecialPowActive = FALSE;
static UBYTE s_ubWeaponPowActive = FALSE;
static UBYTE s_ubPowerupBounceTimer = 0;

// Player Projectiles
static tPlayerProjectile s_tPlayerProjectiles[PLAYER_PROJECTILE_MAX] = {0};
static tSprite *s_pPlayerProjectileSprites[PLAYER_PROJECTILE_TYPES] = {0};
static tBitMap *s_pPlayerProjectileImages[PLAYER_PROJECTILE_TYPES] = {0};

// Enemy Projectiles
static tSprite *s_pEnemyProjectileSprite[ENEMY_SPRITE_CHANNELS] = {0};
static tBob s_tEnemyProjectileBob[ENEMY_BOB_CHANNELS] = {0};
static UBYTE s_ubEnemyProjectileBobTypes[ENEMY_BOB_CHANNELS] = {0};
static UBYTE s_ubProjectileBobIndex = 0;
static UBYTE s_ubEnemyProjectileSpeed = 0;
static UBYTE s_ubEnemyProjectileRange = 0;
static UBYTE s_ubEnemyProjectileAccuracy = 0;
static UBYTE s_ubEnemyProjectileSafetyMargin = 0;

  // fix16
static tComplexEnemyProjectile s_tComplexEnemyProjectiles[ENEMY_PROJECTILE_MAX] = {0};
static tComplexChannelBounds s_fComplexChannelBounds[ENEMY_SPRITE_CHANNELS] = {0};
static fix16_t s_fViewportXMin = 0;
static fix16_t s_fViewportXMax = 0;
static fix16_t s_fBoundsMax = 0;
static fix16_t s_fBoundsMin = 0;

  // UWORD
static tSimpleEnemyProjectile s_tSimpleEnemyProjectiles[ENEMY_PROJECTILE_MAX] = {0};
static tSimpleChannelBounds s_tSimpleChannelBounds[ENEMY_SPRITE_CHANNELS] = {0};

static tBitMap *s_pEnemyProjectileBobsImage;
static tBitMap *s_pEnemyProjectileBobsMask;
static tBitMap *s_pEnemyProjectileSpriteImage[ENEMY_PROJECTILE_TYPES];

// Text
static tBob s_tTextGameOverBob;
static tBitMap *s_pTextGameOverImage;
static tBitMap *s_pTextGameOverMask;
static UBYTE s_ubShowTextGameOver = FALSE;
static UBYTE s_ubShowTextGameOverTimer = 255;

static tBob s_tTextReadyBob;
static tBitMap *s_pTextReadyImage;
static tBitMap *s_pTextReadyMask;
static UBYTE s_ubShowTextReady = FALSE;

static tBob s_tTextGoBob;
static tBitMap *s_pTextGoImage;
static tBitMap *s_pTextGoMask;
static UBYTE s_ubShowTextGo = FALSE;

// Bitmaps
static UWORD s_uwEngineAnimOffset[] = {0, 0, 50, 50, 100, 100, 150, 150}; // 16x1==10
static UWORD s_uwSmallExplosionAnimOffset[] = {0, 0, 160, 160, 320, 320, 480, 480, 640, 640, 800, 800, 960, 960, 1120, 1120, 1280, 1280}; // 16x16
static UWORD s_uwBigExplosionAnimOffset[] = {0, 0, 0, 640, 640, 640, 1280, 1280, 1280, 1920, 1920, 1920, 2560, 2560, 2560, 3200, 3200, 3200, 3840, 3840, 3840, 4480, 4480, 4480}; // 32x32
static UWORD s_uwEnemyBitmapOffset[] = {0, 160, 320, 480, 640, 800, 960, 1120, 1280, 1440};
static UWORD s_uwEnemyProjectileBitmapOffset[] = {0, 140, 280, 420};

// Game states.

void gameGsCreate(void) {
    initGame();
    initViews();
    initHud();
    initBobs();
    initSprites();
    initAudio();
    gameMathInit();
    viewLoad(s_pView);
    tileBufferRedrawAll(s_pTileBuffer);
    memLogPeak();
    systemUnuse();
}

void gameGsLoop(void) {
    ptplayerProcess();

    // Check quit and pause before anything else.
    if (keyCheck(KEY_ESCAPE)) {
        gameExit();
    }

    if (keyCheck(KEY_P)) {
        if (s_ubFireDelay == 0) {
            s_ubGamePaused = !s_ubGamePaused;
            s_ubFireDelay = 10;
        }
    }

    if (s_ubGamePaused == TRUE) {
        if (s_ubFireDelay > 0) { s_ubFireDelay--; }
        systemIdleBegin();
        vPortWaitForEnd(s_pGameViewport);
        systemIdleEnd();
        return;
    }

    // Fade out.
    if (s_ubFadeOut == TRUE && s_ubDimLevel != 0) {
        s_ubDimLevel--;
        if (s_ubDimLevel == 0) { s_ubFadeOut = FALSE; }

        for (UBYTE i=0; i<32; i++) {
            s_pGameViewport->pPalette[i] = s_uwFadePalette[s_ubDimLevel][i];
        }

        viewUpdateGlobalPalette(s_pView);
        viewProcessManagers(s_pView);
        copProcessBlocks();
        systemIdleBegin();
        vPortWaitForEnd(s_pGameViewport);
        systemIdleEnd();
        return;
    }

    // Game Over
    if (s_ubShowTextGameOver == TRUE && s_ubShowTextGameOverTimer == 0 && s_ubDimLevel == 15) {
        s_ubFadeOut = TRUE;
    }

    if (s_ubShowTextGameOver == TRUE && s_ubShowTextGameOverTimer == 0 && s_ubDimLevel == 0) {
        g_ulPlayerScore = s_ulPlayerScore;
        g_ubPlayerLives = 0;
        g_ubPlayerSpecial = 0;

        resetEverything();
        ptplayerSetMasterVolume(0);
        ptplayerEnableMusic(0);
        stateChange(g_pGameStateManager, &g_pGameStates[STATE_SCORE]);
        return;
    }

    // Level End
    if (s_ubLevelEnd == TRUE && s_ubLevelEndTimer == 0 && s_ubDimLevel == 15) {
        s_ubFadeOut = TRUE;
    }

    if (s_ubLevelEnd == TRUE && s_ubLevelEndTimer == 0 && s_ubDimLevel == 0) {
        g_ulPlayerScore = s_ulPlayerScore;
        g_ubPlayerLives = s_ubPlayerLives;
        g_ubPlayerSpecial = s_ubPlayerSpecial;
        g_ubEquippedProjectileType = s_ubEquippedProjectileType;
        g_ubCurrentStage++;
        //if (g_ubCurrentStage >= GAME_STAGES) { g_ubCurrentStage = 0; }

        resetEverything();
        ptplayerSetMasterVolume(0);
        ptplayerEnableMusic(0);
        stateChange(g_pGameStateManager, &g_pGameStates[STATE_INTERMISSION]);
        return;
    }

    // Level Start
    if (s_ubLevelStart == TRUE) {
        processStageStart();
    } else {
        processInput();
    }

    processCamera();
    processWaves();
    processPlayer();
    processPlayerProjectiles();
    processEnemies();
    if (g_ubCurrentStage == BOSS_STAGE) {
        processBoss();
    }
    processSimpleEnemyProjectiles();
    processComplexEnemyProjectiles();
    processPowerups();
    processHud();
    processBobs();
    processTimers();

    tileBufferQueueProcess(s_pTileBuffer);
    viewProcessManagers(s_pView);
    copProcessBlocks();
    systemIdleBegin();
    vPortWaitForEnd(s_pGameViewport);
    systemIdleEnd();
}

void gameGsDestroy(void) {
    systemUse();

    // Destroy audio
    ptplayerStop();
    audioMixerDestroy();
    if (s_pSamplePack != 0) {
        ptplayerSamplePackDestroy(s_pSamplePack);
    }
    ptplayerModDestroy(s_pGameMusic);
    for (UBYTE i=0; i<PLAYER_PROJECTILE_TYPES; i++) {
        ptplayerSfxDestroy(s_pSfxPlayerShot[i]);
    }
    ptplayerSfxDestroy(s_pSfxExplosion);
    ptplayerSfxDestroy(s_pSfxCollectPowerup);
    ptplayerDestroy();

    // Destroy font and text
    fontDestroyTextBitMap(s_pHudScoreText);
    fontDestroyTextBitMap(s_pHudLivesText);
    fontDestroyTextBitMap(s_pHudSpecialText);
    fontDestroyTextBitMap(s_pHudPowerText);
    fontDestroyTextBitMap(s_pStageCompleteText);
    fontDestroy(s_pFont);

    // Destroy sprites
    spriteManagerDestroy();

    for (UBYTE i=1; i<PLAYER_PROJECTILE_TYPES; i++) {
        copBlockDestroy(s_pView->pCopList, s_tPlayerProjectiles[i].pCopBlock);
        memFree(s_pPlayerProjectileSprites[i], sizeof(s_pPlayerProjectileSprites[i]));
    }

    // Destroy bobs
    bobManagerDestroy();

    // Destroy bitmaps
    for (UBYTE i=0; i<PLAYER_PROJECTILE_TYPES; i++) {
        bitmapDestroy(s_pPlayerProjectileImages[i]);
    }

    for (UBYTE i=0; i<ENEMY_PROJECTILE_TYPES; i++) {
        bitmapDestroy(s_pEnemyProjectileSpriteImage[i]);
    }

    bitmapDestroy(s_pHudIconsImage);
    bitmapDestroy(s_pHudIconsMask);
    bitmapDestroy(s_pPlayerImage);
    bitmapDestroy(s_pPlayerMask);
    bitmapDestroy(s_pEngineImage);
    bitmapDestroy(s_pEngineMask);
    bitmapDestroy(s_pEnemyImage);
    bitmapDestroy(s_pEnemyMask);
    bitmapDestroy(s_pBigEnemyImage);
    bitmapDestroy(s_pBigEnemyMask);
    bitmapDestroy(s_pSmallExplosionImage);
    bitmapDestroy(s_pSmallExplosionMask);
    bitmapDestroy(s_pBigExplosionImage);
    bitmapDestroy(s_pBigExplosionMask);
    bitmapDestroy(s_pPowerupsImage);
    bitmapDestroy(s_pPowerupsMask);
    bitmapDestroy(s_pEnemyProjectileBobsImage);
    bitmapDestroy(s_pEnemyProjectileBobsMask);
    bitmapDestroy(s_pTextGameOverImage);
    bitmapDestroy(s_pTextGameOverMask);
    bitmapDestroy(s_pTextReadyImage);
    bitmapDestroy(s_pTextReadyMask);
    bitmapDestroy(s_pTextGoImage);
    bitmapDestroy(s_pTextGoMask);
    bitmapDestroy(s_pStageCompleteBgImage);
    bitmapDestroy(s_pStageCompleteBgMask);
    bitmapDestroy(s_pTiles);

    if (g_ubCurrentStage == BOSS_STAGE) {
        bitmapDestroy(s_pBossDamageImage);
        bitmapDestroy(s_pBossDamageMask);
        bitmapDestroy(s_pBossShotImage);
        bitmapDestroy(s_pBossShotMask);
        bitmapDestroy(s_pBossHitFlashImage);
        bitmapDestroy(s_pBossHitFlashMask);
    }

    bitmapDestroy(s_pPristineBuffer);
    viewDestroy(s_pView);
}

// Initialize game.

static void initGame() {
    // Load enemy path data.
	tFile *pPathData = pakFileGetFile(g_pPakFile, "paths.dat");
	fileRead(pPathData, g_ubPathData, sizeof(g_ubPathData));
    fileClose(pPathData);

    s_fViewportXMin = fix16_from_int(TILE_VIEWPORT_XMIN);
    s_fViewportXMax = fix16_from_int(TILE_VIEWPORT_XMAX);
    s_fBoundsMax = fix16_from_int(BOUNDS_MAX);
    s_fBoundsMin = fix16_from_int(BOUNDS_MIN);

    s_ulPlayerScore = g_ulPlayerScore;
    s_ubPlayerLives = g_ubPlayerLives;
    s_ubPlayerSpecial = g_ubPlayerSpecial;
    s_ubEquippedProjectileType = g_ubEquippedProjectileType;

    s_uwTilesInLevel = MAP_TILES_COUNT;
    s_uwCameraStartYPos = CAMERA_START_YPOS;
    s_uwMapHeightInTiles = MAP_HEIGHT_IN_TILES;

    tFile *pLevelData;

    // Setup variables depending on stage.
    switch (g_ubCurrentStage) {
        case (FIRST_STAGE):
            {
                pLevelData = pakFileGetFile(g_pPakFile, "stage1.dat");
                fileRead(pLevelData, s_uwLevelData, sizeof(s_uwLevelData));
                fileClose(pLevelData);
                s_tNextWave = g_tEnemyWavesForStage1[s_uwWaveIndex];
                s_ubEnemyProjectileRange = 64;
                s_ubEnemyProjectileSpeed = 0;
                s_ubEnemyProjectileAccuracy = 16;
                s_ubEnemyProjectileSafetyMargin = 64;
                g_tEnemyTypes[0].ubMoveSpeed = 4;
                g_tEnemyTypes[1].ubMoveSpeed = 4;
                g_tEnemyTypes[2].ubMoveSpeed = 4;
                g_tEnemyTypes[3].ubMoveSpeed = 2;
                g_tEnemyTypes[7].ubMoveSpeed = 2;
                g_tEnemyTypes[11].ubMoveSpeed = 2;
                g_tEnemyTypes[ENEMY_BIG_TYPE].ubMoveSpeed = 2;
                break;
            }

        case (SECOND_STAGE):
            {
                pLevelData = pakFileGetFile(g_pPakFile, "stage2.dat");
                fileRead(pLevelData, s_uwLevelData, sizeof(s_uwLevelData));
                fileClose(pLevelData);
                s_tNextWave = g_tEnemyWavesForStage2[s_uwWaveIndex];
                s_ubEnemyProjectileRange = 32;
                s_ubEnemyProjectileSpeed = 0;
                s_ubEnemyProjectileAccuracy = 8;
                s_ubEnemyProjectileSafetyMargin = 48;
                g_tEnemyTypes[0].ubMoveSpeed = 4;
                g_tEnemyTypes[1].ubMoveSpeed = 4;
                g_tEnemyTypes[2].ubMoveSpeed = 4;
                g_tEnemyTypes[3].ubMoveSpeed = 2;
                g_tEnemyTypes[7].ubMoveSpeed = 4;
                g_tEnemyTypes[11].ubMoveSpeed = 2;
                g_tEnemyTypes[ENEMY_BIG_TYPE].ubMoveSpeed = 2;
                break;
            }

        case (THIRD_STAGE):
            {
                pLevelData = pakFileGetFile(g_pPakFile, "stage3.dat");
                fileRead(pLevelData, s_uwLevelData, sizeof(s_uwLevelData));
                fileClose(pLevelData);
                s_tNextWave = g_tEnemyWavesForStage3[s_uwWaveIndex];
                s_ubEnemyProjectileRange = 16;
                s_ubEnemyProjectileSpeed = 2;
                s_ubEnemyProjectileAccuracy = 0;
                s_ubEnemyProjectileSafetyMargin = 32;
                g_tEnemyTypes[0].ubMoveSpeed = 6;
                g_tEnemyTypes[1].ubMoveSpeed = 6;
                g_tEnemyTypes[2].ubMoveSpeed = 6;
                g_tEnemyTypes[3].ubMoveSpeed = 4;
                g_tEnemyTypes[7].ubMoveSpeed = 4;
                g_tEnemyTypes[ENEMY_BIG_TYPE].ubMoveSpeed = 4;
                break;
            }

        case (BOSS_STAGE):
            {
                pLevelData = pakFileGetFile(g_pPakFile, "stage4.dat");
                fileRead(pLevelData, s_uwLevelData, (sizeof(UWORD) * BOSS_TILES_COUNT));
                fileClose(pLevelData);

                s_tNextWave = g_tEnemyWavesForStage4[s_uwWaveIndex];
                s_uwCameraStartYPos = BOSS_START_YPOS;
                s_uwMapHeightInTiles = BOSS_HEIGHT_IN_TILES;
                s_uwTilesInLevel = BOSS_TILES_COUNT;

                // Setup BossTurret1
                s_tBossTurrets[0].uwBitmapOffset = 0;
                s_tBossTurrets[0].ubHeight = 30;
                s_tBossTurrets[0].ubFlashTimer = 0;
                s_tBossTurrets[0].wHealth = BOSS_TURRET_HEALTH;
                s_tBossTurrets[0].ubAlive = TRUE;
                s_tBossTurrets[0].tBitmapPos.uwX = 16;
                s_tBossTurrets[0].tBitmapPos.uwY = 102;
                s_tBossTurrets[0].tFlashPos.uwX = 27;
                s_tBossTurrets[0].tFlashPos.uwY = 120;
                s_tBossTurrets[0].tHitboxPos.uwX = 26;
                s_tBossTurrets[0].tHitboxPos.uwY = 117;
                s_tBossTurrets[0].tExplosionPosition.uwX = 23;
                s_tBossTurrets[0].tExplosionPosition.uwY = 114;
                s_tBossTurrets[0].ubCooldownTimer = BOSS_COOLDOWN_TIME + g_bCyclicRng[s_ubCyclicRngIdx];
                s_ubCyclicRngIdx++;

                // Setup BossTurret2
                s_tBossTurrets[1].uwBitmapOffset = 30;
                s_tBossTurrets[1].ubHeight = 24;
                s_tBossTurrets[1].ubFlashTimer = 0;
                s_tBossTurrets[1].wHealth = BOSS_TURRET_HEALTH;
                s_tBossTurrets[1].ubAlive = TRUE;
                s_tBossTurrets[1].tBitmapPos.uwX = 48;
                s_tBossTurrets[1].tBitmapPos.uwY = 97;
                s_tBossTurrets[1].tFlashPos.uwX = 59;
                s_tBossTurrets[1].tFlashPos.uwY = 109;
                s_tBossTurrets[1].tHitboxPos.uwX = 58;
                s_tBossTurrets[1].tHitboxPos.uwY = 106;
                s_tBossTurrets[1].tExplosionPosition.uwX = 56;
                s_tBossTurrets[1].tExplosionPosition.uwY = 104;
                s_tBossTurrets[1].ubCooldownTimer = BOSS_COOLDOWN_TIME + g_bCyclicRng[s_ubCyclicRngIdx];
                s_ubCyclicRngIdx++;

                // Setup BossTurret3
                s_tBossTurrets[2].uwBitmapOffset = 54;
                s_tBossTurrets[2].ubHeight = 24;
                s_tBossTurrets[2].ubFlashTimer = 0;
                s_tBossTurrets[2].wHealth = BOSS_TURRET_HEALTH;
                s_tBossTurrets[2].ubAlive = TRUE;
                s_tBossTurrets[2].tBitmapPos.uwX = 112;
                s_tBossTurrets[2].tBitmapPos.uwY = 97;
                s_tBossTurrets[2].tFlashPos.uwX = 123;
                s_tBossTurrets[2].tFlashPos.uwY = 109;
                s_tBossTurrets[2].tHitboxPos.uwX = 122;
                s_tBossTurrets[2].tHitboxPos.uwY = 106;
                s_tBossTurrets[2].tExplosionPosition.uwX = 120;
                s_tBossTurrets[2].tExplosionPosition.uwY = 104;
                s_tBossTurrets[2].ubCooldownTimer = BOSS_COOLDOWN_TIME + g_bCyclicRng[s_ubCyclicRngIdx];
                s_ubCyclicRngIdx++;

                // Setup BossTurret4
                s_tBossTurrets[3].uwBitmapOffset = 78;
                s_tBossTurrets[3].ubHeight = 29;
                s_tBossTurrets[3].ubFlashTimer = 0;
                s_tBossTurrets[3].wHealth = BOSS_TURRET_HEALTH;
                s_tBossTurrets[3].ubAlive = TRUE;
                s_tBossTurrets[3].tBitmapPos.uwX = 144;
                s_tBossTurrets[3].tBitmapPos.uwY = 103;
                s_tBossTurrets[3].tFlashPos.uwX = 155;
                s_tBossTurrets[3].tFlashPos.uwY = 120;
                s_tBossTurrets[3].tHitboxPos.uwX = 154;
                s_tBossTurrets[3].tHitboxPos.uwY = 117;
                s_tBossTurrets[3].tExplosionPosition.uwX = 153;
                s_tBossTurrets[3].tExplosionPosition.uwY = 114;
                s_tBossTurrets[3].ubCooldownTimer = BOSS_COOLDOWN_TIME + g_bCyclicRng[s_ubCyclicRngIdx];
                s_ubCyclicRngIdx++;

                break;
            }

        default:
            {
                logWrite("Invalid stage: %d", g_ubCurrentStage);
                s_tNextWave = g_tEnemyWavesForStage1[0];
                s_ubEnemyProjectileRange = 160;
                s_ubEnemyProjectileSpeed = 5;
                s_ubEnemyProjectileAccuracy = 0;
                s_ubEnemyProjectileSafetyMargin = 0;
                break;
            }
    }

    if (g_ubLoopIteration == 1) {
        s_ubEnemyProjectileRange = 16;
        s_ubEnemyProjectileSpeed = 2;
        s_ubEnemyProjectileAccuracy = 0;
        s_ubEnemyProjectileSafetyMargin = 32;
    }

    if (g_ubLoopIteration >= 2) {
        s_ubEnemyProjectileRange = 16;
        s_ubEnemyProjectileSpeed = 3;
        s_ubEnemyProjectileAccuracy = 0;
        s_ubEnemyProjectileSafetyMargin = 16;
    }
}

static void initViews() {
    // Setup screen and viewports.
    s_pView = viewCreate(0,
        TAG_VIEW_GLOBAL_PALETTE, 1,
        TAG_VIEW_WINDOW_WIDTH, 160,
        TAG_VIEW_WINDOW_START_X, SCREEN_XOFFSET + 80,
    TAG_DONE);

    s_pGameViewport = vPortCreate(0,
        TAG_VPORT_VIEW, s_pView,
        TAG_VPORT_BPP, GAME_BPP,
        TAG_VPORT_HEIGHT, TILE_VIEWPORT_HEIGHT,
    TAG_DONE);

    s_pHudViewport = vPortCreate(0,
        TAG_VPORT_VIEW, s_pView,
        TAG_VPORT_BPP, GAME_BPP,
        TAG_VPORT_HEIGHT, HUD_VIEWPORT_HEIGHT,
    TAG_DONE);

    // Load palette

    paletteLoadFromFd(pakFileGetFile(g_pPakFile, "game.plt"), s_uwFadePalette[15], 1 << GAME_BPP);
    for (UBYTE i=0; i<16; i++) {
        paletteDim(s_uwFadePalette[15], s_uwFadePalette[i], 32, i);
    }

    // Load tiles bitmap.
    switch(g_ubCurrentStage) {
        case 0:
            s_pTiles = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "tiles_stage1.bm"), 0);
            break;
        case 1:
            s_pTiles = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "tiles_stage2.bm"), 0);
            break;
        case 2:
            s_pTiles = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "tiles_stage3.bm"), 0);
            break;
        case 3:
            s_pTiles = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "tiles_boss.bm"), 0);
            break;
    }

    // Init tilemap buffer.
    s_pTileBuffer = tileBufferCreate(0,
        TAG_TILEBUFFER_VPORT, s_pGameViewport,
        TAG_TILEBUFFER_BITMAP_FLAGS, BMF_CLEAR | BMF_INTERLEAVED,
        TAG_TILEBUFFER_BOUND_TILE_X, MAP_WIDTH_IN_TILES,
        TAG_TILEBUFFER_BOUND_TILE_Y, s_uwMapHeightInTiles,
        TAG_TILEBUFFER_IS_DBLBUF, 1,
        TAG_TILEBUFFER_TILE_SHIFT, 4,
        TAG_TILEBUFFER_REDRAW_QUEUE_LENGTH, 100,
        TAG_TILEBUFFER_TILESET, s_pTiles,
        TAG_TILEBUFFER_MAX_TILESET_SIZE, uwTilesInStage[g_ubCurrentStage],
        TAG_TILEBUFFER_CALLBACK_TILE_DRAW, onTileDraw,
    TAG_DONE);

    s_pPristineBuffer = bitmapCreate(
        bitmapGetByteWidth(s_pTileBuffer->pScroll->pBack) * 8,
        s_pTileBuffer->pScroll->pBack->Rows,
        s_pTileBuffer->pScroll->pBack->Depth, BMF_INTERLEAVED
    );

    // Init simple buffer.
    s_pHudBuffer = simpleBufferCreate(0,
        TAG_SIMPLEBUFFER_VPORT, s_pHudViewport,
        TAG_SIMPLEBUFFER_USE_X_SCROLLING, 0,
        TAG_SIMPLEBUFFER_IS_DBLBUF, 0,
        TAG_SIMPLEBUFFER_BITMAP_FLAGS, BMF_CLEAR,
    TAG_DONE);

    // Populate tilemap.
    UWORD idx = 0;

    for (UWORD y=0; y<s_uwMapHeightInTiles; y++) {
        for (UWORD x=0; x<MAP_WIDTH_IN_TILES; x++) {
            s_pTileBuffer->pTileData[x][y] = s_uwLevelData[idx];
            idx++;
            if (idx == MAP_TILES_COUNT) { idx = 0; }
        }
    }

    // Setup camera.
    s_pCamera = s_pTileBuffer->pCamera;
    cameraMoveBy(s_pCamera, TILE_VIEWPORT_XMIN, s_uwCameraStartYPos);
}

static void initHud() {
    // Load font
    s_pFont = fontCreateFromFd(pakFileGetFile(g_pPakFile, "hudfont.fnt"));
    s_pHudScoreText = fontCreateTextBitMap(HUD_SCORE_WIDTH, HUD_TEXT_HEIGHT);
    s_pHudLivesText = fontCreateTextBitMap(HUD_TEXT_WIDTH, HUD_TEXT_HEIGHT);
    s_pHudSpecialText = fontCreateTextBitMap(HUD_TEXT_WIDTH, HUD_TEXT_HEIGHT);
    s_pHudPowerText = fontCreateTextBitMap(HUD_TEXT_WIDTH, HUD_TEXT_HEIGHT);

    // Load HUD lives icon
    s_pHudIconsImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "hud_icons.bm"), 0);
    s_pHudIconsMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "hud_icons_mask.bm"), 0);

    s_pStageCompleteText = fontCreateTextBitMap(32, 8);
}

static void initAudio() {
    s_pSfxPlayerShot[0] = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "shot0.sfx"), 1);
    s_pSfxPlayerShot[1] = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "shot1.sfx"), 1);
    s_pSfxPlayerShot[2] = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "shot2.sfx"), 1);
    s_pSfxPlayerShot[3] = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "shot3.sfx"), 1);

    s_pSfxExplosion = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "explosion.sfx"), 1);
    s_pSfxCollectPowerup = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "collect.sfx"), 1);

    if (g_ubCurrentStage == BOSS_STAGE) {
        s_pSfxBossShot = ptplayerSfxCreateFromFd(pakFileGetFile(g_pPakFile, "boss_shot.sfx"), 1);
    }

    ptplayerCreate(1);
    ptplayerSetChannelsForPlayer(0b0111);
    ptplayerSetMasterVolume(28);
    audioMixerCreate();

    s_pGameMusic = ptplayerModCreateFromFd(pakFileGetFile(g_pPakFile, "ingame.patterns"));
    s_pSamplePack = ptplayerSampleDataCreateFromFd(pakFileGetFile(g_pPakFile, "ingame.samplepack"));
    if (s_pSamplePack == 0) {
        return;
    }
    ptplayerLoadMod(s_pGameMusic, s_pSamplePack, 0);
    ptplayerEnableMusic(1);
}

static void initBobs() {
    // Init tilemap bob manager.
    bobManagerCreate(s_pTileBuffer->pScroll->pFront, s_pTileBuffer->pScroll->pBack, s_pPristineBuffer ,s_pTileBuffer->pScroll->uwBmAvailHeight);

    // Player ship bob.
    s_pPlayerImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player.bm"), 0);
    s_pPlayerMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_mask.bm"), 0);
    bobInit(&s_tPlayerBob, PLAYER_SHIP_WIDTH, PLAYER_SHIP_HEIGHT, 1, s_pPlayerImage->Planes[0], s_pPlayerMask->Planes[0], 0, 0);

    // Engine bob.
    s_pEngineImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_engine.bm"), 0);
    s_pEngineMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_engine_mask.bm"), 0);
    bobInit(&s_tEngineBob, ENGINE_WIDTH, ENGINE_HEIGHT, 1, s_pEngineImage->Planes[0], s_pEngineMask->Planes[0], 0, 0);

    // Enemy bobs
    s_pEnemyImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_small.bm"), 0);
    s_pEnemyMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_small_mask.bm"), 0);

    // Init enemy structs.
    for (UBYTE i=0; i<ENEMY_MAX; i++) {
        bobInit( &s_tEnemy[i].sBob, 16, 16, 1, s_pEnemyImage->Planes[0], s_pEnemyMask->Planes[0], 0, 0 );
        s_tEnemy[i].wHealth = 0;
    }

    // Big enemy bob
    s_pBigEnemyImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_big.bm"), 0);
    s_pBigEnemyMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_big_mask.bm"), 0);
    bobInit(&s_tBigEnemyBob, 32, 32, 1, s_pBigEnemyImage->Planes[0], s_pBigEnemyMask->Planes[0], 0, 0);

    // Small explosion bobs
    s_pSmallExplosionImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "explosion_small.bm"), 0);
    s_pSmallExplosionMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "explosion_small_mask.bm"), 0);

    for (UBYTE i=0; i<EXPLOSIONS_MAX; i++) {
        bobInit(&s_tExplosions[i].sBob, 16, 16, 1, s_pSmallExplosionImage->Planes[0], s_pSmallExplosionMask->Planes[0], 0, 0);
    }

    // Large explosion bob
    s_pBigExplosionImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "explosion_big.bm"), 0);
    s_pBigExplosionMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "explosion_big_mask.bm"), 0);

    bobInit(&s_tBigExplosionBob, 32, 32, 1, s_pBigExplosionImage->Planes[0], s_pBigExplosionMask->Planes[0], 0, 0);
    bobInit(&s_tPlayerExplosionBob, 32, 32, 1, s_pBigExplosionImage->Planes[0], s_pBigExplosionMask->Planes[0], 0, 0);

    // Enemy projectiles.
    s_pEnemyProjectileBobsImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_bullet_bobs.bm"), 0);
    s_pEnemyProjectileBobsMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_bullet_bobs_mask.bm"), 0);

    for (UBYTE i=0; i<ENEMY_BOB_CHANNELS; i++) {
        bobInit(&s_tEnemyProjectileBob[i], 16, 14, 1, s_pEnemyProjectileBobsImage->Planes[0], s_pEnemyProjectileBobsMask->Planes[0], 0, 0);
    }

    s_pPowerupsImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "powerups_square.bm"), 0);
    s_pPowerupsMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "powerups_square_mask.bm"), 0);
    bobInit(&s_tLifePowBob, 16, 16, 1, s_pPowerupsImage->Planes[0], s_pPowerupsMask->Planes[0], 0, 0); // Extra Life Powerup
    bobInit(&s_tSpecialPowBob, 16, 16, 1, s_pPowerupsImage->Planes[0], s_pPowerupsMask->Planes[0], 0, 0); // Special Powerup
    bobInit(&s_tWeaponPowBob, 16, 16, 1, s_pPowerupsImage->Planes[0], s_pPowerupsMask->Planes[0], 0, 0); // Weapon Powerup

    bobSetFrame(&s_tLifePowBob, &s_pPowerupsImage->Planes[0][0], &s_pPowerupsMask->Planes[0][0]);
    bobSetFrame(&s_tSpecialPowBob, &s_pPowerupsImage->Planes[0][160], &s_pPowerupsMask->Planes[0][160]);
    bobSetFrame(&s_tWeaponPowBob, &s_pPowerupsImage->Planes[0][320], &s_pPowerupsMask->Planes[0][320]);

    // Game Over text
    s_pTextGameOverImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_gameover.bm"), 0);
    s_pTextGameOverMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_gameover_mask.bm"), 0);
    bobInit(&s_tTextGameOverBob, TEXT_GAMEOVER_WIDTH, TEXT_GAMEOVER_HEIGHT, 0, s_pTextGameOverImage->Planes[0], s_pTextGameOverMask->Planes[0], 0, 0);

    // Ready text
    s_pTextReadyImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_ready.bm"), 0);
    s_pTextReadyMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_ready_mask.bm"), 0);
    bobInit(&s_tTextReadyBob, TEXT_READY_WIDTH, TEXT_READY_HEIGHT, 1, s_pTextReadyImage->Planes[0], s_pTextReadyMask->Planes[0], 0, 0);

    // Go text
    s_pTextGoImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_go.bm"), 0);
    s_pTextGoMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "text_go_mask.bm"), 0);
    bobInit(&s_tTextGoBob, TEXT_GO_WIDTH, TEXT_GO_HEIGHT, 1, s_pTextGoImage->Planes[0], s_pTextGoMask->Planes[0], 0, 0);

    s_pStageCompleteBgImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "stage_complete_bg.bm"), 0);
    s_pStageCompleteBgMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "stage_complete_bg_mask.bm"), 0);
    bobInit(&s_tStageCompleteBgBob, TEXT_STAGECOMPLETE_WIDTH, TEXT_STAGECOMPLETE_HEIGHT, 0, s_pStageCompleteBgImage->Planes[0], s_pStageCompleteBgMask->Planes[0], 0, 0);

    if (g_ubCurrentStage == BOSS_STAGE) {
        s_pBossDamageImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "boss_damage.bm"), 0);
        s_pBossDamageMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "boss_damage_mask.bm"), 0);
        s_pBossShotImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "boss_shot.bm"), 0);
        s_pBossShotMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "boss_shot_mask.bm"), 0);
        s_pBossHitFlashImage = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "boss_hitflash.bm"), 0);
        s_pBossHitFlashMask = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "boss_hitflash_mask.bm"), 0);

        bobInit(&s_tBossShotBob, 16, 32, 1, s_pBossShotImage->Planes[0], s_pBossShotMask->Planes[0], 0, 0);
        for (UBYTE i=0; i<4; i++) {
            bobInit(&s_tBossTurrets[i].sFlashBob, 16, 9, 1, s_pBossHitFlashImage->Planes[0], s_pBossHitFlashMask->Planes[0], s_tBossTurrets[i].tFlashPos.uwX, s_tBossTurrets[i].tFlashPos.uwY);
        }
    }

    // Finish bob init.
    bobReallocateBuffers();
}

static void initSprites() {
    // Init sprites.
    spriteManagerCreate(s_pView, 0);
    systemSetDmaBit(DMAB_SPRITE, 1);

    // Enemy projectile sprites.
    s_pEnemyProjectileSpriteImage[0] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_bullet_sprite_1.bm"), 0);
    s_pEnemyProjectileSpriteImage[1] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_bullet_sprite_2.bm"), 0);
    s_pEnemyProjectileSpriteImage[2] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_bullet_sprite_3.bm"), 0);
    s_pEnemyProjectileSpriteImage[3] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "enemy_bullet_sprite_4.bm"), 0);

    s_pEnemyProjectileSprite[0] = spriteAdd(0, s_pEnemyProjectileSpriteImage[0]);
    s_pEnemyProjectileSprite[1] = spriteAdd(1, s_pEnemyProjectileSpriteImage[1]);
    s_pEnemyProjectileSprite[2] = spriteAdd(2, s_pEnemyProjectileSpriteImage[2]);
    s_pEnemyProjectileSprite[3] = spriteAdd(3, s_pEnemyProjectileSpriteImage[3]);

    s_tSimpleChannelBounds[0] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};
    s_tSimpleChannelBounds[1] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};
    s_tSimpleChannelBounds[2] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};
    s_tSimpleChannelBounds[3] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};

    for (UBYTE i=0; i<ENEMY_PROJECTILE_MAX; i++) {
        s_tComplexEnemyProjectiles[i].pCopBlock = copBlockCreate(s_pView->pCopList, 4, 0, 0);
        s_tSimpleEnemyProjectiles[i].pCopBlock = copBlockCreate(s_pView->pCopList, 4, 0, 0);
        s_tComplexEnemyProjectiles[i].ubChannel = 255;
        s_tSimpleEnemyProjectiles[i].ubChannel = 255;
    }

    // Player projectile sprite.
    s_pPlayerProjectileImages[0] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_bullet_sprite_1.bm"), 0);
    s_pPlayerProjectileImages[1] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_bullet_sprite_2.bm"), 0);
    s_pPlayerProjectileImages[2] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_bullet_sprite_3.bm"), 0);
    s_pPlayerProjectileImages[3] = bitmapCreateFromFd(pakFileGetFile(g_pPakFile, "player_bullet_sprite_4.bm"), 0);

    s_pPlayerProjectileSprites[0] = spriteAdd(4, s_pPlayerProjectileImages[0]);
    s_pPlayerProjectileSprites[1] = spriteAdd(4, s_pPlayerProjectileImages[1]);
    s_pPlayerProjectileSprites[2] = spriteAdd(4, s_pPlayerProjectileImages[2]);
    s_pPlayerProjectileSprites[3] = spriteAdd(4, s_pPlayerProjectileImages[3]);

    // s_pPlayerSecondaryProjectileImages[0] = bitmapCreateFromFile("data/bullet6b_sprite_player.bm", 0); // Wide shot
    // s_pPlayerSecondaryProjectileImages[1] = bitmapCreateFromFile("data/bullet7r_sprite_player.bm", 0); // Spread shot

    // s_pPlayerSecondaryProjectileSprites[0] = spriteAdd(5, s_pPlayerSecondaryProjectileImages[0]);
    // s_pPlayerSecondaryProjectileSprites[1] = spriteAdd(5, s_pPlayerSecondaryProjectileImages[1]);

    for (UBYTE i=0; i<PLAYER_PROJECTILE_MAX; i++) {
        s_tPlayerProjectiles[i].pCopBlock = copBlockCreate(s_pView->pCopList, 4, 0, 0);
        //s_tPlayerSecondaryProjectiles[i].pCopBlock = copBlockCreate(s_pView->pCopList, 4, 0, 0);
    }
}

// Process game logic.

static void processStageStart() {
    s_ubLevelStartTimer--;

    if (s_ubDimLevel < 15) {
        for (UBYTE i=0; i<32; i++) {
            s_pGameViewport->pPalette[i] = s_uwFadePalette[s_ubDimLevel][i];
        }

        viewUpdateGlobalPalette(s_pView);
        s_ubDimLevel++;
    }

    if (s_ubLevelStartTimer > 64) {
        s_ubShowTextReady = TRUE;
    }

    if (s_ubLevelStartTimer > 0 && s_ubLevelStartTimer <= 64) {
        s_ubShowTextReady = FALSE;
        s_ubShowTextGo = TRUE;
        s_ubCameraCanMove = TRUE;
    }

    if (s_ubLevelStartTimer == 0) {
        s_ubShowTextReady = FALSE;
        s_ubShowTextGo = FALSE;
        s_ubLevelStart = FALSE;
        s_ubCameraCanMove = TRUE;
    }
}

static void processCamera() {
    if (s_ubCameraCanMove == TRUE) {
        s_ubMoveCameraCounter++;

        if (s_ubMoveCameraCounter >= CAMERA_MOVE_RATE) {
            if (s_pCamera->uPos.uwY > CAMERA_Y_MIN) {
                cameraMoveBy(s_pCamera, 0, CAMERA_MOVE_AMOUNT);

                if (s_ubPlayerMovedOnY == FALSE) {
                    s_tPlayerPosition.uwY += CAMERA_MOVE_AMOUNT;
                }
            }
            s_ubMoveCameraCounter = 0;
        }

        // Keep player inside camera area.
        UWORD uwCameraYMax = s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT;
        if (s_tPlayerPosition.uwY+PLAYER_SHIP_HEIGHT > uwCameraYMax) {
            s_tPlayerPosition.uwY = uwCameraYMax - PLAYER_SHIP_HEIGHT;
        }

        if (s_pCamera->uPos.uwY == CAMERA_Y_MIN && g_ubCurrentStage != BOSS_STAGE) {
            s_ubLevelEndReached = TRUE;
        }

        if (s_pCamera->uPos.uwY == CAMERA_Y_MIN && g_ubCurrentStage == BOSS_STAGE) {
            s_ubBossReached = TRUE;
        }
    }
}

static void processInput() {
    // Move
    s_ubPlayerMovedOnY = FALSE;
    s_ubPlayerMovedLeft = FALSE;
    s_ubPlayerMovedRight = FALSE;
    s_ubDisplayEngine = TRUE;
    s_ubPlayerMoveSpeed = PLAYER_FAST_MOVE_SPEED;

    // Shoot
    if (s_ubLevelEndReached == FALSE) {
        if (keyCheck(KEY_SPACE) || joyCheck(JOY1_FIRE)) {
            s_ubPlayerMoveSpeed = PLAYER_SLOW_MOVE_SPEED;
            //s_ubPlayerFired = TRUE;
            processPlayerShoot();
        }

        // Special
        if (keyCheck(KEY_B) || joyCheck(JOY1_FIRE2)) {
            processPlayerSpecial();
        }
    }

    if (keyCheck(KEY_UP) || joyCheck(JOY1_UP)) {
        s_tPlayerPosition.uwY = s_tPlayerPosition.uwY - s_ubPlayerMoveSpeed;
        s_ubPlayerMovedOnY = TRUE;
        if (s_tPlayerPosition.uwY < s_pCamera->uPos.uwY + TILE_VIEWPORT_YMIN) { s_tPlayerPosition.uwY = s_pCamera->uPos.uwY + TILE_VIEWPORT_YMIN; }
    }
    if (keyCheck(KEY_DOWN) || joyCheck(JOY1_DOWN)) {
        s_tPlayerPosition.uwY = s_tPlayerPosition.uwY + (s_ubPlayerMoveSpeed-1);
        s_ubPlayerMovedOnY = TRUE;
        s_ubDisplayEngine = FALSE;
        if (s_tPlayerPosition.uwY > s_pCamera->uPos.uwY + (TILE_VIEWPORT_HEIGHT-PLAYER_SHIP_HEIGHT)) { s_tPlayerPosition.uwY = s_pCamera->uPos.uwY + (TILE_VIEWPORT_HEIGHT-PLAYER_SHIP_HEIGHT); }
    }
    if (keyCheck(KEY_LEFT) || joyCheck(JOY1_LEFT)) {
        s_tPlayerPosition.uwX = s_tPlayerPosition.uwX - s_ubPlayerMoveSpeed;
        s_ubPlayerMovedLeft = TRUE;
        if (s_tPlayerPosition.uwX < TILE_VIEWPORT_XMIN) { s_tPlayerPosition.uwX = TILE_VIEWPORT_XMIN; }
    }
    if (keyCheck(KEY_RIGHT) || joyCheck(JOY1_RIGHT)) {
        s_tPlayerPosition.uwX = s_tPlayerPosition.uwX + s_ubPlayerMoveSpeed;
        s_ubPlayerMovedLeft = FALSE;
        s_ubPlayerMovedRight = TRUE;
        if (s_tPlayerPosition.uwX > (TILE_VIEWPORT_XMAX-PLAYER_SHIP_WIDTH)) { s_tPlayerPosition.uwX = (TILE_VIEWPORT_XMAX-PLAYER_SHIP_WIDTH); }
    }
}

static void processHud() {
    // Lives
    if (s_ubUpdateLives == TRUE) {
        char cLives[4];
        sprintf(cLives, "%01d", s_ubPlayerLives);
        fontFillTextBitMap(s_pFont, s_pHudLivesText, cLives);
        fontDrawTextBitMap(s_pHudBuffer->pBack, s_pHudLivesText, 14, 3, HUD_TEXT_COLOR, 0);
        blitCopyMask(s_pHudIconsImage, 0, 0, s_pHudBuffer->pBack, 4, 3, 8, 7, s_pHudIconsMask->Planes[0]);
        s_ubUpdateLives = FALSE;
    }

    // Special
    if (s_ubUpdateSpecial == TRUE) {
        char cSpecial[4];
        sprintf(cSpecial, "%01d", s_ubPlayerSpecial);
        fontFillTextBitMap(s_pFont, s_pHudSpecialText, cSpecial);
        fontDrawTextBitMap(s_pHudBuffer->pBack, s_pHudSpecialText, 42, 3, HUD_TEXT_COLOR, 0);
        blitCopyMask(s_pHudIconsImage, 0, 7, s_pHudBuffer->pBack, 32, 3, 8, 7, s_pHudIconsMask->Planes[0]);
        s_ubUpdateSpecial = FALSE;
        s_ubUpdatePower = TRUE;
    }

    // Power
    if (s_ubUpdatePower == TRUE) {
        char cPlayerPower[4];
        sprintf(cPlayerPower, "%01d", s_ubEquippedProjectileType+1);
        fontFillTextBitMap(s_pFont, s_pHudPowerText, cPlayerPower);
        fontDrawTextBitMap(s_pHudBuffer->pBack, s_pHudPowerText, 69, 3, HUD_TEXT_COLOR, 0);
        blitCopyMask(s_pHudIconsImage, 0, 14, s_pHudBuffer->pBack, 58, 3, 8, 7, s_pHudIconsMask->Planes[0]);
        s_ubUpdatePower = FALSE;
    }

    // Score
    if (s_ubUpdateScore == TRUE) {
        char cPlayerScore[12];
        sprintf(cPlayerScore, "%07ld", s_ulPlayerScore);
        fontFillTextBitMap(s_pFont, s_pHudScoreText, cPlayerScore);
        fontDrawTextBitMap(s_pHudBuffer->pBack, s_pHudScoreText, 94, 3, HUD_TEXT_COLOR, 0);
        s_ubUpdateScore = FALSE;
    }
}

static void processWaves() {
    if (s_uwWaveIndex != UWORD_MAX) {
        if (s_pCamera->uPos.uwY == s_tNextWave.uwSpawnYPosition) {
            if (s_ubActiveEnemies + 1 <= ENEMY_MAX) {
                logWrite("Wave[%d] Spawn EnemyType: %d", s_uwWaveIndex, s_tNextWave.ubEnemyType);
                for (UBYTE enemyIdx=0; enemyIdx<ENEMY_MAX; enemyIdx++) {
                    if (s_tEnemy[enemyIdx].wHealth > 0) { continue; }
                    UBYTE ubEnemyTypeToSpawn = s_tNextWave.ubEnemyType;
                    UBYTE ubPathType = s_tNextWave.ubPathType;
                    s_tEnemy[enemyIdx].wHealth = g_tEnemyTypes[ubEnemyTypeToSpawn].wHealth;
                    s_tEnemy[enemyIdx].ubOnScreen = FALSE;
                    s_tEnemy[enemyIdx].ubInvincible = TRUE;
                    s_tEnemy[enemyIdx].ubFlashTimer = 0;
                    s_tEnemy[enemyIdx].ubCanShoot = g_tEnemyTypes[ubEnemyTypeToSpawn].ubCanShoot;
                    s_tEnemy[enemyIdx].ubCooldownTimer = (g_tEnemyTypes[ubEnemyTypeToSpawn].ubCooldownTime + g_bCyclicRng[s_ubCyclicRngIdx]);
                    s_tEnemy[enemyIdx].ubEnemyType = ubEnemyTypeToSpawn;
                    s_tEnemy[enemyIdx].ubPowerupType = g_tEnemyTypes[ubEnemyTypeToSpawn].ubPowerupType;
                    s_tEnemy[enemyIdx].uwScoreValue = g_tEnemyTypes[ubEnemyTypeToSpawn].uwScoreValue;
                    s_tEnemy[enemyIdx].ubMoveSpeed = g_tEnemyTypes[ubEnemyTypeToSpawn].ubMoveSpeed;
                    s_tEnemy[enemyIdx].uwPathArrayOffset = g_uwPathOffset[ubPathType];
                    s_tEnemy[enemyIdx].uwPathLength = g_uwPathLength[ubPathType];
                    s_tEnemy[enemyIdx].uwPathYOffset = s_tNextWave.uwSpawnYPosition + s_tNextWave.bSpawnOffset;
                    s_tEnemy[enemyIdx].uwPathIdx = 0;

                    s_ubCyclicRngIdx++;
                    if (s_ubCyclicRngIdx > RNG_IDX_MAX) {
                        s_ubCyclicRngIdx = 0;
                    }

                    if (ubEnemyTypeToSpawn != ENEMY_BIG_TYPE) {
                        UBYTE ubBitmapOffsetIdx = g_tEnemyTypes[ubEnemyTypeToSpawn].ubBitmapOffset;
                        UWORD uwOffset = s_uwEnemyBitmapOffset[ubBitmapOffsetIdx];
                        bobSetFrame(
                            &s_tEnemy[enemyIdx].sBob,
                            &s_pEnemyImage->Planes[0][uwOffset],
                            &s_pEnemyMask->Planes[0][uwOffset]
                        );

                        if (ubEnemyTypeToSpawn == ENEMY_TURRET_TYPE) {
                            s_tEnemy[enemyIdx].ubInvincible = FALSE;
                            s_tEnemy[enemyIdx].tPosition.uwX = s_tNextWave.ubPathType;
                            s_tEnemy[enemyIdx].tPosition.uwY = s_tNextWave.uwSpawnYPosition + s_tNextWave.bSpawnOffset;
                        }
                    } else {
                        bobSetFrame(
                            &s_tBigEnemyBob,
                            s_pBigEnemyImage->Planes[0],
                            s_pBigEnemyMask->Planes[0]
                        );
                    }

                    logWrite("Wave[%d] Spawned EnemyType:%d => EnemyIdx:%d", s_uwWaveIndex, ubEnemyTypeToSpawn, enemyIdx);
                    s_ubActiveEnemies++;
                    break;
                }
            } else {
                logWrite("Wave[%d] Too many enemies => Active:%d", s_uwWaveIndex, s_ubActiveEnemies);
            }

            s_uwWaveIndex++;
            if (s_uwWaveIndex >= g_uwWavesInLevel[g_ubCurrentStage]) {
                logWrite("No more waves left!");
                s_uwWaveIndex = UWORD_MAX;
            }

            if (s_uwWaveIndex != UWORD_MAX) {
                switch (g_ubCurrentStage) {
                    case (FIRST_STAGE):
                        s_tNextWave = g_tEnemyWavesForStage1[s_uwWaveIndex];
                        break;
                    case (SECOND_STAGE):
                        s_tNextWave = g_tEnemyWavesForStage2[s_uwWaveIndex];
                        break;
                    case (THIRD_STAGE):
                        s_tNextWave = g_tEnemyWavesForStage3[s_uwWaveIndex];
                        break;
                    case (BOSS_STAGE):
                        s_tNextWave = g_tEnemyWavesForStage4[s_uwWaveIndex];
                        break;
                    default:
                        logWrite("Invalid stage: %d", g_ubCurrentStage);
                        s_tNextWave = g_tEnemyWavesForStage1[0];
                        break;
                }
            }
        }
    }
}

static void processBobs() {
    systemSetDmaBit(DMAB_BLITHOG, 1);
    bobBegin(s_pTileBuffer->pScroll->pBack);

    // Boss turrets
    if (s_ubBossReached == TRUE) {
        for (UBYTE turretIdx=0; turretIdx<4; turretIdx++) {
            if (s_tBossTurrets[turretIdx].ubAlive == FALSE) {
                blitCopyMask(s_pBossDamageImage, 0, s_tBossTurrets[turretIdx].uwBitmapOffset, s_pTileBuffer->pScroll->pBack, s_tBossTurrets[turretIdx].tBitmapPos.uwX, s_tBossTurrets[turretIdx].tBitmapPos.uwY, 32, s_tBossTurrets[turretIdx].ubHeight, s_pBossDamageMask->Planes[0]);
            }
        }
    }

    // Player ship
    if (s_ubPlayerAlive == TRUE) {
        s_tPlayerBob.sPos = s_tPlayerPosition;

        if (s_ubPlayerMovedLeft == TRUE) {
            bobSetFrame(
                &s_tPlayerBob,
                &s_pPlayerImage->Planes[0][PLAYER_SHIP_LEFT_FRAME],
                &s_pPlayerMask->Planes[0][PLAYER_SHIP_LEFT_FRAME]
            );
        }

        if (s_ubPlayerMovedRight == TRUE) {
            bobSetFrame(
                &s_tPlayerBob,
                &s_pPlayerImage->Planes[0][PLAYER_SHIP_RIGHT_FRAME],
                &s_pPlayerMask->Planes[0][PLAYER_SHIP_RIGHT_FRAME]
            );
        }

        if (s_ubPlayerMovedLeft == FALSE && s_ubPlayerMovedRight == FALSE) {
            bobSetFrame(
                &s_tPlayerBob,
                &s_pPlayerImage->Planes[0][PLAYER_SHIP_CENTER_FRAME],
                &s_pPlayerMask->Planes[0][PLAYER_SHIP_CENTER_FRAME]
            );
        }

        if (s_ubDisplayPlayer == TRUE) {
            bobPush(&s_tPlayerBob);
        }

        // Engine
        if (s_ubDisplayPlayer == TRUE && s_ubDisplayEngine == TRUE) {
            s_tEngineBob.sPos = s_tPlayerPosition;
            s_tEngineBob.sPos.uwY += 16;
            UBYTE ubFrameOffset = s_uwEngineAnimOffset[s_ubEngineAnimFrame];
            bobSetFrame(
                &s_tEngineBob,
                &s_pEngineImage->Planes[0][ubFrameOffset],
                &s_pEngineMask->Planes[0][ubFrameOffset]
            );
            bobPush(&s_tEngineBob);
        }
    }

    // Turrets
    if (s_ubActiveEnemies > 0) {
        for (UBYTE enemyIdx=0; enemyIdx<ENEMY_MAX; enemyIdx++) {
            if (s_tEnemy[enemyIdx].wHealth <= 0 || s_tEnemy[enemyIdx].ubOnScreen == FALSE) { continue; }
            if (s_tEnemy[enemyIdx].ubEnemyType != ENEMY_TURRET_TYPE) { continue; }
            if (s_tEnemy[enemyIdx].ubFlashTimer == 5) {
                UBYTE ubEnemyType = s_tEnemy[enemyIdx].ubEnemyType;
                UBYTE ubBitmapOffsetIdx = g_tEnemyTypes[ubEnemyType].ubBitmapOffset;
                UWORD uwOffset = s_uwEnemyBitmapOffset[ubBitmapOffsetIdx];
                bobSetFrame(
                    &s_tEnemy[enemyIdx].sBob,
                    &s_pEnemyMask->Planes[0][uwOffset],
                    &s_pEnemyMask->Planes[0][uwOffset]
                );
            }

            if (s_tEnemy[enemyIdx].ubFlashTimer > 0) {
                s_tEnemy[enemyIdx].ubFlashTimer--;
                if (s_tEnemy[enemyIdx].ubFlashTimer == 0) {
                    UBYTE ubEnemyType = s_tEnemy[enemyIdx].ubEnemyType;
                    UBYTE ubBitmapOffsetIdx = g_tEnemyTypes[ubEnemyType].ubBitmapOffset;
                    UWORD uwOffset = s_uwEnemyBitmapOffset[ubBitmapOffsetIdx];
                    bobSetFrame(
                        &s_tEnemy[enemyIdx].sBob,
                        &s_pEnemyImage->Planes[0][uwOffset],
                        &s_pEnemyMask->Planes[0][uwOffset]
                    );
                }
            }

            bobPush(&s_tEnemy[enemyIdx].sBob);
        }
    }

    // Enemies
    if (s_ubActiveEnemies > 0) {
        UBYTE ubBigEnemyProcessed = FALSE;

        for (UBYTE enemyIdx=0; enemyIdx<ENEMY_MAX; enemyIdx++) {
            if (s_tEnemy[enemyIdx].wHealth <= 0 || s_tEnemy[enemyIdx].ubOnScreen == FALSE) { continue; }
            if (s_tEnemy[enemyIdx].ubEnemyType == ENEMY_TURRET_TYPE) { continue; }

            if (s_tEnemy[enemyIdx].ubEnemyType == ENEMY_BIG_TYPE) {
                if (ubBigEnemyProcessed == TRUE) { continue; } // Can only have one big enemy on screen at a time.
                s_tBigEnemyBob.sPos = s_tEnemy[enemyIdx].tPosition;

                if (s_tEnemy[enemyIdx].ubFlashTimer == 5) {
                    bobSetFrame(
                        &s_tBigEnemyBob,
                        s_pBigEnemyMask->Planes[0],
                        s_pBigEnemyMask->Planes[0]
                    );
                }

                if (s_tEnemy[enemyIdx].ubFlashTimer > 0) {
                    s_tEnemy[enemyIdx].ubFlashTimer--;
                    if (s_tEnemy[enemyIdx].ubFlashTimer == 0) {
                        bobSetFrame(
                            &s_tBigEnemyBob,
                            s_pBigEnemyImage->Planes[0],
                            s_pBigEnemyMask->Planes[0]
                        );
                    }
                }

                bobPush(&s_tBigEnemyBob);
                ubBigEnemyProcessed = TRUE;
                continue;
            }

            if (s_tEnemy[enemyIdx].ubFlashTimer == 5) {
                UBYTE ubEnemyType = s_tEnemy[enemyIdx].ubEnemyType;
                UBYTE ubBitmapOffsetIdx = g_tEnemyTypes[ubEnemyType].ubBitmapOffset;
                UWORD uwOffset = s_uwEnemyBitmapOffset[ubBitmapOffsetIdx];
                bobSetFrame(
                    &s_tEnemy[enemyIdx].sBob,
                    &s_pEnemyMask->Planes[0][uwOffset],
                    &s_pEnemyMask->Planes[0][uwOffset]
                );
            }

            if (s_tEnemy[enemyIdx].ubFlashTimer > 0) {
                s_tEnemy[enemyIdx].ubFlashTimer--;
                if (s_tEnemy[enemyIdx].ubFlashTimer == 0) {
                    UBYTE ubEnemyType = s_tEnemy[enemyIdx].ubEnemyType;
                    UBYTE ubBitmapOffsetIdx = g_tEnemyTypes[ubEnemyType].ubBitmapOffset;
                    UWORD uwOffset = s_uwEnemyBitmapOffset[ubBitmapOffsetIdx];
                    bobSetFrame(
                        &s_tEnemy[enemyIdx].sBob,
                        &s_pEnemyImage->Planes[0][uwOffset],
                        &s_pEnemyMask->Planes[0][uwOffset]
                    );
                }
            }

            bobPush(&s_tEnemy[enemyIdx].sBob);
        }
    }

    // Extra Life Powerup
    if (s_ubLifePowActive == TRUE) { bobPush(&s_tLifePowBob); }

    // Special Powerup
    if (s_ubSpecialPowActive == TRUE) { bobPush(&s_tSpecialPowBob); }

    // Weapon Powerup
    if (s_ubWeaponPowActive == TRUE) { bobPush(&s_tWeaponPowBob); }

    // Explosions
    if (s_ubActiveExplosions > 0) {
        for (UBYTE explosionIdx=0; explosionIdx < EXPLOSIONS_MAX; explosionIdx++) {
            if (s_tExplosions[explosionIdx].ubAlive == 0) { continue; }
            UBYTE ubFrameIdx = s_tExplosions[explosionIdx].ubFrameIndex;
            UWORD uwAnimOffset = s_uwSmallExplosionAnimOffset[ubFrameIdx];

            bobSetFrame(
                &s_tExplosions[explosionIdx].sBob,
                &s_pSmallExplosionImage->Planes[0][uwAnimOffset],
                &s_pSmallExplosionMask->Planes[0][uwAnimOffset]
            );

            bobPush(&s_tExplosions[explosionIdx].sBob);
        }
    }

    // Big Explosion
    if (s_ubBigExplosionActive == TRUE) {
        bobSetFrame(
            &s_tBigExplosionBob,
            &s_pBigExplosionImage->Planes[0][s_uwBigExplosionAnimOffset[s_ubBigExplosionFrame]],
            &s_pBigExplosionMask->Planes[0][s_uwBigExplosionAnimOffset[s_ubBigExplosionFrame]]
        );

        bobPush(&s_tBigExplosionBob);
    }

    // Player Explosion
    if (s_ubPlayerExplosionActive == TRUE) {
        bobSetFrame(
            &s_tPlayerExplosionBob,
            &s_pBigExplosionImage->Planes[0][s_uwBigExplosionAnimOffset[s_ubPlayerExplosionAnimFrame]],
            &s_pBigExplosionMask->Planes[0][s_uwBigExplosionAnimOffset[s_ubPlayerExplosionAnimFrame]]
        );

        bobPush(&s_tPlayerExplosionBob);
    }

    // Enemy projectiles
    if (s_ubProjectileBobIndex > 0) {
        for (UBYTE projectileIdx=0; projectileIdx<s_ubProjectileBobIndex; projectileIdx++) {
            UBYTE ubType = s_ubEnemyProjectileBobTypes[projectileIdx];
            UWORD uwOffset = s_uwEnemyProjectileBitmapOffset[ubType];

            bobSetFrame(
                &s_tEnemyProjectileBob[projectileIdx],
                &s_pEnemyProjectileBobsImage->Planes[0][uwOffset],
                &s_pEnemyProjectileBobsMask->Planes[0][uwOffset]
            );

            bobPush(&s_tEnemyProjectileBob[projectileIdx]);
        }
    }

    // Boss shot
    if (s_ubBossShotVisible == TRUE) {
        bobPush(&s_tBossShotBob);
    }

    // Boss turrets hit flash.
    if (s_ubBossReached == TRUE) {
        for (UBYTE turretIdx=0; turretIdx<4; turretIdx++) {
            if (s_tBossTurrets[turretIdx].ubFlashTimer > 0) {
                s_tBossTurrets[turretIdx].ubFlashTimer--;
                bobPush(&s_tBossTurrets[turretIdx].sFlashBob);
            }
        }
    }

    // Game Over text
    if (s_ubShowTextGameOver == TRUE) {
        s_tTextGameOverBob.sPos.uwX = TEXT_GAMEOVER_OFFX;
        s_tTextGameOverBob.sPos.uwY = s_pCamera->uPos.uwY+TEXT_GAMEOVER_OFFY;
        bobPush(&s_tTextGameOverBob);
    }

    // Ready text
    if (s_ubShowTextReady == TRUE) {
        s_tTextReadyBob.sPos.uwX = TEXT_READY_OFFX;
        s_tTextReadyBob.sPos.uwY = s_pCamera->uPos.uwY+TEXT_READY_OFFY;
        bobPush(&s_tTextReadyBob);
    }

    // Go text
    if (s_ubShowTextGo == TRUE) {
        s_tTextGoBob.sPos.uwX = TEXT_GO_OFFX;
        s_tTextGoBob.sPos.uwY = s_pCamera->uPos.uwY+TEXT_GO_OFFY;
        bobPush(&s_tTextGoBob);
    }

    // Stage Complete
    if (s_ubLevelEnd == TRUE) {
        bobPush(&s_tStageCompleteBgBob);
    }

    bobEnd();
    systemSetDmaBit(DMAB_BLITHOG, 0);
}

static void processTimers() {
    // System
    s_ubFrameCounter = !s_ubFrameCounter;
    if (s_ubShowTextGameOver == TRUE && s_ubShowTextGameOverTimer > 0) { s_ubShowTextGameOverTimer--; }
    if (s_ubLevelEnd == TRUE && s_ubLevelEndTimer > 0) { s_ubLevelEndTimer--; }

    // Player
    s_ubEngineAnimFrame++; s_ubEngineAnimFrame = s_ubEngineAnimFrame % ENGINE_ANIM_FRAMES;
    if (s_ubFireDelay > 0) { s_ubFireDelay--; }
    if (s_ubSpecialDelay > 0) { s_ubSpecialDelay--; }
    if (s_ubAudioDelay > 0) { s_ubAudioDelay--; }
    if (s_ubPlayerInvincibleTimer > 0) { s_ubPlayerInvincibleTimer--; }

    // Player invincibility flashing
    s_ubFlashTimer++;

    // Shorten duration towards end of timer.
    UBYTE ubFlashTimeout = FLASH_TIME;
    if (s_ubPlayerInvincibleTimer <= 25) {
        ubFlashTimeout = 2;
    }

    if (s_ubFlashTimer >= ubFlashTimeout) {
        s_ubFlashTimer = 0;
        s_ubFlashOn = !s_ubFlashOn;
    }

    // Explosions
    if (s_ubActiveExplosions > 0) {
        for (UBYTE explosionIdx=0; explosionIdx < EXPLOSIONS_MAX; explosionIdx++) {
            if (s_tExplosions[explosionIdx].ubAlive == 0) { continue; }
            s_tExplosions[explosionIdx].ubFrameIndex++;
            if (s_tExplosions[explosionIdx].ubFrameIndex == EXPLOSION_ANIM_FRAMES) {
                s_tExplosions[explosionIdx].ubAlive = 0;
                s_ubActiveExplosions--;
            }
        }
    }

    // Big Explosion
    if (s_ubBigExplosionActive == TRUE) {
        s_ubBigExplosionFrame++;
        if (s_ubBigExplosionFrame == BIGEXPLOSION_ANIM_FRAMES) {
            s_ubBigExplosionActive = FALSE;
            s_ubBigExplosionFrame = 0;
        }
    }

    // Player Explosion
    if (s_ubPlayerExplosionActive == TRUE) {
        s_ubPlayerExplosionAnimFrame++;
        if (s_ubPlayerExplosionAnimFrame == BIGEXPLOSION_ANIM_FRAMES) {
            s_ubPlayerExplosionActive = FALSE;
            s_ubPlayerExplosionAnimFrame = 0;
        }
    }
}

static void processPowerups() {
    // Extra life
    if (s_ubLifePowActive == TRUE) {
        if (s_ubPowerupBounceTimer > 0) {
            s_ubPowerupBounceTimer--;
            s_tLifePowBob.sPos.uwY -= POWERUP_FALL_SPEED+1;
        } else {
            s_tLifePowBob.sPos.uwY += POWERUP_FALL_SPEED;
        }


        // Check if offscreen.
        if (s_tLifePowBob.sPos.uwY > s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT) {
            s_ubLifePowActive = FALSE;
            return;
        }

        #ifndef COLLISIONS_DISABLED
        UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX, s_tPlayerPosition.uwY, PLAYER_SHIP_WIDTH, PLAYER_SHIP_HEIGHT,
                                           s_tLifePowBob.sPos.uwX, s_tLifePowBob.sPos.uwY, POWERUP_WIDTH, POWERUP_HEIGHT);
        if (ubCollision == TRUE && s_ubPlayerAlive == TRUE) {
            audioMixerPlaySfx(s_pSfxCollectPowerup, CHANNEL_FOR_PLAYER, 9, 0);
            if (s_ubPlayerLives < PLAYER_LIVES_MAX) {
                s_ubPlayerLives++;
                s_ubUpdateLives = TRUE;
            } else {
                s_ulPlayerScore += POWERUP_SCORE;
                s_ubUpdateScore = TRUE;
            }
            s_ubLifePowActive = FALSE;
        }
        #endif

        return;
    }

    // Special
    if (s_ubSpecialPowActive == TRUE) {
        if (s_ubPowerupBounceTimer > 0) {
            s_ubPowerupBounceTimer--;
            s_tSpecialPowBob.sPos.uwY -= POWERUP_FALL_SPEED+1;
        } else {
            s_tSpecialPowBob.sPos.uwY += POWERUP_FALL_SPEED;
        }


        // Check if offscreen.
        if (s_tSpecialPowBob.sPos.uwY > s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT) {
            s_ubSpecialPowActive = FALSE;
            return;
        }

        #ifndef COLLISIONS_DISABLED
        UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX, s_tPlayerPosition.uwY, PLAYER_SHIP_WIDTH, PLAYER_SHIP_HEIGHT,
                                           s_tSpecialPowBob.sPos.uwX, s_tSpecialPowBob.sPos.uwY, POWERUP_WIDTH, POWERUP_HEIGHT);
        if (ubCollision == TRUE && s_ubPlayerAlive == TRUE) {
            audioMixerPlaySfx(s_pSfxCollectPowerup, CHANNEL_FOR_PLAYER, 9, 0);
            if (s_ubPlayerSpecial < PLAYER_SPECIAL_MAX) {
                s_ubPlayerSpecial++;
                s_ubUpdateSpecial = TRUE;
            } else {
                s_ulPlayerScore += POWERUP_SCORE;
                s_ubUpdateScore = TRUE;
            }
            s_ubSpecialPowActive = FALSE;
        }
        #endif

        return;
    }

    // Weapon
    if (s_ubWeaponPowActive == TRUE) {
        if (s_ubPowerupBounceTimer > 0) {
            s_ubPowerupBounceTimer--;
            s_tWeaponPowBob.sPos.uwY -= POWERUP_FALL_SPEED+1;
        } else {
            s_tWeaponPowBob.sPos.uwY += POWERUP_FALL_SPEED;
        }

        // Check if offscreen.
        if (s_tWeaponPowBob.sPos.uwY > s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT) {
            s_ubWeaponPowActive = FALSE;
            return;
        }

        #ifndef COLLISIONS_DISABLED
        UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX, s_tPlayerPosition.uwY, PLAYER_SHIP_WIDTH, PLAYER_SHIP_HEIGHT,
                                           s_tWeaponPowBob.sPos.uwX, s_tWeaponPowBob.sPos.uwY, POWERUP_WIDTH, POWERUP_HEIGHT);
        if (ubCollision == TRUE && s_ubPlayerAlive == TRUE) {
            audioMixerPlaySfx(s_pSfxCollectPowerup, CHANNEL_FOR_PLAYER, 9, 0);
            if (s_ubEquippedProjectileType < (PLAYER_PROJECTILE_TYPES-1)) {
                s_ubEquippedProjectileType++;
                s_ubUpdatePower = TRUE;
            } else {
                s_ulPlayerScore += POWERUP_SCORE;
                s_ubUpdateScore = TRUE;
            }
            s_ubWeaponPowActive = FALSE;
        }
        #endif

        return;
    }
}

static void processPlayer() {
    // Can't touch this.
    if (s_ubPlayerIsInvincible == TRUE) {
        if (s_ubPlayerInvincibleTimer == 0) {
            s_ubPlayerIsInvincible = FALSE;
            s_ubDisplayPlayer = TRUE;
        } else {
            if (s_ubFlashOn == TRUE) {
                s_ubDisplayPlayer = TRUE;
            } else {
                s_ubDisplayPlayer = FALSE;
            }
        }
    }

    // Respawn player.
    if (s_ubPlayerAlive == FALSE && s_ubPlayerLives > 0 && s_ubPlayerExplosionActive == FALSE) {
        s_tPlayerPosition.uwX = s_pCamera->uPos.uwX+(80 - (PLAYER_SHIP_WIDTH/2));
        s_tPlayerPosition.uwY = s_pCamera->uPos.uwY+192;
        s_ubPlayerAlive = TRUE;
        s_ubPlayerIsInvincible = TRUE;
        s_ubPlayerInvincibleTimer = PLAYER_INVINCIBLE_TIME;
    }

    // Game over, man!
    if (s_ubPlayerLives == 0) {
        s_ubPlayerAlive = FALSE;
        s_ubCameraCanMove = FALSE;
        s_ubShowTextGameOver = TRUE;
    }

    // Player has reached end of level, add up bonus/penalty and render text to bitmap.
    if (s_ubLevelEndReached == TRUE && s_ubLevelEnd == FALSE) {
        // Score bonuses and penalty
        ULONG ulKillBonus = 0;
        ULONG ulSpecialBonus = 0;
        ULONG ulDeathPenalty = 0;

        if (g_ubLoopIteration == 0) {
            ulKillBonus = s_uwPlayerKills * BONUS_KILLS_MULTIPLIER;
            ulSpecialBonus = s_ubPlayerSpecial * BONUS_SPECIAL_MULTIPLIER;
            ulDeathPenalty = s_ubPlayerDeaths * BONUS_DEATHS_MULTIPLIER;
        } else {
            ulKillBonus = (s_uwPlayerKills * BONUS_KILLS_MULTIPLIER) * (g_ubLoopIteration+1);
            ulSpecialBonus = (s_ubPlayerSpecial * BONUS_SPECIAL_MULTIPLIER) * (g_ubLoopIteration+1);
            ulDeathPenalty = (s_ubPlayerDeaths * BONUS_DEATHS_MULTIPLIER) * (g_ubLoopIteration+1);
        }

        s_ulPlayerScore += ulKillBonus;
        s_ulPlayerScore += ulSpecialBonus;
        s_ulPlayerScore -= ulDeathPenalty;

        char cSummaryText[6];
        sprintf(cSummaryText, "%03d", s_uwPlayerKills);
        fontDrawStr(s_pFont, s_pStageCompleteBgImage, 19, 15, cSummaryText, HUD_TEXT_COLOR, 0, s_pStageCompleteText);

        sprintf(cSummaryText, "%02d", s_ubPlayerDeaths);
        fontDrawStr(s_pFont, s_pStageCompleteBgImage, 23, 36, cSummaryText, HUD_TEXT_COLOR, 0, s_pStageCompleteText);

        sprintf(cSummaryText, "%02d", s_ubPlayerSpecial);
        fontDrawStr(s_pFont, s_pStageCompleteBgImage, 23, 57, cSummaryText, HUD_TEXT_COLOR, 0, s_pStageCompleteText);

        s_tStageCompleteBgBob.sPos.uwX = TEXT_STAGECOMPLETE_OFFX;
        s_tStageCompleteBgBob.sPos.uwY = s_pCamera->uPos.uwY+TEXT_STAGECOMPLETE_OFFY;

        s_ubUpdateScore = TRUE;
        s_ubLevelEnd = TRUE;
    }
}

static void processEnemies() {
    if (s_ubActiveEnemies == 0) { return; }

    UWORD uwCameraYMin = s_pCamera->uPos.uwY;
    UWORD uwCameraYMax = s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT;
    UWORD uwCameraXMin = TILE_VIEWPORT_XMIN;
    UWORD uwCameraXMax = TILE_VIEWPORT_XMAX;

    for (UBYTE enemyIdx=0; enemyIdx<ENEMY_MAX; enemyIdx++) {
        if (s_tEnemy[enemyIdx].wHealth <= 0) { continue; }

        UBYTE ubEnemyType = s_tEnemy[enemyIdx].ubEnemyType;

        // Move
        if (ubEnemyType != ENEMY_TURRET_TYPE) {
            s_tEnemy[enemyIdx].uwPathIdx += s_tEnemy[enemyIdx].ubMoveSpeed;
            if (s_tEnemy[enemyIdx].uwPathIdx >= s_tEnemy[enemyIdx].uwPathLength-1) {
                s_tEnemy[enemyIdx].wHealth = 0;
                s_tEnemy[enemyIdx].ubOnScreen = FALSE;
                s_ubActiveEnemies--;
                logWrite("[%d] End of Path => Active: %d", enemyIdx, s_ubActiveEnemies);
                continue;
            }

            UWORD uwPathIdx = s_tEnemy[enemyIdx].uwPathArrayOffset + s_tEnemy[enemyIdx].uwPathIdx;
            s_tEnemy[enemyIdx].tPosition.uwX = g_ubPathData[uwPathIdx];
            s_tEnemy[enemyIdx].tPosition.uwY = g_ubPathData[uwPathIdx+1] + s_tEnemy[enemyIdx].uwPathYOffset;
        }

        s_tEnemy[enemyIdx].sBob.sPos = s_tEnemy[enemyIdx].tPosition;

        // UBYTE onBufferCheck = tileBufferIsRectFullyOnBuffer(s_pTileBuffer, s_tEnemy[enemyIdx].sBob.sPos.uwX, s_tEnemy[enemyIdx].sBob.sPos.uwY, 16, 16);
        // if (onBufferCheck == FALSE) {
        //     s_tEnemy[enemyIdx].ubOnScreen = FALSE;
        //     continue;
        // }

        // Check X bounds
        if ((s_tEnemy[enemyIdx].tPosition.uwX+g_tEnemyTypes[ubEnemyType].ubWidth) < uwCameraXMin || s_tEnemy[enemyIdx].tPosition.uwX > uwCameraXMax)
        {
            s_tEnemy[enemyIdx].ubOnScreen = FALSE;
            continue;
        }

        // Check Y bounds
        //if (s_tEnemy[enemyIdx].tPosition.uwY+8 < uwCameraYMin)
        if ((s_tEnemy[enemyIdx].tPosition.uwY+g_tEnemyTypes[ubEnemyType].ubHeight)-1 < uwCameraYMin)
        {
            s_tEnemy[enemyIdx].ubOnScreen = FALSE;
            continue;
        }

        // Remove if below camera Y bounds.
        if (s_tEnemy[enemyIdx].tPosition.uwY >= uwCameraYMax) {
            s_tEnemy[enemyIdx].ubOnScreen = FALSE;
            s_tEnemy[enemyIdx].wHealth = 0;
            s_ubActiveEnemies--;
            logWrite("[%d] Below camera => Active: %d", enemyIdx, s_ubActiveEnemies);
            continue;
        }

        // Enemy is on screen.
        s_tEnemy[enemyIdx].ubOnScreen = TRUE;

        if (s_tEnemy[enemyIdx].ubInvincible == TRUE) {
            if (s_tEnemy[enemyIdx].tPosition.uwY >= uwCameraYMin+ENEMY_INVINCIBLE_MARGIN &&
                s_tEnemy[enemyIdx].tPosition.uwX+g_tEnemyTypes[ubEnemyType].ubWidth >= uwCameraXMin+ENEMY_INVINCIBLE_MARGIN &&
                s_tEnemy[enemyIdx].tPosition.uwX <= uwCameraXMax-ENEMY_INVINCIBLE_MARGIN) {
                s_tEnemy[enemyIdx].ubInvincible = FALSE;
            }
            // TODO: Check X?
        }

        #ifndef COLLISIONS_DISABLED
        // Check collision with player.
        if (s_ubPlayerAlive == TRUE) {
            UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX+PLAYER_HITBOX_OFFSET_X, s_tPlayerPosition.uwY+PLAYER_HITBOX_OFFSET_Y, PLAYER_HITBOX_WIDTH, PLAYER_HITBOX_HEIGHT,
                                               s_tEnemy[enemyIdx].tPosition.uwX, s_tEnemy[enemyIdx].tPosition.uwY, g_tEnemyTypes[ubEnemyType].ubWidth, g_tEnemyTypes[ubEnemyType].ubHeight);
            if (ubCollision == TRUE) {
                processPlayerDie();
            }
        }
        #endif

        // Fire projectile.
        if (s_tEnemy[enemyIdx].ubCanShoot == FALSE || s_ubPlayerAlive == FALSE) { continue; }

        if (s_tEnemy[enemyIdx].ubCooldownTimer == 0) {
            s_tEnemy[enemyIdx].ubCooldownTimer = g_tEnemyTypes[ubEnemyType].ubCooldownTime;
            UBYTE ubProjectileType = g_tEnemyTypes[ubEnemyType].ubProjectileType;

            // Check if too close to player
            UWORD uwDiffX = ABS(s_tPlayerPosition.uwX - s_tEnemy[enemyIdx].tPosition.uwX);
            UWORD uwDiffY = ABS(s_tPlayerPosition.uwY - s_tEnemy[enemyIdx].tPosition.uwY);
            if (uwDiffX <= s_ubEnemyProjectileSafetyMargin && uwDiffY <= s_ubEnemyProjectileSafetyMargin) {
                break;
            }

            if (ubProjectileType == 0) {
                // Only fire when near player on X axis.
                if (uwDiffX > s_ubEnemyProjectileRange) {
                    break;
                }

                for (UBYTE i=0; i<ENEMY_PROJECTILE_MAX; i++) {
                    if (s_tSimpleEnemyProjectiles[i].ubAlive == 0) {
                        UWORD uwEnemyGunX = s_tEnemy[enemyIdx].tPosition.uwX + g_tEnemyTypes[ubEnemyType].ubGunOffsetX;
                        UWORD uwEnemyGunY = s_tEnemy[enemyIdx].tPosition.uwY + g_tEnemyTypes[ubEnemyType].ubGunOffsetY;
                        s_tSimpleEnemyProjectiles[i].uwX = uwEnemyGunX - (g_tEnemyProjectileTypes[ubProjectileType].ubOffset);
                        s_tSimpleEnemyProjectiles[i].uwY = uwEnemyGunY;
                        s_tSimpleEnemyProjectiles[i].bDeltaX = 0;
                        s_tSimpleEnemyProjectiles[i].bDeltaY = (g_tEnemyProjectileTypes[ubProjectileType].bSpeed + s_ubEnemyProjectileSpeed);
                        s_tSimpleEnemyProjectiles[i].ubAlive = 255;
                        s_tSimpleEnemyProjectiles[i].ubChannel = 255;
                        s_tSimpleEnemyProjectiles[i].ubType = ubProjectileType;
                        break;
                    }
                }
            } else {
                for (UBYTE i=0; i<ENEMY_PROJECTILE_MAX; i++) {
                    if (s_tComplexEnemyProjectiles[i].ubAlive == 0) {
                        UWORD uwEnemyGunX = s_tEnemy[enemyIdx].tPosition.uwX + g_tEnemyTypes[ubEnemyType].ubGunOffsetX;
                        UWORD uwEnemyGunY = s_tEnemy[enemyIdx].tPosition.uwY + g_tEnemyTypes[ubEnemyType].ubGunOffsetY;
                        UWORD uwPlayerCenterX = s_tPlayerPosition.uwX + PLAYER_CENTER_OFFSET_X;
                        UWORD uwPlayerCenterY = s_tPlayerPosition.uwY + PLAYER_CENTER_OFFSET_Y;

                        if (s_ubFrameCounter == 0) {
                            uwPlayerCenterX += s_ubEnemyProjectileAccuracy;
                        } else {
                            uwPlayerCenterX -= s_ubEnemyProjectileAccuracy;
                        }

                        UBYTE ubAngle = getAngleBetweenPoints(uwEnemyGunX, uwEnemyGunY, uwPlayerCenterX, uwPlayerCenterY);
                        s_tComplexEnemyProjectiles[i].fX = fix16_from_int(uwEnemyGunX);
                        s_tComplexEnemyProjectiles[i].fY = fix16_from_int(uwEnemyGunY);
                        s_tComplexEnemyProjectiles[i].fDeltaX = ccos(ubAngle) * (g_tEnemyProjectileTypes[ubProjectileType].bSpeed + s_ubEnemyProjectileSpeed);
                        s_tComplexEnemyProjectiles[i].fDeltaY = csin(ubAngle) * (g_tEnemyProjectileTypes[ubProjectileType].bSpeed + s_ubEnemyProjectileSpeed);
                        s_tComplexEnemyProjectiles[i].ubAlive = 255;
                        s_tComplexEnemyProjectiles[i].ubChannel = 255;
                        s_tComplexEnemyProjectiles[i].ubType = ubProjectileType;

                        if (s_tComplexEnemyProjectiles[i].fDeltaX == 0 && s_tComplexEnemyProjectiles[i].fDeltaY == 0) {
                            s_tComplexEnemyProjectiles[i].ubAlive = 0;
                        }

                        break;
                    }
                }
            }
        }

        s_tEnemy[enemyIdx].ubCooldownTimer--;
    }
}

static void processBoss() {
    if (s_ubLevelEndReached == TRUE) { return; }

    // Keep player from going over boss.
    if (s_tPlayerPosition.uwY < 170) {
        s_tPlayerPosition.uwY = 170;
    }

    // All turrets defeated
    if (s_ubBossTurretsAlive == 0 && s_ubBossDefeated == FALSE) {
        s_ubBossDefeated = TRUE;
        s_uwBossShotTimer = 0;
    }

    // Boss defeated. Play explosions and set end of level.
    if (s_ubBossDefeated == TRUE && s_ubLevelEndReached == FALSE) {
        s_ubLevelEndTimer--;
        if (s_ubLevelEndTimer == 0) {
            s_ubLevelEndReached = TRUE;
            s_ubLevelEndTimer = 255;
        }

        if (s_uwBossShotTimer == 0) {
            s_uwBossShotTimer = 15;
            //s_uwBossShotTimer = 32 + g_bCyclicRng[s_ubCyclicRngIdx];
            // s_ubCyclicRngIdx++;
            // if (s_ubCyclicRngIdx >= RNG_IDX_MAX) {
            //     s_ubCyclicRngIdx = 0;
            // }

            tUwCoordYX tExplosionPosition = { .uwX = g_uwSmallExplosionPositions[s_ubBossExplosionIdx], .uwY = g_uwSmallExplosionPositions[s_ubBossExplosionIdx+1] };
            createExplosionAtPosition(tExplosionPosition);
            if (s_ubBossExplosionIdx == 6) {
                s_tBigExplosionBob.sPos.uwX = 80;
                s_tBigExplosionBob.sPos.uwY = 138;
                s_ubBigExplosionActive = TRUE;
                s_ubBigExplosionFrame = 0;
            }
            s_ubBossExplosionIdx += 2;
            if (s_ubBossExplosionIdx >= BOSS_EXPLOSION_POSITIONS) { s_ubBossExplosionIdx = 0; }
        }
    }

    // Count down shot timer.
    if (s_uwBossShotTimer > 0) {
        s_uwBossShotTimer--;
    }

    // Play sound effect before firing.
    if (s_uwBossShotTimer == 20 && s_ubBossDefeated == FALSE) {
        audioMixerPlaySfx(s_pSfxBossShot, 0, 8, 0);
    }

    // Process boss shot.
    if (s_ubBossShotAlive == TRUE) {
        s_ubBossShotVisible = TRUE;
        UWORD uwCameraYMin = s_pCamera->uPos.uwY;
        UWORD uwCameraYMax = s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT;
        s_tBossShotBob.sPos.uwY += 4;

        if ((s_tBossShotBob.sPos.uwY+31) < uwCameraYMin)
        {
            s_ubBossShotVisible = FALSE;
        }

        if (s_tBossShotBob.sPos.uwY >= uwCameraYMax) {
            s_ubBossShotVisible = FALSE;
        }

        if (s_tBossShotBob.sPos.uwY >= BOSS_SHOT_Y_CUTOFF) {
            s_ubBossShotVisible = FALSE;
            s_ubBossShotAlive = FALSE;
        }
    }

    #ifndef COLLISIONS_DISABLED
    // Collision detection with player.
    if (s_ubBossShotVisible == TRUE) {
        UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX+PLAYER_HITBOX_OFFSET_X, s_tPlayerPosition.uwY+PLAYER_HITBOX_OFFSET_Y, PLAYER_HITBOX_WIDTH, PLAYER_HITBOX_HEIGHT,
                                           s_tBossShotBob.sPos.uwX, s_tBossShotBob.sPos.uwY, 16, 32);
        if (ubCollision == TRUE && s_ubPlayerAlive == TRUE) {
            processPlayerDie();
        }
    }
    #endif

    // Fire the cannon.
    if (s_uwBossShotTimer == 0 && s_ubBossShotAlive == FALSE && s_ubBossDefeated == FALSE) {
        if (s_ubBossFirstShot == FALSE) {
            s_tBossShotBob.sPos.uwX = 88;
            s_tBossShotBob.sPos.uwY = 147;
            s_ubBossShotAlive = TRUE;
            s_uwBossShotTimer = BOSS_SHOT_TIME;
        } else {
            s_uwBossShotTimer = BOSS_SHOT_TIME;
            s_ubBossFirstShot = FALSE;
        }

    }

    // Process boss turrets.
    if (s_ubBossReached == TRUE && s_ubPlayerAlive == TRUE) {
        for (UBYTE turretIdx=0; turretIdx<4; turretIdx++) {
            if (s_tBossTurrets[turretIdx].wHealth <= 0 && s_tBossTurrets[turretIdx].ubAlive == TRUE) { destroyBossTurret(turretIdx); }
            if (s_tBossTurrets[turretIdx].wHealth <= 0) { continue; }

            s_tBossTurrets[turretIdx].ubCooldownTimer--;

            if (s_tBossTurrets[turretIdx].ubCooldownTimer == 0) {
                s_tBossTurrets[turretIdx].ubCooldownTimer = BOSS_COOLDOWN_TIME + g_bCyclicRng[s_ubCyclicRngIdx];
                s_ubCyclicRngIdx++;
                if (s_ubCyclicRngIdx >= RNG_IDX_MAX) { s_ubCyclicRngIdx = 0; }

                // Adjust cooldown timer and bullet speed based on how many boss turrets are still alive.
                UBYTE ubSpeed = 3;
                switch (s_ubBossTurretsAlive) {
                    case 1:
                        if (s_tBossTurrets[turretIdx].ubCooldownTimer > 25) { s_tBossTurrets[turretIdx].ubCooldownTimer = 25; ubSpeed = 4;}
                        break;
                    case 2:
                        if (s_tBossTurrets[turretIdx].ubCooldownTimer > 30) { s_tBossTurrets[turretIdx].ubCooldownTimer = 30; }
                        break;
                    case 3:
                        if (s_tBossTurrets[turretIdx].ubCooldownTimer > 40) { s_tBossTurrets[turretIdx].ubCooldownTimer = 40; }
                        break;
                }

                for (UBYTE i=0; i<ENEMY_PROJECTILE_MAX; i++) {
                    if (s_tComplexEnemyProjectiles[i].ubAlive == 0) {
                        UWORD uwEnemyGunX = s_tBossTurrets[turretIdx].tFlashPos.uwX + 3;
                        UWORD uwEnemyGunY = s_tBossTurrets[turretIdx].tFlashPos.uwY + 3;
                        UWORD uwPlayerCenterX = s_tPlayerPosition.uwX + PLAYER_CENTER_OFFSET_X;
                        UWORD uwPlayerCenterY = s_tPlayerPosition.uwY + PLAYER_CENTER_OFFSET_Y;
                        UBYTE ubAngle = getAngleBetweenPoints(uwEnemyGunX, uwEnemyGunY, uwPlayerCenterX, uwPlayerCenterY);
                        s_tComplexEnemyProjectiles[i].fX = fix16_from_int(uwEnemyGunX);
                        s_tComplexEnemyProjectiles[i].fY = fix16_from_int(uwEnemyGunY);
                        s_tComplexEnemyProjectiles[i].fDeltaX = ccos(ubAngle) * ubSpeed;
                        s_tComplexEnemyProjectiles[i].fDeltaY = csin(ubAngle) * ubSpeed;
                        s_tComplexEnemyProjectiles[i].ubAlive = 255;
                        s_tComplexEnemyProjectiles[i].ubChannel = 255;
                        s_tComplexEnemyProjectiles[i].ubType = 1;

                        if (s_tComplexEnemyProjectiles[i].fDeltaX == 0 && s_tComplexEnemyProjectiles[i].fDeltaY == 0) {
                            s_tComplexEnemyProjectiles[i].ubAlive = 0;
                        }

                        break;
                    }
                }
            }
        }
    }
}

static void processPlayerDie() {
    if (s_ubPlayerIsInvincible == TRUE) { return; }
    s_tPlayerExplosionBob.sPos.uwX = s_tPlayerPosition.uwX - 8;
    s_tPlayerExplosionBob.sPos.uwY = s_tPlayerPosition.uwY - 8;
    s_ubPlayerExplosionActive = TRUE;
    s_ubPlayerExplosionAnimFrame = 0;
    audioMixerPlaySfx(s_pSfxExplosion, CHANNEL_FOR_EXPLOSION, 10, 0);
    s_ubPlayerAlive = FALSE;
    if (s_ubPlayerLives != 0) { s_ubPlayerLives--; }
    s_ubUpdateLives = TRUE;
    if (s_ubEquippedProjectileType > 0) {
        s_ubEquippedProjectileType--;
    }
    s_ubUpdatePower = TRUE;

    for (UBYTE i=0; i<ENEMY_PROJECTILE_MAX; i++) {
        if (s_tSimpleEnemyProjectiles[i].ubAlive > 0) { s_tSimpleEnemyProjectiles[i].ubAlive = 1; }
        if (s_tComplexEnemyProjectiles[i].ubAlive > 0) { s_tComplexEnemyProjectiles[i].ubAlive = 1; }
    }

    createPowerupAtPosition(s_tPlayerPosition, 3);
    s_ubPlayerDeaths++;
}

static void processPlayerShoot() {
    if (s_ubFireDelay == 0 && s_ubPlayerAlive == TRUE) {
        for (UBYTE i=0; i<PLAYER_PROJECTILE_MAX; i++) {
            if (s_tPlayerProjectiles[i].ubAlive == 0) {
                s_ubFireDelay = g_tPlayerProjectileTypes[s_ubEquippedProjectileType].ubDelay;

                s_tPlayerProjectiles[i].uwX = (s_tPlayerPosition.uwX + g_tPlayerProjectileTypes[s_ubEquippedProjectileType].ubXOffset);
                s_tPlayerProjectiles[i].uwY = (s_tPlayerPosition.uwY - g_tPlayerProjectileTypes[s_ubEquippedProjectileType].ubHeight);
                s_tPlayerProjectiles[i].ubAlive = 1;
                s_tPlayerProjectiles[i].ubType = s_ubEquippedProjectileType;

                if (s_ubAudioDelay == 0) {
                    audioMixerPlaySfx(s_pSfxPlayerShot[s_ubEquippedProjectileType], CHANNEL_FOR_PLAYER, 8, 0);
                    s_ubAudioDelay = PLAYER_AUDIO_DELAY;
                }

                break;
            }
        }
    }
}

static void processPlayerSpecial() {
    if (s_ubSpecialDelay == 0 && s_ubPlayerAlive == TRUE) {
        if (s_ubPlayerSpecial > 0) {
            // TODO: Play SFX here.
            s_ubPlayerSpecial--;
            s_ubUpdateSpecial = TRUE;
            s_ubSpecialDelay = PLAYER_SPECIAL_DELAY;

            s_ubPlayerIsInvincible = TRUE;
            s_ubPlayerInvincibleTimer = PLAYER_INVINCIBLE_TIME;

            for (UBYTE enemyIdx=0; enemyIdx<ENEMY_MAX; enemyIdx++) {
                if (s_tEnemy[enemyIdx].wHealth > 0 && s_tEnemy[enemyIdx].ubOnScreen == TRUE) {
                    if (s_tEnemy[enemyIdx].ubInvincible == TRUE) { continue; }
                    s_tEnemy[enemyIdx].wHealth -= PLAYER_SPECIAL_DAMAGE;
                    s_tEnemy[enemyIdx].ubFlashTimer = 5;

                    // Enemy is dead.
                    if (s_tEnemy[enemyIdx].wHealth <= 0) {
                        destroyEnemy(enemyIdx);
                        logWrite("[%d] Killed by Special at (%d,%d) => Active: %d", enemyIdx, s_tEnemy[enemyIdx].tPosition.uwX, s_tEnemy[enemyIdx].tPosition.uwY, s_ubActiveEnemies);
                    }
                }
            }
        }
    }
}

static void processPlayerProjectiles() {
    UWORD uwCameraYMin = s_pCamera->uPos.uwY;
    UWORD uwCameraYMax = s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT;
    UWORD uwCameraXMin = TILE_VIEWPORT_XMIN;
    UWORD uwCameraXMax = TILE_VIEWPORT_XMAX;

    for (UBYTE projectileIdx=0; projectileIdx<PLAYER_PROJECTILE_MAX; projectileIdx++) {
        if (s_tPlayerProjectiles[projectileIdx].ubAlive != 0) {
            UWORD uwX = s_tPlayerProjectiles[projectileIdx].uwX;
            UWORD uwY = s_tPlayerProjectiles[projectileIdx].uwY;
            UBYTE ubType = s_tPlayerProjectiles[projectileIdx].ubType;
            //BYTE bDeltaX = g_tPlayerProjectileTypes[ubType].bDeltaX;
            BYTE bDeltaY = g_tPlayerProjectileTypes[ubType].bDeltaY;
            UBYTE ubWidth = g_tPlayerProjectileTypes[ubType].ubWidth;
            UBYTE ubHeight = g_tPlayerProjectileTypes[ubType].ubHeight;
            UBYTE ubDamage = g_tPlayerProjectileTypes[ubType].ubDamage;
            UBYTE ubDieOnCollision = g_tPlayerProjectileTypes[ubType].ubDieOnCollision;

            //UWORD uwX2 = 0;
            //BYTE bDeltaX2 = s_tPlayerProjectileTypes[ubType].bDeltaX2;
            //UBYTE ubSecondarySpriteIndex = s_tPlayerProjectileTypes[ubType].ubSecondarySpriteIndex;
            //UBYTE ubWideSprite = s_tPlayerProjectileTypes[ubType].ubWideSprite;
            //UBYTE ubSpreadShot = s_tPlayerProjectileTypes[ubType].ubSpreadShot;
            //UBYTE ubHasSecondary = FALSE;
            // if (ubWideSprite || ubSpreadShot) {
            //     ubHasSecondary = TRUE;
            //     uwX2 = s_tPlayerSecondaryProjectiles[projectileIdx].uwX;
            // }

            // Check if projectile if off screen.
            //if (uwY < (uwCameraYMin-ubHeight) || uwX < (uwCameraXMin-ubWidth) || uwX > uwCameraXMax) {
            if (uwY < (uwCameraYMin-ubHeight)) {
                s_tPlayerProjectiles[projectileIdx].ubAlive = 0;
                movePlayerProjectile(s_tPlayerProjectiles[projectileIdx].pCopBlock, -16, 0, ubHeight, PLAYER_SPRITE_CHANNEL_A, ubType);

                //movePlayerProjectile(s_tPlayerProjectiles[projectileIdx].pCopBlock, -16, -16, ubHeight, PLAYER_SPRITE_CHANNEL_A, ubType, FALSE);
                // if (ubHasSecondary) {
                //     movePlayerProjectile(s_tPlayerSecondaryProjectiles[projectileIdx].pCopBlock, -16, -16, ubHeight, PLAYER_SPRITE_CHANNEL_B, ubSecondarySpriteIndex, TRUE);
                // }

                continue;
            }

            // Check collisions
            #ifndef COLLISIONS_DISABLED
            for (UBYTE enemyIdx=0; enemyIdx<ENEMY_MAX; enemyIdx++) {
                if (s_tEnemy[enemyIdx].wHealth <= 0) { continue; }

                // Get EnemyType
                UBYTE ubEnemyType = s_tEnemy[enemyIdx].ubEnemyType;

                // Check if enemy is on screen.
                if (s_tEnemy[enemyIdx].tPosition.uwX+g_tEnemyTypes[ubEnemyType].ubWidth < uwCameraXMin || s_tEnemy[enemyIdx].tPosition.uwX > uwCameraXMax) { continue; }
                if (s_tEnemy[enemyIdx].tPosition.uwY+g_tEnemyTypes[ubEnemyType].ubHeight < uwCameraYMin || s_tEnemy[enemyIdx].tPosition.uwY > uwCameraYMax) { continue; }

                // TODO: Rethink this approach, ends up basically doing collision detection twice. Unroll into individual checks? Include checks in checkCollision()?

                // Check if projectile is to far to the left of the enemy
                if (s_tEnemy[enemyIdx].tPosition.uwX+g_tEnemyTypes[ubEnemyType].ubWidth < uwX) { continue; }

                // Check if projectile is to far to the right of the enemy
                if (s_tEnemy[enemyIdx].tPosition.uwX > uwX+ubWidth) { continue; }

                // Check if projectile is above enemy
                if (uwY+ubHeight > s_tEnemy[enemyIdx].tPosition.uwY) { continue; }

                // Test collision
                UBYTE ubCollision = checkCollision(uwX, uwY-bDeltaY, ubWidth, ubHeight, s_tEnemy[enemyIdx].tPosition.uwX, s_tEnemy[enemyIdx].tPosition.uwY, g_tEnemyTypes[ubEnemyType].ubWidth, g_tEnemyTypes[ubEnemyType].ubHeight);

                // Check spread shot collision
                // if (ubSpreadShot == TRUE) {
                //     UBYTE ubSpreadCollision = checkCollision(uwX, uwY+bDeltaY, ubWidth, ubHeight, s_tEnemy[enemyIdx].tPosition.wX, s_tEnemy[enemyIdx].tPosition.wY, ENEMY_WIDTH, ENEMY_HEIGHT);
                // }

                if (ubCollision == FALSE) { continue; }

                // Damage enemy
                if (s_tEnemy[enemyIdx].ubInvincible == FALSE) {
                    s_tEnemy[enemyIdx].wHealth -= ubDamage;
                    s_tEnemy[enemyIdx].ubFlashTimer = 5;
                }

                // Remove projectile?
                if (ubDieOnCollision == TRUE) {
                    s_tPlayerProjectiles[projectileIdx].ubAlive = 0;
                }

                // Enemy is dead.
                if (s_tEnemy[enemyIdx].wHealth <= 0) {
                    destroyEnemy(enemyIdx);
                    logWrite("[%d] Killed by Player at (%d,%d) => Active: %d", enemyIdx, s_tEnemy[enemyIdx].tPosition.uwX, s_tEnemy[enemyIdx].tPosition.uwY, s_ubActiveEnemies);
                }
            }

            if (s_ubBossReached == TRUE) {
                for (UBYTE turretIdx=0; turretIdx<4; turretIdx++) {
                    if (s_tBossTurrets[turretIdx].ubAlive == FALSE) { continue; }

                    UBYTE ubCollision = checkCollision(uwX, uwY-bDeltaY, ubWidth, ubHeight, s_tBossTurrets[turretIdx].tHitboxPos.uwX, s_tBossTurrets[turretIdx].tHitboxPos.uwY, BOSS_HITBOX_WIDTH, BOSS_HITBOX_HEIGHT);
                    if (ubCollision == FALSE) { continue; }

                    // Damage turret
                    s_tBossTurrets[turretIdx].wHealth -= ubDamage;
                    s_tBossTurrets[turretIdx].ubFlashTimer = 5;

                    // Remove projectile?
                    if (ubDieOnCollision == TRUE) {
                        s_tPlayerProjectiles[projectileIdx].ubAlive = 0;
                    }
                }
            }
            #endif

            if (s_tPlayerProjectiles[projectileIdx].ubAlive == 0) {
                movePlayerProjectile(s_tPlayerProjectiles[projectileIdx].pCopBlock, -16, 0, ubHeight, PLAYER_SPRITE_CHANNEL_A, ubType);
                //movePlayerProjectile(s_tPlayerProjectiles[projectileIdx].pCopBlock, -16, -16, ubHeight, PLAYER_SPRITE_CHANNEL_A, ubType, FALSE);
                // if (ubHasSecondary) {
                //     movePlayerProjectile(s_tPlayerSecondaryProjectiles[projectileIdx].pCopBlock, -16, -16, ubHeight, PLAYER_SPRITE_CHANNEL_B, ubSecondarySpriteIndex, TRUE);
                // }
                continue;
            }

            UWORD uwScreenY = (uwY - s_pCamera->uPos.uwY);
            UWORD uwScreenX = (uwX - TILE_VIEWPORT_XMIN);

            movePlayerProjectile(s_tPlayerProjectiles[projectileIdx].pCopBlock, uwScreenX, uwScreenY, ubHeight, PLAYER_SPRITE_CHANNEL_A, ubType);
            //movePlayerProjectile(s_tPlayerProjectiles[projectileIdx].pCopBlock, uwScreenX, uwScreenY, ubHeight, PLAYER_SPRITE_CHANNEL_A, ubType, FALSE);

            // Secondary projectile
            // if (ubHasSecondary) {
            //     movePlayerProjectile(s_tPlayerSecondaryProjectiles[projectileIdx].pCopBlock, uwX2, uwScreenY, ubHeight, PLAYER_SPRITE_CHANNEL_B, ubSecondarySpriteIndex, TRUE);
            // }

            // Move projectile
            // if (bDeltaX != 0) {
            //     s_tPlayerProjectiles[projectileIdx].uwX += bDeltaX;
            //     //s_tPlayerSecondaryProjectiles[projectileIdx].uwX += bDeltaX2;
            // }

            s_tPlayerProjectiles[projectileIdx].uwY += bDeltaY;
        }
    }
}

static void processSimpleEnemyProjectiles() {
    UWORD uwCameraYMin = s_pCamera->uPos.uwY;
    UWORD uwCameraXMin = TILE_VIEWPORT_XMIN;
    UWORD uwCameraXMax = TILE_VIEWPORT_XMAX;
    s_ubProjectileBobIndex = 0;

    s_tSimpleChannelBounds[0] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};
    s_tSimpleChannelBounds[1] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};
    s_tSimpleChannelBounds[2] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};
    s_tSimpleChannelBounds[3] = (tSimpleChannelBounds){.uwMin = BOUNDS_MAX, .uwMax = BOUNDS_MIN};

    for (UBYTE projectileIdx=0; projectileIdx<ENEMY_PROJECTILE_MAX; projectileIdx++) {
        if (s_tSimpleEnemyProjectiles[projectileIdx].ubAlive == 0) { continue; }

        UBYTE ubEnemyProjectileType = s_tSimpleEnemyProjectiles[projectileIdx].ubType;
        UBYTE ubEnemyProjectileWidth = g_tEnemyProjectileTypes[ubEnemyProjectileType].ubWidth;
        UBYTE ubEnemyProjectileHeight = g_tEnemyProjectileTypes[ubEnemyProjectileType].ubHeight;
        UWORD uwCameraYMax = (s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT) - ubEnemyProjectileHeight;

        s_tSimpleEnemyProjectiles[projectileIdx].uwY += s_tSimpleEnemyProjectiles[projectileIdx].bDeltaY;
        s_tSimpleEnemyProjectiles[projectileIdx].ubAlive--;

        if (s_tSimpleEnemyProjectiles[projectileIdx].uwX < uwCameraXMin || s_tSimpleEnemyProjectiles[projectileIdx].uwX > uwCameraXMax) {
            s_tSimpleEnemyProjectiles[projectileIdx].ubAlive = 0;
        }

        if (s_tSimpleEnemyProjectiles[projectileIdx].uwY < uwCameraYMin || s_tSimpleEnemyProjectiles[projectileIdx].uwY > uwCameraYMax) {
            s_tSimpleEnemyProjectiles[projectileIdx].ubAlive = 0;
        }

        // Remove before collision detection.
        if (s_tSimpleEnemyProjectiles[projectileIdx].ubAlive == 0) {
            moveEnemyProjectile(s_tSimpleEnemyProjectiles[projectileIdx].pCopBlock, 0, -15, ubEnemyProjectileHeight+1, 0, s_tSimpleEnemyProjectiles[projectileIdx].ubType);
            s_tSimpleEnemyProjectiles[projectileIdx].ubChannel = 255;
            continue;
        }

        #ifndef COLLISIONS_DISABLED
        // Check collision with player.
        UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX+PLAYER_HITBOX_OFFSET_X, s_tPlayerPosition.uwY+PLAYER_HITBOX_OFFSET_Y, PLAYER_HITBOX_WIDTH, PLAYER_HITBOX_HEIGHT,
                                           s_tSimpleEnemyProjectiles[projectileIdx].uwX, s_tSimpleEnemyProjectiles[projectileIdx].uwY, ubEnemyProjectileWidth, ubEnemyProjectileHeight);
        if (ubCollision == TRUE && s_ubPlayerAlive == TRUE) {
            s_tComplexEnemyProjectiles[projectileIdx].ubAlive = 0;
            processPlayerDie();
        }
        #endif

        // Remove after collision detection.
        if (s_tSimpleEnemyProjectiles[projectileIdx].ubAlive == 0) {
            moveEnemyProjectile(s_tSimpleEnemyProjectiles[projectileIdx].pCopBlock, 0, -15, ubEnemyProjectileHeight+1, 0, s_tSimpleEnemyProjectiles[projectileIdx].ubType);
            s_tSimpleEnemyProjectiles[projectileIdx].ubChannel = 255;
            continue;
        }

        // Find an available sprite channel to use.
        s_tSimpleEnemyProjectiles[projectileIdx].ubChannel = 255;
        UWORD uwSpriteYMin = s_tSimpleEnemyProjectiles[projectileIdx].uwY;
        UWORD uwSpriteYMax = s_tSimpleEnemyProjectiles[projectileIdx].uwY + ubEnemyProjectileHeight;

        for (UBYTE channelIdx=0; channelIdx<ENEMY_SPRITE_CHANNELS; channelIdx++)
        {
            if(uwSpriteYMax < s_tSimpleChannelBounds[channelIdx].uwMin)
            {
                s_tSimpleEnemyProjectiles[projectileIdx].ubChannel = channelIdx;
                s_tSimpleChannelBounds[channelIdx].uwMin = uwSpriteYMin;
                if(s_tSimpleChannelBounds[channelIdx].uwMax <= BOUNDS_MIN) {
                    s_tSimpleChannelBounds[channelIdx].uwMax = uwSpriteYMax;
                }
                break;
            }
            else if (uwSpriteYMin > s_tSimpleChannelBounds[channelIdx].uwMax)
            {
                s_tSimpleEnemyProjectiles[projectileIdx].ubChannel = channelIdx;
                if(s_tSimpleChannelBounds[channelIdx].uwMin >= BOUNDS_MAX) {
                    s_tSimpleChannelBounds[channelIdx].uwMin = uwSpriteYMin;
                }
                s_tSimpleChannelBounds[channelIdx].uwMax = uwSpriteYMax;
                break;
            }
        }

        // Couldn't find a sprite channel. Check if a bob can be used.
        if (s_tSimpleEnemyProjectiles[projectileIdx].ubChannel == 255) {
            moveEnemyProjectile(s_tSimpleEnemyProjectiles[projectileIdx].pCopBlock, 0, -15, ubEnemyProjectileHeight+1, 0, s_tSimpleEnemyProjectiles[projectileIdx].ubType);

            if (s_ubProjectileBobIndex < ENEMY_SPRITE_CHANNELS) {
                s_tEnemyProjectileBob[s_ubProjectileBobIndex].sPos.uwX = s_tSimpleEnemyProjectiles[projectileIdx].uwX;
                s_tEnemyProjectileBob[s_ubProjectileBobIndex].sPos.uwY = s_tSimpleEnemyProjectiles[projectileIdx].uwY;
                s_ubEnemyProjectileBobTypes[s_ubProjectileBobIndex] = s_tSimpleEnemyProjectiles[projectileIdx].ubType;
                s_ubProjectileBobIndex++;
                continue;
            } else {
                s_tSimpleEnemyProjectiles[projectileIdx].ubAlive = 0;
                continue;
            }
        }

        // Move projectile.
        moveEnemyProjectile(s_tSimpleEnemyProjectiles[projectileIdx].pCopBlock,
                            (s_tSimpleEnemyProjectiles[projectileIdx].uwX - TILE_VIEWPORT_XMIN),
                            (s_tSimpleEnemyProjectiles[projectileIdx].uwY - s_pCamera->uPos.uwY),
                            ubEnemyProjectileHeight,
                            s_tSimpleEnemyProjectiles[projectileIdx].ubChannel,
                            ubEnemyProjectileType);
    }
}

static void processComplexEnemyProjectiles() {
    fix16_t fCameraYMin = fix16_from_int(s_pCamera->uPos.uwY);
    fix16_t fCameraXMin = s_fViewportXMin;
    fix16_t fCameraXMax = s_fViewportXMax;

    s_fComplexChannelBounds[0] = (tComplexChannelBounds){.fMin = fix16_from_int(s_tSimpleChannelBounds[0].uwMin), .fMax = fix16_from_int(s_tSimpleChannelBounds[0].uwMax)};
    s_fComplexChannelBounds[1] = (tComplexChannelBounds){.fMin = fix16_from_int(s_tSimpleChannelBounds[1].uwMin), .fMax = fix16_from_int(s_tSimpleChannelBounds[1].uwMax)};
    s_fComplexChannelBounds[2] = (tComplexChannelBounds){.fMin = fix16_from_int(s_tSimpleChannelBounds[2].uwMin), .fMax = fix16_from_int(s_tSimpleChannelBounds[2].uwMax)};
    s_fComplexChannelBounds[3] = (tComplexChannelBounds){.fMin = fix16_from_int(s_tSimpleChannelBounds[3].uwMin), .fMax = fix16_from_int(s_tSimpleChannelBounds[3].uwMax)};

    for (UBYTE projectileIdx=0; projectileIdx<ENEMY_PROJECTILE_MAX; projectileIdx++) {
        if (s_tComplexEnemyProjectiles[projectileIdx].ubAlive == 0 && s_tComplexEnemyProjectiles[projectileIdx].ubChannel != 255) {
            UBYTE ubEnemyProjectileType = s_tComplexEnemyProjectiles[projectileIdx].ubType;
            UBYTE ubEnemyProjectileHeight = g_tEnemyProjectileTypes[ubEnemyProjectileType].ubHeight;
            UBYTE ubChannel = s_tComplexEnemyProjectiles[projectileIdx].ubChannel;
            moveEnemyProjectile(s_tComplexEnemyProjectiles[projectileIdx].pCopBlock, -15, 0, ubEnemyProjectileHeight, ubChannel, ubEnemyProjectileType);
        }

        if (s_tComplexEnemyProjectiles[projectileIdx].ubAlive == 0) { continue; }

        UBYTE ubEnemyProjectileType = s_tComplexEnemyProjectiles[projectileIdx].ubType;
        UBYTE ubEnemyProjectileWidth = g_tEnemyProjectileTypes[ubEnemyProjectileType].ubWidth;
        UBYTE ubEnemyProjectileHeight = g_tEnemyProjectileTypes[ubEnemyProjectileType].ubHeight;

        s_tComplexEnemyProjectiles[projectileIdx].fX = fix16_add(s_tComplexEnemyProjectiles[projectileIdx].fX, s_tComplexEnemyProjectiles[projectileIdx].fDeltaX);
        s_tComplexEnemyProjectiles[projectileIdx].fY = fix16_add(s_tComplexEnemyProjectiles[projectileIdx].fY, s_tComplexEnemyProjectiles[projectileIdx].fDeltaY);
        s_tComplexEnemyProjectiles[projectileIdx].ubAlive--;

        fix16_t fCameraYMax = fix16_from_int((s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT)-ubEnemyProjectileHeight);

        // Check X bounds
        if (s_tComplexEnemyProjectiles[projectileIdx].fX < fCameraXMin || s_tComplexEnemyProjectiles[projectileIdx].fX > fCameraXMax)
        {
            s_tComplexEnemyProjectiles[projectileIdx].ubAlive = 0;
        }

        // Check Y bounds
        if (s_tComplexEnemyProjectiles[projectileIdx].fY < fCameraYMin || s_tComplexEnemyProjectiles[projectileIdx].fY > fCameraYMax)
        {
            s_tComplexEnemyProjectiles[projectileIdx].ubAlive = 0;
        }

        if (s_tComplexEnemyProjectiles[projectileIdx].ubAlive == 0) {
            moveEnemyProjectile(s_tComplexEnemyProjectiles[projectileIdx].pCopBlock, -15, 0, ubEnemyProjectileHeight, 0, ubEnemyProjectileType);
            s_tComplexEnemyProjectiles[projectileIdx].ubChannel = 255;
            continue;
        }

        #ifndef COLLISIONS_DISABLED
        // Check collision with player.
        UBYTE ubCollision = checkCollision(s_tPlayerPosition.uwX+PLAYER_HITBOX_OFFSET_X, s_tPlayerPosition.uwY+PLAYER_HITBOX_OFFSET_Y, PLAYER_HITBOX_WIDTH, PLAYER_HITBOX_HEIGHT,
                                           fix16_to_int(s_tComplexEnemyProjectiles[projectileIdx].fX), fix16_to_int(s_tComplexEnemyProjectiles[projectileIdx].fY), ubEnemyProjectileWidth, ubEnemyProjectileHeight);
        if (ubCollision == TRUE && s_ubPlayerAlive == TRUE) {
            s_tComplexEnemyProjectiles[projectileIdx].ubAlive = 0;
            s_tComplexEnemyProjectiles[projectileIdx].ubChannel = 255;
            moveEnemyProjectile(s_tComplexEnemyProjectiles[projectileIdx].pCopBlock, -15, 0, ubEnemyProjectileHeight, 0, ubEnemyProjectileType);
            processPlayerDie();
            continue;
        }
        #endif

        s_tComplexEnemyProjectiles[projectileIdx].ubChannel = 255;
        fix16_t fSpriteYMin = s_tComplexEnemyProjectiles[projectileIdx].fY;
        fix16_t fSpriteYMax = fix16_add(fSpriteYMin, fix16_from_int(ubEnemyProjectileHeight));

        for (UBYTE channelIdx=0; channelIdx<ENEMY_SPRITE_CHANNELS; channelIdx++)
        {
            if(fSpriteYMax < s_fComplexChannelBounds[channelIdx].fMin)
            {
                // logWrite("before %d: %ld < %ld", channelIdx, fSpriteYMax, fChannelY);
                s_tComplexEnemyProjectiles[projectileIdx].ubChannel = channelIdx;
                s_fComplexChannelBounds[channelIdx].fMin = fSpriteYMin;
                if(s_fComplexChannelBounds[channelIdx].fMax == s_fBoundsMin) {
                    s_fComplexChannelBounds[channelIdx].fMax = fSpriteYMax;
                }
                break;
            }
            else if (fSpriteYMin > s_fComplexChannelBounds[channelIdx].fMax)
            {
                // logWrite("after %d: %ld > %ld", channelIdx, fSpriteY, fChannelYMax);
                s_tComplexEnemyProjectiles[projectileIdx].ubChannel = channelIdx;
                if(s_fComplexChannelBounds[channelIdx].fMin == s_fBoundsMax) {
                    s_fComplexChannelBounds[channelIdx].fMin = fSpriteYMin;
                }
                s_fComplexChannelBounds[channelIdx].fMax = fSpriteYMax;
                break;
            }
        }

        if (s_tComplexEnemyProjectiles[projectileIdx].ubChannel == 255) {
            moveEnemyProjectile(s_tComplexEnemyProjectiles[projectileIdx].pCopBlock, -16, -16, ubEnemyProjectileHeight, 0, ubEnemyProjectileType);

            if (s_ubProjectileBobIndex < ENEMY_BOB_CHANNELS) {
                s_tEnemyProjectileBob[s_ubProjectileBobIndex].sPos.uwX = fix16_to_int(s_tComplexEnemyProjectiles[projectileIdx].fX);
                s_tEnemyProjectileBob[s_ubProjectileBobIndex].sPos.uwY = fix16_to_int(s_tComplexEnemyProjectiles[projectileIdx].fY);
                s_ubProjectileBobIndex++;
                continue;
            } else {
                s_tComplexEnemyProjectiles[projectileIdx].ubAlive = 0;
                continue;
            }
        }

        moveEnemyProjectile(s_tComplexEnemyProjectiles[projectileIdx].pCopBlock,
                            (fix16_to_int(s_tComplexEnemyProjectiles[projectileIdx].fX) - TILE_VIEWPORT_XMIN),
                            (fix16_to_int(s_tComplexEnemyProjectiles[projectileIdx].fY) - s_pCamera->uPos.uwY),
                            ubEnemyProjectileHeight,
                            s_tComplexEnemyProjectiles[projectileIdx].ubChannel,
                            ubEnemyProjectileType);
    }
}

// Utility functions.

static void movePlayerProjectile(tCopBlock *pBlock, WORD wX, WORD wY, UWORD uwHeight, UBYTE ubChannel, UBYTE ubType) {
    UWORD uwVStart = s_pView->ubPosY + wY;
    UWORD uwVStop = uwVStart + uwHeight;
    UWORD uwHStart = (s_pView->ubPosX - 1) + wX;

    UWORD uwPos = ((uwVStart << 8) | ((uwHStart) >> 1));
    UWORD uwCtl = (UWORD) (
        (uwVStop << 8) |
        (0 << 7) |
        (BTST(uwVStart, 8) << 2) |
        (BTST(uwVStop, 8) << 1) |
        BTST(uwHStart, 0)
    );

    copBlockWait(s_pView->pCopList, pBlock, 0, s_pView->ubPosY + wY);

    pBlock->uwCurrCount = 0;
    ULONG ulAddr = 0;
    ulAddr = (ULONG)(
        (UBYTE*)s_pPlayerProjectileSprites[ubType]->pBitmap->Planes[0] +
        sizeof(g_pCustom->spr[ubChannel].pos) +
        sizeof(g_pCustom->spr[ubChannel].ctl)
    ); // skip the control words

    copMove(s_pView->pCopList, pBlock, &g_pSprFetch[ubChannel].uwHi, ulAddr >> 16);
    copMove(s_pView->pCopList, pBlock, &g_pSprFetch[ubChannel].uwLo, ulAddr & 0xFFFF);
    copMove(s_pView->pCopList, pBlock, &g_pCustom->spr[ubChannel].pos, uwPos);
    copMove(s_pView->pCopList, pBlock, &g_pCustom->spr[ubChannel].ctl, uwCtl);
}

static void moveEnemyProjectile(tCopBlock *pBlock, WORD wX, WORD wY, UWORD uwHeight, UBYTE ubChannel, UBYTE ubType) {
    UWORD uwVStart = s_pView->ubPosY + wY;
    UWORD uwVStop = uwVStart + uwHeight;
    UWORD uwHStart = (s_pView->ubPosX - 1) + wX;
    //UWORD uwHStart = 128 + wX;

    UWORD uwPos = ((uwVStart << 8) | ((uwHStart) >> 1));
    UWORD uwCtl = (UWORD) (
        (uwVStop << 8) |
        (0 << 7) |
        (BTST(uwVStart, 8) << 2) |
        (BTST(uwVStop, 8) << 1) |
        BTST(uwHStart, 0)
    );

    copBlockWait(s_pView->pCopList, pBlock, 0, s_pView->ubPosY + wY);

    pBlock->uwCurrCount = 0;
    ULONG ulAddr = (ULONG)(
        (UBYTE*)s_pEnemyProjectileSprite[ubType]->pBitmap->Planes[0] +
        sizeof(g_pCustom->spr[ubChannel].pos) +
        sizeof(g_pCustom->spr[ubChannel].ctl)
    ); // skip the control words

    copMove(s_pView->pCopList, pBlock, &g_pSprFetch[ubChannel].uwHi, ulAddr >> 16);
    copMove(s_pView->pCopList, pBlock, &g_pSprFetch[ubChannel].uwLo, ulAddr & 0xFFFF);
    copMove(s_pView->pCopList, pBlock, &g_pCustom->spr[ubChannel].pos, uwPos);
    copMove(s_pView->pCopList, pBlock, &g_pCustom->spr[ubChannel].ctl, uwCtl);
}

static void destroyEnemy(UBYTE ubEnemyIdx) {
    UBYTE ubEnemyType = s_tEnemy[ubEnemyIdx].ubEnemyType;
    s_tEnemy[ubEnemyIdx].wHealth = 0;

    if (ubEnemyType != ENEMY_BIG_TYPE) {
        createExplosionAtPosition(s_tEnemy[ubEnemyIdx].tPosition);
    } else {
        if (s_ubBigExplosionActive == FALSE) {
            s_tBigExplosionBob.sPos = s_tEnemy[ubEnemyIdx].tPosition;
            s_ubBigExplosionActive = TRUE;
            s_ubBigExplosionFrame = 0;
        }

        audioMixerPlaySfx(s_pSfxExplosion, CHANNEL_FOR_EXPLOSION, 10, 0);
    }

    if (s_tEnemy[ubEnemyIdx].ubPowerupType > 0) {
        createPowerupAtPosition(s_tEnemy[ubEnemyIdx].tPosition, s_tEnemy[ubEnemyIdx].ubPowerupType);
    }

    if (g_ubLoopIteration == 0) {
        s_ulPlayerScore += s_tEnemy[ubEnemyIdx].uwScoreValue;
    } else {
        s_ulPlayerScore += (s_tEnemy[ubEnemyIdx].uwScoreValue * (g_ubLoopIteration+1));
    }

    s_ubUpdateScore = TRUE;
    s_ubActiveEnemies--;
    s_uwPlayerKills++;
}

static void destroyBossTurret(UBYTE ubTurret) {
    createExplosionAtPosition(s_tBossTurrets[ubTurret].tExplosionPosition);
    s_ulPlayerScore += BOSS_TURRET_SCORE;
    s_ubUpdateScore = TRUE;
    s_tBossTurrets[ubTurret].ubAlive = FALSE;
    s_ubBossTurretsAlive--;
    if (s_ubBossTurretsAlive == 2) {
        s_ubEnemyProjectileSpeed = 3;
    }
}

static void createPowerupAtPosition(tUwCoordYX tPosition, UBYTE ubPowerupType) {
    if (s_ubLifePowActive == TRUE || s_ubSpecialPowActive == TRUE || s_ubWeaponPowActive == TRUE) { return; } // Only one active powerups at a time.

    if (g_ubLoopIteration > 0 && ubPowerupType == POWERUP_EXTRALIFE) { return; } // No extra lives on loops.

    switch (ubPowerupType) {
        case POWERUP_EXTRALIFE: {
            s_tLifePowBob.sPos = tPosition;
            s_ubLifePowActive = TRUE;
            s_ubPowerupBounceTimer = POWERUP_BOUNCE_TIME;
            break;
        }
        case POWERUP_SPECIAL: {
            s_tSpecialPowBob.sPos = tPosition;
            s_ubSpecialPowActive = TRUE;
            s_ubPowerupBounceTimer = POWERUP_BOUNCE_TIME;
            break;
        }
        case POWERUP_WEAPON: {
            s_tWeaponPowBob.sPos = tPosition;
            s_ubWeaponPowActive = TRUE;
            s_ubPowerupBounceTimer = POWERUP_BOUNCE_TIME;
            break;
        }
    }
}

static void createExplosionAtPosition(tUwCoordYX tPosition) {
    if (s_ubActiveExplosions < EXPLOSIONS_MAX) {
        UWORD uwCameraYMin = s_pCamera->uPos.uwY;
        UWORD uwCameraYMax = s_pCamera->uPos.uwY+TILE_VIEWPORT_HEIGHT;
        UWORD uwCameraXMin = TILE_VIEWPORT_XMIN;
        UWORD uwCameraXMax = TILE_VIEWPORT_XMAX;

        // Check X bounds
        if ((tPosition.uwX+EXPLOSION_WIDTH) < uwCameraXMin || tPosition.uwX > uwCameraXMax) { return; }

        // Check Y bounds
        if (tPosition.uwY+8 < uwCameraYMin || tPosition.uwY >= uwCameraYMax) { return; }

        for (UBYTE explosionIdx=0; explosionIdx < EXPLOSIONS_MAX; explosionIdx++) {
            if (s_tExplosions[explosionIdx].ubAlive != 0) { continue; }
            s_tExplosions[explosionIdx].sBob.sPos = tPosition;
            s_tExplosions[explosionIdx].ubAlive = 1;
            s_tExplosions[explosionIdx].ubFrameIndex = 0;
            s_ubActiveExplosions++;
            audioMixerPlaySfx(s_pSfxExplosion, CHANNEL_FOR_EXPLOSION, 8, 0);
            break;
        }
    }
}

static UBYTE checkCollision(WORD x1, WORD y1, UBYTE w1, UBYTE h1, WORD x2, WORD y2, UBYTE w2, UBYTE h2) {
    return x1 < x2+w2 && x1+w1 > x2 && y1 < y2+h2 && y1+h1 > y2;
}

static void onTileDraw(UNUSED_ARG UWORD uwTileX, UNUSED_ARG UWORD uwTileY, tBitMap *pBitMap, UWORD uwBitMapX, UWORD uwBitMapY) {
    blitCopyAligned(
        pBitMap, uwBitMapX, uwBitMapY,
        s_pPristineBuffer, uwBitMapX, uwBitMapY,
        1 << 4, 1 << 4
    );
}

static void resetEverything() {
    s_ubDimLevel = 0;
    s_ubFadeOut = FALSE;
    s_ubFrameCounter = 0;
    s_ubFlashTimer = 0;
    s_ubFlashOn = FALSE;
    s_ubLevelStart = TRUE;
    s_ubLevelStartTimer = 128;
    s_ubLevelEnd = FALSE;
    s_ubLevelEndReached = FALSE;
    s_ubLevelEndTimer = 255;
    s_ubCameraCanMove = FALSE;
    s_ubMoveCameraCounter = 0;
    s_ulPlayerScore = 0;
    s_ubPlayerLives = 0;
    s_ubPlayerSpecial = 0;
    s_uwPlayerKills = 0;
    s_ubPlayerDeaths = 0;
    s_ubUpdateScore = TRUE;
    s_ubUpdatePower = TRUE;
    s_ubUpdateLives = TRUE;
    s_ubUpdateSpecial = TRUE;
    s_ubEngineAnimFrame = 0;
    s_ubPlayerExplosionAnimFrame = 0;
    s_ubPlayerExplosionActive = FALSE;
    s_ubFireDelay = 0;
    s_ubSpecialDelay = 0;
    s_ubAudioDelay = 0;
    s_ubEquippedProjectileType = 0;
    s_ubPlayerAlive = FALSE;
    s_ubPlayerMovedLeft = FALSE;
    s_ubPlayerMovedRight = FALSE;
    s_ubPlayerMovedOnY = FALSE;
    s_ubDisplayPlayer = TRUE;
    s_ubDisplayEngine = TRUE;
    s_ubPlayerIsInvincible = FALSE;
    s_ubPlayerInvincibleTimer = 0;
    s_uwWaveIndex = 0;
    s_ubActiveEnemies = 0;
    s_ubBigEnemyAlive = FALSE;
    s_ubActiveExplosions = 0;
    s_ubBigExplosionActive = FALSE;
    s_ubBigExplosionFrame = 0;
    s_ubLifePowActive = FALSE;
    s_ubSpecialPowActive = FALSE;
    s_ubWeaponPowActive = FALSE;
    s_ubShowTextGameOver = FALSE;
    s_ubShowTextGameOverTimer = 255;
    s_ubShowTextReady = FALSE;
    s_ubShowTextGo = FALSE;
    s_ubCyclicRngIdx = 0;
    s_ubBossReached = FALSE;
    s_ubBossFirstShot = TRUE;
    s_ubBossShotAlive = FALSE;
    s_uwBossShotTimer = BOSS_SHOT_TIME;
    s_ubBossTurretsAlive = 4;
    s_ubBossDefeated = FALSE;
    s_ubBossExplosionIdx = 0;

    for (UBYTE i=0; i<ENEMY_MAX; i++) {
        s_tEnemy[i].wHealth = 0;
    }

    for (UBYTE i=0; i<PLAYER_PROJECTILE_MAX; i++) {
        s_tPlayerProjectiles[i].ubAlive = 0;
    }

    for (UBYTE i=0; i<ENEMY_PROJECTILE_MAX; i++) {
        s_tSimpleEnemyProjectiles[i].ubAlive = 0;
        s_tComplexEnemyProjectiles[i].ubAlive = 0;
    }
}