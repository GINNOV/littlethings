
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
#include "Graphics/Device.h"
#include "Graphics/Texture.h"


namespace Graphics {


void Texture::convert_to_a(){
	switch( work_format ){
	case FORMAT_RGB:  convert_rgb_to_a (); break;
	case FORMAT_RGBA: convert_rgba_to_a(); break;
	default: break;
	}

	work_format = FORMAT_A;
}

void Texture::convert_to_rgb(){
	switch( work_format ){
	case FORMAT_A:    convert_a_to_rgb   (); break;
	case FORMAT_RGBA: convert_rgba_to_rgb(); break;
	default: break;
	}

	work_format = FORMAT_RGB;
}

/*
void Texture::convert_to_rgba(){
	switch( work_format ){
	case FORMAT_A:   convert_a_to_rgb   (); 
	case FORMAT_RGB: convert_rgb_to_rgba(); break;
	default: break;
	}

	work_format = FORMAT_RGBA;
}*/


void Texture::convert_a_to_rgb(){
	unsigned char *in  = work_data;
	unsigned char *out = new unsigned char[width*height];
	int            x   = 0;
	int            y   = 0;
	int            a   = 0;

	for( y=0; y<height; y++ ){
		for( x=0; x<height; x++ ){
			a = in[y*width+x];
			out[y*width*3+x*3+0] = a;
			out[y*width*3+x*3+1] = a;
			out[y*width*3+x*3+2] = a;
		}
	}

	setWorkData( out );
}


void Texture::convert_rgb_to_a(){
	unsigned char *in  = work_data;
	unsigned char *out = new unsigned char[width*height];
	int            x   = 0;
	int            y   = 0;
	int            r   = 0;
	int            g   = 0;
	int            b   = 0;
	int            a   = 0;

	for( y=0; y<height; y++ ){
		for( x=0; x<height; x++ ){
			r = in[y*width*3+x*3+0];
			g = in[y*width*3+x*3+1];
			b = in[y*width*3+x*3+2];
			a = r;
			out[y*width+x] = a;
		}
	}

	setWorkData( out );
}


void Texture::convert_rgba_to_a(){
	unsigned char *in  = work_data;
	unsigned char *out = new unsigned char[width*height];
	int            x   = 0;
	int            y   = 0;
	int            r   = 0;
	int            g   = 0;
	int            b   = 0;
	int            a   = 0;

	for( y=0; y<height; y++ ){
		for( x=0; x<height; x++ ){
			r = in[y*width*4+x*4+0];
			g = in[y*width*4+x*4+1];
			b = in[y*width*4+x*4+2];
			a = in[y*width*4+x*4+2];
			out[y*width+x] = a;
		}
	}

	setWorkData( out );
}


void Texture::convert_rgba_to_rgb(){
	unsigned char *in  = work_data;
	unsigned char *out = new unsigned char[width*height*3];
	int            x   = 0;
	int            y   = 0;
	int            r   = 0;
	int            g   = 0;
	int            b   = 0;
	int            a   = 0;

	for( y=0; y<height; y++ ){
		for( x=0; x<height; x++ ){
			r = in[y*width*4+x*4+0];
			g = in[y*width*4+x*4+1];
			b = in[y*width*4+x*4+2];
			a = in[y*width*4+x*4+2];
			out[y*width*3+x*3+0] = r;
			out[y*width*3+x*3+1] = g;
			out[y*width*3+x*3+2] = b;
		}
	}

	setWorkData( out );
}


};  //  namespace Graphics

