#ifndef _SGESTAGE_H
#define _SGESTAGE_H

#define ABSOLUTE 0
#define RELATIVE 1

#define sgeStageGetSpriteGroup(stage, group) sgeArrayGet(stage->spriteGroups, group)

typedef struct {
	int x,y;
	int w,h;
	SGESPRITE *sprite;
} SGELAYER;

typedef struct {
	int cameraX, cameraY;
	int w, h;
	SGEARRAY *layers;
	SGEARRAY *spriteGroups;
} SGESTAGE;

SGELAYER *sgeLayerNew(SGESPRITE *sprite);
void sgeLayerDestroy(SGELAYER *l);

SGESTAGE *sgeStageNew(int width, int height);
void sgeStageDestroy(SGESTAGE *s);
int sgeStageAddLayer(SGESTAGE *s, SGESPRITE *sprite, int x, int y);
void sgeStageSetLayerHeight(SGESTAGE *s, int layer, int height);
void sgeStageSetLayerWidth(SGESTAGE *s, int layer, int width);
void sgeStageDrawLayer(SGESTAGE *s, SDL_Surface *dest, int layer);
int sgeStageAddSpriteGroup(SGESTAGE *s, SGESPRITEGROUP *g);
int sgeStageAddSprite(SGESTAGE *s, int spriteGroup, SGESPRITE *sprite);
void sgeStageDrawSpriteGroup(SGESTAGE *s, int spriteGroup);
void sgeStageDrawSpriteGroups(SGESTAGE *s);
int sgeStageSpriteGroupCollideSprite(SGESTAGE *s, int b, SGESPRITE *a, int orientation);
int sgeStageSpriteGroupCollideSpriteGroup(SGESTAGE *s, int a, int b, int orientationa);
SGEPOSITION *sgeStageScreenToReal(SGESTAGE *s, int x, int y);

#endif
