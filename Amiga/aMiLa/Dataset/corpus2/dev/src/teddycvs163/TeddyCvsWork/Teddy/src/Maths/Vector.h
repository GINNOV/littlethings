
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
	\class   Vector
	\ingroup g_maths
	\author  Sean O'Neil
	\date    2001

	This template class implements a simple 3D vector with v[0], v[1], and v[2] coordinates.
	Several functions and operators are defined to make working with vectors easier,
	and because it's templatized, any numeric type can be used with it. Macros are
	defined for the most common types.
*/


#ifndef TEDDY_MATHS_VECTOR_H
#define TEDDY_MATHS_VECTOR_H


#include "SysSupport/StdMaths.h"


namespace Maths {


//! Template Class: TVector
/*
	This template class implements a simple 3D vector with v[0], v[1], and v[2] coordinates.
	Several functions and operators are defined to make working with vectors easier,
	and because it's templatized, any numeric type can be used with it. Macros are
	defined for the most common types.
*/
#define Vector        TVector<float>
#define DoubleVector  TVector<double>
#define CIntVector    TVector<int>
#define CByteVector   TVector<unsigned char>

#define VECTOR_EPSILON 0.00001

template <class T> class TVector
{
public:
	T v[3];

	// Constructors
	TVector(){}
	TVector( const T a, const T b, const T c ){
		v[0] = a;
		v[1] = b;
		v[2] = c;
	}

	TVector( const T           t  ){ *this = t;  }
	TVector( const T          *pt ){ *this = pt; }
	TVector( const TVector<T> &v  ){ *this = v;  }

	// Casting and unary operators
	            operator TVector<float>  ()                    { return TVector<float>((float)v[0], (float)v[1], (float)v[2]); }
	            operator TVector<double> ()                    { return TVector<double>((double)v[0], (double)v[1], (double)v[2]); }
	            operator              T* ()                    { return &v[0]; }
	T          &operator              [] ( const int n )       { return (&v[0])[n]; }
	            operator const        T* ()              const { return &v[0]; }
	T           operator              [] ( const int n ) const { return (&v[0])[n]; }
	TVector<T>  operator               - ()              const { return TVector<T>(-v[0], -v[1], -v[2]); }

	// Equal and comparison operators
	void operator= ( const T           t   )       { v[0] = v[1] = v[2] = t; }
	void operator= ( const T          *pt  )       { v[0] = pt[0]; v[1] = pt[1]; v[2] = pt[2]; }
	void operator= ( const TVector<T> &vec )       { v[0] = vec.v[0]; v[1] = vec.v[1]; v[2] = vec.v[2]; }
	bool operator==(       TVector<T> &vec ) const { return (Abs(v[0] - vec.v[0]) <= (T)0.00001f && Abs(v[1] - vec.v[1]) <= 0.00001f && Abs(v[2] - vec.v[2]) <= 0.00001f); }
	bool operator!=(       TVector<T> &vec ) const { return !(*this == vec); }

	// Arithmetic operators (vector with scalar)
	      TVector<T>  operator+ ( const T t ) const { return TVector<T>(v[0]+t, v[1]+t, v[2]+t); }
	      TVector<T>  operator- ( const T t ) const { return TVector<T>(v[0]-t, v[1]-t, v[2]-t); }
	      TVector<T>  operator* ( const T t ) const { return TVector<T>(v[0]*t, v[1]*t, v[2]*t); }
	      TVector<T>  operator/ ( const T t ) const { return TVector<T>(v[0]/t, v[1]/t, v[2]/t); }
	const TVector<T> &operator+=( const T t )       { v[0] += t; v[1] += t; v[2] += t; return *this; }
	const TVector<T> &operator-=( const T t )       { v[0] -= t; v[1] -= t; v[2] -= t; return *this; }
	const TVector<T> &operator*=( const T t )       { v[0] *= t; v[1] *= t; v[2] *= t; return *this; }
	const TVector<T> &operator/=( const T t )       { v[0] /= t; v[1] /= t; v[2] /= t; return *this; }

	// Arithmetic operators (vector with vector)
	      TVector<T>  operator+ ( const TVector<T> &vec ) const { return TVector<T>(v[0]+vec.v[0], v[1]+vec.v[1], v[2]+vec.v[2]); }
	      TVector<T>  operator- ( const TVector<T> &vec ) const { return TVector<T>(v[0]-vec.v[0], v[1]-vec.v[1], v[2]-vec.v[2]); }
	      TVector<T>  operator* ( const TVector<T> &vec ) const { return TVector<T>(v[0]*vec.v[0], v[1]*vec.v[1], v[2]*vec.v[2]); }
	      TVector<T>  operator/ ( const TVector<T> &vec ) const { return TVector<T>(v[0]/vec.v[0], v[1]/vec.v[1], v[2]/vec.v[2]); }
	const TVector<T> &operator+=( const TVector<T> &vec )       { v[0] += vec.v[0]; v[1] += vec.v[1]; v[2] += vec.v[2]; return *this; }
	const TVector<T> &operator-=( const TVector<T> &vec )       { v[0] -= vec.v[0]; v[1] -= vec.v[1]; v[2] -= vec.v[2]; return *this; }
	const TVector<T> &operator*=( const TVector<T> &vec )       { v[0] *= vec.v[0]; v[1] *= vec.v[1]; v[2] *= vec.v[2]; return *this; }
	const TVector<T> &operator/=( const TVector<T> &vec )       { v[0] /= vec.v[0]; v[1] /= vec.v[1]; v[2] /= vec.v[2]; return *this; }

	// Dot and cross product operators
	      T           operator| ( const TVector<T> &vec ) const { return v[0]*vec.v[0] + v[1]*vec.v[1] + v[2]*vec.v[2]; }
	      TVector<T>  operator^ ( const TVector<T> &vec ) const { return TVector<T>(v[1]*vec.v[2] - v[2]*vec.v[1], v[2]*vec.v[0] - v[0]*vec.v[2], v[0]*vec.v[1] - v[1]*vec.v[0]); }
	const TVector<T> &operator^=( const TVector<T> &vec )       { *this = *this ^ vec; return *this; }

	// Magnitude/distance methods
	T          magnitudeSquared()                        const { return v[0]*v[0] + v[1]*v[1] + v[2]*v[2]; }
	T          magnitude       ()                        const { return (T)sqrt(magnitudeSquared()); }
	T          distanceSquared ( const TVector<T> &vec ) const { return (*this - vec).magnitudeSquared(); }
	T          distance        ( const TVector<T> &vec ) const { return (*this - vec).magnitude(); }
	TVector<T> midpoint        ( const TVector<T> &vec ) const { return Vector((*this - vec) / 2 + v); }
	TVector<T> average         ( const TVector<T> &vec ) const { return Vector((*this + vec) / 2); }

	// Advanced methods (should only be used with float or double types)
	void       normalize()                              { *this /= magnitude(); }
	double     angle    ( const TVector<T> &vec ) const { return acos(*this | vec); }
	TVector<T> reflect  ( const TVector<T> &n   ) const {
		T t = (T)magnitude();
		TVector<T> v = *this / t;
		return (v - n * (2 * (v | n))) * t;
	}

	TVector<T> rotate( const T tAngle, const Vector &n ) const {
		T tCos = (T)cos( tAngle );
		T tSin = (T)sin( tAngle );
		return TVector<T>(*this * tCos + ((n * *this) * (1 - tCos)) * n + (*this ^ n) * tSin);
	}
};

// Returns the normal vector of two vectors (the normalized cross product)
template <class T> inline TVector<T> normalVector( const TVector<T> &v1, const TVector<T> &v2 ){
	TVector<T> v = v1 ^ v2;
	v.normalize();
	return v;
}

// Returns the normal vector of a triangle or 3 points on a plane (assumes counter-clockwise orientation)
template <class T> inline TVector<T> normalVector( const TVector<T> &p1, const TVector<T> &p2, const TVector<T> &p3 ){
	return normalVector( p2-p1, p3-p1 );
}

// Returns the direction vector between two points
template <class T> inline TVector<T> directionVector( const TVector<T> &p1, const TVector<T> &p2 ){
	TVector<T> vec = p2 - p1;
	vec.normalize();
	return vec;
}


};  //  namespace Maths


#endif  //  TEDDY_MATHS_VECTOR_H

