
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
	\class   Font
	\ingroup g_graphics
	\author  Timo Suoranta
	\brief   Glyph rendering with OpenGL textured quads
	\todo    Freetype
	\date    2000, 2001

	This class implements glyph storing and rendering code
	(but it is not Renderable).

	Implementation is very primitive at the moment. Later,
	FreeType library could be intergrated here.

	This class is currently for OpenGL.
*/


#ifndef TEDDY_GRAPHICS_FONT_H
#define TEDDY_GRAPHICS_FONT_H


namespace Graphics {


class Texture;
class View;


class Font {
public:
	Font( const char *fname ); 

	void drawString( View *v, const char *str, int xp, int yp );
	int  getWidth  ();
	int  getHeight ();

	static Font *default_font;

private:
	Texture     *texture;  //!<  Texture object
	float        x[256];   //!<  Texture coordinates, char = index
	float        y[256];   //!<  Texture coordinates, char = index
	int          x_pos;
	int          y_pos;
	int          cw;       //!<  Char width in pixels
	int          cwl;      //!<  Char width-1 in pixels
	int          ch;       //!<  Char height
	float        tw;       //!<  Char width in texture coords
	float        twl;      //!<  Char width-1 pixel in texture coords
	float        th;       //!<  Char height in texture coords
};


};  //  namespace Graphics


#endif  //  TEDDY_GRAPHICS_FONT_H

