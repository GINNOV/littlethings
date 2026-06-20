
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


#include "config.h"
#include "Graphics/Texture.h"
#include "Graphics/View.h"
#include "Materials/Material.h"
#include "PhysicalComponents/EventListener.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Projection.h"
#include "PhysicalComponents/WindowFrame.h"
#include "Scenes/Camera.h"
#include "SysSupport/Messages.h"
#include <cstdio>
using namespace Graphics;
using namespace Scenes;


namespace PhysicalComponents {


#ifndef MIN
#define MIN(a,b) ((a)<(b)?(a):(b))
#endif
#ifndef MAX
#define MAX(a,b) ((a)>(b)?(a):(b))
#endif


//! Constructor
Projection::Projection( const char *name, Camera *camera )
:
Area           (name),
Options        (PR_CLEAR|PR_CLIP)
{
	this->ordering        = separate_self;  //  Separate drawSelf() invocation
	this->camera          = camera;
	this->active_material = NULL;
	this->active_texture  = NULL;
	this->clear_color     = Color::BLACK;
	this->master_material = new Material( "Projection master material", RENDER_OPTION_ALL_M );
	this->master_material->setMode    ( RENDER_MODE_FILL_OUTLINE );
	this->master_material->setLighting( RENDER_LIGHTING_SIMPLE );
	this->master_material->setAmbient ( Color::BLACK   );
	this->master_material->setDiffuse ( Color::GRAY_50 );
	this->master_material->setBorder  ( Color::BLACK   );
	this->setSelect( RENDER_OPTION_ALL_M );
	this->constraint = new LayoutConstraint();
	constraint->parent_x_fill_relative = 1;
	constraint->parent_y_fill_relative = 1;
}


//!  Destructor
/*virtual*/ Projection::~Projection(){
}


//!  Area Input Interface - Get Hit Area, NULL if none
/*virtual*/ Area *Projection::getHit( const int x, const int y ){
	EventListener *e = dynamic_cast<EventListener*>( this );
	if( (x >= viewport[0]) &&
		(x <= viewport[2]) &&
		(y >= viewport[1]) &&
		(y <= viewport[3]) &&
		(e != NULL       )    )
	{
		return this;
	}
	return NULL;
}


//!  Apply Material to Projection.
void Projection::materialApply( Material *m ){
	render_pass       = 0;
	render_pass_count = 1;

	if( isEnabled(PR_PICK) ){
		return;
	}

	if( m == NULL ){
		mat_debug_msg( "NULL material\n" );
	}

	if( (active_material==m) || (m==NULL) ){
		mat_debug_msg( "already active material %s reset\n", m->getName() );
		return;
	}
	active_material = m;

	mat_debug_msg( "Activating material %s\n", m->getName() );

	materialReapplyActive();
}


//!  Apply material
void Projection::materialReapplyActive(){
	Material *m = this->active_material;

	Uint8 l = MIN( m->getLighting(), master_material->getLighting() );
	if( l >= RENDER_LIGHTING_PRIMARY_LIGHT_ONLY ){
		view->enable( LIGHTING );
	}else{
		view->disable( LIGHTING );
	}

	//	Apply rendering options
	Uint32 mask_select = m->getOptions() & render_options_selection_mask;
	Uint32 mask_enable = mask_select & master_material->getOptions();
	for( int i=0; i<32; i++ ){
		bool select = (mask_select>>i) & 1 == 1;  // true if select material, false if select projection
		bool enable = (mask_enable>>i) & 1 == 1;  // true if enabled, false if disabled
		Material *selected_material;
		if( select ){
			selected_material = m;
		}else{
			selected_material = master_material;
		}

		if( getFeature(i) != 0 ){
			view->setState( getFeature(i), enable );
		}else{
			if( true/*enable*/ ){
				switch( i ){
				case RENDER_OPTION_AMBIENT:   selected_material->applyAmbient  (l); break;
				case RENDER_OPTION_DIFFUSE:   selected_material->applyDiffuse  (l); break;
				case RENDER_OPTION_SPECULAR:  selected_material->applySpecular (l); break;
				case RENDER_OPTION_EMISSION:  selected_material->applyEmission (l); break;
				case RENDER_OPTION_SHINYNESS: selected_material->applyShinyness(l); break;
//				case RENDER_OPTION_REMOVE_HIDDEN:  if( select ){ applyRemoveHidden (); } break;
//				case RENDER_OPTION_FRUSTUM_CULL:   if( select ){ applyFrustumCull  (); } break;
//				case RENDER_OPTION_SORT_INSTANCES: if( select ){ applySortInstances(); } break;
//				case RENDER_OPTION_SORT_ELEMENTS:  if( select ){ applySortElements (); } break;
				default:
					break;
				}
			}  //  end if enable
		}  //  end if getFeature(i) != 0
	}

	int master_mode = master_material->getMode();

	if( master_mode == RENDER_MODE_FILL_OUTLINE ){
		render_pass_count = 2;
	}else{
		render_pass_count = 1;
	}
}


//!  Apply single material application pass
bool Projection::materialPass(){
	render_pass++;

	if( render_pass <= render_pass_count ){

		if( isEnabled(PR_PICK) ){
			return true;
		}

		if( active_material == NULL ){
			debug_msg( "MaterialPass() needs material\n" );
			false;
		}

		float    polygon_offset = 2;
		Texture *t              = NULL;

		if( active_material->getPolygonOffset() == 1 ){
			polygon_offset -= 1;
		}

/*&& (t != active_texture)*/
		
		switch( render_pass ){
		case 1: {
			//	Apply polygon rendering mode
			switch(  MIN( active_material->getMode(), master_material->getMode() )  ){
			case RENDER_MODE_POINT:        view->setPolygonMode( GL_POINT ); break;
			case RENDER_MODE_LINE:         view->setPolygonMode( GL_LINE  ); break;
			case RENDER_MODE_FILL:         view->setPolygonMode( GL_FILL  ); break;
			case RENDER_MODE_FILL_OUTLINE: view->setPolygonMode( GL_FILL  ); break;
			default: break;
			}

			t = active_material->getTexture();
			if( (t != NULL)  ){
				active_texture = t;
				view->setTexture( t );
				view->enable( TEXTURE_2D );
			}else{
				view->disable( TEXTURE_2D );
			}

		} break;

		case 2: {
			if( master_material->getMode() == RENDER_MODE_FILL_OUTLINE ){
				polygon_offset += -1;
			}

			Uint32 mask_select = active_material->getOptions() & render_options_selection_mask;

			bool select = (mask_select>>RENDER_OPTION_BORDER) & 1 == 1;  // true if select material, false if select projection

			//	Borders are rendered without lighting.
			view->disable       ( POLYGON_OFFSET );
			view->disable       ( LIGHTING       );
			view->disable       ( TEXTURE_2D     );
			view->setPolygonMode( GL_LINE        );

			//	..using either material or projection color setting
			if( select ){
				active_material->applyBorder( RENDER_LIGHTING_COLOR );
			}else{
				master_material->applyBorder( RENDER_LIGHTING_COLOR );
			}

		} break;

		default:
			break;
		}

		if( polygon_offset != 0 ){
			view->enable( POLYGON_OFFSET );
			glPolygonOffset( 2.0, polygon_offset );
		}else{
			view->disable( POLYGON_OFFSET );
		}

		return true;
	}else{
		return false;
	}
}


//!  Drawing code
/*virtual*/ void Projection::drawSelf(){
	//	Reversing y coordinates because of OpenGL has mixed up and down..

	GLint *viewp;
	viewp = view->getViewport();
	glViewport( viewport[0], viewp[3]-viewport[3], viewport[2]-viewport[0], viewport[3]-viewport[1] );

	if( isEnabled(PR_CLIP) ){
#		if !defined( USE_TINY_GL )
		glScissor ( viewport[0], viewp[3]-viewport[3], viewport[2]-viewport[0], viewport[3]-viewport[1] );
		view->enable( SCISSOR_TEST );
#		endif
	}

	if( isEnabled(PR_CLEAR) ){
		glClearDepth( 1 );
		glClearColor( clear_color.rgba[0], clear_color.rgba[1], clear_color.rgba[2], clear_color.rgba[3] );
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	}

	//	Make sure first material is always applied
	active_material = NULL;
	camera->projectScene( this );

	if( isEnabled(PR_CLIP) ){
#		if !defined( USE_TINY_GL )
		view->disable( SCISSOR_TEST );
		glScissor( viewp[0], viewp[1], viewp[2], viewp[3] );
#		endif
	}
}


//!  Camera get accessor
Camera *Projection::getCamera(){
	return this->camera;
}


//!  Camera set accessor
void Projection::setCamera( Camera *c ){
	this->camera = c;
}


unsigned long Projection::getSelect(){
	return this->render_options_selection_mask;
}


void Projection::setSelect( unsigned long select ){
	render_options_selection_mask = select;
}


void Projection::enableSelect( unsigned long select ){
	render_options_selection_mask |= select;
}


void Projection::disableSelect( unsigned long select ){
	render_options_selection_mask &= ~select;
}


//!  Enable and or disable pick mode
void Projection::pickState( const bool state ){
	if( state == true ){
		enableOptions ( PR_PICK );
	}else{
		disableOptions( PR_PICK );
	}

	active_material = NULL;
	active_texture  = NULL;
}


Material *Projection::getMaster(){
	return master_material;
}


void Projection::setClearColor( Color c ){
	this->clear_color = c;
}


Color Projection::getClearColor(){
	return this->clear_color;
}


void Projection::setProjectionMatrix( Matrix &m ){
	view->setProjectionMatrix( m );
}

void Projection::setModelViewMatrix( Matrix &m ){
	view->setModelViewMatrix( m );
}


};  //  namespace PhysicalComponents

