
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta, Sean O' Neil
    tksuoran@cc.helsinki.fi, s_p_oneil@hotmail.com

		Adapted from

		The Universe Development Kit
		Copyright (C) 2000  Sean O'Neil
		s_p_oneil@hotmail.com

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
	\class   Quaternion
	\ingroup g_maths
	\author  Sean O'Neil
	\date    2000, 2001

	This class implements a 4D quaternion. Several functions and operators are
	defined to make working with quaternions easier. Quaternions are often used to
	represent rotations, and have a number of advantages over other constructs.
	Their main disadvantage is that they are unintuitive.
	
	Note: This class is not templatized because integral data types don't make sense
	      and there's no need for double-precision.
*/


#ifndef TEDDY_MATHS_QUATERNION_H
#define TEDDY_MATHS_QUATERNION_H


#include "Maths/Vector.h"
#include "SysSupport/StdMaths.h"


namespace Maths {


class Matrix;


//! Class: CQuaternion
/*!
	This class implements a 4D quaternion. Several functions and operators are
	defined to make working with quaternions easier. Quaternions are often used to
	represent rotations, and have a number of advantages over other constructs.
	Their main disadvantage is that they are unintuitive.

	Note: This class is not templatized because integral data types don't make sense
	and there's no need for double-precision.
*/
class Quaternion {
public:
	float v[4];

	// Constructors
	Quaternion(){}
	Quaternion( const float a, const float b, const float c, const float d ){
		v[0] = a;
		v[1] = b;
		v[2] = c;
		v[3] = d;
	}
	Quaternion( const Vector     &v, const float f){ setAxisAngle(v, f); }
	Quaternion( const Vector     &v ){ *this = v; }
	Quaternion( const Quaternion &q ){ *this = q; }
	Quaternion( const Matrix     &m ){ *this = m; }
	Quaternion( const float      *p ){ *this = p; }

	// Casting and unary operators
	            operator       float* ()                    { return v; }
	float      &operator           [] ( const int n )       { return v[n]; }
	            operator const float* ()              const { return v; }
	float       operator           [] ( const int n ) const { return v[n]; }
	Quaternion  operator            - ()              const { return Quaternion(-v[0], -v[1], -v[2], -v[3]); }

	// Equal and comparison operators
	void operator=( const Vector     &vec ){ v[0] = vec.v[0]; v[1] = vec.v[1]; v[2] = vec.v[2]; v[3] =    0; }
	void operator=( const Quaternion &q   ){ v[0] = q  .v[0]; v[1] = q  .v[1]; v[2] = q  .v[2]; v[3] = q.v[3]; }
	void operator=( const Matrix     &m   );
	void operator=( const float      *p   ){ v[0] = p[0]; v[1] = p[1]; v[2] = p[2]; v[3] = p[3]; }

	// Arithmetic operators (quaternion and scalar)
	Quaternion operator+( const float f ) const { return Quaternion(v[0]+f, v[1]+f, v[2]+f, v[3]+f); }
	Quaternion operator-( const float f ) const { return Quaternion(v[0]-f, v[1]-f, v[2]-f, v[3]-f); }
	Quaternion operator*( const float f ) const { return Quaternion(v[0]*f, v[1]*f, v[2]*f, v[3]*f); }
	Quaternion operator/( const float f ) const { return Quaternion(v[0]/f, v[1]/f, v[2]/f, v[3]/f); }
	const Quaternion &operator+=( const float f ){ v[0]+=f; v[1]+=f; v[2]+=f; v[3]+=f; return *this; }
	const Quaternion &operator-=( const float f ){ v[0]-=f; v[1]-=f; v[2]-=f; v[3]-=f; return *this; }
	const Quaternion &operator*=( const float f ){ v[0]*=f; v[1]*=f; v[2]*=f; v[3]*=f; return *this; }
	const Quaternion &operator/=( const float f ){ v[0]/=f; v[1]/=f; v[2]/=f; v[3]/=f; return *this; }

