
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
	\file   State.h
	\author Timo Suoranta
	\brief  LSystem state
	\date   2001
*/


#ifndef TEDDY_TEST_MANIPULATE_STATE_H
#define TEDDY_TEST_MANIPULATE_STATE_H


#include "Maths/Vector.h"
#include "Maths/Quaternion.h"
using namespace Maths;


//!  LSystem state
class State {
public:
	State();

	void heading( double degrees );
	void pitch  ( double degrees );
	void roll   ( double degrees );

public:
	double      length;
	double      angle;
	double      thickness;
	Vector     position;
	Vector     direction;
	Quaternion quat;
};


#endif  //  TEDDY_TEST_MANIPULATE_STATE_H

