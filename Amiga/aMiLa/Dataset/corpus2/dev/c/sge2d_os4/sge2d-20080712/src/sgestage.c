#include <sge.h>

SGELAYER *sgeLayerNew(SGESPRITE *sprite) {
	SGELAYER *ret;
	SGESPRITEIMAGE *i=sgeArrayGet(sgeSpriteGetCurrentSpriteArray(sprite), sprite->currentFrame);
	sgeNew(ret, SGELAYER);
	ret->x=0;
	ret->y=0;
	ret->w=i->image->w;
	ret->h=i->image->h;
	ret->sprite=sprite;
	return ret;
}

void sgeLayerDestroy(SGELAYER *l) {
	sgeSpriteDestroy(l->sprite);
	sgeFree(l);
}

SGESTAGE *sgeStageNew(int width, int height) {
	SGESTAGE *ret;
	sgeNew(ret, SGESTAGE);
	ret->cameraX=0;
	ret->cameraY=0;
	ret->w=width;
	ret->h=height;
	ret->layers=sgeArrayNew();
	ret->spriteGroups=sgeArrayNew();
	return ret;
}

static void sgeStageDestroyLayersHelper(Uint32 id, void *data) {
	SGELAYER *l=(SGELAYER *)data;
	sgeLayerDestroy(l);
}

static void sgeStageDestroySpriteGroupsHelper(Uint32 id, void *data) {
	SGESPRITEGROUP *g=(SGESPRITEGROUP *)data;
	sgeSpriteGroupDestroy(g);
}

void sgeStageDestroy(SGESTAGE *s) {
	sgeArrayForEach(s->layers, sgeStageDestroyLayersHelper);
	sgeArrayDestroy(s->layers);
	sgeArrayForEach(s->spriteGroups, sgeStageDestroySpriteGroupsHelper);
	sgeArrayDestroy(s->spriteGroups);
	sgeFree(s);
}

int sgeStageAddLayer(SGESTAGE *s, SGESPRITE *sprite, int x, int y) {
	SGELAYER *l;
	l=sgeLayerNew(sprite);
	l->x=x;
	l->y=y;
	sgeArrayAdd(s->layers, l);
	return s->layers->numberOfElements-1;
}

void sgeStageSetLayerHeight(SGESTAGE *s, int layer, int height) {
	SGELAYER *l=(SGELAYER *)sgeArrayGet(s->layers, layer);
	l->h=height;
}

void sgeStageSetLayerWidth(SGESTAGE *s, int layer, int width) {
	SGELAYER *l=(SGELAYER *)sgeArrayGet(s->layers, layer);
	l->w=width;
}

void sgeStageDrawLayer(SGESTAGE *s, SDL_Surface *dest, int layer) {
	SDL_Rect r;
	SGELAYER *l=(SGELAYER *)sgeArrayGet(s->layers, layer);
	SGEARRAY *cur=sgeSpriteGetCurrentSpriteArray(l->sprite);
	SGESPRITEIMAGE *i=sgeArrayGet(cur, l->sprite->currentFrame);
	int newx, newy;
	double tmp;
	newx=s->cameraX-l->x;
	if (l->x!=0) {
		newx-=screen->w;
	}
	newy=s->cameraY-l->y;
	if (l->y!=0) {
		newy-=screen->h;
	}
	tmp=(double)newx*(double)((double)(i->w+l->x-screen->w)/(double)s->w);
	r.x=(int)tmp;
	tmp=(double)newy*(double)((double)(i->h+l->y-screen->h)/(double)s->h);
	r.y=(int)tmp;
	r.w=dest->w;
	r.h=dest->h;

	SDL_BlitSurface(i->image, &r, dest, NULL);
}

int sgeStageAddSpriteGroup(SGESTAGE *s, SGESPRITEGROUP *g) {
	sgeArrayAdd(s->spriteGroups, g);
	return s->spriteGroups->numberOfElements-1;
}

int sgeStageAddSprite(SGESTAGE *s, int spriteGroup, SGESPRITE *sprite) {
	SGESPRITEGROUP *g=sgeArrayGet(s->spriteGroups,spriteGroup);
	sgeSpriteGroupAddSprite(g, sprite);
	return g->sprite->numberOfElements-1;
}

void sgeStageDrawSpriteGroup(SGESTAGE *s, int spriteGroup) {
	SGESPRITEGROUP *g=sgeArrayGet(s->spriteGroups,spriteGroup);
	sgeSpriteGroupDrawRelative(g, s->cameraX, s->cameraY);
}

void sgeStageDrawSpriteGroups(SGESTAGE *s) {
	Uint32 i;
	SGESPRITEGROUP *g;
	for (i=0;i<s->spriteGroups->numberOfElements;i++) {
		g=(SGESPRITEGROUP *)sgeArrayGet(s->spriteGroups,i);
		sgeSpriteGroupDrawRelative(g, s->cameraX, s->cameraY);
	}
}

int sgeStageSpriteGroupCollideSprite(SGESTAGE *s, int b, SGESPRITE *a, int orientation) {
	SGESPRITEGROUP *g;
	SGESPRITE *collider;
	SGESPRITEIMAGE *collidersprite, *colliderimage;
	int ret=0;

	if (b > s->spriteGroups->numberOfElements-1) {
		return 0;
	}

	g=(SGESPRITEGROUP *)sgeArrayGet(s->spriteGroups, b);
	collidersprite=sgeSpriteGetCurrentFrame(a);
	colliderimage=sgeSpriteImageDuplicate(collidersprite);

	if (orientation==RELATIVE) {
		colliderimage->x+=s->cameraX;
		colliderimage->y+=s->cameraY;
	}

	collider=sgeSpriteNew();
	sgeSpriteAddSpriteImage(collider, colliderimage);

	ret=sgeSpriteGroupCollideSprite(g, collider);
	sgeSpriteDestroy(collider);
	return ret;
}

int sgeStageSpriteGroupCollideSpriteGroup(SGESTAGE *s, int a, int b, int orientationa) {
	SGESPRITE *tmpa;
	SGESPRITEGROUP *g;
	int i;

	if (
			(b > s->spriteGroups->numberOfElements-1) ||
			(a > s->spriteGroups->numberOfElements-1)
	) {
		return 0;
	}

	g=(SGESPRITEGROUP *)sgeArrayGet(s->spriteGroups, a);
	for (i=0;i<g->sprite->numberOfElements;i++) {
		tmpa=(SGESPRITE *)sgeArrayGet(g->sprite,i);
		if (sgeStageSpriteGroupCollideSprite(s, b, tmpa, orientationa)) return 1;
	}
	return 0;
}

SGEPOSITION *sgeStageScreenToReal(SGESTAGE *s, int x, int y) {
	return sgePositionNew(x+s->cameraX,y+s->cameraY);
}
