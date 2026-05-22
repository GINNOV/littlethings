#ifndef _SGESPRITEGROUP_H
#define _SGESPRITEGROUP_H

typedef struct {
	SGEARRAY *sprite;
} SGESPRITEGROUP;

SGESPRITEGROUP *sgeSpriteGroupNew(void);
void sgeSpriteGroupDestroy(SGESPRITEGROUP *g);

void sgeSpriteGroupAddSprite(SGESPRITEGROUP *g, SGESPRITE *s);
int sgeSpriteGroupCollide(SGESPRITEGROUP *g, SGESPRITEGROUP *cg);
int sgeSpriteGroupCollideSprite(SGESPRITEGROUP *g, SGESPRITE *s);
SGESPRITE *sgeSpriteGroupGetCollider(SGESPRITEGROUP *g, SGESPRITEGROUP *cg);
SGESPRITE *sgeSpriteGroupGetColliderSprite(SGESPRITEGROUP *g, SGESPRITE *s);
void sgeSpriteGroupDraw(SGESPRITEGROUP *g);
void sgeSpriteGroupDrawRelative(SGESPRITEGROUP *g, int camx, int camy);

#endif
