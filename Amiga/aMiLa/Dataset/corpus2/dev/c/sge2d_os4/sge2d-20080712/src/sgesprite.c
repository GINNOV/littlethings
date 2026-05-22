#include <sge.h>

SGESPRITE *sgeSpriteNew() {
	SGESPRITE *ret;
	sgeNew(ret, SGESPRITE);
	ret->x=0;
	ret->y=0;
	ret->currentFrame=0;
	sgeSpriteSetFPS(ret, 15);
	ret->sprite=sgeArrayNew();
	sgeArrayAdd(ret->sprite, sgeArrayNew());
	ret->bankSize=sgeArrayNew();
	sgeArrayAdd(ret->bankSize, 0);
	ret->isMoving=0;
	ret->initMove=1;
	ret->wayPoints=sgeArrayNew();
	ret->fX=0;
	ret->fY=0;
	ret->dirX=0;
	ret->dirY=0;
	ret->moveSpeed=1.0;
	ret->userData=NULL;
	ret->initialized=0;
	ret->numberOfBanks=1;
	ret->currentBank=0;
	ret->animate=YES;
	return ret;
}

SGESPRITE *sgeSpriteNewFile(SGEFILE *f, const char *filename) {
	SGESPRITE *ret=sgeSpriteNew();
	sgeSpriteAddFile(ret, f, filename);
	return ret;
}

SGESPRITE *sgeSpriteNewFileRange(SGEFILE *f, const char *template, Uint32 start, Uint32 end) {
	SGESPRITE *ret=sgeSpriteNew();
	sgeSpriteAddFileRange(ret, f, template, start, end);
	return ret;
}

void sgeSpriteDestroy(SGESPRITE *s) {
	int i,n;
	SGEARRAY *cur;

	for (n=s->numberOfBanks-1;n>-1;n--) {
		sgeSpriteSetAnimBank(s,n);
		cur=sgeSpriteGetCurrentSpriteArray(s);
		for (i=0;i<sgeSpriteGetNumberOfFrames(s);i++) {
			sgeSpriteImageDestroy(sgeArrayGet(cur,0));
			sgeArrayRemove(cur,0);
		}
		sgeArrayDestroy(cur);
		sgeArrayRemove(s->sprite,n);
		sgeArrayRemove(s->bankSize,n);
	}
	sgeArrayDestroy(s->sprite);
	sgeArrayDestroy(s->bankSize);

	sgeSpriteClearWayPoints(s);
	sgeArrayDestroy(s->wayPoints);
	sgeFree(s);
}

SGESPRITEIMAGE *sgeSpriteGetCurrentFrame(SGESPRITE *s) {
	return (SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s), s->currentFrame);
}

void sgeSpriteSetFPS(SGESPRITE *s, Uint32 fps) {
	s->framesPerSecond=fps;
	s->lastFrame=0;
}

void sgeSpriteAddSpriteImage(SGESPRITE *s, SGESPRITEIMAGE *i) {
	sgeArrayAdd(sgeSpriteGetCurrentSpriteArray(s), (void *)i);
	sgeSpriteSetNumberOfFrames(s, sgeSpriteGetNumberOfFrames(s)+1);
}

void sgeSpriteAddFile(SGESPRITE *s, SGEFILE *f, const char *name) {
	SGESPRITEIMAGE *new;
	SDL_Surface *img=sgeReadImage(f,name);
	sgeNew(new, SGESPRITEIMAGE);
	sgeSpriteImageSetImage(new, img);
	sgeArrayAdd(sgeSpriteGetCurrentSpriteArray(s), (void *)new);
	sgeSpriteSetNumberOfFrames(s, sgeSpriteGetNumberOfFrames(s)+1);
}

void sgeSpriteAddFileRange(SGESPRITE *s, SGEFILE *f, const char *template, Uint32 start, Uint32 end) {
	char *buf;
	Uint32 i;
	
	sgeMalloc(buf, char, MAXFILENAMELEN);
	for (i=start;i<=end;i++) {
		memset(buf, 0, MAXFILENAMELEN+1);
		snprintf(buf, MAXFILENAMELEN, template, i);
		sgeSpriteAddFile(s, f, buf);
	}
	sgeFree(buf);
}

inline void sgeSpriteUpdatePosition(SGESPRITE *s) {
	SGESPRITEIMAGE *frame;

	frame=(SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s),s->currentFrame);
	frame->x=s->x;
	frame->y=s->y;
}

