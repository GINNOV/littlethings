
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


#include "config.h"
#include "Graphics/Font.h"
#include "Graphics/Features.h"
#include "Graphics/Texture.h"
#include "Graphics/View.h"
#include "SysSupport/EndianIn.h"
using namespace Graphics;
using namespace PhysicalComponents;
using namespace SysSupport;


namespace Graphics {


/*static*/ Font *Font::default_font = NULL; // Can't initialize here; there is no OpenGL context yet. Done in View constructor.

static float DIV_256 = 1.0f/256.0f;


/*!
	Font constructor which loads given 256x256 alpha channel raw data file
	and creates map.
*/
Font::Font( const char *fname ){
	texture = new Texture( "font texture" );

	unsigned char array[10][21] = {
//		0         1         2
//		012345678901234567890
		"!\"#$%&'()*+,-./01234", // 0 
		"56789:;<=>?@ABCDEFGH",  // 1
		"IJKLMNOPQRSTUVWXYZ[\\", // 2
		"]^_`abcdefghijklmnop",  // 3
		"qrstuvwxyz{|}~ ¡¢£¤¥",  // 4
		"¦§¨©ª«¬­®¯°±²³´µ¶·¸¹",  // 5
		"º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍ",  // 6
		"ÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàá",  // 7
		"âãäåæçèéêëìíîïðñòóôõ",  // 8
		"ö÷øùúûüýþÿ??????????"   // 9
	};
	int row;
	int col;
	int i;

	for( i=0; i<256; i++ ){
		x[i] = 255-8;
		y[i] = 0;
	}

#if !defined( USE_TINY_GL )
	EndianIn      *s      = NULL;
	unsigned char *filler = NULL;
	unsigned char *data   = NULL;

	try{
		s = new EndianIn( fname );
		s->set_bigendian();
		filler = data = new unsigned char[256*256];
		for(int i=0; i<256*256;i++){
			*filler++ = s->read_byte();
		}		
	}catch( ... ){
	}
	s->close();

	texture->setEnv   ( ENV_MODULATE );
	texture->setWrap  ( WRAP_REPEAT, WRAP_REPEAT );
	texture->setFilter( FILTER_NEAREST );
	texture->putData  ( data, 256, 256, FORMAT_A, Options(0) );
	
	delete[] data;


	cw  =  8;
	ch  =  8;
	cwl = cw-1;
	tw  = cw *DIV_256;
	twl = cwl*DIV_256;
	th  = ch *DIV_256;

	for( row=0; row<10; row++ ){
		for( col=0; col<20; col++ ){
			x[ array[row][col] ] = (col*cw)*DIV_256;
			y[ array[row][col] ] = (row*ch)*DIV_256;
		}
	}
#endif


#if defined( USE_TINY_GL )
	EndianIn      *s      = NULL;
	unsigned char *filler = NULL;
	unsigned char *data   = NULL;

	try{
		s = new EndianIn( fname );
		s->set_bigendian();
		filler = data = new unsigned char[256*256*3];
		for(int i=0; i<256*256;i++){
			unsigned char in = s->read_byte();
			*filler++ = in;
			*filler++ = in;
			*filler++ = in;
		}		
	}catch( ... ){
	}
	s->close();
	
	texture->setEnv   ( ENV_MODULATE );
	texture->setWrap  ( WRAP_REPEAT, WRAP_REPEAT );
	texture->setFilter( FILTER_NEAREST );
	texture->putData  ( data, 256, 256, GL_RGB, Options(0) );

	delete[] data;

	cw  =  8;
	ch  =  7;
	tw  = (cw) *DIV_256;
	th  = (ch) *DIV_256;

	for( row=0; row<10; row++ ){
		for( col=0; col<20; col++ ){
			x[ array[row][col] ] = (col*(cw)+1)*DIV_256;
			y[ array[row][col] ] = (row*(ch+1))*DIV_256;
		}
	}
#endif
}


//!  Render string str to (xp,yp) with this font
void Font::drawString( View *v, const char *str, int xp, int yp ){
	const char *ptr = str;
	v->setPolygonMode( GL_FILL    );
	v->setBlendFunc  ( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	v->enable        ( TEXTURE_2D );
	v->enable        ( BLEND      );
	v->setTexture    ( texture    );
	v->beginQuads();
	while( *ptr != '\0' ){
		v->texture( x[*ptr]   , y[*ptr]    ); v->vertex( (float)xp     , (float)yp      );
		v->texture( x[*ptr]+tw, y[*ptr]    ); v->vertex( (float)(xp+cw), (float)yp      );
		v->texture( x[*ptr]+tw, y[*ptr]+th ); v->vertex( (float)(xp+cw), (float)(yp+ch) );
		v->texture( x[*ptr]   , y[*ptr]+th ); v->vertex( (float)xp     , (float)(yp+ch) );
		xp += cw;
		ptr++;
	}
	v->end();
}


//!  Return font width in pixels
int Font::getWidth(){
	return cw;
}


//!  Return font height in pixels
int Font::getHeight(){
	return ch;
}


};  //  namespace Graphics

