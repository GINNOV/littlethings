
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
	\file   testevents.cpp
	\author Timo Suoranta
	\brief  Teddy example program for input events
	\date   2001

	This example program demonstrates how to make an
	interactive program using the Teddy framework.
	Texture mapping is also demonstrated.

	The program creates a scene from several objects.
	Some objects are animated in the simulation timer.
	The test class is inherited from EventListener so
	that it can receive input event messages.

	Input event messages are handled in the main thread.
	The handlers only record the fact that control is
	changed. Controls are actually applied in the
	simulation timer at regular intervals.

	Keyboard input messages are handled as follows:

	- left    / right     : turn left    / right
	- up      / down      : move forward / backward
	- page up / page down : turn up      / down
	- home    / end       : strafe up    / down
	- z       / c         : strafe left  / right

	Mouse input messages are handled as follow:

	- drag with left button  : heading and pitch
	- drag with right button : roll and forward / backward
	
	Adding full controls like Descent for example
	is left as an exercise to the reader..
*/


//  The greater you set this subdivision define, the more
//  smooth objects you get. Smaller values speed up the graphics.
#define SD 4

//  Feel free to change these to your favorite first person shooter controls :)
#define CONTROL_KEY_TURN_RIGHT   SDLK_RIGHT
#define CONTROL_KEY_TURN_LEFT    SDLK_LEFT
#define CONTROL_KEY_TURN_UP      SDLK_PAGEUP
#define CONTROL_KEY_TURN_DOWN    SDLK_PAGEDOWN
#define CONTROL_KEY_FORWARD      SDLK_UP
#define CONTROL_KEY_BACKWARD     SDLK_DOWN
#define CONTROL_KEY_FASTER       SDLK_RCTRL
#define CONTROL_KEY_STRAFE_LEFT  SDLK_z         //  Also 'z' would work
#define CONTROL_KEY_STRAFE_RIGHT SDLK_c         //  Also 'c' would work
#define CONTROL_KEY_STRAFE_UP    SDLK_HOME      //  See SDL documentation and/or
#define CONTROL_KEY_STRAFE_DOWN  SDLK_END       //  header files for other keys.


#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Materials/Light.h"
#include "Materials/SdlTexture.h"
#include "Models/ModelInstance.h"
#include "Models/Box.h"
#include "Models/Cone.h"
#include "Models/Cylinder.h"
#include "Models/Grid.h"
#include "Models/Sphere.h"
#include "Models/Torus.h"
#include "Models/Tube.h"
#include "PhysicalComponents/EventListener.h"
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
	This is the timer update function.
	It is a standard SDL callback function.
*/
Uint32 test_timer_callback( Uint32 interval, void *param );


/*!
	This class is used to pass data to the simulation timer.
	The constructor creates the test scene set up and initializes
	controls.

	This class also implements event handlers so we can receive
	input from the WindowManager.
*/
class TestEvents : public EventListener {
public:
	TestEvents();

	//  Initialization is split into two methods for clarity
	void addObjects    ();
	void applyControls ();

	//  This method is called by the simulation timer
	void animateObjects();

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
	ModelInstance *grid_obj;
	ModelInstance *floor_box;
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

	TestEvents *tester = new TestEvents();

	return 0 ;
}


