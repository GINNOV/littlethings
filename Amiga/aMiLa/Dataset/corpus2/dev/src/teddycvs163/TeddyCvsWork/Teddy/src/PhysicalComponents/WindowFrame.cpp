
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


#include "PhysicalComponents/WindowFrame.h"
#include "PhysicalComponents/ActionButton.h"
#include "PhysicalComponents/Button.h"
#include "PhysicalComponents/HSplit.h"
#include "PhysicalComponents/Label.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "Graphics/Features.h"
#include "Graphics/Font.h"
#include "Graphics/View.h"
#include <cstdio>
using namespace Graphics;


namespace PhysicalComponents {


//!  Default constructor
WindowFrame::WindowFrame( const char *name ):HDock(name){
	constraint = new LayoutConstraint();
	constraint->local_x_offset_pixels  =   -style->frame_x_pixels;
	constraint->local_y_offset_pixels  =   -style->frame_y_pixels;
	constraint->local_x_fill_pixels    = 2* style->frame_x_pixels;
	constraint->local_y_fill_pixels    = 2* style->frame_y_pixels;
	constraint->parent_x_fill_relative = 1;
	constraint->parent_y_fill_relative = 1;
	color    = style->frame_color;
	ordering = pre_self;

	this->insert(  new ActionButton( " Size ",     this, EVENT_MOUSE_DRAG_M, EVENT_SIZE,         Color::DARK_RED    )  );
	this->insert(  new ActionButton( ":",          this, EVENT_MOUSE_DRAG_M, EVENT_SPLIT_UPDATE, Color::GRAY_50     )  );
	this->insert(  new ActionButton( " Move ",     this, EVENT_MOUSE_DRAG_M, EVENT_MOVE,         Color::DARK_YELLOW )  );
#	if 0
	this->insert(  new ActionButton( ":",          this, EVENT_MOUSE_DRAG_M, EVENT_SPLIT_UPDATE, Color::GRAY_50     )  );
	this->insert(  new ActionButton( " To Front ", this, EVENT_MOUSE_KEY_M,  EVENT_TO_FRONT,     Color::DARK_GREEN  )  );
	this->insert(  new ActionButton( ":",          this, EVENT_MOUSE_DRAG_M, EVENT_SPLIT_UPDATE, Color::GRAY_50     )  );
	this->insert(  new ActionButton( " To Back ",  this, EVENT_MOUSE_KEY_M,  EVENT_TO_BACK,      Color::DARK_BLUE   )  );
#	endif
}	


//!  Destructor FIX
/*virtual*/ WindowFrame::~WindowFrame(){
}


//!  Return event target
/*virtual*/ Area *WindowFrame::getTarget( const Event e ){
	if( e==EVENT_SPLIT_UPDATE ){
		return this;
	}else{
		return this->parent;
	}
}


void WindowFrame::setColor( Color c ){
	this->color = c;
}


//!  Drawing code
void WindowFrame::drawSelf(){
#	if defined( USE_TINY_GL )
	return;
#	endif

	int width;
	int height;

	getSize( width, height );

	view->disable( TEXTURE_2D );

	drawBiColRect( style->border_color_shadow,  style->border_color_hilight, style->frame_x_pixels-1, style->frame_y_pixels-2, width-style->frame_x_pixels+1, height-style->frame_y_pixels );
	drawBiColRect( style->border_color_hilight, style->border_color_shadow,   0, -1, width, height-1 );

	int x0 = style->frame_x_pixels - 1;
	int y0 = style->frame_y_pixels - 1;
	int x1 = width  - style->frame_x_pixels+1;
	int y1 = height - style->frame_y_pixels+1;
	int x2 = width  - 1;
	int y2 = height;

	view->setPolygonMode( GL_FILL );
	color.glApply();

	beginQuads();

	vertex2i( 1,  1  );
	vertex2i( x2, 1  );
	vertex2i( x2, y0 );
	vertex2i( 1,  y0 );

	vertex2i( 1,  y1   );
	vertex2i( x2, y1   );
	vertex2i( x2, y2-1 );
	vertex2i( 1,  y2-1 );

	vertex2i( 1,  y0 );
	vertex2i( x0, y0 );
	vertex2i( x0, y1 );
	vertex2i( 1,  y1 );

	vertex2i( x1, y0 );
	vertex2i( x2, y0 );
	vertex2i( x2, y1 );
	vertex2i( x1, y1 );

	end();

	view->setPolygonMode( GL_FILL );
	view->enable( BLEND );
	view->enable( TEXTURE_2D );
	view->setBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	style->text_color.glApply();
	drawString(
		style->button_font,
		name,
		style->inner_x_space_pixels,
		- style->button_font->getHeight() * 2 - (style->inner_y_space_pixels)*2
	);

}


};  //  namespace PhysicalComponents

