
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
	\file   Timer.h
	\author Timo Suoranta
	\brief  Simulation update timer
	\date   2001
*/


#ifndef TEDDY_TEST_MANIPULATE_TIMER_H
#define TEDDY_TEST_MANIPULATE_TIMER_H


#include "SDL.h"


/*!
	This is the timer update function.
	It is a standard SDL callback function.
*/
extern Uint32 test_timer_callback( Uint32 interval, void *param );


#endif  //  TEDDY_TEST_MANIPULATE_TIMER_H