/*!
	This is the basic test setup constructor.
*/
TestEvents::TestEvents()
:EventListener(EVENT_KEY_DOWN_M|EVENT_KEY_UP_M|EVENT_MOUSE_KEY_M|EVENT_MOUSE_HOLD_DRAG_M)
{
	int   screen_x = 640;         //!<  Width of SDL window
	int   screen_y = 480;         //!<  Height of SDL window
	int   flags    = SDL_OPENGL;  //!<  SDL_OPENGL is needed

	//  A View must be created first before much else can be done
	view   = new View  ( "TestObjects", screen_x, screen_y, flags ); 

	//  Create scene and camera
	scene  = new Scene ( "Test Scene"         );
	camera = new Camera( "Test Camera", scene );

	//  Set initial camera configuration (that is, position and attitude)
	camera->setPosition( -1000, 100, 1000 );
	camera->heading    ( -45.0f );

	//  Create window manager, default layer and a projection window
	wm       = new WindowManager( view );
	root_l   = new Layer        ( "Root Layer",  view   );
	proj_win = new Projection   ( "Test Window", camera );

	//  Create the scene
	this->addObjects();

	//  Create some lightsources and add them to the scene
	light = new Light( "Lightsource 1 (white)" );
	light->setAmbient ( Color::WHITE );
	light->setDiffuse ( Color::WHITE );
	light->setSpecular( Color::WHITE );
	light->setPosition( -2000, 2000, 1000 );
	light->enable();
	scene->addLight( light );

	light = new Light( "Lightsource 2 (yellow)" );
	light->setAmbient ( Color::LIGHT_YELLOW );
	light->setDiffuse ( Color::LIGHT_YELLOW );
	light->setSpecular( Color::LIGHT_YELLOW );
	light->setPosition(  2000, 2000, -1000 );
	light->enable();
	scene->addLight( light );

	light = new Light( "Lightsource 3 (magenta)" );
	light->setAmbient ( Color::DARK_BLUE );
	light->setDiffuse ( Color::DARK_BLUE );
	light->setSpecular( Color::DARK_BLUE );
	light->setPosition( -2000, 0, -1000 );
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

	//  Initialize control variables
	control_speed_more   = false;
	control_speed_less   = false;
	control_strafe_up    = false;
	control_strafe_down  = false;
	control_strafe_left  = false;
	control_strafe_right = false;
	control_turn_up      = false;
	control_turn_down    = false;
	control_turn_left    = false;
	control_turn_right   = false;
	control_speed        = 0;
	control_heading      = 0;
	control_pitch        = 0;
	control_roll         = 0;
	control_last_button  = 0;
	control_up_down      = 0;
	control_left_right   = 0;

	//  Run the simulation update timer
	SDL_AddTimer( 10, test_timer_callback, this );

	//  Tell the window manager to send events to this TestEvents
	//  instance, so that we can react to user input.
	wm->setFocus ( this );

	//  Enter Teddy loop.
	wm->inputLoop();

	//  From this point, execution is split in two threads.
	//  This thread is mostly running in the windowmanager's
	//  loop polling events and redrawing the display.

	//  The simulation update timer thread is executed at
	//  ten millisecond intervals. It animates the objects.
}


//!  MouseListener interface
/*virtual*/ void TestEvents::mouseKey( const int button, const int state, const int x, const int y ){
	if( state == SDL_PRESSED ){
		control_last_button = button;
	}
}


/*virtual*/ void TestEvents::mouseMotion( const int x, const int y, const int dx, const int dy ){
	switch( control_last_button ){
	case 2:
	case 3:
		control_roll    += 0.1f * dx;
		control_speed   -= 0.1f * dy;
		break;
	case 0:
	case 1:
	default:
		control_heading -= 0.1f * dx;
		control_pitch   -= 0.1f * dy;
		break;
	}
}


/*!
	Handle key down events. When control key is pressed,
	the control is activated. If escape or q is pressed,
	program exists instantly. If space is pressed, speed
	of the camera is set to zero.
*/
/*virtual*/ void TestEvents::keyDown( const SDL_keysym key ){
	switch( key.sym ){
	case SDLK_ESCAPE:
	case 'q'        : exit(0); break;

	case CONTROL_KEY_TURN_RIGHT  : control_turn_right   = true; break;
	case CONTROL_KEY_TURN_LEFT   : control_turn_left    = true; break;
	case CONTROL_KEY_TURN_UP     : control_turn_up      = true; break;
	case CONTROL_KEY_TURN_DOWN   : control_turn_down    = true; break;
	case CONTROL_KEY_FORWARD     : control_speed_more   = true; break;
	case CONTROL_KEY_BACKWARD    : control_speed_less   = true; break;
	case CONTROL_KEY_STRAFE_LEFT : control_strafe_right = true; break;  
	case CONTROL_KEY_STRAFE_RIGHT: control_strafe_left  = true; break;  
	case CONTROL_KEY_STRAFE_UP   : control_strafe_up    = true; break;  
	case CONTROL_KEY_STRAFE_DOWN : control_strafe_down  = true; break;  
	case CONTROL_KEY_FASTER      : control_faster       = true; break;  
	default: break;
	}
};


/*!
	Handle key up events. When control key is released,
	the control is deactivated.
*/
/*virtual*/ void TestEvents::keyUp( const SDL_keysym key ){
	switch( key.sym ){
	case CONTROL_KEY_TURN_RIGHT  : control_turn_right   = false; break;
	case CONTROL_KEY_TURN_LEFT   : control_turn_left    = false; break;
	case CONTROL_KEY_TURN_UP     : control_turn_up      = false; break;
	case CONTROL_KEY_TURN_DOWN   : control_turn_down    = false; break;
	case CONTROL_KEY_FORWARD     : control_speed_more   = false; break;
	case CONTROL_KEY_BACKWARD    : control_speed_less   = false; break;
	case CONTROL_KEY_STRAFE_LEFT : control_strafe_right = false; break;  
	case CONTROL_KEY_STRAFE_RIGHT: control_strafe_left  = false; break;  
	case CONTROL_KEY_STRAFE_UP   : control_strafe_up    = false; break;  
	case CONTROL_KEY_STRAFE_DOWN : control_strafe_down  = false; break;  
	case CONTROL_KEY_FASTER      : control_faster       = false; break;  
	default: break;
	}
};


