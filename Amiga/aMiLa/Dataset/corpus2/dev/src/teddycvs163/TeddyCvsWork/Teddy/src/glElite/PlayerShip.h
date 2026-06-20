
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
	\class   PlayerShip
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Player controlled ship
	\date    2001
*/


#ifndef TEDDY_APPLICATION_PLAYER_SHIP_H
#define TEDDY_APPLICATION_PLAYER_SHIP_H


#include "glElite/Ship.h"
namespace Materials { class Light;          };
namespace Models    { class CollisionGroup; };
namespace Models    { class Mesh;           };
namespace Models    { class ModelInstance;  };
using namespace Materials;
using namespace Models;


namespace Application {


class UI;


class PlayerShip : public Ship {
public:
	PlayerShip( UI *ui, ShipType *ship_type );

	void  init             ();
	void  setCollisionGroup( CollisionGroup *cg );

	//  Player controls
	virtual void applyControls( float age );

protected:

protected:
	//  Player control
	UI   *ui;
	Mesh *bullet;
	bool  wait_up;  //!<  True if we are waiting key release
	bool  touch;    //!<  True if player has pressed any key
};


extern Light *ply_light;


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_PLAYER_SHIP_H

