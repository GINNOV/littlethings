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

#include "Screen.h"
#include "Surface.h"
#include "Rect.h"
#include "SDL.h"

Screen* Screen::m_instance = NULL;

//----------------------------------------------------------------------
// FUNCTION: Screen::Screen
//----------------------------------------------------------------------

Screen::Screen()
{
	m_surface = SDL_GetVideoSurface();

	LoadPalette("Pixels.bmp");
}

//----------------------------------------------------------------------
// FUNCTION: Screen::~Screen
//----------------------------------------------------------------------

Screen::~Screen()
{
	m_surface = NULL;
}

//----------------------------------------------------------------------
// FUNCTION: Screen::Flip
//----------------------------------------------------------------------

int Screen::Flip()
{
	SDL_Flip(m_surface);

	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Screen::LoadPalette
//----------------------------------------------------------------------

int Screen::LoadPalette(char* filename)
{
	Surface image;
	
	image.Load(filename);

	GetPalette(&image);
	
	return 0;
}

//----------------------------------------------------------------------
// FUNCTION: Screen::Resize
//----------------------------------------------------------------------

int Screen::Resize(int w, int h)
{
	SDL_Surface* surface = SDL_SetVideoMode(
		w,h,m_surface->format->BitsPerPixel,m_surface->flags);

	if (surface == NULL) return -1;

	m_surface = surface;

	LoadPalette("Pixels.bmp");

	return 0;
}

