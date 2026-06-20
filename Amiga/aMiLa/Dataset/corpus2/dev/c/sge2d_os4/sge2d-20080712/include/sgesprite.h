#ifndef _SGESPRITE_H
#define _SGESPRITE_H

typedef struct {
	int x;
	int y;
} SGESPRITEWAYPOINT;

typedef struct {
	int x;
	int y;
	Uint32 currentFrame;
	Uint32 lastFrame;
	Uint32 framesPerSecond;
	SGEARRAY *sprite;
	SGEARRAY *bankSize;
	Uint32 isMoving;
	SGEARRAY *wayPoints;
	float fX, fY;
	float dirX, dirY;
	float moveSpeed;
	int initMove;
	void *userData;
	int initialized;
	int numberOfBanks;
	int currentBank;
	int animate;
} SGESPRITE;

SGESPRITE *sgeSpriteNew(void);
SGESPRITE *sgeSpriteNewFile(SGEFILE *f, const char *filename);
SGESPRITE *sgeSpriteNewFileRange(SGEFILE *f, const char *template, Uint32 start, Uint32 end);
void sgeSpriteDestroy(SGESPRITE *s);

SGESPRITEIMAGE *sgeSpriteGetCurrentFrame(SGESPRITE *s);
void sgeSpriteSetFPS(SGESPRITE *s, Uint32 fps);
void sgeSpriteAddSpriteImage(SGESPRITE *s, SGESPRITEIMAGE *i);
void sgeSpriteAddFile(SGESPRITE *s, SGEFILE *f, const char *name);
void sgeSpriteAddFileRange(SGESPRITE *s, SGEFILE *f, const char *template, Uint32 start, Uint32 end);
void sgeSpriteDraw(SGESPRITE *s, SDL_Surface *dest);
void sgeSpriteDrawXY(SGESPRITE *s, int x, int y, SDL_Surface *dest);
inline void sgeSpriteDrawRotoZoomed(SGESPRITE *s, float rotation, float zoom, SDL_Surface *dest);
inline void sgeSpriteDrawXYRotoZoomed(SGESPRITE *s, int x, int y, float rotation, float zoom, SDL_Surface *dest);
void sgeAnimatedspriteUseAlpha(SGESPRITE *s);
void sgeSpriteIgnoreAlpha(SGESPRITE *s);
void sgeSpriteIgnoreAlpha(SGESPRITE *s);
int sgeSpriteBoxCollide(SGESPRITE *a, SGESPRITE *b);
int sgeSpriteCollide(SGESPRITE *a, SGESPRITE *b);
int sgeSpriteBoxCollideSpriteImage(SGESPRITE *a, SGESPRITEIMAGE *b);
int sgeSpriteCollideSpriteImage(SGESPRITE *a, SGESPRITEIMAGE *b);
int sgeSpriteWidth(SGESPRITE *s);
int sgeSpriteHeight(SGESPRITE *s);
void sgeSpriteAddWayPoint(SGESPRITE *s, int x, int y);
void sgeSpriteRemoveNextWayPoint(SGESPRITE *s);
void sgeSpriteClearWayPoints(SGESPRITE *s);
void sgeSpriteStartMovement(SGESPRITE *s, float speed);
void sgeSpriteAbortMovement(SGESPRITE *s);
void sgeSpriteMoveTowards(SGESPRITE *s, int x, int y);
void sgeSpriteSetUserData(SGESPRITE *s, void *data);
void *sgeSpriteGetUserData(SGESPRITE *s);
inline void sgeSpriteUpdatePosition(SGESPRITE *s);
void sgeSpriteUpdate(SGESPRITE *s);
inline Uint32 sgeSpriteGetNumberOfFrames(SGESPRITE *s);
inline void sgeSpriteSetNumberOfFrames(SGESPRITE *s, Uint32 number);
inline SGEARRAY *sgeSpriteGetCurrentSpriteArray(SGESPRITE *s);
inline void sgeSpriteSetAnimBank(SGESPRITE *s, Uint32 bank);
void sgeSpriteAddAnimBank(SGESPRITE *s);
Uint32 sgeSpriteGetAnimBank(SGESPRITE *s);
void sgeSpriteAnimate(SGESPRITE *s, int state);
void sgeSpriteResetAnimation(SGESPRITE *s);
inline void sgeSpriteForceFrame(SGESPRITE *s, Uint32 frame);

#endif
