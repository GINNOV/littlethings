
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
	\file   TestManipulateEvents.cpp
	\author Timo Suoranta
	\brief  Event handling
	\date   2001

	This example program is not yet finished.
*/


#include "TestManipulate.h"
#include "SDL.h"
#include <cstdlib>


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


//!  MouseListener interface
/*virtual*/ void TestManipulate::mouseKey( const int button, const int state, const int x, const int y ){
	if( state == SDL_PRESSED ){
		control_last_button = button;
	}
}


/*virtual*/ void TestManipulate::mouseMotion( const int x, const int y, const int dx, const int dy ){
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
/*virtual*/ void TestManipulate::keyDown( const SDL_keysym key ){
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
/*virtual*/ void TestManipulate::keyUp( const SDL_keysym key ){
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
