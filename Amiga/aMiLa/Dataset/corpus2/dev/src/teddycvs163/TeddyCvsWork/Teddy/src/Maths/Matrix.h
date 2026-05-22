
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
	\class   Matrix
	\ingroup g_maths
	\author  Sean O'Neil
	\brief   4x4 Matrix
	\date    2000, 2001
*/


#ifndef TEDDY_MATHS_MATRIX_H
#define TEDDY_MATHS_MATRIX_H


#if defined(_MSC_VER)
# pragma warning(disable:4786)
#endif


#include "Maths/Vector.h"
#include "Maths/Vector4.h"
#include "SysSupport/StdMaths.h"


namespace Maths {


class Quaternion;


//! Class: Matrix
/*!
	This class implements a 4x4 matrix. Several functions and operators are
	defined to make working with matrices easier. The values are kept in column-
	major order to make it easier to use with OpenGL. For performance reasons,
	most of the functions assume that all matrices are orthogonal, which means the
	bottom row is [ 0 0 0 1 ]. Since I plan to use the GL_PROJECTION matrix to
	handle the projection matrix, I should never need to use any other kind of
	matrix, and I get a decent performance boost by ignoring the bottom row.
	
	Note: This class is not templatized because integral data types don't make sense
	      and there's no need for double-precision.
*/
class Matrix {
public:
	// This class uses column-major order, as used by OpenGL
	// | m[0][0] m[1][0] m[2][0] m[3][0] |
	// | m[0][1] m[1][1] m[2][1] m[3][1] | 
	// | m[0][2] m[1][2] m[2][2] m[3][2] | 
	// | m[0][3] m[1][3] m[2][3] m[3][3] | 
	float m[4][4];

	Matrix(){}
	Matrix(const float       f  ){ *this = f;  }
	Matrix(const float      *pf ){ *this = pf; }
	Matrix(const Quaternion &q  ){ *this = q;  }

	// Init functions
	void zeroMatrix(){
		m[0][0] = m[0][1] = m[0][2] = m[0][3] =
		m[1][0] = m[1][1] = m[1][2] = m[1][3] =
		m[2][0] = m[2][1] = m[2][2] = m[2][3] =
		m[3][0] = m[3][1] = m[3][2] = m[3][3] = 0;
	}

	       operator        float* ()                                 { return &m[0][0]; }
	float &operator            () ( const int i, const int j )       { return m[i][j]; }
	       operator const float*  ()                           const { return &m[0][0]; }
	float  operator            () ( const int i, const int j ) const { return m[i][j]; }

	void operator=( const float k ){
	    float *f;

		for( f = &m[0][0]; f != (float *)m+16; f++ ){
			*f = k;
		}
	}

	void operator=( const float *pf){
	    float *to = &m[0][0];

		for( register int i=0; i<16; i++ ){
			to[i] = pf[i];
		}
	}

	void   operator=( const Quaternion &q);

	Matrix operator-() const {
		Matrix mat;
	    const float *from = &    m[0][0];
	    float *to   = &mat.m[0][0];

		for( register int i=0; i<16; i++ ){
			to[i] = -from[i];
		}
		return mat;
	}

	      Matrix   operator* ( const Matrix  &mat ) const;
	const Matrix  &operator*=( const Matrix  &mat ){ *this = *this * mat; }
	      Vector   operator* ( const Vector  &vec ) const { return transformVector (vec); }
	      Vector4  operator* ( const Vector4 &vec ) const { return transformVector4(vec); }

