
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


#include "PhysicalComponents/Frame.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "PhysicalComponents/WindowManager.h"
#include "Graphics/Color.h"
#include <cstdio>
using namespace Graphics;


namespace PhysicalComponents {


//!  Default constructor
Frame::Frame( const char *name ):Area(name){
	printf( "Frame::Frame...\n" );
	constraint = new LayoutConstraint();
	constraint->local_x_offset_pixels  =  -style->frame_x_pixels;
	constraint->local_y_offset_pixels  =  -style->frame_y_pixels;
	constraint->local_x_fill_pixels    = 2*style->frame_x_pixels;
	constraint->local_y_fill_pixels    = 2*style->frame_y_pixels;
	constraint->parent_x_fill_relative = 1.0;
	constraint->parent_y_fill_relative = 1.0;
	ordering = pre_self;
}


//!  Destructor
/*virtual*/ Frame::~Frame(){
	//	FIX
}


//!  Drawing code
void Frame::drawSelf(){
	int width;
	int height;

	getSize( width, height );

	style->shadow_color.glApply();
	drawRect( 0, 0, width, height );
	drawBiColRect( style->hilight_color, style->shadow_color, 1, 1, width-1, height-1 );
}


};	//	namespace PhysicalComponents

