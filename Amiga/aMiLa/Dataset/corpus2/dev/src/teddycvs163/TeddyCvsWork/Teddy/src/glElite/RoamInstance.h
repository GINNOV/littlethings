
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
	\class   RoamInstance
	\ingroup g_application
	\author  Timo Suoranta
	\date    2001
*/


#ifndef TEDDY_APPLICATION_ROAM_INSTANCE_H
#define TEDDY_APPLICATION_ROAM_INSTANCE_H


#include "glElite/CollisionInstance.h"


namespace Application {


extern float c_h;


class RoamInstance : public CollisionInstance {
public:
	RoamInstance( const char *name, Mesh *mesh );

	virtual void drawImmediate ( Projection *p );
	virtual bool collisionCheck( CollisionInstance *mi );
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_ROAM_INSTANCE_H

