// INCLUDES ///////////////////////////////////////////////////////////////////

#include "sdl.h"
#include "globals.h"
#include "surface.h"
#include "gfxutil.h"
#include "imagestack.h"
#include <string.h>

////////////////////////////////////////////////////////////////////////////////

#ifndef EVERSION__USE_ASM

extern "C" {

void flipImageV(u8 *buffer, u32 width, u32 height, u8 bpp)
{
	u8* _buffer = buffer;
	u8 *_bufferTop = buffer + width*(height-1)*bpp;
	u32 pitch = width*bpp*2;
	u32 height_half = height/2;
	u32 line_len = width*bpp;
	u8 c;

	for(u32 h = 0; h < height_half; h++)
	{
		for(u32 w = 0; w < line_len; w++)
		{
			c = *_buffer;
			*_buffer = *_bufferTop;
			*_bufferTop = c;

			_buffer++;
			_bufferTop++;
		}

		_bufferTop -= pitch;
	}
}


void flipImageH(u8 *buffer, u32 width, u32 height, u8 bpp)
{
	u32 pitch1 = width*bpp/2;
	u32 pitch2 = pitch1*3;
	u8 *_buffer = buffer;
	u8 *_buffer2 = buffer+(width-1)*bpp;
	u32 half_width = width/2;
	u32 bpp_m2 = bpp*2;
	u8 c;

	for(u32 h=0; h<height; h++)
	{
		for(u32 w=0; w<half_width; w++)
		{
			for(u32 pix = 0; pix<bpp; pix++)
			{
				c = *_buffer;
				*_buffer = *_buffer2;
				*_buffer2 = c;

				_buffer++;
				_buffer2++;
			}

			_buffer2 -= bpp_m2;
		}
		_buffer += pitch1;
		_buffer2 += pitch2;
	}
}


void swapAC(u8 *buffer, u32 width, u32 height, u8 bpp)
{
	u32 imageSize = width*height*bpp;

	for(u32 cswap = 0; cswap < imageSize; cswap += bpp)
	{
		buffer[cswap] ^= buffer[cswap+2] ^= buffer[cswap] ^= buffer[cswap+2];
	}
}

}

#endif


namespace eversion {


// FUNCTIONS //////////////////////////////////////////////////////////////////

void surface::init()
{
	image = NULL;
	rect.x = rect.y = 0;  rect.w = rect.h = 0;
}


void surface::free()
{
/*
	if(image != NULL)
	{
		SDL_FreeSurface(image);
	}
*/
	init();
}

void surface::dealloc()
{
	if(image)
	{
		SDL_FreeSurface(image);
	}

	init();
}


void surface::draw(s32 x, s32 y, SDL_Surface *dst)
{
	::SDL_Rect rectDest;

	rectDest.x = x;  rectDest.y = y;
	rectDest.w = image->w;  rectDest.h = image->h;

	eversion::SDL_BlitSurface(image, &rect, dst, &rectDest);
}


void surface::draw(::SDL_Rect rectDest, SDL_Surface *dst)
{
	eversion::SDL_BlitSurface(image, &rect, dst, &rectDest);
}


surface& surface::flipH()
{
	::flipImageH(
		(u8*)image->pixels,
		(u32)image->w, (u32)image->h,
		image->format->BitsPerPixel/8
		);

	return *this;
}


surface& surface::flipV()
{
	::flipImageV(
		(u8*)image->pixels,
		(u32)image->w, (u32)image->h,
		image->format->BitsPerPixel/8
		);

	return *this;
}


bool surface::load(char *filename)
{
	//free();

	image = image_stack::instance()->load(filename);

	if(image==NULL)
		return false;

	rect.w = image->w; rect.h = image->h;

	setColorKey(0);
	return true;
}

bool surface::alloc(s32 w, s32 h, u16 depth)
{
	dealloc();
	s32 bpp=depth?depth:eversion::screenBitsPerPixel;
	image = SDL_CreateRGBSurface(SDL_SRCCOLORKEY,w,h,bpp,0,0,0,0);

	if(image==NULL)
	{
		fprintf(stderr, "surface::alloc: SDL_CreateRGBSurface returned NULL\n");
		return false;
	}

	if ( SDL_MUSTLOCK(image) )
	{
		if ( SDL_LockSurface(image) < 0 )
		{
			fprintf(stderr, "surface::alloc: couldn't lock the surface\n");
		}
	}

	::memset((u8*)(image->pixels),0,image->w*image->h*image->format->BytesPerPixel);

	if ( SDL_MUSTLOCK(image) )
		SDL_UnlockSurface(image);



	rect.x=0; rect.y=0; rect.w=w; rect.h=h;
	setColorKey(0);
	return true;
}

////////////////////////////////////////////////////////////////////////////////

}

////////////////////////////////////////////////////////////////////////////////
