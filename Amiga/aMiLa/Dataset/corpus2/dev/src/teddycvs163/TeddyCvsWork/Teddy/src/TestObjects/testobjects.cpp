
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
	\file   testobjects.cpp
	\author Timo K Suoranta
	\brief  Teddy example program for objects
	\date   2001

	This is example program demonstrates some
	primitive object shapes and object methods.

	The program does the following things:

	<ul>
	<li>creates a single camera which looks at the scene
	<li>creates a timer which bounces the camera up and down	
	<li>creates one scene and puts following objects to it
		<ul>
		<li>two boxes
		<li>a big sphere
		<li>four smaller spheres
		<li>two cones with tubes on tips
		<li>two cylinders
		<li>a torus
	<li>the camera and smaller spheres are animated
	</ul>
*/


#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Materials/Light.h"
#include "Models/ModelInstance.h"
#include "Models/Box.h"
#include "Models/Cone.h"
#include "Models/Cylinder.h"
#include "Models/Grid.h"
#include "Models/Ring.h"
#include "Models/Sphere.h"
#include "Models/Torus.h"
#include "Models/Tube.h"
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
class TestObjects {
public:
	TestObjects();
	
public:
	View          *view;       //!<  This wraps up all access to the drawing context (SDL window)
	Scene         *scene;      //!<  This contains all objects in the test scene
	Camera        *camera;     //!<  This can be positioned and used to look at the scene
	WindowManager *wm;         //!<  This contains all layers we want to show
	Layer         *root_l;     //!<  This contains all windows we want to show
	Light         *light;      //!<  Lightsource emitting light to objects in scene
	Projection    *proj_win;   //!<  This is the projection window used to show the camera view
	ModelInstance *grid_obj;
	ModelInstance *box_obj1;
	ModelInstance *box_obj2;
	ModelInstance *cone_obj1;
	ModelInstance *cone_obj2;
	ModelInstance *cyl_obj1;
	ModelInstance *cyl_obj2;
	ModelInstance *sphere_obj1;
	ModelInstance *sphere_obj2;
	ModelInstance *sphere_obj3;
	ModelInstance *sphere_obj4;
	ModelInstance *sphere_obj5;
	ModelInstance *torus_obj1;
	ModelInstance *tube_obj1;
	ModelInstance *tube_obj2;
};


