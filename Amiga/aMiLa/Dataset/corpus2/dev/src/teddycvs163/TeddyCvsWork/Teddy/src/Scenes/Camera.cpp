
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
#include "Graphics/View.h"
#include "Models/Mesh.h"
#include "PhysicalComponents/Projection.h"
#include "Scenes/Camera.h"
#include "Scenes/Scene.h"
#include "SysSupport/StdMaths.h"
using namespace Graphics;
using namespace Models;
using namespace PhysicalComponents;


namespace Scenes {


//!  Constructor for skybox enabled first person camera
Camera::Camera( const char *name, Scene *scene ):ModelInstance(name){
	this->scene 	 = scene;
	this->fov		 = 80.0f;
	this->near_clip  = 1;
	this->far_clip	 = 8192;
	this->title      = "";
}


void Camera::setTitle( char *title ){
	this->title = title;
}

char *Camera::getTitle(){
	return this->title;
}


//!  Destructor
Camera::~Camera(){
//	delete star_field;
}


void Camera::doProjection( Projection *p, const bool load_matrix ){
	projection_matrix = getPerspectiveMatrix( fov, p->getRatio(), near_clip, far_clip );
	if( load_matrix == true ){		
		p->setProjectionMatrix( projection_matrix );
		glMatrixMode( GL_MODELVIEW );
	}
}

void Camera::doCamera( Projection *p, const bool load_matrix ){
//  need origo camera fix
//	view_matrix = getViewMatrix();
	view_matrix = worldToLocal();
	if( load_matrix == true ){
		p->setModelViewMatrix( view_matrix );
	}

	//  Update view frustum clipping planes
	updatePlanes();
}

void Camera::doObjectMatrix( Projection *p, const Matrix &m, const bool load_matrix ){
	model_view_matrix  = view_matrix * m;
	to_screen_s_matrix = projection_matrix * model_view_matrix;
	if( load_matrix == true ){
		p->setModelViewMatrix( model_view_matrix );
	}
}

Vector4 Camera::projectVector( const Vector4 &v ){
	return to_screen_s_matrix.transformVector4( v );
}

/*!
	Apply camera transformations to active viewport (Perspective Area)
	Renders skybox
*/
/*virtual*/ void Camera::projectScene( Projection *p ){
	View *view = p->getView();
	this->p = p;
	this->viewport[0] = p->getViewport()[0];
	this->viewport[1] = p->getViewport()[1];
	this->viewport[2] = p->getViewport()[2];
	this->viewport[3] = p->getViewport()[3];

#	if 0 // defined( USE_TINY_GL )
	scene->drawPostElements( this, p );
//	glClear( GL_DEPTH_BUFFER_BIT );
#   endif

	//  Update and load projection matrix
	//  Draw Scene
	doProjection( p );
	doCamera    ( p );
	scene->draw ( this, p );

#	if 0  //  !defined( USE_TINY_GL )
	scene->drawPostElements( this, p );
#   endif

	//	Draw Starfield
#	if 0  //  !defined( USE_TINY_GL )
	p->setModelViewMatrix( worldToLocal() );
	star_field->draw( p );
#	endif

	debug_matrix = view_matrix;
}


/*!
	Apply camera transformations to viewport
	Apply pick matrix for OpenGL selection
	No skybox, no starfield
*/
ModelInstance *Camera::pickInstance( Projection *p, const int x, const int y ){
	projection_matrix =
		getPickMatrix       ( x, p->getView()->getHeight()-y, 3.0, 3.0, p->getViewport() ) *
		getPerspectiveMatrix( fov, p->getRatio(), near_clip, far_clip                    );
	p->setProjectionMatrix( projection_matrix );

	doCamera( p, true );
	return scene->pickInstance( this, p );
}	


//!  Set field of vision
void Camera::setFov( const float fov ){
	this->fov = fov;
}


//!  Return field of vision
float Camera::getFov() const {
	return fov;
}


//!  Set Scene for camera
void Camera::setScene( Scene *scene ){
	this->scene = scene;
}

//!  Return Scene of camera
Scene *Camera::getScene() const {
	return scene;
}


bool Camera::cull( ModelInstance *mi ){
	Vector loc = mi->getPosition  ();
	float  rad = mi->getClipRadius() * 2;

	if( view_plane[0].distance(loc) < -rad ) return true;
	if( view_plane[1].distance(loc) < -rad ) return true;
	if( view_plane[2].distance(loc) < -rad ) return true;
	if( view_plane[3].distance(loc) < -rad ) return true;
	if( view_plane[4].distance(loc) < -rad ) return true;
	if( view_plane[5].distance(loc) < -rad ) return true;
	return false;
}


Matrix Camera::getFrustumMatrix( const float left, const float right, const float bottom, const float top, const float nearval, const float farval ){
	float x, y, a, b, c, d;
	Matrix frustum_matrix;

	x =  (2	* nearval) / (right  - left   );
	y =  (2	* nearval) / (top    - bottom );
	a =  (right  + left   ) / (right  - left   );
	b =  (top    + bottom ) / (top    - bottom );
	c = -(farval + nearval) / (farval - nearval);
	d = -(2 * farval * nearval) / (farval - nearval);

//#	define M(row,col)  frustum_matrix.f1[col*4+row]
#	define M(row,col)	frustum_matrix.m[col][row]
	M(0,0) = x;  M(0,1) = 0;  M(0,2) =  a;  M(0,3) = 0;
	M(1,0) = 0;  M(1,1) = y;  M(1,2) =  b;  M(1,3) = 0;
	M(2,0) = 0;  M(2,1) = 0;  M(2,2) =  c;  M(2,3) = d;
	M(3,0) = 0;  M(3,1) = 0;  M(3,2) = -1;  M(3,3) = 0;
#	undef M

	return frustum_matrix;
}


Matrix Camera::getPerspectiveMatrix( const float fovy, const float aspect, const float zNear, const float zFar ){
	float xmin, xmax, ymin, ymax;

	ymax = zNear * tan( fovy * M_PI / 360.0 );
	ymin = -ymax;
	xmin = ymin * aspect;
	xmax = ymax * aspect;

	return getFrustumMatrix( xmin, xmax, ymin, ymax, zNear, zFar );
}


Matrix Camera::getPickMatrix( const float x, const float y, const float width, const float height, int viewport[4] ){
	Matrix pick_matrix;
	float  sx, sy;
	float  tx, ty;

	sx =  viewport[2] / width;
	sy =  viewport[3] / height;
	tx = (viewport[2] + 2 * (viewport[0] - x )) / width;
	ty = (viewport[3] + 2 * (viewport[1] - y )) / height;

//#	define M(row,col)  pick_matrix.f1[col*4+row]
#	define M(row,col)	pick_matrix.m[col][row]
	M(0, 0) = sx;
	M(0, 1) =  0;
	M(0, 2) =  0;
	M(0, 3) = tx;
	M(1, 0) =  0;
	M(1, 1) = sy;
	M(1, 2) =  0;
	M(1, 3) = ty;
	M(2, 0) =  0;
	M(2, 1) =  0;
	M(2, 2) =  1;
	M(2, 3) =  0;
	M(3, 0) =  0;
	M(3, 1) =  0;
	M(3, 2) =  0;
	M(3, 3) =  1;
#	undef M

	return pick_matrix;
}


void Camera::updatePlanes(){
	Matrix m = projection_matrix * view_matrix;
	m.transpose();
	view_plane[0] = m.transformVector4(  Vector4(-1, 0, 0, 1 )  );
	view_plane[1] = m.transformVector4(  Vector4( 1, 0, 0, 1 )  );
	view_plane[2] = m.transformVector4(  Vector4( 0,-1, 0, 1 )  );
	view_plane[3] = m.transformVector4(  Vector4( 0, 1, 0, 1 )  );
	view_plane[4] = m.transformVector4(  Vector4( 0, 0,-1, 1 )  );
	view_plane[5] = m.transformVector4(  Vector4( 0, 0, 1, 1 )  );
}


}; //  namespace Scenes



