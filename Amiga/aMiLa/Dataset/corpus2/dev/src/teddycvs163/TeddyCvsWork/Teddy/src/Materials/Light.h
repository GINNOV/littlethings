
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

/*!
	\class   Light
	\ingroup g_materials
	\author  Timo Suoranta
	\brief   Lightsource baseclass
	\warning Very incomplete
	\bug     Poor id and enable/disable management
	\todo    Destructors
	\date    1999, 2000, 2001

	Lights are used to lit objects in Scene. At the moment
	this class implements a simple OpenGL light wrapper
	with minimum featurs.
*/


#ifndef TEDDY_MATERIALS_LIGHT_H
#define TEDDY_MATERIALS_LIGHT_H


#include "Models/ModelInstance.h"
#include "Graphics/Color.h"
#include "Maths/Vector.h"
namespace PhysicalComponents { class Projection; };
using namespace Graphics;
using namespace Models;
using namespace PhysicalComponents;


namespace Materials {


class Light : public ModelInstance {
public:
	Light( const char *name );

	void          setAmbient      ( const Color &a );
	void          setDiffuse      ( const Color &d );
	void          setSpecular     ( const Color &s );
	void          setAttenuation  ( const float constant, const float linear, const float quadratic );
	void          setSpotCutOff   ( const float cutoff_angle );
	void          setSpotExponent ( const float exponent );
	void          setSpotDirection( Vector spot_direction );
	void          enable          ();
	void          disable         ();
	virtual void  applyLight      ( Projection *p );

	//  Light special tick
	void          orbit           ( float radius, float speed, int axis );

protected:
	int           id;
	Color         ambient;
	Color         diffuse;
	Color         specular;
	unsigned int  flags;

	float         constant_attenuation;
	float         linear_attenuation;
	float         quadratic_attenuation;
	float         spot_cutoff_angle;
	float         spot_exponent;
	Vector        spot_direction;

	bool          orbit_active;
	float         orbit_radius;
	float         orbit_speed;
	int           orbit_axis;
		
	static unsigned int light_id    [8];  //  FIX (query number of available lights from OpenGL)
	static int          light_status[8];	
};


};  //  namespace Materials


#endif  //  TEDDY_MATERIALS_LIGHT_H

