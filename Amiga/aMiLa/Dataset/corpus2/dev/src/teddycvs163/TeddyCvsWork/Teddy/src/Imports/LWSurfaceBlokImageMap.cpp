
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


#if defined(_MSC_VER)
#pragma warning(disable:4786)
#endif


#include "Imports/LWClip.h"
#include "Imports/LWFile.h"
#include "Imports/LWLayer.h"
#include "Imports/LWMesh.h"
#include "Imports/LWSurface.h"
#include "Imports/LWSurfaceBlok.h"
#include "Graphics/Texture.h"
#include "Materials/SdlTexture.h"
#include "SysSupport/Messages.h"
#include "SysSupport/FileScan.h"
#include "SysSupport/StdMaths.h"
#include <cstdio>
using namespace Graphics;


namespace Imports {


void LWSurfaceBlok::applyImageMap(){
	//  Disabled image maps are easy to handle
	if( enable == 0 ){
		return;
	}

	//  At the moment only color textures are supported
	if( texture_channel != ID_COLR ){
		lwo_debug_msg(
			"Texture channel %s not supported; only COLR channel is supported.",
			did( texture_channel )
		);
	}

	//  We need to get the texture name; only still images are supported
	LWLayer *layer = dynamic_cast<LWLayer*>( surface->getLayer() );
	if( layer == NULL ){
		lwo_debug_msg( "Layer not found" );
		return;
	}

	Mesh *mesh= surface->getMesh();
	if( mesh == NULL ){
		lwo_debug_msg( "Mesh not found" );
	}

	LWClip *clip = layer->getClip( texture_image_map );
	if( clip == NULL ){
		lwo_debug_msg(
			"Texture image map %d not found",
			texture_image_map
		);
		return;
	}

	char *texture_file_name = clip->still_image;
	if( texture_file_name == NULL ){
		lwo_debug_msg( "No still image found in clip" );
		return;
	}

	char *fixed_file_name = fix_file_name( texture_file_name );
	int   final_length    = strlen( fixed_file_name ) + strlen( "textures/" ) + 1;
	char *final_file_name = new char[ final_length];
	sprintf( final_file_name, "textures/%s", fixed_file_name );
	lwo_debug_msg( "Look for texture file '%s'", final_file_name );
	Texture *t = new SdlTexture( final_file_name );
	surface->setTexture( t, true );

	//  Choose projection mode
	switch( texture_projection_mode ){
	case LW_PROJECTION_PLANAR:
		mesh->makePlanarTextureCoordinates(
			texture_center,
			texture_size,
			texture_major_axis
		);
		tmap_debug_msg( "Planar Image Map done" );
		break;

	case LW_PROJECTION_CYLINDRICAL:
		mesh->makeCylindricalTextureCoordinates(
			texture_center,
			texture_size,
			texture_major_axis
		);
		tmap_debug_msg( "Cylindrical Image Map done" );
		break;

	case LW_PROJECTION_SPHERICAL:
		mesh->makeSphericalTextureCoordinates(
			texture_center,
			texture_size,
			texture_major_axis
		);
		tmap_debug_msg( "Spherical Image Map done" );
		break;

	case LW_PROJECTION_CUBIC:
		mesh->makeCubicTextureCoordinates(
			texture_center,
			texture_size
		);
		tmap_debug_msg( "Cubic Image Map done" );
		break;

	case LW_PROJECTION_FRONT:
		lwo_debug_msg( "Front projection not yet implemented" );
		break;

	case LW_PROJECTION_UV:
		lwo_debug_msg( "UV projection not yet implemented" );
		break;

	default:
		lwo_debug_msg( "Unknown projection mode" );
		break;
	}

}



/*
Here are some simplified code fragments showing how LightWave computes UV
coordinates from X, Y, and Z.  If the resulting UV coordinates are not in
the range from 0 to 1, the appropriate integer should be added to them to
bring them into that range (the fract function should have accomplished
this by subtracting the floor of each number from itself).  Then they can
be multiplied by the width and height (in pixels) of an image map to
determine which pixel to look up.  The texture size, center, and tiling
parameters are taken right off the texture control panel.


    x -= xTextureCenter;
    y -= yTextureCenter;
    z -= zTextureCenter;
    if (textureType == TT_PLANAR) {
        s = (textureAxis == TA_X) ? z / zTextureSize + .5 :
          x / xTextureSize + .5;
        t = (textureAxis == TA_Y) ? -z / zTextureSize + .5 :
          -y / yTextureSize + .5;
        u = fract(s);
        v = fract(t);
    }
    else if (type == TT_CYLINDRICAL) {
        if (textureAxis == TA_X) {
            xyztoh(z,x,-y,&lon);
            t = -x / xTextureSize + .5;
        }
        else if (textureAxis == TA_Y) {
            xyztoh(-x,y,z,&lon);
            t = -y / yTextureSize + .5;
        }
        else {
            xyztoh(-x,z,-y,&lon);
            t = -z / zTextureSize + .5;
        }
        lon = 1.0 - lon / TWOPI;
        if (widthTiling != 1.0)
            lon = fract(lon) * widthTiling;
        u = fract(lon);
        v = fract(t);
    }
    else if (type == TT_SPHERICAL) {
        if (textureAxis == TA_X)
            xyztohp(z,x,-y,&lon,&lat);
        else if (textureAxis == TA_Y)
            xyztohp(-x,y,z,&lon,&lat);
        else
            xyztohp(-x,z,-y,&lon,&lat);
        lon = 1.0 - lon / TWOPI;
        lat = .5 - lat / PI;
        if (widthTiling != 1.0)
            lon = fract(lon) * widthTiling;
        if (heightTiling != 1.0)
            lat = fract(lat) * heightTiling;
        u = fract(lon);
        v = fract(lat);
    }

support functions:

void xyztoh(float x,float y,float z,float *h)
{
    if (x == 0.0 && z == 0.0)
        *h = 0.0;
    else {
        if (z == 0.0)
            *h = (x < 0.0) ? HALFPI : -HALFPI;
        else if (z < 0.0)
            *h = -atan(x / z) + PI;
        else
            *h = -atan(x / z);
    }
}

void xyztohp(float x,float y,float z,float *h,float *p)
{
    if (x == 0.0 && z == 0.0) {
        *h = 0.0;
        if (y != 0.0)
            *p = (y < 0.0) ? -HALFPI : HALFPI;
        else
            *p = 0.0;
    }
    else {
        if (z == 0.0)
            *h = (x < 0.0) ? HALFPI : -HALFPI;
        else if (z < 0.0)
            *h = -atan(x / z) + PI;
        else
            *h = -atan(x / z);
        x = sqrt(x * x + z * z);
        if (x == 0.0)
            *p = (y < 0.0) ? -HALFPI : HALFPI;
        else
            *p = atan(y / x);
    }
}
*/






};  //  namespace Imports

