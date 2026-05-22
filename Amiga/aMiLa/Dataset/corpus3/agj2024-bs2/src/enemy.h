#include "main.h"

#define ENEMY_TYPES 14
#define ENEMY_BIG_TYPE 12
#define ENEMY_TURRET_TYPE 13
#define ENEMY_MAX 8
#define ENEMY_INVINCIBLE_MARGIN 4

typedef struct _tEnemy {
    tUwCoordYX tPosition;
    tBob sBob;
    WORD wHealth;
    UBYTE ubOnScreen;
    UBYTE ubInvincible;
    UBYTE ubFlashTimer;
    UBYTE ubCanShoot;    
    UBYTE ubCooldownTimer;
    UBYTE ubBitmapOffset;
    UBYTE ubEnemyType;
    UBYTE ubPowerupType;
    UBYTE ubMoveSpeed; // MUST BE MULTIPLE OF 2
    UWORD uwPathArrayOffset;
    UWORD uwPathIdx;
    UWORD uwPathLength;
    UWORD uwPathYOffset;
    UWORD uwScoreValue;
} tEnemy;

typedef struct _tEnemyType {
    WORD wHealth;
    UBYTE ubWidth, ubHeight;
    UBYTE ubGunOffsetX, ubGunOffsetY;
    UBYTE ubBitmapOffset;
    UBYTE ubMoveSpeed; // MUST BE MULTIPLE OF 2 
    UBYTE ubCanShoot;
    UBYTE ubCooldownTime;
    UBYTE ubProjectileType;
    UBYTE ubPowerupType;
    UWORD uwScoreValue;
} tEnemyType;

typedef struct _tEnemyWave {
    UBYTE ubEnemyType;
    UWORD uwSpawnYPosition;
    BYTE bSpawnOffset;
    UBYTE ubPathType;
} tEnemyWave;

// Enemy types.
tEnemyType g_tEnemyTypes[ENEMY_TYPES] = {// Type 1
                                         { 10, 16, 16,  3, 15, 0, 4, FALSE,   0, 0, 0, 1337},  // No shot
                                         { 20, 16, 16,  3, 15, 1, 4,  TRUE,  80, 0, 0, 1337},  // Simple shot
                                         { 20, 16, 16,  3, 15, 1, 4,  TRUE,  90, 1, 0, 1337},  // Aimed shot
                                         { 20, 16, 16,  3, 15, 2, 4,  TRUE,  70, 1, 3, 1987},  // Aimed shot & Drops powerup

                                         // Type 2
                                         { 10, 16, 16,  3, 15, 3, 4, FALSE,   0, 0, 0, 1337},  // No shot
                                         { 20, 16, 16,  3, 15, 4, 4,  TRUE,  80, 0, 0, 1337},  // Simple shot
                                         { 30, 16, 16,  3, 15, 4, 4,  TRUE,  90, 1, 0, 1337},  // Aimed shot
                                         { 30, 16, 16,  3, 15, 5, 4,  TRUE,  70, 1, 1, 1987},  // Aimed shot & Drops 1up

                                         // Type 3
                                         { 20, 16, 16,  3, 15, 6, 2, FALSE,   0, 0, 0, 1337},  // No shot
                                         { 30, 16, 16,  3, 15, 7, 2,  TRUE,  90, 0, 0, 1337},  // Simple shot
                                         { 30, 16, 16,  3, 15, 7, 2,  TRUE, 120, 1, 0, 1337},  // Aimed shot
                                         { 40, 16, 16,  3, 15, 8, 2,  TRUE,  80, 1, 2, 1987},  // Aimed shot & Drops Special

                                         // Tank
                                         {200, 32, 32, 16, 16, 0, 2,  TRUE,  80, 2, 0, 2600},  // Aimed shot
                                         
                                         // Turret
                                         { 64, 16, 16,  8,  8, 9, 0,  TRUE,  70, 1, 0, 6502}}; // Aimed shot
