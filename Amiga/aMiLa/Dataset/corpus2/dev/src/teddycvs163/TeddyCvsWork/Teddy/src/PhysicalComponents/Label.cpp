
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


#include "PhysicalComponents/Label.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "Graphics/Features.h"
#include "Graphics/Font.h"
#include "Graphics/View.h"
#include <cstring>


namespace PhysicalComponents {


//!  Constructor
Label::Label( char *label ):Area(label),text(label){
	this->constraint = new LayoutConstraint();
	this->constraint->local_x_offset_pixels = style->inner_x_space_pixels;
	this->constraint->local_y_offset_pixels = style->inner_y_space_pixels;
	this->constraint->local_x_fill_pixels	= strlen(label) * style->button_font->getWidth() + style->inner_x_space_pixels*2;
	this->constraint->local_y_fill_pixels	= style->button_font->getHeight() + style->inner_y_space_pixels*2;
	ordering = post_self;
}


//!  Area interface
/*virtual*/ void Label::drawSelf(){
	view->enable( BLEND );
	view->enable( TEXTURE_2D );
	view->setBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	style->hilight_color.glApply();
	drawString( style->button_font, text, style->inner_x_space_pixels, style->inner_y_space_pixels );
	view->disable( TEXTURE_2D );
}


void Label::setText( char *text ){
	this->text = text;
}


char *Label::getText(){
	return this->text;
}


};	//	namespace PhysicalComponents

