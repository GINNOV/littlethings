
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
	\class   Vertex
	\ingroup g_models
	\author  Timo Suoranta
	\brief   Defines one point of polygon or line
	\date    1999, 2000, 2001

	Vertex is the most basic primitive for building object models.
	This class attempts to provide flexible vertex by coupling
	possible vertex features into a single class. Additionally
	vertices can be arranged into hieararchy so that one vertex
	can inherit some (or all) features from its parent. By using
	feature inheritance it is possible eg. share the vertex
	coordinate but specify different normal, or different texture
	coordinate.
*/


#ifndef TEDDY_MODELS_VERTEX_H
#define TEDDY_MODELS_VERTEX_H


#if defined(_MSC_VER)
#pragma warning(disable:4521)  //  multiple copy constructors defined (!)
#endif


#include "Graphics/Color.h"
#include "Maths/Vector.h"
#include "MixIn/Options.h"
#include "Models/Element.h"
#include "SysSupport/StdList.h"
using namespace Graphics;
using namespace Maths;


namespace Models {


class Face;


//!<  Options features for Vertex:
#define VX_HAS_PARENT         (1L<< 0L)  //    1
#define VX_HAS_VERTEX         (1L<< 1L)  //    2
#define VX_HAS_NORMAL         (1L<< 2L)  //    4
#define VX_HAS_COLOR          (1L<< 3L)  //    8
#define VX_HAS_TEXTURE        (1L<< 4L)  //   16

#define VX_USE_THIS_VERTEX    (1L<< 5L)  //   32
#define VX_USE_THIS_NORMAL    (1L<< 6L)  //   64
#define VX_USE_THIS_COLOR     (1L<< 7L)  //  128
#define VX_USE_THIS_TEXTURE   (1L<< 8L)  //  256

#define VX_USE_PARENT_VERTEX  (1L<< 9L)
#define VX_USE_PARENT_NORMAL  (1L<<10L)
#define VX_USE_PARENT_COLOR   (1L<<11L)
#define VX_USE_PARENT_TEXTURE (1L<<12L)

#define VX_USE_PARENT_ALL   \
	VX_USE_PARENT_VERTEX  | \
	VX_USE_PARENT_NORMAL  | \
	VX_USE_PARENT_COLOR   | \
	VX_USE_PARENT_TEXTURE
		

class Vertex : public Element, public Options {
public:
	Vertex();
	Vertex( Vertex *v );
	Vertex( Vertex &v );
	Vertex( const Vertex &v );
	Vertex( const Vector &v );
	Vertex( const float x, const float y, const float z );
    virtual ~Vertex();

public:
	virtual void  debug       ();
	virtual void  draw        ( Projection *p );
	virtual void  applyColor  ( Projection *p );
	virtual void  applyNormal ( Projection *p );
	virtual void  applyTexture( Projection *p );
	virtual void  applyVertex ( Projection *p );

	void          neg         ();
	void          setParent   ( const Vertex &vert    );
	void          setVertex   ( const Vector &vert    );
	void          setColor    ( const Color  &color   );
	void          setNormal   ( const Vector &normal  );
	void          setTexture  ( const Vector &texture );
	void          addNormal   ( const Vector &add     );
	void          normNormal  ();
	void          removeNormal();
	Vertex       *getRoot     ();
	Vertex       *getParent   ();
	Vector       &getVertex   ();
	Color        &getColor    ();
	Vector       &getNormal   ();
	Vector       &getTexture  ();
	list<Face*>  &getFaces    ();
	void          addFace     ( Face *face );

	//  Basic operations on vertex
	Vertex &operator+=( Vertex &v ){ vert += v.getVertex(); return *this; };
	Vertex &operator-=( Vertex &v ){ vert -= v.getVertex(); return *this; };
	Vertex &operator*=( float   k ){ vert *= k; return *this; };
	Vertex &operator/=( float   k ){ vert /= k; return *this; };

	Vertex &operator+=( const Vertex &v ){ vert += v.vert; return *this; };
	Vertex &operator-=( const Vertex &v ){ vert -= v.vert; return *this; };
//	Vertex &operator*=( const float   k ){ vert *= k; return *this; };
//	Vertex &operator/=( const float   k ){ vert /= k; return *this; };

	Vertex  operator+( Vertex &v ){ return new Vertex(vert+v.vert); };
	Vertex  operator-( Vertex &v ){ return new Vertex(vert-v.vert); };
	Vertex  operator*( float   k ){ return new Vertex(vert*k     ); };
	Vertex  operator/( float   k ){ return new Vertex(vert/k     ); };

	Vertex  operator+( const Vertex &v ){ return new Vertex(vert+v.vert); };
	Vertex  operator-( const Vertex &v ){ return new Vertex(vert-v.vert); };
//	Vertex  operator*( const float   k ){ return new Vertex(vert*k            ); };
//	Vertex  operator/( const float   k ){ return new Vertex(vert/k            ); };

	//  Flip code; FIX if parent vertex is being used, copy it and only change the copy
	void flipX    (){ getVertex().v[0] *= -1; };
	void flipY    (){ getVertex().v[1] *= -1; };
	void flipZ    (){ getVertex().v[2] *= -1; };

	//  Length code; FIX if parent vertex is being used, copy it and only change the copy
	void  normalize(){ getVertex().normalize();        };
	float magnitude(){ return getVertex().magnitude(); };

public:
	list<Face*>   faces;         //!<  Cross-reference

protected:
	Vertex       *parent;        //!<  Original shared vertex
	Vector        vert;          //!<  The actual vertex coordinates
	Vector        normal;        //!<  Normal coordinates
	Color         color;         //!<  Color
	Vector        texturecoord;  //!<  Texture coordinates
};


};  //  namespace Models


#endif  //  TEDDY_MODELS_VERTEX_H


