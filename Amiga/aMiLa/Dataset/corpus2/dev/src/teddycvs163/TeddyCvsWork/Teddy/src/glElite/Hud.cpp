
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


#include "config.h"
#include "glElite/Hud.h"
#include "glElite/ui.h"
#include "glElite/version.h"
#include "glElite/PlayerShip.h"
#include "glElite/RoamInstance.h"
#include "glElite/RoamSphere.h"
#include "glElite/ShipType.h"
#include "Graphics/View.h"
#include "Graphics/Features.h"
#include "Materials/SdlTexture.h"
#include "Maths/Vector.h"
#include "Models/ModelInstance.h"
#include "PhysicalComponents/GradientFill.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "PhysicalComponents/WindowFrame.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
#include <cstdio>
using namespace Graphics;
using namespace Models;
using namespace PhysicalComponents;
using namespace Scenes;


namespace Application {


float average_priority_class[10];


//!  Constructor
Hud::Hud( UI *ui ):Area("Hud"){
	this->ui      = ui;
	target_matrix = NULL;

	constraint    = new LayoutConstraint();
	constraint->local_x_offset_pixels  =  10;
	constraint->local_y_offset_pixels  =  24;
	constraint->parent_x_fill_relative =   1;
	constraint->local_x_fill_pixels    = -20;

#if defined( _DEBUG )
	constraint->local_y_fill_pixels    =  95;
#else
	constraint->local_y_fill_pixels    =  50;
#endif

	for( int i=0; i<10; i++ ){
		average_priority_class[i] = 0;
	}

#if !defined( USE_TINY_GL )
	this->insert(
		new PhysicalComponents::GradientFill(  
			Color( 0.3f, 0.5f, 0.0f, 0.8f ),
			Color( 0.3f, 0.5f, 0.0f, 0.8f ),
			Color( 0.1f, 0.4f, 0.0f, 0.5f ),
			Color( 0.1f, 0.4f, 0.0f, 0.5f )
		)
	);

	WindowFrame *f1 = new WindowFrame( "Heads Up Display" );
	this->insert( f1 );
		
#endif

	ordering = post_self;
}


//!  Set HUD target matrix
void Hud::setTargetMatrix( Matrix *target ){
	this->target_matrix = target;
}


extern double speed;


//!  Drawing code - FIX, ugly code...
void Hud::drawSelf(){
	char        hud[100];
	const char *name;
	char       *unit;
	Ship       *ship     = ui->getPlayerShip();
	float       dst      = 0;
	float       distance = 0;
	double      radius   = 0;
	double      angle    = 0;
	double      kal_h    = 0;

	view->enable( BLEND );  
	view->enable( TEXTURE_2D );
	view->setBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );

	if( ship->getTarget() != NULL ){
		name     = ship->getTarget()->getName();
		distance = ship->distanceTo( *(ship->getTarget()) );
		dst      = distance;
		unit     = "m";
		if( fabs(distance)>1000.0f ){
			distance *= 0.001f;
			unit      = "km";
		}
		if( fabs(distance)>1000.0f ){
			distance *= 0.001f;
			unit      = "tkm";
		}
		if( fabs(distance)>1000.0f ){
			distance *= 0.001f;
			unit      = "Mkm";
		}
	}else{
		name = "-";
		unit = "";
	}		 

	float alpha = 0.9f;

#if 0
	for( int i=0; i<10; i++ ){
		average_priority_class[i] = alpha * average_priority_class[i] + (1-alpha) * (float)(priority_class[i]);
	}
#endif
	color( 0.5f, 1.0f, 0.5f, 1.0f );

	sprintf(
		hud,
		"Teddy %d.%d % 6.1f fps % 6.1f ms Alt: % 6.1f Target: %s %.3f %s",
		TEDDY_VERSION_MAJOR,
		TEDDY_VERSION_MINOR,
		view->fps,
		view->last_frame,
		0.0f, // roam_height,
		name,
		distance,
		unit
	);
	drawString( style->small_font, hud, 5, 8 );

	float  speed = ship->getSpeed() * 100.0f;
	char  *speed_unit = "m/s";
	if( fabs(speed) < 0.1f ){
		speed      *= 100.0f;
		speed_unit  = "cm/s";
	}
	if( fabs(speed) < 0.1f ){
		speed      *= 10.0f;
		speed_unit  = "mm/s";
	}
	if( fabs(speed) > 1000.0f ){
		speed      *= 0.001f;
		speed_unit  = "km/s";
	}
	if( fabs(speed) > 1000.0f ){
		speed      *= 0.001f;
		speed_unit  = "tkm/s";
	}
	if( fabs(speed) > 1000.0f ){
		speed      *= 0.001f;
		speed_unit  = "Mkm/s";
	}

