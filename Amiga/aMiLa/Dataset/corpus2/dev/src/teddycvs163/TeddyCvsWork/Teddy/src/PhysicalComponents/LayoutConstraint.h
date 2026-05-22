
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

/*!
	\class   LayoutConstraint
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Layout Constraints for Areas
	\date    2000, 2001

	LayoutConstraint contains parameters of Area to
	help choose corrent placing (location and size)
	for areas.
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_LAYOUT_CONSTRAINT_H
#define TEDDY_PHYSICAL_COMPONENTS_LAYOUT_CONSTRAINT_H


namespace PhysicalComponents {


class LayoutConstraint {
public:
	LayoutConstraint();

	//  Positioning
	int   local_x_offset_pixels;
	int   local_y_offset_pixels;
	float local_x_offset_relative;
	float local_y_offset_relative;
	int   parent_x_offset_pixels;
	int   parent_y_offset_pixels;
	float parent_x_offset_relative;
	float parent_y_offset_relative;

	//  Sizing
	int   min_x_fill_pixels;       //  Negative = not in use
	int   min_y_fill_pixels;       //  Negative = not in use
	int   max_x_fill_pixels;	   //  Negative = not in use
	int   max_y_fill_pixels;       //  Negative = not in use
	float parent_x_fill_relative;  //  Negative = not in use  
	float parent_y_fill_relative;  //  Negative = not in use
	int   local_x_fill_pixels;
	int   local_y_fill_pixels;

	static LayoutConstraint default_constraint;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_LAYOUT_CONSTRAINT_H

