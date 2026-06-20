
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


#include "config.h"
#include "glElite/ui.h"
#include "glElite/ConsoleStream.h"
#include "glElite/PlayerShip.h"
#include "Graphics/View.h"
#include "Imports/LWMesh.h"
#include "Materials/Material.h"
#include "Materials/Light.h"
#include "Maths/Vector.h"
#include "Maths/Vector4.h"
#include "Models/PointMesh.h"
#include "Models/LineMesh.h"
#include "Models/Line.h"
#include "Models/Vertex.h"
#include "Models/Grid.h"
#include "Models/Torus.h"
#include "Models/Tube.h"
#include "Scenes/Camera.h"
#include "Scenes/PostElement.h"
#include "Scenes/Scene.h"
#include "SysSupport/Messages.h"
#include <cstdio>
using namespace Graphics;
using namespace Imports;
using namespace Materials;
using namespace Scenes;


namespace Application {


//!  Initialize objects == scene
void UI::initObjects(){
	//	This torus is currently used as Mesh for the spectator camera
	Torus *torus = new Torus( "Torus", 5.0, 2.0, 14, 14 );

	camera ->translate     ( 0, 400,  800 );
	camera ->pitch         ( -35 );
	camera2->translate     ( 0, 10, -100 );
	camera2->disableOptions( MI_VISIBLE );
	camera2->heading       ( 180.0f );
	scene  ->addInstance   ( camera );
	camera ->setMesh       ( torus );
	camera2->setMesh       ( torus );
	scene  ->addInstance   ( camera2 );

	camera ->setMaterial( &Material::YELLOW );
	camera2->setMaterial( &Material::MAGENTA );


	//  Add reference point
/*
	LineMesh *line_mesh = new LineMesh( "Lines" );
	Vertex *origo = new Vertex( 0, 0, 0 );
	Vertex *x_end = new Vertex(40, 0, 0 );
	Vertex *y_end = new Vertex( 0,40, 0 );
	Vertex *z_end = new Vertex( 0, 0,40 );
	line_mesh->insert( new Line(origo,x_end) );
	line_mesh->insert( new Line(origo,y_end) );
	line_mesh->insert( new Line(origo,z_end) );
	line_mesh->setClipRadius( sqrt(40*40*3) );
	ModelInstance *mi_lines = new ModelInstance( "Lines", line_mesh );
	Material      *mat      = new Material( Material::RED );
	mat     ->setLighting( RENDER_LIGHTING_COLOR );
	mi_lines->setMaterial( mat );
	mi_lines->setPosition( 10, 10, 10 );
	scene   ->addInstance( mi_lines );*/

#if 0
	PostElement *pe;
		
/*	pe = new PostElement( "star.png", 20 );
	pe->insert( new Vector4( 0, 0, 0, 1 ) );
	pe->insert( new Vector4(40, 0, 0, 1 ) );
	pe->insert( new Vector4( 0,40, 0, 1 ) );
	pe->insert( new Vector4( 0, 0,40, 1 ) );
	pe->setPosition( 10, 10, 10 );
	scene->addPostElement( pe );	  */

	char name[100];
	int  i;
	for( i=1; i<2; i++ ){
		float x = 3000 * sin( i*M_PI/7 );
		float z = 3000 * cos( i*M_PI/7 );
		sprintf( name, "alphasprites/Star%d.png", i );
		pe = new PostElement( name, 500, i*117, 315*(i%6+2) );
		pe->insert( new Vector4( 0, 0, 0, 1 ) );
		pe->setPosition( x, 1000, z );
		scene->addPostElement( pe );
	}
#endif

	addLights( 4, false );
	addGrid( 50, 50, 100, 100 );

//	addPrimitives();
	loadLWO();
//	addFFE();
//	addROAM();
//	addRigidBodies();
}


//!  Add preset light(s) to scene
void UI::addLights( int num, const bool animate ){
#	define LX 20000
#	define LY 50000
#	define LZ 20000
	Light *light;

	View::check();
	light = new Light( "Player Light" );
	light->setAmbient ( Color(0.6f,0.6f,0.6f) );
	light->setDiffuse ( Color(0.6f,0.6f,0.6f) );
	light->setSpecular( Color(0.6f,0.6f,0.6f) );
	light->setPosition( 0, 0, 0 );
	light->setSpotCutOff( 25.0f );
	light->setSpotExponent( 32.0f );
	light->enable();
	scene->addLight( light );
	ply_light = light;
	View::check();
	
	if( num>1 ){
		light = new Light( "Light 1" );
		light->setAmbient ( Color(0.4f,0.4f,0.4f) );
		light->setDiffuse ( Color(0.4f,0.4f,0.4f) );
		light->setSpecular( Color(0.4f,0.4f,0.4f) );
		light->setPosition( LX, LY, 0 );
		light->enable();
		scene->addLight( light );
		if( animate ){
//			light->tick_translation = DoubleVector( 2.0, 0.0, 0.0 );
			light->orbit( 8000, 15000, 0 );
		}
		View::check();
	}

	if( num>2 ){
		light = new Light( "Light 2" );
		light->setAmbient ( Color(0.4f,0.4f,0.4f) );
		light->setDiffuse ( Color(0.4f,0.4f,0.4f) );
		light->setSpecular( Color(0.4f,0.4f,0.4f) );
		light->setPosition(  0, LY, LZ );
		light->enable();
		scene->addLight( light );
		if( animate ){
//			light->tick_translation = DoubleVector( 0.0, -20.0, 0.0 );
			light->orbit( 6000, 30000, 1 );
		}
		View::check();
	}

	if( num>3 ){
		light = new Light( "Light 3" );
		light->setAmbient ( Color(0.4f,0.4f,0.4f) );
		light->setDiffuse ( Color(0.4f,0.4f,0.4f) );
		light->setSpecular( Color(0.4f,0.4f,0.4f) );
		light->setPosition( 0, -LY, 0 );
		light->enable();
		scene->addLight( light );
		if( animate ){
//			light->tick_translation = DoubleVector( -2.0, -1.0, 10.0 );
			light->orbit( 7000, 50000, 2 );
		}
		View::check();
	}

	if( num>4 ){
		light = new Light( "Light 4" );
		light->setAmbient ( Color::GRAY_50 );
		light->setDiffuse ( Color::GRAY_50 );
		light->setSpecular( Color::GRAY_50 );
		light->setPosition( -LX, LY, LZ );
		light->enable();
		scene->addLight( light );
//		if( animate ){
//			light->tick_translation = DoubleVector( 40.0, 20.0, 1.0 );
			light->orbit( 15000, 700, 3 );
//		}
		View::check();
	}

	if( num>5 ){
		light = new Light( "Light 5" );
		light->setAmbient ( Color(0,0,0.2f) );
		light->setDiffuse ( Color(0,0,0.2f) );
		light->setSpecular( Color(0,0,0.2f) );
		light->setPosition( LX, LY, 0 );
		light->enable();
		scene->addLight( light );
		light->orbit( 50000, 71, 5 );
		View::check();
	}
	if( num>6 ){
		light = new Light( "Light 6" );
		light->setAmbient ( Color::BLACK );
		light->setDiffuse ( Color::LIGHT_BLUE );
		light->setSpecular( Color::LIGHT_BLUE );
		light->setPosition( -LX, -LY, 0 );
		light->enable();
		scene->addLight( light );
		light->orbit( 25000, 300, 4 );
		View::check();
	}
	view->display();
	View::check();
}


//!  Add simple grid to scene
void UI::addGrid( int xcount, int zcount, int xspace, int zspace ){
	Material      *m;
	ModelInstance *mi;

#	if 0 // !defined( USE_TINY_GL )
	Grid *grid = new Grid( xcount, zcount, xspace, zspace );

	mi = new ModelInstance( "Grid", grid );
	mi->setPosition( 0.0, 1000.0f, 0.0 );
	mi->setMaterial( m = new Material( Material::DARK_BLUE, RENDER_LIGHTING_COLOR ) );
	m->setDiffuse( Color(0.334f,0.33f,0.44f) );
	scene->addInstance( mi );

	mi = new ModelInstance( "Grid", grid );
	mi->setPosition( 0, -1000, 0 );
	mi->setMaterial( m = new Material( Material::DARK_BLUE, RENDER_LIGHTING_COLOR ) );
	m->setDiffuse( Color(0.33f,0.33f,0.44f) );
	scene->addInstance( mi );
#else
	Grid *grid = new Grid( xcount/2, zcount/2, xspace*2, zspace*2 );
#endif

	mi = new ModelInstance( "Grid", grid );
	mi->setPosition( 0, 0.0f, 0 );
	mi->setMaterial( m = new Material( Material::DARK_RED, RENDER_LIGHTING_COLOR ) );
	m->setDiffuse( Color(0.65f,0.43f,0.21f) );
	scene->addInstance( mi );

}


};	//	namespace Application



