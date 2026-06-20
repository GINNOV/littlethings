
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


#include "Maths/Plane.h"
#include <cstdio>


namespace Maths {


/*!	
	   Ax + Bx + Cx + D = 0
	
	-( Ax + Bx + Cx ) = D
*/

/*
Plane::Plane( const Vector &p1, const Vector &p2, const Vector &p3 ){
	*this = (p1-p2) * (p1-p3);
	this->Norm();
	d = -( r*p1.r + s*p1.s + t*p1.t );
} */


/*!
	Distance - returns positive or negative or (near) zero
	if point is on side or another or in this plane.
*/
float Plane::distance( const Vector &p ) const {
	return( v[0]*p.v[0] + v[1]*p.v[1] + v[2]*p.v[2] + v[3] );
}


//!  Negate plane, that is, flip
void Plane::neg(){
	v[0] = -v[0];
	v[1] = -v[1];
	v[2] = -v[2];
	v[3] = -v[3];
}



Vector Plane::getNormal() const {
	return Vector( v[0], v[1], v[2] );
}

float Plane::getConstant() const {
	return v[3];
}

//!  Assign vector
Plane &Plane::operator=( const Vector &vec ){
	v[0] = vec.v[0];
	v[1] = vec.v[1];
	v[2] = vec.v[2]; 
	return( *this );
}

//!  Assign vector4
Plane &Plane::operator=( const Vector4 &vec ){
	v[0] = vec.v[0];
	v[1] = vec.v[1];
	v[2] = vec.v[2]; 
	v[3] = vec.v[3]; 
	return( *this );
}


//!  Debugging information
void Plane::debug() const {
	printf( "%f, %f, %f, %f", (float)v[0], (float)v[1], (float)v[2], (float)v[3] );
}


};  //  namespace Maths


