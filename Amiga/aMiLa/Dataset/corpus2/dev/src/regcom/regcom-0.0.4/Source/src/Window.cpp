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

#include "Window.h"
#include "Screen.h"

Window* Window::m_capture_view = NULL;
Rect Window::m_capture_rect;
Point Window::m_mouse_position;
int Window::m_mouse_override = 0;

int Window::m_debug_dirty_rectangles = 0;

//----------------------------------------------------------------------      
// FUNCTION: Window::Window
//----------------------------------------------------------------------

Window::Window()
{
	m_frame = Rect(0,0,0,0);

	m_parent = NULL;
	m_last_child = NULL;
	m_first_child = NULL;
	m_next_sibling = NULL;
	m_prev_sibling = NULL;
}

//----------------------------------------------------------------------      
// FUNCTION: Window::~Window
//----------------------------------------------------------------------

Window::~Window()
{
}

//----------------------------------------------------------------------      
// FUNCTION: Window::Update
//----------------------------------------------------------------------

void Window::Update(Rect rect)
{
	Draw(rect);

	if (m_debug_dirty_rectangles)
	{
		int x0 = rect.x;
		int y0 = rect.y;
		int x1 = x0 + rect.w - 1;
		int y1 = y0 + rect.h - 1;

		FillRect(Rect(x0,y0,rect.w,1),255,255,255);
		FillRect(Rect(x0,y0,1,rect.h),255,255,255);
		FillRect(Rect(x0,y1,rect.w,1),255,255,255);
		FillRect(Rect(x1,y0,1,rect.h),255,255,255);
	}
	
	Window* window = m_first_child;
	
	while (window)
	{
		Rect new_rect = rect;

		new_rect.x -= window->Frame().x;
		new_rect.y -= window->Frame().y;

		new_rect = window->Bounds().Intersection(new_rect);

		if (new_rect.IsValid())
			window->Update(new_rect);
		
		window = window->m_next_sibling;
	}
}

//----------------------------------------------------------------------      
// FUNCTION: Window::CaptureMouse
//----------------------------------------------------------------------

void Window::CaptureMouse(Rect rect)
{
	m_capture_view = this;
	m_capture_rect = rect;
}

//----------------------------------------------------------------------      
// FUNCTION: Window::ReleaseMouse
//----------------------------------------------------------------------

void Window::ReleaseMouse()
{
	m_capture_view = NULL;
}

//----------------------------------------------------------------------      
// FUNCTION: Window::AddChild
//----------------------------------------------------------------------

void Window::AddChild(Window* window)
{
	window->m_parent = this;

	if (m_last_child == NULL)
	{
		m_last_child = window;
		m_first_child = window;
	}
	else
	{
		m_last_child->m_next_sibling = window;
		window->m_prev_sibling = m_last_child;
		m_last_child = window;
	}
}

//----------------------------------------------------------------------      
// FUNCTION: Window::FindWindow
//----------------------------------------------------------------------

Window* Window::FindWindow(Point point)
{
	Window* window = m_last_child;

	point.x -= Frame().x;
	point.y -= Frame().y;

	while (window)
	{
		if (window->Contains(point))
			return window->FindWindow(point);
		window = window->m_prev_sibling;
	}
	
	return this;
}

//----------------------------------------------------------------------      
// FUNCTION: Window::OnMouse
//----------------------------------------------------------------------

void Window::OnMouseMove(Point point) { }
void Window::OnMouseDown(int n, Point point) { }
void Window::OnMouseUp(int n, Point point) { }

//----------------------------------------------------------------------      
// FUNCTION: Window::Invalidate
//----------------------------------------------------------------------

void Window::Invalidate(Rect rect)
{
	if (m_parent)
	{
		rect.x += Frame().x;
		rect.y += Frame().y;

		m_parent->Invalidate(rect);
	}
}

void Window::Invalidate()
{
	Invalidate(Bounds());
}

//----------------------------------------------------------------------      
// FUNCTION: Window::DrawSurface
//----------------------------------------------------------------------

void Window::DrawSurface(Surface* surface, Rect rect)
{
	Point point = ConvertToScreen(Point(rect.x,rect.y));
	surface->Blit(Screen::Instance(),&rect,point.x,point.y);
}

void Window::DrawSurface(Surface* surface, Rect src, Rect dst)
{
	Point point = ConvertToScreen(Point(dst.x,dst.y));
	surface->Blit(Screen::Instance(),&src,point.x,point.y);
}

//----------------------------------------------------------------------      
// FUNCTION: Window::FillRect
//----------------------------------------------------------------------

void Window::FillRect(Rect rect, int r, int g, int b)
{
	if (rect.IsValid())
	{
		Point point = ConvertToScreen(Point(rect.x,rect.y));
		rect.x = point.x;
		rect.y = point.y;
		Screen::Instance()->FillRect(&rect,r,g,b);
	}
}

//----------------------------------------------------------------------      
// FUNCTION: Window::ResizeTo
//----------------------------------------------------------------------

void Window::ResizeTo(int w, int h)
{
	m_frame.w = w;
	m_frame.h = h;

	FrameResized(m_frame.w,m_frame.h);
}

//----------------------------------------------------------------------      
// FUNCTION: Window::ResizeBy
//----------------------------------------------------------------------

void Window::ResizeBy(int w, int h)
{
	m_frame.w += w;
	m_frame.h += h;

	FrameResized(m_frame.w,m_frame.h);
}

//----------------------------------------------------------------------      
// FUNCTION: Window::OffsetTo
//----------------------------------------------------------------------

void Window::OffsetTo(int x, int y)
{
	m_frame.x = x;
	m_frame.y = y;

	FrameMoved(Point(m_frame.x,m_frame.y));
}

//----------------------------------------------------------------------      
// FUNCTION: Window::OffsetBy
//----------------------------------------------------------------------

void Window::OffsetBy(int x, int y)
{
	m_frame.x += x;
	m_frame.y += y;

	FrameMoved(Point(m_frame.x,m_frame.y));
}

void Window::FrameMoved(Point point) { }
void Window::FrameResized(int w, int h) { }

