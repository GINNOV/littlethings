
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
#include "Graphics/Device.h"
#include "Graphics/Features.h"
#include "Graphics/Font.h"
#include "Graphics/Texture.h"
#include "Graphics/View.h"
#include "Maths/Matrix.h"
#include "PhysicalComponents/WindowManager.h"
#include "PhysicalComponents/Style.h"
#include "SysSupport/Messages.h"
#include "SysSupport/Timer.h"
#include "SDL.h"
#include <cstdio>
#include <cstdlib>
using namespace PhysicalComponents;
using namespace Maths;


namespace Graphics {


View  *View::active      = NULL;
float  frame_age         = 0.0f;
int    SCREEN_X          = 1024;
int    SCREEN_Y          = 768;


//!  View constructor
View::View( char *title, int width, int height, unsigned long flags ){
	active = this;
	clear  = true;

	/* Information about the current video settings. */
	const SDL_VideoInfo *info = NULL;
	/* Dimensions of our window. */
	int bpp    = 0;  /* Color depth in bits of our window. */	 

	/* Let's get some video information. */
	info = SDL_GetVideoInfo();

	/*
	 * Set our width/height to 640/480 (you would
	 * of course let the user decide this in a normal
	 * app). We get the bpp we will request from
	 * the display. On X11, VidMode can't change
	 * resolution, so this is probably being overly
	 * safe. Under Win32, ChangeDisplaySettings
	 * can change the bpp.
	 */
	bpp    = info->vfmt->BitsPerPixel;

#	if defined( USE_TINY_GL )
	/* Set video mode */
	sdl_surface = SDL_SetVideoMode(width, height, 16, SDL_DOUBLEBUF);
	if( sdl_surface == NULL ) {
		fatal_msg( "Couldn't set %dx%d video mode: %s", width, height, SDL_GetError() );
	}

	sdl_swgl_Context *context = sdl_swgl_CreateContext();
	sdl_swgl_MakeCurrent( sdl_surface, context );
#	else
	/*
	 * Now, we want to setup our requested
	 * window attributes for our OpenGL window.
	 * We want *at least* 5 bits of red, green
	 * and blue. We also want at least a 16-bit
	 * depth buffer.
	 *
	 * The last thing we do is request a double
	 * buffered window. '1' turns on double
	 * buffering, '0' turns it off.
	 *
	 * Note that we do not use SDL_DOUBLEBUF in
	 * the flags to SDL_SetVideoMode. That does
	 * not affect the GL attribute state, only
	 * the standard 2D blitting setup.
	 */
	init_msg( "SDL_GL_SetAttribute..." );
	SDL_GL_SetAttribute( SDL_GL_RED_SIZE,	   5 );
	SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE,    5 );
	SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE,	   5 );
	SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE,   16 );
	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER,  1 );

	/*
	 * We want to request that SDL provide us
	 * with an OpenGL window, in a fullscreen
	 * video mode.
	 *
	 */
	//flags = SDL_OPENGL | SDL_FULLSCREEN;

	/*
	 * Set the video mode
	 */
	init_msg( "SDL_SetVideoMode( %d, %d, %d, 0x%x )...", width, height, bpp, flags );
	sdl_surface = SDL_SetVideoMode( width, height, bpp, flags );
	if( sdl_surface == 0 ) {
		/* 
		 * This could happen for a variety of reasons,
		 * including DISPLAY not being set, the specified
		 * resolution not being available, etc.
		 */
		fatal_msg( "Video mode set failed: %s", SDL_GetError() );
		exit( 0 );
	}else{
		init_msg( "Video mode ok..." );
	}
#	endif


	//	Create OpenGL screen
	/*
	sdl_surface = SDL_SetVideoMode( width, height, 0, flags );
	if( sdl_surface == NULL ){
		cout << "View constructor failed: " << SDL_GetError() << endl;;
		exit( 2 );
	}*/

	SDL_WM_SetCaption( title, NULL );