	// Arithmetic operators (quaternion and quaternion)
	Quaternion operator+( const Quaternion &q ) const { return Quaternion(v[0]+q.v[0], v[1]+q.v[1], v[2]+q.v[2], v[3]+q.v[3]); }
	Quaternion operator-( const Quaternion &q ) const { return Quaternion(v[0]-q.v[0], v[1]-q.v[1], v[2]-q.v[2], v[3]-q.v[3]); }
	Quaternion operator*( const Quaternion &q ) const;  //  Multiplying quaternions is a special operation
																															   
	const Quaternion &operator+=( const Quaternion &q ){ v[0]+=q.v[0]; v[1]+=q.v[1]; v[2]+=q.v[2]; v[3]+=q.v[3]; return *this; }
	const Quaternion &operator-=( const Quaternion &q ){ v[0]-=q.v[0]; v[1]-=q.v[1]; v[2]-=q.v[2]; v[3]-=q.v[3]; return *this; }
	const Quaternion &operator*=( const Quaternion &q ){ *this = *this * q; return *this; }

	// Magnitude/normalize methods
	float magnitudeSquared() const { return v[0]*v[0] + v[1]*v[1] + v[2]*v[2] + v[3]*v[3]; }
	float magnitude       () const { return sqrtf( magnitudeSquared() ); }
	void  normalize       ()       { *this /= magnitude(); }

	// Advanced quaternion methods
	Quaternion conjugate   () const { return Quaternion(-v[0], -v[1], -v[2], v[3]); }
	Quaternion inverse     () const { return conjugate() / magnitudeSquared(); }
	Quaternion unitInverse () const { return conjugate(); }
	Vector     rotateVector( Vector &v ) const;
	void       setAxisAngle( const Vector &vAxis, const float fAngle );
	void       getAxisAngle( Vector &vAxis, float &fAngle) const;

	void rotate( const Quaternion &q ){ *this = q * *this; }

	void rotate( const Vector &vAxis, const float fAngle ){
		Quaternion q;
		q.setAxisAngle( vAxis, fAngle );
		rotate( q );
	}

	/*Vector getViewAxis() const {
		// 6 muls, 7 adds
		float x2 = v[0] + v[0];
		float y2 = v[1] + v[1];
		float z2 = v[2] + v[2];
		float xx = v[0] * x2; float xz = v[0] * z2;
		float yy = v[1] * y2; float yz = v[1] * z2;
		float wx = v[3] * x2; float wy = v[3] * y2;
		return -Vector(xz+wy, yz-wx, 1-(xx+yy));
	}*/

	Vector getViewAxis() const {
		// 6 muls, 7 adds
		float x2 = v[0] + v[0];
		float y2 = v[1] + v[1];
		float z2 = v[2] + v[2];
		float xx = v[0] * x2; float xz = v[0] * z2;
		float yy = v[1] * y2; float yz = v[1] * z2;
		float wx = v[3] * x2; float wy = v[3] * y2;
		return -Vector(xz+wy, yz-wx, 1-(xx+yy));
	}

	Vector getUpAxis() const {
		// 6 muls, 7 adds
		float x2 = v[0] + v[0];
		float y2 = v[1] + v[1];
		float z2 = v[2] + v[2];
		float xx = v[0] * x2; float xy = v[0] * y2;
		float yz = v[1] * z2; float zz = v[2] * z2;
		float wx = v[3] * x2; float wz = v[3] * z2;
		return Vector(xy-wz, 1-(xx+zz), yz+wx);
	}

	Vector getRightAxis() const {
		// 6 muls, 7 adds
		float x2 = v[0] + v[0];
		float y2 = v[1] + v[1];
		float z2 = v[2] + v[2];
		float xy = v[0] * y2; float xz = v[0] * z2;
		float yy = v[1] * y2; float zz = v[2] * z2;
		float wy = v[3] * y2; float wz = v[3] * z2;
		return Vector(1-(yy+zz), xy+wz, xz-wy);
	}
};


extern Quaternion slerp( const Quaternion &q1, const Quaternion &q2, const float t );


};  //  namespace Maths


#endif  //  TEDDY_MATHS_QUATERNION_H

