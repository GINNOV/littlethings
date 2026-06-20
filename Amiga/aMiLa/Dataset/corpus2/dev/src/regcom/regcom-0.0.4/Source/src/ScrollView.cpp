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

#include "ScrollView.h"
#include "Surface.h"
#include "Point.h"
#include "Screen.h"

//----------------------------------------------------------------------
// FUNCTION: ScrollView::ScrollView
//----------------------------------------------------------------------

ScrollView::ScrollView()
{
	m_buffer = new Surface;
	m_viewport = Rect(0,0,0,0);

	m_px = 0.0;
	m_py = 0.0;
	m_vx = 0.0;
	m_vy = 0.0;

	m_xmin = 0.0;
	m_xmax = 0.0;
	m_ymin = 0.0;
	m_ymax = 0.0;

	m_pixel_vel = 0.0;
	m_pixel_acc = 0.0;

	m_oldx = 0;
	m_oldy = 0;

	m_state = 0;
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::~ScrollView
//----------------------------------------------------------------------

ScrollView::~ScrollView()
{
	delete m_buffer;
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::FrameResized
//----------------------------------------------------------------------

void ScrollView::FrameResized(int w, int h)
{
	m_viewport.w = w;
	m_viewport.h = h;

	m_buffer->Create(w,h);
	m_buffer->DisplayFormat();

	ViewportChanged();
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::Draw
//----------------------------------------------------------------------

void ScrollView::Draw(Rect rect)
{
	//------------------------------------------
	// calculate region values
	//------------------------------------------
	
	int xc = m_viewport.x % m_viewport.w;
	int yc = m_viewport.y % m_viewport.h;

	if (xc < 0) xc += m_viewport.w;
	if (yc < 0) yc += m_viewport.h;

	int w1 = xc;
	int h1 = yc;
	int w2 = m_viewport.w - xc;
	int h2 = m_viewport.h - yc;
	
	//------------------------------------------
	// create regions
	//------------------------------------------
	
	Rect a1( xc, yc, w2, h2 );
	Rect b1(  0, yc, w1, h2 );
	Rect c1( xc,  0, w2, h1 );
	Rect d1(  0,  0, w1, h1 );

	//------------------------------------------
	// clip regions
	//------------------------------------------

	Rect a2 = rect;
	Rect b2 = rect;
	Rect c2 = rect;
	Rect d2 = rect;

	a2.x += xc; a2.y += yc;
	b2.x -= w2; b2.y += yc;
	c2.x += xc; c2.y -= h2;
	d2.x -= w2; d2.y -= h2;

	a2 = a1.Intersection(a2);
	b2 = b1.Intersection(b2);
	c2 = c1.Intersection(c2);
	d2 = d1.Intersection(d2);

	//------------------------------------------
	// copy regions
	//------------------------------------------

	Point point = ConvertToScreen(Point(rect.x,rect.y));

	int x0 = point.x;
	int y0 = point.y;
	
	int x1 = (a2.w < 0) ? x0 : x0 + a2.w;
	int y1 = (a2.h < 0) ? y0 : y0 + a2.h;
	
	if (a2.IsValid()) m_buffer->Blit(Screen::Instance(), &a2, x0, y0 );
	if (b2.IsValid()) m_buffer->Blit(Screen::Instance(), &b2, x1, y0 );
	if (c2.IsValid()) m_buffer->Blit(Screen::Instance(), &c2, x0, y1 );
	if (d2.IsValid()) m_buffer->Blit(Screen::Instance(), &d2, x1, y1 );
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::UpdateRect
//----------------------------------------------------------------------

void ScrollView::UpdateRect(Rect& rect, bool clip /* = true */ )
{
	//------------------------------------------
	// clip against viewport
	//------------------------------------------

	if (clip) rect = m_viewport.Intersection(rect);

	if (!rect.IsValid()) return;

	//------------------------------------------
	// calculate rotary boundaries
	//------------------------------------------

	int x = m_viewport.x;
	int y = m_viewport.y;
	int w = m_viewport.w;
	int h = m_viewport.h;
	
	int x1 = (x / w) * w;
	int y1 = (y / h) * h;

	if (x < 0) x1 -= w;
	if (y < 0) y1 -= h;
	
	int x2 = x1 + w;
	int y2 = y1 + h;

	//------------------------------------------
	// handle window invalidation
	//------------------------------------------

	if (clip)
	{
		Rect r = rect;

		r.x -= m_viewport.x;
		r.y -= m_viewport.y;
	
		Invalidate(r);
	}

	//------------------------------------------
	// handle vertical splits
	//------------------------------------------
	
	if ( (rect.x < x2) && ((rect.x + rect.w) > x2) )
	{
		Rect a = Rect(rect.x,rect.y,x2-rect.x,rect.h);
		Rect b = Rect(x2,rect.y,rect.w-(x2-rect.x),rect.h);
		UpdateRect(a,false);
		UpdateRect(b,false);
		return;
	}
	
	//------------------------------------------
	// handle horizontal splits
	//------------------------------------------
	
	if ( (rect.y < y2) && ((rect.y + rect.h) > y2) )
	{
		Rect a = Rect(rect.x,rect.y,rect.w,y2-rect.y);
		Rect b = Rect(rect.x,y2,rect.w,rect.h-(y2-rect.y));
		UpdateRect(a,false);
		UpdateRect(b,false);
		return;
	}

	//------------------------------------------
	// transfer to buffer
	//------------------------------------------
	
	int bx = (rect.x - x1) % w;
	int by = (rect.y - y1) % h;

	DrawImage(rect,m_buffer,bx,by);
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::Scroll
//----------------------------------------------------------------------

void ScrollView::Scroll(int dx, int dy)
{
	//------------------------------------------
	// adjust viewport corner 
	//------------------------------------------
	
	m_viewport.x += dx;
	m_viewport.y += dy;

	ViewportChanged();

	Invalidate();

	int x = m_viewport.x;
	int y = m_viewport.y;
	int w = m_viewport.w;
	int h = m_viewport.h;

	//------------------------------------------
	// calculate dirty rectangles
	//------------------------------------------

	Rect a(x,y,0,0);
	Rect b(x,y,0,0);

	if (dx > 0)	a = Rect(x+w-dx,y,dx,h);
	if (dx < 0) a = Rect(x,y,-dx,h);
	if (dy > 0)	b = Rect(x,y+h-dy,w,dy);
	if (dy < 0)	b = Rect(x,y,w,-dy);

	//------------------------------------------
	// eliminate diagonal overlap
	//------------------------------------------
	
	if ((a.w > 0) && (b.w > 0))
	{
		if (b.x == a.x) b.x += a.w;
		if (b.w < a.w)
			b.w = 0;
		else b.w -= a.w;
	}

	//------------------------------------------
	// update dirty rectangles
	//------------------------------------------

	UpdateRect(a);
	UpdateRect(b);
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::Refresh
//----------------------------------------------------------------------

void ScrollView::Refresh()
{
	m_xmin = 0;
	m_xmax =
		(float)(GetImageWidth() - GetViewport().w);

	m_ymin = 0;
	m_ymax =
		(float)(GetImageHeight() - GetViewport().h);

	if (m_xmax < 0) m_xmin = m_xmax =
		(float)GetImageWidth() / 2 - (float)GetViewport().w / 2;		
	
	if (m_ymax < 0) m_ymin = m_ymax =
		(float)GetImageHeight() / 2 - (float)GetViewport().h / 2;

	if (m_px < m_xmin) m_px = m_xmin;
	if (m_px > m_xmax) m_px = m_xmax;
	if (m_py < m_ymin) m_py = m_ymin;
	if (m_py > m_ymax) m_py = m_ymax;

	m_oldx = (int)(m_px + 0.5);
	m_oldy = (int)(m_py + 0.5);

	Warp(m_oldx,m_oldy);

	UpdateRect(m_viewport,false);
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::Warp
//----------------------------------------------------------------------

void ScrollView::Warp(int x, int y)
{
	int dx = x - m_viewport.x;
	int dy = y - m_viewport.y;

	Scroll(dx,dy);
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::UpdateVScroll
//----------------------------------------------------------------------

void ScrollView::UpdateVScroll(float dt)
{
	float target = 0.0;

	switch (m_state&(SCROLLVIEWSTATE_UP|SCROLLVIEWSTATE_DOWN))
	{
	case SCROLLVIEWSTATE_UP:	target = -m_pixel_vel; break;
	case SCROLLVIEWSTATE_DOWN:	target = +m_pixel_vel; break;
	}
	
	if (m_vy > target)
	{
		m_vy -= m_pixel_acc * dt;
		if (m_vy < target) m_vy = target;
	}

	if (m_vy < target)
	{
		m_vy += m_pixel_acc * dt;
		if (m_vy > target) m_vy = target;
	}

	m_py += m_vy * dt;

	if (m_py < m_ymin) { m_py = m_ymin; m_vy = 0; }
	if (m_py > m_ymax) { m_py = m_ymax; m_vy = 0; }
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::UpdateHScroll
//----------------------------------------------------------------------

void ScrollView::UpdateHScroll(float dt)
{
	float target = 0.0;

	switch (m_state&(SCROLLVIEWSTATE_LEFT|SCROLLVIEWSTATE_RIGHT))
	{
	case SCROLLVIEWSTATE_LEFT:	target = -m_pixel_vel; break;
	case SCROLLVIEWSTATE_RIGHT:	target = +m_pixel_vel; break;
	}
	
	if (m_vx > target)
	{
		m_vx -= m_pixel_acc * dt;
		if (m_vx < target) m_vx = target;
	}

	if (m_vx < target)
	{
		m_vx += m_pixel_acc * dt;
		if (m_vx > target) m_vx = target;
	}

	m_px += m_vx * dt;

	if (m_px < m_xmin) { m_px = m_xmin; m_vx = 0; }
	if (m_px > m_xmax) { m_px = m_xmax; m_vx = 0; }
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::Update
//----------------------------------------------------------------------

void ScrollView::Update(float dt)
{
	UpdateVScroll(dt);
	UpdateHScroll(dt);

	int x = (int)(m_px + 0.5);
	int y = (int)(m_py + 0.5);

	if ((x != m_oldx) || (y != m_oldy))
	{
		int dx = x - m_oldx;
		int dy = y - m_oldy;

		Scroll(dx,dy);
			
		m_oldx = x;
		m_oldy = y;
	}
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::GetCenter
//----------------------------------------------------------------------

Point ScrollView::GetCenter()
{
	Point point;
	point.x = (int)(m_px+0.5) + m_viewport.w/2;
	point.y = (int)(m_py+0.5) + m_viewport.h/2;
	return point;
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::SetCenter
//----------------------------------------------------------------------

void ScrollView::SetCenter(Point point)
{
	m_px = (float)point.x - m_viewport.w/2;
	m_py = (float)point.y - m_viewport.h/2;
}

//----------------------------------------------------------------------
// FUNCTION: ScrollView::SetCorner
//----------------------------------------------------------------------

void ScrollView::SetCorner(Point point)
{
	m_px = (float)point.x;
	m_py = (float)point.y;
}
