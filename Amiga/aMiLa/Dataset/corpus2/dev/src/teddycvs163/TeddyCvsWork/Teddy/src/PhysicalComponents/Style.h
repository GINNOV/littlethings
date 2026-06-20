
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
	\class   Style
	\ingroup g_physical_components
	\author  Timo Suoranta
	\brief   Style definition for physical components
	\date    2000, 2001

	Style defines physical appearence for physical components.
	Each area has associated style. Style defines colorscheme,
	frame, fill, size, font etc. Physical components should not
	store these properties themselves in any case; instead they
	should consider expanding Style.

	Currently Style does not implement much anything..

	Style might actually use tags?
*/


#ifndef TEDDY_PHYSICAL_COMPONENTS_STYLE_H
#define TEDDY_PHYSICAL_COMPONENTS_STYLE_H


namespace Graphics { class Font; }
#include "Graphics/Color.h"
using namespace Graphics;


namespace PhysicalComponents {


class Frame;
class Fill;


class Style {
public:
	Style();
	virtual ~Style();

	static Style *default_style;

	Font  *large_font;
	Font  *medium_font;
	Font  *small_font;
	Font  *window_title_font;
	Font  *group_title_font;
	Font  *monospace_font;
	Font  *basic_font;
	Font  *button_font;
	Frame *frame;
	Fill  *background;
	int    inner_x_space_pixels;
	int    inner_y_space_pixels;
	Color  hilight_color;
	Color  shadow_color;
	Color  fill_color;
	Color  background_color;
	Color  text_color;
	Color  frame_color;
	Color  selection_background_color;
	Color  selection_foreground_color;
	Color  border_color_fill;
	Color  border_color_hilight;
	Color  border_color_shadow;
	int    frame_x_pixels;
	int    frame_y_pixels;
	int    glyph_x_pixels;
	int    glyph_y_pixels;
};


};  //  namespace PhysicalComponents


#endif  //  TEDDY_PHYSICAL_COMPONENTS_STYLE_H

