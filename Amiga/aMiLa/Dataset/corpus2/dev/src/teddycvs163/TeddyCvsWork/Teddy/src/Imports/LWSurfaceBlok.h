
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
	\class   LWSurfaceBlok
	\ingroup g_imports
	\author  Timo Suoranta
	\brief   Parser for LightWave object file surface blok subchunks
	\warning Very incomplete
	\bug     Destructors missing?
	\date    2000

	A surface may contain any number of 'blocks' which hold texture layers or
	shaders. The blocks are defined by a sub-chunk with the following format. 

	BLOK { 
		type { ordinal[ID4], header[SUB-CHUNK] * },
			attributes[SUB-CHUNK] * 
	} 

	Immediately inside the block sub-chunk is another sub-chunk which is the
	header for the block. The type code for this header block defines the type
	of the block. This header block contains an ordinal string followed by any
	number and type of header sub-chunks. Following the required header sub-chunk,
	sub-chunks which contain the attributes of this block are found in any order.
	The chunks here will depend on the overall type of the block. 

	Ordinary string compare functions are used to sort the ordinal strings. These
	are never read by the user, so they can contain any characters from 1 to 255
	and tend to be very short. The only rule is that an ordinal string must not
	end with a 1 byte, since that prevents arbitrary insertion. 
*/


#ifndef TEDDY_IMPORTS_LW_SURFACE_BLOK_H
#define TEDDY_IMPORTS_LW_SURFACE_BLOK_H


#include "Imports/lwdef.h"
#include "SysSupport/StdList.h"


namespace Imports {


class LWFile;
class LWSurface;


class LWSurfaceBlok {
public:
	LWSurfaceBlok( LWSurface *surface );
	
	void processBlok();

protected:
	//  Apply attributes
	void applyAttributes( ID4 type );
	void applyImageMap  ();
	void applyProcedural();
	void applyGradient  ();
	void applyShader    ();

	//  Header
	void readChannel_ID4        ();
	void readEnable_U2          ();
	void readOpacity_U2_FP4_VX  ();
	void readDisplacementAxis_U2();

	//  Texture Map Parser
	void readTextureMap( ID4 parent );

	//  Texture Maps
	void readTextureCenter_VEC12_VX            ();  //!<  CNTR
	void readTextureSize_VEC12_VX              ();  //!<  SIZE
	void readTextureRotation_VEC12_VX          ();  //!<  ROTA
	void readTextureReferenceObject_S0         ();  //!<  OREF
	void readTextureFalloff_U2_VEC12_VX        ();  //!<  FALL
	void readTextureCoordinateSystem_U2        ();  //!<  CSYS

	//  Image maps
	void readTextureProjectionMode_U2          ();  //!<  PROJ
	void readTextureMajorAxis_U2               ();  //!<  AXIS
	void readTextureImageMap_VX                ();  //!<  IMAG
	void readTextureWrapOptions_U2_U2          ();  //!<  WRAP
	void readTextureWrapWidthAmount_FP4_VX     ();  //!<  WRPW
	void readTextureWrapHeightAmount_FP4_VX    ();  //!<  WRPH
	void readTextureUV_VertexMap_S0            ();  //!<  VMAP
	void readTextureAntialiasingStrength_U2_FP4();  //!<  AAST
	void readTexturePixelBlending_U2           ();  //!<  PIXB
	void readTextureStack_VX                   ();  //!<  STCK
	void readTextureAmplitude_FP4_VX           ();  //!<  TAMP
	void readTextureNegative_U2                ();  //!<  NEGA

	//  Procedurals
	void readProceduralAxis_U2              ();  //!<  AXIS
	void readProceduralBasicValue_FP4_1_or_3();  //!<  VALU
	void readProceduralAlgorithm_S0_data    ();  //!<  FUNC

	//  Gradients
	void readGradientParameter_S0           ();  //!<  PNAM
	void readGradientItem_S0                ();  //!<  INAM
	void readGradientRangeStart_FP4         ();  //!<  GRST
	void readGradientRangeEnd_FP4           ();  //!<  GREN
	void readGradientRepeat_U2              ();  //!<  GRPT
	void readGradientKeys_FP4_data_FP4      ();  //!<  FKEY
	void readGradientKeyParameters_data_U2  ();  //!<  IKEY

	//  Shaders
	void readShaderAlgorithm_S0_data        ();  //!<  FUNC

protected:
	LWFile    *f;
	LWSurface *surface;

	//  Header values
	ID4     texture_channel;    //!<  CHAN
	U2      enable;             //!<  ENAB
	U2      opacity_type;       //!<  OPAC
	FP4     opacity;            //!<  OPAC
	VX      opacity_envelope;   //!<  OPAC
	U2      displacement_axis;  //!<  AXIS

	//  Texture maps
	VEC12   texture_center;                        //!<  CNTR
	VX      texture_center_envelope;               //!<  CNTR
	VEC12   texture_size;                          //!<  SIZE
	VX      texture_size_envelope;                 //!<  SIZE
	VEC12   texture_rotation;                      //!<  ROTA
	VX      texture_rotation_envelope;             //!<  ROTA
	S0      texture_reference_object;              //!<  OREF
	U2      texture_falloff_type;                  //!<  FALL
	VEC12   texture_falloff;                       //!<  FALL
	VX      texture_falloff_envelope;              //!<  FALL	
	U2      texture_coordinate_system;             //!<  CSYS

	//  Image maps
	U2      texture_projection_mode;               //!<  PROJ
	U2      texture_major_axis;                    //!<  AXIS
	VX      texture_image_map;                     //!<  IMAG
	U2      texture_width_wrap;                    //!<  WRAP
	U2      texture_height_wrap;                   //!<  WRAP
	FP4     texture_wrap_width_cycles;             //!<  WRPW
	VX      texture_wrap_width_cycles_envelope;    //!<  WRPW
	FP4     texture_wrap_height_cycles;			   //!<  WRPH
	VX      texture_wrap_height_cycles_envelope;   //!<  WRPH  
	S0      texture_uv_vertex_map;                 //!<  VMAP
	U2      texture_antialiasing_type;             //!<  AAST
	FP4     texture_antialiasing_strength;         //!<  AAST
	U2      texture_pixel_blending;                //!<  PIXB
	VX      texture_stack;                         //!<  STCK
	FP4     texture_amplitude;                     //!<  TAMP
	VX      texture_amplitude_envelope;            //!<  TAMP
	U2      texture_negative;                      //!<  NEGA

	//  Procedurals
	U2  procedural_axis;       //!<  AXIS
	S0  procedural_algorithm;  //!<  FUNC

	//  Gradients
	S0  gradient_parameter;    //!<  PNAM
	S0  gradient_item;         //!<  INAM
	FP4 gradient_range_start;  //!<  GTST
	FP4 gradient_range_end;    //!<  GREN
	U2  gradient_repeat;       //!<  GRPT

	//  Shaders
	S0  shader_algorithm;      //!<  FUNC

};


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_SURFACE_BLOK_H

