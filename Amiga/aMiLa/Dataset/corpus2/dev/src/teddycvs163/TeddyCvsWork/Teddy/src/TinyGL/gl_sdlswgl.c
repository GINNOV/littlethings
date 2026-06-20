
/*!
	\file
	\ingroup
	\author
	\brief
	\date    2001
*/


#include "TinyGL/gl_sdlswgl.h"
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


/*  Prototype  */
static int sdl_swgl_resize_viewport( GLContext *c, int *xsize_ptr, int *ysize_ptr );


/*!  Create context  */
sdl_swgl_Context *sdl_swgl_CreateContext(){
	sdl_swgl_Context *ctx;

	ctx = (sdl_swgl_Context*)malloc( sizeof(sdl_swgl_Context) );
	if( ctx == NULL ){
		return NULL;
	}
	ctx->gl_context = NULL;
	return ctx;
}


/*!  Destroy context  */
void sdl_swgl_DestroyContext( sdl_swgl_Context *ctx ){
	if( ctx->gl_context != NULL ){
		glClose();
	}
	free( ctx );
}


/*!  Connect surface to context  */
int sdl_swgl_MakeCurrent( SDL_Surface *surface, sdl_swgl_Context *ctx ){
	int      mode;
	int      xsize;
	int      ysize;
	ZBuffer *zb;

	if( ctx->gl_context == NULL ){
		/* create the TinyGL context */

		xsize = surface->w;
		ysize = surface->h;

		/* currently, we only support 16 bit rendering */
		switch( surface->format->BitsPerPixel ){
		case  8: mode = ZB_MODE_INDEX;  printf("TGL  8-bit\n");break;
		case 16: mode = ZB_MODE_5R6G5B; printf("TGL 16-bit\n");break;
		case 24: mode = ZB_MODE_RGB24;  printf("TGL 24-bit\n");break;
		case 32: mode = ZB_MODE_RGBA;   printf("TGL 32-bit\n");break;
		default: return 0; break;
		}
		
		/*mode = ZB_MODE_RGBA; */
		zb   = ZB_open( xsize, ysize, mode, 0, NULL, NULL, surface->pixels );
		ZB_update( zb, surface->pixels, surface->w, surface->h, surface->pitch );
		if( zb == NULL ){
/*			fprintf( stderr, "Error while initializing Z buffer\n" );  */
			exit( 1 );
		}

		/* initialisation of the TinyGL interpreter */
		glInit( zb );
		ctx->gl_context                     = gl_get_context();
		ctx->gl_context->opaque             = (void *) ctx;
		ctx->gl_context->gl_resize_viewport = sdl_swgl_resize_viewport;

		/* set the viewport */
		/*  TIS: !!! HERE SHOULD BE -1 on both to force reshape  */
		/*  which is needed to make sure initial reshape is  */
		/*  called, otherwise it is not called..  */
		ctx->gl_context->viewport.xsize = xsize;
		ctx->gl_context->viewport.ysize = ysize;
      
		glViewport( 0, 0, xsize, ysize );
	}
	ctx->surface = surface;
  
	return 1;
}


/*!  Swap buffers  */
void sdl_swgl_SwapBuffers(){
	GLContext        *gl_context;
	sdl_swgl_Context *ctx;
    
    /* retrieve the current sdl_swgl_Context */
    gl_context = gl_get_context();
    ctx = (sdl_swgl_Context *)gl_context->opaque;

   	/* Update the screen! */
	if ( (ctx->surface->flags & SDL_DOUBLEBUF) == SDL_DOUBLEBUF ) {
		SDL_Flip( ctx->surface );
	}else{
		/*SDL_LockSurface( sdl_surface );*/
		SDL_UpdateRect( ctx->surface, 0, 0, ctx->surface->w, ctx->surface->h );
		/*SDL_UnlockSurface( sdl_surface );*/
	}
	ZB_update( gl_context->zb, ctx->surface->pixels, ctx->surface->w, ctx->surface->h, ctx->surface->pitch );
}


/*!  Resize context  */
static int sdl_swgl_resize_viewport( GLContext *c, int *xsize_ptr, int *ysize_ptr ){
	return 0;
#if 0
	sdl_swgl_Context *ctx;
	int               xsize;
	int               ysize;
  
	ctx = (sdl_swgl_Context *)c->opaque;

	xsize = *xsize_ptr;
	ysize = *ysize_ptr;

	/* we ensure that xsize and ysize are multiples of 2 for the zbuffer. 
	   TODO: find a better solution */
	xsize &= ~3;
	ysize &= ~3;

	if (xsize == 0 || ysize == 0) return -1;

	*xsize_ptr = xsize;
	*ysize_ptr = ysize;

	ctx->xsize = xsize;
	ctx->ysize = ysize;

	/* resize the Z buffer */
	ZB_resize( c->zb, surface->pixels, xsize, ysize );
	return 0;
#endif
}

