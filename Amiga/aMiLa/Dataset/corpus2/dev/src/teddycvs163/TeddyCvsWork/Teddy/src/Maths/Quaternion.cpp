
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


#include "Maths/Quaternion.h"
#include "Maths/Matrix.h"


namespace Maths {


#define DELTA 1e-6f

#define QUATERNION_EPSILON 1e-6f


Vector Quaternion::rotateVector( Vector &vec ) const {
	return Vector( *this * Quaternion(vec) * unitInverse() );
}

void Quaternion::setAxisAngle( const Vector &vAxis, const float radians ){
	// 4 muls, 2 trig function calls
	float f = radians * 0.5f;

	*this = vAxis * sinf( f );
	v[3]  = cosf( f );
}

void Quaternion::getAxisAngle( Vector &vAxis, float &radians ) const {
	// 4 muls, 1 div, 2 trig function calls
	radians = acosf( v[3] );
	vAxis   = *this / sinf( radians );
	radians *= 2.0f;
}


void Quaternion::operator=( const Matrix &m ){
	// Check the sum of the diagonal
	float tr = m(0, 0) + m(1, 1) + m(2, 2);
	if( tr > 0.0f ){
		// The sum is positive
		// 4 muls, 1 div, 6 adds, 1 trig function call
		float s = sqrtf(tr + 1.0f);
		v[3] = s * 0.5f;
		s    = 0.5f / s;
		v[0] = (m(1, 2) - m(2, 1)) * s;
		v[1] = (m(2, 0) - m(0, 2)) * s;
		v[2] = (m(0, 1) - m(1, 0)) * s;
	}else{
		// The sum is negative
		// 4 muls, 1 div, 8 adds, 1 trig function call
		const int nIndex[3] = {1, 2, 0};
		int i;
		int j;
		int k;
		i = 0;
		if( m(1, 1) > m(i, i) ) i = 1;
		if( m(2, 2) > m(i, i) ) i = 2;
		j = nIndex[i];
		k = nIndex[j];

		float s = sqrtf((m(i, i) - (m(j, j) + m(k, k))) + 1.0f);
		(*this)[i] = s * 0.5f;
		if( s != 0.0 ) s = 0.5f / s;
		(*this)[j] = (m(i, j) + m(j, i)) * s;
		(*this)[k] = (m(i, k) + m(k, i)) * s;
		(*this)[3] = (m(j, k) - m(k, j)) * s;
	}
}

Quaternion Quaternion::operator*( const Quaternion &q ) const {
	// 12 muls, 30 adds
	float E = (v[0] + v[2])*(q.v[0] + q.v[1]);
	float F = (v[2] - v[0])*(q.v[0] - q.v[1]);
	float G = (v[3] + v[1])*(q.v[3] - q.v[2]);
	float H = (v[3] - v[1])*(q.v[3] + q.v[2]);
	float A = F - E;
	float B = F + E;
	return Quaternion(
		(v[3] + v[0])*(q.v[3] + q.v[0]) + (A - G - H) * 0.5f,
		(v[3] - v[0])*(q.v[1] + q.v[2]) + (B + G - H) * 0.5f,
		(v[1] + v[2])*(q.v[3] - q.v[0]) + (B - G + H) * 0.5f,
		(v[2] - v[1])*(q.v[1] - q.v[2]) + (A + G + H) * 0.5f
	);
}

// Spherical linear interpolation between two quaternions
Quaternion slerp( const Quaternion &q1, const Quaternion &q2, const float t ){
	// Calculate the cosine of the angle between the two
	float  fScale0;
	float  fScale1;
	double dCos = q1.v[0] * q2.v[0] + q1.v[1] * q2.v[1] + q1.v[2] * q2.v[2] + q1.v[3] * q2.v[3];

	// If the angle is significant, use the spherical interpolation
	if( (1.0 - fabs(dCos)) > DELTA ){
		double dTemp = acos( fabs(dCos) );
		double dSin  = sin ( dTemp );
		fScale0 = (float)(sin( (1.0 - t) * dTemp) / dSin );
		fScale1 = (float)(sin(        t  * dTemp) / dSin );
	}else{  //  Else use the cheaper linear interpolation
		fScale0 = 1.0f - t;
		fScale1 = t;
	}

	if( dCos < 0.0 ) fScale1 = -fScale1;

	// Return the interpolated result
	return (q1 * fScale0) + (q2 * fScale1);
}


};  //  namespace Maths

