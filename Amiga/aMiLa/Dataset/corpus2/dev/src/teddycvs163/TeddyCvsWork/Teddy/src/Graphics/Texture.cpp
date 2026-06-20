
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
#include "Graphics/glu_mipmap.h"
#include "SysSupport/Messages.h"
#include <cstdlib>


namespace Graphics {


static int minPow( GLuint value ){
	GLuint i = 2;

	while( i<value ) i *= 2;
	return i;
}


//! Constructor which loads named file into texture
Texture::Texture( const char *name ):Named(name){
	this->is_good       = false;
	this->gl_format     = 0;
	this->gl_components = 0;  
	this->env           = ENV_MODULATE;
	this->env_color     = Color(0,0,0,0);
	this->filter        = FILTER_NEAREST;
	this->wrap_s        = WRAP_REPEAT;
	this->wrap_t        = WRAP_REPEAT;

#	if defined( USE_TINY_GL )
	this->env           = ENV_DECAL;
#	endif

	glGenTextures( 1, &gltid );
}


//!  Destructor
/*virtual*/ Texture::~Texture(){
	glDeleteTextures( 1, &gltid );
	setWorkData( NULL );
}


//!  Apply texture
void Texture::apply(){
	if( is_good ){
		glBindTexture( GL_TEXTURE_2D, gltid );
	}
}


//!  Return true if there is actual texturemap bind to this texture
bool Texture::isGood(){
	return is_good;
}


void Texture::setWrap( int wrap_s, int wrap_t ){
	this->wrap_s = wrap_s;
	this->wrap_t = wrap_t;
}

void Texture::setEnv( int env ){
	this->env = env;
}

void Texture::setEnv( int env, const Color &c ){
#	if !defined( USE_TINY_GL )
	this->env       = env;
	this->env_color = c;
#	endif
}

void Texture::setFilter( int filter ){
	this->filter = filter;
}


//!  Return width of texture in texels
int Texture::getWidth(){
	return width;
}


//!  Return height of texture in texels
int  Texture::getHeight(){
	return height;
}


void Texture::putData( unsigned char *data, int width, int height, int format, Options modify ){
	this->work_data     = data;
	this->width         = width;
	this->height        = height;
	this->work_format   = format;
	this->modify        = modify;

	doFormat   ();        //  First  do conversion to requested format by adding or remove alpha or simulating alpha with rgb
	doSize     ();        //  Second make sure the size in that format is suitable
	doBind     ();        //  Last   upload texture to texture object
	setWorkData( NULL );  //  Free our copy of workingdata, if it was used

	is_good = true;
}


void Texture::setWorkData( unsigned char *data ){
	if( work_data_allocated == true ){
		delete[] work_data;
	}
	work_data = data;
	if( data != NULL ){
		work_data_allocated = true;
	}
}


void Texture::doFormat(){

#	if defined( USE_TINY_GL )

	convert_to_rgb();

#	else

	//  Generate, add and remove alpha channel
	if( modify.isEnabled(TX_NO_ALPHA) ){
		switch( work_format ){
		case FORMAT_RGB : break;
		case FORMAT_RGBA: convert_to_rgb(); break;
		case FORMAT_A   : break;
		default: break;
		}
	}else if( modify.isEnabled(TX_GENERATE_ALPHA) ){
		if( modify.isEnabled(TX_ALPHA_ONLY) ){
			convert_to_a();
		}else{
			switch( work_format ){
//			case FORMAT_RGB : convert_to_rgba(); break;
			case FORMAT_RGBA: break;
			case FORMAT_A   : break;
			default: break;
			}
		}
	}

#	endif

}


void Texture::doSize(){
	switch( work_format ){
	case FORMAT_RGB:  gl_format = GL_RGB;   gl_components = 3; break;
	case FORMAT_RGBA: gl_format = GL_RGBA;  gl_components = 4; break;
	case FORMAT_A:    gl_format = GL_ALPHA; gl_components = 1; break;
	default: break;
	}

#	if defined( USE_TINY_GL )
	gl_format     = GL_RGB;
	gl_components = 3;
#	endif

	//  Scale if needed
	glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );
	bool scale      = false;
	int  new_width  = width;
	int  new_height = height;

	//  Scaling process should make sure that all
	//  texture sizes are ok to the OpenGL driver,
	//  which may be different on any machine.
	if( new_width != minPow(new_width) ){
		new_width = minPow( new_width );
		scale     = true;
	}
	if( new_height != minPow(new_height) ){
		new_height = minPow( new_height );
		scale      = true;
	}

