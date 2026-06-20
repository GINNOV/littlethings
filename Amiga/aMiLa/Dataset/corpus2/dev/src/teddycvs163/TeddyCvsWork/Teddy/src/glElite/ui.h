
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
	\class   UI
	\ingroup g_application
	\author  Timo Suoranta
	\brief   UserInterface
	\warning This is the temprorary testing environment only.
	\date    1999, 2000, 2001
	
	This class contains the application logic for the testing environment.
*/


#ifndef TEDDY_APPLICATION_UI_H
#define TEDDY_APPLICATION_UI_H


#include "glElite/ConsoleStream.h"
#include "MixIn/Options.h"
#include "SDL_timer.h"
namespace Scenes             { class Camera;         };
namespace Scenes             { class Scene;          };
namespace Graphics           { class View;           };
namespace PhysicalComponents { class Layer;          };
namespace PhysicalComponents { class WindowManager;  };
namespace Models             { class ModelInstance;  };
namespace Models             { class CollisionGroup; };
using namespace Graphics;
using namespace Models;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Application {


#define MM_CONTROL_CAMERA         0
#define MM_TRANSLATE_INSTANCE     1
#define MM_ROTATE_SCALE_INSTANCE  2


class Console;
class FrontCamera;
class Sight;
class Hud;
class Scanner;
class ShipType;
class Ship;
class PlayerShip;
class ShipCamera;


#define ENABLE_FULLSCREEN        (1<<0)
#define ENABLE_BACKGROUND_WINDOW (1<<1)
#define ENABLE_AUDIO             (1<<2)
#define ENABLE_WINDOWS           (1<<3)
#define ENABLE_CABIN             (1<<4)
#define ENABLE_DEBUG             (1<<5)


class UI : public Options {
public:
	UI( int argc, char **argv );

	//  Accessors
	Console    *getConsole   ();
	Camera     *getCamera    ();
	Scene      *getScene     ();
	PlayerShip *getPlayerShip();
	ShipCamera *getShipCamera();

	//  Actions
	void cameraRotate         ( const int x, const int y );  // mouse move delta
	void cameraTranslate      ( const int x, const int y );  // mouse move delta
	void instanceRotate       ( const int x, const int y );  // mouse move delta
	void instanceScale        ( const int x, const int y );  // mouse move delta
	void instanceTranslateXZ  ( const int x, const int y );  // mouse move delta
	void instanceTranslateYZ  ( const int x, const int y );  // mouse move delta

	void updateSimulation     ();
	
	//  Action logical components FIX (no registering, no mapping...)
	void toggleCamera         ();

	void setActiveCamera      ( Camera *c );
	void mouseMotion          ( const int b, const int x_delta, const int y_delta );
	void selectInstance       ( const int x, const int y );
	void displayHelp          ();  
	void displayExtensions    ();
	void instanceDebug        ();
	void instanceFace         ();
	void instanceCycle        ();
	void scannerCycle         ();
	void renderModePoint      ();
	void renderModeLine       ();
	void renderModeFill       ();
	void renderModeFillOutline();
	void cullFaceEnable       ();
	void cullFaceDisable      ();
	void depthTestEnable      ();
	void depthTestDisable     ();
	void lightingOn           ();
	void lightingOff          ();
	void blendOn              ();
	void blendOff             ();
	void fovNormal            ();
	void fovWide              ();
	void antialiseOn          ();
	void antialiseOff         ();
	void chooseMouseMode      ();
	void quit                 ();

	//  initObjects() subroutines to add things to scene
	void addLights     ( int num  =1, const bool animate=false );
	void addGrid       ( int xcount, int zcount, int xspace, int zspace );
	void addPrimitives ();
	void loadLWO       ();
	void addFFE        ();
	void addROAM       ();
	void addRigidBodies();

	//  audio API
	void playWav    ( void *chunk );
	void playPulse  ();
	void playHyper  ();
	void playExplode();

protected:
	View           *view;             //!<  Render Context
	Scene          *scene;            //!<  Container for renderable 3D objects
	Camera         *active_camera;    //!<
	Camera         *camera;           //!<  User controllable camera
	Camera         *camera2;          //!<  Another User controllable camera
	ShipCamera     *player_camera;    //!<  Player ship camera;
	Console        *console;
	Layer          *layer;            //!<  Fullscreen area of view; receives inputs, contains rest of physical components
	FrontCamera    *front_camera;     //!<  Projection area for camera(s)
	FrontCamera    *front_camera2;    //!<  Projection area for camera(s)
	Sight          *sight;            //!<  Simple sight component (for FrontCamera)
	Hud            *hud;              //!<  Small information display component
	Scanner        *scanner;          //!<  Radar component
	ModelInstance  *instance;         //!<  Selected instance from scene
	WindowManager  *window_manager;   //!<  Window manager
	CollisionGroup *solar_bodies_cg;  //!<  Collision group for solar bodies
	ShipType       *ship_type;        //!<  Ship type
	PlayerShip     *player_ship;      //!<  Player ship

	SDL_TimerID    simulation_timer;
	int            mouse_mode;          //!<  Currently active mouse control mode

	//  Spectator camera control
	float control_roll;
	float control_heading;
	float control_pitch;
	bool  control_speed_more;
	bool  control_speed_less;
	float control_speed;
	int   control_last_button;

	//  Initialization routines
	void parseOptions          ( int argc, char **argv );
	void initActions           ();
	void initAudio             ();
	void initObjects           ();
	void initPhysicalComponents();
	void initPreferences       ();

	//  FIX
	void inputLoop();
};


extern ConsoleStream  con;
extern UI            *ui;


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_UI_H

