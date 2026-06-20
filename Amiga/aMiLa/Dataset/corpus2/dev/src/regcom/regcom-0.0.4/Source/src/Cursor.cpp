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

#include "Cursor.h"
#include "Surface.h"
#include "Screen.h"
#include "SDL.h"

//----------------------------------------------------------------------
// FUNCTION: Cursor::Cursor
//----------------------------------------------------------------------

Cursor::Cursor()
{
	m_image = new Surface;
	m_image->Load("Cursor.bmp");
	m_image->SetColorKey(255,0,255);
	m_image->DisplayFormat();

	ResizeTo(m_image->Width(),m_image->Height());

	m_visible = 0;
}

//----------------------------------------------------------------------
// FUNCTION: Cursor::~Cursor
//----------------------------------------------------------------------

Cursor::~Cursor()
{
	if (m_image) delete m_image;
}

//----------------------------------------------------------------------
// FUNCTION: Cursor::Draw
//----------------------------------------------------------------------

void Cursor::Draw(Rect rect)
{
	if (m_visible) DrawSurface(m_image,rect);
}

//----------------------------------------------------------------------
// FUNCTION: Cursor::Warp
//----------------------------------------------------------------------

void Cursor::Warp(int x, int y)
{
	SDL_WarpMouse(x,y);
}

//----------------------------------------------------------------------
// FUNCTION: Cursor::SetPosition
//----------------------------------------------------------------------

void Cursor::SetPosition(Point point)
{
	Rect r1 = Frame();
	
	if ((r1.x == point.x) &&
		(r1.y == point.y)) return;
	
	Invalidate();
	OffsetTo(point.x,point.y);
	Invalidate();
}

//----------------------------------------------------------------------
// FUNCTION: Cursor::Hide
//----------------------------------------------------------------------

void Cursor::Hide()
{
	m_visible = 0;
	Invalidate();
}

//----------------------------------------------------------------------
// FUNCTION: Cursor::Show
//----------------------------------------------------------------------

void Cursor::Show()
{
	m_visible = 1;
	Invalidate();
}