/*	int alpha_size = 0;
	int ret_val = SDL_GL_GetAttribute( SDL_GL_ALPHA_SIZE, &alpha_size );
	if( ret_val != 0 ){
		debug_msg( "Could not get OpenGL alpha size attribute" );
	}
	if( alpha_size <= 0 ){
		debug_msg( "Alpha size <= 0 : %d", alpha_size );
	}
	debug_msg( "Alpha size %d", alpha_size );*/

	ratio	   = (GLfloat)width/(GLfloat)height;
	frames	   = 0;
	last_frame = 0;
	last_time  = 0;
	fps 	   = 0;
	fps_time   = 0;

	if( Font::default_font == NULL ){
		Font::default_font = new Font( "gui/fonts.raw" );
	}
	if( Style::default_style == NULL ){
		Style::default_style = new Style();
	}

	glGetIntegerv( GL_VIEWPORT, viewport );

	gl_polygon_mode 			= GL_FILL;
	gl_shade_model				= GL_FLAT;
	gl_blend_source_factor		= GL_SRC_ALPHA;
	gl_blend_destination_factor = GL_ONE_MINUS_SRC_ALPHA;
	gl_fog_mode 				= GL_LINEAR;
	gl_fog_color[0] 			= 0;
	gl_fog_color[1] 			= 0;
	gl_fog_color[2] 			= 0;
	gl_fog_start				= 0;
	gl_fog_end					= 1;
	gl_clear_depth				= 1;

	glMatrixMode( GL_MODELVIEW );
	current_matrix_mode         = GL_MODELVIEW;
	current_texture             = NULL;
	current_element             = -1;

	for( int i=0; i<256; i++ ){
		gl_feature[i] = false;
	}

	Color ambient   = Color::RED;
	Color diffuse   = Color::RED;
	Color specular  = Color::RED;
	Color emission  = Color::RED;
	float shininess = 1.0f;

//	glPointSize    ( 4.0f );
	glColor4f      ( 0.5f, 0.5f, 0.5f, 1.0f );
	glMaterialfv   ( GL_FRONT, GL_AMBIENT,   ambient .rgba );
	glMaterialfv   ( GL_FRONT, GL_DIFFUSE,   diffuse .rgba );
	glMaterialfv   ( GL_FRONT, GL_SPECULAR,  specular.rgba );
	glMaterialfv   ( GL_FRONT, GL_EMISSION,  emission.rgba );
	glMaterialf    ( GL_FRONT, GL_SHININESS, shininess );
	glHint         ( GL_LINE_SMOOTH_HINT, GL_NICEST );
//	glHint         ( GL_LINE_SMOOTH_HINT, GL_FASTEST );
	glCullFace	   ( GL_BACK );
	glColorMaterial( GL_FRONT_AND_BACK, GL_DIFFUSE );
	glFrontFace    ( GL_CW );

#	if !defined( USE_TINY_GL )
	glLightModeli  ( GL_LIGHT_MODEL_LOCAL_VIEWER, GL_TRUE );
	glLightModeli  ( GL_LIGHT_MODEL_TWO_SIDE,     GL_FALSE );
	setBlendFunc( GL_ONE, GL_ONE );
#	endif


	SDL_Delay( 5 );
	init_msg( "sync..." );
	(void)sync.Update();
	(void)sync.Passed();
}


//!  View::display() calls active->display();
/*static*/ void View::displayOne(){
	active->display();
}


//!  Return viewport ratio
float View::getRatio(){
	return ratio;
}


//!  Return viewport
GLint *View::getViewport(){
	return viewport;
}


//!  Return viewport height  FIX (-viewport[0])
GLint View::getHeight(){
	return viewport[3];
}


void View::setState( const int feature, const bool state ){
	if( state ){
		enable( feature );
	}else{
		disable( feature );
	}
}


/*!
	Set clear status.
	If clear status is true, each frame is cleared before
	the components are drawn. Otherwise it is not cleared.
*/
void View::setClear( bool clear ){
	this->clear = clear;
}


//!  Return clear status
bool View::getClear(){
	return this->clear;
}


bool View::getState( const int feature ){
	GLenum code = getCode( feature );

#	if defined( USE_TINY_GL )
	if( gl_feature[feature] == true ){
		return true;
	}else{
		return false;
	}
#	else

	if( glIsEnabled(code) == GL_TRUE ){
		if( gl_feature[feature] == true ){
			return true;
		}else{
			mat_debug_msg( "OpenGL says %s is enabled", feature_to_str(feature) );
			mat_debug_msg( "But I thought it was disabled!" );
			mat_debug_msg( "Check use of attribute stack" );
			gl_feature[feature] = true;
			return true;
		}
	}
	if( glIsEnabled(code) == GL_FALSE ){
		if( gl_feature[feature] == false ){
			return false;
		}else{
			mat_debug_msg( "OpenGL says %s is disabled", feature_to_str(feature) );
			mat_debug_msg( "But I thought it was enabled!" );
			mat_debug_msg( "Check use of attribute stack" );
			gl_feature[feature] = false;
			return false;
		}
	}

#	endif

	return false;
}


//!  Enable OpenGL feature - only if not already enabled
void View::enable( const int feature ){
	if( gl_feature[feature] == false ){
		gl_feature[feature] = true;
		mat_debug_msg( "%s enabled", feature_to_str(feature) );
		GLenum code = getCode( feature );
		glEnable( code );
	}
}


//!  Disable OpenGL feature - only if not already disabled
void View::disable( const int feature ){
	if( gl_feature[feature] == true ){
		gl_feature[feature] = false;
		mat_debug_msg( "%s disabled", feature_to_str(feature) );
		GLenum code = getCode( feature );
		glDisable( code );
//	}else{
//		cout << feature_to_str(feature) << " not disabled; already disabled" << endl;
	}
}


