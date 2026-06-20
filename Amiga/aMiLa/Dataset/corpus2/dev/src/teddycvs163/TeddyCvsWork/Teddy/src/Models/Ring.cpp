
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


#include "Maths/Vector.h"
#include "Models/Ring.h"
#include "Models/QuadStrip.h"
#include "Models/Vertex.h"
#include "SysSupport/StdMaths.h"


namespace Models {


Ring::Ring( const char *name, const float inner_radius, const float outer_radius, const int slices ):Mesh(name){
	QuadStrip *qs = new QuadStrip();
	for( int i=0; i<=slices; i++ ){
		float theta = i*M_2_PI/slices;
		float slice = 1.0f - (float)(i)/(float)(slices);
		Vertex *v1 = new Vertex( inner_radius * cos(theta), 0, inner_radius * sin(theta) );
		v1->setNormal ( Vector( 0, 1, 0 ) );
		v1->setTexture( Vector( slice, 0.0f, 0 ) );
		Vertex *v2 = new Vertex( outer_radius * cos(theta), 0, outer_radius * sin(theta) );
		v1->setNormal ( Vector( 0, 1, 0 ) );
		v1->setTexture( Vector( slice, 1.0f, 0 ) );
		qs->insert( v1 );
		qs->insert( v2 );
	}
	this->insert( qs );
	setClipRadius( outer_radius );
}


};  //  namespace Models

