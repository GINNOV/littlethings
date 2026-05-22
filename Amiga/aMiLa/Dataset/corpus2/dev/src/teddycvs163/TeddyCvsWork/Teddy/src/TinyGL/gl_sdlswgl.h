
/*!
	\file
	\ingroup
	\author
	\date
*/


#ifndef TEDDY_TINYGL_SDLSWGL_H
#define TEDDY_TINYGL_SDLSWGL_H


#ifdef __cplusplus
extern "C" {
#endif

#include "TinyGL/gl_gl.h"
#include "TinyGL/gl_zgl.h"
#include "SDL_video.h"


typedef struct {
    GLContext   *gl_context;
	SDL_Surface *surface;
} sdl_swgl_Context;


extern sdl_swgl_Context *sdl_swgl_CreateContext ();
extern void              sdl_swgl_DestroyContext( sdl_swgl_Context *ctx );
extern int               sdl_swgl_MakeCurrent   ( SDL_Surface *surface, sdl_swgl_Context *ctx );
extern void              sdl_swgl_SwapBuffers   ();


#ifdef __cplusplus
}
#endif


#endif  /*  TEDDY_TINYGL_SDLSWGL_H  */