	Vector transformVector( const Vector &vec ) const {
		// 9 muls, 9 adds
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | v.v[0] |   | m[0][0]*v.v[0]+m[1][0]*v.v[1]+m[2][0]*v.v[2]+m[3][0] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | v.v[1] |   | m[0][1]*v.v[0]+m[1][1]*v.v[1]+m[2][1]*v.v[2]+m[3][1] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | v.v[2] | = | m[0][2]*v.v[0]+m[1][2]*v.v[1]+m[2][2]*v.v[2]+m[3][2] |
		// | 0   0   0   1   |   | 1   |   | 1                           |
		return Vector(
			(m[0][0]*vec.v[0] + m[1][0]*vec.v[1] + m[2][0]*vec.v[2] + m[3][0]),
			(m[0][1]*vec.v[0] + m[1][1]*vec.v[1] + m[2][1]*vec.v[2] + m[3][1]),
			(m[0][2]*vec.v[0] + m[1][2]*vec.v[1] + m[2][2]*vec.v[2] + m[3][2])
		);
	}
	Vector4 transformVector4( const Vector4 &vec ) const {
		return Vector4(
			(m[0][0]*vec.v[0] + m[1][0]*vec.v[1] + m[2][0]*vec.v[2] + m[3][0]*vec.v[3]),
			(m[0][1]*vec.v[0] + m[1][1]*vec.v[1] + m[2][1]*vec.v[2] + m[3][1]*vec.v[3]),
			(m[0][2]*vec.v[0] + m[1][2]*vec.v[1] + m[2][2]*vec.v[2] + m[3][2]*vec.v[3]),
			(m[0][3]*vec.v[0] + m[1][3]*vec.v[1] + m[2][3]*vec.v[2] + m[3][3]*vec.v[3])
		);
	}


	Vector transformNormal( const Vector &vec ) const {
		// 9 muls, 6 adds
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | v.v[0] |   | m[0][0]*v.v[0]+m[1][0]*v.v[1]+m[2][0]*v.v[2] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | v.v[1] |   | m[0][1]*v.v[0]+m[1][1]*v.v[1]+m[2][1]*v.v[2] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | v.v[2] | = | m[0][2]*v.v[0]+m[1][2]*v.v[1]+m[2][2]*v.v[2] |
		// | 0   0   0   1   |   | 1   |   | 1                       |
		return Vector(
			(m[0][0]*vec.v[0] + m[1][0]*vec.v[1] + m[2][0]*vec.v[2] ),
			(m[0][1]*vec.v[0] + m[1][1]*vec.v[1] + m[2][1]*vec.v[2] ),
			(m[0][2]*vec.v[0] + m[1][2]*vec.v[1] + m[2][2]*vec.v[2] )
		);
	}

	// Translate functions
	void translateMatrix( const float x, const float y, const float z ){
		// | 1  0  0  x |
		// | 0  1  0  y |
		// | 0  0  1  z |
		// | 0  0  0  1 |
		m[0][1] = m[0][2] = m[0][3] =
		m[1][0] = m[1][2] = m[1][3] =
		m[2][0] = m[2][1] = m[2][3] = 0;
		m[0][0] = m[1][1] = m[2][2] = m[3][3] = 1;
		m[3][0] = x; 
		m[3][1] = y; 
		m[3][2] = z;
	}

	void translateMatrix( const float *pf ){ translateMatrix( pf[0], pf[1], pf[2] ); }

	void translate( const float x, const float y, const float z ){
		// 9 muls, 9 adds
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | 1  0  0  x |   | m[0][0] m[1][0] m[2][0] m[0][0]*x+m[1][0]*y+m[2][0]*z+m[3][0] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | 0  1  0  y |   | m[0][1] m[1][1] m[2][1] m[0][1]*x+m[1][1]*y+m[2][1]*z+m[3][1] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | 0  0  1  z | = | m[0][2] m[1][2] m[2][2] m[0][2]*x+m[1][2]*y+m[2][2]*z+m[3][2] |
		// | 0   0   0   1   |   | 0  0  0  1 |   | 0   0   0   1                     |
		m[3][0] = m[0][0]*x + m[1][0]*y + m[2][0]*z + m[3][0];
		m[3][1] = m[0][1]*x + m[1][1]*y + m[2][1]*z + m[3][1];
		m[3][2] = m[0][2]*x + m[1][2]*y + m[2][2]*z + m[3][2];
	}

	void translate( const float *pf ){
		translate( pf[0], pf[1], pf[2] );
	}

