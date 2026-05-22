
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


#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Models/Element.h"
#include "Models/Face.h"
#include "Models/Mesh.h"
#include "PhysicalComponents/Projection.h"
#include "Scenes/Camera.h"
#include "SysSupport/Messages.h"
#include <cstdio>
using namespace Graphics;
using namespace Materials;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Models {


//!  Default Constructor
Mesh::Mesh():
Named      (""),
Options    (MS_SELF_VISIBLE|MS_RECURS_VISIBLE),
parent     (NULL),
material   (&Material::GRAY_75),
clip_radius(0)
{
}


//!  Constructor with name
/*!
	\param name Name for the Mesh
*/
Mesh::Mesh( char *name, unsigned long options ):
Named      (name),
Options    (options),
parent     (NULL),
material   (&Material::GRAY_75),
clip_radius(0)
{
}


//!  Constructor with name
/*!
	\param name Name for the Mesh
*/
Mesh::Mesh( const char *name, unsigned long options ):
Named      (name),
Options    (options),
parent     (NULL),
material   (&Material::GRAY_75),
clip_radius(0)
{
}


//!  Constructor with name and default material
/*!
	\param name Name for the Mesh
	\param material Material for the Mesh
*/
Mesh::Mesh( const char *name, Material *material, unsigned long options ):
Named      (name),
Options    (options),
parent     (NULL),
material   (material),
clip_radius(0)
{
}


//!  Destructor
/*virtual*/ Mesh::~Mesh(){
}


//!  Set Mesh parent
/*!
	\param m Mesh which is set as parent for this Mesh
*/
/*virtual*/ void Mesh::setParent( Mesh *m ){
	this->parent = m;
}


//!  Get Mesh parent
Mesh *Mesh::getParent() const {
	return this->parent;
}


//!  Insert submesh to Mesh
/*!
	\param m Mesh which is added as submesh to this Mesh
	\note Parent of Mesh m is set to this Mesh
	\warning Using single mesh in multiple parents is not supported yet.
*/
void Mesh::insert( Mesh *m ){
	submeshes.push_back( m );
	m->setParent( this );
}


//!  Insert Element to Mesh
/*!
	\param e Element which is added to this Mesh
*/
void Mesh::insert( Element *e ){
	elements.push_back( e );
}


//!  Draw Immediate
/*virtual*/ void Mesh::drawImmediate( Projection *p, Material *instance_material ){
	if( isEnabled(MS_SELF_VISIBLE) == true ){
		if( instance_material != NULL ){
			p->materialApply( instance_material );
		}else{
			p->materialApply( this->material );
		}
		while( p->materialPass() ){
			drawElements( p );
		}
	}

	if( isEnabled(MS_RECURS_VISIBLE) == true ){
		list<Mesh*>::iterator m_it = submeshes.begin();
		while( m_it != submeshes.end() ){
			if( isEnabled(MS_RECURS_MATERIALS) ){
				(*m_it)->drawImmediate( p, instance_material );
			}else{
				(*m_it)->drawImmediate( p, NULL );
			}
			m_it++;
		}
	}
}

/*virtual*/ void Mesh::drawNoMaterial( Projection *p ){
	if( isEnabled(MS_SELF_VISIBLE) == true ){
		drawElements( p );
	}

	if( isEnabled(MS_RECURS_VISIBLE) == true ){
		list<Mesh*>::iterator m_it;
		m_it = submeshes.begin();
		while( m_it != submeshes.end() ){
			(*m_it)->drawNoMaterial( p );
			m_it++;
		}
	}
}


//!  Mesh Interface - Begin Elements - Pre drawing code
/*virtual*/ void Mesh::beginElements( Projection *p ){
}


//!  Mesh Interface - Draw elements
/*virtual*/ void Mesh::drawElements( Projection *p ){
	beginElements( p );

	list<Element*>::const_iterator e_it = elements.begin();
	while( e_it!=elements.end() ){
		(*e_it)->draw( p );
		e_it++;
	}

	endElements( p );
}


//!  Mesh Interface - End Elements - Post drawing code
/*virtual*/ void Mesh::endElements( Projection *p ){
}


//!  Get Mesh material
Material *Mesh::getMaterial(){
	return material;
}

						   
//!  Set Mesh Material
void Mesh::setMaterial( Material *m ){
	this->material = m;
}


//!  Get Mesh clipping radius
float Mesh::getClipRadius() const {
	return clip_radius;
}

						   
//!  Set Mesh clipping radius
void Mesh::setClipRadius( float r ){
	this->clip_radius = r;
}


//!  Get Mesh Clipping Range
float Mesh::getClipRange() const {
	float cr = this->clip_radius;
	//	FIX Below is very bad guessing!
	return cr*1000.0f;
}


//!  Debugging information
void Mesh::debug( unsigned long command, void *data ){ 
	debug_msg( "Mesh %s, %d elements\n", name, elements.size() );

	list<Mesh*>::const_iterator m_it;
	m_it = submeshes.begin();
	while( m_it != submeshes.end() ){
		(*m_it)->debug( 0, NULL );
		m_it++;
	}
}


//!  Average shared normals for vertices. Non-recursive.
void Mesh::smooth( float max_smoothing_angle ){
	list<Element*>::iterator  f_it;
	Face                     *face;
	int                       face_smooth = 0;

	//  Ror each Face element, smooth it.
	f_it = elements.begin();
	while( f_it != elements.end() ){
		face = dynamic_cast<Face*>(*f_it);
		if( face != NULL ){
			face->smooth( max_smoothing_angle );
			face_smooth++;
		}
		f_it++;
	}

	vert_debug_msg( "Faces smoothed        : %d", face_smooth );
}


};	//	namespace Models

