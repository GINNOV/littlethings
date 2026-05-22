
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
	\file   testbasic.cpp
	\author Timo K Suoranta
	\brief  Very basic Teddy test program
	\date   2001

	This is close to nearly possible example program
	using the Teddy framework.

	The program does the following things:

		- creates one scene containing one object (a simple grid).
		- creates a single camera which looks at the scene
		- creates a timer which bounces the camera up and down	
*/


#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Models/ModelInstance.h"
#include "Models/Grid.h"
#include "PhysicalComponents/Layer.h"
#include "PhysicalComponents/Projection.h"
#include "PhysicalComponents/WindowManager.h"
#include "Scenes/Scene.h"
#include "Scenes/Camera.h"
#include "SysSupport/Messages.h"
#include "SysSupport/Timer.h"
#include "SDL.h"
using namespace Graphics;
using namespace Materials;
using namespace Models;
using namespace Scenes;
using namespace PhysicalComponents;


int main_cpp( int argc, char **argv );


extern "C" {
	int SDL_main( int argc, char **argv ){
		main_cpp( argc, argv );
		return 0;
	}
}


/*!
	This is the timer update function. It is a standard SDL callback function.
*/
Uint32 test_timer_callback( Uint32 interval, void *param );


/*!
	This class is used to pass data to the simulation timer.
	The constructor creates the basic test set up.
*/
class TestBasic {
public:
	TestBasic();
	
public:
	View          *view;       //!<  This wraps up all access to the drawing context (SDL window)
	Scene         *scene;      //!<  This contains all objects in the test scene
	Camera        *camera;     //!<  This can be positioned and used to look at the scene
	WindowManager *wm;         //!<  This contains all layers we want to show
	Layer         *root_l;     //!<  This contains all windows we want to show
	Projection    *proj_win;   //!<  This is the projection window used to show the camera view
	Mesh          *grid_mesh;  //!<  This is shape for the grid
	Material      *grid_mat;   //!<  This defines material properties (looks) for grid
	ModelInstance *grid_obj;   //!<  This is a grid object
};


/*!
	This is the program entry point. It initializes Teddy
	and creates the test scene by calling TestBasic constructor.
*/
int main_cpp( int argc, char **argv ){
	int   screen_x = 640;
	int   screen_y = 480;
	int   flags    = SDL_OPENGL;
	int   x_count  = 10;
	int   z_count  = 10;
	float x_space  = 100.0f;
	float z_space  = 100.0f;

	if( SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE|SDL_INIT_AUDIO) < 0 ){
		fatal_msg( MSG_HEAD "Unable to initialize SDL: %s\n", SDL_GetError() );
	}else{
		atexit( SDL_Quit );
	}

	init_materials      ();
	init_graphics_device();

	TestBasic *tester = new TestBasic();

	return 0 ;
}


/*!
	This is the basic test setup constructor.
*/
TestBasic::TestBasic(){
	int   screen_x = 640;           //!<  Width of SDL window
	int   screen_y = 480;           //!<  Height of SDL window
	int   flags    = SDL_OPENGL;    //!<  SDL_OPENGL is needed
	int   x_count  = 10;            //!<  Number of lines in x axis for the Grid object
	int   z_count  = 10;            //!<  Number of lines in z axis for the Grid object
	float x_space  = 100.0f;        //!<  Space between lines in x axis for the Grid object
	float z_space  = 100.0f;        //!<  Space between lines in z axis for the Grid object

	//  View must be first opened before much else can be done
	view      = new View         ( "TestBasic",   screen_x, screen_y, flags ); 

	//  Create scene and camera
	scene     = new Scene        ( "Test Scene"          );
	camera    = new Camera       ( "Test Camera", scene  );

	//  Create window manager, default layer and a projection window
	wm        = new WindowManager( view );
	root_l    = new Layer        ( "Root Layer",  view   );
	proj_win  = new Projection   ( "Test Window", camera );

	//  Create shape and material and object
	grid_mesh = new Grid         ( x_count, z_count, x_space, z_space );
	grid_mat  = new Material     ( Material::GRAY_50, RENDER_LIGHTING_COLOR );
	grid_obj  = new ModelInstance( "Grid", grid_mesh );

	//  Set material for the object and add the object to the scene
	grid_obj->setMaterial     ( grid_mat );
	scene   ->addInstance     ( grid_obj );

	//  Connect the projection to the layer and add the layer to window manager
	root_l  ->addProjection   ( proj_win );
	root_l  ->place           ();
	wm      ->insert          ( root_l );
	view    ->setWindowManager( wm );

	//  Set some default values for the projection window
	proj_win->setClearColor           ( Color(0.3f,0.3f,0.3f,1.0f) );
	proj_win->getMaster()->setOptions ( RENDER_OPTION_ALL_M );
	proj_win->getMaster()->setMode    ( RENDER_MODE_FILL );
	proj_win->getMaster()->setLighting( RENDER_LIGHTING_SIMPLE );

	//  Run the simulation update timer
	SDL_AddTimer( 10, test_timer_callback, this );

	//  Enter Teddy loop.
	wm->inputLoop();
	//  Since we have no event handlers, we can only
	//  do things in the simulation timer after this.
}


/*!
	This is the timer update function implementation.
	Variables frame_age, sys_time and sync are provided by Teddy.
*/
Uint32 test_timer_callback( Uint32 interval, void *param ){
	TestBasic *tester  = (TestBasic *)( param );
	
	sys_time += frame_age = sync.Passed();

	//  Calculate new height and set new position for the camera
	float y = fabs( 100 * sin( sys_time/1000 ) );
	tester->camera->setPosition( Vector(0,y,0) );

	sync.Update();
	
	return interval;
}

