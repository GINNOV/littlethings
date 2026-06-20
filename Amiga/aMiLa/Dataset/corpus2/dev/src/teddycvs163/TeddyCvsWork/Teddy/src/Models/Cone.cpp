
/*
	TEDDY - General graphics application library
	Copyright (C) 1999, 2000, 2001	Timo Suoranta
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


#include "Models/Cone.h"
#include "Models/QuadStrip.h"
#include "Models/TriangleFan.h"
#include "Models/Vertex.h"
#include "Models/Mesh.h"
#include "Models/Face.h"
#include "SysSupport/StdMaths.h"


namespace Models {


Cone::Cone( const char *name, float base_radius, float top_radius, float height, float slices, float stacks )
:Mesh(name,MS_DEFAULT|MS_RECURS_MATERIALS)
{
	Vertex *v1;
	Vector	n1;
	Vertex *v2;
	Vector	n2;

	this->setClipRadius( base_radius+height );

	float da = M_2_PI / slices;
	float dr = (top_radius - base_radius) / stacks;
	float dz = height / stacks;
	float nz = (base_radius - top_radius) / height;  /* Z component of normal vectors */

	float ds = 1 / slices;
	float dt = 1 / stacks;
	float t  = 0;
	float z  = 0;
	float r  = base_radius;
	int   i;
	int   j;

	Face  *top    = new Face();
	Face  *bottom = new Face();

	for( j=0; j<=stacks-1; j++ ){
		float      s = 0;
		QuadStrip *qs = new QuadStrip();

		for( i=0; i<=slices; i++ ){
			float x;
			float y;

			if( i==slices ){
				x = ::sin( 0 );
				y = ::cos( 0 );
			}else{
				x = ::sin( i * da );
				y = ::cos( i * da );
			}

			v1 = new Vertex( r*x,  z, r*y );
			n1 =     Vector(   x, nz,   y );
			n1.  normalize();
			v1 ->setNormal( n1 );
			qs->insert    ( v1 );

			v2 = new Vertex( (r+dr)*x, dz+z, (r+dr)*y );
			n2 =     Vector(        x,   nz,        y );
			n2.  normalize();
			v2 ->setNormal( n2 );
			qs->insert    ( v2 );

			//  Bottom
			if( (j==0) && (r!=0) ){
				Vertex *v_bot = new Vertex( v1 );
				v_bot->disableOptions( VX_USE_PARENT_NORMAL|VX_USE_THIS_VERTEX );
				bottom->insert( v_bot );
			}

			//  Top
			if( (j==stacks-1) && ((r+dr)!=0) ){
				Vertex *v_top = new Vertex( v2 );
				v_top->disableOptions( VX_USE_PARENT_NORMAL|VX_USE_THIS_VERTEX );
				top->insert( v_top );
			}

			s += ds;
		}  //  slices

		this->insert( qs );
		r += dr;
		t += dt;
		z += dz;
	}  //  stacks
	bottom->reverse();
	bottom->makeNormal();
	top   ->makeNormal();
	this->insert( bottom );
	this->insert( top );
}


};	//	namespace Models

