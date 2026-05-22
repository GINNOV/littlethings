
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


#include "PhysicalComponents/GradientFill.h"
#include "Graphics/Features.h"
#include "Graphics/View.h"


namespace PhysicalComponents {


//!  Default constructor
GradientFill::GradientFill( const Color &left_top, const Color &right_top, const Color &right_bottom, const Color &left_bottom ):Fill(){
	//  Assign colors
	this->left_top     = left_top;
	this->right_top    = right_top;
	this->right_bottom = right_bottom;
	this->left_bottom  = left_bottom;
}


//!  Rendering overlay window
void GradientFill::drawSelf(){
#	if defined( USE_TINY_GL )
	return;
#	endif

	int width;
	int height;

	getSize( width, height );

	//	FIX add glPolygonMode();

	view->setPolygonMode( GL_FILL );
	view->enable        ( BLEND );
	view->disable       ( TEXTURE_2D );
	view->setBlendFunc  ( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	view->setShadeModel ( GL_SMOOTH );

	beginQuads();
	color( left_top     ); vertex2i( 0, 0 );
	color( right_top    ); vertex2i( width, 0 );
	color( right_bottom ); vertex2i( width, height );
	color( left_bottom  ); vertex2i( 0, height );
	end();
}


};  //  namespace PhysicalComponents

