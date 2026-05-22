
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


#include "PhysicalComponents/Dock.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"


namespace PhysicalComponents {


//!  Constructor
Dock::Dock( const char *name ):Area(name){
	this->constraint = new LayoutConstraint();
}


//!  Destructor
/*virtual*/ Dock::~Dock(){
}


//!  Area Layout Interface - Begin placement process for children
/*virtual*/ void Dock::beginPlace(){
	cursor_x = style->inner_x_space_pixels;
	cursor_y = style->inner_y_space_pixels;
}


//!  Area interface
/*virtual*/ void Dock::insert( Area *area ){
/*	int w;
	int h;*/
	Area::insert( area );
	getMinSize( constraint->min_x_fill_pixels, constraint->min_y_fill_pixels );
/*	constraint->min_x_fill_pixels = w;
	constraint->min_y_fill_pixels = h;*/
}


//!  Area Layout Interface - End placement process for children
/*virtual*/ void Dock::endPlace(){
}


};  //  namespace PhysicalComponents

