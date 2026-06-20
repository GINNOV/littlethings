
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


#include "Materials/PixFileTexture.h"
#include "Graphics/Device.h"
#include "SysSupport/EndianIn.h"
#include "SysSupport/Messages.h"
#include <cstdio>
using namespace SysSupport;


namespace Materials {


//!  Constructor-loader
PixFileTexture::PixFileTexture( const char *fname ):Texture(fname){
	EndianIn      *s       = NULL;
	unsigned char *filler  = NULL;
	unsigned char *data    = NULL;
	unsigned char  byte_in;
	unsigned char  color_table[256*4];  //  256 * RGBA
	unsigned char  index;
	int            i = 0;

	//  First read palette PAL
	try{
		s = new EndianIn( "buda_textures/iwarflip.pal" );
		s->set_bigendian();

		//  First skip 24 byte header
		for( i=0; i<24; i++ ){
			s->read_byte();
		}

		//  Next read in color palette data
		for( i=0; i<256;i++ ){
			color_table[i*4+0] = s->read_byte();
			color_table[i*4+1] = s->read_byte();
			color_table[i*4+2] = s->read_byte();
			color_table[i*4+3] = s->read_byte();
		}		
	}catch( ... ){
		debug_msg( "Error loading iwarflip.pal, got as far as i = %d", i );
	}
	delete s;

	this->width  = 256;
	this->height = 256;

	//  Then load texture PIX
	try{
		s = new EndianIn( fname );
		/*debug_msg(
			"PIX texture file %s opened, length %d bytes",
			fname,
			s->len()
		);*/
		s->set_bigendian();
		filler = data = new unsigned char[256*256*4];

		int skip_count = 0;
		do{
			byte_in = s->read_byte();
			skip_count++;
		}while( byte_in != 0x80 );
		//lwo_debug_msg( "Header scan %d bytes skipped", skip_count );

		do{
			byte_in = s->read_byte();
			skip_count++;
		}while( byte_in != 0x80 );
		//lwo_debug_msg( "Header scan %d bytes skipped", skip_count );

		do{
			byte_in = s->read_byte();
			skip_count++;
		}while( byte_in != 0x0 );
		//lwo_debug_msg( "Header scan %d bytes skipped", skip_count );

		//  Name comes after 80 00 80 
		//  00 terminates name
		for( i=0; i<16; i++ ){    //  16 values skipped after name
			byte_in = s->read_byte();
			//lwo_debug_msg( "Header scan byte in %d", byte_in );
			skip_count++;
		}
		//lwo_debug_msg( "Header scan %d bytes skipped", skip_count );

		//  Next data
		for( i=0; i<256*256; i++ ){
			index     = s->read_byte();
			*filler++ = color_table[index*4+0];
			*filler++ = color_table[index*4+1];
			*filler++ = color_table[index*4+2];
		}
	}catch( ... ){
		debug_msg( "Error reading texture %s: %d bytes missing", fname, 256*256 - i );
	}
	s->close();
	printf( "%s\n", fname );

	glBindTexture  ( GL_TEXTURE_2D, gltid );
	glPixelStorei  ( GL_UNPACK_ALIGNMENT, 1 );
	glTexParameteri( GL_TEXTURE_2D,  GL_TEXTURE_WRAP_S,     GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D,  GL_TEXTURE_WRAP_T,     GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D,  GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameteri( GL_TEXTURE_2D,  GL_TEXTURE_MIN_FILTER, GL_LINEAR );
#	if !defined( USE_TINY_GL )
	glTexImage2D   ( GL_TEXTURE_2D,  0, GL_RGBA, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, data );
#	else
	glTexEnvi      ( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE,   GL_DECAL/*GL_MODULATE*/ );
	glTexImage2D   ( GL_TEXTURE_2D,  0, 3, 256, 256, 0, GL_RGB, GL_UNSIGNED_BYTE, data );
#	endif
	delete[] data;
	this->is_good = true;

	// 00 00 00 12  
	// 00 00 00 08                   bits per pixel ?
	// 00 00 00 02
	// 00 00 00 02
	// 00 00 00 03
	// 00 00 00 14/0f/11
	// 03 01 00 01
	// 00 01 00 00	                 256 - width / height ?
	// 80 00 80  n   a  m  e  0
	// 00 00 00 21
	// 00 01 00 08
	// 00 01 00 00                   256 - width / height ?
	// 00 00 00 01   d  a  t  a
	// 00 00 00 00
	// 00 00 00 00
}


};  //  namespace Materials

