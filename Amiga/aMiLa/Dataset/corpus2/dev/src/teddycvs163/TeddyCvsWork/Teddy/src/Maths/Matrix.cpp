
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


#include "Maths/Matrix.h"
#include "Maths/Quaternion.h"


namespace Maths {


static float a_identity_matrix[] = {
	1.0f,0.0f,0.0f,0.0f, 
	0.0f,1.0f,0.0f,0.0f,
	0.0f,0.0f,1.0f,0.0f,
	0.0f,0.0f,0.0f,1.0f
};
static float *mat = &a_identity_matrix[0];
Matrix Matrix::Identity( mat );


void Matrix::operator=( const Quaternion &q ){
	// 9 muls, 15 adds
	float x2 = q.v[0] + q.v[0];
	float y2 = q.v[1] + q.v[1];
	float z2 = q.v[2] + q.v[2];
	float xx = q.v[0] * x2;  float xy = q.v[0] * y2;  float xz = q.v[0] * z2;
	float yy = q.v[1] * y2;  float yz = q.v[1] * z2;  float zz = q.v[2] * z2;
	float wx = q.v[3] * x2;  float wy = q.v[3] * y2;  float wz = q.v[3] * z2;

	m[0][3] = 
	m[1][3] = 
	m[2][3] = 
	m[3][0] = m[3][1] = m[3][2] = 0; 
	m[3][3] = 1;
	m[0][0] = 1-(yy+zz);  m[1][0] = xy+wz;      m[2][0] = xz-wy;
	m[0][1] = xy-wz;      m[1][1] = 1-(xx+zz);  m[2][1] = yz+wx;
	m[0][2] = xz+wy;      m[1][2] = yz-wx;      m[2][2] = 1-(xx+yy);
}

Matrix Matrix::operator*( const Matrix &mat ) const {
	// 36 muls, 27 adds
	// | m[0][0] m[1][0] m[2][0] m[3][0] |   | mat.m[0][0] mat.m[1][0] mat.m[2][0] mat.m[3][0] |   | m[0][0]*mat.m[0][0]+m[1][0]*mat.m[0][1]+m[2][0]*mat.m[0][2] m[0][0]*mat.m[1][0]+m[1][0]*mat.m[1][1]+m[2][0]*mat.m[1][2] m[0][0]*mat.m[2][0]+m[1][0]*mat.m[2][1]+m[2][0]*mat.m[2][2] m[0][0]*mat.m[3][0]+m[1][0]*mat.m[3][1]+m[2][0]*mat.m[3][2]+m[3][0] |
	// | m[0][1] m[1][1] m[2][1] m[3][1] |   | mat.m[0][1] mat.m[1][1] mat.m[2][1] mat.m[3][1] |   | m[0][1]*mat.m[0][0]+m[1][1]*mat.m[0][1]+m[2][1]*mat.m[0][2] m[0][1]*mat.m[1][0]+m[1][1]*mat.m[1][1]+m[2][1]*mat.m[1][2] m[0][1]*mat.m[2][0]+m[1][1]*mat.m[2][1]+m[2][1]*mat.m[2][2] m[0][1]*mat.m[3][0]+m[1][1]*mat.m[3][1]+m[2][1]*mat.m[3][2]+m[3][1] |
	// | m[0][2] m[1][2] m[2][2] m[3][2] | * | mat.m[0][2] mat.m[1][2] mat.m[2][2] mat.m[3][2] | = | m[0][2]*mat.m[0][0]+m[1][2]*mat.m[0][1]+m[2][2]*mat.m[0][2] m[0][2]*mat.m[1][0]+m[1][2]*mat.m[1][1]+m[2][2]*mat.m[1][2] m[0][2]*mat.m[2][0]+m[1][2]*mat.m[2][1]+m[2][2]*mat.m[2][2] m[0][2]*mat.m[3][0]+m[1][2]*mat.m[3][1]+m[2][2]*mat.m[3][2]+m[3][2] |
	// | 0   0   0   1   |   | 0     0     0     1     |   | 0                             0                             0                             1                                 |
	Matrix mRet;

	mRet.m[0][0] = m[0][0]*mat.m[0][0] + m[1][0]*mat.m[0][1] + m[2][0]*mat.m[0][2] + m[3][0]*mat.m[0][3];
	mRet.m[1][0] = m[0][0]*mat.m[1][0] + m[1][0]*mat.m[1][1] + m[2][0]*mat.m[1][2] + m[3][0]*mat.m[1][3];
	mRet.m[2][0] = m[0][0]*mat.m[2][0] + m[1][0]*mat.m[2][1] + m[2][0]*mat.m[2][2] + m[3][0]*mat.m[2][3];
	mRet.m[3][0] = m[0][0]*mat.m[3][0] + m[1][0]*mat.m[3][1] + m[2][0]*mat.m[3][2] + m[3][0]*mat.m[3][3];

	mRet.m[0][1] = m[0][1]*mat.m[0][0] + m[1][1]*mat.m[0][1] + m[2][1]*mat.m[0][2] + m[3][1]*mat.m[0][3];
	mRet.m[1][1] = m[0][1]*mat.m[1][0] + m[1][1]*mat.m[1][1] + m[2][1]*mat.m[1][2] + m[3][1]*mat.m[1][3];
	mRet.m[2][1] = m[0][1]*mat.m[2][0] + m[1][1]*mat.m[2][1] + m[2][1]*mat.m[2][2] + m[3][1]*mat.m[2][3];
	mRet.m[3][1] = m[0][1]*mat.m[3][0] + m[1][1]*mat.m[3][1] + m[2][1]*mat.m[3][2] + m[3][1]*mat.m[3][3];

	mRet.m[0][2] = m[0][2]*mat.m[0][0] + m[1][2]*mat.m[0][1] + m[2][2]*mat.m[0][2] + m[3][2]*mat.m[0][3];
	mRet.m[1][2] = m[0][2]*mat.m[1][0] + m[1][2]*mat.m[1][1] + m[2][2]*mat.m[1][2] + m[3][2]*mat.m[1][3];
	mRet.m[2][2] = m[0][2]*mat.m[2][0] + m[1][2]*mat.m[2][1] + m[2][2]*mat.m[2][2] + m[3][2]*mat.m[2][3];
	mRet.m[3][2] = m[0][2]*mat.m[3][0] + m[1][2]*mat.m[3][1] + m[2][2]*mat.m[3][2] + m[3][2]*mat.m[3][3];

	mRet.m[0][3] = m[0][3]*mat.m[0][0] + m[1][3]*mat.m[0][1] + m[2][3]*mat.m[0][2] + m[3][3]*mat.m[0][3];
	mRet.m[1][3] = m[0][3]*mat.m[1][0] + m[1][3]*mat.m[1][1] + m[2][3]*mat.m[1][2] + m[3][3]*mat.m[1][3];
	mRet.m[2][3] = m[0][3]*mat.m[2][0] + m[1][3]*mat.m[2][1] + m[2][3]*mat.m[2][2] + m[3][3]*mat.m[2][3];
	mRet.m[3][3] = m[0][3]*mat.m[3][0] + m[1][3]*mat.m[3][1] + m[2][3]*mat.m[3][2] + m[3][3]*mat.m[3][3];

	return mRet;
}


};  //  namespace Maths

