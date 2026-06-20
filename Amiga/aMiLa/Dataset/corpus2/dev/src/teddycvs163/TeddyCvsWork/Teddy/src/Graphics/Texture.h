
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
	\class   Texture
	\ingroup g_graphics
	\author  Timo Suoranta
	\brief   Texture
	\date    1999, 2000, 2001
*/


#ifndef TEDDY_GRAPHICS_TEXTURE_H
#define TEDDY_GRAPHICS_TEXTURE_H


#include "MixIn/Named.h"
#include "MixIn/Options.h"
#include "Graphics/Color.h"


namespace Graphics {


#define TX_GENERATE_ALPHA (1ul<<0ul)
#define TX_ALPHA_ONLY     (1ul<<1ul)
#define TX_NO_ALPHA       (1ul<<2ul)

#define WRAP_REPEAT    1
#define WRAP_CLAMP     2

#define ENV_BLEND      1
#define ENV_REPLACE    2
#define ENV_DECAL      3
#define ENV_MODULATE   4

#define FORMAT_A       1
#define FORMAT_RGB     2
#define FORMAT_RGBA    3

#define FILTER_NEAREST 1
#define FILTER_LINEAR  2


class Texture : public Named, public Options {
public:
	Texture( const char *name );
	virtual ~Texture();

	void putData    ( unsigned char *data, int width, int height, int format, Options modify );

	void apply      ();
	void blit       ( const int x, const int y );

	bool isGood     ();
	int  getWidth   ();
	int  getHeight  ();
	void setWrap    ( int wrap_s, int wrap_t );
	void setEnv     ( int env );
	void setEnv     ( int env, const Color &c );
	void setFilter  ( int filter );

protected:
	void doFormat           ();
	void doSize             ();
	void doBind             ();
	void setWorkData        ( unsigned char *data );

	void convert_to_a       ();
	void convert_to_rgb     ();
	void convert_rgba       ();

	void convert_rgb_to_a   ();
	void convert_rgba_to_a  ();
	void convert_a_to_rgb   ();
	void convert_rgba_to_rgb();
	void convert_rgb_to_rgba();

protected:
	bool           is_good;
	unsigned int   gltid;
	int            width;
	int            height;
	Color          env_color;
	int            wrap_s;
	int            wrap_t;
	int            env;
	int            filter;
	int            work_format;
	unsigned char *work_data;
	bool           work_data_allocated;
	Options        modify;
	int            gl_format;
	int            gl_components;
};


};  //  namespace Graphics


#endif  //  TEDDY_GRAPHICS_TEXTURE_H

