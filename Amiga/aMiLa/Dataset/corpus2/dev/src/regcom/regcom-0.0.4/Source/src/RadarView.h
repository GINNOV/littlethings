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

#ifndef RADARVIEW_H
#define RADARVIEW_H

#include "Window.h"
#include "Rect.h"
#include "Point.h"

class Surface;
class Map;
class MapView;
class Console;

class RadarView : public Window
{
public:

	Console* m_console;

private:

	Map* m_map;
	MapView* m_mapview;

	Point m_viewport_pos;
	
	Rect m_cursor;

	Surface* m_image;

	int m_dragging;
	Point m_drag_corner;

	Rect m_visible_rect;

protected:

	void DrawMargins(Rect rect);
	void DrawMap(Rect rect);
	void DrawCursor(Rect rect);

	void PixelScanMap();
	void BlitScanMap();

public:

	RadarView();
	virtual ~RadarView();

	virtual void Draw(Rect rect);

	void SetMap(Map* map) { m_map = map; }
	void SetMapView(MapView* view) { m_mapview = view; }
	void ScanMap();

	void SetCursor(Rect& rect);

	virtual void OnMouseMove(Point point);
	virtual void OnMouseDown(int n, Point point);
	virtual void OnMouseUp(int n, Point point);
};

#endif
