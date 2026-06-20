
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


#include "Models/ModelInstance.h"


namespace Models {


/*!
	Simple transformation matrix from world coordinates
	to local coordinates. No tricks.

	worldToLocal() is usually used for camera matrices.
*/
Matrix ModelInstance::worldToLocal(){
	Matrix m = *this;
	float  x = (float) -position.v[0];
	float  y = (float) -position.v[1];
	float  z = (float) -position.v[2];

	m.translate( x, y, z );
	return m;
}


/*!
	Simple transformation matrix from local coordinates
	to world coordinates. No tricks.

	localToWolrd() is usually used for model matrices.
*/
Matrix ModelInstance::localToWorld(){
	Matrix r = *this;
	Matrix t;
	r.transpose();
	float  x = (float) position.v[0];
	float  y = (float) position.v[1];
	float  z = (float) position.v[2];
	t.translateMatrix( x, y, z );
	return t * r;
}


/*!
 Camera matrix which only contains rotations;
 translations are expexted to be applied into
 objects' model matrices instead.
*/
Matrix ModelInstance::getViewMatrix(){
	// Don't use the normal view matrix because it causes precision
	// problems if the camera is too far away from the origin.
	// Instead, pretend the camera is at the origin and offset all
	// model matrices by subtracting the camera's position.
	Matrix m = *this;
	return m;
}


/*!
	Return model matrix, which works by applying camera positioning
	into objects' model matrices
*/
Matrix ModelInstance::getModelMatrix( ModelInstance *camera ){
	Matrix m;
	m.modelMatrix( *this, position-camera->position );
	return m;
}


/*!
	Return scaled model matrix. Makes all objects fit to depth range, but objects
	might overlap in z buffer because of this
*/
Matrix ModelInstance::getScaledModelMatrix( ModelInstance *camera ){
	// This code scales the planet's size and distance to the camera
	// down when it's too far away.
	// This solves a problem with many video card drivers where objects
	// too far away aren't rendering properly
	// It also alleviates the Z-buffer precision problem caused by having
	// your near and far clipping planes too far apart.
#	define MAX_DISTANCE    256.0			  // Distance to desired far clipping plane
#	define MAX_DISCERNABLE (512.0f*512.0f)	  // Beyond this distance, everything is rendered at MAX_DISTANCE
#	define HALF_MAX 	  (MAX_DISTANCE*0.5)  // Everything between HALF_MAX and MAX_DISCERNABLE is scaled exponentially between HALF_MAX and MAX_DISTANCE
	Matrix		 mat      = getModelMatrix( camera );
	DoubleVector vec      = position - camera->position;
	double		 distance = vec.magnitude();

	if( distance > HALF_MAX ){
		vec			  /= distance;
		double factor  = MAX_DISTANCE;

		if( distance < MAX_DISCERNABLE ){
			factor = (HALF_MAX + HALF_MAX * (1.0f - exp((HALF_MAX - distance) / MAX_DISCERNABLE)));
		}
		vec *= factor;
		mat.m[3][0]  = (float)vec.v[0];
		mat.m[3][1]  = (float)vec.v[1];
		mat.m[3][2]  = (float)vec.v[2];
		factor /= distance;
		mat.scale( (float)factor, (float)factor, (float)factor );
	}
	return mat;
}


};  //  namespace Models

