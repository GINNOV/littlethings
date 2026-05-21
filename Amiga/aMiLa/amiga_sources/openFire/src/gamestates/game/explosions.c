#include "gamestates/game/explosions.h"
#include "gamestates/game/bob_new.h"

#define EXPLOSION_FRAME_COUNT 6
#define EXPLOSION_FRAME_LENGTH 4
#define EXPLOSION_DURATION (EXPLOSION_FRAME_COUNT * EXPLOSION_FRAME_LENGTH)
#define EXPLOSION_SIZE 32

typedef struct _tExplosion {
	tBobNew sBob;
	UWORD uwDuration;
} tExplosion;

static tExplosion s_pExplosions[EXPLOSIONS_MAX];
static tBitMap *s_pBitmap;
static tBitMap *s_pMask;

void explosionsAdd(UWORD uwX, UWORD uwY) {
	// Find free explosion slot
	for(UWORD i = EXPLOSIONS_MAX; i--;) {
		if(s_pExplosions[i].uwDuration >= EXPLOSION_DURATION) {
			// Free slot found - setup explosion
			s_pExplosions[i].sBob.sPos.sUwCoord.uwX = uwX - EXPLOSION_SIZE/2;
			s_pExplosions[i].sBob.sPos.sUwCoord.uwY = uwY - EXPLOSION_SIZE/2;
			s_pExplosions[i].uwDuration = 0;
			return;
		}
	}
}

void explosionsCreate(void) {
	logBlockBegin("explosionsCreate()");
	s_pBitmap = bitmapCreateFromFile("data/explosion.bm");
	s_pMask = bitmapCreateFromFile("data/explosion_mask.bm");

	for(UBYTE i = EXPLOSIONS_MAX; i--;) {
		bobNewInit(&s_pExplosions[i].sBob, 32, 32, 1, s_pBitmap, s_pMask, 0, 0);
		s_pExplosions[i].uwDuration = EXPLOSION_DURATION;
	}

	logBlockEnd("explosionsCreate()");
}

void explosionsDestroy(void) {
	logBlockBegin("explosionsDestroy()");
	bitmapDestroy(s_pBitmap);
	bitmapDestroy(s_pMask);
	logBlockEnd("explosionsDestroy()");
}

void explosionsProcess(void) {
	for(UBYTE i = 0; i < EXPLOSIONS_MAX; ++i) {
		if(s_pExplosions[i].uwDuration < EXPLOSION_DURATION) {
			bobNewSetBitMapOffset(
				&s_pExplosions[i].sBob,
				s_pExplosions[i].uwDuration/EXPLOSION_FRAME_LENGTH * EXPLOSION_SIZE
			);
			bobNewPush(&s_pExplosions[i].sBob);
			++s_pExplosions[i].uwDuration;
		}
	}
}
