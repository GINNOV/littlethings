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

#ifndef SCROLLVIEW_H
#define SCROLLVIEW_H

#include "Window.h"
#include "Surface.h"
#include "Rect.h"

class Point;

typedef enum SCROLLVIEWSTATE
{
	SCROLLVIEWSTATE_UP		= 0x0001,
	SCROLLVIEWSTATE_DOWN	= 0x0002,
	SCROLLVIEWSTATE_LEFT	= 0x0004,
	SCROLLVIEWSTATE_RIGHT	= 0x0008

} SCROLLVIEWSTATE;

class ScrollView : public Window
{
public:

	Surface* m_buffer;
	Rect m_viewport;

	float m_vx;
	float m_vy;

	float m_xmin;
	float m_xmax;
	float m_ymin;
	float m_ymax;

	float m_pixel_vel;	// pixels/sec
	float m_pixel_acc;	// pixels/sec/sec

	int m_oldx;
	int m_oldy;

	int m_state;

protected:

	float m_px;
	float m_py;

	virtual void DrawImage(
		Rect rect, Surface* surface, int x, int y) = 0;

	virtual void ViewportChanged() = 0;
	
	void UpdateRect(Rect& rect, bool clip = true);

	virtual int GetImageWidth() = 0;
	virtual int GetImageHeight() = 0;

	void UpdateVScroll(float dt);
	void UpdateHScroll(float dt);

public:

	ScrollView();
	virtual ~ScrollView();

	virtual void FrameResized(int w, int h);

	void Scroll(int dx, int dy);
	void Warp(int x, int y);
	
	virtual void Draw(Rect rect);

	Rect GetViewport() { return m_viewport; }

	void Refresh();

	void SetVelocity(float vel) { m_pixel_vel = vel; }
	void SetAcceleration(float acc) { m_pixel_acc = acc; }
	void Update(float dt);

	Point GetCenter();
	void SetCenter(Point point);
	void SetCorner(Point point);

	void SetState(int state) { m_state |= state; }
	void ClearState(int state) { m_state &= ~state; }
};

#endif
