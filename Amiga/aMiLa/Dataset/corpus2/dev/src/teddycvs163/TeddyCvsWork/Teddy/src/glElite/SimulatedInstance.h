
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
	\class	 SimulatedInstance
	\ingroup g_application
	\author  Timo Suoranta
	\brief	 Simulated ModelInstance
	\date	 2001
*/


#ifndef TEDDY_APPLICATION_SIMULATED_INSTANCE_H
#define TEDDY_APPLICATION_SIMULATED_INSTANCE_H


#include "glElite/Simulated.h"
#include "Maths/Vector.h"
#include "Maths/Quaternion.h"
#include "Models/ModelInstance.h"
using namespace Models;


namespace Application {


class SimulatedInstance : public ModelInstance, public Simulated {
public:
	//	Constructors
	SimulatedInstance( const char *name, Mesh *mesh = NULL );
	virtual ~SimulatedInstance();

	//  Simulated interface
	virtual void tick();

public:
	DoubleVector tick_translation;           //!<  direction, speed
	DoubleVector tick_translation_delta;     //!<  acceleration
	Quaternion   tick_rotation;              //!<  world rotation
	Quaternion   tick_rotation_delta;        //!<  world angular acceleration
	Vector       tick_local_rotation;        //!<  local rotation
	Vector       tick_local_rotation_delta;  //!<  locla angular acceleration
};


};	//	namespace Models


#endif	//	TEDDY_APPLICATION_SIMULATED_INSTANCE_H

