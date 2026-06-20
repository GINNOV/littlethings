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

#ifndef GAME_H
#define GAME_H

#include "SDL.h"

#include "Rect.h"

class Cursor;
class Map;
class MapView;
class Console;
class Desktop;

class Window;
class Point;

typedef enum _GAMEUSEREVENT {
	GAMEUSEREVENT_ZOOMIN		= 1,
	GAMEUSEREVENT_ZOOMOUT		= 2,
	GAMEUSEREVENT_TOGGLEGRID	= 3,
	GAMEUSEREVENT_NEWMAP		= 4,
	GAMEUSEREVENT_QUITGAME		= 5
} GAMEUSEREVENT;

class Game
{
private:
	
	int m_done;

	Cursor* m_cursor;
	Map* m_map;
	MapView* m_map_view;
	Console* m_console;
	Desktop* m_desktop;

	static Game* m_instance;

protected:

	Window* CalculateMouse(Point& point);

	void PollEvents(void);

	void OnActiveEvent(SDL_ActiveEvent event);
	void OnKeyDown(SDL_KeyboardEvent event);
	void OnKeyUp(SDL_KeyboardEvent event);
	void OnMouseMotion(SDL_MouseMotionEvent event);
	void OnMouseButtonDown(SDL_MouseButtonEvent event);
	void OnMouseButtonUp(SDL_MouseButtonEvent event);
	void OnVideoResize(SDL_ResizeEvent event);
	void OnQuit(SDL_QuitEvent event);
	void OnUserEvent(SDL_UserEvent event);
	void OnSysWMEvent(SDL_SysWMEvent event);

private:
	
	Game();

public:
	
	virtual ~Game();
	
	static Game* Instance();
	
	int Run(void);
	void PushUserEvent(int code, void* data1, void* data2);
};

#endif

