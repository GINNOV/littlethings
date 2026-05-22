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

#ifndef CONSOLE_H
#define CONSOLE_H

#include "Surface.h"
#include "Window.h"
#include "Rect.h"
#include "RadarView.h"
#include "Font.h"

class Button;
class StringView;

class Console : public Window
{
public:
	
	RadarView* m_radar_view;
	StringView* m_status;

	Surface* m_frame_image;
	
	Button* m_button_table[8];
	
	int m_dragging;
	int m_drag_x;
	int m_drag_y;

	virtual int Contains(Point point);

public:

	Console();
	virtual ~Console();

	virtual void Draw(Rect rect);

	virtual void OnMouseMove(Point point);
	virtual void OnMouseDown(int n, Point point);
	virtual void OnMouseUp(int n, Point point);

	void SetStatus(const char* status);

public:

	void SetMap(Map* map) { m_radar_view->SetMap(map); }
	void SetMapView(MapView* view) { m_radar_view->SetMapView(view); }
	void SetRadarCursor(Rect rect) { m_radar_view->SetCursor(rect); }
	void ScanMap() { m_radar_view->ScanMap(); }
};

#endif