/*	int   r;
	int   c;
	float a;
	float b;
	for( r=0; r<4; r++ ){
		for( c=0; c<4; c++ ){
			a = m .f1[c*4+r];
			b = m2.f1[c*4+r];
			printf( "% 6.1f, % 6.1f  :", a, b );
		}
		printf( "\n" );
	}
	printf( "\n" );*/


/* Calculates the six view volume planes in object coordinate (OC) space.
	   
   Algorithm:
   
   A view volume plane in OC is transformed into CC by multiplying it by
   the inverse of the combined ModelView and Projection matrix (M).
   Algebraically, this is written:
		  -1
	 P	 M	 = P
	  oc		cc
   
   The resulting six view volume planes in CC are:
	 [ -1  0  0  1 ]
	 [	1  0  0  1 ]
	 [	0 -1  0  1 ]
	 [	0  1  0  1 ]
	 [	0  0 -1  1 ]
	 [	0  0  1  1 ]
   
   To transform the CC view volume planes into OC, we simply multiply
   the CC plane equations by the combined ModelView and Projection matrices
   using standard vector-matrix multiplication. Algebraically, this is written:  
	 P	 M = P
	  cc	  oc
   
   Since all of the CC plane equation components are 0, 1, or -1, full vector-
   matrix multiplication is overkill. For example, the first element of the
   first OC plane equation is computed as:
	 A = -1 * m0 + 0 * m1 + 0 * m2 + 1 * m3
   This simplifies to:
	 A = m3 - m0
   
   Other terms simplify similarly. In fact, all six plane equations can be
   computed as follows:
	 [ m3-m0  m7-m4  m11-m8  m15-m12 ]
	 [ m3+m0  m7+m4  m11+m8  m15+m12 ]
	 [ m3-m1  m7-m5  m11-m9  m15-m13 ]
	 [ m3+m1  m7+m5  m11+m9  m15+m13 ]
	 [ m3-m2  m7-m6  m11-m10 m15-m14 ]
	 [ m3+m2  m7+m6  m11+m10 m15+m14 ]
 */
