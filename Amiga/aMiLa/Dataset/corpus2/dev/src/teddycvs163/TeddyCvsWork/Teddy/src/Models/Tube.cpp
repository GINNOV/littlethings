
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


#include "Models/Tube.h"
#include "Models/QuadStrip.h"
#include "Models/Vertex.h"
#include "SysSupport/StdMaths.h"


namespace Models {


Tube::Tube( const char *name, const float len, const float rad, const int stacks, const int slices ):Mesh(name){
	float r;
	float x;
	float y;
	float z;
	int   i;
	int   j;
	int   k;

	this->radius = rad;
	this->stacks = stacks;
	this->slices = slices;
	this->setClipRadius( len+rad );

	for( j=0; j<stacks/2; j++ ){
		QuadStrip *qs = new QuadStrip();
		for( i=0; i<slices+1; i++ ){
			for( k=0; k<2; k++ ){
				z = radius*cos( (j+k)*M_PI/stacks );
				r =	radius*sin( (j+k)*M_PI/stacks );
				y = r*cos( i*M_2_PI/slices );
				x = r*sin( i*M_2_PI/slices );
				Vertex *v = new Vertex( x, y, z + len/2 );
				Vector normal = Vector( x, y, z );
				normal.normalize();
				v->setNormal( normal );
				qs->insert( v );
			}
		}
		this->insert( qs );
	}

	j=stacks/2;

	QuadStrip *qs = new QuadStrip();
	for( i=0; i<slices+1; i++ ){
		for( k=0; k<2; k++ ){
			z = radius*cos( (j/*+k*/)*M_PI/stacks );
			r =	radius*sin( (j/*+k*/)*M_PI/stacks );
			y = r*cos( i*M_2_PI/slices );
			x = r*sin( i*M_2_PI/slices );
			Vertex *v = new Vertex( x, y, z + len/2 - (k * len) );
			Vector normal = Vector( x, y, z );
			normal.normalize();
			v->setNormal( normal );
			qs->insert( v );
		}
	}
	this->insert( qs );

	for( j=stacks/2; j<stacks; j++ ){
		QuadStrip *qs = new QuadStrip();
		for( i=0; i<slices+1; i++ ){
			for( k=0; k<2; k++ ){
				z = radius*cos( (j+k)*M_PI/stacks );
				r =	radius*sin( (j+k)*M_PI/stacks );
				y = r*cos( i*M_2_PI/slices );
				x = r*sin( i*M_2_PI/slices );
				Vertex *v = new Vertex( x, y, z - len/2 );
				Vector normal = Vector( x, y, z );
				normal.normalize();
				v->setNormal( normal );
				qs->insert( v );
			}
		}
		this->insert( qs );
	}
}


};  //  namespace Models

