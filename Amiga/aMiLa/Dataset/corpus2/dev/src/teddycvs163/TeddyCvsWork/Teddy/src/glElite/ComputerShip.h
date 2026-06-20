
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
	\class   ComputerShip
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Computer controlled ship
	\date    2001
*/


#ifndef TEDDY_APPLICATION_COMPUTER_SHIP_H
#define TEDDY_APPLICATION_COMPUTER_SHIP_H


#include "glElite/Ship.h"


namespace Application {


class ComputerShip : public Ship {
public:
	ComputerShip( char *name, ShipType *ship_type );

	//  Computer AI routines do decide controls
	virtual void applyControls( float age );

protected:

protected:
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_COMPUTER_SHIP_H

