
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


#include "Models/Face.h"
#include "Models/Mesh.h"
#include "Models/Vertex.h"
#include "SysSupport/Messages.h"
#include "SysSupport/StdMaths.h"
#include <cstdio>
using namespace std;


namespace Models {


#define TC_EPSILON (double)(0.0009) // texturecoordinate face epsilon


//!  This subroutine is used by texture coordinate calculations
static void xyz_to_h( const float x, const float y, const float z, float &h ){
    if( x == 0 && z == 0){
        h = 0;
	}else{
        if( z == 0 ){
            h = (x < 0) ? M_HALF_PI : -M_HALF_PI;
        }else if (z < 0){
            h = -atan(x / z) + M_PI;
        }else{
            h = -atan(x / z);
		}
    }
}


//!  This subroutine is used by texture coordinate calculations
static void xyz_to_hp( float x, float y, float z, float &h, float &p ){

    if( x == 0 && z == 0 ){
        h = 0;

        if( y != 0 ){
            p = (y<0) ? -M_HALF_PI : M_HALF_PI;
        }else{
            p = 0;
		}

    }else{
        if( z == 0 ){
            h = (x < 0) ? M_HALF_PI : -M_HALF_PI;
        }else if( z < 0){
            h = -atan( x/z ) + M_PI;
        }else{
            h = -atan( x/z );
		}

        x = sqrt( x*x + z*z );

        if( x == 0 ){
            p = (y<0) ? -M_HALF_PI : M_HALF_PI;
        }else{
            p = atan( y/x );
		}
    }
}


//!  This subroutine is used by texture coordinate calculations
static float fract( float f ){
	float val = (float)(f - floor( f ) );

	return val;
}


void Mesh::setTextureCoordinate( Face *f, list<Vertex*>::iterator v_it, float s, float t ){
	Vertex *vx = *v_it;

	Vector new_tc = Vector( s, t, 0 );

	//  If the old vertex has no texture coordinate set, place new coordinate there
	if( vx->isDisabled(VX_HAS_TEXTURE) ){
		tmap_debug_msg(
			"Vertex %ld had no old texture coordinate, setting (%.8f, %.8f)",
			(unsigned long)vx,
			s, 
			t
		);
		vx->setTexture( new_tc );
		if( vx->isDisabled(VX_HAS_TEXTURE) ){
			tmap_debug_msg( "Vertex tc problem" );
		}
	}else{
		//  Otherwise if the old texture coordinate is different,
		//  make a new Vertex and replace the Vertex pointer in
		//  Face's Vertex list
		Vector old_tc = vx->getTexture();
		float ds = fabs( old_tc.v[0] - new_tc.v[0] );
		float dt = fabs( old_tc.v[1] - new_tc.v[1] );
		if( ds > TC_EPSILON || dt > TC_EPSILON ){
			tmap_debug_msg(
				"Vertex %ld had a different texture coordinate delta = (%.8f, %.8f), making copy new tc = (%.8f, %.8f)",
				(unsigned long)vx,
				ds,
				dt,
				s, 
				t
			);
			Vertex *new_vertex = new Vertex( vx );
			new_vertex->setTexture( new_tc );
			*v_it = new_vertex;
			//new_vertex->debug();
		}else{
			tmap_debug_msg(
				"Vertex %ld had the same texture coordinate delta = (%.8f, %.8f), tc = (%.8f, %.8f)",
				(unsigned long)vx,
				ds,
				dt,
				s, 
				t
			);
			//  Otherwise, the old texture coordinate is the same
			//  as the new, and we do nothing about it.
		}
	}
}


/*!
	Here are some simplified code fragments showing how
	LightWave computes UV coordinates from X, Y, and Z.
	If the resulting UV coordinates are not in the range
	from 0 to 1, the appropriate integer should be added
	to them to bring them into that range (the fract function
	should have accomplished this by subtracting the floor
	of each number from itself).  Then they can be multiplied
	by the width and height (in pixels) of an image map to
	determine which pixel to look up.  The texture size,
	center, and tiling parameters are taken right off the
	texture control panel.

	Texture coordinate calculation for Mesh is done
	Face by Face.

	For each Face, we calculate a new texture coordinate
	for each Vertex of the Face.

	If the Vertex in the Face does not yet have a texture
	coordinate set, we will set the new texture coordinate
	to the existing Vertex.

	If the Vertex in the Face does have the same texture
	coordinate as we just calculated, we do nothing to it.

	If the Vertex in the Face has a different texture coordinate,
	then we replace the old Vertex pointer in Face's Vertex
	list with a new Vertex that inherits the old Vertex but has
	the new texture coordinate. The old Vertex is not changed,
	and other Face's Vertex lists still point to it.

	This routine is not recursive; sub-meshes are not processed.
*/
void Mesh::makePlanarTextureCoordinates( Vector center, Vector size, int axis ){
	float s = 0;
	float t = 0;
	float u;
	float v;
	float x, y, z;

	tmap_debug_msg( "Planar Image Map, Axis %d", axis );
	tmap_debug_msg(
		"Texture center (%.1f, %.1f, %.1f )",
		center.v[0],
		center.v[1],
		center.v[2]
	);
	tmap_debug_msg(
		"Texture size (%.1f, %.1f, %.1f )",
		size.v[0],
		size.v[1],
		size.v[2]
	);

	int face_count   = 0;
	int vertex_count = 0;

	//  For each Face Element in the Mesh
	list<Element*>::iterator e_it = elements.begin();
	while( e_it != elements.end() ){
		Element *e = (*e_it);
		Face    *f = dynamic_cast<Face*>( e );
		if( f == NULL ){
			tmap_debug_msg( "Non-face element found in Mesh" );
			e_it++;
			continue;
		}
		face_count++;

		//  For each Vertex in the Face
		int face_vertices = 0;
		list<Vertex*>::iterator v_it = f->vertices.begin();
		while( v_it != f->vertices.end() ){
			Vertex *vx = *v_it;
			if( vx == NULL ){
				tmap_debug_msg( "Found NULL vertex" );
				v_it++;
				continue;
			}
		
			vertex_count++;
			face_vertices++;

			x = vx->getVertex().v[0];
			y = vx->getVertex().v[1];
			z = vx->getVertex().v[2];

			//  Calculate texture coordinate from (x, y, z)
			x -= center.v[0];
			y -= center.v[1];
			z -= center.v[2];

			switch( axis ){
			case TEXTURE_AXIS_X: s = ( z / size.v[2]) + .5; t = (-y / size.v[1]) + .5; break;
			case TEXTURE_AXIS_Y: s = ( x / size.v[0]) + .5; t = (-z / size.v[2]) + .5; break;
			case TEXTURE_AXIS_Z: s = ( x / size.v[0]) + .5; t = (-y / size.v[1]) + .5; break;
			default       : lwo_debug_msg( "Bad axis %d", axis ); break;
			}

			u = s; //fract( s );
			v = t; //fract( t );
			if( fabs(u)<TC_EPSILON && fabs(v)<TC_EPSILON ){
				tmap_debug_msg(
					"x = %.5f, y = %.5f, z = %.5f, size.v[0] = %.5f size.v[1] = %.5f size.v[2] = %.5f",
					x,
					y,
					z,
					size.v[0],
					size.v[1],
					size.v[2]
				);
				tmap_debug_msg( "Problem" );
			}
			setTextureCoordinate( f, v_it, u, v );

			v_it++;
		}  //  vertex iterator v_it
		tmap_debug_msg( "Face ready, %ld vertices", face_vertices );

		e_it++;
	}  //  element iterator e_it;

	tmap_debug_msg(
		"Texture coordinates ready, %d faces %d vertices",
		face_count,
		vertex_count
	);

}

void Mesh::makeCylindricalTextureCoordinates( Vector center, Vector size, int axis ){
	float t = 0;
	float u;
	float v;
	float lon;
	float x,y,z;

	tmap_debug_msg( "Cylindrical Image Map, Axis %d", axis );
	tmap_debug_msg(
		"Texture center (%.1f, %.1f, %.1f )",
		center.v[0],
		center.v[1],
		center.v[2]
	);
	tmap_debug_msg(
		"Texture size (%.1f, %.1f, %.1f )",
		size.v[0],
		size.v[1],
		size.v[2]
	);

	int face_count   = 0;
	int vertex_count = 0;

	list<Element*>::iterator e_it = elements.begin();
	while( e_it != elements.end() ){
		Element *e = (*e_it);
		Face    *f = dynamic_cast<Face*>( e );
		if( f == NULL ){
			lwo_debug_msg( "Non-face element found in Mesh" );
			e_it++;
			continue;
		}
		face_count++;

		list<Vertex*>::iterator v_it = f->vertices.begin();
		while( v_it != f->vertices.end() ){
			Vertex *vx = (*v_it);
			if( vx == NULL ){
				lwo_debug_msg( "Found NULL vertex" );
				v_it++;
				continue;
			}

			vertex_count++;

			x = vx->getVertex().v[0];
			y = vx->getVertex().v[1];
			z = vx->getVertex().v[2];

			x -= center.v[0];
			y -= center.v[1];
			z -= center.v[2];

			switch( axis ){
			case TEXTURE_AXIS_X: xyz_to_h(  z,  x, -y, lon ); t = -x / size.v[0] + .5; break;
			case TEXTURE_AXIS_Y: xyz_to_h( -x,  y,  z, lon ); t = -y / size.v[1] + .5; break;
			case TEXTURE_AXIS_Z: xyz_to_h( -x,  z, -y, lon ); t = -z / size.v[2] + .5; break;
			default: lwo_debug_msg( "Bad axis %d", axis ); break;
			}

			lon = 1 - lon / M_2_PI;
		//	if( widthTiling != 1 ) lon = fract(lon) * widthTiling;
			u = fract( lon );
			v = fract( t   );

			setTextureCoordinate( f, v_it, u, v );

			v_it++;
		}

		e_it++;
	}

	lwo_debug_msg(
		"Texture coordinates ready, %d faces %d vertices",
		face_count,
		vertex_count
	);

}

void Mesh::makeSphericalTextureCoordinates( Vector center, Vector size, int axis ){
	float lon;
	float lat;
	float u;
	float v;
	float x,y,z;

	lwo_debug_msg( "Spherical Image Map, Axis %d", axis );
	lwo_debug_msg(
		"Texture center (%.1f, %.1f, %.1f )",
		center.v[0],
		center.v[1],
		center.v[2]
	);
	lwo_debug_msg(
		"Texture size (%.1f, %.1f, %.1f )",
		size.v[0],
		size.v[1],
		size.v[2]
	);

	int face_count   = 0;
	int vertex_count = 0;

	list<Element*>::iterator e_it = elements.begin();
	while( e_it != elements.end() ){
		Element *e = (*e_it);
		Face    *f = dynamic_cast<Face*>( e );
		if( f == NULL ){
			lwo_debug_msg( "Non-face element found in Mesh" );
			e_it++;
			continue;
		}
		face_count++;

		list<Vertex*>::iterator v_it = f->vertices.begin();
		while( v_it != f->vertices.end() ){
			Vertex *vx = (*v_it);
			if( vx == NULL ){
				lwo_debug_msg( "Found NULL vertex" );
				v_it++;
				continue;
			}

			vertex_count++;

			x = vx->getVertex().v[0];
			y = vx->getVertex().v[1];
			z = vx->getVertex().v[2];

			x -= center.v[0];
			y -= center.v[1];
			z -= center.v[2];

			switch( axis ){
			case TEXTURE_AXIS_X: xyz_to_hp(  z,  x, -y, lon, lat ); break;
			case TEXTURE_AXIS_Y: xyz_to_hp( -x,  y,  z, lon, lat ); break;
			case TEXTURE_AXIS_Z: xyz_to_hp( -x,  z, -y, lon, lat ); break;
			default: lwo_debug_msg( "Bad axis %d", axis ); break;
			}

			//lon = 1.0 - lon / M_2_PI;
			lon = lon / M_2_PI;
			lat = 0.5 - lat / M_PI;
			//	if( widthTiling  != 1 ) lon = fract(lon) * widthTiling;
			//	if( heightTiling != 1 ) lat = fract(lat) * heightTiling;
			u = fract( lon );
			v = fract( lat );

			setTextureCoordinate( f, v_it, u, v );

			v_it++;
		}

		e_it++;
	}

	lwo_debug_msg(
		"Texture coordinates ready, %d faces %d vertices",
		face_count,
		vertex_count
	);
}


void Mesh::makeCubicTextureCoordinates( Vector center, Vector size ){
	float s = 0;
	float t = 0;
	float u;
	float v;
	float x, y, z;

	tmap_debug_msg( "Cubic Image Map" );
	tmap_debug_msg(
		"Texture center (%.1f, %.1f, %.1f )",
		center.v[0],
		center.v[1],
		center.v[2]
	);
	tmap_debug_msg(
		"Texture size (%.1f, %.1f, %.1f )",
		size.v[0],
		size.v[1],
		size.v[2]
	);

	int face_count   = 0;
	int vertex_count = 0;

	//  For each Face Element in the Mesh
	list<Element*>::iterator e_it = elements.begin();
	while( e_it != elements.end() ){
		Element *e = (*e_it);
		Face    *f = dynamic_cast<Face*>( e );
		if( f == NULL ){
			tmap_debug_msg( "Non-face element found in Mesh" );
			e_it++;
			continue;
		}
		face_count++;

		if( f->isDisabled(FC_HAS_FACE_NORMAL) ){
			f->makeNormal();
		}

		Vector fn   = f->getNormal();
		int    axis = TEXTURE_AXIS_X;
		if( fabs(fn.v[1]) >= fabs(fn.v[0]) && fabs(fn.v[1]) >= fabs(fn.v[2]) ) axis = TEXTURE_AXIS_Y;
		if( fabs(fn.v[2]) >= fabs(fn.v[0]) && fabs(fn.v[2]) >= fabs(fn.v[1]) ) axis = TEXTURE_AXIS_Z;

		//  For each Vertex in the Face
		int face_vertices = 0;
		list<Vertex*>::iterator v_it = f->vertices.begin();
		while( v_it != f->vertices.end() ){
			Vertex *vx = *v_it;
			if( vx == NULL ){
				tmap_debug_msg( "Found NULL vertex" );
				v_it++;
				continue;
			}
		
			vertex_count++;
			face_vertices++;

			x = vx->getVertex().v[0];
			y = vx->getVertex().v[1];
			z = vx->getVertex().v[2];

			//  Calculate texture coordinate from (x, y, z)
			x -= center.v[0];
			y -= center.v[1];
			z -= center.v[2];

			switch( axis ){
			case TEXTURE_AXIS_X: s = ( z / size.v[2]) + .5; t = (-y / size.v[1]) + .5; break;
			case TEXTURE_AXIS_Y: s = ( x / size.v[0]) + .5; t = (-z / size.v[2]) + .5; break;
			case TEXTURE_AXIS_Z: s = ( x / size.v[0]) + .5; t = (-y / size.v[1]) + .5; break;
			default: lwo_debug_msg( "Bad axis %d", axis ); break;
			}

			u = s; //fract( s );
			v = t; //fract( t );
			if( fabs(u)<TC_EPSILON && fabs(v)<TC_EPSILON ){
				tmap_debug_msg(
					"x = %.5f, y = %.5f, z = %.5f, size.v[0] = %.5f size.v[1] = %.5f size.v[2] = %.5f",
					x,
					y,
					z,
					size.v[0],
					size.v[1],
					size.v[2]
				);
				tmap_debug_msg( "Problem" );
			}
			setTextureCoordinate( f, v_it, u, v );

			v_it++;
		}  //  vertex iterator v_it
		tmap_debug_msg( "Face ready, %ld vertices", face_vertices );

		e_it++;
	}  //  element iterator e_it;

	tmap_debug_msg(
		"Texture coordinates ready, %d faces %d vertices",
		face_count,
		vertex_count
	);

}


};  //  namespace Imports

