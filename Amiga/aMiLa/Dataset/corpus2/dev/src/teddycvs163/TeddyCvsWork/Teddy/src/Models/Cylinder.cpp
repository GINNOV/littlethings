
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


#include "Models/Cylinder.h"
#include "Models/QuadStrip.h"
#include "Models/Vertex.h"
#include "Models/Mesh.h"
#include "Models/Face.h"
#include "SysSupport/StdMaths.h"


namespace Models {


Cylinder::Cylinder( const char *name, const float rad, const float height, const int quads )
:Mesh(name,MS_DEFAULT|MS_RECURS_MATERIALS)
{
	float x;
	float z;
	int   i;

	this->radius = rad;
	this->quads  = quads;
	this->setClipRadius( rad+height );

	QuadStrip *pipe   = new QuadStrip();
	Face  *top    = new Face();
	Face  *bottom = new Face();

	Vector neg_y = Vector(0,1,0);
	neg_y *= -1;

	for( i=0; i<quads+1; i++ ){
		Vertex *v1;
		Vertex *v2;
		Vertex *v3;
		Vertex *v4;

		x   = rad*cos( i*M_2_PI/quads );
		z   = rad*sin( i*M_2_PI/quads );
		v1 = new Vertex( x, height, z );
		v2 = new Vertex( x, 0, z );
		v3 = new Vertex( x, height, z );
		v4 = new Vertex( x, 0, z );
		Vector normal = Vector( x, 0, z );
		normal.normalize();
		v1    ->setNormal( normal );
		v2    ->setNormal( normal );
		v3    ->setNormal( Vector(0,1,0) );
		v4    ->setNormal( neg_y );
		pipe  ->insert( v1 );
		pipe  ->insert( v2 );
		top   ->insert( v3 );
		bottom->insert( v4 );
	}
	top->reverse();
	bottom->makeNormal();
	top->makeNormal();
	this->insert( pipe );
	Mesh *ends = new Mesh( "tops" );
	ends->insert( top );
	ends->insert( bottom );
	this->insert( ends );
}


};  //  namespace Models

