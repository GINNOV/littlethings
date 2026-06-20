
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
	\class   Face
	\ingroup g_models
	\author  Timo Suoranta
	\brief   Ordered collection of vertices to define a polygon
	\date    1999, 2000, 2001

	Face Element is a polygon. The polygon is defined by edge vertices.
	Care must be taken to insert or append (and maintain) vertices 
	in counterclockwise (IIRC) order for backfaceculling to work.
*/


#ifndef TEDDY_MODELS_FACE_H
#define TEDDY_MODELS_FACE_H


#include "Models/Vertex.h"
#include "Models/Element.h"
#include "MixIn/Options.h"
#include "SysSupport/Types.h"
#include "SysSupport/StdList.h"


namespace Models {


#define FC_HAS_FACE_NORMAL    (1<<0)
#define FC_USE_FACE_NORMAL    (1<<1)
#define FC_USE_VERTEX_NORMALS (1<<2)


class Face : public Element, public Options {
public:
	Face();
    virtual ~Face();

	virtual void  draw      ( Projection *p );
	void          insert    ( const float x, const float y, const float z );
	void          insert    ( Vertex *v );
	void          append    ( const float x, const float y, const float z );
	void          append    ( Vertex *v );
	void          reverse   ();
	bool          contains  ( const Vertex *v ) const;

	void          setNormal ( const Vector *normal );
	void          makeNormal();
	const Vector &getNormal () const;
	void          smooth    ( float max_smoothing_angle );

//  vertices -member is public for easy access from Mesh texture coordinate code
public:
	list<Vertex*> vertices;

protected:
	Vector        normal;
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_FACE_H

