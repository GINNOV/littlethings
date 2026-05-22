
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


#include "Models/TriangleFan.h"
#include "Models/Vertex.h"
#include "PhysicalComponents/Projection.h"


namespace Models {


//!  Constructor
TriangleFan::TriangleFan(){
	//  FIX
}


//!  Destructor
/*virtual*/ TriangleFan::~TriangleFan(){
	//  FIX
}


//!  Insert vertex to QuadStrip
void TriangleFan::insert( Vertex *v ){
	vertices.push_back( v );
}


//!  Draw QuadStrip
void TriangleFan::draw( Projection *p ){
	p->beginTriangleFan();
	list<Vertex*>::const_iterator v_it = vertices.begin();
	while( v_it != vertices.end() ){
		(*v_it)->draw( p );
		v_it++;
	}
	p->end();
}


};  //  namespace Models

