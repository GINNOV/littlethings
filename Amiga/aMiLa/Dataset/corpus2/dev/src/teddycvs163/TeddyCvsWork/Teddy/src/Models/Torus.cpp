
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
#include "Models/QuadStrip.h"
#include "Models/Torus.h"
#include "Models/Vertex.h"
#include "SysSupport/StdMaths.h"


namespace Models {


Torus::Torus( const char *name, const float rt, const float rc, const int numt, const int numc ):Mesh(name){
	int   i;
	int   j;
	int   k;
	float s;
	float t;
	float x;
	float y;
	float z;

	setClipRadius( rt+rc );

	for( i=0; i<numc; i++ ){
		QuadStrip *qs = new QuadStrip();
		for( j=0; j<=numt; j++ ){
			for( k=1; k>=0; k-- ){
				s = (i + k) % numc + 0.5;
				t = j % numt;

				x = (rt + rc * cos(s*M_2_PI/numc)) * cos(t*M_2_PI/numt);
				z = (rt + rc * cos(s*M_2_PI/numc)) * sin(t*M_2_PI/numt);
				y = rc * sin(s*M_2_PI/numc);
				Vertex *v = new Vertex( x, y, z );

				x = cos(t*M_2_PI/numt) * cos(s*M_2_PI/numc);
				z = sin(t*M_2_PI/numt) * cos(s*M_2_PI/numc);
				y = sin(s*M_2_PI/numc);
				v->setNormal( Vector( x, y, z ) );
				qs->insert( v );
			}
		}
		this->insert( qs );
	}
}


};  //  namespace Models

