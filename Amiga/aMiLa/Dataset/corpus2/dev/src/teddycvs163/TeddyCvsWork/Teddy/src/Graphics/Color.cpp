
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


#include "Graphics/Color.h"
#include "Graphics/Device.h"


namespace Graphics {


Color Color::BLACK         = Color( C_BLACK         );
Color Color::WHITE         = Color( C_WHITE         );
Color Color::RED           = Color( C_RED           );
Color Color::GREEN         = Color( C_GREEN         );
Color Color::BLUE          = Color( C_BLUE          );
Color Color::GRAY          = Color( C_GRAY          );
Color Color::CYAN          = Color( C_CYAN          );
Color Color::MAGENTA       = Color( C_MAGENTA       );
Color Color::YELLOW        = Color( C_YELLOW        );
Color Color::ORANGE        = Color( C_ORANGE        );
Color Color::DARK_RED      = Color( C_DARK_RED      );
Color Color::DARK_GREEN    = Color( C_DARK_GREEN    );
Color Color::DARK_BLUE     = Color( C_DARK_BLUE     );
Color Color::DARK_CYAN     = Color( C_DARK_CYAN     );
Color Color::DARK_MAGENTA  = Color( C_DARK_MAGENTA  );
Color Color::DARK_YELLOW   = Color( C_DARK_YELLOW   );
Color Color::DARK_ORANGE   = Color( C_DARK_ORANGE   );
Color Color::LIGHT_RED     = Color( C_LIGHT_RED     );
Color Color::LIGHT_GREEN   = Color( C_LIGHT_GREEN   );
Color Color::LIGHT_BLUE    = Color( C_LIGHT_BLUE    );
Color Color::LIGHT_CYAN    = Color( C_LIGHT_CYAN    );
Color Color::LIGHT_MAGENTA = Color( C_LIGHT_MAGENTA );
Color Color::LIGHT_YELLOW  = Color( C_LIGHT_YELLOW  );
Color Color::LIGHT_ORANGE  = Color( C_LIGHT_ORANGE  );
Color Color::GRAY_25       = Color( C_GRAY_25       );
Color Color::GRAY_50       = Color( C_GRAY_50       );
Color Color::GRAY_75       = Color( C_GRAY_75       );



//!  Default Color constructor
Color::Color(){
	this->rgba[0] = 0.941176f;
	this->rgba[1] = 0.666667f;
	this->rgba[2] = 0.549025f;
	this->rgba[3] = 1.000000f;
}


//!  Color constructor with given rgb components
Color::Color( const float r, const float g, const float b ){
	this->rgba[0] = r;
	this->rgba[1] = g;
	this->rgba[2] = b;
	this->rgba[3] = 1.;
}


//!  Color constructor with given rgba components
Color::Color( const float r, const float g, const float b, const float a ){
	this->rgba[0] = r;
	this->rgba[1] = g;
	this->rgba[2] = b;
	this->rgba[3] = a;
}


//!  Color constructor with given rgba components in array
Color::Color( const float rgba[4] ){
	this->rgba[0] = rgba[0];
	this->rgba[1] = rgba[1];
	this->rgba[2] = rgba[2];
	this->rgba[3] = rgba[3];
}


//!  Debugging information
void Color::debug(){
//	cout << "( " << rgba[0] << ", " << rgba[1] << ", " << rgba[2] << "; " << rgba[3] << " )";
}


//!  Apply color to OpenGL state
void Color::glApply() const {
	glColor4fv( this->rgba );
}


//!  Add two color together (no limit checking)
Color Color::operator+( const Color &c ) const {
	return Color(
		rgba[0] + c.rgba[0],
		rgba[1] + c.rgba[1],
		rgba[2] + c.rgba[2],
		rgba[3] + c.rgba[3]
	);
}


//!  Add colors (no limit checking)
Color &Color::operator+=( const Color &c ){
	rgba[0] += c.rgba[0];
	rgba[1] += c.rgba[1];
	rgba[2] += c.rgba[2];
	rgba[3] += c.rgba[3];
	return *this;
}


//!  Substract colors (no limit checking)
Color Color::operator-( const Color &c ) const {
	return Color(
		rgba[0] - c.rgba[0],
		rgba[1] - c.rgba[1],
		rgba[2] - c.rgba[2],
		rgba[3] - c.rgba[3]
	);
}


//!  Substract colors (no limit checking)
Color &Color::operator-=( const Color &c ){
	rgba[0] -= c.rgba[0];
	rgba[1] -= c.rgba[1];
	rgba[2] -= c.rgba[2];
	rgba[3] -= c.rgba[3];
	return *this;
}


//!  Multiply color with scalar (no limit checking)
Color Color::operator*( const float &k ) const {
	return Color(
		rgba[0] * k,
		rgba[1] * k,
		rgba[2] * k,
		rgba[3] * k
	);
}


//!  Multiply color with scalar (no limit checking)
Color &Color::operator*=( const float &k ){
	rgba[0] *= k;
	rgba[1] *= k;
	rgba[2] *= k;
	rgba[3] *= k;
	return( *this );
}


};  //  namespace Graphics

