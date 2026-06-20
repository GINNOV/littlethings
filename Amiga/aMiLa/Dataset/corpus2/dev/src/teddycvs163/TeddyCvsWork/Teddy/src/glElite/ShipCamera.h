
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
	\class	 ShipCamera
	\ingroup g_scenes
	\author  Timo Suoranta
	\brief	 Camera which is attached to a ship
	\date	 2001
*/


#ifndef TEDDY_APPLICATION_SHIP_CAMERA_H
#define TEDDY_APPLICATION_SHIP_CAMERA_H


#include "glElite/Simulated.h"
#include "Scenes/Camera.h"
namespace Models { class Mesh; };
using namespace Scenes;


namespace Application {


class Ship;


class ShipCamera : public Camera, public Simulated {
public:
	ShipCamera( Ship *ship, Scene *scene, Mesh *cabin = NULL );

	virtual void   projectScene ( Projection *p );

	void   front      ();
	void   left       ();
	void   right      ();
	void   rear       ();
	void   top        ();
	void   bottom     ();
	void   setCabin   ( Mesh  *cabin_mesh );
	void   setHeading ( float  heading    );
	void   setPitch   ( float  pitch      );
	void   setRoll    ( float  roll       );
	void   setDistance( float  distance   );
	Ship  *getShip    ();
	Scene *getScene   ();
	Mesh  *getMesh    ();
	float  getDistance();
	float  getHeading ();
	float  getPitch   ();
	float  getRoll    ();

	//  Simulation Update Interface
	virtual void tick();

protected:
	Ship  *ship;
	Mesh  *cabin;
	float  heading_v;
	float  pitch_v;
	float  roll_v;
	float  range;
};


};  //  namespace Scenes


#endif  //  TEDDY_APPLICATION_SHIP_CAMERA_H

