
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


#include "Materials/Light.h"
#include "Graphics/Device.h"
#include "Graphics/View.h"
#include "PhysicalComponents/Projection.h"
#include "SysSupport/Timer.h"
#include "Scenes/Camera.h"
#include <cstdio>
using namespace Graphics;
using namespace Materials;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Materials {


/*!
	Reservation status for OpenGL lights

	This really needs a lot of fixing.
*/
unsigned int Light::light_id    [8] = { GL_LIGHT0, GL_LIGHT1, GL_LIGHT2, GL_LIGHT3, GL_LIGHT4, GL_LIGHT5, GL_LIGHT6, GL_LIGHT7 };
int          Light::light_status[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };


//!  Default constructor for light with name only
Light::Light( const char *name ):ModelInstance(name){
	orbit_active = false;
	for( int i=0; i<8; i++ ){
		if( light_status[i] == 0 ){
			light_status[i] = 1;
			id = i;
			break;
		}
	}
	ambient  = Color::BLACK;
	diffuse  = Color::WHITE;
	specular = Color::BLACK;

	float pos[4];

	pos[0] = 0;  //  position.r;
	pos[1] = 0;  //  position.s;
	pos[2] = 0;  //  position.t;
	pos[3] = 1;

	glLightfv( light_id[id], GL_POSITION, pos );
}


void Light::setAttenuation( const float constant, const float linear, const float quadratic ){
	constant_attenuation  = constant;
	linear_attenuation    = linear;
	quadratic_attenuation = quadratic;
	glLightf( light_id[id], GL_CONSTANT_ATTENUATION,  constant_attenuation  );
	glLightf( light_id[id], GL_LINEAR_ATTENUATION,    linear_attenuation    );
	glLightf( light_id[id], GL_QUADRATIC_ATTENUATION, quadratic_attenuation );
}

void Light::setSpotCutOff( const float cutoff_angle ){
	spot_cutoff_angle = cutoff_angle;
	glLightf( light_id[id], GL_SPOT_CUTOFF, spot_cutoff_angle );
}

void Light::setSpotExponent( const float exponent ){
	spot_exponent = exponent;
	glLightf( light_id[id], GL_SPOT_EXPONENT, spot_exponent );
}

void Light::setSpotDirection( Vector spot_direction ){
	this->spot_direction = spot_direction;
}


void Light::orbit( float radius, float speed, int axis ){
	orbit_active = true;
	orbit_radius = radius;
	orbit_speed  = speed;
	orbit_axis   = axis;
}

/*virtual*/ 
/*
void Light::tick(){
	if( orbit_active == true ){
		float y = (float)(orbit_radius * sin( (double)(sys_time)/(double)(orbit_speed) ));
		float x = (float)(orbit_radius * cos( (double)(sys_time)/(double)(orbit_speed) ));
		switch( orbit_axis ){
		case 0: this->setPosition(  x,  y,  0 ); break;
		case 1: this->setPosition(  0,  x,  y ); break;
		case 2: this->setPosition(  x,  0,  y ); break;
		case 3: this->setPosition( -x,  y,  0 ); break;
		case 4: this->setPosition(  0, -x,  y ); break;
		case 5: this->setPosition(  x,  0, -y ); break;
		default: break;
		}
	}else{
		SimulatedInstance::tick();
	}
} */


//!  Set light ambient component
void Light::setAmbient( const Color &a ){
	ambient = a;
}


//!  Set light diffuse component
void Light::setDiffuse( const Color &d ){
	diffuse = d;
}


//!  Set light specular component
void Light::setSpecular( const Color &s ){
	specular = s;
}


//!  Enable individual light
void Light::enable(){
	glEnable( light_id[id] );
}


//!  Disable individual light
void Light::disable(){
	glDisable( light_id[id] );
}


//!  Apply light
/*virtual*/ void Light::applyLight( Projection *p ){
    Camera *camera = p->getCamera();
	float   pos[4];

	pos[0] = 0.0f;  //  position.r;
	pos[1] = 0.0f;  //  position.s;
	pos[2] = 0.0f;  //  position.t;
	pos[3] = 1.0f;

	glPushMatrix();
	camera->doCamera( p, true );

//  need origo camera fix
//	Vector v = getPosition() - p->getCamera()->getPosition();
	Vector vec = getPosition();

	pos[0] = vec.v[0];
	pos[1] = vec.v[1];
	pos[2] = vec.v[2];
	pos[3] = 1;
	glLightfv( light_id[id], GL_POSITION,       pos );
	glLightfv( light_id[id], GL_SPOT_DIRECTION, this->spot_direction );
	glLightfv( light_id[id], GL_AMBIENT,        ambient.rgba );
	glLightfv( light_id[id], GL_DIFFUSE,        diffuse.rgba );
	glLightfv( light_id[id], GL_SPECULAR,       specular.rgba );
	glPopMatrix();

}


};  //  namespace Materials