/*!
	This is the program entry point. It initializes Teddy
	and creates the test scene by calling TestObjects constructor.
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

	TestObjects *tester = new TestObjects();

	return 0 ;
}


/*!
	This is the basic test setup constructor.
*/
TestObjects::TestObjects(){
	int   screen_x = 640;           //!<  Width of SDL window
	int   screen_y = 480;           //!<  Height of SDL window
	int   flags    = SDL_OPENGL;    //!<  SDL_OPENGL is needed
	int   x_count  = 20;            //!<  Number of lines in x axis for the Grid object
	int   z_count  = 20;            //!<  Number of lines in z axis for the Grid object
	float x_space  = 100.0f;        //!<  Space between lines in x axis for the Grid object
	float z_space  = 100.0f;        //!<  Space between lines in z axis for the Grid object

	//  View must be first opened before much else can be done
	view   = new View  ( "TestObjects", screen_x, screen_y, flags ); 

	//  Create scene and camera
	scene  = new Scene ( "Test Scene"         );
	camera = new Camera( "Test Camera", scene );

	camera->heading( -45.0f );
	camera->pitch  ( -20.0f );

	//  Create window manager, default layer and a projection window
	wm        = new WindowManager( view );
	root_l    = new Layer        ( "Root Layer",  view   );
	proj_win  = new Projection   ( "Test Window", camera );

	//  Create some shapes
	Grid     *grid_mesh     = new Grid    ( x_count, z_count, x_space, z_space );
	Box      *box_mesh      = new Box     ( "Box shape",          400, 400, 200         );
	Cone     *cone_mesh     = new Cone    ( "Cone shape",         100, 0, 400,  20, 20  );
	Cylinder *cylinder_mesh = new Cylinder( "Cylinder shape",     100, 200,     20      );
	Ring     *ring_mesh     = new Ring    ( "Ring shape",         110, 150,     30      );
	Sphere   *sphere_mesh1  = new Sphere  ( "Small Sphere shape",  50, 15,      15      );
	Sphere   *sphere_mesh2  = new Sphere  ( "Big Sphere shape",   150, 20,      20      );
	Torus    *torus_mesh    = new Torus   ( "Torus shape",        150, 40,      28, 18  );
	Tube     *tube_mesh     = new Tube    ( "Tube shape",          40, 10,      14, 14  );

	//  Create objects
	grid_obj    = new ModelInstance( "Grid",         grid_mesh     );
	box_obj1    = new ModelInstance( "Box one",      box_mesh      );
	box_obj2    = new ModelInstance( "Box two",      box_mesh      );
	cone_obj1   = new ModelInstance( "Cone one",     cone_mesh     );
	cone_obj2   = new ModelInstance( "Cone two",     cone_mesh     );
	cyl_obj1    = new ModelInstance( "Cylinder one", cylinder_mesh );
	cyl_obj2    = new ModelInstance( "Cylinder two", cylinder_mesh );
	sphere_obj1 = new ModelInstance( "Sphere 1",     sphere_mesh1  );
	sphere_obj2 = new ModelInstance( "Sphere 2",     sphere_mesh1  );
	sphere_obj3 = new ModelInstance( "Sphere 3",     sphere_mesh1  );
	sphere_obj4 = new ModelInstance( "Sphere 4",     sphere_mesh1  );
	sphere_obj5 = new ModelInstance( "Big Sphere",   sphere_mesh2  );
	torus_obj1  = new ModelInstance( "Torus",        torus_mesh    );
	tube_obj1   = new ModelInstance( "Tube One",     tube_mesh     );
	tube_obj2   = new ModelInstance( "Tube Two",     tube_mesh     );

	//  Set objects' materials
	grid_obj   ->setMaterial( new Material(Material::GRAY_50,RENDER_LIGHTING_COLOR)  );
	box_obj1   ->setMaterial( &Material::BLUE          );
	box_obj2   ->setMaterial( &Material::LIGHT_BLUE    );
	cone_obj1  ->setMaterial( &Material::RED           );
	cone_obj2  ->setMaterial( &Material::GREEN         );
	cyl_obj1   ->setMaterial( &Material::ORANGE        );
	cyl_obj2   ->setMaterial( &Material::LIGHT_ORANGE  );
	sphere_obj1->setMaterial( &Material::LIGHT_YELLOW  );
	sphere_obj2->setMaterial( &Material::LIGHT_CYAN    );
	sphere_obj3->setMaterial( &Material::LIGHT_GREEN   );
	sphere_obj4->setMaterial( &Material::LIGHT_BLUE    );
	sphere_obj5->setMaterial( &Material::DARK_BLUE     );
	torus_obj1 ->setMaterial( &Material::BLACK         );
	tube_obj1  ->setMaterial( &Material::WHITE         );
	tube_obj2  ->setMaterial( &Material::WHITE         );


	//  Set objects' positions
	box_obj1   ->setPosition( -400, 200, -500 );
	box_obj2   ->setPosition(  400, 200, -500 );
	cone_obj1  ->setPosition( -400,   0,    0 );
	cone_obj2  ->setPosition(  400,   0,    0 );
	cyl_obj1   ->setPosition(  200,   0,  400 );
	cyl_obj2   ->setPosition(    0,   0, -400 );
	sphere_obj1->setPosition(    0, 250,  220 );
	sphere_obj2->setPosition(    0, 250, -220 );
	sphere_obj3->setPosition( -220, 250,    0 );
	sphere_obj4->setPosition(  220, 250,    0 );
	sphere_obj5->setPosition(    0, 150,    0 );  //  radius 150
	torus_obj1 ->setPosition(    0,  40,    0 );
	tube_obj1  ->setPosition( -400, 400,    0 );
	tube_obj2  ->setPosition(  400, 400,    0 );

	//  Add objects to the scene
	scene->addInstance( grid_obj    );
	scene->addInstance( box_obj1    );
	scene->addInstance( box_obj2    );
	scene->addInstance( cone_obj1   );
	scene->addInstance( cone_obj2   );
	scene->addInstance( cyl_obj1    );
	scene->addInstance( cyl_obj2    );
	scene->addInstance( sphere_obj1 );
	scene->addInstance( sphere_obj2 );
	scene->addInstance( sphere_obj3 );
	scene->addInstance( sphere_obj4 );
	scene->addInstance( sphere_obj5 );
	scene->addInstance( torus_obj1  );
	scene->addInstance( tube_obj1   );
	scene->addInstance( tube_obj2   );

	//  Create lightsource and add it to the scene
	light = new Light( "Lightsource" );
	light->setAmbient ( Color::WHITE );
	light->setDiffuse ( Color::WHITE );
	light->setSpecular( Color::WHITE );
	light->setPosition( -3000, 2000, 1000 );
	light->enable();
	scene->addLight( light );

	//  Connect the projection to the layer and add the layer to window manager
	root_l->addProjection   ( proj_win );
	root_l->place           ();
	wm    ->insert          ( root_l );
	view  ->setWindowManager( wm );

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
	TestObjects *tester  = (TestObjects *)( param );
	
	sys_time += frame_age = sync.Passed();

	float x, y, z;

	//  Calculate new positions for camera and spheres
	y = 450 + 150 * sin( sys_time/2000 );
	tester->camera->setPosition( Vector(-400,y,400) );

	y = 50 + fabs(  200 * sin( sys_time/270 )  );
	x = 220 * cos( sys_time/333 );
	z = 200 * sin( sys_time/333 );
	tester->sphere_obj1->setPosition( x, y, z );

	x = 220 * cos( M_2_PI / 3 + sys_time/333 );
	z = 200 * sin( M_2_PI / 3 + sys_time/333 );
	tester->sphere_obj2->setPosition( x, y, z );

	x = 220 * cos( 2 * M_2_PI / 3 + sys_time/333 );
	z = 200 * sin( 2 * M_2_PI / 3 + sys_time/333 );
	tester->sphere_obj3->setPosition( x, y, z );

	y = 250 + fabs(  200 * sin( sys_time/350 )  );
	tester->sphere_obj4->setPosition( 0, y, -400 );

	//  Rotate tubes
	tester->tube_obj1->heading(  5 );
	tester->tube_obj2->heading( -1 );

	sync.Update();
	
	return interval;
}

