
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


#include "PhysicalComponents/LayoutConstraint.h"


namespace PhysicalComponents {


//!  Default constraint
LayoutConstraint LayoutConstraint::default_constraint = LayoutConstraint();


//!  Constructor
LayoutConstraint::LayoutConstraint(){
	local_x_offset_pixels    =  0;
	local_y_offset_pixels    =  0;
	local_x_offset_relative  =  0;
	local_y_offset_relative  =  0;
	parent_x_offset_pixels   =  0;
	parent_y_offset_pixels   =  0;
	parent_x_offset_relative =  0;
	parent_y_offset_relative =  0;
	min_x_fill_pixels        = -1;
	min_y_fill_pixels        = -1;
	max_x_fill_pixels        = -1;
	max_y_fill_pixels        = -1;
	parent_x_fill_relative   = -1;
	parent_y_fill_relative   = -1;
	local_x_fill_pixels      =  0;
	local_y_fill_pixels      =  0;
}


};  //  namespace PhysicalComponents

