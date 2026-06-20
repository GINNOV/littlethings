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

#ifndef RECT_H
#define RECT_H

#include "Point.h"

class Rect
{
public:

	int x,y,w,h;

public:

	Rect() {}

	virtual ~Rect() {}

	Rect(int x, int y, int w, int h)
	{
		this->x = x;
		this->y = y;
		this->w = w;
		this->h = h;
	}

	Rect(const Point& a, const Point& b)
	{
		x = a.x;
		y = a.y;
		
		w = b.x - a.x;
		h = b.y - a.y;
	}

	Point UpperLeft() const { return Point(x,y); }
	Point LowerRight() const { return Point(x+w,y+h); }

	bool Contains(const Point& point) const
	{
		return (point.x >= x) && (point.x <= x + w) && 
			(point.y >= y) && (point.y <= y + h);
	}

	bool Contains(const Rect& rect) const
	{
		return Contains(rect.UpperLeft()) &&
			Contains(rect.LowerRight());
	}

	Rect Intersection(const Rect& rect) const
	{
		int x0 = x > rect.x ? x : rect.x;
		int y0 = y > rect.y ? y : rect.y;

		int x1 = x + w < rect.x + rect.w ? x + w : rect.x + rect.w;
		int y1 = y + h < rect.y + rect.h ? y + h : rect.y + rect.h;

		return Rect(Point(x0,y0),Point(x1,y1));
	}

	Rect Union(const Rect& rect) const
	{
		int x0 = x < rect.x ? x : rect.x;
		int y0 = y < rect.y ? y : rect.y;
		
		int x1 = x + w > rect.x + rect.w ? x + w : rect.x + rect.w;
		int y1 = y + h > rect.y + rect.h ? y + h : rect.y + rect.h;

		return Rect(Point(x0,y0),Point(x1,y1));
	}

	bool IsValid() const { return (w >= 0) && (h >= 0); }
};

#endif
