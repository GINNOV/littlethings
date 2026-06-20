
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


#include "PhysicalComponents/Style.h"
#include "Graphics/Color.h"
#include "Graphics/Font.h"
#include <cstring>
using namespace Graphics;


namespace PhysicalComponents {


/*static*/ Style *Style::default_style = NULL;	// Can't initialize here; there is no OpenGL context yet so there can't be default font. Done in View constructor.


//!  Constructor
Style::Style(){ 
		large_font				   = Font::default_font;
		medium_font 			   = Font::default_font;
		small_font				   = Font::default_font;
		window_title_font		   = Font::default_font;
		group_title_font		   = Font::default_font;
		monospace_font			   = Font::default_font;
		basic_font				   = Font::default_font;
		button_font 			   = Font::default_font;
		inner_x_space_pixels	   = 2;
		inner_y_space_pixels	   = 2;
		hilight_color			   = Color::WHITE;
		shadow_color			   = Color::BLACK;
		background_color		   = Color(0.0f,0.3f,0.5f);
		fill_color				   = Color::DARK_GREEN;
		text_color				   = Color::WHITE;
		frame_color 			   = Color::YELLOW;//(0.1f,0.4f,0.5f);
		border_color_fill		   = Color::YELLOW;
		border_color_hilight	   = Color::LIGHT_YELLOW;
		border_color_shadow 	   = Color::DARK_YELLOW;
		selection_background_color = Color::RED;
		selection_foreground_color = Color::WHITE;
		frame_x_pixels			   = 2;
		frame_y_pixels			   = 2;
		glyph_x_pixels			   = 10;
		glyph_y_pixels			   = 10;

};


//!  Destructor
/*virtual*/ Style::~Style(){
}


};	//	namespace PhysicalComponents