	color( 1.0f, 0.8f, 0.3f, 1.0f );
	sprintf(
		hud,
		"Pitch: % 2.2f Roll % 2.2f Speed %.3f %s",
		ship->getPitch() * 1000,
		ship->getRoll()  * 1000,
		speed,
		speed_unit
	);
	drawString( style->small_font, hud, 5, 17 );

#ifdef _DEBUG
	int row;
//	drawString( style->small_font, "Debug Matrix:", 50, 50 );
	if( target_matrix != NULL ){
		for( row=0; row<4; row++ ){
			sprintf(
				hud,
				" % 7.2f % 7.2f % 7.2f % 7.2f",
				target_matrix->m[0][row],
				target_matrix->m[1][row],
				target_matrix->m[2][row],
				target_matrix->m[3][row]
			);
			drawString( style->small_font, hud, 5, 50+10*row );
		}
	}

#if 0

	color( 0.8f, 1.0f, 0.8f, 1.0f );
	sprintf( hud, "X: % 10.3f", (float)ship->getPosition().x ); drawString( style->small_font, hud, 280, 50 );
	sprintf( hud, "Y: % 10.3f", (float)ship->getPosition().y ); drawString( style->small_font, hud, 280, 60 );
	sprintf( hud, "Z: % 10.3f", (float)ship->getPosition().z ); drawString( style->small_font, hud, 280, 70 );

#else

	if( ship->getTarget() != NULL ){
		Vector tpos   = ship->getTarget()->getPosition();
		Vector cpos   = ship->getPosition();
		Vector delta  = tpos - cpos;
		Vector cview  = ship->getViewAxis();
		Vector cup    = ship->getUpAxis();
		Vector cright = ship->getRightAxis();
		delta .normalize();
		float  view_dp  = cview  | delta;
		float  up_dp    = cup    | delta;
		float  right_dp = cright | delta;
		float  brk_dst  = ship->getBrakeDistance();

		color( 0.8f, 1.0f, 0.8f, 1.0f );
		sprintf( hud, "V: %- 6.2f", view_dp  ); drawString( style->small_font, hud, 280, 50 );
		sprintf( hud, "U: %- 6.2f", up_dp    ); drawString( style->small_font, hud, 280, 60 );
		sprintf( hud, "R: %- 6.2f", right_dp ); drawString( style->small_font, hud, 280, 70 );
//		sprintf( hud, "U: %- 6.2f", ship->getPitchDistance() ); drawString( style->small_font, hud, 280, 60 );
//		sprintf( hud, "R: %- 6.2f", ship->getRollDistance () ); drawString( style->small_font, hud, 280, 70 );
		sprintf( hud, "D: %- 6.2f", brk_dst  ); drawString( style->small_font, hud, 280, 80 );

	}
#endif

#if 0
	view->color( 0.6f, 0.8f, 1.0f, 1.0f );
	char c = (roam_update==true)?'T':'F';
	sprintf( hud, "Err: % 5.4f %c",   (float)roam_const*1000.0f, c ); drawString( style->small_font, hud, 400, 50 );
	sprintf( hud, "Tri: % 7d",        roam_triangle_count          ); drawString( style->small_font, hud, 400, 60 );
	sprintf( hud, "D/C: % 3d / % 3d", Scene::drawn, Scene::culled  ); drawString( style->small_font, hud, 400, 70 );
#endif

#endif

	view->disable( TEXTURE_2D );

	color( 0.0f, 0.0f, 0.0f, 70.5f );
	drawFillRect( 40-20-1, 30-2,  44+20+1, 40+1 );
	drawFillRect(100-20-1, 30-2, 104+20+1, 40+1 );
	drawFillRect(200   -1, 30-2, 400   +1, 40+1 );

	color( 1.0f, 1.0f, 0.0f, 0.95f );
	drawRect ( 40-20-2, 30-3,  44+20+2, 40+2 );
	drawRect (100-20-2, 30-3, 104+20+2, 40+2 );
	drawRect (200     , 30-3, 400     , 40+2 );

	color( 1.0f, 1.0f, 1.0f, 1.0f );
	beginLines();
	vertex2i(  42, 30 );
	vertex2i(  42, 40 );
	vertex2i( 102, 30 );
	vertex2i( 102, 40 );
	vertex2i( 300, 30 );
	vertex2i( 300, 40 );
	end();


	color( 0.25f, 1.0f, 0.25f, 0.75f );

	int roll  = (int)(ship->getRoll () * 20 / ship->getShipType()->getMaxRoll () + 0.5);
	int pitch = (int)(ship->getPitch() * 20 / ship->getShipType()->getMaxPitch() + 0.5);
	int spd   = (int)(ship->getSpeed() * 15 + 0.5);
	drawFillRect(  40 + roll , 30,  44 + roll , 40 );
	drawFillRect( 100 + pitch, 30, 104 + pitch, 40 );
	if( spd == 0 ){
		spd = 1;
	}
	if( spd > 0 ){
		color( 0.5f, 1.0f, 0.25f, 0.75f );
	}else{
		color( 1.0f, 0.5f, 0.25f, 0.75f );
	}
	drawFillRect( 300 , 30, 300 + spd, 40 );

}


};  //  namespace Application

