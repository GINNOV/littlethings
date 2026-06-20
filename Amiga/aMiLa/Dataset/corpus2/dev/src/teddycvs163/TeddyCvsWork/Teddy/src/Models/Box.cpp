
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


#include "Models/Box.h"
#include "Models/Face.h"


namespace Models {


Box::Box( const char *name, const float x_size, const float y_size, const float z_size ):Mesh(name){
	float x = x_size/2;
	float y = y_size/2;
	float z = z_size/2;

	Face *top    = new Face();
	Face *bottom = new Face();
	Face *front  = new Face();
	Face *back   = new Face();
	Face *left   = new Face();
	Face *right  = new Face();

	top->insert( -x,  -y, -z );
	top->insert(  x,  -y, -z );
	top->insert(  x,  -y,  z );
	top->insert( -x,  -y,  z );
	top->makeNormal();
	this->insert( top );

	bottom->insert( -x,  y,  z );
	bottom->insert(  x,  y,  z );
	bottom->insert(  x,  y, -z );
	bottom->insert( -x,  y, -z );
	bottom->makeNormal();
	this->insert( bottom );

	front->insert(  x,  y,  z );
	front->insert( -x,  y,  z );
	front->insert( -x, -y,  z );
	front->insert(  x, -y,  z );
	front->makeNormal();
	this->insert( front );

	back->insert( -x,  y,  -z );
	back->insert(  x,  y,  -z );
	back->insert(  x, -y,  -z );
	back->insert( -x, -y,  -z );
	back->makeNormal();
	this->insert( back );

	right->insert( -x,  y,  z );
	right->insert( -x,  y, -z );
	right->insert( -x, -y, -z );
	right->insert( -x, -y,  z );
	right->makeNormal();
	this->insert( right );

	left->insert(  x,  y, -z );
	left->insert(  x,  y,  z );
	left->insert(  x, -y,  z );
	left->insert(  x, -y, -z );
	left->makeNormal();
	this->insert( left );

	this->setClipRadius( (x_size*x_size)+(y_size*y_size)+(z_size*z_size) );
}


};  //  namespace Models

