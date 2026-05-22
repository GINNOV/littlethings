
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


#include "config.h"
#include "glElite/Scanner.h"
#include "glElite/ui.h"
#include "Graphics/View.h"
#include "Materials/Material.h"
#include "Materials/SdlTexture.h"
#include "Maths/Vector.h"
#include "Models/ModelInstance.h"
#include "PhysicalComponents/GradientFill.h"
#include "PhysicalComponents/TextureFill.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "PhysicalComponents/WindowFrame.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
#include <cstdio>
using namespace Graphics;
using namespace Models;
using namespace PhysicalComponents;


namespace Application {


//!  Constructor
Scanner::Scanner( UI *ui ):Area("Scanner"){
//	txt = new SdlTexture("frontier_scanner.png");
	txt = new SdlTexture( "gui/scanner.png" );

	this->ui		 = ui;
	this->camera	 = ui->getCamera();
	this->constraint = new LayoutConstraint();
	constraint->local_x_offset_relative  =	-1;
	constraint->local_y_offset_relative  =	-1;
	constraint->local_x_offset_pixels	 = -10;
	constraint->local_y_offset_pixels	 = -10;
	constraint->parent_x_offset_relative =	 1;
	constraint->parent_y_offset_relative =	 1;
	constraint->local_x_fill_pixels 	 = 256;
	constraint->local_y_fill_pixels 	 =	70;

	this->insert(
		new PhysicalComponents::GradientFill(
			Color( 0.7f, 0.0f, 0.1f, 0.83f ),
			Color( 0.7f, 0.0f, 0.1f, 0.83f ),
			Color( 0.7f, 0.0f, 0.1f, 0.53f ),
			Color( 0.7f, 0.0f, 0.1f, 0.53f )
		)
	);

	this->insert(
		new WindowFrame( "Scanner" )
	);

	range	 = 8;
	ordering = post_self;
}


void Scanner::cycle(){
	range = (range<32)? range*=2 : 1;
}


//!  Drawing code
void Scanner::drawSelf(){
	color( C_WHITE );
	if( txt != NULL ){
		view->blit( txt, this->viewport[0], this->viewport[1] );
	}

	return;
	view->disable( TEXTURE_2D );

	list<ModelInstance*> instances = camera->getScene()->getInstances();
	Vector loc;
	int    x,  y,  z;
	int    x1, y1, y2;

	Matrix w2l = camera->worldToLocal();

	list<ModelInstance*>::iterator i_it = instances.begin();
	while( i_it != instances.end() ){
		Vector pos = (*i_it)->getPosition();
		Vector loc = w2l.transformVector( pos );
		loc = loc * (float)(range);

        Color c;
		Material *mat = (*i_it)->getMaterial();
		if( mat != NULL ){
			c = mat->getDiffuse();
		}else{
			c = Color::GRAY_50;
		}
        color( c );

		x = (int)( loc.v[0] * 0.01 );
		y = (int)( loc.v[1] * 0.01 );
		z = (int)( loc.v[2] *-0.01 );
				
		x1 = x;
		y1 = -z / 4;
		y2 = y1 - y / 2;
				
		if( (y2 > - 50) && (y2 < 50) &&
			(x1 > -100) && (x1 <100)	)
		{
				
			x1 += 127;
			y1 += 31;
			y2 += 31;
				
			beginLines();
			vertex2i( x1  , y2	 ); vertex2i( x1+3, y2	 );
			vertex2i( x1  , y2+1 ); vertex2i( x1+4, y2+1 );
			vertex2i( x1  , y2+2 ); vertex2i( x1+4, y2+2 );
			vertex2i( x1  , y2+3 ); vertex2i( x1+3, y2+3 );
			vertex2i( x1  , y1	 ); vertex2i( x1  , y2	 );
			vertex2i( x1+1, y1	 ); vertex2i( x1+1, y2	 );
			end();
		}
		i_it++;
	}
}


};	//	namespace Application

