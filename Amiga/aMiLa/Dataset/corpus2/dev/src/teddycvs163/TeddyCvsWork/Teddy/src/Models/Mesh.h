
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
	\class   Mesh
	\ingroup g_models
	\author  Timo Suoranta
	\brief   Mesh maintains modeling and rendering data for part of Mesh Model
	\bug     Destructors are missing
	\bug     There is no level of detail support.
	\date    1999, 2000, 2001

	Mesh maintains modeling data for an object.
	Mesh is collection of Elements and sub-meshes.
	Each mesh can have individual Material properties.

	The level of detail support should be added.
*/


#ifndef TEDDY_MODELS_MESH_H
#define TEDDY_MODELS_MESH_H


#include "Maths/Vector.h"
#include "MixIn/Named.h"
#include "MixIn/Options.h"
#include "SysSupport/StdList.h"
namespace Materials          { class Material; };
namespace PhysicalComponents { class Projection; };
using namespace Materials;
using namespace Maths;
using namespace PhysicalComponents;


#define TEXTURE_AXIS_X 0
#define TEXTURE_AXIS_Y 1
#define TEXTURE_AXIS_Z 2


namespace Models {


class Element;
class Face;
class Vertex;


#define MS_SELF_VISIBLE     (1ul<<0ul)
#define MS_RECURS_VISIBLE   (1ul<<1ul)
#define MS_RECURS_MATERIALS (1ul<<2ul)
#define MS_DEFAULT          (MS_SELF_VISIBLE|MS_RECURS_VISIBLE)


class Mesh : public Named, public Options {
public:
	Mesh();
	Mesh( char *name, unsigned long options = MS_DEFAULT );
	Mesh( const char *name, unsigned long options = MS_DEFAULT );
	Mesh( const char *name, Material *material, unsigned long options = MS_DEFAULT );
    virtual ~Mesh();

	virtual void   drawImmediate   ( Projection *p, Material *instance_material );
	virtual void   drawNoMaterial  ( Projection *p );

	//  Mesh Interface
	virtual void   beginElements   ( Projection *p );
	virtual void   drawElements    ( Projection *p );
	virtual void   endElements     ( Projection *p );
	virtual void   debug           ( unsigned long command, void *data );

	void           insert          ( Mesh    *c );
	void           insert          ( Element *e );
	virtual void   setParent       ( Mesh    *m );
	Mesh          *getParent       () const;
	void           setClipRadius   ( float r );
	float          getClipRadius   () const;
	float          getClipRange    () const;
	void           setMaterial     ( Material *m );
	Material      *getMaterial     ();

	//  Smoothing and texture mapping
	void           smooth                           ( float max_smoothing_angle );
	void           makePlanarTextureCoordinates     ( Vector center, Vector size, int axis );
	void           makeCylindricalTextureCoordinates( Vector center, Vector size, int axis );
	void           makeSphericalTextureCoordinates  ( Vector center, Vector size, int axis );
	void           makeCubicTextureCoordinates      ( Vector center, Vector size );
	void           setTextureCoordinate             ( Face *f, list<Vertex*>::iterator v_it, float u, float v );

public:
	list<Mesh*>      submeshes;       //!<  Hierarchial meshes have submeshes 

protected:
	Mesh            *parent;          //!<  Parent of this mesh
	Material        *material;        //!<  Material property for this Mesh
	list<Element*>   elements;        //!<  A single mesh is set of elements
	float            clip_radius;     //!<  For view volume clipping

protected:
	static Material *default_material;
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_MESH_H

