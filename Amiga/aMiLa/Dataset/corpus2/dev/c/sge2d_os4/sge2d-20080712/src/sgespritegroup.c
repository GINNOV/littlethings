#include <sge.h>

SGESPRITEGROUP *sgeSpriteGroupNew(void) {
	SGESPRITEGROUP *ret;
	sgeNew(ret, SGESPRITEGROUP);
	ret->sprite=sgeArrayNew();
	return ret;
}

static void sgeSpriteGroupDestroySpriteHelper(Uint32 id, void *data) {
	SGESPRITE *s=(SGESPRITE *)data;
	if (s!=NULL) sgeSpriteDestroy(s);
}

void sgeSpriteGroupDestroy(SGESPRITEGROUP *g) {
	sgeArrayForEach(g->sprite, sgeSpriteGroupDestroySpriteHelper);
	sgeArrayDestroy(g->sprite);
	sgeFree(g);
}

void sgeSpriteGroupAddSprite(SGESPRITEGROUP *g, SGESPRITE *s) {
	sgeArrayAdd(g->sprite,s);
}

int sgeSpriteGroupCollide(SGESPRITEGROUP *g, SGESPRITEGROUP *cg) {
	if (sgeSpriteGroupGetCollider(g,cg)==NULL) return 0;
	return 1;
}

int sgeSpriteGroupCollideSprite(SGESPRITEGROUP *g, SGESPRITE *s) {
	if (sgeSpriteGroupGetColliderSprite(g,s)==NULL) return 0;
	return 1;
}

SGESPRITE *sgeSpriteGroupGetCollider(SGESPRITEGROUP *g, SGESPRITEGROUP *cg) {
	SGESPRITE *tmpa;
	int i;
	for (i=0;i<g->sprite->numberOfElements;i++) {
		tmpa=(SGESPRITE *)sgeArrayGet(g->sprite,i);
		if (sgeSpriteGroupCollideSprite(cg, tmpa)) return tmpa;
	}
	return NULL;
}

SGESPRITE *sgeSpriteGroupGetColliderSprite(SGESPRITEGROUP *g, SGESPRITE *s) {
	SGESPRITE *tmpa;
	int i;
	for (i=0;i<g->sprite->numberOfElements;i++) {
		tmpa=(SGESPRITE *)sgeArrayGet(g->sprite,i);
		if (sgeSpriteCollide(tmpa,s)) return tmpa;
	}
	return NULL;
}

void sgeSpriteGroupDraw(SGESPRITEGROUP *g) {
	SGESPRITE *tmpa;
	int i;
	for (i=0;i<g->sprite->numberOfElements;i++) {
		tmpa=(SGESPRITE *)sgeArrayGet(g->sprite,i);
		sgeSpriteDraw(tmpa, screen);
	}
}

void sgeSpriteGroupDrawRelative(SGESPRITEGROUP *g, int camx, int camy) {
	SGESPRITE *tmpa;
	int i;
	for (i=0;i<g->sprite->numberOfElements;i++) {
		tmpa=(SGESPRITE *)sgeArrayGet(g->sprite,i);
		sgeSpriteDrawXY(tmpa, tmpa->x-camx, tmpa->y-camy, screen);
	}
}

