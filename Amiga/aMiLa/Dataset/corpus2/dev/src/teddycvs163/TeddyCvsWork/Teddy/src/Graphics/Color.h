
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
	\class   Color
	\ingroup g_graphics
	\author  Timo Suoranta
	\brief   Color specified with red, green, blue and alpha components
	\bug     No limit checks
	\date    1999, 2000, 2001

	Color class stores colors, and applies them to OpenGL.
*/


#ifndef TEDDY_GRAPHICS_COLOR_H
#define TEDDY_GRAPHICS_COLOR_H


namespace Graphics {


//  Quick shortcut, not very smart...
#define C_BLACK           0.00,0.00,0.00
#define C_WHITE           1.00,1.00,1.00
#define C_RED             1.00,0.00,0.00
#define C_GREEN           0.00,1.00,0.00
#define C_BLUE            0.00,0.00,1.00
#define C_GRAY            0.50,0.50,0.50
#define C_CYAN            0.00,1.00,1.00
#define C_MAGENTA         1.00,0.00,1.00
#define C_YELLOW          1.00,1.00,0.00
#define C_ORANGE          1.00,0.50,0.00
#define C_DARK_RED        0.50,0.00,0.00
#define C_DARK_GREEN      0.00,0.50,0.00
#define C_DARK_BLUE       0.00,0.00,0.50
#define C_DARK_GRAY       0.25,0.25,0.25
#define C_DARK_CYAN	      0.00,0.50,0.50
#define C_DARK_MAGENTA    0.50,0.00,0.50
#define C_DARK_YELLOW     0.50,0.50,0.00
#define C_DARK_ORANGE     0.50,0.25,0.00
#define C_LIGHT_RED       1.00,0.50,0.50
#define C_LIGHT_GREEN     0.50,1.00,0.50
#define C_LIGHT_BLUE      0.50,0.50,1.00
#define C_LIGHT_GRAY      0.75,0.75,0.75
#define C_LIGHT_CYAN      0.50,1.00,1.00
#define C_LIGHT_MAGENTA   1.00,0.50,1.00
#define C_LIGHT_YELLOW    1.00,1.00,0.50
#define C_LIGHT_ORANGE    1.00,0.75,0.50
#define C_GRAY_50         0.50,0.50,0.50
#define C_GRAY_25         0.25,0.25,0.25
#define C_GRAY_75         0.75,0.75,0.75


class Color {
public:
	float rgba[4];

	Color();
	Color( const float r, const float g, const float b );
	Color( const float r, const float g, const float b, const float a );
	Color( const float rgba[4] );

	void   debug     ();
	void   glApply   () const;
	Color  operator+ ( const Color &c ) const;
	Color &operator+=( const Color &c );
	Color  operator- ( const Color &c ) const;
	Color &operator-=( const Color &c );
	Color  operator* ( const float &k ) const;
	Color &operator*=( const float &k );

	static Color BLACK;
	static Color WHITE;
	static Color RED;
	static Color GREEN;
	static Color BLUE;
	static Color GRAY;
	static Color CYAN;
	static Color MAGENTA;
	static Color YELLOW;
	static Color ORANGE;
	static Color DARK_RED;
	static Color DARK_GREEN;
	static Color DARK_BLUE;
	static Color DARK_CYAN;
	static Color DARK_MAGENTA;
	static Color DARK_YELLOW;
	static Color DARK_ORANGE;
	static Color LIGHT_RED;
	static Color LIGHT_GREEN;
	static Color LIGHT_BLUE;
	static Color LIGHT_CYAN;
	static Color LIGHT_MAGENTA;
	static Color LIGHT_YELLOW;
	static Color LIGHT_ORANGE;
	static Color GRAY_50;
	static Color GRAY_25;
	static Color GRAY_75;
};


};  //  namespace Graphics


#endif  //  TEDDY_GRAPHICS_COLOR_H

