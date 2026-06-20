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

#include "Console.h"
#include "RadarView.h"
#include "Surface.h"
#include "RadarView.h"
#include "StringView.h"
#include "Button.h"
#include "Font.h"
#include "Game.h"
#include "Screen.h"

#include <string.h>

#define BUTTON_COUNT 5
#define BUTTON_X0 6
#define BUTTON_Y0 156
#define BUTTON_WIDTH 40
#define BUTTON_HEIGHT 16

static struct
{
	int x,y;
	int code;
	char* status;
}
button_data[BUTTON_COUNT] =
{
	{ BUTTON_X0, BUTTON_Y0 + 0*BUTTON_HEIGHT,
		GAMEUSEREVENT_ZOOMIN, "Zoom in" },
	{ BUTTON_X0, BUTTON_Y0 + 1*BUTTON_HEIGHT,
		GAMEUSEREVENT_ZOOMOUT, "Zoom out" },
	{ BUTTON_X0, BUTTON_Y0 + 2*BUTTON_HEIGHT,
		GAMEUSEREVENT_TOGGLEGRID, "Toggle grid" },
	{ BUTTON_X0, BUTTON_Y0 + 3*BUTTON_HEIGHT,
		GAMEUSEREVENT_NEWMAP, "New map" },
	{ BUTTON_X0, BUTTON_Y0 + 4*BUTTON_HEIGHT,
		GAMEUSEREVENT_QUITGAME, "Quit game" }
};

//----------------------------------------------------------------------
// FUNCTION: Console::Console
//----------------------------------------------------------------------

Console::Console()
{
	//-----------------------------------------

	m_dragging = 0;
	m_drag_x = 0;
	m_drag_y = 0;

	m_frame_image = new Surface;
	m_frame_image->Load("Console.bmp");
	m_frame_image->SetColorKey(255,0,255);
	m_frame_image->DisplayFormat();

	ResizeTo(m_frame_image->Width(),m_frame_image->Height());

	//-----------------------------------------

	m_radar_view = new RadarView;
	m_radar_view->ResizeTo(128,128);
	m_radar_view->OffsetTo(6,22);

	m_radar_view->m_console = this;

	AddChild(m_radar_view);

	//-----------------------------------------

	m_status = new StringView;
	m_status->ResizeTo(83,14);
	m_status->OffsetTo(51,154);

	m_status->LoadFontImage("ConsoleFont.bmp");

	AddChild(m_status);

	//-----------------------------------------

	Surface button_image;
	button_image.Load("Buttons.bmp");
	button_image.DisplayFormat();

	for (int n = 0; n < BUTTON_COUNT; n++)
	{
		Button* button = new Button;
		
		button->ResizeTo(BUTTON_WIDTH,BUTTON_HEIGHT);
		button->OffsetTo(button_data[n].x,button_data[n].y);

		button->m_code = button_data[n].code;
		button->SetStatus(button_data[n].status);

		for (int i = 0; i < 4; i++)
		{
			Rect src(n*BUTTON_WIDTH,i*BUTTON_HEIGHT,
				BUTTON_WIDTH,BUTTON_HEIGHT);

			Surface* surface = new Surface;

			surface->Create(BUTTON_WIDTH,BUTTON_HEIGHT);
			surface->DisplayFormat();
			
			button_image.LowerBlit(surface,&src,0,0);
			
			button->m_image[i] = surface;
		}

		button->m_console = this;

		AddChild(button);

		m_button_table[n] = button;
	}

	//-----------------------------------------
}

//----------------------------------------------------------------------
// FUNCTION: Console::~Console
//----------------------------------------------------------------------

Console::~Console()
{
	if (m_radar_view) delete m_radar_view;

	if (m_status) delete m_status;

	if (m_frame_image) delete m_frame_image;

	for (int n = 0; n < BUTTON_COUNT; n++)
		if (m_button_table[n])
			delete m_button_table[n];
}

//----------------------------------------------------------------------
// FUNCTION: Console::Contains
//----------------------------------------------------------------------

int Console::Contains(Point point)
{
	if (!Window::Contains(point)) return 0;

	if (Window::FindWindow(point) != this)
		return 1;
	
	point = ConvertFromScreen(point);

	if (m_frame_image->Transparent(point.x,point.y))
		return 0;

	return 1;
}

//----------------------------------------------------------------------
// FUNCTION: Console::Draw
//----------------------------------------------------------------------

void Console::Draw(Rect rect)
{
	DrawSurface(m_frame_image,rect);
}

//----------------------------------------------------------------------      
// FUNCTION: Console::OnMouseMove
//----------------------------------------------------------------------

void Console::OnMouseMove(Point point)
{
	SetStatus("Console");

	if (!m_dragging) return;

	Invalidate();
	OffsetBy(point.x - m_drag_x, point.y - m_drag_y);
	Invalidate();

	Window::OnMouseMove(point);
}

//----------------------------------------------------------------------      
// FUNCTION: Console::OnMouseDown
//----------------------------------------------------------------------

void Console::OnMouseDown(int n, Point point)
{
	m_drag_x = point.x;
	m_drag_y = point.y;

	m_dragging = 1;

	Point a,b;

	a = point;
	
	b.x = a.x + m_parent->Width() - Width();
	b.y = a.y + m_parent->Height() - Height();

	a = m_parent->ConvertToScreen(a);
	b = m_parent->ConvertToScreen(b);

	CaptureMouse(Rect(a,b));
}

//----------------------------------------------------------------------      
// FUNCTION: Console::OnMouseUp
//----------------------------------------------------------------------

void Console::OnMouseUp(int n, Point point)
{
	if (!m_dragging) return;

	m_dragging = 0;

	ReleaseMouse();
}

//----------------------------------------------------------------------      
// FUNCTION: Console::SetStatus
//----------------------------------------------------------------------

void Console::SetStatus(const char* status)
{
	m_status->SetText(status);
}
