
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
	\class   ShipType
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Ship type
	\todo    weapons
	\date    2001
*/


#ifndef TEDDY_APPLICATION_SHIP_TYPE_H
#define TEDDY_APPLICATION_SHIP_TYPE_H


#include "MixIn/Named.h"
#include "MixIn/Options.h"
namespace Models { class Mesh; };
using namespace Models;


namespace Application {


class ShipType {
public:
	ShipType( Mesh *mesh, float a, float ms, float pc, float rc, float mp, float mc );

	Mesh  *getMesh        ();
	float  getAcceleration();
	float  getRollConst   ();
	float  getPitchConst  ();
	float  getMaxRoll     ();
	float  getMaxPitch    ();
	float  getMaxSpeed    ();


protected:
	Mesh  *mesh;
	float  acceleration;
	float  pitch_const;
	float  roll_const;
	float  max_pitch;
	float  max_roll;
	float  max_speed;
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_SHIP_TYPE_H

