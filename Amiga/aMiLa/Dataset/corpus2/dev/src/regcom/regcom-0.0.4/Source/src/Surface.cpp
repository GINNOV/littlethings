//**********************************************************************
//
//  REGCOM: Regimental Command
//  Copyright (C) 1997-2001 Randi J. Relander
//	<rjrelander@users.sourceforge.net>
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public
//  License along with this program; if not, write to the Free
//  Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
//  MA 02111-1307, USA.
//  
//**********************************************************************

#include <stdlib.h>
#include <string.h>

#include "Rect.h"
#include "Surface.h"

#ifndef GAME_DATADIR
#define GAME_DATADIR "data/"
#endif

#define IMAGE_SUB "images/"

#ifdef macintosh
#define PATH_SEP	":"
#define PATH_CUR	":"
#else
#define PATH_SEP	""
#define PATH_CUR	"."
#endif

//----------------------------------------------------------------------      
// FUNCTION: Surface::Surface
//----------------------------------------------------------------------

Surface::Surface()
{
	m_surface = NULL;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::~Surface
//----------------------------------------------------------------------

Surface::~Surface()
{
	if (m_surface) SDL_FreeSurface(m_surface);
}

//----------------------------------------------------------------------
// FUNCTION: Surface::Create
//----------------------------------------------------------------------

int Surface::Create(int w, int h)
{
	if (m_surface) SDL_FreeSurface(m_surface);

	m_surface = SDL_AllocSurface(0, w, h, 8, 0, 0, 0, 0);

	if (m_surface == NULL) return -1;

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::Load
//----------------------------------------------------------------------

int Surface::Load(const char* name)
{
	if (m_surface) SDL_FreeSurface(m_surface);

	long size = strlen(GAME_DATADIR) + strlen(PATH_SEP) +
		strlen(IMAGE_SUB) + strlen(PATH_SEP) + strlen(name) + 1;

	char* buffer = new char [size];
		
	sprintf(buffer,"%s%s%s%s%s",
		GAME_DATADIR,PATH_SEP,IMAGE_SUB,PATH_SEP,name);

	m_surface = SDL_LoadBMP(buffer);

	if (m_surface == NULL) {
		fprintf(stderr, "SDL_LoadBMP: %s\n",SDL_GetError());
		exit(-1);
	}

	delete [] buffer;
	
	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::SetColorKey
//----------------------------------------------------------------------

int Surface::SetColorKey(int r, int g, int b)
{
	if (m_surface == NULL) return -1;
	
	int result = SDL_SetColorKey(m_surface,
		SDL_SRCCOLORKEY|SDL_RLEACCEL,
		SDL_MapRGB(m_surface->format,r,g,b));
	
	if (result) return -1;
	
	return 0;
}	

//----------------------------------------------------------------------
// FUNCTION: Surface::DisplayFormat
//----------------------------------------------------------------------

int Surface::DisplayFormat()
{
	if (m_surface == NULL) return -1;
	
	SDL_Surface* image = SDL_DisplayFormat(m_surface);
	
	SDL_FreeSurface(m_surface);
	
	m_surface = image;

	if (m_surface == NULL) return -1;

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::Blit
//----------------------------------------------------------------------

int Surface::Blit(Surface* surface, Rect* src, int x, int y)
{
	if (m_surface == NULL) return -1;

	SDL_Rect sdl_src;
	SDL_Rect sdl_dst;

	if (src == NULL)
	{
		sdl_src.x = 0;
		sdl_src.y = 0;
		sdl_src.w = m_surface->w;
		sdl_src.h = m_surface->h;
		
		sdl_dst.x = x;
		sdl_dst.y = y;
		sdl_dst.w = m_surface->w;
		sdl_dst.h = m_surface->h;
	}
	else
	{
		sdl_src.x = src->x;
		sdl_src.y = src->y;
		sdl_src.w = src->w;
		sdl_src.h = src->h;

		sdl_dst.x = x;
		sdl_dst.y = y;
		sdl_dst.w = src->w;
		sdl_dst.h = src->h;
	}

	int result = SDL_BlitSurface(
		m_surface,&sdl_src,surface->m_surface,&sdl_dst);

	if (result) return -1;
	
	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::LowerBlit
//----------------------------------------------------------------------

int Surface::LowerBlit(Surface* surface, Rect* src, int x, int y)
{
	if (m_surface == NULL) return -1;

	SDL_Rect sdl_src;
	SDL_Rect sdl_dst;

	if (src == NULL)
	{
		sdl_src.x = 0;
		sdl_src.y = 0;
		sdl_src.w = m_surface->w;
		sdl_src.h = m_surface->h;
		
		sdl_dst.x = x;
		sdl_dst.y = y;
		sdl_dst.w = m_surface->w;
		sdl_dst.h = m_surface->h;
	}
	else
	{
		sdl_src.x = src->x;
		sdl_src.y = src->y;
		sdl_src.w = src->w;
		sdl_src.h = src->h;

		sdl_dst.x = x;
		sdl_dst.y = y;
		sdl_dst.w = src->w;
		sdl_dst.h = src->h;
	}

	int result = SDL_LowerBlit(
		m_surface,&sdl_src,surface->m_surface,&sdl_dst);

	if (result) return -1;
	
	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::FillRect
//----------------------------------------------------------------------

int Surface::FillRect(Rect* rect, int r, int g, int b)
{
	if (m_surface == NULL) return -1;

	SDL_Rect sdl_rect;

	sdl_rect.x = rect->x;
	sdl_rect.y = rect->y;
	sdl_rect.w = rect->w;
	sdl_rect.h = rect->h;

	int result = SDL_FillRect(m_surface,
		&sdl_rect,SDL_MapRGB(m_surface->format,r,g,b));
	
	if (result) return -1;
	
	return 0;
}	

//----------------------------------------------------------------------
// FUNCTION: Surface::Transparent
//----------------------------------------------------------------------

int Surface::Transparent(int x, int y)
{
	if (m_surface == NULL) return 0;

	return GetPixel(x,y) == m_surface->format->colorkey;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::GetPixel
//----------------------------------------------------------------------

Uint32 Surface::GetPixel(int x, int y)
{
	if (m_surface == NULL) return 0;

	Uint8 r, g, b;
	Uint32 pixel;
	Uint8 *bits, bpp;

	Lock();

	bpp = m_surface->format->BytesPerPixel;

	bits = ((Uint8*)m_surface->pixels)+y*m_surface->pitch+x*bpp;

	switch(bpp) {
	case 1:
		pixel = *((Uint8 *)(bits));
		break;
	case 2:
		pixel = *((Uint16 *)(bits));
		break;
	case 3:
		r = *((bits) + m_surface->format->Rshift / 8);
		g = *((bits) + m_surface->format->Gshift / 8);
		b = *((bits) + m_surface->format->Bshift / 8);
		pixel  = (r<<m_surface->format->Rshift);
		pixel |= (g<<m_surface->format->Gshift);
		pixel |= (b<<m_surface->format->Bshift);
		break;
	case 4:
		pixel = *((Uint32 *)(bits));
		break;
	}

	Unlock();

	return pixel;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::Lock
//----------------------------------------------------------------------

int Surface::Lock()
{
	if (m_surface == NULL) return -1;

	if ( SDL_MUSTLOCK(m_surface) )
	{
		if ( SDL_LockSurface(m_surface) < 0 )
			return -1;
	}

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::Unlock
//----------------------------------------------------------------------

int Surface::Unlock()
{
	if (m_surface == NULL) return -1;

	if ( SDL_MUSTLOCK(m_surface) )
		SDL_UnlockSurface(m_surface);

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Surface::GetPalette
//----------------------------------------------------------------------

int Surface::GetPalette(Surface* surface)
{
	if (m_surface == NULL) return -1;

	SDL_Palette* palette = surface->m_surface->format->palette;

	if (palette)
	{
		int result = SDL_SetColors(
			m_surface, palette->colors, 0, palette->ncolors);

		if (result) return -1;
	}
	
	return 0;
}
