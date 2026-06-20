
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

/*!
	\class   Plane
	\ingroup g_maths
	\author  Timo Suoranta
	\brief   Plane equation
	\date    1999, 2000, 2001
*/


#ifndef TEDDY_MATHS_PLANE_H
#define TEDDY_MATHS_PLANE_H


#include "Maths/Vector.h"
#include "Maths/Vector4.h"


namespace Maths {


class Plane : public Vector4 {
public:
	Plane(){}
	Plane( float a, float b, float c, float d ):Vector4(a,b,c,d){}

	void          neg      ();
	float         distance ( const Vector &p ) const;
	Plane        &operator=( const Vector &v );
	Plane        &operator=( const Vector4 &v );
	Vector        getNormal() const;
	float         getConstant() const;

	virtual void  debug() const;
};


};  //  namespace Maths


#endif  //  TEDDY_MATHS_PLANE_H


