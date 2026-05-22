
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


#include "glElite/FrontCamera.h"
#include "glElite/PlayerShip.h"
#include "glElite/RoamSphere.h"
#include "glElite/ui.h"
#include "glElite/ShipCamera.h"
#include "PhysicalComponents/WindowManager.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "PhysicalComponents/WindowFrame.h"
#include "PhysicalComponents/Label.h"
#include "Graphics/View.h"
#include "SDL_mouse.h"
using namespace Graphics;


namespace Application {


bool FrontCamera::keys[SDLK_LAST+1];


//!  Constructor
FrontCamera::FrontCamera( const char *name, Camera *camera, UI *ui, LayoutConstraint *lc, bool frame )
:
Projection   (name,camera),
EventListener(EVENT_KEY_DOWN_M|EVENT_KEY_UP_M|EVENT_MOUSE_KEY_M|EVENT_MOUSE_HOLD_DRAG_M)
{
	int i;

	this->constraint  = lc;
	this->ui          = ui;
	this->player_ship = ui->getPlayerShip();

	for( i=0; i<SDLK_LAST+1; i++ ){
		this->keys[i] = false;
	}

	if( frame ){
		window_frame = new WindowFrame( name );
		this->insert( window_frame );
	}else{
		window_frame = NULL;
	}

	title = new Label( "" );
	LayoutConstraint *cons = title->getLayoutConstraint();
	cons->local_x_offset_relative  = -0.5;
	cons->local_y_offset_relative  = -0.5;
	cons->parent_x_offset_relative =  0.5;
	cons->parent_y_offset_relative =  0;
	cons->local_y_offset_pixels    = 10;
	this->insert( title );

	for( i=0; i<4; i++ ){
		this->mouse_click_x[i] = 0;
		this->mouse_click_y[i] = 0;
		this->mouse_drag_x [i] = 0;
		this->mouse_drag_y [i] = 0;
	}
}


/*virtual*/ void FrontCamera::drawSelf(){
	title->setText( camera->getTitle() );
	title->place();
	Projection::drawSelf();
}



//!  Return event target
/*virtual*/ Area *FrontCamera::getTarget( const Event e ) const {
	return window_frame;
}


//!  Destructor
FrontCamera::~FrontCamera(){
	//  FIX
}


//!  Received or lost focus
/*virtual*/ void FrontCamera::focusActive( const bool active ){
	if( active ){
		ui->setActiveCamera( this->camera );
		if( window_frame!=NULL ){
			window_frame->setColor( Color::CYAN );
		}
	}else{
		if( window_frame!=NULL ){
			window_frame->setColor( style->frame_color );
		}
	}
}


//!  MouseListener interface
/*virtual*/ void FrontCamera::mouseKey( const int button, const int state, const int x, const int y ){
	if( state == SDL_PRESSED ){
		mouse_click_x[button] = x;
		mouse_click_y[button] = y;
		mouse_drag_x [button] = x;
		mouse_drag_y [button] = y;
	}else{
		if( (button == SDL_BUTTON_LEFT       ) &&
		    (state  == SDL_RELEASED          ) &&
		    (x      == mouse_click_x[button] ) &&
			(y      == mouse_click_y[button] )    )
		{
			ui->selectInstance( x, y );
		}
	}
	mouse_b[button] = state;
}


/*virtual*/ void FrontCamera::mouseMotion( const int x, const int y, const int dx, const int dy ){
	for( int b = 1; b < 4; b++ ){
		if( mouse_b[b] == SDL_PRESSED ){
			ui->mouseMotion( b, dx, dy );
		}
	}
}


//!  KeyListener interface implementation
/*virtual*/ void FrontCamera::keyDown( const SDL_keysym key ){
	keys[ key.sym ] = true;

	switch( key.sym ){
	case 'd': ui->blendOn();                break;
	case 'c': ui->blendOff();               break;
	case 'h': ui->displayHelp();            break;
	case 'e': ui->displayExtensions();      break;
//	case 'a': ui->instanceFace();           break;
	case 'w': ui->instanceDebug();          break;
	case 'u': ui->renderModePoint();        break;
	case 'i': ui->renderModeLine();         break;
	case 'o': ui->renderModeFill();         break;
	case 'p': ui->renderModeFillOutline();  break;
	case 'v': ui->cullFaceDisable();        break;
	case 'b': ui->cullFaceEnable();         break;
	case 'f': ui->depthTestDisable();       break;
	case 'g': ui->depthTestEnable();        break;
	case 'k': ui->lightingOff();            break;
	case 'l': ui->lightingOn();             break;
	case 'n': ui->fovNormal();              break;
	case 'm': ui->fovWide();                break;
	case 'r': ui->antialiseOff();           break;
	case 't': ui->antialiseOn();            break;
	case '1': ui->toggleCamera();           break;
	case '3': ui->chooseMouseMode();        break;
	case '4': ui->instanceCycle();          break;
	case '5': ui->scannerCycle();           break;

#if 0
	case '6': roam_update  = false;         break;
	case '7': roam_update  = true;          break;
	case '8': roam_const  *= 0.9f;          break;
	case '9': roam_const  *= 1.1f;          break;
#endif

	case 'q': ui->quit();                   break;

	case 'a': player_ship->controlFireWeapon( true ); break;
	case 'x': player_ship->controlPitchUp   ( true ); break;
	case 's': player_ship->controlPitchDown ( true ); break;
	case ',': player_ship->controlRollLeft  ( true ); break;
	case '.': player_ship->controlRollRight ( true ); break;

	case SDLK_F1:     ui->getShipCamera()->front (); break;
	case SDLK_F2:     ui->getShipCamera()->left  (); break;
	case SDLK_F3:     ui->getShipCamera()->right (); break;
	case SDLK_F4:     ui->getShipCamera()->rear  (); break;
	case SDLK_F5:     ui->getShipCamera()->top   (); break;
	case SDLK_F6:     ui->getShipCamera()->bottom(); break;
	case SDLK_SPACE:  player_ship->controlMoreSpeed ( true ); break;
	case SDLK_TAB:    player_ship->controlLessSpeed ( true ); break;
	case SDLK_ESCAPE: player_ship->controlStop      ( true ); break;

	case SDLK_KP0:
	case SDLK_KP1: {
		float roll = ui->getShipCamera()->getRoll();
		roll += (float)rads( 10 );
		ui->getShipCamera()->setRoll( roll );
	} break;

	case SDLK_KP2: {
		float pitch = ui->getShipCamera()->getPitch();
		pitch -= (float)rads( 10 );
		ui->getShipCamera()->setPitch( pitch );
	} break;

	case SDLK_KP3: {
		float roll = ui->getShipCamera()->getRoll();
		roll -= (float)rads( 10 );
		ui->getShipCamera()->setRoll( roll );
	} break;

	case SDLK_KP4: {
		float head = ui->getShipCamera()->getHeading();
		head += (float)rads( 10 );
		ui->getShipCamera()->setHeading( head );
	} break;
	case SDLK_KP5: {
		ui->getShipCamera()->setDistance( 0 );
	} break;

	case SDLK_KP6: {
		float head = ui->getShipCamera()->getHeading();
		head -= (float)rads( 10 );
		ui->getShipCamera()->setHeading( head );
	} break;
	case SDLK_KP7: {
		float roll = ui->getShipCamera()->getRoll();
		roll += (float)rads( 10 );
		ui->getShipCamera()->setRoll( roll );
	} break;

	case SDLK_KP8: {
		float pitch = ui->getShipCamera()->getPitch();
		pitch += (float)rads( 10 );
		ui->getShipCamera()->setPitch( pitch );
	} break;
	case SDLK_KP9: {
		float roll = ui->getShipCamera()->getRoll();
		roll -= (float)rads( 10 );
		ui->getShipCamera()->setRoll( roll );
	} break;

	case SDLK_KP_PERIOD	 :
	case SDLK_KP_DIVIDE	 :
	case SDLK_KP_MULTIPLY:  break;
	case SDLK_KP_MINUS	: {
		float distance = ui->getShipCamera()->getDistance();
		if( distance < ui->getShipCamera()->getShip()->getClipRadius() ){
			distance = ui->getShipCamera()->getShip()->getClipRadius();
		}
		distance += 4;
		distance *= (float)1.2;
		ui->getShipCamera()->setDistance( distance );
	} break;

	case SDLK_KP_PLUS	: {
		float distance = ui->getShipCamera()->getDistance();
		distance /= (float)1.2;
		distance -= 4;
		if( distance < ui->getShipCamera()->getShip()->getClipRadius() ){
			distance = 0;
		}
		ui->getShipCamera()->setDistance( distance );
	} break;

	case SDLK_KP_ENTER	:
	case SDLK_KP_EQUALS	: break;

	default: break;
	}
};


/*virtual*/ void FrontCamera::keyUp( const SDL_keysym key ){
	keys[ key.sym ] = false;

	switch( key.sym ){
	case 'a':         player_ship->controlFireWeapon( false ); break;
	case 'x':         player_ship->controlPitchUp   ( false ); break;
	case 's':         player_ship->controlPitchDown ( false ); break;
	case ',':         player_ship->controlRollLeft  ( false ); break;
	case '.':         player_ship->controlRollRight ( false ); break;
	case SDLK_SPACE:  player_ship->controlMoreSpeed ( false ); break;
	case SDLK_TAB:    player_ship->controlLessSpeed ( false ); break;
	case SDLK_ESCAPE: player_ship->controlStop      ( false ); break;
	default: break;
	}

};


};  //  namespace Application

