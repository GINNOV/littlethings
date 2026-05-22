
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

/*!
	\file
	\ingroup g_application
	\author  Timo Suoranta
	\date	 2001
*/


#include "glElite/Cabin.h"
#include "Graphics/Features.h"
#include "Graphics/View.h"
#include "Imports/LWMesh.h"
#include "Models/Mesh.h"
#include "PhysicalComponents/LayoutConstraint.h"
using namespace Graphics;
using namespace Imports;
using namespace Materials;
using namespace Models;
using namespace PhysicalComponents;


namespace Application {


//!  Add primitive objects to scene
Cabin::Cabin( char *name ):Area("Cabin"){
	constraint = new LayoutConstraint();
	constraint->parent_x_fill_relative = 1;
	constraint->parent_y_fill_relative = 1;
	mesh = new LWMesh( name, 0 );
}


/*virtual*/ void Cabin::drawSelf(){
	return;
	view->setProjectionMatrix( Matrix::Identity );
	view->setModelViewMatrix ( Matrix::Identity );

	view->color( 0.1f, 0.1f, 0.2f, 0.8f );
	view->enable        ( BLEND );
	view->setBlendFunc  ( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	view->disable       ( TEXTURE_2D );
	view->disable       ( DEPTH_TEST );
	view->setPolygonMode( GL_FILL );
//	mesh->drawNoMaterial(  );
	view->color( C_WHITE );
}


};	//	namespace Application

