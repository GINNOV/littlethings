
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


#include "PhysicalComponents/HSplit.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "PhysicalComponents/WindowManager.h"


namespace PhysicalComponents {


//!  Constructor
HSplit::HSplit( const char *name, Area *target ):Area(name),EventListener(EVENT_MOUSE_KEY_M|EVENT_MOUSE_DRAG){
	this->target = target;
	this->drag   = false;
	constraint = new LayoutConstraint();
	constraint->local_x_fill_pixels    = style->glyph_x_pixels;
	constraint->parent_y_fill_relative = 1.0;
	ordering = pre_self;
}


//!  Destructor
/*virtual*/ HSplit::~HSplit(){
	//  FIX
}


//!  Return event target
/*virtual*/ Area *HSplit::getTarget(){
	return this->target;
}


//!  Drawing code
void HSplit::drawSelf(){
	int width;
	int height;

	getSize( width, height );
	style->fill_color.glApply();
	drawFillRect( 1, 1, width-1, height-1 );
	drawBiColRect( style->hilight_color, style->shadow_color,  0, -1, width, height-1 );
}


//!  EventListener Interface
/*virtual*/ void HSplit::mouseDrag( const Uint32 button_mask, const int x, const int y ){
	window_manager->event( EVENT_SPLIT_UPDATE, this, target, x, y );
}


};  //  namespace PhysicalComponents

