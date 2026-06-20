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

#include "Desktop.h"

#include "Screen.h"

#include "SDL.h"

//----------------------------------------------------------------------      
// FUNCTION: Desktop::Desktop
//----------------------------------------------------------------------

Desktop::Desktop()
{
	m_dirty_count = 0;
}

//----------------------------------------------------------------------      
// FUNCTION: Desktop::~Desktop
//----------------------------------------------------------------------

Desktop::~Desktop()
{
}

//----------------------------------------------------------------------      
// FUNCTION: Desktop::Invalidate
//----------------------------------------------------------------------

void Desktop::Invalidate(Rect rect)
{
	rect = Bounds().Intersection(rect);

	if (!rect.IsValid()) return;

	int n;

	Rect new_dirty_rects[DESKTOP_MAXDIRTY];

	int new_dirty_count = 0;

	// for each dirty rectangle
	for (n = 0; n < m_dirty_count; n++)
	{
		// get old rectangle from the list
		Rect dirty = m_dirty_rects[n];
		
		// check if new rectangle is covered by old
		if (dirty.Contains(rect)) return;

		// get intersection of rectangles
		Rect intersect = rect.Intersection(dirty);

		// check if intersection is valid
		if (intersect.IsValid())
		{
			// get union of rectangles
			Rect u = rect.Union(dirty);

			// check if it's cheaper to use the union
			if ((dirty.w*dirty.h + rect.w*rect.h) > u.w*u.h)
			{
				// use the union
				m_dirty_rects[n] = u;
				return;
			}
		}

		// make sure new isn't covering old
		if (!rect.Contains(dirty))
		{
			// copy old rectangle into the new list
			new_dirty_rects[new_dirty_count++] = 
				m_dirty_rects[n];
		}
	}

	m_dirty_count = new_dirty_count;

	for (n = 0; n < m_dirty_count; n++)
	{
		m_dirty_rects[n] = new_dirty_rects[n];
	}

	if (m_dirty_count < DESKTOP_MAXDIRTY)
	{
		m_dirty_rects[m_dirty_count++] = rect;
	}
}

void Desktop::Invalidate()
{
	m_dirty_rects[0] = Bounds();
	m_dirty_count = 1;
}

//----------------------------------------------------------------------
// FUNCTION: Desktop::Update
//----------------------------------------------------------------------

void Desktop::Update(Rect rect)
{
	Window::Update(rect);
}

void Desktop::Update()
{
	if (m_dirty_count)
	{
		if (m_dirty_count == DESKTOP_MAXDIRTY)
		{
			m_dirty_rects[0] = Bounds();
			m_dirty_count = 1;
		}

		SDL_Rect rects[DESKTOP_MAXDIRTY];

		for (int n = 0; n < m_dirty_count; n++)
		{
			Rect rect = m_dirty_rects[n];

			Update(rect);

			rects[n].x = rect.x;
			rects[n].y = rect.y;
			rects[n].w = rect.w;
			rects[n].h = rect.h;
		}
			
		SDL_UpdateRects(SDL_GetVideoSurface(),
			m_dirty_count,rects);

		m_dirty_count = 0;
	}

//	Screen::Instance()->Flip();

}
