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

#ifndef SURFACE_H
#define SURFACE_H

#include "SDL.h"

class Rect;

class Surface
{
protected:

	SDL_Surface* m_surface;

public:

	Surface();
	virtual ~Surface();

	int Create(int w, int h);

	int Load(const char* name);
	int SetColorKey(int r, int g, int b);
	int DisplayFormat();
	int Blit(Surface* surface, Rect* src, int x, int y);
	int LowerBlit(Surface* surface, Rect* src, int x, int y);
	int FillRect(Rect* rect, int r, int g, int b);

	int Transparent(int x, int y);

	Uint32 GetPixel(int x, int y);

	int Width() { return m_surface->w; }
	int Height() { return m_surface->h; }
	int Depth() { return m_surface->format->BytesPerPixel; }
	int Pitch() { return m_surface->pitch; }
	
	void* Pixels() { return m_surface->pixels; }

	int Lock();
	int Unlock();

	int GetPalette(Surface* surface);
};

#endif
