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

#include "Game.h"

#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "SDL.h"

#include "Map.h"

#include "Screen.h"
#include "Surface.h"
#include "Cursor.h"
#include "MapView.h"
#include "Console.h"
#include "Desktop.h"

#define MAP_WIDTH		256
#define MAP_HEIGHT		256

#define FALSE 0
#define TRUE (!FALSE)

Game* Game::m_instance = NULL;

//----------------------------------------------------------------------
// FUNCTION: Game::Instance
//----------------------------------------------------------------------

Game* Game::Instance()
{
	if (m_instance == NULL)
		m_instance = new Game;
	return m_instance;
}

//----------------------------------------------------------------------
// FUNCTION: Game::Game
//----------------------------------------------------------------------

Game::Game()
{
	m_done = 0;

	Screen::Instance();

	m_desktop = NULL;
	m_map_view = NULL;
	m_console = NULL;
	m_cursor = NULL;

	m_map = NULL;
}

//----------------------------------------------------------------------
// FUNCTION: Game::Game
//----------------------------------------------------------------------

Game::~Game()
{
	if (m_desktop) delete m_desktop;
	if (m_console) delete m_console;
	if (m_map_view) delete m_map_view;
	if (m_map) delete m_map;
	if (m_cursor) delete m_cursor;
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnActiveEvent
//----------------------------------------------------------------------

void Game::PushUserEvent(int code, void* data1, void* data2)
{
	SDL_Event event;
	event.type = SDL_USEREVENT;
	event.user.code = code;
	event.user.data1 = data1;
	event.user.data2 = data2;
	SDL_PushEvent(&event);
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnActiveEvent
//----------------------------------------------------------------------

void Game::OnActiveEvent(SDL_ActiveEvent event)
{
	if ((event.state & SDL_APPMOUSEFOCUS) && (!event.gain))
	{
		m_cursor->Hide();
		m_console->SetStatus("");
	}
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnKeyDown
//----------------------------------------------------------------------

void Game::OnKeyDown(SDL_KeyboardEvent event)
{
	switch (event.keysym.sym)
	{
	case SDLK_ESCAPE:
		PushUserEvent(GAMEUSEREVENT_QUITGAME,NULL,NULL); break;

	case SDLK_KP_PLUS:
		PushUserEvent(GAMEUSEREVENT_ZOOMIN,NULL,NULL); break;
	
	case SDLK_KP_MINUS:
		PushUserEvent(GAMEUSEREVENT_ZOOMOUT,NULL,NULL); break;

	case SDLK_g:
		
		if (event.keysym.mod & KMOD_CTRL)
		{
			if (SDL_WM_GrabInput(SDL_GRAB_QUERY) == SDL_GRAB_OFF)
				SDL_WM_GrabInput(SDL_GRAB_ON);
			else if (SDL_WM_GrabInput(SDL_GRAB_QUERY) == SDL_GRAB_ON)
				SDL_WM_GrabInput(SDL_GRAB_OFF);
	    }
		else PushUserEvent(GAMEUSEREVENT_TOGGLEGRID,NULL,NULL);
		
		break;

	case SDLK_n:
		PushUserEvent(GAMEUSEREVENT_NEWMAP,NULL,NULL);
		break;

	case SDLK_x:
		{
			if (!Window::m_debug_dirty_rectangles)
			{
				Window::m_debug_dirty_rectangles = 1;

				Rect rect(0,0,Screen::Instance()->Width(),Screen::Instance()->Height());
				
				Screen::Instance()->FillRect(&rect,192,192,192);
				Screen::Instance()->Flip();
			}
			else
			{
				Window::m_debug_dirty_rectangles = 0;
				
				m_desktop->Invalidate();
			}
		}
		break;

	case SDLK_z:
		if (event.keysym.mod & KMOD_CTRL)
			SDL_WM_IconifyWindow();
		break;

	case SDLK_UP:
		m_map_view->SetState(SCROLLVIEWSTATE_UP); break;
	case SDLK_DOWN:
		m_map_view->SetState(SCROLLVIEWSTATE_DOWN); break;
	case SDLK_LEFT:
		m_map_view->SetState(SCROLLVIEWSTATE_LEFT); break;
	case SDLK_RIGHT:
		m_map_view->SetState(SCROLLVIEWSTATE_RIGHT); break;
	}
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnKeyUp
//----------------------------------------------------------------------

void Game::OnKeyUp(SDL_KeyboardEvent event)
{
	switch (event.keysym.sym)
	{
	case SDLK_UP:
		m_map_view->ClearState(SCROLLVIEWSTATE_UP); break;
	case SDLK_DOWN:
		m_map_view->ClearState(SCROLLVIEWSTATE_DOWN); break;
	case SDLK_LEFT:
		m_map_view->ClearState(SCROLLVIEWSTATE_LEFT); break;
	case SDLK_RIGHT:
		m_map_view->ClearState(SCROLLVIEWSTATE_RIGHT); break;
	}
}

//----------------------------------------------------------------------
// FUNCTION: Game::CalculateMouse
//----------------------------------------------------------------------

Window* Game::CalculateMouse(Point& point)
{
	Window* window;
	
	if (m_desktop->m_capture_view)
	{
		window = m_desktop->m_capture_view;
	
		Rect rect = m_desktop->m_capture_rect;

		Point a = rect.UpperLeft();
		Point b = rect.LowerRight();
		Point c = point;
		
		if (c.x < a.x) c.x = a.x;
		if (c.y < a.y) c.y = a.y;
		if (c.x > b.x) c.x = b.x;
		if (c.y > b.y) c.y = b.y;

		if ((c.x != point.x) || (c.y != point.y))
		{
			m_cursor->Warp(c.x,c.y);
			point = c;
		}
	}
	else window = m_desktop->FindWindow(point);
	
	return window;
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnMouseMotion
//----------------------------------------------------------------------

void Game::OnMouseMotion(SDL_MouseMotionEvent event)
{
	Point point(event.x,event.y);

	m_cursor->SetPosition(point);

	Window* window = CalculateMouse(point);

	window->OnMouseMove(window->ConvertFromScreen(point));

	m_cursor->Show();
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnMouseButtonDown
//----------------------------------------------------------------------

void Game::OnMouseButtonDown(SDL_MouseButtonEvent event)
{
	Point point(event.x,event.y);
	Window* window = CalculateMouse(point);
	window->OnMouseDown(event.button,window->ConvertFromScreen(point));
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnMouseButtonUp
//----------------------------------------------------------------------

void Game::OnMouseButtonUp(SDL_MouseButtonEvent event)
{
	Point point(event.x,event.y);
	Window* window = CalculateMouse(point);
	window->OnMouseUp(event.button,window->ConvertFromScreen(point));
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnVideoResize
//----------------------------------------------------------------------

void Game::OnVideoResize(SDL_ResizeEvent event)
{
	int w = event.w;
	int h = event.h;

	Screen::Instance()->Resize(w,h);

	m_desktop->ResizeTo(w,h);
	m_map_view->ResizeTo(w,h);
	m_map_view->Refresh();
	m_desktop->Invalidate();
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnQuit
//----------------------------------------------------------------------

void Game::OnQuit(SDL_QuitEvent event) 
{
	m_done = 1;
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnUserEvent
//----------------------------------------------------------------------

void Game::OnUserEvent(SDL_UserEvent event)
{
	switch (event.code)
	{
	case GAMEUSEREVENT_ZOOMIN:
		m_map_view->ZoomIn(); break;
	
	case GAMEUSEREVENT_ZOOMOUT:
		m_map_view->ZoomOut(); break;

	case GAMEUSEREVENT_TOGGLEGRID:
		m_map_view->ToggleGrid(); break;

	case GAMEUSEREVENT_NEWMAP:
		m_map->FractalCreate(16,8);
		m_map_view->ScanMap();
		m_console->ScanMap();
		break;

	case GAMEUSEREVENT_QUITGAME:
		m_done = 1; break;
	}
}

//----------------------------------------------------------------------
// FUNCTION: Game::OnSysWMEvent
//----------------------------------------------------------------------

void Game::OnSysWMEvent(SDL_SysWMEvent event)
{
}

//----------------------------------------------------------------------
// FUNCTION: Game::PollEvents
//----------------------------------------------------------------------

void Game::PollEvents(void)
{
	SDL_Event event;
	
	if (SDL_PeepEvents(&event,1,
		SDL_PEEKEVENT,SDL_MOUSEMOTIONMASK)==1)
	{
		do {
			SDL_PeepEvents(&event,1,
				SDL_GETEVENT,SDL_MOUSEMOTIONMASK);
		} while (SDL_PeepEvents(&event,1,
			SDL_PEEKEVENT,SDL_MOUSEMOTIONMASK)==1);
		
		OnMouseMotion(event.motion);
	}

	if (SDL_PollEvent(&event))
	{
		switch (event.type)
		{
		case SDL_ACTIVEEVENT:
			OnActiveEvent(event.active); break;
		
		case SDL_KEYDOWN:
			OnKeyDown(event.key); break;
		case SDL_KEYUP:
			OnKeyUp(event.key); break;

		case SDL_MOUSEMOTION:
			OnMouseMotion(event.motion); break;
		case SDL_MOUSEBUTTONDOWN:
			OnMouseButtonDown(event.button); break;
		case SDL_MOUSEBUTTONUP:
			OnMouseButtonUp(event.button); break;

		case SDL_VIDEORESIZE:
			OnVideoResize(event.resize); break;
		
		case SDL_QUIT:
			OnQuit(event.quit); break;
		case SDL_USEREVENT:
			OnUserEvent(event.user); break;
		case SDL_SYSWMEVENT:
			OnSysWMEvent(event.syswm); break;
		}
	}
	else SDL_Delay(1);
}

//----------------------------------------------------------------------
// FUNCTION: Game::Run
//----------------------------------------------------------------------

int Game::Run(void)
{
	SDL_ShowCursor(0);

	/* init window manager stuff */
	
	int w = Screen::Instance()->Width();
	int h = Screen::Instance()->Height();

	m_desktop = new Desktop;
	m_map_view = new MapView;
	m_console = new Console;
	m_cursor = new Cursor;

	m_desktop->ResizeTo(w,h);
	m_map_view->ResizeTo(w,h);
	m_console->OffsetTo(20,20);

	m_desktop->AddChild(m_map_view);
	m_desktop->AddChild(m_console);
	m_desktop->AddChild(m_cursor);

	m_desktop->Invalidate();

	/* create and display background */
	
	m_map = new Map;

	m_console->SetMap(m_map);
	m_console->SetMapView(m_map_view);

	m_map_view->SetMap(m_map);
	m_map_view->SetConsole(m_console);
	m_map_view->SetVelocity(2000.0);
	m_map_view->SetAcceleration(10000.0);

	m_map->SetSize(MAP_WIDTH,MAP_HEIGHT);
	m_map->FractalCreate(16,8);
	m_map_view->ScanMap();
	m_console->ScanMap();

	// initialize variables and loop
	
	long last_ticks = SDL_GetTicks();

	while (!m_done)
	{
		PollEvents();
		
		long t1 = last_ticks;
		long t2 = SDL_GetTicks();
			
		float dt = (t2 - t1) * 0.001f;

		last_ticks = t2;

		m_map_view->Update(dt);

		if (Window::m_mouse_override)
			m_cursor->SetPosition(Window::m_mouse_position);

		m_desktop->Update();
	}

	return 0;
}
