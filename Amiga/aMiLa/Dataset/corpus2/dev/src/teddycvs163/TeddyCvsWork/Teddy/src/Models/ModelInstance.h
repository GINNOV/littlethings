
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
	\class	 ModelInstance
	\ingroup g_models
	\author  Timo Suoranta
	\brief	 Instance of Model
	\date	 1999, 2000, 2001

	This class is the base class for all objects which make
	up the Scene.

	ModelInstance is also baseclass for Light and Camera
*/


#ifndef TEDDY_MODELS_MODEL_INSTANCE_H
#define TEDDY_MODELS_MODEL_INSTANCE_H


#include "Maths/Matrix.h"
#include "Maths/Quaternion.h"
#include "Maths/Vector.h"
#include "MixIn/Named.h"
#include "MixIn/Options.h"
#include "SysSupport/Types.h"
#include "SDL_thread.h"
namespace Materials          { class Material;   };
namespace PhysicalComponents { class Projection; };
using namespace Materials;
using namespace Maths;
using namespace PhysicalComponents;


namespace Models {


class Mesh;
//class CollisionGroup;


#define MI_VISIBLE  (1L<<0L)


class ModelInstance : public Quaternion, public Named, public Options {
public:
	//	Constructors
	ModelInstance( const char *name, Mesh *mesh = NULL );
	virtual ~ModelInstance();
	
	//  Matrices
	Matrix            localToWorld        ();
	Matrix            worldToLocal        ();
	Matrix            getViewMatrix       ();
	Matrix            getModelMatrix      ( ModelInstance *camera );
	Matrix            getScaledModelMatrix( ModelInstance *camera );

	float             distanceTo     ( ModelInstance &obj );
	float             distanceTo     ( DoubleVector  &pos );
	Vector            vectorTo       ( ModelInstance &obj );	
	virtual void      setPosition    ( const double x, const double y, const double z ){
		position.v[0] = x;
		position.v[1] = y;
		position.v[2] = z;
	}
	virtual void      setPosition    ( const DoubleVector &v ){ position = v; }
	DoubleVector      getPosition    () const { return position; }

	void              translate      ( const DoubleVector &v ){ position += v; }
	void              roll           ( const float angle );
	void              pitch          ( const float angle );
	void              heading        ( const float angle );
	void              translate      ( const double x, const double y, const double z );
	void              foward         ( const double l );
	void              copyOrientation( const ModelInstance &other  );
	void              face           ( const ModelInstance &target );
	
	//  Renderable Interface
	virtual void      drawImmediate  ( Projection *p );
	
	//	ModelInstance interface
	Mesh             *getMesh      () const;
	void              setMesh      ( Mesh *m );
	virtual Material *getMaterial  ();
	void              setMaterial  ( Material *m );
	virtual float     getClipRadius() const;
	virtual float     getClipRange () const;

public:
	DoubleVector    position;          //!<  position

protected:
	Mesh           *mesh;              //!<  Mesh
	Material       *material;          //!<  Material property for this ModelInstance
};


};	//	namespace Models


#endif	//	TEDDY_MODELS_MODEL_INSTANCE_H

