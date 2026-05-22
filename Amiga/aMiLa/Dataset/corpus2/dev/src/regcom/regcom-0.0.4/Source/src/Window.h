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

#ifndef WINDOW_H
#define WINDOW_H

#include "Rect.h"
#include "Point.h"
#include "Surface.h"

class Window
{
private:

	Rect m_frame;

public:

	Window* m_parent;
	Window* m_first_child;
	Window* m_last_child;
	Window* m_prev_sibling;
	Window* m_next_sibling;

public:

	static Window* m_capture_view;
	static Rect m_capture_rect;
	static Point m_mouse_position;
	static int m_mouse_override;

	static int m_debug_dirty_rectangles;

	void CaptureMouse(Rect rect);
	void ReleaseMouse();

	void AddChild(Window* window);
	Window* FindWindow(Point point);

	Point ConvertFromScreen(Point point)
	{
		point.x -= m_frame.x;
		point.y -= m_frame.y;
		if (m_parent)
			return m_parent->ConvertFromScreen(point);
		else return point;
	}

	Point ConvertToScreen(Point point)
	{
		point.x += m_frame.x;
		point.y += m_frame.y;
		if (m_parent)
			return m_parent->ConvertToScreen(point);
		else return point;
	}

public:

	Window();
	virtual ~Window();

	virtual void Update(Rect rect);

	virtual void Draw(Rect rect) { }
	
	void DrawSurface(Surface* surface, Rect rect);
	void DrawSurface(Surface* surface, Rect src, Rect dst);
	void FillRect(Rect rect, int r, int g, int b);

	virtual void OnMouseMove(Point point);
	virtual void OnMouseDown(int n, Point point);
	virtual void OnMouseUp(int n, Point point);

	virtual void Invalidate(Rect rect);
	virtual void Invalidate();

	Rect Bounds() {return Rect(0,0,m_frame.w,m_frame.h); }
	Rect Frame() { return m_frame; }

	void ResizeTo(int w, int h);
	void ResizeBy(int w, int h);
	void OffsetTo(int x, int y);
	void OffsetBy(int x, int y);

	virtual void FrameMoved(Point point);
	virtual void FrameResized(int w, int h);

	int Width() { return m_frame.w; }
	int Height() { return m_frame.h; }

	virtual int Contains(Point point) { return m_frame.Contains(point); }
};

#endif
