
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


#include "glElite/ShipType.h"
#include "Models/Mesh.h"
using namespace Models;


namespace Application {


ShipType::ShipType( Mesh *mesh, float a, float ms, float pc, float rc, float mp, float mr ){
	this->mesh         = mesh;
	this->acceleration = a;
	this->pitch_const  = pc;
	this->roll_const   = rc;
	this->max_pitch    = mp;
	this->max_roll     = mr;
	this->max_speed    = ms;
}

Mesh *ShipType::getMesh(){
	return this->mesh;
}

float ShipType::getAcceleration(){
	return this->acceleration;
}

float ShipType::getPitchConst(){
	return this->pitch_const;
}

float ShipType::getRollConst(){
	return this->roll_const;
}

float ShipType::getMaxPitch(){
	return this->max_pitch;
}

float ShipType::getMaxRoll(){
	return this->max_roll;
}

float ShipType::getMaxSpeed(){
	return this->max_speed;
}


};

