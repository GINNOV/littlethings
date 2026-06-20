
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


#if 0


#include "config.h"
#include "Graphics/View.h"
#include "Graphics/Features.h"
#include "Maths/trigmath.h"
#include "Maths/Random.h"
#include "PhysicalComponents/Projection.h"
#include "Scenes/Camera.h"
#include "Scenes/StarField.h"
using namespace Graphics;
using namespace PhysicalComponents;


namespace Scenes {


//!  Constructor
StarField::StarField( Camera *c, int count, float range ){
	this->camera = c;
	this->count  = count;
	this->range  = range;
	random.Init( 1 );
	stars = new Vector[count];
	Vector front = c->getPosition();  /* + this->getViewAxis() * 100;*/
	float  cx    = front.x;
	float  cy    = front.y;
	float  cz    = front.z;
	for( int i=0; i<count; i++ ){
		Vector rv;
		rv.x = (float)random.RandomD( -range, range );
		rv.y = (float)random.RandomD( -range, range );
		rv.z = (float)random.RandomD( -range, range );
		stars[i] = front + rv;
	}
}


//!  Destructor
StarField::~StarField(){
	delete[] stars;
}


//!  Draw
void StarField::draw( Projection *p ){
	View *view = p->getView();

	view->disable( LIGHTING );
	view->disable( TEXTURE_2D );
	view->disable( DEPTH_TEST );

#	if !defined( USE_TINY_GL )
	view->enable( FOG );

	float fog_black[4] = { 0, 0, 0, 1 };

	glFogi ( GL_FOG_MODE,	 GL_LINEAR );
	glFogfv( GL_FOG_COLOR,	 fog_black );
	glFogf ( GL_FOG_DENSITY,   1       );
	glFogf ( GL_FOG_START,	 range/3   );
	glFogf ( GL_FOG_END,	 range     );
#	endif

	view->color( C_WHITE );
	view->beginPoints();
	Vector		front = camera->getPosition();
	float		cx	  = front.x;
	float		cy	  = front.y;
	float		cz	  = front.z;
	for( int i=0; i<count; i++ ){
		float dx = stars[i].x - cx;
		float dy = stars[i].y - cy;
		float dz = stars[i].z - cz;
		if( dx<-range || dx>range || dy<-range || dy>range || dz<-range || dz>range ){
			Vector rv;
			rv.x = (float)random.RandomD( -range, range );
			rv.y = (float)random.RandomD( -range, range );
			rv.z = (float)random.RandomD( -range, range );
			stars[i] = front + rv;
		}
		view->vertex( stars[i].x, stars[i].y, stars[i].z );
	}
	view->end();
	view->disable( FOG );
}


};  //  namespace Scenes


#endif

