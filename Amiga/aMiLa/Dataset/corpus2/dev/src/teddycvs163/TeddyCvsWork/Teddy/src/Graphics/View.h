
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
	\class   View
	\ingroup g_graphics
	\author  Timo Suoranta
	\brief   Root drawing device (context)
	\date    1999, 2000, 2001

	View can contain Physical user interface Components - drawable
	Areas, which implement both Renderable and RenderingContext.
*/


#ifndef TEDDY_GRAPHICS_VIEW_H
#define TEDDY_GRAPHICS_VIEW_H


#include "Maths/Matrix.h"
#include "Graphics/Device.h"
namespace PhysicalComponents { class Layer;         };
namespace PhysicalComponents { class WindowManager; };
using namespace PhysicalComponents;
using namespace Maths;


struct SDL_Surface;


namespace Graphics {


class Color;
class Font;
class Texture;


extern float frame_age;
extern int   SCREEN_X;
extern int   SCREEN_Y;


class View {
public:
	View();
	View( char *title, int width, int height, unsigned long flags );

	//  View Interface
	void   reshape         ( int w, int h );
	void   display         ();

	int   *getViewport     ();
	int    getHeight       ();
	float  getRatio        ();

	void   setWindowManager( WindowManager *wm );
	Matrix getOrthoMatrix  ( float left, float right, float bottom, float top, float nearval, float farval );

	void   setProjectionMatrix( const Matrix  &m );
	void   setModelViewMatrix ( const Matrix  &m );
	void   setTextureMatrix   ( const Matrix  &m );
	void   setTexture         ( Texture *t );

	void   beginPoints        ();
	void   beginLines         ();
	void   beginLineStrip     ();
	void   beginLineLoop      ();
	void   beginTriangles     ();
	void   beginTriangleStrip ();
	void   beginTriangleFan   ();
	void   beginQuads         ();
	void   beginQuadStrip     ();
	void   beginPolygon       ();
	void   end                ();

	void   vertex            ( float x, float y, float z = 0 );
	void   vertex            ( float *xyz );
	void   normal            ( float x, float y, float z = 0 );
	void   normal            ( float *xyz );
	void   color             ( float r, float g, float b, float a = 1 );
	void   color             ( const Color &c );
	void   texture           ( float s, float t );
	void   texture           ( float *st );
	void   begin2d           ();
	void   end2d             ();

	char  *getExtensions     ();
	char  *getVendor         ();
	char  *getRenderer       ();
	char  *getVersion        ();
	int    getMaxTextureSize ();
	int    getMaxLights      ();
	void   getMaxViewportDims( int &width, int &height );

	void   vertex_v3ft2f   ( float vx, float vy, float vz, float tx, float ty );
	void   vertex_v2it2f   ( const int x, const int y, float tx, float ty );
	void   vertex2i        ( const int x, const int y );
	void   drawString      ( Font        *font,     const char  *str,          const int xp, const int yp );  // const?
	void   drawFillRect    ( const int    x1,       const int    y1,           const int x2, const int y2 );  // const?
	void   drawRect        ( const int    x1,       const int    y1,           const int x2, const int y2 );  // const?
	void   drawBiColRect   ( const Color &top_left, const Color &bottom_right, const int x1, const int y1, const int x2, const int y2 );  // const?
	void   blit            ( Texture     *t,        const int    x1,           const int y1 );

	void   setClear        ( bool clear );
	bool   getClear        ();
	void   begin3d         ();
	void   end3d           ();
	void   setState        ( const  int feature, const bool  state );
	bool   getState        ( const  int feature );
	void   enable          ( const  int feature );
	void   disable         ( const  int feature );
	void   setPolygonMode  ( const  unsigned int polygon_mode );
	void   setShadeModel   ( const  unsigned int shade_model );
	void   setFrontFace    ( const  unsigned int front_face );
	void   setBlendFunc    ( const  unsigned int sfactor, const unsigned int dfactor );
	void   setClearDepth   ( const  float depth );
	void   setFogStart     ( const  float start );
	void   setFogEnd       ( const  float end );
	void   setFogMode      ( const  unsigned int mode );
	void   setFogColor     ( float *color );
	SDL_Surface *getSurface();

	static void  check         ();

	//  FIX accessors
	int    frames;
	float  last_frame;
	float  fps;
	float  fps_time;
	float  last_time;

protected:
	SDL_Surface   *sdl_surface;
	WindowManager *window_manager;
	Texture       *current_texture;
	int            current_element;
	int            current_matrix_mode;
	float          ratio;
	int            width;
	int            height;
	int            viewport[4];
	bool           clear;

protected:
	unsigned int gl_blend_source_factor;
	unsigned int gl_blend_destination_factor;
	unsigned int gl_fog_mode;
	unsigned int gl_polygon_mode;
	unsigned int gl_shade_model;
	float        gl_fog_start;
	float        gl_fog_end;
	float        gl_fog_color[4];
	float        gl_clear_depth;
	bool         gl_feature[256];

protected:
	static View *active;

	static void  displayOne();
	static void  reshapeOne( int w, int h );
};


};  //  namespace Graphics


#endif  //  TEDDY_GRAPHICS_VIEW_H

