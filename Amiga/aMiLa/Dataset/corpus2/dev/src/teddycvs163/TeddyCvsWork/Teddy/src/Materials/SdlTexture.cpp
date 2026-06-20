
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
    tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/


#include "config.h"
#include "Materials/SdlTexture.h"
#include "Graphics/Device.h"
#include "Graphics/View.h"
#include "Graphics/SDL_gfxPrimitives.h"
#include "SysSupport/Messages.h"
using namespace Graphics;


namespace Materials {


#ifdef HAVE_LIB_SDL_IMAGE
# include "SDL_image.h"
# if defined(_MSC_VER)
#  if defined(_DEBUG)
#   pragma comment (lib, "SDLD_image.lib")
#  else
#   pragma comment (lib, "SDL_image.lib")
#  endif
# endif
#endif


//!  Constructor from file
SdlTexture::SdlTexture( const char *fname, int mode, int flags ):Texture( fname){
#ifdef HAVE_LIB_SDL_IMAGE
	if( strlen(fname) > 0 ){
		SDL_Surface *sdl_surface = IMG_Load( fname );
		if( sdl_surface != NULL ){
			copySdlSurface( sdl_surface, mode, flags );
//			SDL_FreeSurface( sdl_surface );
			this->is_good = true;
		}else{
			error_msg( MSG_HEAD "Could not load texture file %s", fname );
		}
	}else{
		error_msg( MSG_HEAD "Bad empty filename" );
	}
#else
	error_msg( MSG_HEAD "SDL_image not available" );
#endif
}

//!  Constructor from SDL_Surface
SdlTexture::SdlTexture( SDL_Surface *surface, int mode, int flags ):Texture(""){
	copySdlSurface( surface, mode, flags );
}


//!  Copy SDL_Surface to texture
void SdlTexture::copySdlSurface( SDL_Surface *surface, int mode, int flags ){
	this->width  = surface->w;
	this->height = surface->h;
	int format;

	SDL_LockSurface( surface );
#	if !defined( USE_TINY_GL )
	format       = FORMAT_RGBA;
	Uint32 *data = new Uint32[width*height];

	//  Copy all pixels
	for( int y=0; y<height; y++ ){
		for( int x=0; x<width; x++ ){
			data[x+y*width] = SDL_GetPixel( surface, x, y );
		}
	}
#	else
	format      = FORMAT_RGB;
	Uint8 *data = new Uint8[width*height*3];

	//  Copy all pixels
	SDL_LockSurface( surface );
	for( int y=0; y<height; y++ ){
		for( int x=0; x<width; x++ ){
			Uint32 rgba = SDL_GetPixel( surface, x, y );
			data[(x+y*width)*3+0] = (rgba     ) & 0xff;
			data[(x+y*width)*3+1] = (rgba >> 8) & 0xff;
			data[(x+y*width)*3+2] = (rgba >>16) & 0xff;
		}
	}
#	endif
	SDL_UnlockSurface( surface );

	setWrap  ( WRAP_REPEAT, WRAP_REPEAT );
	setFilter( FILTER_LINEAR );
	setEnv   ( ENV_MODULATE );
	putData( (unsigned char*)data, width, height, format, Options(0) );

	delete[] data;

	View::check();
}


};  //  namespace Materials

