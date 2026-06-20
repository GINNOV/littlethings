
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


#include "config.h"
#include "Graphics/Color.h"
#include "Graphics/Device.h"
#include "Graphics/Features.h"
#include "Graphics/Texture.h"
#include "Graphics/View.h"
#include "SysSupport/Messages.h"


namespace Graphics {


void View::beginPoints(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_POINTS );
	current_element = GL_POINTS;
}

void View::beginLines(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_LINES );
	current_element = GL_LINES;
}

void View::beginLineStrip(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_LINE_STRIP );
	current_element = GL_LINE_STRIP;
}

void View::beginLineLoop(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_LINE_LOOP );
	current_element = GL_LINE_LOOP;
}

void View::beginTriangles(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_TRIANGLES );
	current_element = GL_TRIANGLES;
}

void View::beginTriangleStrip(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_TRIANGLE_STRIP );
	current_element = GL_TRIANGLE_STRIP;
}

void View::beginTriangleFan(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_TRIANGLE_FAN );
	current_element = GL_TRIANGLE_FAN;
}

void View::beginQuads(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_QUADS );
	current_element = GL_QUADS;
}

void View::beginQuadStrip(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_QUAD_STRIP );
	current_element = GL_QUAD_STRIP;
}

void View::beginPolygon(){
	if( current_element != -1 ){
		debug_msg( "current element" );
	}
	glBegin( GL_POLYGON );
	current_element = GL_POLYGON;
}

void View::end(){
	if( current_element == -1 ){
		debug_msg( "current element" );
	}
	glEnd();
	current_element = -1;
}

void View::setProjectionMatrix( const Matrix &m ){
	if( current_matrix_mode != GL_PROJECTION ){
		glMatrixMode( GL_PROJECTION );
		current_matrix_mode = GL_PROJECTION;
	}
	glLoadMatrixf( m );
}

void View::setModelViewMatrix( const Matrix &m ){
	if( current_matrix_mode != GL_MODELVIEW ){
		glMatrixMode( GL_MODELVIEW );
		current_matrix_mode = GL_MODELVIEW;
	}
	glLoadMatrixf( m );
}

void View::setTextureMatrix( const Matrix &m ){
	if( current_matrix_mode != GL_TEXTURE ){
		glMatrixMode( GL_TEXTURE );
		current_matrix_mode = GL_TEXTURE;
	}
	glLoadMatrixf( m );
}

void View::color( float r, float g, float b, float a ){
	glColor4f( r, g, b, a );
}

void View::color( const Color &c ){
	glColor4fv( c.rgba );
}

void View::vertex( float x, float y, float z ){
	glVertex3f( x, y, z );
}

void View::vertex( float *xyz ){
	glVertex3fv( xyz );
}

void View::normal( float x, float y, float z ){
	glNormal3f( x, y, z );
}

void View::normal( float *xyz ){
	glNormal3fv( xyz );
}

void View::texture( float s, float t ){
	glTexCoord2f( s, t );
}

void View::texture( float *st ){
	glTexCoord2fv( st );
}

char *View::getExtensions(){
#	if defined( HAVE_OPEN_GL )
		return (char *)glGetString( GL_EXTENSIONS );
#	endif
#	if defined( USE_TINY_GL )
		return "";
#	endif
}

char *View::getVendor(){
#	if defined( HAVE_OPEN_GL )
		return (char *)glGetString( GL_VENDOR );
#	endif
#	if defined( USE_TINY_GL )
		return "Inbuilt Software";
#	endif
}

char *View::getRenderer(){
#	if defined( HAVE_OPEN_GL )
		return (char *)glGetString( GL_RENDERER );
#	endif
#	if defined( USE_TINY_GL )
		return "TinyGL";
#	endif
}

char *View::getVersion(){
#	if defined( HAVE_OPEN_GL )
		return (char *)glGetString( GL_VERSION );
#	endif
#	if defined( USE_TINY_GL )
		return "1.0";
#	endif
}

int View::getMaxTextureSize(){
	int max_texture_size = 0;
	glGetIntegerv( GL_MAX_TEXTURE_SIZE, &max_texture_size );
	return max_texture_size;
}
int View::getMaxLights(){
	int max_lights = 0;
	glGetIntegerv( GL_MAX_LIGHTS, &max_lights );
	return max_lights;
}

void View::getMaxViewportDims( int &width, int &height ){
	int dims[2] = { 0, 0 };
	glGetIntegerv( GL_MAX_VIEWPORT_DIMS, dims );
	width  = dims[0];
	height = dims[1];
}

void View::setTexture( Texture *t ){
	if( current_texture != t ){
		current_texture = t;
		t->apply();
	}
}


};  // namespace Graphics

