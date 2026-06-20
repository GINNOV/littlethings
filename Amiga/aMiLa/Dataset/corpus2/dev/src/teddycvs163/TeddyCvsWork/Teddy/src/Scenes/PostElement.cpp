		
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


#include "config.h"
#include "Scenes/PostElement.h"
#include "Graphics/View.h"
#include "Graphics/Features.h"
#include "Materials/SdlTexture.h"
#include "Maths/Vector4.h"
#include "PhysicalComponents/Projection.h"
#include "Scenes/Camera.h"
#include "SysSupport/StdList.h"
#include "SysSupport/Timer.h"
using namespace Graphics;
using namespace Materials;
using namespace Maths;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Scenes {


PostElement::PostElement( const char *name, float radius, float offset, float cycle ):ModelInstance(name){
	txt = new SdlTexture( name );
	min_radius   = radius/2;
	max_radius   = radius;
	this->offset = offset;
	this->cycle  = cycle / M_2_PI;
}


void PostElement::insert( Vector4 *v ){
	vertices.push_back( v );
}


/*virtual*/ void PostElement::drawImmediate( Projection *p ){
	Camera *camera = p->getCamera();
	View   *view   = p->getView();
	float   ratio  = view->getRatio();
	float   radius = min_radius + (max_radius-min_radius)*(0.5 + sin( (sys_time+offset)/(cycle) )/2);

	camera->doObjectMatrix( p, localToWorld(), false );

	if( txt!=NULL ){
		if( txt->isGood() == true ){
			view->setTexture( txt );
			view->enable( TEXTURE_2D );
//			printf( "Doing texture\n" );
		}
	}

	p->color( C_WHITE );
	list<Vector4*>::iterator v_it = vertices.begin();
	while( v_it != vertices.end() ){
		Vector4 *v = (*v_it);
		Vector4  ss_v = camera->projectVector( *v );
		float    inv_z = 1/(ss_v.v[2] + 1 );
		float    x     = ss_v.v[0] * inv_z;
		float    y     = ss_v.v[1] * inv_z;
		float    dx    = radius * inv_z;
		float    dy    = dx * ratio;
		if( inv_z > 0 ){
			p->beginQuads();
			p->texture( 0, 0 ); p->vertex( x+dx, y+dy );
			p->texture( 1, 0 ); p->vertex( x+dx, y-dy );
			p->texture( 1, 1 ); p->vertex( x-dx, y-dy );
			p->texture( 0, 1 ); p->vertex( x-dx, y+dy );
			p->end();
		}
		v_it++;
	}
}


}  //  namespace Scenes

