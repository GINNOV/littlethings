
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


#if defined(_MSC_VER)
#pragma warning(disable:4305)  //  from const double to float
#endif


#include "glElite/ShipCamera.h"
#include "glElite/Ship.h"
#include "Models/Mesh.h"
using namespace Models;


namespace Application {


ShipCamera::ShipCamera( Ship *ship, Scene *scene, Mesh *cabin_mesh )
:Camera( ship->getName(), scene )
{
	this->ship  = ship;
	this->cabin = cabin_mesh;
	this->range = 0;
	front();
}


/*!  
	Target ship hidden if distance == 0
*/
/*virtual*/ void ShipCamera::projectScene( Projection *p ){
	unsigned long tmp_options;

	if( range == 0 ){
		tmp_options = ship->getOptions();
		ship->disableOptions( MI_VISIBLE );
		Camera::projectScene( p );
		ship->setOptions( tmp_options );
	}else{
		Camera::projectScene( p );
	}
}


//!  Simulate one tick
/*virtual*/ void ShipCamera::tick(){
	setPosition( ship->getPosition() );
	v[0] = ship->v[0];
	v[1] = ship->v[1];
	v[2] = ship->v[2];
	v[3] = ship->v[3];
	heading( degs(heading_v) );
	pitch  ( degs(pitch_v  ) );
	roll   ( degs(roll_v   ) );
	foward( -range );
}


void ShipCamera::front(){
	setHeading( 0 );
	setPitch  ( 0 );
	setRoll   ( 0 );
	setTitle  ( "Front View" );
}

void ShipCamera::left(){
	setHeading( M_HALF_PI );
	setPitch  ( 0 );
	setRoll   ( 0 );
	setTitle  ( "Left View" );
}

void ShipCamera::right(){
	setHeading( -M_HALF_PI );
	setPitch  ( 0 );
	setRoll   ( 0 );
	setTitle  ( "Right View" );
}

void ShipCamera::rear(){
	setHeading( M_PI );
	setPitch  ( 0 );
	setRoll   ( 0 );
	setTitle  ( "Rear View" );
}

void ShipCamera::top(){
	setHeading( 0 );
	setPitch  ( M_HALF_PI );
	setRoll   ( 0 );
	setTitle  ( "Top View" );
}

void ShipCamera::bottom(){
	setHeading( 0 );
	setPitch  ( -M_HALF_PI );
	setRoll   ( 0 );
	setTitle  ( "Bottom View" );
}


void ShipCamera::setCabin( Mesh *cabin_mesh ){
	this->cabin = cabin_mesh;
}

void ShipCamera::setDistance( float distance ){
	this->range = distance;
}

void ShipCamera::setHeading( float heading ){
	this->heading_v = heading;
}

void ShipCamera::setPitch( float pitch ){
	this->pitch_v = pitch;
}

void ShipCamera::setRoll( float roll ){
	this->roll_v = roll;
}

float ShipCamera::getDistance(){
	return this->range;
}

float ShipCamera::getHeading(){
	return this->heading_v;
}

float ShipCamera::getPitch(){
	return this->pitch_v;
}

float ShipCamera::getRoll(){
	return this->roll_v;
}

Ship *ShipCamera::getShip(){
	return this->ship;
}

Scene *ShipCamera::getScene(){
	return this->scene;
}

Mesh *ShipCamera::getMesh(){
	return this->cabin;
}

};  //  namespace Application

