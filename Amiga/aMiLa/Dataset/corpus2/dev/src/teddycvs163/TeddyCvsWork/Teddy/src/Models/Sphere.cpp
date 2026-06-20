
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


#include "Models/Sphere.h"
#include "Models/QuadStrip.h"
#include "Models/Vertex.h"
#include "SysSupport/StdMaths.h"


namespace Models {


Sphere::Sphere( const char *name, const float rad, const int stacks, const int slices ):Mesh(name){
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
	this->setClipRadius( rad );

	for( j=0; j<stacks; j++ ){
		QuadStrip *qs = new QuadStrip();
		for( i=0; i<slices+1; i++ ){
			for( k=0; k<2; k++ ){
				y = radius*cos( (j+k)*M_PI/stacks );
				r =	radius*sin( (j+k)*M_PI/stacks );
				x = r*cos( i*M_2_PI/slices );
				z = r*sin( i*M_2_PI/slices );
				Vector normal = Vector( x, y, z );
				normal.normalize();
				//normal.neg();
				float s = 1.0f - (float) (i) / (float) (stacks);
				float t = (float) ((j+k) ) / (float) slices;
/*				if( s>1.0f )
					s = 1.0f;
				if( t>1.0f )
					t = 1.0f;
				if( s<0.0f )
					s = 0.0f;
				if( t<0.0f )
					t = 0.0f;*/
				Vector texcoord = Vector(
					s,
					t,
					0
				);
				Vertex *v = new Vertex( x, y, z );
				v->setNormal ( normal );
				v->setTexture( texcoord );
				qs->insert( v );
			}
		}
		this->insert( qs );
	}

}


};  //  namespace Models

