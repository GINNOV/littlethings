#ifndef _SGESPRITEIMAGE_H
#define _SGESPRITEIMAGE_H

typedef struct {
	int useAlpha;
	Uint32 collisionColor;
	int x,y;
	int w,h;
	SDL_Surface *image;
} SGESPRITEIMAGE;

SGESPRITEIMAGE *sgeSpriteImageNew(void);
SGESPRITEIMAGE *sgeSpriteImageNewFile(SGEFILE *f, const char *name);
void sgeSpriteImageDestroy(SGESPRITEIMAGE *s);

void sgeSpriteImageSetImage(SGESPRITEIMAGE *s, SDL_Surface *image);
void sgeSpriteImageDraw(SGESPRITEIMAGE *s, SDL_Surface *dest);
void sgeSpriteImageDrawXY(SGESPRITEIMAGE *s, int x, int y, SDL_Surface *dest);
int sgeSpriteImageBoxCollide(SGESPRITEIMAGE *a, SGESPRITEIMAGE *b);
int sgeSpriteImageCollide(SGESPRITEIMAGE *a, SGESPRITEIMAGE *b);
void sgeSpriteImageUseAlpha(SGESPRITEIMAGE *s);
void sgeSpriteImageIgnoreAlpha(SGESPRITEIMAGE *s);
void sgeSpriteImageSetCollisionColor(SGESPRITEIMAGE *s, int r, int g, int b, int a);
SGESPRITEIMAGE *sgeSpriteImageDuplicate(SGESPRITEIMAGE *s);

#endif
