
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

/*!
	\file
	\ingroup g_application
	\author  Timo Suoranta
	\warning This file contains Logical UserInterface Actions
	\date	 2001
*/


#if defined(_MSC_VER)
#pragma warning(disable:4244)  //  conversion from 'double' to 'float', possible loss of data
#endif


#include "glElite/Atmosphere.h"
#include "Maths/Matrix.h"
#include "Maths/Plane.h"
#include "Maths/Vector.h"
#include <cmath>
using namespace Maths;


namespace Application {


static void generateOrthonormalBasis( Vector &U, Vector &V, Vector &W );


void PerspProjEllipsoid(
	const Ellipsoid &ellipsoid,
    const Vector    &eye,
	const Plane     &plane,
	Ellipse         &ellipse
){
    // compute matrix M
    Vector  AE   = ellipsoid.A * eye;
    float   EAE  = eye         | AE;
    float   BE   = ellipsoid.B | eye;
    float   tmp  = 4 * ( EAE + BE + ellipsoid.C );
    Vector  tmpv = ellipsoid.B + AE * 2;
    Matrix  mat;  // 3x3

	mat = Matrix::Identity;

    mat(0,0) = tmpv.v[0] * tmpv.v[0] - tmp * ellipsoid.A(0,0);
    mat(0,1) = tmpv.v[0] * tmpv.v[1] - tmp * ellipsoid.A(0,1);
    mat(0,2) = tmpv.v[0] * tmpv.v[2] - tmp * ellipsoid.A(0,2);
    mat(1,1) = tmpv.v[1] * tmpv.v[1] - tmp * ellipsoid.A(1,1);
    mat(1,2) = tmpv.v[1] * tmpv.v[2] - tmp * ellipsoid.A(1,2);
    mat(2,2) = tmpv.v[2] * tmpv.v[2] - tmp * ellipsoid.A(2,2);
    mat(1,0) = mat(0,1);
    mat(2,0) = mat(0,2);
    mat(2,1) = mat(1,2);

    // Normalize N and construct U and V so that {U,V,N} forms a
    // right-handed, orthonormal basis.
    Vector U;
	Vector V;
	Vector N = plane.getNormal();
    generateOrthonormalBasis( U, V, N );

    // compute coefficients for projected ellipse
    Vector MU       = mat * U;
	Vector MV       = mat * V;
	Vector MN       = mat * N;
    float  DmNE     = plane.getConstant() - ( N | eye );

	ellipse.A      = Matrix::Identity;  //  TIS
    ellipse.A(0,0) = U | MU;
    ellipse.A(0,1) = U | MV;
    ellipse.A(1,1) = V | MV;
    ellipse.A(1,0) = ellipse.A(0,1);
    ellipse.B.v[0]     =   2  * DmNE * ( U | MN );
    ellipse.B.v[1]     =   2  * DmNE * ( V | MN );
	ellipse.B.v[2]     =   1;                           //  TIS
    ellipse.C       = DmNE * DmNE * ( N | MN );
}


void ConvertEllipse(
	Ellipse &ellipse,
	Vector  &center,
    Vector  &axis0,
	Vector  &axis1,
	float   &halfLength0,
    float   &halfLength1
){
    // factor A = R^t D R
    double trace = ellipse.A(0,0) + ellipse.A(1,1);
    if( trace < 0 ){
        // Convert A from negative definite to positive definite
        // (multiply quadratic equation by -1).
        ellipse.A = -ellipse.A;
        ellipse.B = -ellipse.B;
        ellipse.C = -ellipse.C;
        trace     = -trace;
    }

    double tmp   = ellipse.A(0,0) - ellipse.A(1,1);
    double discr = sqrt( tmp*tmp + 4*ellipse.A(0,1) * ellipse.A(0,1) );

    //  Matrix D (eigenvalues of A)
    double D0    = 0.5 * (trace - discr);
    double D1    = 0.5 * (trace + discr);
    double invD0 = 1/D0;
    double invD1 = 1/D1;

    //  Matrix R (columns are eigenvectors of A)
    Matrix R;
    Vector beta;

	R = Matrix::Identity;  //  TIS
    if( ellipse.A(0,1) != 0 ){
        double invLength;

        R(0,0)    = ellipse.A(0,1);
        R(1,0)    = D0 - ellipse.A(0,0);
        invLength = 1 / sqrt( R(0,0) * R(0,0)  +  R(1,0) * R(1,0) );
        R(0,0)   *= invLength;
        R(1,0)   *= invLength;

        R(0,1)    = D1 - ellipse.A(1,1);
        R(1,1)    = ellipse.A(0,1);
        invLength = 1 / sqrt( R(0,1) * R(0,1)  +  R(1,1) * R(1,1) );
        R(0,1)   *= invLength;
        R(1,1)   *= invLength;
    }

    beta     =   R  * ellipse.B;        //  Compute the ellipse center
    center.v[0] = -0.5 * beta.v[0] * invD0;
    center.v[1] = -0.5 * beta.v[1] * invD1;
	center.v[2] =  0;  //  TIS

    axis0.v[0]  = R(0,0);  //  Compute the ellipse axes
    axis0.v[1]  = R(1,0);
    axis1.v[0]  = R(0,1);
    axis1.v[1]  = R(1,1);

    // compute the ellipse axis half lengths
    tmp           = D0 * center.v[0] * center.v[0]  +  D1 * center.v[1] * center.v[1]  -  ellipse.C;
    halfLength0 = sqrt(  fabs( tmp * invD0 )  );
    halfLength1 = sqrt(  fabs( tmp * invD1 )  );
}



static void generateOrthonormalBasis( Vector &U, Vector &V, Vector &W ){
    double inv_length;

	W.normalize();

    if( fabs(W.v[0]) >= fabs(W.v[1]) ){
        // W.v[0] or W.v[2] is the largest magnitude component, swap them
        inv_length = 1 / sqrt( W.v[0]*W.v[0]+W.v[2]*W.v[2] );
        U.v[0] = -W.v[2] * inv_length;
        U.v[1] = 0;
        U.v[2] = +W.v[0] * inv_length;
    }else{
        // W.v[1] or W.v[2] is the largest magnitude component, swap them
        inv_length = 1 / sqrt( W.v[1]*W.v[1]+W.v[2]*W.v[2] );
        U.v[0] = 0;
        U.v[1] = +W.v[2] * inv_length;
        U.v[2] = -W.v[1] * inv_length;
    }

    V = W ^ U;  //  Cross-product
}



};  //  namespace Application