	// Scale functions
	void scaleMatrix( const float x, const float y, const float z ){
		// | x  0  0  0 |
		// | 0  y  0  0 |
		// | 0  0  z  0 |
		// | 0  0  0  1 |
		m[0][1] = m[0][2] = m[0][3] =
		m[1][0] = m[1][2] = m[1][3] =
		m[2][0] = m[2][1] = m[2][3] =
		m[3][0] = m[3][1] = m[3][2] = 0;
		m[0][0] = x;
		m[1][1] = y;
		m[2][2] = z;
		m[3][3] = 1;
	}

	void scaleMatrix( const float *pf ){
		scaleMatrix( pf[0], pf[1], pf[2] );
	}

	void scale( const float x, const float y, const float z ){
		// 9 muls
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | x  0  0  0 |   | m[0][0]*x m[1][0]*y m[2][0]*z m[3][0] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | 0  y  0  0 |   | m[0][1]*x m[1][1]*y m[2][1]*z m[3][1] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | 0  0  z  0 | = | m[0][2]*x m[1][2]*y m[2][2]*z m[3][2] |
		// | 0   0   0   1   |   | 0  0  0  1 |   | 0     0     0     1   |
		m[0][0] *= x; m[1][0] *= y; m[2][0] *= z;
		m[0][1] *= x; m[1][1] *= y; m[2][1] *= z;
		m[0][2] *= x; m[1][2] *= y; m[2][2] *= z;
	}

	void scale( const float *pf ){
		scale( pf[0], pf[1], pf[2] );
	}

	// Rotate functions
	void rotateXMatrix( const float radians ){
		// | 1 0    0     0 |
		// | 0 fCos -fSin 0 |
		// | 0 fSin fCos  0 |
		// | 0 0    0     1 |
		m[0][1] = m[0][2] = m[0][3] = 
		m[1][0] = m[1][3] =
		m[2][0] = m[2][3] =
		m[3][0] = m[3][1] = m[3][2] = 0;
		m[0][0] = m[3][3] = 1;

		float fCos = cosf( radians );
		float fSin = sinf( radians );
		m[1][1] = m[2][2] = fCos;
		m[1][2] =  fSin;
		m[2][1] = -fSin;
	}

	void rotateX( const float radians ){
		// 12 muls, 6 adds, 2 trig function calls
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | 1 0    0     0 |   | m[0][0] m[1][0]*fCos+m[2][0]*fSin m[2][0]*fCos-m[1][0]*fSin m[3][0] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | 0 fCos -fSin 0 |   | m[0][1] m[1][1]*fCos+m[2][1]*fSin m[2][1]*fCos-m[1][1]*fSin m[3][1] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | 0 fSin fCos  0 | = | m[0][2] m[1][2]*fCos+m[2][2]*fSin m[2][2]*fCos-m[1][2]*fSin m[3][2] |
		// | 0   0   0   1   |   | 0 0    0     1 |   | 0   0                 0                 1   |
		float fTemp;
		float fCos = cosf( radians );
		float fSin = sinf( radians );

		fTemp   = m[1][0]*fCos + m[2][0]*fSin;
		m[2][0] = m[2][0]*fCos - m[1][0]*fSin;
		m[1][0] = fTemp;
		fTemp   = m[1][1]*fCos + m[2][1]*fSin;
		m[2][1] = m[2][1]*fCos - m[1][1]*fSin;
		m[1][1] = fTemp;
		fTemp   = m[1][2]*fCos + m[2][2]*fSin;
		m[2][2] = m[2][2]*fCos - m[1][2]*fSin;
		m[1][2] = fTemp;
	}

