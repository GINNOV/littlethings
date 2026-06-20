// INCLUDES ///////////////////////////////////////////////////////////////////

#include "sdl.h"
#include "tileset.h"
#include "globals.h"


////////////////////////////////////////////////////////////////////////////////

namespace eversion {


// FUNCTIONS //////////////////////////////////////////////////////////////////

void tileset::init()
{
	surface::init();
	count = 0;
	width = height = 0;
}


void tileset::free()
{
	surface::free();
	init();
}


void tileset::draw(s32 index, s32 x, s32 y, SDL_Surface *dst)
{
#ifdef EVERSION__DEBUG
	if(index < 0 || index > count)
		return;
#endif
	::SDL_Rect rectDest,rectSrc;

	rectSrc.x = (index % (surface::getWidth()/width) )*width;
	rectSrc.y = s32(index/ (surface::getWidth()/width) )*height;
	rectSrc.w = width; rectSrc.h = height;

	rectDest.x = x;  rectDest.y = y;
	rectDest.w = width;  rectDest.h = height;

	eversion::SDL_BlitSurface(image, &rectSrc, dst, &rectDest);
}


void tileset::draw(s32 index, ::SDL_Rect rectDest, SDL_Surface *dst)
{
#ifdef EVERSION__DEBUG
	if(index < 0 || index > count)
		return;
#endif
	::SDL_Rect rectSrc;

	rectSrc.x = (index%count)*width; rectSrc.y = s32(index/count)*height;
	rectSrc.w = width; rectSrc.h = height;

	eversion::SDL_BlitSurface(image, &rectSrc, dst, &rectDest);
}


bool tileset::load(char *filename, s32 _width, s32 _height, s32 _count)
{
	if( !surface::load(filename) )
	{
		fprintf(stderr,"TileSet load failure");
		return false;
	}

	width = _width;
	height = _height;

	if(_count == 0)
	{
		count = (surface::getWidth()*surface::getHeight())/(width*height);
	}
	else
	{
		count = _count;
	}

	return true;
}


////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
