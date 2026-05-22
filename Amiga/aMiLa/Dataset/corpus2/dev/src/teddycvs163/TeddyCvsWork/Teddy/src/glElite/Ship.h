
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
	\class   Ship
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Ship
	\date    2001
*/


#ifndef TEDDY_APPLICATION_SHIP_H
#define TEDDY_APPLICATION_SHIP_H


#include "Maths/Vector.h"
#include "MixIn/Named.h"
#include "glElite/SimulatedInstance.h"
using namespace Models;


namespace Application {


class ShipType;


class Ship : public SimulatedInstance {
public:
	Ship( char *name, ShipType *ship_type );

	ShipType      *getShipType      ();
	void           setTarget        ( ModelInstance *mi, Vector offset = Vector(0,0,0) );
	ModelInstance *getTarget        ();
	void           setTargetPosition();
	float          getPitch         () const;
	float          getRoll          () const;
	float          getSpeed         () const;

	//  Simulation update
	virtual void   tick             ();

	//  ShipControls
	void           controlPitchUp   ( bool apply );
	void           controlPitchDown ( bool apply );
	void           controlRollLeft  ( bool apply );
	void           controlRollRight ( bool apply );
	void           controlMoreSpeed ( bool apply );
	void           controlLessSpeed ( bool apply );
	void           controlStop      ( bool apply );
	void           controlFireWeapon( bool apply );
			   
	void           stopSpeed        ();
	void           stopPitch        ();
	void           stopRoll         ();

	//  Low level AI
	float          getBrakeDistance () const;
	float          getTargetDistance() const;
	float          getPitchDistance (){ return pitch_distance; };
	float          getRollDistance  (){ return roll_distance;  };

	//  Medium level AI
	void           trackTarget      ();

	//  Master level
	virtual void   applyControls    ( float age );

protected:
	ShipType       *ship_type;
	ModelInstance  *target;               //!<  Ship navigation aimpoint
	Vector          target_offset;        //!<  Aimpoint offset
	float           prev_bullet_time;

	bool            control_pitch_up;     //!<  True if pitch up   key is pressed down
	bool            control_pitch_down;   //!<  True if pitch down key is pressed down
	bool            control_roll_left;    //!<  True if roll left  key is pressed down
	bool            control_roll_right;   //!<  True if roll right key is pressed down
	bool            control_more_speed;   //!<  True if player wants more speed
	bool            control_less_speed;   //!<  True if player wants less speed
	bool            control_stop;         //!<  True if player wants to stop
	bool            control_fire_weapon;  //!<  True if player wants to fire weapon
	bool            active_pitch;         //!<  True if player is controlling pitch
	bool            active_roll;          //!<  True if player is controlling roll

	float           pitch_delta;
	float           roll_delta;
	float           pitch;             //!<  Current ship pitch delta
	float           roll;              //!<  Current ship roll delta
	float           speed;             //!<  Current ship speed
	float           accel;             //!<  Current ship acceleration
	float           pitch_distance;    //!<
	float           roll_distance;     //!<
};									   


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_SHIP_H

