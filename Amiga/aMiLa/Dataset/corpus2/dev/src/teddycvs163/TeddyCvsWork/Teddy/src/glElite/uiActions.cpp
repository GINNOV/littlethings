
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
	\file
	\ingroup g_testing_environment
	\author  Timo Suoranta
	\warning This file contains Logical UserInterface Actions except settings
	\date	 2001
*/


#include "config.h"
#include "glElite/ui.h"
#include "glElite/Action.h"
#include "glElite/PlayerShip.h"
#include "glElite/LogicalUI.h"
#include "glElite/FrontCamera.h"
#include "glElite/Hud.h"
#include "glElite/Scanner.h"
#include "glElite/Sight.h"
#include "glElite/ShipCamera.h"
#include "Graphics/Features.h"
#include "Graphics/View.h"
#include "PhysicalComponents/Layer.h"
#include "Models/Mesh.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
#include "SysSupport/Messages.h"
using namespace Scenes;


namespace Application {


#define TRANSLATE_SCALE   1.0f
#define ROTATE_SCALE	  0.3f
#define distance_delta	  0.01f
#define SCALE			  1.00f


static void action_quit 			 ( void *param ){ ui->quit();				  }
static void action_display_extensions( void *param ){ ui->displayExtensions();	  }
static void action_add_ffe			 ( void *param ){ ui->addFFE(); 			  }
static void action_add_roam 		 ( void *param ){ ui->addROAM();			  }
static void action_load_lwo 		 ( void *param ){ ui->loadLWO();			  }
static void action_add_primitives	 ( void *param ){ ui->addPrimitives();		  }
static void action_help 			 ( void *param ){ ui->displayHelp();		  }


//!  Initialize actions
void UI::initActions(){
	init_msg( "initActions..." );
	mouse_mode = MM_CONTROL_CAMERA;
	instance   = NULL;
	displayHelp();

	LogicalUI *lui = new LogicalUI();
	lui->insert( new Action( "quit",		   action_quit				 ) );
	lui->insert( new Action( "extensions",	   action_display_extensions ) );
	lui->insert( new Action( "add ffe", 	   action_add_ffe			 ) );
	lui->insert( new Action( "add roam",	   action_add_roam			 ) );
	lui->insert( new Action( "load lwo",	   action_load_lwo			 ) );
	lui->insert( new Action( "add primitives", action_add_primitives	 ) );
	lui->insert( new Action( "help",		   action_help				 ) );
//	lui->insert( new Action( "minicam", 	   action_minicam			 ) );
	console->setLogicalUI( lui );
}


void UI::toggleCamera(){
	static int toggle = 0;

	toggle = 1 - toggle;

	if( toggle == 0 ){
		front_camera->setCamera( camera );
	}else{
		front_camera->setCamera( player_camera );
	}
}


//!  Exit program
void UI::quit(){
	exit( 0 );
}


//!
void UI::setActiveCamera( Camera *c ){
	this->active_camera = c;
//	this->player_ship   = c;
}


//!
void UI::chooseMouseMode(){
	mouse_mode++;
	if( mouse_mode>2 ){
		mouse_mode = 0;
	}
	switch( mouse_mode ){
	case MM_CONTROL_CAMERA:
		con << ": Drag Left Mouse Buttom down: Rotate camera" << endl;
		con << ": Drag Right Mouse Button down: Move forward/backward" << endl;
		break;
	case MM_TRANSLATE_INSTANCE:
		con << ": Drag Left Mouse Buttom down: Translate object X, Z" << endl;
		con << ": Drag Right Mouse Button down: Translate object X, Y" << endl;
		break;
	case MM_ROTATE_SCALE_INSTANCE:
		con << ": Drag Left Mouse Buttom down: Rotate object X, Y" << endl;
		con << ": Drag Right Mouse Button down: Rotate object Z, Scale object" << endl;
		break;
	default:
		break;
	}
}


//!  Interface: Displace help message in console
void UI::displayHelp(){
/*	con << ":: TEDDY ODE DEMO " << endl;
	con << "::  - Press once 3" << endl;
	con << "::  - Then click on box" << endl;
	con << "::  - Then drag box" << endl;
	con << "::  Or: Shoot at boxes (key a)" << endl;*/
	con << "Teddy - Timo Suoranta" << endl << endl;
	con << ": Commands:" << endl;
	con << ": help, quit, extensions, load lwo" << endl;
	con << ": add ffe, add roam, add primitives" << endl;
	con << ": Control pitch keys: s x" << endl;
	con << ": Control roll  keys: , ." << endl;
	con << ": Control speed keys: space tab esc" << endl;
}


//!  Display OpenGL extensions
void UI::displayExtensions(){

	con << ": OpenGL driver information:" << endl;
	con << ": " << view->getVendor  () << endl;
	con << ": " << view->getRenderer() << endl;
	con << ": " << view->getVersion () << endl;
	con << ": OpenGL extensions:" << endl;
	char *start;
	char *i;
	start = i = view->getExtensions();
	while( *i != '\0' ){
		if( *i==' ' ){
			*i = '\0';
			con << ": " << start << endl;
			start = ++i;
			continue;
		}
		i++;
	}
	int width  = 0;
	int height = 0;
	view->getMaxViewportDims( width, height );
	con << ": Maximum texture size:  " << view->getMaxTextureSize() << endl;
	con << ": Maximum lights:		 " << view->getMaxLights     () << endl;
	con << ": Maximum viewport dims: " << width << " x " << height  << endl;
}
				

//!  mouse motion
void UI::mouseMotion( const int b, const int x_delta, const int y_delta ){
	switch( mouse_mode ){
	case MM_CONTROL_CAMERA: 
		switch( b ){
		case 1: cameraRotate   ( x_delta, y_delta ); break;
		case 2: cameraTranslate( x_delta, y_delta ); break;
		case 3: cameraTranslate( x_delta, y_delta ); break;
		default: break;
		}
		break;
	case MM_TRANSLATE_INSTANCE:
		switch( b ){
		case 1: instanceTranslateXZ( x_delta, y_delta ); break;
		case 2: instanceTranslateYZ( x_delta, y_delta ); break;
		case 3: instanceTranslateYZ( x_delta, y_delta ); break;
		default: break;
		}
		break;
	case MM_ROTATE_SCALE_INSTANCE:
		switch( b ){
		case 1: instanceRotate( x_delta, y_delta ); break;
		case 2: instanceScale ( x_delta, y_delta ); break;
		case 3: instanceScale ( x_delta, y_delta ); break;
		default: break;
		}
		break;
	default:
		break;
	}
}


//!  translate instance on XZ plane
void UI::instanceTranslateXZ( const int x_delta, const int y_delta ){
	if( instance==NULL ){
		return;
	}

//	instance->translate( Vector( -x_delta, 0.0, -y_delta ) );
	DoubleVector pos = instance->getPosition();
	pos += DoubleVector( x_delta*0.1, 0.0, y_delta*0.1 );
	instance->setPosition( pos );
}


//!  translate instance on YZ plane
void UI::instanceTranslateYZ( const int x_delta, const int y_delta ){
	if( instance==NULL ){
		return;
	}

//	instance->translate( Vector( -x_delta, -y_delta, 0.0 ) );
	DoubleVector pos = instance->getPosition();
	pos += DoubleVector( x_delta*0.1, y_delta*0.1, 0.0 );
	instance->setPosition( pos );
}


//!  rotate instance
void UI::instanceRotate( const int x_delta, const int y_delta ){
	if( instance==NULL ){
		return;
	}
	instance->heading( x_delta*4.0f );
	instance->pitch  ( y_delta*4.0f );
}


//!  scale instance
void UI::instanceScale( const int x_delta, const int y_delta ){
	if( instance==NULL ){
		return;
	}
		
	double dist = 0.3*y_delta;
	if( dist<0 ){
		dist = 1/sqrt(1-(dist/10));
	}else{
		dist = sqrt(1+(dist/10));
	}
		
	instance->roll (  rads( x_delta*0.3)  );
	instance->pitch(  rads( y_delta*0.3)  );
}


//!  Mouse buttonpress event
void UI::selectInstance( const int x, const int y ){
	static char    sel_line[80];
	ModelInstance *pick;
	list<Mesh*>::iterator m_it;
		
	pick = camera->pickInstance( front_camera, x, y );

	if( pick!=NULL ){
#if 0
		Material	  *m;
		if( instance !=NULL ){
			m = instance->getMaterial();
			if( m != NULL ){
//				*console << "Disabling outline from old selection"; console->newLine();
				m->setMode( RENDER_MODE_FILL );
			}
			m_it = instance->getMesh()->submeshes.begin();
			while( m_it != instance->getMesh()->submeshes.end() ){
				Material *m = (*m_it)->getMaterial();
				if( m != NULL ){
//					*console << "Disabling outline from old selection"; console->newLine();
					m->setMode( RENDER_MODE_FILL );
				}
				m_it++;
			} 
		}
#endif
		instance = pick;

#if 0
		m = instance->getMaterial();
		if( m != NULL ){
//			*console << "Enabling outline for new selection"; console->newLine();
			m->setMode( RENDER_MODE_FILL_OUTLINE );
		}
		m_it = instance->getMesh()->submeshes.begin();
		while( m_it != instance->getMesh()->submeshes.end() ){
			Material *m = (*m_it)->getMaterial();																			  
			if( m != NULL ){
//				*console << "Enabling outline for new selection"; console->newLine();
				m->setMode( RENDER_MODE_FILL_OUTLINE );
			}
			m_it++;
		}
#endif

		player_ship->setTarget( instance );
	}
}


void UI::instanceFace(){
	con << ": Instance Face -- UNIMPLEMENTED" << endl;
/*	if( instance!=NULL ){
		active_camera->face( instance->getLoc() );
	}*/
}


void UI::instanceDebug(){
	con << ": Instance Debug" << endl;
	if( instance!=NULL ){
		instance->getMesh()->debug(0,NULL);
	}
}


void UI::instanceCycle(){
//	con << ": Instance Cycle" << endl;
	list<ModelInstance*> &instances 	= scene->getInstances();
	list<ModelInstance*>::iterator i_it = instances.begin();
	while( i_it != instances.end() ){
		if( (*i_it) == instance ){
			i_it++;
			if( i_it != instances.end() ){
				instance = *i_it;
			}else{
				instance = *(instances.begin());
			}
			break;					
		}
		i_it++;
	}
	player_ship->setTarget( instance );
}


void UI::scannerCycle(){
	con << ": Scanner Cycle Range" << endl;
	scanner->cycle();
}


};	//	namespace Application