/*!
	This is the timer update function implementation.
	Variables frame_age, sys_time and sync are provided by Teddy.
*/
Uint32 test_timer_callback( Uint32 interval, void *param ){
	TestEvents *tester = (TestEvents *)( param );
	
	sys_time += frame_age = sync.Passed();

	tester->applyControls ();
	tester->animateObjects();

	sync.Update();
	
	return interval;
}


//!  Apply controls
void TestEvents::applyControls(){
	float term;

	if( control_faster == true ){
		term = 0.2f;
	}else{
		term = 0.1f;
	}

	//  Faster and slower
	if( control_speed_more == true  && control_speed_less == false ){
		control_speed += term;
	}
	if( control_speed_more == false && control_speed_less == true  ){
		control_speed -= term;
	}

	//  Strafe left and right
	if( control_strafe_left == true  && control_strafe_right == false ){
		control_left_right += term;
	}
	if( control_strafe_left == false && control_strafe_right == true  ){
		control_left_right -= term;
	}

	//  Strafe up and down
	if( control_strafe_up == true  && control_strafe_down == false ){
		control_up_down += term;
	}
	if( control_strafe_up == false && control_strafe_down == true  ){
		control_up_down -= term;
	}

	//  Turn left and right
	if( control_turn_left == true  && control_turn_right == false ){
		control_heading += term;
	}
	if( control_turn_left == false && control_turn_right == true  ){
		control_heading -= term;
	}

	//  Turn up and down
	if( control_turn_up == true  && control_turn_down == false ){
		control_pitch += term;
	}
	if( control_turn_up == false && control_turn_down == true  ){
		control_pitch -= term;
	}

	//  Apply rotations
	camera->heading( control_heading );
	camera->pitch  ( control_pitch   );
	camera->roll   ( control_roll    );

	//  Calculate and apply translation
	Vector delta;
	delta  = camera->getViewAxis () * control_speed;
	delta += camera->getRightAxis() * control_left_right;
	delta += Vector( 0, control_up_down, 0 );
	camera->translate( delta );

	//  Dampen all controls so if there is no user input
	//  the controls will eventually halt
	control_heading    *= 0.88f;
	control_pitch      *= 0.88f;
	control_roll       *= 0.88f;
	control_speed      *= 0.98f;
	control_up_down    *= 0.98f;
	control_left_right *= 0.98f;
}


//!  Animate objects
void TestEvents::animateObjects(){
	float x;
	float y;
	float z;

	//  Animation: calculate new positions for spheres
	y = 50 + fabs(  200 * sin( sys_time/270 )  );
	x = 220 * cos( sys_time/333 );
	z = 200 * sin( sys_time/333 );
	sphere_obj1->setPosition( x, y, z );

	x = 220 * cos( M_2_PI / 3 + sys_time/333 );
	z = 200 * sin( M_2_PI / 3 + sys_time/333 );
	sphere_obj2->setPosition( x, y, z );

	x = 220 * cos( 2 * M_2_PI / 3 + sys_time/333 );
	z = 200 * sin( 2 * M_2_PI / 3 + sys_time/333 );
	sphere_obj3->setPosition( x, y, z );

	y = 250 + fabs(  300 * sin( sys_time/350 )  );
	sphere_obj4->setPosition( 0, y, -500 );

	//  Rotate tubes
	tube_obj1->heading(  5 );
	tube_obj2->heading( -1 );
}


