
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


#include "SDL.h"
#include "glElite/CollisionGroup.h"
#include "glElite/ComputerShip.h"
#include "glElite/Console.h"
#include "glElite/PlayerShip.h"
#include "glElite/SimulationTimer.h"
#include "glElite/Ship.h"
#include "glElite/ShipType.h"
#include "glElite/ShipCamera.h"
#include "glElite/ui.h"
#include "Imports/LWMesh.h"
#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Models/Box.h"
#include "PhysicalComponents/WindowManager.h"
#include "PhysicalComponents/Layer.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
#include "SDL_video.h"
#include "SysSupport/Messages.h"
#include <cmath>
#include <cstdio>
using namespace Graphics;
using namespace Imports;
using namespace Models;
using namespace PhysicalComponents;
//using namespace UniverseDevelopmentKit;


namespace Application {


#define SIMULATION_INTERVAL_MS 10
#define PITCH_CONST  (float)(   1.0f * M_2_PI/1000000.0f )  //  RADS PER TICK
#define ROLL_CONST   (float)(   1.0f * M_2_PI/1000000.0f )  //  RADS PER TICK
#define MAX_PITCH    (float)( 250.0f * M_2_PI/1000000.0f )  //  RADS PER TICK
#define MAX_ROLL     (float)( 250.0f * M_2_PI/1000000.0f )  //  RADS PER TICK
#define ACCEL_CONST  (float)(   0.0020f)                    //  m/s PER TICK
#define MAX_SPEED    (float)(   6.5000f)                    //  m/s PER TICK


ConsoleStream  con;
UI            *ui = NULL;


//!  Constructor the the testing user interface.
UI::UI( int argc, char **argv ){
	ui = this;
	parseOptions( argc, argv );
	unsigned long flags = SDL_OPENGLBLIT;  // SDL_OPENGL
	if( isEnabled(ENABLE_FULLSCREEN) == true ){
		flags |= SDL_FULLSCREEN;
	}

	init_materials      ();
	init_graphics_device();

	solar_bodies_cg = new CollisionGroup( "solar bodies" );

	//	View must be the first thing to be created before other OpenGL related things
	view = new View( "Teddy", SCREEN_X, SCREEN_Y, flags ); 

	init_msg( "CVertex::Array..." );
//	CVertex::Array.Init();
//	CVertex::Array.EnableVertexArray();
//	CVertex::Array.EnableNormalArray();
//  CVertex::Array.EnableTextureCoordArray();

	window_manager = new WindowManager( view );
	view->setWindowManager( window_manager );
	Area::setDefaultWindowManager( window_manager );
//	Mesh *cobra_mesh = new Box( "cobra", 30,10,20);
//	Mesh *viper_mesh = new Box( "viper", 10,10,40);
	Mesh     *cobra_mesh      = new LWMesh  ( "cobra_with_texture.lwo", 0 );
	Mesh     *viper_mesh      = new LWMesh  ( "VIPER.lwo",              0 );
	ShipType *cobra_ship_type = new ShipType( cobra_mesh, ACCEL_CONST, MAX_SPEED, PITCH_CONST, ROLL_CONST, MAX_PITCH, MAX_ROLL );
	ShipType *viper_ship_type = new ShipType( viper_mesh, ACCEL_CONST, MAX_SPEED, PITCH_CONST, ROLL_CONST, MAX_PITCH, MAX_ROLL );
	scene         = new Scene     ( "Test scene" );
	camera        = new Camera    ( "Spectator Camera", scene );
	camera2       = new Camera    ( "Other View",       scene );
	layer         = new Layer     ( "Test Layer",       view );
	console       = new Console   ( "Standard IO Console", 45, 14 );
	active_camera = camera;

	player_ship     = new PlayerShip( this, cobra_ship_type );
	Ship *wingman_1 = new ComputerShip( "Wingman 1", viper_ship_type );
	Ship *wingman_2 = new ComputerShip( "Wingman 2", viper_ship_type );
	wingman_1->setTarget( player_ship, Vector(-400,0,-300) );
	wingman_2->setTarget( player_ship, Vector( 400,0,-300) );
	wingman_1->setTargetPosition();
	wingman_2->setTargetPosition();

	player_camera = new ShipCamera( player_ship, scene, NULL );
	player_camera->disableOptions( MI_VISIBLE );

	scene->addInstance( player_ship );
	scene->addInstance( player_camera );  //  Needed in scene so it will be ticked to be kept at player_ship location
	scene->addInstance( wingman_1 );
	scene->addInstance( wingman_2 );
	
//	camera->setCollisionGroup( solar_bodies_cg );

	//  Initialize spectator camera control variables
	control_speed_more  = false;
	control_speed_less  = false;
	control_speed       = 0;
	control_heading     = 0;
	control_pitch       = 0;
	control_roll        = 0;
	control_last_button = 0;
	
	con.setCon( console );
	
	initAudio();
	setActiveCamera( camera );
	initActions();
	initPhysicalComponents();
	initObjects();
	SDL_Delay( 5 );
	init_msg( "simulation_timer..." );
	simulation_timer = SDL_AddTimer( SIMULATION_INTERVAL_MS, SimulationTimer::callb, this );		
	playHyper();
	window_manager->inputLoop();
}


void UI::parseOptions( int argc, char **argv ){
	init_msg( "UI::parseOptions..." );
	int  i;

	setOptions( ENABLE_AUDIO | ENABLE_WINDOWS | ENABLE_CABIN );

	for( i=1; i<argc; i++ ){
		if( strcmp(argv[i],"--fullscreen") == 0 ){
			enableOptions( ENABLE_FULLSCREEN );
		}else if( strcmp(argv[i],"--width") == 0 ){
			if( argc > i+1 ){
				SCREEN_X = atoi( argv[i+1] );
			}else{
				printf( "width needs parameter\n" );
			}
		}else if( strcmp(argv[i],"--height") == 0 ){
			if( argc > i+1 ){
				SCREEN_Y = atoi( argv[i+1] );
			}else{
				printf( "height needs parameter\n" );
			}
		}else if( strcmp(argv[i],"--background") == 0 ){
			enableOptions( ENABLE_BACKGROUND_WINDOW );
		}else if( strcmp(argv[i],"--no-background") == 0 ){
			disableOptions( ENABLE_BACKGROUND_WINDOW );
		}else if( strcmp(argv[i],"--no-audio") == 0 ){
			disableOptions( ENABLE_AUDIO );
		}else if( strcmp(argv[i],"--no-windows") == 0 ){
			disableOptions( ENABLE_WINDOWS );
		}else if( strcmp(argv[i],"--no-cabin") == 0 ){
			disableOptions( ENABLE_CABIN );
		}else if( strcmp(argv[i],"--debug") == 0 ){
			enableOptions( ENABLE_DEBUG );
		}
	}

	if( SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE|SDL_INIT_AUDIO) < 0 ){
		fatal_msg( MSG_HEAD "Unable to initialize SDL: %s\n", SDL_GetError() );
	}else{
		atexit( SDL_Quit );
	}

