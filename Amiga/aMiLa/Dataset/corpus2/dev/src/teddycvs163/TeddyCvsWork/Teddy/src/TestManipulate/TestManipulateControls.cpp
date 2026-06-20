
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
	\file   TestManipulateControls.cpp
	\author Timo Suoranta
	\brief  Navigation controls
	\date   2001

	This example program is not yet finished.
*/


#include "TestManipulate.h"
#include "Scenes/Camera.h"
using namespace Scenes;


//!  Apply controls
void TestManipulate::applyControls(){
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
