
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
	\ingroup g_testing_environment
	\author  Timo Suoranta
	\warning This file contains Logical UserInterface Actions
	\date	 2001
*/


#include "glElite/ui.h"
#include "Graphics/View.h"
#include "Imports/LWMesh.h"
#include "Materials/Material.h"
#include "Materials/SdlTexture.h"
#include "Models/Box.h"
#include "Models/Cone.h"
#include "Models/ModelInstance.h"
#include "Models/PointMesh.h"
#include "Models/Sphere.h"
#include "Models/Torus.h"
#include "Models/Tube.h"
#include "Models/Vertex.h"
#include "Scenes/Scene.h"
#include "SysSupport/FileScan.h"
using namespace Imports;
using namespace Models;
using namespace Scenes;


namespace Application {


//!  Add primitive objects to scene
void UI::addPrimitives(){
	Material *m1 = new Material( "Test Material m1" );
	m1->setEmission( Color(0,0,0) );
	m1->setAmbient ( Color(0.3f,0.2f,0.1f) );
	m1->setDiffuse ( Color(0.3f,0.2f,0.1f) );
	m1->setSpecular( Color(0.4f,0.4f,0.8f) );
	m1->setBorder  ( Color(0,0,1) );
	m1->setMode    ( RENDER_MODE_FILL );
	m1->setLighting( RENDER_LIGHTING_SIMPLE );
	m1->setOptions (
		RENDER_OPTION_CULL_FACE_M  |
		RENDER_OPTION_DEPTH_TEST_M |
		RENDER_OPTION_AMBIENT_M    |
		RENDER_OPTION_DIFFUSE_M    |
		RENDER_OPTION_SPECULAR_M   |
		RENDER_OPTION_EMISSION_M   |
		RENDER_OPTION_SHINYNESS_M  |
		RENDER_OPTION_SMOOTH_M
	);
	m1->setShininess( 8.0f );

	//	Add Torus
	Torus		  *torus	= new Torus( "Torus", 9.0, 3.0, 21, 24 );
	ModelInstance *mi_torus = new ModelInstance( "Torus 1", torus );
	mi_torus->setPosition( 30.0, -30.0, 0.0 );
	mi_torus->setMaterial( &Material::RED );
	scene->addInstance( mi_torus );

	//	Add Tube
	Tube          *tube    = new Tube( "Tube", 20.0, 5.0, 21, 24 );
	ModelInstance *mi_tube = new ModelInstance( "Tube", tube );
	mi_tube->setPosition( -30.0, 0.0, 0.0 );
	mi_tube->setMaterial( &Material::YELLOW );
	scene->addInstance( mi_tube );

	// Add Cone
	Cone		  *cone    = new Cone( "Cone", 10.0f, 3.0f, 10.0f, 17, 11 );
	ModelInstance *mi_cone = new ModelInstance( "Cone", cone );
	mi_cone->setPosition( 30.0, 0.0, -30.0	);
	mi_cone->setMaterial( m1 );
	scene->addInstance( mi_cone );

	// Add Sphere
	Sphere		  *sphere	 = new Sphere( "Sphere", 10.0f, 17, 17 );
	ModelInstance *mi_sphere = new ModelInstance( "Sphere", sphere );
	mi_sphere->setPosition( -15.0, 0.0, -40.0 );
	mi_sphere->setMaterial( &Material::WHITE );
//		mi_sphere->getMaterial()->setTexture( new SdlTexture( "mars.jpg" ), true );
	scene->addInstance( mi_sphere );

	// Add Box
	Box           *box    = new Box( "Box", 20, 10, 30 );
	ModelInstance *mi_box = new ModelInstance( "Box", box );
	mi_box->setPosition( -10, -5, 60 );
	mi_box->setMaterial( &Material::CYAN );
	scene->addInstance( mi_box );


	view->display();
}


};	//	namespace Application

