
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
	\file   TestManipulate.h
	\author Timo Suoranta
	\brief  Teddy example program for object manipulation
	\date   2001

	This example program is not yet finished.
*/


#ifndef TEDDY_TEST_MANIPULATE_TEST_MANIPULATE_H
#define TEDDY_TEST_MANIPULATE_TEST_MANIPULATE_H


#include "PhysicalComponents/EventListener.h"
#include "SDL.h"
namespace Graphics           { class View;          };
namespace Materials          { class Light;         };
namespace Models             { class Mesh;          };
namespace Models             { class ModelInstance; };
namespace PhysicalComponents { class Layer;         };
namespace PhysicalComponents { class Projection;    };
namespace PhysicalComponents { class WindowManager; };
namespace Scenes             { class Camera;        };
namespace Scenes             { class Scene;         };
using namespace Graphics;
using namespace Materials;
using namespace Models;
using namespace PhysicalComponents;
using namespace Scenes;


class LSystem;


//!  Test setup context
/*!
	This class is used to pass data to the simulation timer.
	The constructor creates the test scene set up and initializes
	controls.

	This class also implements event handlers so we can receive
	input from the WindowManager.
*/
class TestManipulate : public EventListener {
public:
	TestManipulate();

	void addObjects   ();
	void applyControls();

	//  WindowManager calls these methods when there is mouse event
	virtual void  mouseKey   ( const int button, const int state, const int x, const int y );
	virtual void  mouseMotion( const int x, const int y, const int dx, const int dy );
	
	//  WindowManager calls these methods when there is keyboard event
	virtual void  keyDown    ( const SDL_keysym key );
	virtual void  keyUp      ( const SDL_keysym key );
	
public:
	View          *view;       //!<  This wraps up all access to the drawing context (SDL window)
	Scene         *scene;      //!<  This contains all objects in the test scene
	Camera        *camera;     //!<  This can be positioned and used to look at the scene
	WindowManager *wm;         //!<  This contains all layers we want to show
	Layer         *root_l;     //!<  This contains all windows we want to show
	Light         *light;      //!<  Lightsource emitting light to objects in scene
	Projection    *proj_win;   //!<  This is the projection window used to show the camera view

	//  These objects are listed here so they could be used
	//  by the animeteObjects() -method.
	ModelInstance *floor_box;
	ModelInstance *lsystem_obj1;
	ModelInstance *lsystem_obj2a;
	ModelInstance *lsystem_obj2b;
	ModelInstance *lsystem_obj2c;
	ModelInstance *lsystem_obj3;

	//  These member variables keep record on currently active controls
	bool  control_speed_more;
	bool  control_speed_less;
	bool  control_strafe_up;
	bool  control_strafe_down;
	bool  control_strafe_left;
	bool  control_strafe_right;
	bool  control_turn_up;
	bool  control_turn_down;
	bool  control_turn_left;
	bool  control_turn_right;
	bool  control_faster;

	//  These member variables keep record on current movement and attitude
	float control_roll;
	float control_heading;
	float control_pitch;
	float control_speed;
	float control_up_down;
	float control_left_right;

	//  Mouse can be used when dragging either left or right mouse button
	int   control_last_button;
};


#endif  //  TEDDY_TEST_MANIPULATE_TEST_MANIPULATE_H

