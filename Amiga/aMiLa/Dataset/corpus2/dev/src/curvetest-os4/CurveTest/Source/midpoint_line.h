#ifndef __MIDPOINT_LINE_H__
#define __MIDPOINT_LINE_H__

#include <SDL/SDL_video.h>

#include <SDL/begin_code.h>
#ifdef __cplusplus
extern "C" {
#endif

DECLSPEC void SDLCALL putpixel(SDL_Surface *surface, int x, int y,
                               Uint32 pixel);

DECLSPEC void SDLCALL horiz_line(SDL_Surface *s, int x, int x2, int y, 
                                 Uint32 color);

DECLSPEC void SDLCALL midpoint_circle(SDL_Surface *s, int xin, int yin, 
                                      int rad, Uint32 color);

DECLSPEC void SDLCALL midpoint_line(SDL_Surface *s, int x0,
                                    int y0, int x1, int y1, Uint32 color);

#ifdef __cplusplus
}
#endif
#include <SDL/close_code.h>

#endif/*__MIDPOINT_LINE_H__*/
