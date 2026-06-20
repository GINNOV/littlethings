
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
	\warning This file contains Logical UserInterface Actions except settings
	\date	 2001
*/


#include "config.h"
#include "glElite/ui.h"
#include "glElite/Simulated.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
using namespace Scenes;


namespace Application {


#define TRANSLATE_SCALE   1.0f
#define ROTATE_SCALE	  0.3f
#define distance_delta	  0.01f
#define SCALE			  1.00f


void UI::updateSimulation(){
	camera->heading( control_heading );
	camera->pitch  ( control_pitch   );
	camera->roll   ( control_roll    );

	Vector delta = camera->getViewAxis() * control_speed;
	camera->translate( delta );

	control_heading *= 0.88f;
	control_pitch   *= 0.88f;
	control_roll    *= 0.88f;
	control_speed   *= 0.98f;

	list<ModelInstance*>::iterator i_it = scene->getInstances().begin();
	while( i_it != scene->getInstances().end() ){
		ModelInstance *mi = *i_it;
		Simulated     *s  = dynamic_cast<Simulated*>( mi );
		if( s != NULL ){
			s->tick();
		}
		i_it++;
	}
}

//!  translate camera
void UI::cameraRotate( const int x_delta, const int y_delta ){
	control_heading -= 0.1f * x_delta;
	control_pitch   -= 0.1f * y_delta;
}


//!  rotate camera
void UI::cameraTranslate( const int x_delta, const int y_delta ){
	control_roll    += 0.1f * x_delta;
	control_speed   -= 0.1f * y_delta;
}


};	//	namespace Application