void TestEvents::addObjects(){
	//  Create some shapes
	Box    *box_mesh       = new Box   ( "Box shape",          400,  400,  200             );
	Box    *floor_box_mesh = new Box   ( "Floor box shape",   2000,  100, 2000             );
	Cone   *cone_mesh      = new Cone  ( "Cone shape",         100,    0,  400, 4*SD, 4*SD );
	Cone   *cylinder_mesh  = new Cone  ( "Cylinder shape",     100,  100,  200, 4*SD, 4*SD );
	Sphere *sphere_mesh1   = new Sphere( "Small Sphere shape",  50,   15,       3*SD       );
	Sphere *sphere_mesh2   = new Sphere( "Big Sphere shape",   150,             6*SD, 5*SD );
	Torus  *torus_mesh     = new Torus ( "Torus shape",        150,   40,       6*SD, 6*SD );
	Tube   *tube_mesh      = new Tube  ( "Tube shape",          40,   10,       3*SD, 3*SD );

	//  Create objects
	box_obj1    = new ModelInstance( "Box one",      box_mesh       );
	box_obj2    = new ModelInstance( "Box two",      box_mesh       );
	floor_box   = new ModelInstance( "Floor box",    floor_box_mesh );
	cone_obj1   = new ModelInstance( "Cone one",     cone_mesh      );
	cone_obj2   = new ModelInstance( "Cone two",     cone_mesh      );
	cyl_obj1    = new ModelInstance( "Cylinder one", cylinder_mesh  );
	cyl_obj2    = new ModelInstance( "Cylinder two", cylinder_mesh  );
	sphere_obj1 = new ModelInstance( "Sphere 1",     sphere_mesh1   );
	sphere_obj2 = new ModelInstance( "Sphere 2",     sphere_mesh1   );
	sphere_obj3 = new ModelInstance( "Sphere 3",     sphere_mesh1   );
	sphere_obj4 = new ModelInstance( "Sphere 4",     sphere_mesh1   );
	sphere_obj5 = new ModelInstance( "Big Sphere",   sphere_mesh2   );
	torus_obj1  = new ModelInstance( "Torus",        torus_mesh     );
	tube_obj1   = new ModelInstance( "Tube One",     tube_mesh      );
	tube_obj2   = new ModelInstance( "Tube Two",     tube_mesh      );

	//  Set objects' materials
	Material *textured_material1 = new Material(Material::WHITE,RENDER_LIGHTING_SIMPLE);
	Material *textured_material2 = new Material(Material::WHITE,RENDER_LIGHTING_SIMPLE);
	Texture  *texture1           = new SdlTexture( "textures/texture9.jpg" );
	Texture  *texture2           = new SdlTexture( "textures/grid32.png" );
	Vector    texture_center     = Vector(   0,   0,   0 );
	Vector    texture_size       = Vector( 400, 400, 400 );

	box_mesh->makeCubicTextureCoordinates(
		texture_center,
		texture_size
	);

	floor_box_mesh->makeCubicTextureCoordinates(
		texture_center,
		Vector( 250, 250, 250 )
	);
	textured_material1->setTexture( texture1 );
	textured_material2->setTexture( texture2 );

	box_obj1   ->setMaterial( textured_material1       );
	box_obj2   ->setMaterial( textured_material1       );
	floor_box  ->setMaterial( textured_material2       );
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
	floor_box  ->setPosition(    0, -50,    0 );
	cone_obj1  ->setPosition( -400,   0,    0 );
	cone_obj2  ->setPosition(  400,   0,    0 );
	cyl_obj1   ->setPosition(  200,   0,  500 );
	cyl_obj2   ->setPosition(    0,   0, -500 );
	sphere_obj1->setPosition(    0, 250,  220 );
	sphere_obj2->setPosition(    0, 250, -220 );
	sphere_obj3->setPosition( -220, 250,    0 );
	sphere_obj4->setPosition(  220, 250,    0 );
	sphere_obj5->setPosition(    0, 150,    0 );  //  radius 150
	torus_obj1 ->setPosition(    0,  40,    0 );
	tube_obj1  ->setPosition( -400, 400,    0 );
	tube_obj2  ->setPosition(  400, 400,    0 );

	//  Add objects to the scene
	scene->addInstance( box_obj1    );
	scene->addInstance( box_obj2    );
	scene->addInstance( floor_box   );
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

	//  add spheres to show lightsource locations
	ModelInstance *li1 = new ModelInstance( "White Light indicator",  sphere_mesh1 );
	ModelInstance *li2 = new ModelInstance( "Yellow Light indicator", sphere_mesh1 );
	ModelInstance *li3 = new ModelInstance( "Blue Light indicator",   sphere_mesh1 );
	li1->setMaterial( new Material(Material::WHITE,        RENDER_LIGHTING_COLOR) );
	li2->setMaterial( new Material(Material::LIGHT_YELLOW, RENDER_LIGHTING_COLOR) );
	li3->setMaterial( new Material(Material::DARK_BLUE,    RENDER_LIGHTING_COLOR) );
	li1->setPosition( -2000, 2000,  1000 );
	li2->setPosition(  2000, 2000, -1000 );
	li3->setPosition( -2000,    0, -1000 );
	scene->addInstance( li1 );
	scene->addInstance( li2 );
	scene->addInstance( li3 );
}

