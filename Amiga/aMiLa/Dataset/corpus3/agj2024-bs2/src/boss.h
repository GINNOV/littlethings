#include "main.h"

#define BOSS_TURRET_HEALTH 300
#define BOSS_HITBOX_WIDTH 12
#define BOSS_HITBOX_HEIGHT 12
#define BOSS_EXPLOSION_OFFSET_X 4
#define BOSS_EXPLOSION_OFFSET_Y 4
#define BOSS_COOLDOWN_TIME 60
#define BOSS_SHOT_TIME 250
#define BOSS_SHOT_Y_CUTOFF 992
#define BOSS_TURRET_SCORE 68000
#define BOSS_EXPLOSION_POSITIONS 12

typedef struct _tBossTurret {
    UWORD uwBitmapOffset;
    UBYTE ubHeight;
    tBob sFlashBob;
    UBYTE ubFlashTimer;
    UBYTE ubCooldownTimer;
    WORD wHealth;
    UBYTE ubAlive;
    tUwCoordYX tBitmapPos;
    tUwCoordYX tFlashPos;
    tUwCoordYX tHitboxPos;
    tUwCoordYX tExplosionPosition;
} tBossTurret;

UWORD g_uwSmallExplosionPositions[] = {18,116,124,109,78,129,98,154,53,99,156,111,98,133,29,107,118,96,146,117,72,150,61,110};

// UBYTE ubTilePosForBossTurret1[] = {6,2,7,1,7,2,8,1,8,2};
// UBYTE ubDamageTilesForTurret1[] = {2,9,10,17,18};

// UBYTE ubTilePosForBossTurret2[] = {6,3,6,4,7,3,7,4};
// UBYTE ubDamageTilesForTurret2[] = {3,4,11,12};

// UBYTE ubTilePosForBossTurret3[] = {6,7,6,8,7,7,7,8};
// UBYTE ubDamageTilesForTurret3[] = {5,6,13,14};

// UBYTE ubTilePosForBossTurret4[] = {6,9,7,9,7,10,8,9,8,10};
// UBYTE ubDamageTilesForTurret4[] = {7,15,16,19,20};