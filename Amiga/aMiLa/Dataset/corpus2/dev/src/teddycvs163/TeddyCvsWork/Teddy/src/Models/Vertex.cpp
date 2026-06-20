
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


#include "PhysicalComponents/Projection.h"
#include "Models/Vertex.h"
#include "Models/Face.h"
#include "SysSupport/Messages.h"


using namespace Graphics;


namespace Models {


//!  Default constructor
Vertex::Vertex():
Options     ( 0          ),
parent      ( NULL       ),
vert        ( 0, 0, 0    ),
normal      ( 0, 1, 0    ),
color       ( 1, 1, 1, 1 ),
texturecoord( 0, 0, 0    )
{
}


/*!
	Vertex - Vertex Inheritance constructor
	Notice that Face cross-reference -list is not copied
	Notice how Parent is set
*/
Vertex::Vertex( Vertex *v ):
Options     ( VX_HAS_PARENT | VX_USE_PARENT_ALL ),
parent      ( v          ),
vert        ( 0, 0, 0    ),
normal      ( 0, 1, 0    ),
color       ( 1, 1, 1, 1 ),
texturecoord( 0, 0, 0    )
{
}


/*!
	Vertex - Vertex copy constructor
	Notice that Face cross-reference -list is not copied
	Notice how Parent is set
	Notice that accessor methods are not used for some members
*/
Vertex::Vertex( Vertex &v ):
Options     ( v.getOptions() ),
parent      ( v.getParent () ),
vert        ( v.vert         ),
normal      ( v.normal       ),
color       ( v.color        ),
texturecoord( v.texturecoord )
{
}


//!  Vertex - Vector Copy-constructor
Vertex::Vertex( const Vector &v ):
Options     ( VX_HAS_VERTEX | VX_USE_THIS_VERTEX ),
parent      ( NULL       ),
vert        ( v          ),
normal      ( 0, 1, 0    ),
color       ( 1, 1, 1, 1 ),
texturecoord( 0, 0, 0    )
{
}


//!  Vertex Component constructor
Vertex::Vertex( const float x, const float y, const float z):
Options     ( VX_HAS_VERTEX | VX_USE_THIS_VERTEX ),
parent      ( NULL       ),
vert        ( x, y, z    ),
normal      ( 0, 1, 0    ),
color       ( 1, 1, 1, 1 ),
texturecoord( 0, 0, 0    )
{
}


/*virtual*/ Vertex::~Vertex(){
}


//!  Flip the vertex. Notice that normal is not changed by this routine
void Vertex::neg(){
	vert.v[0] = -vert.v[0];
	vert.v[1] = -vert.v[1];
	vert.v[2] = -vert.v[2];
}


void Vertex::setColor( const Color &color ){
	enableOptions ( VX_USE_THIS_COLOR | VX_HAS_COLOR );
	disableOptions( VX_USE_PARENT_COLOR );
	this->color  = color;
}


void Vertex::setNormal( const Vector &normal ){
	enableOptions ( VX_USE_THIS_NORMAL | VX_HAS_NORMAL );
	disableOptions( VX_USE_PARENT_NORMAL );
	this->normal  = normal;
}


void Vertex::addNormal( const Vector &add ){
	this->normal += add;
}


void Vertex::normNormal(){
	if( isDisabled(VX_HAS_NORMAL) ){
		debug_msg( "Vertex has no normal which to normalize" );
		return;
	}

	enableOptions ( VX_USE_THIS_NORMAL | VX_HAS_NORMAL );
	disableOptions( VX_USE_PARENT_NORMAL );
	normal.normalize();

	//  Check that normalize worked
	float len = normal.magnitude();
	if( len > 1.1 || len < 0.9 ){
		debug_msg( "Bad normal" );
	}
}


//!  Set vertex texture coordinate
void Vertex::setTexture( const Vector &texture ){
	enableOptions ( VX_USE_THIS_TEXTURE | VX_HAS_TEXTURE );
	disableOptions( VX_USE_PARENT_TEXTURE );
	this->texturecoord  = texture;
}


//!  Sharing lists are only stored in the root
void Vertex::addFace( Face *face ){
	getRoot()->faces.push_back( face );
}


//!  Return the share list of this vertex
list<Face*> &Vertex::getFaces(){
	return getRoot()->faces;
}


//!  Return the effective ancestor of this vertex. Recursively seeks for parent.
Vertex *Vertex::getRoot(){
	Vertex *p = getParent();
	if( p==NULL ){
		return this;
	}else{
		return p->getRoot();
	}
}


//!  Return the effective parent of this vertex
Vertex *Vertex::getParent(){
	return this->parent;
}


//!  Return the effective vertex position of this vertex
Vector &Vertex::getVertex(){
	if( isEnabled(VX_USE_THIS_VERTEX|VX_HAS_VERTEX) ){
		return this->vert;
	}else if( isEnabled(VX_USE_PARENT_VERTEX|VX_HAS_PARENT) ){
		return parent->getVertex();
	}else{
		vert_debug_msg( "Vertex not found in vertex" );
		return this->vert;
	}
}

//!  Return the effective vertex color
Color &Vertex::getColor(){
	if( isEnabled(VX_USE_THIS_COLOR|VX_HAS_COLOR) ){
		return this->color;
	}else if( isEnabled(VX_USE_PARENT_COLOR|VX_HAS_PARENT) ){
		return parent->getColor();
	}else{
		vert_debug_msg( "Color not found in vertex" );
		return this->color;
	}
}


//!  Return the effective vertex normal coordinate
Vector &Vertex::getNormal(){
	if( isEnabled(VX_USE_THIS_NORMAL|VX_HAS_NORMAL) ){
		return this->normal;
	}else if( isEnabled(VX_USE_PARENT_NORMAL|VX_HAS_PARENT) ){
		return parent->getNormal();
	}else{
		vert_debug_msg( "Normal not found in vertex" );
		return this->normal;
	}
}


//!  Return vertex texture coordinate
Vector &Vertex::getTexture(){
	if( isEnabled(VX_USE_THIS_TEXTURE|VX_HAS_TEXTURE) ){
		return this->texturecoord;
	}else if( isEnabled(VX_USE_PARENT_TEXTURE|VX_HAS_PARENT) ){
		return parent->getTexture();
	}else{
		vert_debug_msg( "Texture coordinates not found in Vertex" );
		return this->texturecoord;
	}
}


/*!	Draw.

	Since any feature may or may not be inherited
	from parent, all settings are handled in sub-methods.

	Does NOT include begin(), so Vertex can be used with
	any OpenGL primitives, but needs begin() outside.
*/
void Vertex::draw( Projection *p ){
	applyColor  ( p );
	applyNormal ( p );
	applyTexture( p );
	applyVertex ( p );
}


/*virtual*/ void Vertex::applyColor( Projection *p ){
	if( isEnabled(VX_USE_THIS_COLOR|VX_HAS_COLOR) ){
		p->color( color );
	}else if( isEnabled(VX_USE_PARENT_COLOR|VX_HAS_PARENT) ){
//		vert_debug_msg( "Using parent color" );
		parent->applyColor( p );
	}else{
//		vert_debug_msg( "This vertex has no color" );
	}
}


/*virtual*/ void Vertex::applyNormal( Projection *p ){
	if( isEnabled(VX_USE_THIS_NORMAL|VX_HAS_NORMAL) ){
		p->normal( normal.v[0], normal.v[1], normal.v[2] );
	}else if( isEnabled(VX_USE_PARENT_NORMAL|VX_HAS_PARENT) ){
		vert_debug_msg( "Using parent normal" );
		parent->applyNormal( p );
	}else{
		debug();
		vert_debug_msg( "This vertex has no normal" );
	}
}


/*virtual*/ void Vertex::applyTexture( Projection *p ){
	if( isEnabled(VX_USE_THIS_TEXTURE|VX_HAS_TEXTURE) ){
		p->texture( texturecoord.v[0], texturecoord.v[1] );
	}else if( isEnabled(VX_USE_PARENT_TEXTURE|VX_HAS_PARENT) ){
//		vert_debug_msg( "Using parent texture" );
		parent->applyTexture( p );
	}else{
//		vert_debug_msg( "This vertex has no texture" );
	}
}


/*virtual*/ void Vertex::applyVertex( Projection *p ){
	if( isEnabled(VX_USE_THIS_VERTEX|VX_HAS_VERTEX) ){
		p->vertex( vert.v[0], vert.v[1], vert.v[2] );
	}else if( isEnabled(VX_USE_PARENT_VERTEX|VX_HAS_PARENT) ){
		//vert_debug_msg( "Using parent vertex" );
		parent->applyVertex( p );
	}else{
		debug();
		vert_debug_msg( "This vertex has no vertex" );
	}
}


/*virtual*/ void Vertex::debug(){
	if( isEnabled(VX_HAS_PARENT        ) ) vert_debug_msg("VX_HAS_PARENT        ");
	if( isEnabled(VX_HAS_VERTEX        ) ) vert_debug_msg("VX_HAS_VERTEX        ");
	if( isEnabled(VX_HAS_NORMAL        ) ) vert_debug_msg("VX_HAS_NORMAL        ");
	if( isEnabled(VX_HAS_COLOR         ) ) vert_debug_msg("VX_HAS_COLOR         ");
	if( isEnabled(VX_HAS_TEXTURE       ) ) vert_debug_msg("VX_HAS_TEXTURE       ");

	if( isEnabled(VX_USE_THIS_VERTEX   ) ) vert_debug_msg("VX_USE_THIS_VERTEX   ");
	if( isEnabled(VX_USE_THIS_NORMAL   ) ) vert_debug_msg("VX_USE_THIS_NORMAL   ");
	if( isEnabled(VX_USE_THIS_COLOR    ) ) vert_debug_msg("VX_USE_THIS_COLOR    ");
	if( isEnabled(VX_USE_THIS_TEXTURE  ) ) vert_debug_msg("VX_USE_THIS_TEXTURE  ");

	if( isEnabled(VX_USE_PARENT_VERTEX ) ) vert_debug_msg("VX_USE_PARENT_VERTEX ");
	if( isEnabled(VX_USE_PARENT_NORMAL ) ) vert_debug_msg("VX_USE_PARENT_NORMAL ");
	if( isEnabled(VX_USE_PARENT_COLOR  ) ) vert_debug_msg("VX_USE_PARENT_COLOR  ");
	if( isEnabled(VX_USE_PARENT_TEXTURE) ) vert_debug_msg("VX_USE_PARENT_TEXTURE");
}


};  //  namespace Models

