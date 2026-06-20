
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


#include "Scenes/SkyBox.h"
#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Models/Line.h"
#include "PhysicalComponents/Projection.h"
using namespace Materials;
using namespace Graphics;
using namespace PhysicalComponents;


namespace Models {


//!  Constructor. Loads textures. Should have Destructor as well...
SkyBox::SkyBox():Mesh("skybox"){
	Material *mat;

	mat = new Material( "Skybox material",
		RENDER_MODE_LINE,
		RENDER_LIGHTING_COLOR,
		RENDER_OPTION_DIFFUSE_M
	);
	mat->setDiffuse( Color(0,0,1,1) );
	this->setMaterial( mat );

	// front = new Material( "SkyBox Front", new Texture("simple_sunset_FR.raw") );
	// back  = new Material( "SkyBox Back",  new Texture("simple_sunset_BK.raw") );
	// left  = new Material( "SkyBox Left",  new Texture("simple_sunset_LF.raw") );
	// right = new Material( "SkyBox Right", new Texture("simple_sunset_RT.raw") );
	// up	 = new Material( "SkyBox Up",	 new Texture("simple_sunset_UP.raw") );
	// down  = new Material( "SkyBox DOwn",  new Texture("simple_sunset_DN.raw") );
};


//!  Skybox rendering code
/*virtual*/ void SkyBox::drawElements( Projection *p ){
	View *view = p->getView();

	double a = 4.0;
	//glColor4f( 0.5f, 0.5f, 0.55f, 1.0f );
	//for texture use only -> material
	//glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
	//glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );
#	define tmin (0.0 + 0.5/256.0)  // this will remove (most of) visible edges 
#	define tmax (1.0 - 0.5/256.0)  // in skybox
	//front->glApply();
	view->beginQuads();
	view->vertex_v3ft2f(  a,  a, -a, tmin, tmin );
	view->vertex_v3ft2f( -a,  a, -a, tmax, tmin );
	view->vertex_v3ft2f( -a, -a, -a, tmax, tmax );
	view->vertex_v3ft2f(  a, -a, -a, tmin, tmax );
	//back->glApply();
	view->vertex_v3ft2f( -a,  a,  a, tmin, tmin );
	view->vertex_v3ft2f(  a,  a,  a, tmax, tmin );
	view->vertex_v3ft2f(  a, -a,  a, tmin, tmin );
	view->vertex_v3ft2f( -a, -a,  a, tmin, tmax );
	//right->glApply();
	view->vertex_v3ft2f( -a,  a, -a, tmin, tmin );
	view->vertex_v3ft2f( -a,  a,  a, tmax, tmin );
	view->vertex_v3ft2f( -a, -a,  a, tmax, tmax );
	view->vertex_v3ft2f( -a, -a, -a, tmin, tmax );
	//left->glApply();
	view->vertex_v3ft2f(  a,  a,  a, tmin, tmin );
	view->vertex_v3ft2f(  a,  a, -a, tmax, tmin );
	view->vertex_v3ft2f(  a, -a, -a, tmax, tmax );
	view->vertex_v3ft2f(  a, -a,  a, tmin, tmax );
	//up->glApply();
	view->vertex_v3ft2f( -a,  a,  a, tmax, tmin );
	view->vertex_v3ft2f( -a,  a, -a, tmax, tmax );
	view->vertex_v3ft2f(  a,  a, -a, tmin, tmax );
	view->vertex_v3ft2f(  a,  a,  a, tmin, tmin );
	//down->glApply();
	view->vertex_v3ft2f( -a, -a,  a, tmax, tmin );
	view->vertex_v3ft2f( -a, -a, -a, tmax, tmax );
	view->vertex_v3ft2f(  a, -a, -a, tmin, tmax );
	view->vertex_v3ft2f(  a, -a,  a, tmin, tmin );
	view->end();
}


};	//	namespace Models