void sgeSpriteUpdate(SGESPRITE *s) {
	SGESPRITEWAYPOINT *wp;

	if (s->isMoving) {
		wp=sgeArrayGet(s->wayPoints,0);
		sgeSpriteMoveTowards(s, wp->x, wp->y);
		if (!s->isMoving) {
			sgeSpriteRemoveNextWayPoint(s);
			if (s->wayPoints->numberOfElements>0) {
				s->isMoving=1;
			}
		}
	}

	if (s->animate) {
		if ((SDL_GetTicks()-s->lastFrame)>=1000/s->framesPerSecond) {
			s->lastFrame=SDL_GetTicks();
			s->currentFrame++;
			s->currentFrame%=sgeSpriteGetNumberOfFrames(s);
		}
	}
	sgeSpriteUpdatePosition(s);
}

void sgeSpriteDraw(SGESPRITE *s, SDL_Surface *dest) {
	sgeSpriteUpdate(s);
	sgeSpriteImageDrawXY((SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s),s->currentFrame),s->x, s->y, dest);
}

void sgeSpriteDrawXY(SGESPRITE *s, int x, int y, SDL_Surface *dest) {
	sgeSpriteUpdate(s);
	sgeSpriteImageDrawXY((SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s),s->currentFrame), x, y, dest);
}

inline void sgeSpriteDrawRotoZoomed(SGESPRITE *s, float rotation, float zoom, SDL_Surface *dest) {
	sgeSpriteDrawXYRotoZoomed(s, s->x, s->y, rotation, zoom, dest);
}

inline void sgeSpriteDrawXYRotoZoomed(SGESPRITE *s, int x, int y, float rotation, float zoom, SDL_Surface *dest) {
	SGESPRITEIMAGE *sprite;
	SDL_Surface *rz;
	SDL_Rect r;

	sgeSpriteUpdate(s);
	sprite=(SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s),s->currentFrame);
	rz=sgeRotoZoom(sprite->image, rotation, zoom);
	r.x=x-(rz->w>>1)+(sprite->image->w>>1);
	r.y=y-(rz->h>>1)+(sprite->image->h>>1);
	SDL_BlitSurface(rz,NULL,dest,&r);
	SDL_FreeSurface(rz);
}

static void sgeSpriteUseAlphaHelper(Uint32 id, void *data) {
	SGESPRITEIMAGE *s=(SGESPRITEIMAGE *)data;
	sgeSpriteImageUseAlpha(s);
}
void sgeAnimatedspriteUseAlpha(SGESPRITE *s) {
	// TODO all sprite banks
	sgeArrayForEach(sgeSpriteGetCurrentSpriteArray(s), sgeSpriteUseAlphaHelper);
}

static void sgeSpriteIgnoreAlphaHelper(Uint32 id, void *data) {
	SGESPRITEIMAGE *s=(SGESPRITEIMAGE *)data;
	sgeSpriteImageIgnoreAlpha(s);
}
void sgeSpriteIgnoreAlpha(SGESPRITE *s) {
	// TODO all sprite banks
	sgeArrayForEach(sgeSpriteGetCurrentSpriteArray(s), sgeSpriteIgnoreAlphaHelper);
}

int sgeSpriteBoxCollide(SGESPRITE *a, SGESPRITE *b) {
	if (a==b) return 0;
	return sgeSpriteImageBoxCollide((SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(a),a->currentFrame),(SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(b),b->currentFrame));
}

int sgeSpriteCollide(SGESPRITE *a, SGESPRITE *b) {
	if (a==b) return 0;
	return sgeSpriteImageCollide((SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(a),a->currentFrame),(SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(b),b->currentFrame));
}

int sgeSpriteBoxCollideSpriteImage(SGESPRITE *a, SGESPRITEIMAGE *b) {
	return sgeSpriteImageBoxCollide((SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(a),a->currentFrame), b);
}

int sgeSpriteCollideSpriteImage(SGESPRITE *a, SGESPRITEIMAGE *b) {
	return sgeSpriteImageCollide((SGESPRITEIMAGE *)sgeArrayGet(sgeSpriteGetCurrentSpriteArray(a),a->currentFrame), b);
}

int sgeSpriteWidth(SGESPRITE *s) {
	SGESPRITEIMAGE *i=sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s), s->currentFrame);
	return i->w;
}

int sgeSpriteHeight(SGESPRITE *s) {
	SGESPRITEIMAGE *i=sgeArrayGet(sgeSpriteGetCurrentSpriteArray(s), s->currentFrame);
	return i->h;
}

void sgeSpriteAddWayPoint(SGESPRITE *s, int x, int y) {
	SGESPRITEWAYPOINT *wp;
	sgeNew(wp, SGESPRITEWAYPOINT);
	wp->x=x;
	wp->y=y;
	sgeArrayAdd(s->wayPoints, wp);
}

