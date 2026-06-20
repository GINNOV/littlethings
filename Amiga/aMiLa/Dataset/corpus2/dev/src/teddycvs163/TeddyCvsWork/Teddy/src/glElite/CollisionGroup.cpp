
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


namespace Application {


CollisionGroup::CollisionGroup( const char *name ):Named(name){
}


void CollisionGroup::insert( CollisionInstance *mi ){
	instances.push_back( mi );
}


void CollisionGroup::doCollisions( CollisionInstance *mi ){
	list<CollisionInstance*>::iterator ci_it = instances.begin();
	while( ci_it != instances.end() ){
		(*ci_it)->collisionCheck( mi );
		ci_it++;
	}

}


};  //  namespace Application

