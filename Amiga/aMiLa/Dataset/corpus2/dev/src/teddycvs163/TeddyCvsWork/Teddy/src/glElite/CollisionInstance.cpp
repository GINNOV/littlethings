
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


#include "glElite/CollisionGroup.h"
#include "glElite/CollisionInstance.h"
#include "glElite/Simulated.h"


namespace Application {


//!  Constructor
CollisionInstance::CollisionInstance( const char *name, Mesh *mesh )
:
SimulatedInstance(name,mesh),
collision_group  (NULL)
{
}


//!  Destructor
/*virtual*/ CollisionInstance::~CollisionInstance(){
}


//!  Simulate one tick
/*virtual*/ void CollisionInstance::tick(){
	lock();
	translate( tick_translation );
	if( collision_group != NULL ){
		collision_group->doCollisions( this );
	}
	rotate	 ( tick_rotation );
	heading  ( tick_local_rotation.v[0] );
	pitch	 ( tick_local_rotation.v[1] );
	roll	 ( tick_local_rotation.v[2] );
	tick_rotation.rotate( tick_rotation_delta );
	tick_translation	+= tick_translation_delta;
	tick_local_rotation += tick_local_rotation_delta;
	unlock();
}

//!  Set CollisionGroup
void CollisionInstance::setCollisionGroup( CollisionGroup *cg ){
	this->collision_group = cg;
}


//!  Generic collision check algorithm
/*virtual*/ bool CollisionInstance::collisionCheck( CollisionInstance *other ){
	float distance = this->distanceTo( *other );
	if( distance < this->getClipRadius() + other->getClipRadius() ){
		this->applyCollision( other );
		other->applyCollision( this );
		return true;
	}
	return false;
}


//!  Generic collision apply routine
/*virtual*/ void CollisionInstance::applyCollision( CollisionInstance *ci ){
	tick_translation *= -1;
	translate( tick_translation );
	tick_translation = DoubleVector( 0, 0, 0 );
//	ui->playExplode();
}


};  //  namespace Application

