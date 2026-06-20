
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


#include "Graphics/Features.h"
#include "Graphics/Font.h"
#include "Graphics/View.h"
#include "PhysicalComponents/Button.h"
#include "PhysicalComponents/Frame.h"
#include "PhysicalComponents/GradientFill.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include <cstring>


namespace PhysicalComponents {


//! Constructor
Button::Button( const char *label ):Area( label ),label(label){
	this->label = label;

	constraint	= new LayoutConstraint();
	constraint->local_x_offset_pixels  = style->inner_x_space_pixels;
	constraint->local_y_offset_pixels  = style->inner_y_space_pixels;
	constraint->min_x_fill_pixels	   = strlen(label) * style->button_font->getWidth() + (style->inner_x_space_pixels)*2;
	constraint->min_y_fill_pixels	   = style->button_font->getHeight() + (style->inner_y_space_pixels)*2;

	this->insert(
		new GradientFill(
			Color( 0.8f, 0.8f, 0.8f, 0.5f ),
			Color( 0.7f, 0.7f, 0.7f, 0.5f ),
			Color( 0.5f, 0.5f, 0.5f, 0.5f ),
			Color( 0.6f, 0.6f, 0.6f, 0.5f )
		)
	);

	state	 = up;
	ordering = post_self;
}


//!  Area interface
/*virtual*/ void Button::drawSelf(){
	view->setPolygonMode( GL_FILL );
	view->enable( BLEND );
	view->enable( TEXTURE_2D );
	view->setBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	style->text_color.glApply();
	drawString( style->button_font, label, style->inner_x_space_pixels, style->inner_y_space_pixels );
}


};	//	namespace PhysicalComponents

