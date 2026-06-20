
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
	\warning This file contains Physical UserInterface Component setup
	\date	 2001
*/


#include "ui.h"
#include "glElite/Cabin.h"
#include "glElite/FrontCamera.h"
#include "glElite/Hud.h"
#include "glElite/Scanner.h"
#include "glElite/Sight.h"
#include "glElite/ShipCamera.h"
#include "Graphics/View.h"
#include "Graphics/Features.h"
#include "Materials/Material.h"
#include "PhysicalComponents/WindowManager.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Layer.h"
#include "PhysicalComponents/WindowManager.h"
#include "PhysicalComponents/HDock.h"
#include "SysSupport/Messages.h"
using namespace Graphics;


namespace Application {


//!  Create testing environment physical user interface
void UI::initPhysicalComponents(){
	LayoutConstraint *constraint_1 = new LayoutConstraint();

	if( isEnabled(ENABLE_BACKGROUND_WINDOW) == true ){
		constraint_1->parent_x_fill_relative =    1;
		constraint_1->parent_y_fill_relative =    1;
		this->view->setClear( false );
	}else{
		constraint_1->parent_x_fill_relative =    0.5;
		constraint_1->local_x_fill_pixels    =  -20;
		constraint_1->parent_y_fill_relative =    1;
		constraint_1->local_y_fill_pixels    = -320;
		constraint_1->parent_x_offset_pixels =   10;
		constraint_1->parent_y_offset_pixels =  140;
	}

	LayoutConstraint *constraint_2 = new LayoutConstraint();
	constraint_2->parent_x_fill_relative   =    0.5;
	constraint_2->local_x_fill_pixels      =  -20;
	constraint_2->parent_y_fill_relative   =    1;
	constraint_2->local_y_fill_pixels      = -320;
	constraint_2->parent_x_offset_relative =    1;
	constraint_2->parent_x_offset_pixels   =  -20;
	constraint_2->local_x_offset_relative  =   -1;
	constraint_2->parent_y_offset_pixels   =  140;

	//	Create physical components for user interface
	front_camera  = new FrontCamera( "Camera 1", camera,        this, constraint_1, isDisabled(ENABLE_BACKGROUND_WINDOW) );
	front_camera2 = new FrontCamera( "Camera 2", player_camera, this, constraint_2, true );
	hud           = new Hud        ( this );
	scanner       = new Scanner    ( this );

	camera->setTitle( "Spectator View" );
	player_camera->setTitle( "Front View" );

	hud->setTargetMatrix( &camera->debug_matrix );

	window_manager->setFocus( dynamic_cast<EventListener*>(front_camera) );
	window_manager->insert( layer );

	layer->place ();
	view ->display();

	layer->addProjection( front_camera  );
	layer->addProjection( front_camera2 );

//	HDock *cams = new HDock( "Cameras" );
//	cams->insert( front_camera ->getTarget(EVENT_NULL) );
//	cams->insert( front_camera2->getTarget(EVENT_NULL) );
//	layer->insert( cams );

	if( isEnabled(ENABLE_CABIN) == true ){
		layer->insert( new Cabin("cabins/cabin5.lwo") );
	}

//	if( isEnabled(ENABLE_WINDOWS) == true ){
		layer->insert( hud );
		layer->insert( console );
		layer->insert( scanner );
//	}
	front_camera2->insert( new Sight() );

	layer->place();
	front_camera->focusActive( true );

	front_camera->setClearColor( Color(0.3f,0.2f,0.1f,1.0f) );
	front_camera->getMaster()->setOptions( RENDER_OPTION_ALL_M );
	front_camera->getMaster()->setMode( RENDER_MODE_FILL );
	front_camera->getMaster()->setLighting( RENDER_LIGHTING_SIMPLE );
	front_camera2->setClearColor( Color(0.1f,0.3f,0.0f,1.0f) );
	front_camera2->getMaster()->setMode( RENDER_MODE_FILL_OUTLINE );
	front_camera2->getMaster()->setLighting( RENDER_LIGHTING_COLOR );
	front_camera2->getMaster()->disableOptions( RENDER_OPTION_AMBIENT_M );
	front_camera2->getMaster()->disableOptions( RENDER_OPTION_SPECULAR_M );
	front_camera2->disableSelect( RENDER_OPTION_DIFFUSE_M );
	front_camera2->disableSelect( RENDER_OPTION_BORDER_M  );
	front_camera2->getMaster()->setDiffuse( Color(0.0f,0.2f,0.0f,1.0f) );
	front_camera2->getMaster()->setBorder ( Color(0.6f,0.7f,0.5f,1.0f) );

}


};	//	namespace Application