	void rotateYMatrix( const float radians ){
		// | fCos  0 fSin  0 |
		// | 0     1 0     0 |
		// | -fSin 0 fCos  0 |
		// | 0     0 0     1 |
		m[0][1] = m[0][3] = 
		m[1][0] = m[1][2] = m[1][3] = 
		m[2][1] = m[2][3] = 
		m[3][0] = m[3][1] = m[3][2] = 0;
		m[1][1] = m[3][3] = 1;

		float fCos = cosf( radians );
		float fSin = sinf( radians );
		m[0][0] = m[2][2] = fCos;
		m[0][2] = -fSin;
		m[2][0] =  fSin;
	}
	void rotateY( const float radians ){
		// 12 muls, 6 adds, 2 trig function calls
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | fCos  0 fSin  0 |   | m[0][0]*fCos-m[2][0]*fSin m[1][0] m[0][0]*fSin+m[2][0]*fCos m[3][0] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | 0     1 0     0 |   | m[0][1]*fCos-m[2][1]*fSin m[1][1] m[0][1]*fSin+m[2][1]*fCos m[3][1] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | -fSin 0 fCos  0 | = | m[0][2]*fCos-m[2][2]*fSin m[1][2] m[0][2]*fSin+m[2][2]*fCos m[3][2] |
		// | 0   0   0   1   |   | 0     0 0     1 |   | 0                 0   0                 1   |
		float fTemp;
		float fCos = cosf( radians );
		float fSin = sinf( radians );
		fTemp   = m[0][0]*fCos - m[2][0]*fSin;
		m[2][0] = m[0][0]*fSin + m[2][0]*fCos;
		m[0][0] = fTemp;
		fTemp   = m[0][1]*fCos - m[2][1]*fSin;
		m[2][1] = m[0][1]*fSin + m[2][1]*fCos;
		m[0][1] = fTemp;
		fTemp   = m[0][2]*fCos - m[2][2]*fSin;
		m[2][2] = m[0][2]*fSin + m[2][2]*fCos;
		m[0][2] = fTemp;
	}
	void rotateZMatrix(const float radians ){
		// | fCos -fSin 0 0 |
		// | fSin fCos  0 0 |
		// | 0    0     1 0 |
		// | 0    0     0 1 |
		m[0][2] = m[0][3] =
		m[1][2] = m[1][3] =
		m[2][0] = m[2][1] = m[2][3] =
		m[3][0] = m[3][1] = m[3][2] = 0;
		m[2][2] = m[3][3] = 1;

		float fCos = cosf( radians );
		float fSin = sinf( radians );
		m[0][0] = m[1][1] = fCos;
		m[0][1] =  fSin;
		m[1][0] = -fSin;
	}

	void rotateZ(const float radians ){
		// 12 muls, 6 adds, 2 trig function calls
		// | m[0][0] m[1][0] m[2][0] m[3][0] |   | fCos -fSin 0 0 |   | m[0][0]*fCos+m[1][0]*fSin m[1][0]*fCos-m[0][0]*fSin m[2][0] m[3][0] |
		// | m[0][1] m[1][1] m[2][1] m[3][1] |   | fSin fCos  0 0 |   | m[0][1]*fCos+m[1][1]*fSin m[1][1]*fCos-m[0][1]*fSin m[2][1] m[3][1] |
		// | m[0][2] m[1][2] m[2][2] m[3][2] | * | 0    0     1 0 | = | m[0][2]*fCos+m[1][2]*fSin m[1][2]*fCos-m[0][2]*fSin m[2][2] m[3][2] |
		// | 0   0   0   1   |   | 0    0     0 1 |   | 0                 0                 0   1   |
		float fTemp;
		float fCos = cosf( radians );
		float fSin = sinf( radians );
		fTemp   = m[0][0]*fCos + m[1][0]*fSin;
		m[1][0] = m[1][0]*fCos - m[0][0]*fSin;
		m[0][0] = fTemp;
		fTemp   = m[0][1]*fCos + m[1][1]*fSin;
		m[1][1] = m[1][1]*fCos - m[0][1]*fSin;
		m[0][1] = fTemp;
		fTemp   = m[0][2]*fCos + m[1][2]*fSin;
		m[1][2] = m[1][2]*fCos - m[0][2]*fSin;
		m[0][2] = fTemp;
	}

