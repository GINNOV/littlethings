#ifndef _SGEFONT_H
#define _SGEFONT_H

#define SGEFONT_BITMAP 1

typedef struct {
	SDL_Surface *bitmap;
	unsigned char *charmap;
	SGEARRAY *info;
} SGEBITMAPFONT;

typedef struct {
	int type;
	void *data;
} SGEFONT;

SGEFONT *sgeFontNew(int type);
SGEFONT *sgeFontNewFile(SGEFILE *f, int type, const char *filename);
SGEFONT *sgeFontNewFileBitmap(SGEFILE *f, const char *filename);
void sgeFontDestroy(SGEFONT *f);

int sgeFontGetLineHeight(SGEFONT *f);
int sgeFontGetLineHeightBitmap(SGEFONT *f);
int sgeFontPrint(SGEFONT *f, SDL_Surface *dest, int x, int y, const char *text);
int sgeFontPrintBitmap(SGEFONT *f, SDL_Surface *dest, int x, int y, const char *text);
int sgeFontGetWidth(SGEFONT *f, const char *text);
int sgeFontGetWidthBitmap(SGEFONT *f, const char *text);

#endif