//!  Surface reshape callback function
/*virtual*/ void View::reshape( int w, int h ){
	glViewport( 0, 0, (GLsizei)w, (GLsizei)h );
	glGetIntegerv( GL_VIEWPORT, viewport );
	ratio  = (GLfloat)w/(GLfloat)h;
	width  = w;
	height = h;
	window_manager->update();
	displayOne();
}


void View::setWindowManager( WindowManager *wm ){
	this->window_manager = wm;
}


//!  Displaying surface
/*virtual*/ void View::display(){

	if( clear == true ){
		glClearColor( 0.134f, 0.14f, 0.134f, 1.0f );
		glClearDepth( 1 );
		glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
	}

	current_texture = NULL;

	//	Draw layers
	window_manager->draw();

#	if defined( USE_TINY_GL )
	sdl_swgl_SwapBuffers();
#	else
	SDL_GL_SwapBuffers();
#	endif

	//check();

	frames++;
	if( (sys_time - fps_time) > 1000.0 ){
		fps 	 = (float)(frames)*1000.0f / (sys_time - fps_time);
		frames	 = 0;					   
		fps_time = sys_time;
	}
	last_frame = sys_time - last_time;
	last_time  = sys_time;
}


Matrix View::getOrthoMatrix( float left, float right, float bottom, float top, float nearval, float farval ){
	float   x, y, z;
	float   tx, ty, tz;
	Matrix	ortho_matrix;
		
	x  =  2 / (right -left   );
	y  =  2 / (top   -bottom );
	z  = -2 / (farval-nearval);
	tx = -(right +left	 ) / (right -left	);
	ty = -(top	 +bottom ) / (top	-bottom );
	tz = -(farval+nearval) / (farval-nearval);

//#	define M(row,col)	ortho_matrix.m[col*4+row]
#	define M(row,col)	ortho_matrix.m[col][row]
	M(0,0) = x;  M(0,1) = 0;  M(0,2) = 0;  M(0,3) = tx;
	M(1,0) = 0;  M(1,1) = y;  M(1,2) = 0;  M(1,3) = ty;
	M(2,0) = 0;  M(2,1) = 0;  M(2,2) = z;  M(2,3) = tz;
	M(3,0) = 0;  M(3,1) = 0;  M(3,2) = 0;  M(3,3) =  1;
#	undef M

	return ortho_matrix;
}

//!  View interface - Prepare Area for rendering 2D graphics
/*virtual*/ void View::begin2d(){
	Matrix om = getOrthoMatrix( 0, viewport[2]-viewport[0], viewport[3]-viewport[1], 0, 0, 1 );

	disable( LIGHTING   );
	disable( DEPTH_TEST );
	disable( CULL_FACE  );
	disable( BLEND      );
	glViewport         ( viewport[0], viewport[1], viewport[2], viewport[3] );
	color              ( C_WHITE );
	setPolygonMode     ( GL_FILL );
	setProjectionMatrix( om );
	setModelViewMatrix ( Matrix::Identity );
//	glTranslatef( 0.375, 0.375, 0.0 );
}


//!  View interface - End rendering 2D graphics
/*virtual*/ void View::end2d(){
}


//!  View interface - Prepare Area for rendering 3D graphics
void View::begin3d(){
}


//!  View interface - End rendering 3D graphics
void View::end3d(){
}


//!  Set gl polygon mode
void View::setPolygonMode( const GLenum polygon_mode ){
	if( gl_polygon_mode != polygon_mode ){
		gl_polygon_mode = polygon_mode;

#		ifdef GRAPHICS_STATE_DEBUG
		if( polygon_mode == GL_FILL ){
			cout << "polygon mode fill" << endl;
		}else if( polygon_mode == GL_LINE ){
			cout << "polygon mode line" << endl;
		}else if( polygon_mode == GL_POINTS ){
			cout << "polygon mode points" << endl;
		}else{
			cout << "unknown polygon mode " << (int)(polygon_mode) << endl;
		}
#		endif

		glPolygonMode( GL_FRONT_AND_BACK, polygon_mode );
	}
}


//!  Set gl shade model
void View::setShadeModel( const GLenum shade_model ){
	if( gl_shade_model != shade_model ){
		gl_shade_model = shade_model;
		glShadeModel( shade_model );
	}
}


//!  Set blending function
void View::setBlendFunc( const GLenum sfactor, const GLenum dfactor ){
#if !defined( USE_TINY_GL )
	if( gl_blend_source_factor		!= sfactor ||
		gl_blend_destination_factor != dfactor	  )
	{
		gl_blend_source_factor		= sfactor;
		gl_blend_destination_factor = dfactor;
		glBlendFunc( sfactor, dfactor );
	}
#endif
}


