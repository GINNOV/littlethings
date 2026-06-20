
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


#include "glElite/Sight.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/GradientFill.h"
#include "PhysicalComponents/Frame.h"
#include "Graphics/Features.h"
#include "Graphics/View.h"
using namespace PhysicalComponents;


namespace Application {


#define x_term 16
#define y_term 16


/*
  0 1 2 3 4
  . . . . . 	0
  . . | . . 	1 
  ._. . ._. 	2				(2,2,) offset
  . . . . . 3
  . . | . . 4
*/


/*virtual*/ void Sight::place( int offset_x, int offset_y ){
	Area::place( offset_x, offset_y );
}


//!  Constructor
Sight::Sight():Area("Sight"){
	constraint = new LayoutConstraint();
	constraint->local_x_offset_relative  = -0.5;
	constraint->local_y_offset_relative  = -0.5;
	constraint->parent_x_offset_relative =  0.5;
	constraint->parent_y_offset_relative =  0.5;
	constraint->local_x_fill_pixels      = 4*x_term;
	constraint->local_y_fill_pixels      = 4*y_term;
		
/*	this->insert(
		new PhysicalComponents::GradientFill(
			Color( 0.6, 0.0, 0.0, 0.4 ),
			Color( 0.6, 0.0, 0.0, 0.4 ),
			Color( 0.6, 0.0, 0.0, 0.4 ),
			Color( 0.6, 0.0, 0.0, 0.4 )
		)
	);*/
/*	this->insert(
		new Frame()
	); */

}


//!  Destructor
/*virtual*/ Sight::~Sight(){
}


float ctrlpoints[4][3] = {
	{   60.0,  60.0, 0.0 },
	{   80.0, 130.0, 0.0 },
	{  120.0,  70.0, 0.0 },
	{  140.0, 140.0, 0.0 }
};

static int whichPoint =  0;
static int nLines 	= 10;

//!  Drawing code
void Sight::drawSelf(){
	view->disable( TEXTURE_2D );
//		view->disable( DEPTH_TEST );
	color( C_LIGHT_GREEN );
	beginLines();
	vertex2i( 0*x_term, 2*y_term );
	vertex2i( 1*x_term, 2*y_term );
	vertex2i( 3*x_term, 2*y_term );
	vertex2i( 4*x_term, 2*y_term );
	vertex2i( 2*x_term, 0*y_term );
	vertex2i( 2*x_term, 1*y_term );
	vertex2i( 2*x_term, 3*y_term );
	vertex2i( 2*x_term, 4*y_term );
	end();
	
	color( C_BLACK );
	beginLines();
	vertex2i( 0*x_term,   2*y_term-1 );
	vertex2i( 1*x_term,   2*y_term-1 );
	vertex2i( 3*x_term,   2*y_term-1 );
	vertex2i( 4*x_term,   2*y_term-1 );
	vertex2i( 0*x_term,   2*y_term+1 );
	vertex2i( 1*x_term,   2*y_term+1 );
	vertex2i( 3*x_term,   2*y_term+1 );
	vertex2i( 4*x_term,   2*y_term+1 );
	vertex2i( 2*x_term-1, 0*y_term );
	vertex2i( 2*x_term-1, 1*y_term );
	vertex2i( 2*x_term-1, 3*y_term );
	vertex2i( 2*x_term-1, 4*y_term );
	vertex2i( 2*x_term+1, 0*y_term );
	vertex2i( 2*x_term+1, 1*y_term );
	vertex2i( 2*x_term+1, 3*y_term );
	vertex2i( 2*x_term+1, 4*y_term );
	end();
}


};	//	namespace Application

