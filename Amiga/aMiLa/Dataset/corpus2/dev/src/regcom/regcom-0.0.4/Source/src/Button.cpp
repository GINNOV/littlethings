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

#include "Button.h"
#include "Console.h"
#include "Game.h"

#include <string.h>

Button::Button()
{
	m_state = 0;
	m_status = NULL;
	m_console = NULL;

	m_image[0] = new Surface;
	m_image[1] = new Surface;
	m_image[2] = new Surface;
	m_image[3] = new Surface;

	m_code = 0;
	m_data1 = NULL;
	m_data2 = NULL;
}

Button::~Button()
{
	delete m_image[0];
	delete m_image[1];
	delete m_image[2];
	delete m_image[3];
}

void Button::Draw(Rect rect)
{
	int index = 0;
	if ((m_state == 1) || (m_state == 3)) index = 1;
	else if (m_state == 2) index = 2;

	DrawSurface(m_image[index],rect);
}

void Button::OnMouseMove(Point point)
{
	Rect rect = Bounds();

	switch (m_state)
	{
	case 0:

		if (rect.Contains(point))
		{
			m_state = 1;
			Invalidate();
				
			SDL_Surface* screen = SDL_GetVideoSurface();
			Rect capture(1,1,screen->w-3,screen->h-3);
			CaptureMouse(capture);
		}

		break;

	case 1:

		if (!rect.Contains(point))
		{
			ReleaseMouse();
			m_state = 0;
			Invalidate();
		}
		
		break;

	case 2:

		if (!rect.Contains(point))
		{
			m_state = 3;
			Invalidate();
		}
		
		break;

	case 3:

		if (rect.Contains(point))
		{
			m_state = 2;
			Invalidate();
		}
		
		break;
	}

	if (m_console && m_status) m_console->SetStatus(m_status);
}

void Button::OnMouseDown(int n, Point point)
{
	if (n != 1) return;

	if (m_state == 1)
	{
		m_state = 2;
		Invalidate();
	}
}

void Button::OnMouseUp(int n, Point point)
{
	if (n != 1) return;

	if (m_state == 2)
	{
		Game::Instance()->PushUserEvent(m_code,m_data1,m_data2);
		m_state = 1;
		Invalidate();
	}
	else if (m_state == 3)
	{
		ReleaseMouse();
		m_state = 0;
		Invalidate();
	}
}

void Button::SetStatus(const char* status)
{
	if ((m_status != NULL) && (strcmp(status,m_status) == 0)) return;
	
	if (m_status) delete [] m_status;
	m_status = new char[strlen(status)+1];
	strcpy(m_status,status);
}

void Button::Load(Surface* surface)
{
	int w = surface->Width();
	int h = surface->Height()/4;

	ResizeTo(w,h);

	for (int n = 0; n < 4; n++)
	{
		Rect src(0,n*h,w,h);

		m_image[n]->Create(w,h);
		m_image[n]->DisplayFormat();
			
		surface->Blit(m_image[n],&src,0,0);
	}
}
