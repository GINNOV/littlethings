
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


#include "PhysicalComponents/ActionButton.h"
#include "PhysicalComponents/LayoutConstraint.h"
#include "PhysicalComponents/Style.h"
#include "PhysicalComponents/WindowManager.h"
#include "Graphics/Features.h"
#include "Graphics/Font.h"
#include "Graphics/View.h"
#include <cstring>
using namespace Graphics;


namespace PhysicalComponents {


//!  Constructor
ActionButton::ActionButton(
	const char *name,
	Area	   *target,
	EventMask   in_event_mask,
	Event	    out_event,
	Color	    color )
:	Area(name),
	EventListener(in_event_mask),
	label(name)
{

	constraint = new LayoutConstraint();
	constraint->local_x_fill_pixels 	= strlen(name) * style->button_font->getWidth() + (style->inner_x_space_pixels)*2;
	constraint->local_y_fill_pixels 	= style->glyph_y_pixels;
	constraint->local_y_offset_relative = -1;
	constraint->local_y_offset_pixels	= -style->frame_y_pixels - 1;
	this->ordering	 = pre_self;
	this->color 	 = color;
	this->out_event  = out_event;
	this->target	 = target;
}


//!  Destructor
ActionButton::~ActionButton(){
	//	FIX
}


//!  Return event target
/*virtual*/ Area *ActionButton::getTarget( const Event e ){
	return target;
}


//!  Drawing code
void ActionButton::drawSelf(){
	view->disable( TEXTURE_2D );

#	if !defined( USE_TINY_GL )
	int width;
	int height;

	getSize( width, height );
	color.glApply();
	this->drawFillRect( 1, 1, width-1, height-1 );
	drawBiColRect( style->hilight_color, style->shadow_color,  0, -1, width, height-1 );
#	endif

	view->setPolygonMode( GL_FILL );
	view->enable( BLEND );
	view->enable( TEXTURE_2D );
	view->setBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	style->text_color.glApply();
	drawString( style->button_font, label, style->inner_x_space_pixels, style->inner_y_space_pixels );
}


//!  MouseListener interface
/*virtual*/ void ActionButton::mouseKey( const int button, const int state, const int x, const int y ){
	window_manager->event( out_event, this, target->getTarget(out_event), x, y );
}


//!  MouseListener interface
/*virtual*/ void ActionButton::mouseDrag( const int button, const int x, const int y, const int dx, const int dy ){
	window_manager->event( out_event, this, target->getTarget(out_event), dx, dy );
}


};	//	namespace PhysicalComponents

