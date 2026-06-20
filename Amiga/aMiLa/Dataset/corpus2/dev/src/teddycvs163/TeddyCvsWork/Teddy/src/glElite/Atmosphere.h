
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
	\file
	\ingroup g_application
	\author  Timo Suoranta
	\date    2001
*/


#ifndef TEDDY_APPLICATION_ATMOSPHERE_H
#define TEDDY_APPLICATION_ATMOSPHERE_H


#include "Maths/Matrix.h"
#include "Maths/Plane.h"
#include "Maths/Vector.h"
using namespace Maths;


namespace Application {


/*!
	Ellipsoid is X^T A X + B^T X + C = 0
	
		A        is symmetric 3x3
		B and X  are          3x1
		C        is a scalar

	Since A is symmetric, it is not necessary to store all 9 values,
	but I use it for convenience of doing matrix/vector arithmetic.
*/
class Ellipsoid {
public:
    Matrix A;  // 3x3
    Vector B;  // 3x1
    float  C;  // scalar
};


/*!
	Ellipse is X^T A X + B^T X + C = 0 where
	
		A        is symmetric 2x2
		B and X  are          2x1
		C        is a scalar
		
	Since A is symmetric, it is not necessary to store all 4 values,
	but I use it for convenience of doing matrix/vector arithmetic.
*/
class Ellipse {
public:
    Matrix A;  //  2x2
    Vector B;  //  2x1
    float  C;
};


/*!
	Input:

		E                        eyepoint
		N^t X = D                view plane
		X^t A X + B^t X + C = 0  ellipsoid   

			E, N, B, X  3x1
			A           3x3
			C, D        scalars
	
	Output:

		Y^t A Y + B^t Y + C = 0  projected ellipse

			Y B      2x1,
			A        2x2,
			C        scalar
*/
extern void PerspProjEllipsoid (
	const Ellipsoid &ellipsoid,
    const Vector    &eye,
	const Plane     &plane,
	Ellipse         &ellipse
);


/*!
	Compute center, axes, and axis half lengths for the ellipse
	Y^t A Y + B^t Y + C = 0.
*/
extern void ConvertEllipse (
	Ellipse &ellipse,
	Vector  &center,
    Vector  &axis0,
	Vector  &axis1,
	float   &halfLength0,
    float   &halfLength1
);


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_ATMOSPHERE


/*

> How do I get ellipsoid in the form the code
> takes input from my sphere which has radius r
> and location specified as OpenGL modelview
> matrix?

This discussion assumes that you have already transformed
your sphere into eye coordinates.

The GeneralEllipsoid class is based on the ellipsoid
representation

	X^T*A*X + B^T*X + C = 0
	
	A is a 3x3 symmetric matrix,
	B is a 3x1 vector,
	C is a scalar.

The superscript T means "transpose".  

The equation for a sphere is

	(X-K)^T*(X-K) = R^2.

	center K
	radius R

Multiplying the left-hand side and 
subtracting R^2 to the left produces

	X^T*I*X - 2*K^T*X + K^T*K - R^2 = 0

	I is the 3x3 identity matrix.
	
In setting up the GeneralEllipsoid object

	X^T*A*X + B^T*X + C = 0
	
	A is a 3x3 symmetric matrix,
	B is a 3x1 vector,
	C is a scalar.

you need

	A = I             3x3 Matrix: Identity
	B = -2*K          3x1 Vector: -2 * center 
	C = K^T*K - R^2   1   Scalar: center transpose ^ center - radius * radius ?



Since you are in eye coordinates, the 'eye' input to the
projector is the zero vector (0,0,0).  The view plane has
normal N = (0,0,1) and plane constant n, the near value
for the frustum.  That is, the plane is Dot(N,X) = n.

The returned GeneralEllipse object (a 2D object) is in the
form

	Y^T*A*Y + B^T*Y + C = 0
	
	(not the same A, B,C in the ellipsoid).

Matrix A is a symmetric 2x2 matrix,
B        is a 2x1 vector, and 
C        is a scalar.  

The 2D plane in which the ellipse is defined is the near plane.
The origin of that plane is the center of the frustum near face.

If you need to GeneralEllipse in factored form:
Complete the square,

	(Y-U)^t A (Y-U) = U^t A U - C where

	U = -0.5 A^{-1} B.  
	
Define M = A/(U^t A U - C).  
The ellipse is

	(Y-U)^t M (Y-U) = 1.  
	
Factor M = R^t D R (can do this with an eigensolver)
where R is orthonormal and D is diagonal with
positive // diagonal terms.

If Z = R(Y-U) = (z1,z2), and D = diag(d1,d2), then the
ellipse is

	1 = Z^t D Z = d1*z1^2+d2*z2^2.


The silhouette is a hyperbola whenever part
of the sphere is behind the viewer.  (E.g,
when the viewer is standing at the shore
looking out over the Pacific Ocean at the
horizon.)  It's a parabola when the sphere
is tangent to the view plane (the plane
containing the view point, with normal equal
to the view direction.)

*/

