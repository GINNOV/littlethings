
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


#include "Models/Grid.h"
#include "Models/Vertex.h"
#include "Models/Line.h"


namespace Models {


/*!
	Constructor which makes xSize times xCount wide and
	zCount times zSize 'deep' grid on XZ-plane.
*/
Grid::Grid( const int xCount, const int zCount, const float xSize, const float zSize ):LineMesh("Grid"){
	Vertex *v1;
	Vertex *v2;
	Line   *l;

	//  Boundaries
	fore   =  zCount/2*zSize;
	back   = -zCount/2*zSize;
	right  =  xCount/2*xSize;
	left   = -xCount/2*xSize;

	float r1 = xCount/2*xSize;
	float r2 = zCount/2*zSize;
	float r = sqrt(r1*r1 + r2*r2);
	this->setClipRadius( r );

	//  Horizontal lines
	for( int x=-xCount/2; x<=xCount/2; x++ ){
		v1 = new Vertex( x*xSize, 0, fore   );
		v2 = new Vertex( x*xSize, 0, back   );
		l  = new Line( v1, v2 );
		insert( l );
	}

	//  Vertical lines
	for( int z=-zCount/2; z<=zCount/2; z++ ){
		v1 = new Vertex( left,  0, z*zSize );
		v2 = new Vertex( right, 0, z*zSize );
		l  = new Line( v1, v2 );
		insert( l );
	}
}


};  //  namespace Models

