
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
	\file   State.cpp
	\author Timo Suoranta
	\brief  LSystem state
	\date   2001
*/


#include "State.h"
#include "Maths/Matrix.h"
#include "Maths/Quaternion.h"
using namespace Maths;


State::State(){
	length    = 100.0f;
	angle     =  90.0f;
	thickness =   1;
	position  = Vector(0,0,0);
	direction = Vector(0,1,0);
	quat.setAxisAngle( Vector(1,0,0), (float)rads(90.0f) );
}


void State::heading( double degrees ){
	//  Rotate around Y axis
	quat.rotate( quat.getUpAxis(), (float)rads(degrees) );

	direction = quat.getViewAxis();
	quat.normalize();
}

void State::roll( double degrees ){
	quat.rotate( quat.getViewAxis(), (float)rads(degrees) );

	direction = quat.getViewAxis();
	quat.normalize();
}

void State::pitch( double degrees ){
	quat.rotate( quat.getRightAxis(), (float)rads(degrees) );

	direction = quat.getViewAxis();
	quat.normalize();
}