	//  See if texture size is ok for OpenGL driver
	//  Does not seem to work :/

#	if defined( USE_TINY_GL )

	if( new_width > 256 ){
		new_width = 256;
		scale = true;
	}
	if( new_height > 256 ){
		new_height = 256;
		scale = true;
	}

#	else

	if( new_width > 1024 ){
		new_width = 1024;
		scale = true;
	}
	if( new_height > 512 ){
		new_height = 512;
		scale = true;
	}

	GLint format = 0;
	int   x      = 0;
	int   tries  = 0;

	for( tries=0; tries<1000; tries++ ){
		glTexImage2D( GL_PROXY_TEXTURE_2D, 0, gl_format, new_width, new_height, 0, gl_format, GL_UNSIGNED_BYTE, NULL );
		glGetTexLevelParameteriv( GL_PROXY_TEXTURE_2D, 0, GL_TEXTURE_INTERNAL_FORMAT, &format );
		if( format == 0 ){  //  if not, go down in size
			x     = 1 - x;
			scale = true;
			if( x==0 ){
				new_height = new_height / 2;  //  halve height
			}else{
				new_width  = new_width / 2;   //  halve width
			}
		}else{
			if( format == gl_format ){
				break;  //  ok size!
			}else{
				debug_msg( "format?! 0x%x\n", format );
				break;
			}
		}
		if( new_height==0 || new_width==0 ){
			error_msg( MSG_HEAD "Can not find memory for texture - Giving up!" );
			return;
		}
	}

	if( tries==1000 ){
		error_msg( MSG_HEAD "Can not find memory for texture after 1000 tries - Giving up!" );
		return;
	}

#	endif

	if( scale ){
		//debug_msg( "Doing scale from %d x %d to %d x %d", width, height, new_width, new_height );
		unsigned char *new_data = new unsigned char[ new_width * new_height * gl_components];
		glu_ScaleImage(
			gl_format,
			width,     height,     GL_UNSIGNED_BYTE, work_data,
			new_width, new_height, GL_UNSIGNED_BYTE, new_data
		);

		setWorkData( new_data );
		this->width  = new_width;
		this->height = new_height;
	}
	//debug_msg( "Texture size %d x %d", width, height );
}


void Texture::doBind(){
	glBindTexture( GL_TEXTURE_2D,       gltid );
	glPixelStorei( GL_UNPACK_ALIGNMENT, 1 );

	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );

	switch( filter ){
	case FILTER_NEAREST:
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
		break;

	case FILTER_LINEAR:
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		break;

	default:
		debug_msg( "Unknown texture filter mode" );
		break;
	}

	switch( wrap_s ){
	case WRAP_REPEAT : glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT ); break;
	case WRAP_CLAMP  : glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP  ); break;
	default:
		debug_msg( "Unknown texture wrap mode" );
		break;
	}

	switch( wrap_t ){
	case WRAP_REPEAT : glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT ); break;
	case WRAP_CLAMP  : glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP  ); break;
	default:
		debug_msg( "Unknown texture wrap mode" );
		break;
	}

#	if !defined( USE_TINY_GL )
	switch( env ){
	case ENV_BLEND   : 
		glTexEnvi ( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE,  GL_BLEND       );
		glTexEnvfv( GL_TEXTURE_ENV, GL_TEXTURE_ENV_COLOR, env_color.rgba ); 
		break;
	case ENV_REPLACE : glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE  ); break;
	case ENV_DECAL   : glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL    ); break;
	case ENV_MODULATE: glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE ); break;
	default: 
		debug_msg( "Unknown texture function" );
		break;
	}
/*	glPixelStorei  ( GL_UNPACK_ALIGNMENT, 1 );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S,     GL_REPEAT );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T,     GL_REPEAT );*/
//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR               );
	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
/*	glTexImage2D   ( GL_TEXTURE_2D, 0, GL_ALPHA, 256, 256, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data );
	*/
	glTexImage2D( GL_TEXTURE_2D, 0, gl_format, width, height, 0, gl_format, GL_UNSIGNED_BYTE, work_data );
	glu_Build2DMipmaps(
		GL_TEXTURE_2D,
		gl_format,
		width, height,
		gl_format, 
		GL_UNSIGNED_BYTE, 
		work_data 
	);

#	else
	glTexImage2D( GL_TEXTURE_2D, 0, gl_components, width, height, 0, gl_format, GL_UNSIGNED_BYTE, work_data );
#	endif
}


};  //  namespace Materials

