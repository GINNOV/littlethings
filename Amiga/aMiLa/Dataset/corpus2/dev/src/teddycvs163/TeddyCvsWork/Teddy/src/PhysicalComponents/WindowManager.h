
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
	tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!
	\class	 WindowManager
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief	 Window Manager
	\date	 2001

	WindowManager encapsulates window management such as
	positioning and depth ordering of windows in customizable
	way.
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_WINDOW_MANAGER_H
#define TEDDY_PHYSICAL_COMPONENTS_WINDOW_MANAGER_H


#include "PhysicalComponents/EventListener.h"
#include "SysSupport/StdList.h"
namespace Graphics  { class View;    };
namespace Graphics  { class Texture; };
using namespace Graphics;


namespace PhysicalComponents {


class Area;
class Layer;


class WindowManager : public EventListener {
public:
	WindowManager( View *view );
	virtual ~WindowManager();

	void           inputLoop    ();  //  never returns

	void           draw         ();
	void           update       ();
	void           insert       ( Layer *layer );
	View          *getView      ();

	//	Focus Management
	void           setFocus     ( EventListener *focus );

	//	Callback functions
	virtual void   mouseKey     ( const int button, const int state, const int x,  const int y );
	virtual void   mouseMotion  ( const int x,      const int y,     const int dx, const int dy );
	virtual void   keyDown      ( const SDL_keysym key );
	virtual void   keyUp        ( const SDL_keysym key );

	//	Event processing
	void           event        ( Event event, Area *source, Area *target, int x, int y );

protected:
	View          *view;         //!<  Graphics View
	EventListener *focus;        //!<  Currently active Focus Area
	Texture       *cursor;       //!<  Mouse cursor
	list<Layer*>   layers;       //!<  Drawable Areas
	list<Area*>    focus_stack;  //!<  Focus stack
	bool           skip_warp;    //!<  Need to skip mouse motion event?
	int            mx;           //!<  Current mouse cursor x
	int            my;           //!<  Current mouse cursor y
	int            mouse_b[3];   //!<  Current mouse button states
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_WINDOW_MANAGER_H

