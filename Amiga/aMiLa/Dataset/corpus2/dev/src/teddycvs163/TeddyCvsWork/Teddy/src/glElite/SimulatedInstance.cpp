
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


#include "glElite/SimulatedInstance.h"


namespace Application {


//!  Constructor
SimulatedInstance::SimulatedInstance( const char *name, Mesh *mesh)
:
ModelInstance            (name,mesh),
tick_translation         (0,0,0),
tick_translation_delta   (0,0,0),
tick_rotation            (0,0,0,1),
tick_rotation_delta      (0,0,0,1),
tick_local_rotation      (0,0,0),
tick_local_rotation_delta(0,0,0)
{
}


//!  Destructor
/*virtual*/ SimulatedInstance::~SimulatedInstance(){
}

//!  Simulate one tick
/*virtual*/ void SimulatedInstance::tick(){
	lock();
	translate( tick_translation );
	rotate	 ( tick_rotation );
	heading  ( tick_local_rotation.v[0] );
	pitch	 ( tick_local_rotation.v[1] );
	roll	 ( tick_local_rotation.v[2] );
	tick_rotation.rotate( tick_rotation_delta );
	tick_translation	+= tick_translation_delta;
	tick_local_rotation += tick_local_rotation_delta;
	unlock();
}


};  //  namespace Application

