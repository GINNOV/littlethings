
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
	\warning This file contains testing user interface settings actions
	\date	 2001
*/


#include "glElite/ui.h"
#include "Graphics/Features.h"
#include "Graphics/View.h"
#include "Materials/Material.h"
#include "FrontCamera.h"
#include "Scenes/Scene.h"
#include "Scenes/Camera.h"
using namespace Materials;
using namespace Scenes;


namespace Application {


void UI::blendOff(){
	view->disable( BLEND );
}

void UI::blendOn(){
	view->enable( BLEND );
}


void UI::renderModePoint(){
	con << ": Polygon Mode Point" << endl;
	front_camera->getMaster()->setMode( RENDER_MODE_POINT );
	scene->update( front_camera );
}


void UI::renderModeLine(){
	con << ": Polygon Mode Line" << endl;
	front_camera->getMaster()->setMode( RENDER_MODE_LINE );
	scene->update( front_camera );
}


void UI::renderModeFill(){
	con << ": Polygon Mode Fill" << endl;
	front_camera->getMaster()->setMode( RENDER_MODE_FILL );
	scene->update( front_camera );
}


void UI::renderModeFillOutline(){
	con << ": Polygon Mode Fill Outline" << endl;
	front_camera->getMaster()->setMode( RENDER_MODE_FILL_OUTLINE );
	scene->update( front_camera );
}


void UI::cullFaceEnable(){
	con << ": Master Face Culling Enabled" << endl;
	front_camera->getMaster()->enableOptions( RENDER_OPTION_CULL_FACE_M );
	scene->update( front_camera );
}


void UI::cullFaceDisable(){
	con << ": Master Face Culling Disabled" << endl;
	front_camera->getMaster()->disableOptions( RENDER_OPTION_CULL_FACE_M );
	scene->update( front_camera );
}


void UI::depthTestEnable(){
	con << ": Master Depth Test Enabled" << endl;
	front_camera->getMaster()->enableOptions( RENDER_OPTION_DEPTH_TEST_M );
	scene->update( front_camera );
}


void UI::depthTestDisable(){
	con << ": Master Depth Test Disabled" << endl;
	front_camera->getMaster()->disableOptions( RENDER_OPTION_DEPTH_TEST_M );
	scene->update( front_camera );
}


void UI::lightingOn(){
	con << ": Master Lighting Enabled (simple)" << endl;
	front_camera->getMaster()->setLighting( RENDER_LIGHTING_SIMPLE );
	scene->update( front_camera );
}


void UI::lightingOff(){
	con << ": Master Lighting Disabled (color)" << endl;
	front_camera->getMaster()->setLighting( RENDER_LIGHTING_COLOR );
	scene->update( front_camera );
}


void UI::fovNormal(){
	float fov = front_camera->getCamera()->getFov() - 5;
	if( fov > 0 ){
		con << ": Field of Vision " << fov << " degrees" << endl;
		front_camera->getCamera()->setFov( fov );
	}
}


void UI::fovWide(){
	float fov = front_camera->getCamera()->getFov() + 5;
	if( fov < 180 ){
		con << ": Field of Vision " << fov << " degrees" << endl;
		front_camera->getCamera()->setFov( fov );
	}
}


void UI::antialiseOn(){
	con << ": Line Smooth Hint Nicest" << endl;
	front_camera->enableOptions( RENDER_OPTION_LINE_SMOOTH_M );
	scene->update( front_camera );
}


void UI::antialiseOff(){
	con << ": Line Smooth Hint Fastest" << endl;
	front_camera->disableOptions( RENDER_OPTION_LINE_SMOOTH_M );
	scene->update( front_camera );
}


};	//	namespace Application

