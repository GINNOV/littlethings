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

#include "RadarView.h"
#include "Surface.h"
#include "Map.h"
#include "Tile.h"
#include "MapView.h"
#include "Console.h"
#include "Screen.h"

//----------------------------------------------------------------------
// FUNCTION: RadarView::RadarView
//----------------------------------------------------------------------

RadarView::RadarView()
{
	m_map = NULL;
	m_mapview = NULL;
	
	m_viewport_pos = Point(0,0);

	m_cursor = Rect(0,0,0,0);

	m_image = new Surface;

	m_dragging = 0;
	m_drag_corner = Point(0,0);

	m_visible_rect = Rect(0,0,0,0);
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::~RadarView
//----------------------------------------------------------------------

RadarView::~RadarView()
{
	delete m_image;
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::DrawMargins
//----------------------------------------------------------------------

void RadarView::DrawMargins(Rect rect)
{
	Rect clip = Rect(
		-m_visible_rect.x,-m_visible_rect.y,
		Width(),Height());

	int x = 0;
	int y = 0;

	// draw left margin
	if (clip.x < 0)
	{
		int delta = -clip.x;
		Rect a(x,y,delta,clip.h);
		a = rect.Intersection(a);
		if (a.IsValid()) FillRect(a,0,0,0);
		clip.x += delta;
		clip.w -= delta;
		x += delta;
	}

	// draw right margin
	if (clip.x + clip.w > m_map->GetWidth())
	{
		int delta = clip.x + clip.w - m_map->GetWidth();
		Rect a(x+clip.w-delta,y,delta,clip.h);
		a = rect.Intersection(a);
		if (a.IsValid()) FillRect(a,0,0,0);
		clip.w -= delta;
	}

	// draw top margin
	if (clip.y < 0)
	{
		int delta = -clip.y;
		Rect a(x,y,clip.w,delta);
		a = rect.Intersection(a);
		if (a.IsValid()) FillRect(a,0,0,0);
		clip.y += delta;
		clip.h -= delta;
		y += delta;
	}

	// draw bottom margin
	if (clip.y + clip.h > m_map->GetHeight())
	{
		int delta = clip.y + clip.h - m_map->GetHeight();
		Rect a(x,y+clip.h-delta,clip.w,delta);
		a = rect.Intersection(a);
		if (a.IsValid()) FillRect(a,0,0,0);
		clip.h -= delta;
	}
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::DrawMap
//----------------------------------------------------------------------

void RadarView::DrawMap(Rect rect)
{
	Rect src = Rect(
		-m_visible_rect.x+m_viewport_pos.x+rect.x,
		-m_visible_rect.y+m_viewport_pos.y+rect.y,
		rect.w,rect.h);

	Rect dst = rect;

	DrawSurface(m_image,src,dst);
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::DrawCursor
//----------------------------------------------------------------------

void RadarView::DrawCursor(Rect rect)
{
	int x0 = m_cursor.x - m_viewport_pos.x + m_visible_rect.x;
	int y0 = m_cursor.y - m_viewport_pos.y + m_visible_rect.y;

	Rect a(x0,y0,1,m_cursor.h);
	Rect b(x0,y0,m_cursor.w,1);
	Rect c(x0+m_cursor.w,y0,1,m_cursor.h+1);
	Rect d(x0,y0+m_cursor.h,m_cursor.w+1,1);

	a = rect.Intersection(a);
	b = rect.Intersection(b);
	c = rect.Intersection(c);
	d = rect.Intersection(d);

	if (a.IsValid()) FillRect(a,255,255,255);
	if (b.IsValid()) FillRect(b,255,255,255);
	if (c.IsValid()) FillRect(c,255,255,255);
	if (d.IsValid()) FillRect(d,255,255,255);
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::Draw
//----------------------------------------------------------------------

void RadarView::Draw(Rect rect)
{
	DrawMargins(rect);
	DrawMap(rect);
	DrawCursor(rect);
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::SetCursor
//----------------------------------------------------------------------

void RadarView::SetCursor(Rect& rect)
{
	m_cursor = rect;

	int x1 = m_cursor.x;
	int y1 = m_cursor.y;
	
	int x2 = x1 + m_cursor.w + 1;
	int y2 = y1 + m_cursor.h + 1;
	
	if (x2 > (m_viewport_pos.x + Width()))
		m_viewport_pos.x = x2 - Width();

	if (y2 > (m_viewport_pos.y + Height()))
		m_viewport_pos.y = y2 - Height();

	if (x1 < m_viewport_pos.x) m_viewport_pos.x = x1;
	if (y1 < m_viewport_pos.y) m_viewport_pos.y = y1;

	if (m_viewport_pos.x < 0) m_viewport_pos.x = 0;
	if (m_viewport_pos.y < 0) m_viewport_pos.y = 0;

	if (m_cursor.w > m_map->GetWidth())
	{
		m_cursor.x = 0;
		m_cursor.w = m_map->GetWidth()-1;
	}

	if (m_cursor.h > m_map->GetHeight())
	{
		m_cursor.y = 0;
		m_cursor.h = m_map->GetHeight()-1;
	}

	if (m_dragging)
	{
		Point c;

		c.x = m_cursor.x + m_cursor.w/2 + m_visible_rect.x - m_viewport_pos.x;
		c.y = m_cursor.y + m_cursor.h/2 + m_visible_rect.y - m_viewport_pos.y;
	
		m_mouse_position = ConvertToScreen(c);
	}

	Invalidate();
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::PixelScanMap
//----------------------------------------------------------------------

void RadarView::PixelScanMap()
{
	Surface pixels;
	pixels.Load("Pixels.bmp");
	
	int w = m_map->GetWidth();
	int h = m_map->GetHeight();

	m_image->Create(w,h);
	m_image->GetPalette(&pixels);

	pixels.Lock();
	m_image->Lock();

	Uint8* src = (Uint8*)pixels.Pixels();
	Uint8* dst = (Uint8*)m_image->Pixels();

	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			int sx,sy;

			Tile* tile = m_map->GetTile(x,y);
			
			if (tile->IsWater())
				{ sx = 24; sy = 5; }
			else if (tile->IsLight())
			{
				if ((x&1)==(y&1))
					{ sx = 20; sy = 3; }
				else { sx = 22; sy = 2; }
			}
			else if (tile->IsWoods())
				{ sx = 20; sy = 3; }
			else { sx = 22; sy = 2; }

			if ((x > 0) && (y > 0))
			{
				int level0 = tile->GetLevel();
				int level1 = m_map->GetTile(x-1,y-1)->GetLevel();
				
				if (((y&31) == 0) ||
					((x&31) == 0) ||
					(level0 > level1)) sx += 4;
				
				if (((y&31) == 31) ||
					((x&31) == 31) ||
					(level0 < level1)) sx -= 4;
			}
			else sx += 4;

			*dst++ = *(src + sy * pixels.Pitch() + sx);
		}

		dst += m_image->Pitch() - w;
	}

	pixels.Unlock();
	m_image->Unlock();
	m_image->DisplayFormat();
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::BlitScanMap
//----------------------------------------------------------------------

void RadarView::BlitScanMap()
{
	Surface pixels;
	pixels.Load("Pixels.bmp");
	
	int w = m_map->GetWidth();
	int h = m_map->GetHeight();

	m_image->Create(w,h);

	Rect pixel;

	for (int y = 0; y < h; y++)
	{
		for (int x = 0; x < w; x++)
		{
			Tile* tile = m_map->GetTile(x,y);
			
			if (tile->IsWater())
				pixel = Rect(24,5,1,1);
			else if (tile->IsLight())
			{
				if ((x&1)==(y&1))
					pixel = Rect(20,3,1,1);
				else pixel = Rect(22,2,1,1);
			}
			else if (tile->IsWoods())
				pixel = Rect(20,3,1,1);
			else pixel = Rect(22,2,1,1);

			if ((x > 0) && (y > 0))
			{
				int level0 = tile->GetLevel();
				int level1 = m_map->GetTile(x-1,y-1)->GetLevel();
				
				if (level0 > level1) pixel.x += 4;
				if (level0 < level1) pixel.x -= 4;
			}

			pixels.LowerBlit(m_image,&pixel,x,y);
		}
	}

	pixels.DisplayFormat();
}

//----------------------------------------------------------------------
// FUNCTION: RadarView::ScanMap
//----------------------------------------------------------------------

void RadarView::ScanMap()
{
	//--------------------------------------------------
	// calculate visible region
	//--------------------------------------------------
	
	m_visible_rect = Bounds();

	if (m_map->GetWidth() < Width())
	{
		m_visible_rect.x = Width()/2 - m_map->GetWidth()/2;
		m_visible_rect.w = m_map->GetWidth();
	}

	if (m_map->GetHeight() < Height())
	{
		m_visible_rect.y = Height()/2 - m_map->GetHeight()/2;
		m_visible_rect.h = m_map->GetHeight();
	}

	//--------------------------------------------------
	// scan map into image
	//--------------------------------------------------
	
	PixelScanMap();

	Invalidate();
}

//----------------------------------------------------------------------      
// FUNCTION: RadarView::OnMouseMove
//----------------------------------------------------------------------

void RadarView::OnMouseMove(Point point)
{
	Point a,b,c;

	m_console->SetStatus("Radar");

	if (!m_dragging) return;

	//--------------------------------------------------
	// calculate delta and recenter mouse
	//--------------------------------------------------
	
	int dx = point.x - Width() / 2;
	int dy = point.y - Height() / 2;

	if ((dx==0)&&(dy==0)) return;

	c.x = (int)(Width()/2);
	c.y = (int)(Height()/2);
	
	c = ConvertToScreen(c);

	SDL_WarpMouse(c.x,c.y);

	//--------------------------------------------------
	// adjust and clip radar cursor
	//--------------------------------------------------

	c = m_drag_corner;
	
	c.x += dx;
	c.y += dy;

	a = Point(0,0);
	
	b = Point(m_map->GetWidth()-m_cursor.w,
			m_map->GetHeight()-m_cursor.h);

	if (c.x < a.x) c.x = a.x;
	if (c.y < a.y) c.y = a.y;
	if (c.x > b.x) c.x = b.x;
	if (c.y > b.y) c.y = b.y;

	m_drag_corner = c;
	
	m_mapview->WarpToTile(m_drag_corner);
}

//----------------------------------------------------------------------      
// FUNCTION: RadarView::OnMouseDown
//----------------------------------------------------------------------

void RadarView::OnMouseDown(int n, Point point)
{
	Point a,b,c;

	m_dragging = 1;
	m_mouse_override = 1;

	//--------------------------------------------------
	// capture mouse and center in view
	//--------------------------------------------------
	
	a = ConvertToScreen(Point(0,0));
	b = ConvertToScreen(Point(Width(),Height()));

	Rect rect;

	rect.x = a.x;
	rect.y = a.y;
	rect.w = b.x - a.x;
	rect.h = b.y - a.y;

	CaptureMouse(rect);

	c.x = Width() / 2;
	c.y = Height() / 2;

	c = ConvertToScreen(c);

	SDL_WarpMouse(c.x,c.y);

	//--------------------------------------------------
	// align radar cursor and mouse image
	//--------------------------------------------------

	c = point;

	c.x -= m_cursor.w/2 + m_visible_rect.x;
	c.y -= m_cursor.h/2 + m_visible_rect.y;
	
	a = Point(0,0);

	b = Point(m_visible_rect.w-m_cursor.w-1,
		m_visible_rect.h-m_cursor.h-1);

	if (c.x < a.x) c.x = a.x;
	if (c.y < a.y) c.y = a.y;
	if (c.x > b.x) c.x = b.x;
	if (c.y > b.y) c.y = b.y;

	m_drag_corner.x = c.x + m_viewport_pos.x;
	m_drag_corner.y = c.y + m_viewport_pos.y;

	m_mapview->WarpToTile(m_drag_corner);
}

//----------------------------------------------------------------------      
// FUNCTION: RadarView::OnMouseUp
//----------------------------------------------------------------------

void RadarView::OnMouseUp(int n, Point point)
{
	if (!m_dragging) return;

	SDL_WarpMouse(m_mouse_position.x,m_mouse_position.y);

	ReleaseMouse();
	m_mouse_override = 0;
	m_dragging = 0;
}

