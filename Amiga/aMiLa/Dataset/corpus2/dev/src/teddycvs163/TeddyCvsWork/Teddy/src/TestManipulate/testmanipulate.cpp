
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
	\file   TestManipulate.cpp
	\author Timo Suoranta
	\brief  Teddy example program for object manipulation
	\date   2001
*/


#include "TestManipulate.h"
#include "LSystem.h"
#include "Timer.h"

#include "Graphics/View.h"
#include "Materials/Light.h"
#include "Materials/Material.h"
#include "Materials/SdlTexture.h"
#include "Models/Box.h"
#include "Models/Mesh.h"
#include "Models/ModelInstance.h"
#include "PhysicalComponents/Layer.h"
#include "PhysicalComponents/Projection.h"
#include "PhysicalComponents/WindowManager.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
#include "SysSupport/Messages.h"
#include "SDL.h"
using namespace Graphics;
using namespace Materials;
using namespace Models;
using namespace Scenes;
using namespace PhysicalComponents;


/*!
	This is the test setup constructor.
*/
TestManipulate::TestManipulate()
:EventListener(EVENT_KEY_DOWN_M|EVENT_KEY_UP_M|EVENT_MOUSE_KEY_M|EVENT_MOUSE_HOLD_DRAG_M)
{
	int   screen_x = 640;         //!<  Width of SDL window
	int   screen_y = 480;         //!<  Height of SDL window
	int   flags    = SDL_OPENGL;  //!<  SDL_OPENGL is needed

	//  A View must be created first before much else can be done
	view   = new View  ( "TestManipulate", screen_x, screen_y, flags ); 

	//  Create scene and camera
	scene  = new Scene ( "Test Scene"         );
	camera = new Camera( "Test Camera", scene );

	//  Set initial camera configuration (that is, position and attitude)
	camera->setPosition( 0, 100, 100 );

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
	light->setPosition( -2000, 4000, 1000 );
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


void TestManipulate::addObjects(){
	//  Create some shapes
	Box     *floor_box_mesh = new Box    ( "Floor box shape", 2000,  100, 2000  );
	LSystem *lsystem1       = new LSystem();
	LSystem *lsystem2       = new LSystem();
	LSystem *lsystem3       = new LSystem();

#	if 0  // Some tests - if enabled, disable snowflake
	lsystem1->setAxiom( "K" );  // Try others as well
	lsystem1->setRule ( 'A', "[F&F&F^F^F]"           );  //  pitch
	lsystem1->setRule ( 'B', "[&&F+F+F-F-F]"         );  //  heading
	lsystem1->setRule ( 'C', "[F&F&F]"               );  //  roll
	lsystem1->setRule ( 'D', "[F<&F&F]"              );
	lsystem1->setRule ( 'E', "[F<<&F&F]"             );
	lsystem1->setRule ( 'I', "[F&(45)F&(45)F]"       );  //  parameter
	lsystem1->setRule ( 'J', "[F&(30)F&(30)F&(30)F]" );
	lsystem1->setRule ( 'K', "[';&FK]"               );  //  Recursive angle change
	lsystem1->setAngle( 10.0f );
	lsystem1->expand  ( 5     );
	lsystem1->generate();
#	endif

	//  Snowflake
	lsystem1->setAxiom ( "-(30)F--F--F" );
	lsystem1->setLength( 1.0f );
	lsystem1->setRule  ( 'F', "F+F--F+F"   ); 
	lsystem1->setAngle ( 60.0f );
	lsystem1->expand   ( 4 );
	lsystem1->generate ();


	//  Tree
	lsystem2->setAxiom ( "T"   );
	lsystem2->setLength( 10.0f );
	lsystem2->setRule  ( 'T', "CCA" );
	lsystem2->setRule  ( 'A', "CBD>(94)CBD>(132)BD" );
	lsystem2->setRule  ( 'B', "[&CDCD$A]"       );
	lsystem2->setRule  ( 'D', "[g(5)Lg(5)L]"    );
	lsystem2->setRule  ( 'C', "!(0.95)~(5)tF"   );
	lsystem2->setRule  ( 'F', "'(1.25)F'(0.8)"  );
	lsystem2->setRule  ( 'L', "[~f(20)c(2){+(30)f(20)-(120)f(20)-(120)f(20)}]" );
	lsystem2->setRule  ( 'f', "'(0.7071)" );
	lsystem2->setRule  ( 'z', "_"         );
	lsystem2->setAngle ( 20.0 );
	lsystem2->expand   ( 10   );
	lsystem2->generate ();

	//  Plant
	lsystem3->setAxiom ( "x"   );
	lsystem3->setLength(  1.0f );
	lsystem3->setRule  ( 'x', "<(5)F[++x][--x]<(5)'(1.1)F[++x][--x]'(0.9)F>(5)[+x][-x]'(0.9)F>(5)[x]" ); 
	lsystem3->setRule  ( 'F', "<(10)FFF>(10)" ); 
	lsystem3->setAngle ( 30.0f );
	lsystem3->expand   (  4    );
	lsystem3->generate ();

	//  Create objects
	floor_box     = new ModelInstance( "Floor box", floor_box_mesh );
	lsystem_obj1  = new ModelInstance( "Snowflake", lsystem1 );
	lsystem_obj2a = new ModelInstance( "Tree 1",    lsystem2 );
	lsystem_obj2b = new ModelInstance( "Tree 2",    lsystem2 );
	lsystem_obj2c = new ModelInstance( "Tree 3",    lsystem2 );
	lsystem_obj3  = new ModelInstance( "Plant",     lsystem3 );

	//  Set objects' materials
	Material *m1           = new Material  ( Material::WHITE,        RENDER_LIGHTING_COLOR  );
	Material *m2           = new Material  ( Material::LIGHT_ORANGE, RENDER_LIGHTING_COLOR  );
	Material *m3           = new Material  ( Material::LIGHT_GREEN,  RENDER_LIGHTING_COLOR  );
	Material *textured_mat = new Material  ( Material::WHITE,        RENDER_LIGHTING_SIMPLE );
//	Texture  *texture      = new SdlTexture( "textures/grid256.png" );
	Texture  *texture      = new SdlTexture( "gui/frontier_cursor.png" );

	floor_box_mesh->makeCubicTextureCoordinates(
		Vector(   0,   0,   0 ),
		Vector( 250, 250, 250 )
	);
	textured_mat->setTexture( texture );

	//  This makes polygons double-sided
	m1->disableOptions( RENDER_OPTION_CULL_FACE_M );
	m2->disableOptions( RENDER_OPTION_CULL_FACE_M );
	m3->disableOptions( RENDER_OPTION_CULL_FACE_M );

	floor_box    ->setMaterial( textured_mat );
	lsystem_obj1 ->setMaterial( m1 );
	lsystem_obj2a->setMaterial( m2 );
	lsystem_obj2b->setMaterial( m2 );
	lsystem_obj2c->setMaterial( m2 );
	lsystem_obj3 ->setMaterial( m3 );

	//  Set objects' positions
	floor_box    ->setPosition(    0,  -50,    0 );
	lsystem_obj1 ->setPosition( -400,   50,    0 );
	lsystem_obj2a->setPosition(    0,    0,  100 );
	lsystem_obj2b->setPosition(  300,    0,    0 );
	lsystem_obj2c->setPosition( -100,    0, -200 );
	lsystem_obj3 ->setPosition(  400,    0,    0 );

	//  Add objects to the scene
	scene->addInstance( floor_box     );
	scene->addInstance( lsystem_obj1  );
	scene->addInstance( lsystem_obj2a );
	scene->addInstance( lsystem_obj2b );
	scene->addInstance( lsystem_obj2c );
	scene->addInstance( lsystem_obj3  );
}

