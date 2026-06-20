
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


#include "glElite/ui.h"
#include "glElite/PlayerShip.h"
#include "Materials/Material.h"
#include "Materials/Light.h"
#include "Models/Tube.h"
#include "Models/Box.h"
#include "Scenes/Scene.h"
#include "SysSupport/Messages.h"
#include "SysSupport/Timer.h"
using namespace Materials;
using namespace Maths;
using namespace Models;
using namespace Scenes;


namespace Application {


#define BULLET_RATE  ( 150.0000f)                   
#define BULLET_SPEED (  50.0000f)
#define FM_ELITE     0
#define FM_FREE	     1


Light *ply_light = NULL;


PlayerShip::PlayerShip( UI *ui, ShipType *ship_type )
:
	Ship( "Player", ship_type )
{
	this->ui = ui;
//	this->sb = sb;

	init();

	bullet = new Tube( "BulletMesh", 5.0, 3.0, 6, 7 );
	prev_bullet_time = 0;
}

void PlayerShip::init(){
	wait_up = false;
	touch   = false;
}


//!  Apply Plaeyr Controls
/*virtual*/ void PlayerShip::applyControls( float age ){
	if( control_fire_weapon ){
		trackTarget();
	}

	Ship::applyControls( age );


	if( ply_light != NULL ){
		ply_light->setPosition( getPosition() /*- getViewAxis() * 200.0f*/ );
		ply_light->setSpotDirection( getViewAxis() );
	}

#if 0
	if( control_fire_weapon ){
		if( sys_time - prev_bullet_time > BULLET_RATE ){
			prev_bullet_time = sys_time;


			ModelInstance *mi_bullet = new ModelInstance( "Bullet", bullet );
			mi_bullet->copyOrientation( *mi );
			mi_bullet->setPosition( getPosition() + getViewAxis() * 5 - GetUpAxis() * 5 );
			mi_bullet->tick_translation = 
				getViewAxis() * speed +
				getViewAxis() * BULLET_SPEED;
			mi_bullet->setMaterial( &Material::GRAY_75 );
			ui->getScene()->addInstance( mi_bullet );
			mi_bullet->setCollisionGroup( sb );
			/*

#define SIDE 4
#define MASS 0.1f
			dMass     *mass    = new dMass;
			RigidBody *new_box = NULL;
			Box       *box     = NULL;
			dGeom     *geom    = NULL;

			mass->setBox( 1, SIDE, SIDE, SIDE );
			mass->adjust( MASS );

			box   = new Box( "Box", SIDE, SIDE, SIDE );
			geom  = new dGeom;
			geom->createBox( *space, SIDE, SIDE, SIDE );

			new_box = new RigidBody( "Box", box, geom );
			new_box->setMaterial( &Material::WHITE );
			ui->getScene()->addInstance( new_box );

			new_box->setPosition ( mi->getPosition() );
			new_box->setMass     ( mass );
			new_box->setData     ( NULL );
			new_box->setLinearVel( mi->getViewAxis() * BULLET_SPEED );
#undef SIDE	  */

			ui->playPulse();
		}
	}
#endif
}


};  //  namespace Application


