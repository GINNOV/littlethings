
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
#include "Materials/Light.h"
#include "Materials/Material.h"
#include "PhysicalComponents/Projection.h"
#include "Scenes/Camera.h"
#include "Scenes/PostElement.h"
#include "Scenes/Scene.h"
#include "SysSupport/Messages.h"
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <algorithm>
using namespace Graphics;
using namespace Materials;
using namespace PhysicalComponents;
using namespace std;


#if defined(_MSC_VER)
# define isnan _isnan
#else
# define isnan __isnan
#endif


namespace Scenes {


int Scene::culled = 0;
int Scene::drawn  = 0;


//!  Constructor
Scene::Scene( const char *name ):Named(name){
}


//!  Add new Light to Scene
void Scene::addLight( Light *l ){
	lights.push_back( l );
}


//!  Add new PostElement to Scene
void Scene::addPostElement( PostElement *p ){
	post_elements.push_back( p );
}


//!  Add new ModelInstance to Scene
void Scene::addInstance( ModelInstance *i ){
	instances.push_back( i );
}


/*!
	Update ModelInstances Meshes in scene
	This is required when any Material control property of Projection is changed.
*/
void Scene::update( Projection *p ){
//	Disabled; not needed in immediate drawing
/*	list<ModelInstance*>::iterator i_it = instances.begin();
	while( i_it != instances.end() ){
		(*i_it)->update( p );
		i_it++;
	}*/
}


//!  Return instance list
list<ModelInstance*> &Scene::getInstances(){
	return instances;
}


//!  Draw scene to OpenGL viewport
void Scene::draw( Camera *c, Projection *p ){
	View                           *view   = p->getView();
	list<Light        *>::iterator  l_it;
	list<PostElement  *>::iterator  p_it;
	list<ModelInstance*>::iterator  i_it;
	culled = 0;
	drawn  = 0;

	//	Apply lights 
	switch( p->getMaster()->getLighting() ){

	case RENDER_LIGHTING_COLOR:
		//	No lights appleid
		break;

	case RENDER_LIGHTING_CUSTOM:
		//	FIX Not yet implemented
		break;

	case RENDER_LIGHTING_PRIMARY_LIGHT_ONLY:
		//	Only OpenGL primary light is applied
		l_it = lights.begin();
		if( l_it != lights.end() ){
			(*l_it)->applyLight( p );
		}
		break;

	case RENDER_LIGHTING_FULL:
		//	FIX Not yet implemented; fall through
	case RENDER_LIGHTING_SIMPLE:
		//	Render all enabled OpenGL lights
		l_it = lights.begin();
		while( l_it != lights.end() ){
			(*l_it)->applyLight( p );
			l_it++;
		}
		break;


	default:
		//  Unknown lighting mode
		break;
	}

	//  Render objects
	i_it = instances.begin();
	while( i_it != instances.end() ){
		if( ((*i_it)->isEnabled(MI_VISIBLE)) && ( (*i_it) != c ) ){
/*		real r2 = (*i_it)->distanceSqr( Vector::NullVector );
		if( r2 < (*i_it)->getClipRange() ){*/
			if( c->cull( *i_it ) ){
				culled++;
			}else{
				(*i_it)->drawImmediate( p );
				drawn++;
			}
/*		}else{
			culled++;
		}*/
		}
		i_it++;
	}
}


//!  Draw scene to OpenGL viewport
void Scene::drawPostElements( Camera *c, Projection *p ){
	View                           *view   = p->getView();
	list<PostElement  *>::iterator  p_it;

	//  Render PostElements
	c->doProjection     ( p, false );
	c->doCamera         ( p, false );
	view->enable        ( BLEND );
	view->setShadeModel ( GL_SMOOTH );
	view->setPolygonMode( GL_FILL );
	view->setBlendFunc  ( GL_ONE, GL_ONE );
	view->disable       ( LIGHTING );
	view->disable       ( DEPTH_TEST );
	view->disable       ( CULL_FACE );
	view->disable       ( POLYGON_OFFSET );

	view->setProjectionMatrix( Matrix::Identity );
	view->setModelViewMatrix ( Matrix::Identity );

	p_it = post_elements.begin();
	while( p_it != post_elements.end() ){
		(*p_it)->drawImmediate( p );
		p_it++;
	}
}


//!  Return ModelInstance close to given view coordinates  3
ModelInstance *Scene::pickInstance( Camera *c, Projection *p ){
	ModelInstance                  *mi_lookup[1024];
	ModelInstance                  *pick = NULL;
	View                           *view;
	GLuint                          hits[1024];
	list<ModelInstance*>::iterator  i_it;

	glSelectBuffer( 1024, hits );

	(void)glRenderMode( GL_SELECT );
	view = p->getView();	
	p->pickState( true );
//	view->setPolygonMode( GL_FILL );
//	view->setPolygonMode( GL_FILL );
//	view->enable( CULL_FACE );
	glInitNames();
	glPushName( 0 );

	int name = 1;
	i_it     = instances.begin();

	int pick_drawn	= 0;
	int pick_culled = 0;
	int pick_hidden = 0;

	while( i_it != instances.end() ){
		ModelInstance *mi = (*i_it);
		mi_lookup[name] = mi;
		glLoadName( name++ );
//		real r2 = mi->distanceSqr( Vector::NullVector );
//		if( r2 < mi->getClipRange() ){
		if( mi->isEnabled(MI_VISIBLE) == true && (mi != c)){
/*			if( c->cull( mi ) ){
				pick_culled++;
			}else{
				mi->drawImmediate( p );
				pick_drawn++;
			}*/
			mi->drawImmediate( p );
			pick_drawn++;
		}else{
			pick_hidden++;
		}

		i_it++;
	}
	GLuint  num_hits = glRenderMode( GL_RENDER );
	GLuint *ptr      = hits;
	GLuint  names;
	GLuint  z_min;
	GLuint  z_max;
	GLuint  hit_name;
	GLuint  nearest = 0xffffffff;
	printf( "Pick: drawn %d culled %d hidden %d hits %d\n", pick_drawn, pick_culled, pick_hidden, num_hits );
	for( GLuint i=0; i<num_hits; i++ ){
		names = *ptr++;
		z_min = *ptr++;
		z_max = *ptr++;
		for( GLuint j=0; j<names; j++ ){
			hit_name = *ptr++;
			if( z_min<nearest ){
				nearest = z_min;
				pick	= mi_lookup[hit_name];
			}
		}		
	}
	p->pickState( false );
	if( pick != NULL ){
		printf( "Picked %s\n ", pick->getName() );
	}else{
		printf( "NULL pick\n" );
	}
	return pick;
}


};  //  namespace Scenes


