#include "main.h"

#define EXPLOSIONS_MAX 8
#define EXPLOSION_WIDTH 16
#define EXPLOSION_HEIGHT 16
#define BIGEXPLOSION_WIDTH 32
#define BIGEXPLOSION_HEIGHT 32
#define EXPLOSION_ANIM_FRAMES 16
#define BIGEXPLOSION_ANIM_FRAMES 24

typedef struct _tExplosion {
    tBob sBob;
    UBYTE ubFrameIndex;
    UBYTE ubAlive;
} tExplosion;