//!  Set fog mode
void View::setFogMode( const unsigned int mode ){
#	if !defined( USE_TINY_GL )
	if( gl_fog_mode != mode ){
		gl_fog_mode = mode;
		glFogi( GL_FOG_MODE, mode );
	}
#	endif
}


//!  Set fog color
void View::setFogColor( float *color ){
#	if !defined( USE_TINY_GL )
	//	FIX
	glFogfv( GL_FOG_COLOR, color );
#	endif
}


//!  Set fog start
void View::setFogStart( float start ){
#	if !defined( USE_TINY_GL )
	if( gl_fog_start != start ){
		gl_fog_start = start;
		glFogf( GL_FOG_START, start );
	}
#	endif
}


//!  Set fog end
void View::setFogEnd( float end ){
#	if !defined( USE_TINY_GL )
	glFogf( GL_FOG_END, end );
#	endif
}


//!  Check if there are any OpenGL errors.
/*static*/ void View::check(){
#	if !defined( USE_TINY_GL )
	int e;

	e = glGetError();
	switch( e ){
	case GL_NO_ERROR:
		//printf( "No OpenGL errors\n ");
		break;
	default:
		error_msg( "OpenGL error" );
		//	Here is a good place for breakpoint
		//	cout << "OpenGL error: " << gluErrorString((GLenum)e) << endl;

		break;
	}
#	endif
}


//!  Enter 3D vertex with texture coordinates
void View::vertex_v3ft2f( float vx, float vy, float vz, float tx, float ty ){
	texture( tx, ty );
	vertex ( vx, vy, vz );
}


//!  Enter 2D vertex with texture coordinates
void View::vertex_v2it2f( const int x, const int y, float tx, float ty ){
	texture( tx, ty );
	vertex ( (float)(viewport[0]+x), (float)(viewport[1]+y) );
}


//!  Enter 2D vertex to rendering engine
void View::vertex2i( const int x, const int y ){
	vertex( (float)(viewport[0]+x), (float)(viewport[1]+y) );
}


//!  Area Graphics interface - Draw filled rectangle - changed polygonmode..
void View::drawFillRect( const int x1, const int y1, const int x2, const int y2 ){
	setPolygonMode( GL_FILL );
	beginQuads();
	vertex2i( x1, y1 );
	vertex2i( x2, y1 );
	vertex2i( x2, y2 );
	vertex2i( x1, y2 );
	end();
}


void View::blit( Texture *t, const int x1, const int y1 ){
	int x2 = x1 + t->getWidth ()  -1 ;
	int y2 = y1 + t->getHeight() -1 ;

	color( C_WHITE );
/*	disable( LIGHTING   );
	disable( DEPTH_TEST );
	disable( CULL_FACE  );*/
//	disable( BLEND      );
	setTexture    ( t );
	setPolygonMode( GL_FILL    );
	setBlendFunc  ( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
//	setBlendFunc  ( GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA );
//	setBlendFunc  ( GL_ONE, GL_ONE );
	enable        ( TEXTURE_2D );
	enable        ( BLEND      );

	beginQuads();
	vertex_v2it2f( x1, y1, 0, 0 );
	vertex_v2it2f( x2, y1, 1, 0 );
	vertex_v2it2f( x2, y2, 1, 1 );
	vertex_v2it2f( x1, y2, 0, 1 );
	end();
}


//!  Area Graphics interface - Draw non-filled rectangle - changed polygonmode..
void View::drawRect( const int x1, const int y1, const int x2, const int y2 ){
	setPolygonMode( GL_LINE );
	beginQuads();
	vertex2i( x1,	y1+1 );
	vertex2i( x2-1, y1+1 );
	vertex2i( x2-1, y2 );
	vertex2i( x1,	y2 );
	end();
}


//!  Area Graphics interface - Draw twocolor rectangle
void View::drawBiColRect( const Color &top_left, const Color &bottom_right, const int x1, const int y1, const int x2, const int y2 ){
	color( top_left );
	beginLineStrip();
	vertex2i( x1, y2   );
	vertex2i( x1, y1+1 );
	vertex2i( x2, y1+1 );
	end();
	color( bottom_right );
	beginLineStrip();
	vertex2i( x2-1,  y1+2 );
	vertex2i( x2-1,  y2   );
	vertex2i( x1,	 y2   );
	end();
}


//!  Area Graphics interface - Draw string - no formatting
void View::drawString( Font *font, const char *str, const int xp, const int yp ){
	font->drawString( this, str, viewport[0]+xp, viewport[1]+yp );
}


//!  Access sdl surface directly
SDL_Surface *View::getSurface(){
	return sdl_surface;
}


};	//	namespace Graphics

