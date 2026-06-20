#ifndef _SGEGFX_H
#define _SGEGFX_H

#define sgeClearScreen() SDL_FillRect(screen, NULL, 0)

typedef struct {
	Uint8 r,g,b,a;
} SGEPIXELINFO;

typedef struct {
	int x,y;
} SGEPOSITION;

SGEPOSITION *sgePositionNew(int x, int y);
void sgePositionDestroy(SGEPOSITION *p);

SGEPIXELINFO *sgePixelInfoNew(Uint8 r, Uint8 g, Uint8 b, Uint8 a);
void sgePixelInfoDestroy(SGEPIXELINFO *i);

inline Uint32 sgeMakeColor(int r, int g, int b, int a);
inline void sgeFillRect(SDL_Surface *dest, int x, int y, int w, int h, Uint32 color);
inline void sgeDrawRect(SDL_Surface *dest, int x, int y, int w, int h, int linewidth, Uint32 color);
inline void sgeDrawPixel(SDL_Surface *dest, int x, int y, Uint32 color);
inline SGEPIXELINFO *sgeGetPixel(SDL_Surface *dest, int x, int y);
inline void sgeDrawLine(SDL_Surface *dest, int x, int y, int x2, int y2, Uint32 color);
inline void sgeDrawImage(SDL_Surface *dest, SDL_Surface *image, int x, int y);
void sgeIgnoreAlpha(SDL_Surface *s);
void sgeUseAlpha(SDL_Surface *s);
SDL_Surface *sgeRotoZoom(SDL_Surface *source, float rotation, float zoom);

#endif
