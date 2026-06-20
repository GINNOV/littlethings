
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


namespace Application {


void Ship::applyControls( float age ){
	float accel_const = ship_type->getAcceleration();
	float pitch_const = ship_type->getPitchConst  ();
	float roll_const  = ship_type->getRollConst   ();
	float max_pitch   = ship_type->getMaxPitch    ();
	float max_roll    = ship_type->getMaxRoll     ();
	float max_speed   = ship_type->getMaxSpeed    ();
	
	//  Damp pitch
	if( !active_pitch ){
		if( pitch > pitch_const ){
			pitch -= pitch_const*age; 
			if( pitch < pitch_const ){
				pitch = 0;
			}
		}else if( pitch < -pitch_const ){
			pitch += pitch_const*age;
			if( pitch > -pitch_const ){
				pitch = 0;
			}
		}
	}else{
		pitch += pitch_delta * age;
		if( pitch>max_pitch ){
			pitch = max_pitch;
		}else if( pitch<-max_pitch ){
			pitch = -max_pitch;
		}
	}

	//  Damp roll
	if( !active_roll ){
		if( roll > roll_const ){
			roll -= roll_const*age;
			if( roll < roll_const ){
				roll = 0;
			}
		}else if( roll < -roll_const ){
			roll += roll_const*age;
			if( roll > -roll_const ){
				roll = 0;
			}
		}
	}else{
		roll += roll_delta * age;
		if( roll>max_roll ){
			roll = max_roll;
		}else if( roll<-max_roll ){
			roll = -max_roll;
		}
	}

	//  Apply pitch and roll
	rotate( getViewAxis(),  roll  * age );
	rotate( getRightAxis(), pitch * age );
	
	//  ----- Control Speed -----
	double old_speed = speed;

	//  Faster
	if( control_more_speed ){
		if( speed < max_speed ){
			speed += accel_const * age;
			if(  (old_speed < 0) && 
				 (speed     > 0)    )
			{
				speed = 0;
			}else if( speed > max_speed ){
				speed = max_speed;
			}
		}
	}

	//  Slower
	if( control_less_speed ){
		if( speed > -max_speed ){
			speed -= accel_const * age;
			if(  (old_speed > 0) &&
			     (speed     < 0)    )
			{
				speed = 0;
			}else if( speed< -max_speed ){
				speed = -max_speed;
			}
		}
	}

	//  Stop
	if( control_stop ){
		if( speed < 0 ){
			speed += accel_const * age;
			if( speed > 0 ){
				speed = 0;
			}
		}else if( speed > 0 ){
			speed -= accel_const * age;
			if( speed < 0 ){
				speed = 0;
			}
		}
	}

	//  Fully controlled 'Elite' flight mode - go where nose points...
//	if( flight_mode == FM_ELITE ){
		tick_translation = getViewAxis() * speed;
/*}else{
		tick_translation_delta = getViewAxis() * speed;
	}*/
}


//!  Ship has activated or deactivated pitch up control
void Ship::controlPitchUp( bool apply ){
	float pitch_const = ship_type->getPitchConst();
	control_pitch_up  = apply;

	if( control_pitch_up ){
		active_pitch =  true;
		pitch_delta  =  pitch_const;
	}else if( control_pitch_down ){
		pitch_delta  = -pitch_const;
	}else{
		active_pitch =  false;
		pitch_delta  =  0;
	}
}


//!  Ship has activated or deactivated pitch down control
void Ship::controlPitchDown( bool apply ){
	float pitch_const  = ship_type->getPitchConst();
	control_pitch_down = apply;

	if( control_pitch_down ){
		active_pitch =  true;
		pitch_delta  = -pitch_const;
	}else if( control_pitch_up ){
		pitch_delta  =  pitch_const;
	}else{
		active_pitch =  false;
		pitch_delta  =  0;
	}
}


//!  Ship has activated or deactivated roll right control
void Ship::controlRollRight( bool apply ){
	float roll_const  = ship_type->getRollConst();
	control_roll_left = apply;

	if( control_roll_left ){
		active_roll =  true;
		roll_delta  =  roll_const;
	}else if( control_roll_right ){
		roll_delta  = -roll_const;
	}else{
		active_roll =  false;
		roll_delta  =  0;
	}
}


//!  Ship has activated or deactivated roll left control
void Ship::controlRollLeft( bool apply ){
	float roll_const   = ship_type->getRollConst();
	control_roll_right = apply;

	if( control_roll_right ){
		active_roll =  true;
		roll_delta  = -roll_const;
	}else if( control_roll_left ){
		roll_delta  =  roll_const;
	}else{
		active_roll =  false;
		roll_delta  =  0;
	}
}


//!  Ship wants more speed
void Ship::controlMoreSpeed( bool apply ){
	control_more_speed = apply;
}


//!  Ship wants less speed
void Ship::controlLessSpeed( bool apply ){
	control_less_speed = apply;
}


//!  Ship wants to stop
void Ship::controlStop( bool apply ){
	control_stop = apply;
}

//!  Ship wants to fire its weapon
void Ship::controlFireWeapon( bool apply ){
	control_fire_weapon = apply;
	if( apply == false ){
		controlMoreSpeed( false ); controlLessSpeed( false );
		controlRollRight( false ); controlRollLeft ( false );
		controlPitchUp  ( false ); controlPitchDown( false );
	}
}



};  //  namespace Application

