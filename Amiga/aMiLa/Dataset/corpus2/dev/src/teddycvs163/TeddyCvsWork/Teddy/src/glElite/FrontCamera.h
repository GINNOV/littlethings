
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
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
	\class   FrontCamera
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Main 3D display for testing environment
	\warning The perspective interface is not yet in use/designed
	\date    2000, 2001
*/


#ifndef TEDDY_APPLICATION_FRONT_CAMERA_H
#define TEDDY_APPLICATION_FRONT_CAMERA_H


#include "PhysicalComponents/EventListener.h"
#include "PhysicalComponents/Projection.h"
namespace Scenes             { class Camera;      };
namespace PhysicalComponents { class Label;       };
namespace PhysicalComponents { class WindowFrame; };
using namespace PhysicalComponents;
using namespace Scenes;


namespace Application {


class UI;
class PlayerShip;


class FrontCamera : public Projection, public EventListener {
public:
	FrontCamera( const char *name, Camera *camera, UI *ui, LayoutConstraint *lc, bool frame );
	virtual ~FrontCamera();

	virtual void  drawSelf();

	//  FocusListener interface
	virtual void  focusActive( const bool active );

	//  MouseListener interface
	virtual void  mouseKey   ( const int button, const int state, const int x, const int y );
	virtual void  mouseMotion( const int x, const int y, const int dx, const int dy );

	virtual Area *getTarget  ( const Event e ) const;
	
	//  KeyListener interface
	virtual void  keyDown    ( const SDL_keysym key );
	virtual void  keyUp      ( const SDL_keysym key );

protected:
	UI          *ui;
	WindowFrame *window_frame;
	PlayerShip  *player_ship;
	Label       *title;
	int          mouse_drag_x [4];
	int          mouse_drag_y [4];
	int          mouse_click_x[4];
	int          mouse_click_y[4];
	int          mouse_b      [4];
	static bool  keys[SDLK_LAST+1];
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_FRONT_CAMERA_H

