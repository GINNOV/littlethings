
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


#include "glElite/Ship.h"
#include "glElite/ShipType.h"
#include "glElite/SimulatedInstance.h"
using namespace Models;


namespace Application {


Ship::Ship( char *name, ShipType *ship_type)
:
	SimulatedInstance( name, ship_type->getMesh() 
){
	this->ship_type = ship_type;

	target              = NULL;
	target_offset       = Vector(0,0,0);
	pitch               = 0;
	roll                = 0;
	speed               = 0;
	accel               = 0;
	control_pitch_up    = false;
	control_pitch_down  = false;
	control_roll_left   = false;
	control_roll_right  = false;
	control_more_speed  = false;
	control_less_speed  = false;
	control_stop        = false;
	control_fire_weapon = false;
	active_pitch        = false;
	active_roll         = false;
	pitch_delta         = 0;
	roll_delta          = 0;
}

//!  Simulate one tick
/*virtual*/ void Ship::tick(){
	applyControls( 10.0f );
	SimulatedInstance::tick();
}

//  -----  SIMPLE CONTROLS -----


void Ship::stopSpeed(){
	if( speed > 0 ){
		controlMoreSpeed( false );
		controlLessSpeed( true  );
	}else if( speed < 0 ){
		controlMoreSpeed( true  );
		controlLessSpeed( false );
	}
}


void Ship::stopPitch(){
	if( pitch > 0 ){
		controlPitchDown( true  );
		controlPitchUp  ( false );
	}else if( pitch < 0 ){
		controlPitchDown( false );
		controlPitchUp  ( true  );
	}
}


void Ship::stopRoll(){
	if( roll > 0 ){
		controlRollLeft ( true  );
		controlRollRight( false );
	}else if( roll < 0 ){
		controlRollLeft ( false );
		controlRollRight( true  );
	}
}


//  -----  USED BY DEBUG HUD  -----


float Ship::getTargetDistance() const {
	if( target != NULL ){
		Vector tpos   = target->getPosition();
		Vector cpos   = this->getPosition();
		Vector delta  = tpos - cpos;

		float target_distance = delta.magnitude();
		target_distance -= target->getClipRadius() * 2;
//		target_distance -= this->getClipRadius() * 2;
		return target_distance;
	}else{
		return 0;
	}
}

float Ship::getBrakeDistance() const {
	return (speed * speed) / (2 * ship_type->getAcceleration() * 10);
}


//  ----- TRACKING CODE -----


/*!
	Tactics:

	If V: > 0.5  ->  forward
	If V: < 0.5  ->  backward

	If U: < 0    ->  pitch up      ; do only if 
	If U: > 0    ->  pitch down    ; fabs(U) > fabs(R)

	If R: > 0    ->	 roll right
	If R: < 0    ->  roll left
*/
void Ship::trackTarget(){
	if( target == NULL ){
		return;
	}
	
	Vector tpos   =	target->getPosition();
	Vector cpos   = this->getPosition();
	Vector tview  = target->getViewAxis ();
	Vector tup    = target->getUpAxis   ();
	Vector tright = target->getRightAxis();
	Vector cview  = getViewAxis ();
	Vector cup    = getUpAxis   ();
	Vector cright = getRightAxis();
	Vector offset = tright * target_offset.v[0] +
	                tup    * target_offset.v[1] +
	                tview  * target_offset.v[2];
	Vector delta  = tpos + offset - cpos;
	float  target_speed;

	SimulatedInstance *sim_target = dynamic_cast<SimulatedInstance*>( target );
	if( sim_target != NULL ){
		target_speed = (float)(sim_target->tick_translation.magnitude());
	}else{
		target_speed = 0;
	}

	float  target_distance  = getTargetDistance();
	float  brake_distance   = (speed * speed) / (20 * ship_type->getAcceleration() );
	float  b_pitch_distance = 10 * (pitch * pitch) / (2 * ship_type->getPitchConst  () );
	float  b_roll_distance  = 10 * (roll  * roll ) / (2 * ship_type->getRollConst   () );

	delta .normalize();
	float  v = cview  | delta;
	float  u = cup    | delta;
	float  r = cright | delta;
	float  v_epsilon = 0.01f;  // error tolerance
	float  u_epsilon = 0.01f;  // error tolerance
	float  r_epsilon = 0.02f;  // error tolerance
	pitch_distance   = (float)acos( u );
	roll_distance    = (float)acos( r );

	//  Arrived to target?
	if( target_distance < 1 ){
		stopSpeed();
		stopPitch();
		stopRoll ();
		return;
	}

	bool speed_control = false;
	if(
		(  brake_distance  <  target_distance  )
		
		&&

		(

		  (
		   (target_distance <  100                ) &&
		   (fabs(speed)     <  fabs(target_speed) )    
		  )
		 
		  ||

          (
		   target_distance >= 100
		  )
		)
	){
		speed_control = true;
	}

	//  Target in front
	if( v > 0.5 ){

		//  Go faster?
		if( speed_control == true ){
			controlMoreSpeed( true ); 
			controlLessSpeed( false );
		}else{
			stopSpeed();
		}
	}

	//  Target behind
	if( v < 0.5 ){

		//  Go backwards
		if( speed_control == true ){
			controlMoreSpeed( false ); 
			controlLessSpeed( true );
		}else{
			stopSpeed();
		}
	}

	// Looking pretty straight at target?
	if( fabs(0.5-v) < v_epsilon ){
		stopPitch();
		stopRoll();
		return;
	}

	//  Target above
	if( u >= 0 ){ 

		//  Pitch up
		if( (b_pitch_distance < pitch_distance) && 
			(fabs(u)          > fabs(r)       ) &&
			(u > u_epsilon                    )    )
		{
			controlPitchUp  ( true  );
			controlPitchDown( false );
		}else{
			stopPitch();
		}

		//  Target on right (above)
		if( r > r_epsilon ){
			//  Roll right
			if( b_roll_distance < roll_distance ){
				controlRollRight( true  ); 
				controlRollLeft ( false );
			}else{
				stopRoll();
			}
		}

		//  Target on left (above)
		if( r < -r_epsilon ){
			//  Roll left
			if( b_roll_distance < roll_distance ){
				controlRollRight( false );
				controlRollLeft ( true  ); 
			}else{
				stopRoll();
			}
		}
	}

	//  Target below
	if( u < 0 ){ 

		//  Pitch down
		if( (b_pitch_distance < pitch_distance) && 
			(fabs(u)          > fabs(r)       ) &&
			(u                < -u_epsilon    )    )
		{
			controlPitchUp  ( false );
			controlPitchDown( true  );
		}else{
			stopPitch();
		}

		//  Target on right (below)
		if( r > r_epsilon ){
			//  Roll left
			if( b_roll_distance < roll_distance ){
				controlRollRight( false );
				controlRollLeft ( true  ); 
			}else{
				stopRoll();
			}
		}

		//  Target on left (below)
		if( r < -r_epsilon ){
			//  Roll right
			if( b_roll_distance < roll_distance ){
				controlRollRight( true  ); 
				controlRollLeft ( false );
			}else{
				stopRoll();
			}
		}
	}
}


//  ----- ACCESSORS -----


ShipType *Ship::getShipType(){
	return this->ship_type;
}

void Ship::setTarget( ModelInstance *mi, Vector offset ){
	this->target        = mi;
	this->target_offset = offset;
}


//!  Teleport instantly to target postion. Used to initialize wingmen position
void Ship::setTargetPosition(){
	Vector tpos   =	target->getPosition();
//	Vector cpos   = this->getPosition();
	Vector tview  = target->getViewAxis ();
	Vector tup    = target->getUpAxis   ();
	Vector tright = target->getRightAxis();
//	Vector cview  = getViewAxis ();
//	Vector cup    = getUpAxis   ();
//	Vector cright = getRightAxis();
	Vector offset = tright * target_offset.v[0] +
	                tup    * target_offset.v[1] +
	                tview  * target_offset.v[2];
//	Vector delta  = tpos + offset - cpos;
	setPosition( tpos + offset );
}

ModelInstance *Ship::getTarget(){
	return target;
}

float Ship::getPitch() const {
	return pitch;
}

float Ship::getRoll() const {
	return roll;
}

float Ship::getSpeed() const {
	return speed;
}


};  //  namespace