void sgeSpriteRemoveNextWayPoint(SGESPRITE *s) {
	SGESPRITEWAYPOINT *wp;
	wp=sgeArrayGet(s->wayPoints,0);
	sgeFree(wp);
	sgeArrayRemove(s->wayPoints,0);
}

void sgeSpriteClearWayPoints(SGESPRITE *s) {
	int i;
	for (i=0;i<s->wayPoints->numberOfElements;i++) {
		sgeSpriteRemoveNextWayPoint(s);
	}
}

void sgeSpriteStartMovement(SGESPRITE *s, float speed) {
	SGESPRITEWAYPOINT *wp=sgeArrayGet(s->wayPoints, 0);
	s->fX=(float)wp->x;
	s->fY=(float)wp->y;
	s->moveSpeed=speed;
	s->isMoving=1;
}

void sgeSpriteAbortMovement(SGESPRITE *s) {
	s->isMoving=0;
	s->initMove=1;
	sgeSpriteClearWayPoints(s);
}

void sgeSpriteMoveTowards(SGESPRITE *s, int x, int y) {
	int dx, dy;
	if (s->initMove) {
		dx=x-s->x;
		dy=y-s->y;
		s->fX=(float)s->x;
		s->fY=(float)s->y;
		if (abs(dx)>abs(dy)) {
			if (dx<0) {
				s->dirX=-1;
			} else {
				s->dirX=1;
			}
			s->dirY=(float)dy/(float)dx;
			if ( (dx<0) && (dy<0) )  {
				s->dirY*=-1;
			}
		} else {
			s->dirX=(float)dx/(float)dy;
			if ( (dx<0) && (dy<0) )  {
				s->dirX*=-1;
			}
			if (dy<0) {
				s->dirY=-1;
			} else {
				s->dirY=1;
			}
		}
		s->initMove=0;
	}
	s->fX+=s->dirX*s->moveSpeed;
	s->fY+=s->dirY*s->moveSpeed;
	s->x=(int)s->fX;
	s->y=(int)s->fY;


	if ( (s->dirX>0) && (s->fX>=(float)x) ) {
		s->dirX=0;
		s->x=x;
		s->fX=(float)x;
	} else if ( (s->dirX<0) && (s->fX<=(float)x) ) {
		s->dirX=0;
		s->x=x;
		s->fX=(float)x;
	}
	if ( (s->dirY>0) && (s->fY>=(float)y) ) {
		s->dirY=0;
		s->y=y;
		s->fY=(float)y;
	} else if ( (s->dirY<0) && (s->fY<=(float)y) ) {
		s->dirY=0;
		s->y=y;
		s->fY=(float)y;
	}
	if ( (s->x==x) && (s->y==y) ) {
		s->isMoving=0;
		s->initMove=1;
	}
}

void sgeSpriteSetUserData(SGESPRITE *s, void *data) {
	s->userData=(void *)data;
}

void *sgeSpriteGetUserData(SGESPRITE *s) {
	return (void *)s->userData;
}

inline Uint32 sgeSpriteGetNumberOfFrames(SGESPRITE *s) {
	return (Uint32)sgeArrayGet(s->bankSize,s->currentBank);
}

inline void sgeSpriteSetNumberOfFrames(SGESPRITE *s, Uint32 number) {
	sgeArrayReplace(s->bankSize,s->currentBank,(void *)number);
}

inline SGEARRAY *sgeSpriteGetCurrentSpriteArray(SGESPRITE *s) {
	SGEARRAY *ret=sgeArrayGet(s->sprite, s->currentBank);
	return ret;
}

inline void sgeSpriteSetAnimBank(SGESPRITE *s, Uint32 bank) {
	s->currentBank=bank;
	s->currentFrame=0;
	s->lastFrame=0;
}

void sgeSpriteAddAnimBank(SGESPRITE *s) {
	Uint32 nextbank=s->bankSize->numberOfElements;
	sgeArrayAdd(s->sprite, sgeArrayNew());
	sgeArrayAdd(s->bankSize, 0);
	sgeSpriteSetAnimBank(s, nextbank);
	s->numberOfBanks++;
}

Uint32 sgeSpriteGetAnimBank(SGESPRITE *s) {
	return s->currentBank;
}

void sgeSpriteAnimate(SGESPRITE *s, int state) {
	s->animate=state;
}

void sgeSpriteResetAnimation(SGESPRITE *s) {
	sgeSpriteForceFrame(s,0);
}

inline void sgeSpriteForceFrame(SGESPRITE *s, Uint32 frame) {
	s->currentFrame=frame;
	s->lastFrame=frame;
}