	//	Print initialization messages
	if( isEnabled(ENABLE_AUDIO) == true ){
		printf( "audio enabled\n" );
	}else{
		printf( "audio disabled\n" );
		
	}

	if( isEnabled(ENABLE_BACKGROUND_WINDOW) ){
		init_msg( "background window enabled" );
	}else{
		init_msg( "background window disabled" );
	}

	if( isEnabled(ENABLE_WINDOWS) == true ){
		init_msg( "windows enabled" );
	}else{
		init_msg( "windows disabled" );
	}

	if( isEnabled(ENABLE_CABIN) == true ){
		init_msg( "cabin enabled" );
	}else{
		init_msg( "cabin disabled" );
	}

	if( isEnabled(ENABLE_FULLSCREEN) == true ){
		init_msg( "fullscreen enabled" );
	}else{
		init_msg( "fullscreen disabled" );
	}

	if( isEnabled(ENABLE_DEBUG) == true ){
		init_msg( "debug enabled" );
	}else{
		init_msg( "debug disabled" );
	}
}


//!  Accessor for scene;
Scene *UI::getScene(){
	return scene;
}

Camera *UI::getCamera(){
	return this->active_camera;
}

Console *UI::getConsole(){
	return this->console;
}

PlayerShip *UI::getPlayerShip(){
	return this->player_ship;
}

ShipCamera *UI::getShipCamera(){
	return this->player_camera;
}


};  //  namespace Application

