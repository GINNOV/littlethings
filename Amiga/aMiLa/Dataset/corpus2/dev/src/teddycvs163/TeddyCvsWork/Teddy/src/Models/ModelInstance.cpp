
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


#include "Materials/Material.h"
#include "Models/Mesh.h"
#include "Models/ModelInstance.h"
#include "PhysicalComponents/Projection.h"
#include "Scenes/Camera.h"
#include "SysSupport/StdMaths.h"
#include "SDL_thread.h"
#include <cstdio>
using namespace Graphics;
using namespace Materials;
using namespace Scenes;


namespace Models {


//!  Create new ModelInstance
/*!
	\param name Name for the new ModelInstance
	\param mesh Mesh defining shape for the new ModelInstance
*/
ModelInstance::ModelInstance( const char *name, Mesh *mesh ):
Quaternion(0,0,0,1),
Named     (name),
Options   (MI_VISIBLE),
position  (0,0,0),
mesh      (mesh),
material  (&Material::GRAY_75)
{
}


//!  Destructor
/*virtual*/ ModelInstance::~ModelInstance(){
}



//!  Return distance to another ModelInstance
/*!
	\param obj The other ModelInstance to which the distance is calculated
	\note Distance between object centers is calculated. The actual
	distance is usually a little less. You might want to substract
	clip radius of both ModelInstances in some cases from the given
	distance.
*/
float ModelInstance::distanceTo( ModelInstance &obj ){
	return (float)position.distance( obj.position );
}


//!  Return distance to other position
/*!
	\param pos Position in world cooridates to which distance is calculated
	\note  Distance is calculated from object center to the given point.
*/
float ModelInstance::distanceTo( DoubleVector &pos ){
	return (float)position.distance( pos );
}


//!  Return vector to other ModelInstance
/*!
	\param obj The other ModelInstance to which the delta vector is returned
*/
Vector ModelInstance::vectorTo( ModelInstance &obj ){
	return obj.position - position;
}


//!  Get ModelInstance Mesh
Mesh *ModelInstance::getMesh() const {
	return( mesh );
}


//! Set ModelInstance Mesh
/*!
	\param m The Mesh that will define the shape
	You must update() ModelInstance after setMesh()
	Erm, that is, if there was back end optimizer.
	Since there is none yet, this is not needed.
*/
void ModelInstance::setMesh( Mesh *m ){
	this->mesh = m;
}


//!  Copy orientation (attitude) from other ModelInstance
/*!
	\param other The source ModelInstance of the orientation
*/
void ModelInstance::copyOrientation( const ModelInstance &other ){
	this->v[0] = other.v[0];
	this->v[1] = other.v[1];
	this->v[2] = other.v[2];
	this->v[3] = other.v[3];
}


//!  Return the effective material used for this ModelInstance
/*!
	\note Each ModelInstance may set material, but it does not have to set it.
	If ModelInstance has not set material, material of the Mesh is used when
	drawing. In such case this method returns the material of the Mesh.
*/
/*virtual*/ Material *ModelInstance::getMaterial(){
	if( material != NULL ){
		return material;
	}else{
		if( mesh != NULL ){
			return mesh->getMaterial();
		}else{
			return NULL;
		}
	}

}


//!  Set ModelInstance Material
/*!
	\param m Material for this ModelInstance
*/
void ModelInstance::setMaterial( Material *m ){
	this->material = m;
}


//!  Wrapper for mesh->getClipRadius()
/*virtual*/ float ModelInstance::getClipRadius() const {
	if( mesh != NULL ){
		return mesh->getClipRadius();
	}else{
		return 0;
	}
}


//!  Wrapper for mesh->getClipRange()
/*!
	\warning Mesh::getClipRange() is not implemented well at the moment
*/
/*virtual*/ float ModelInstance::getClipRange() const {
	if( mesh != NULL ){
		return mesh->getClipRange();
	}else{
		return 0;
	}
}


//!	 Drawing the instance.
/*!
	\warning Current implementation does not do any optimization.
	\note    No displaylists or vertex arrays are used.
*/
/*virtual*/ void ModelInstance::drawImmediate( Projection *p ){
	if( (p==NULL) || isDisabled(MI_VISIBLE) ){
		return;
	}

	//	There are several options for
	//	modelview matrices for objects:

	//	- localToWorld()		  Simplest no tricks
	//	- getModelMatrix()		  Works as if camera was always in origo
	//	- getScaledModelMatrix()  Additional scaling such that all objects
	//							  fit into depth range. Causes objects to
	//							  overlap badly :/

//  need origo camera fix
//	p->getCamera()->doObjectMatrix( p, getModelMatrix( p->getCamera()) );
	p->getCamera()->doObjectMatrix( p, localToWorld() );
	mesh->drawImmediate( p, material );
}


//!  Concatenate roll
/*!
	\param angle Rotation angle in degrees

	ModelInstance is rotated around roll axis (Z) by angle degrees.
*/
void ModelInstance::roll( const float angle ){
	rotate( getViewAxis(),	rads(angle) );
}


//!  Concatenate pitch
/*!
	\param angle Rotation angle in degress

	ModelInstance is rotated around pitch axis (X) by angle degrees.
*/
void ModelInstance::pitch( const float angle ){
	rotate( getRightAxis(),  rads(angle) );
}


//!  Concatenate heading
/*!
	\param angle Rotation angle in degrees

	ModelInstance is rotated around heading axis (Y) by angle degrees.
*/
void ModelInstance::heading( const float angle ){
	rotate( getUpAxis(),  rads(angle) );
}


//!  Move ModelInstance foward
/*!
	\param len Amount of translation

	ModelInstance is translated along its view axis (Z)
	by len units.
*/
void ModelInstance::foward( const double len ){
	translate( getViewAxis() * len );
}


//!  Translate ModelInstance by (x,y,z)
/*!
	\param x Translation in world X axis
	\param y Translation in world Y axis
	\param z Translation in world Z axis

	ModelInstance is translated in world coordinates by (x, y, z).
*/
void ModelInstance::translate( const double x, const double y, const double z ){
	translate( DoubleVector( x, y, z ) );
}

void ModelInstance::face( const ModelInstance &target ){
/*	Vector tpos   =	target->getPosition();
	Vector cpos   = this->getPosition();
	Vector tview  = target->getViewAxis ();
	Vector tup    = target->getUpAxis   ();
	Vector tright = target->getRightAxis();
	Vector cview  = getViewAxis ();
	Vector cup    = getUpAxis   ();
	Vector cright = getRightAxis();

	delta .Normalize();
	float  v = cview  | delta;
	float  u = cup    | delta;
	float  r = cright | delta;
*/
}


};	//	namespace Models