	void rotateMatrix( const Vector &vec, const float radians ){
		// 15 muls, 10 adds, 2 trig function calls
		float  fCos = cosf( radians );
		Vector vCos = vec * (1 - fCos);
		Vector vSin = vec * sinf( radians );

		m[0][3] = 
		m[1][3] = 
		m[2][3] = 
		m[3][0] = m[3][1] = m[3][2] = 0;
		m[3][3] = 1;

		m[0][0] = (vec.v[0] * vCos.v[0]) + fCos;
		m[1][0] = (vec.v[0] * vCos.v[1]) - (vSin.v[2]);
		m[2][0] = (vec.v[0] * vCos.v[2]) + (vSin.v[1]);
		m[0][1] = (vec.v[1] * vCos.v[0]) + (vSin.v[2]);
		m[1][1] = (vec.v[1] * vCos.v[1]) + fCos;
		m[2][1] = (vec.v[1] * vCos.v[2]) - (vSin.v[0]);
		m[0][2] = (vec.v[2] * vCos.v[1]) - (vSin.v[1]);
		m[2][1] = (vec.v[2] * vCos.v[2]) + (vSin.v[0]);
		m[2][2] = (vec.v[2] * vCos.v[3]) + fCos;
	}

	void rotate( const Vector &vec, const float f ){
		// 51 muls, 37 adds, 2 trig function calls
		Matrix mat;
		mat.rotateMatrix( vec, f );
		*this *= mat;
	}

	void modelMatrix( const Quaternion &q, const Vector &vFrom ){
		*this = q;
		m[3][0] = vFrom.v[0];
		m[3][1] = vFrom.v[1];
		m[3][2] = vFrom.v[2];
	}

	void viewMatrix( const Quaternion &q, const Vector &vFrom ){
		*this = q;
		m[3][0] = -(vFrom.v[0]*m[0][0] + vFrom.v[1]*m[1][0] + vFrom.v[2]*m[2][0]);
		m[3][1] = -(vFrom.v[0]*m[0][1] + vFrom.v[1]*m[1][1] + vFrom.v[2]*m[2][1]);
		m[3][2] = -(vFrom.v[0]*m[0][2] + vFrom.v[1]*m[1][2] + vFrom.v[2]*m[2][2]);
	}

	void viewMatrix( const Vector &vFrom, const Vector &vView, const Vector &vUp, const Vector &vRight ){
		// 9 muls, 9 adds
		m[0][0] =  vRight.v[0]; m[1][0] =  vRight.v[1]; m[2][0] =  vRight.v[2]; m[3][0] = -( vFrom |  vRight );
		m[0][1] =  vUp   .v[0]; m[1][1] =  vUp   .v[1]; m[2][1] =  vUp   .v[2]; m[3][1] = -( vFrom |  vUp    );
		m[0][2] = -vView .v[0]; m[1][2] = -vView .v[1]; m[2][2] = -vView .v[2]; m[3][2] = -( vFrom | -vView  );
		m[0][3] =            0; m[1][3] =            0; m[2][3] =            0; m[3][3] = 1;
	}

	void viewMatrix( const Vector &vFrom, const Vector &vAt, const Vector &vUp ){
		Vector vView   = vAt    - vFrom; vView  .normalize();
		Vector vRight  = vView  ^ vUp;   vRight .normalize();
		Vector vTrueUp = vRight ^ vView; vTrueUp.normalize();
		viewMatrix( vFrom, vView, vTrueUp, vRight );
	}

	// For orthogonal matrices, I belive this also gives you the inverse.
	void transpose(){
#		define SWAP(a,b,c) c=a; a=b; b=c
		float f;
		SWAP(m[0][1], m[1][0], f);
		SWAP(m[0][2], m[2][0], f);
		SWAP(m[0][3], m[3][0], f);
		SWAP(m[1][2], m[2][1], f);
		SWAP(m[1][3], m[3][1], f);
		SWAP(m[2][3], m[3][2], f);
#		undef SWAP
	}

	static Matrix Identity;

};


};  //  namespace Maths;


#endif  //  TEDDY_MATHS_MATRIX_H

