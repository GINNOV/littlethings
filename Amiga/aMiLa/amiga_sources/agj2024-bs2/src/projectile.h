#include "main.h"

#define PLAYER_PROJECTILE_MAX 5
#define PLAYER_PROJECTILE_TYPES 4
#define PLAYER_SECONDARY_PROJECTILE_TYPES 0

#define PLAYER_SPRITE_CHANNEL_A 4
#define PLAYER_SPRITE_CHANNEL_B 5

#define ENEMY_PROJECTILE_MAX 6
#define ENEMY_PROJECTILE_TYPES 4
#define ENEMY_SIMPLEPROJECTILE_SPEED 3
#define ENEMY_SIMPLEPROJECTILE_HEIGHT 6

#define ENEMY_BOB_CHANNELS 2
#define ENEMY_SPRITE_CHANNELS 4

typedef struct tComplexChannelBounds {
    fix16_t fMin;
    fix16_t fMax;
} tComplexChannelBounds;

typedef struct tSimpleChannelBounds {
    UWORD uwMin;
    UWORD uwMax;
} tSimpleChannelBounds;

typedef struct _tPlayerProjectile {
    tCopBlock *pCopBlock;
    UWORD uwX, uwY;
    UBYTE ubAlive;
    UBYTE ubType;
} tPlayerProjectile;

typedef struct _tPlayerSecondaryProjectile {
    tCopBlock *pCopBlock;
    UWORD uwX;
    UBYTE ubType;
} tPlayerSecondaryProjectile;

typedef struct _tPlayerProjectileType {
    UBYTE ubDamage;
    UBYTE ubDelay;
    BYTE bDeltaX, bDeltaX2, bDeltaY;
    UBYTE ubXOffset, ubXOffset2;
    UBYTE ubWidth, ubHeight;
    UBYTE ubDieOnCollision;
    UBYTE ubWideSprite, ubSpreadShot;
    UBYTE ubSecondarySpriteIndex;
} tPlayerProjectileType;

typedef struct _tEnemyProjectileType {
    UBYTE ubWidth, ubHeight;
    UBYTE ubOffset;
    BYTE bSpeed;
} tEnemyProjectileType;

typedef struct _tComplexEnemyProjectile {
    tCopBlock *pCopBlock;
    fix16_t fX, fY;
    fix16_t fDeltaX, fDeltaY;
    UBYTE ubAlive;
    UBYTE ubChannel;
    UBYTE ubType;    
} tComplexEnemyProjectile;

typedef struct _tSimpleEnemyProjectile {
    tCopBlock *pCopBlock;
    UWORD uwX, uwY;
    BYTE bDeltaX, bDeltaY;
    UBYTE ubAlive;
    UBYTE ubChannel;
    UBYTE ubType;
} tSimpleEnemyProjectile;

// Enemy projectile types
tEnemyProjectileType g_tEnemyProjectileTypes[ENEMY_PROJECTILE_TYPES] = {{ .ubWidth = 10, .ubHeight =  5, .ubOffset = 0, .bSpeed = 2},
                                                                        { .ubWidth =  5, .ubHeight =  5, .ubOffset = 2, .bSpeed = 2},
                                                                        { .ubWidth =  8, .ubHeight =  8, .ubOffset = 4, .bSpeed = 1},
                                                                        { .ubWidth = 14, .ubHeight = 14, .ubOffset = 7, .bSpeed = 1}};

// Player projectile types
tPlayerProjectileType g_tPlayerProjectileTypes[PLAYER_PROJECTILE_TYPES] = {{ .ubDamage = 30, .ubDelay = 12, .bDeltaX = 0, .bDeltaX2 = 0, .bDeltaY = -6, .ubXOffset = 4, .ubXOffset2 = 0, .ubWidth =  8, .ubHeight =  7, .ubDieOnCollision =  TRUE, .ubWideSprite = FALSE, .ubSpreadShot = FALSE, .ubSecondarySpriteIndex = 0 },
                                                                           { .ubDamage = 20, .ubDelay = 10, .bDeltaX = 0, .bDeltaX2 = 0, .bDeltaY = -6, .ubXOffset = 4, .ubXOffset2 = 0, .ubWidth =  8, .ubHeight = 10, .ubDieOnCollision =  TRUE, .ubWideSprite = FALSE, .ubSpreadShot = FALSE, .ubSecondarySpriteIndex = 0 },
                                                                           { .ubDamage = 10, .ubDelay =  8, .bDeltaX = 0, .bDeltaX2 = 0, .bDeltaY = -7, .ubXOffset = 3, .ubXOffset2 = 0, .ubWidth = 10, .ubHeight = 12, .ubDieOnCollision = FALSE, .ubWideSprite = FALSE, .ubSpreadShot = FALSE, .ubSecondarySpriteIndex = 0 },
                                                                           { .ubDamage = 12, .ubDelay =  6, .bDeltaX = 0, .bDeltaX2 = 0, .bDeltaY = -8, .ubXOffset = 2, .ubXOffset2 = 0, .ubWidth = 12, .ubHeight = 16, .ubDieOnCollision =  TRUE, .ubWideSprite = FALSE, .ubSpreadShot = FALSE, .ubSecondarySpriteIndex = 0 }};