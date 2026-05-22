
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


#include "Imports/LWFile.h"
#include "Imports/LWLayer.h"
#include "Imports/LWSurface.h"
#include "Imports/LWMesh.h"
#include "Imports/LWTexture.h"
//#include "Materials/SdlTexture.h"
#include "Materials/PixFileTexture.h"
#include "SysSupport/FileScan.h"
#include <cstdio>
using namespace Materials;


namespace Imports {


LWTexture::LWTexture( LWSurface *surface, int map_type ){
	this->f                       = surface->getLayer()->getMesh()->getFile();
	this->surface                 = surface;
	switch( map_type ){
	case LW_PLANAR_IMAGE_MAP     : texture_projection_mode = LW_PROJECTION_PLANAR     ; break;
	case LW_CYLINDRICAL_IMAGE_MAP: texture_projection_mode = LW_PROJECTION_CYLINDRICAL; break;
	case LW_SPHERICAL_IMAGE_MAP  : texture_projection_mode = LW_PROJECTION_SPHERICAL  ; break;
	case LW_CUBIC_IMAGE_MAP      : texture_projection_mode = LW_PROJECTION_CUBIC      ; break;
	default: lwo_debug_msg( "Unknown projection mode" ); break;
	}
	texture_center          = Vector(0,0,0);        //!<  TCTR
	texture_size            = Vector(1,1,1);        //!<  TSIZ
//	texture_projection_mode = LW_PLANAR_IMAGE_MAP;  //!<  CTEX
	texture_major_axis      = TEXTURE_AXIS_X;       //!<  TFLG
	texture_image_map       = 0;                    //!<  TIMG
}


void LWTexture::applyTexture(){
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

	char *texture_file_name = texture_image_map;
	if( texture_file_name == NULL ){
		lwo_debug_msg( "No still image found in clip" );
		return;
	}

	char *fixed_file_name = fix_file_name( texture_file_name );
	int   final_length    = strlen( fixed_file_name ) + strlen( "buda_textures/" ) + 1;
	char *final_file_name = new char[ final_length];
	sprintf( final_file_name, "buda_textures/%s", fixed_file_name );
	final_file_name[ final_length-4 ] = 'p';
	final_file_name[ final_length-3 ] = 'i';
	final_file_name[ final_length-2 ] = 'x';
	lwo_debug_msg( "Look for texture file '%s'", final_file_name );
	Texture *t = new PixFileTexture( final_file_name );
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
void LWTexture::processTexture(){
	ID4 chunk_type   = f->read_ID4();
	U2  chunk_length = f->read_U2();

	f->pushDomain( chunk_length );

	switch( chunk_type ){
		case ID_TFLG: readTextureFlags_U2          (); break;
		case ID_TSIZ: readTextureSize_VEC12        (); break;
		case ID_TCTR: readTextureCenter_VEC12      (); break;
		case ID_TFAL: readTextureFallOff_VEC12     (); break;
		case ID_TVEL: readTextureVelocity_VEC12    (); break;
		case ID_TREF: readTextureReferenceObject_S0(); break;
		case ID_TCLR: readTextureColor_COL4        (); break;
		case ID_TVAL: readTextureValue_IP2         (); break;
		case ID_TAMP: readBumpTextureAmplitude_FP4 (); break;
		case ID_TFP : readTextureAlgorithm_F4      (); break;  // ns not yet handled
		case ID_TIP : readTextureAlgorithm_I2      (); break;
		case ID_TSP : readTextureAlgorithm_F4      (); break;  // obsolete
		case ID_TFRQ: readTextureAlgorithm_I2      (); break;  // obsolete
		case ID_TIMG: readImageMap_FNAM0           (); break;
		case ID_TALP: readImageAlpha_FNAM0         (); break;
		case ID_TWRP: readImageWarpOptions_U2_U2   (); break;
		case ID_TAAS: readAntialiasingStrength_FP4 (); break;
		case ID_TOPC: readTextureOpacity_FP4       (); break;
		default: break;
	}

	f->popDomain( true );

} */

void LWTexture::readTextureFlags_U2(){
	int count = 0;
	U2  flags = f->read_U2();	

	lwo_debug_msg( "TMap flags 0x%x", flags );

	if( (flags & LW_TF_AXIS_X) == LW_TF_AXIS_X ){
		texture_major_axis = TEXTURE_AXIS_X;
		lwo_debug_msg( "TMap axis x" );
	}

	if( (flags & LW_TF_AXIS_Y) == LW_TF_AXIS_Y ){
		texture_major_axis = TEXTURE_AXIS_Y;
		lwo_debug_msg( "TMap axis y" );
	}
	if( (flags & LW_TF_AXIS_Z) == LW_TF_AXIS_Z ){
		texture_major_axis = TEXTURE_AXIS_Z;
		lwo_debug_msg( "TMap axis z" );
	}

	/*if( flags & LW_TF_WORLD_COORDINATES ){
	}
	if( flags & LW_TF_NEGATIVE_IMAGE ){
	}
	if( flags & LW_TF_PIXEL_BLENDING ){
	}
	if( flags & LW_TF_ANTIALISING ){
	}*/
}

void LWTexture::readTextureSize_VEC12(){
	texture_size = f->read_VEC12();
}

void LWTexture::readTextureCenter_VEC12(){
	texture_center = f->read_VEC12();
}

void LWTexture::readTextureFallOff_VEC12(){
}

void LWTexture::readTextureVelocity_VEC12(){
}

void LWTexture::readTextureReferenceObject_S0(){
}

void LWTexture::readTextureColor_COL4(){
}

void LWTexture::readTextureValue_IP2(){
}

void LWTexture::readBumpTextureAmplitude_FP4(){
}

void LWTexture::readTextureAlgorithm_F4(){
}

void LWTexture::readTextureAlgorithm_I2(){
}

void LWTexture::readImageMap_FNAM0(){
	texture_image_map = f->read_FNAM0();
}

void LWTexture::readImageAlpha_FNAM0(){
	//char *image_alpha = f->read_FNAM0();
}

void LWTexture::readImageWarpOptions_U2_U2(){
}

void LWTexture::readAntialiasingStrength_FP4(){
}

void LWTexture::readTextureOpacity_FP4(){
}


};  //  namespace Imports

