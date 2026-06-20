
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


#include "Imports/LWFile.h"
#include "Imports/LWLayer.h"
#include "Imports/LWMesh.h"
#include "Imports/LWSurface.h"
#include "Imports/LWSurfaceBlok.h"
#include "SysSupport/Messages.h"
#include <cstdio>


namespace Imports {


LWSurfaceBlok::LWSurfaceBlok( LWSurface *surface ){
	this->f       = surface->getLayer()->getMesh()->getFile();
	this->surface = surface;
	ID4     texture_channel    = 0;
	U2      enable             = 0;
	U2      opacity_type       = 0;
	FP4     opacity            = 0;
	VX      opacity_envelope   = 0;
	U2      displacement_axis  = 0;

	VEC12   texture_center                        = Vector(0,0,0);
	VX      texture_center_envelope               = 0;
	VEC12   texture_size                          = Vector(1,1,1);
	VX      texture_size_envelope                 = 0;
	VEC12   texture_rotation                      = Vector(0,0,0);
	VX      texture_rotation_envelope             = 0;
	S0      texture_reference_object              = NULL;
	U2      texture_falloff_type                  = 0;
	VEC12   texture_falloff                       = Vector(0,0,0);
	VX      texture_falloff_envelope              = 0;
	U2      texture_coordinate_system             = 0;

	U2      texture_projection_mode               = 0;
	U2      texture_major_axis                    = 0;
	VX      texture_image_map                     = 0;
	U2      texture_width_wrap                    = 0;
	U2      texture_height_wrap                   = 0;
	FP4     texture_wrap_width_cycles             = 0;
	VX      texture_wrap_width_cycles_envelope    = 0;
	FP4     texture_wrap_height_cycles			  = 0;
	VX      texture_wrap_height_cycles_envelope   = 0;
	S0      texture_uv_vertex_map                 = NULL;
	U2      texture_antialiasing_type             = 0;
	FP4     texture_antialiasing_strength         = 0;
	U2      texture_pixel_blending                = 0;
	VX      texture_stack                         = 0;
	FP4     texture_amplitude                     = 0;
	VX      texture_amplitude_envelope            = 0;
	U2      texture_negative                      = 0;

	U2  procedural_axis       = 0;
	S0  procedural_algorithm  = NULL;

	S0  gradient_parameter    = NULL;
	S0  gradient_item         = NULL;
	FP4 gradient_range_start  = 0;
	FP4 gradient_range_end    = 0;
	U2  gradient_repeat       = 0;

	S0  shader_algorithm      = NULL;

}


/*!  LWO2 BLOK

	Surface Blocks

	A surface may contain any number of blocks which hold
	texture layers or shaders. Each block is defined by a
	subchunk with the following format.

	BLOK { header[SUB-CHUNK], attributes[SUB-CHUNK] * } 

	Since this regular expression hides much of the structure
	of a block, it may be helpful to visualize a typical texture
	block in outline form. 

	-block
		-header
			-ordinal string 
			-channel 
			-enable flag 
			-opacity... 
		-texture mapping
			-center 
			-size...	
		-other attributes... 

	The first subchunk is the header. The subchunk ID specifies
	the block type, and the subchunks within the header subchunk
	define properties that are common to all block types. The
	ordinal string defines the sorting order of the block relative
	to other blocks. The header is followed by other subchunks
	specific to each type. For some texture layers, one of these
	will be a texture mapping subchunk that defines the mapping
	from object to texture space. All of these components are
	explained in the following sections.

	Ordinal Strings

	Each BLOK represents a texture layer applied to one of the
	surface channels, or a shader plug-in applied to the surface.
	If more than one layer is applied to a channel, or more than
	one shader is applied to the surface, we need to know the
	evaluation order of the layers or shaders, or in what order
	they are "stacked." The ordinal string defines this order.

	Readers can simply compare ordinal strings using the C strcmp
	function to sort the BLOKs into the correct order. Writers of
	LWO2 files need to generate valid ordinal strings that put the
	texture layers and shaders in the right order. See the Object
	Examples supplement for an example function that generates
	ordinal strings.

	To understand how LightWave uses these, imagine that instead
	of strings, it used floating-point fractions as the ordinals.
	Whenever LightWave needed to insert a new block between two
	existing blocks, it would find the new ordinal for the inserted
	block as the average of the other two, so that a block inserted
	between ordinals 0.5 and 0.6 would have an ordinal of 0.55.

	But floating-point ordinals would limit the number of insertions
	to the (fixed) number of bits used to represent the mantissa.
	Ordinal strings are infinite-precision fractions written in
	base 255, using the ASCII values 1 to 255 as the digits (0 isn't
	used, since it's the special character that marks the end of the
	string).

	Ordinals can't end on a 1, since that would prevent arbitrary
	insertion of other blocks. A trailing 1 in this system is like
	a trailing 0 in decimal, which can lead to situations like this, 

	   0.5    "\x80"
	   0.50   "\x80\x01"

	where there's no daylight between the two ordinals for inserting
	another block.
*/
void LWSurfaceBlok::processBlok(){
	ID4  blok_type    = f->read_ID4();
	ID4  blok_ordinal = f->read_ID4();
	bool header_done  = false;
	ID4  subchunk;
	U2   length;

	while( f->domainLeft() > 0 ){

		subchunk = f->read_ID4();
		length   = f->read_U2();
		f->pushDomain( length );

		lwo_debug_msg(
			"LWO2::SURF::BLOK::%s::%s (%d bytes)",
			did( blok_type ),
			did( subchunk  ),
			length
		);

		//  Headers are accepted only in the beginning
		if( header_done == false ){
			switch( subchunk ){
			case ID_CHAN: readChannel_ID4        (); break;
			case ID_ENAB: readEnable_U2          (); break;
			case ID_OPAC: readOpacity_U2_FP4_VX  (); break;
			case ID_AXIS: readDisplacementAxis_U2(); break;
			default:      header_done = true;        break;
			}
		}

		//  Other than headers
		if( header_done == true ){
			//  LWO2 BLOK Block Headers
			//  
			//  Every block contains a header subchunk.
			//  
			//  block-header { ordinal[S0], block-attributes[SUB-CHUNK] * } 
			//  
			//  The ID of the header subchunk identifies the block type and can
			//  be one of the following.
			//  
			//  IMAP - an image map texture
			//  PROC - a procedural texture
			//  GRAD - a gradient texture
			//  SHDR - a shader plug-in
			//  
			//  The header contains an ordinal string (described above) and
			//  subchunks that are common to all block types. 
			switch( blok_type ){
			//  LWO2 BLOK Image Maps
			//  
			//  Texture blocks with a header type of IMAP are image maps.
			//  These use an image to modulate one of the surface channels.
			//  In addition to the basic parameters listed below, the block
			//  may also contain a TMAP chunk. 
			//
			case ID_IMAP:
				switch( subchunk ){
				case ID_TMAP: readTextureMap               ( ID_IMAP ); break;
				case ID_PROJ: readTextureProjectionMode_U2          (); break;
				case ID_AXIS: readTextureMajorAxis_U2               (); break;
				case ID_IMAG: readTextureImageMap_VX                (); break;
				case ID_WRAP: readTextureWrapOptions_U2_U2          (); break;
				case ID_WRPW: readTextureWrapWidthAmount_FP4_VX     (); break;
				case ID_WRPH: readTextureWrapHeightAmount_FP4_VX    (); break;
				case ID_VMAP: readTextureUV_VertexMap_S0            (); break;
				case ID_AAST: readTextureAntialiasingStrength_U2_FP4(); break;
				case ID_PIXB: readTexturePixelBlending_U2           (); break;
				case ID_STCK: readTextureStack_VX                   (); break;
				case ID_TAMP: readTextureAmplitude_FP4_VX           (); break;
				case ID_NEGA: readTextureNegative_U2                (); break;

				//  New block state?
				default:
					lwo_debug_msg( "FIX End IMAP, to %s", did(subchunk) );
					applyAttributes( blok_type );
					blok_type = subchunk;
					break;
				}
				break;  //  ID_IMAP

			//  LWO2 BLOK Procedural Textures
			//  
			//  Texture blocks of type PROC are procedural textures
			//  that modulate the value of a surface channel
			//  algorithmically. 
			//  
			case ID_PROC:
				switch( subchunk ){
				case ID_TMAP: readTextureMap            ( ID_PROC ); break;
				case ID_AXIS: readProceduralAxis_U2              (); break;
				case ID_VALU: readProceduralBasicValue_FP4_1_or_3(); break;
				case ID_FUNC: readProceduralAlgorithm_S0_data    (); break;
																  
				//  New block state?
				default:
					lwo_debug_msg( "FIX End PROC, to %s", did(subchunk) );
					applyAttributes( blok_type );
					blok_type = subchunk;
					break;
				}
				break;  //  ID_PROC

			//  Gradient Textures
			//  
			//  Texture blocks of type GRAD are gradient textures that
			//  modify a surface channel by mapping an input parameter
			//  through an arbitrary transfer function. Gradients are
			//  represented to the user as a line containing keys. Each
			//  key is a color, and the gradient function is an interpolation
			//  of the keys in RGB space. The input parameter selects a
			//  point on the line, and the output of the texture is the
			//  value of the gradient at that point. 
			//  
			case ID_GRAD:
				switch( subchunk ){
				case ID_PNAM: readGradientParameter_S0           (); break;
				case ID_INAM: readGradientItem_S0                (); break;
				case ID_GRST: readGradientRangeStart_FP4         (); break;
				case ID_GREN: readGradientRangeEnd_FP4           (); break;
				case ID_GRPT: readGradientRepeat_U2              (); break;
				case ID_FKEY: readGradientKeys_FP4_data_FP4      (); break;
				case ID_IKEY: readGradientKeyParameters_data_U2  (); break;

				//  New blok state?
				default:
					lwo_debug_msg( "FIX End GRAD, to %s", did(subchunk) );
					applyAttributes( blok_type );
					blok_type = subchunk;
					break;
				}
				break;  //  ID_GRAD

			//  LWO2 BLOK Shaders
			//  
			//  Shaders are BLOK subchunks with a header type
			//  of SHDR. They are applied to a surface after
			//  all basic channels and texture layers are
			//  evaluated, and in the order specified by the
			//  ordinal sequence. The only header chunk they
			//  support is ENAB and they need only one data
			//  chunk to describe them. 
			//  
			case ID_SHDR:
				switch( subchunk ){
				case ID_FUNC: readShaderAlgorithm_S0_data        (); break;

				//  New blok state?
				default:
					lwo_debug_msg( "FIX End SHDR, to %s", did(subchunk) );
					applyAttributes( blok_type );
					blok_type = subchunk;
					break;
				}
				break;  //  ID_SHDR

			//  Unknown attribute -- blok_state
			default:
				lwo_debug_msg(
					"LWO2::SURF::BLOK parser confused by blok type %s",
					did(blok_type)
				);
				break;
			}
		}

		f->popDomain( true );
	}
	applyAttributes( blok_type );
}


void LWSurfaceBlok::applyAttributes( ID4 type ){
	switch( type ){
	case ID_IMAP: applyImageMap  (); break;
	case ID_PROC: applyProcedural(); break;
	case ID_GRAD: applyGradient  (); break;
	case ID_SHDR: applyShader    (); break;
	default:
		lwo_debug_msg( "Unknown BLOK attribute %s", type );
		break;
	}
}


/*!  LWO2 BLOK Texture Mapping
	
	Image map and procedural textures employ the TMAP subchunk
	to define the mapping they use to get from object or world
	coordinate space to texture space. 
	
	TMAP { attributes[SUB-CHUNK] * } 
	
	The TMAP subchunk contains a set of attribute chunks which
	describe the different aspects of this mapping. 
*/
void LWSurfaceBlok::readTextureMap( ID4 parent ){
	ID4  subchunk;
	U2   length;

	while( f->domainLeft() > 0 ){

		subchunk = f->read_ID4();
		length   = f->read_U2();

		lwo_debug_msg(
			"LWO2::SURF::BLOK::%s::TMAP::%s (%d bytes)",
			did( parent   ),
			did( subchunk ),
			length
		);

		f->pushDomain( length );
		switch( subchunk ){
		case ID_CNTR: readTextureCenter_VEC12_VX            (); break;
		case ID_SIZE: readTextureSize_VEC12_VX              (); break;
		case ID_ROTA: readTextureRotation_VEC12_VX          (); break;
		case ID_OREF: readTextureReferenceObject_S0         (); break;
		case ID_FALL: readTextureFalloff_U2_VEC12_VX        (); break;
		case ID_CSYS: readTextureCoordinateSystem_U2        (); break;

		//  New blok state?
		default: 
			lwo_debug_msg( "Unknown TMAP::%s", did(subchunk) );
			break;
		}
		f->popDomain( true );
	}
}


/*!  LWO2::BLOK Header Channel 

	CHAN { texture-channel[ID4] } 

	This is required in all texture layer blocks and can have a
	value of COLR, DIFF, LUMI, SPEC, GLOS, REFL, TRAN, RIND, TRNL,
	or BUMP, The texture layer is applied to the corresponding
	surface attribute. If present in a shader block, this value
	is ignored. 
*/
void LWSurfaceBlok::readChannel_ID4(){
	texture_channel = f->read_ID4();
}


/*!  LWO2::BLOK Header Enable State 

	ENAB { enable[U2] } 

	True if the texture layer or shader should be evaluated during
	rendering. If ENAB is missing, the block is assumed to be enabled. 
*/
void LWSurfaceBlok::readEnable_U2(){
	enable = f->read_U2();
}


/*!  LWO2::BLOK Header Opacity 

	OPAC { type[U2], opacity[FP4], envelope[VX] } 

	Opacity is valid only for texture layers. It specifies how opaque
	the layer is with respect to the layers before it (beneath it) on
	the same channel, or how the layer is combined with the previous
	layers. The types can be 

	0 - Additive
	1 - Subtractive
	2 - Difference
	3 - Multiply
	4 - Divide
	5 - Alpha
	6 - Texture Displacement

	Alpha opacity uses the current layer as an alpha channel. The
	previous layers are visible where the current layer is white
	and transparent where the current layer is black. Texture
	Displacement distorts the underlying layers. If OPAC is
	missing, 100% Additive opacity is assumed. 
*/
void LWSurfaceBlok::readOpacity_U2_FP4_VX(){
	opacity_type     = f->read_U2 ();
	opacity          = f->read_FP4();
	opacity_envelope = f->read_VX ();  //  FIX envelope
}


/*!  LWO2::BLOK Header Displacement Axis

	AXIS { displacement-axis[U2] } 

	For displacement mapping, defines the plane from which
	displacements will occur. The value is 0, 1 or 2 for
	the X, Y or Z axis. 
*/
void LWSurfaceBlok::readDisplacementAxis_U2(){
	displacement_axis = f->read_U2();
}


/*!  LWO2::BLOK::TMAP Position, Orientation and Size 

	CNTR, SIZE, ROTA { vector[VEC12], envelope[VX] } 

	These subchunks each consist of a vector for the texture's
	size, center and rotation. The size and center are normal
	positional vectors in meters, and the rotation is a vector
	of heading, pitch and bank in radians. If missing, the
	center and rotation are assumed to be zero. The size should
	always be specified if it si to be used for any given mapping. 
*/
void LWSurfaceBlok::readTextureCenter_VEC12_VX(){
	texture_center          = f->read_VEC12();
	texture_center_envelope = f->read_VX   ();  //  FIX envelope
}


void LWSurfaceBlok::readTextureSize_VEC12_VX(){
	texture_size          = f->read_VEC12();
	texture_size_envelope = f->read_VX   ();  //  FIX envelope
}

void LWSurfaceBlok::readTextureRotation_VEC12_VX(){
	texture_rotation          = f->read_VEC12();
	texture_rotation_envelope = f->read_VX   ();  //  FIX envelope
}


/*!  LWO2::BLOK::TMAP Reference Object 

	OREF { object-name[S0] } 

	Specifies a reference object for the texture. The reference
	object is given by name, and the scene position, rotation
	and scale of the object are combined with the previous
	chunks to compute the texture mapping. If the object name
	is "(none)" or OREF is missing, no reference object is used.
*/
void LWSurfaceBlok::readTextureReferenceObject_S0(){
	texture_reference_object = f->read_S0();
}


/*!  LWO2::BLOK::TMAP Falloff 

	FALL { type[U2], vector[VEC12], envelope[VX] } 

	Texture effects may fall off with distance from the texture
	center if this subchunk is present. The vector represents a
	rate per unit distance along each axis. The type can be

	0 - Cubic;     Falloff is linear along all three axes independently. 
	1 - Spherical; Falloff is proportional to the Euclidean distance from the center. 
	2 - Linear X
	3 - Linear Y
	4 - Linear Z 

	Falloff is linear only along the specified axis. The other
	two vector components are ignored. 
*/
void LWSurfaceBlok::readTextureFalloff_U2_VEC12_VX(){
	texture_falloff_type     = f->read_U2   ();
	texture_falloff          = f->read_VEC12();
	texture_falloff_envelope = f->read_VX   ();  //  FIX envelope
}


/*!  LWO2::BLOK::TMAP Coordinate System 

	CSYS { type[U2] } 

	The coordinate system can be 0 for object coordinates
	(the default if the chunk is missing) or 1 for world
	coordinates. 
*/
void LWSurfaceBlok::readTextureCoordinateSystem_U2(){
	texture_coordinate_system = f->read_U2();
}


/*!  LWO2::BLOK::IMAP Projection Mode 

	PROJ { projection-mode[U2] } 

	The projection defines how 2D coordinates in the image are
	transformed into 3D coordinates in the scene. In the following
	list of projections, image coordinates are called r (horizontal)
	and s (vertical).

	0 - Planar 

	The image is projected on a plane along the major axis
	(specified in the AXIS subchunk). r and s map to the
	other two axes. 

	1 - Cylindrical 

	The image is wrapped cylindrically around the major axis.
	r maps to longitude (angle around the major axis). 

	2 - Spherical 

	The image is wrapped spherically around the major axis.
	r and s map to longitude and latitude. 

	3 - Cubic 

	Like Planar, but projected along all three axes. The dominant
	axis of the geometric normal selects the projection axis for
	a given surface spot. 

	4 - Front Projection 

	The image is projected on the current camera's viewplane.
	r and s map to points on the viewplane. 

	5 - UV 

	r and s map to points (u, v) defined for the geometry using a
	vertex map (identified in the BLOK's VMAP subchunk). 
*/
void LWSurfaceBlok::readTextureProjectionMode_U2(){
	texture_projection_mode = f->read_U2();
}


/*!  LWO2::BLOK::IMAP Major Axis 

	AXIS { texture-axis[U2] } 

	The major axis used for planar, cylindrical and spherical
	projections. The value is 0, 1 or 2 for the X, Y or Z axis. 
*/
void LWSurfaceBlok::readTextureMajorAxis_U2(){
	texture_major_axis = f->read_U2();
}


/*!  LWO2::BLOK::IMAP Image Map 

	IMAG { texture-image[VX] } 

	The CLIP index of the mapped image. 
*/
void LWSurfaceBlok::readTextureImageMap_VX(){
	texture_image_map = f->read_VX();
}


/*!  LWO2::BLOK::IMAP Image Wrap Options 

	WRAP { width-wrap[U2], height-wrap[U2] } 

	Specifies how the color of the texture is derived for
	areas outside the image.

	0 - Reset 

	Areas outside the image are assumed to be black. The ultimate
	effect of this depends on the opacity settings. For an additive
	texture layer on the color channel, the final color will come
	from the preceding layers or from the base color of the surface. 

	1 - Repeat (default)

	The image is repeated or tiled. 

	2 - Mirror 

	Like repeat, but alternate tiles are mirror-reversed. 

	3 - Edge 

	The color is taken from the image's nearest edge pixel. 
*/
void LWSurfaceBlok::readTextureWrapOptions_U2_U2(){
	texture_width_wrap  = f->read_U2();
	texture_height_wrap = f->read_U2();
}


/*!  LWO2::BLOK::IMAP Image Wrap Amount 

	WRPW, WRPH { cycles[FP4], envelope[VX] } 

	For cylindrical and spherical projections, these parameters
	control how many times the image repeats over each full interval. 
*/
void LWSurfaceBlok::readTextureWrapWidthAmount_FP4_VX(){
	texture_wrap_width_cycles          = f->read_FP4();
	texture_wrap_width_cycles_envelope = f->read_VX ();  //  FIX envelope
}


void LWSurfaceBlok::readTextureWrapHeightAmount_FP4_VX(){
	texture_wrap_height_cycles          = f->read_FP4();
	texture_wrap_height_cycles_envelope = f->read_VX ();  //  FIX envelope
}


/*!  LWO2::BLOK::IMAP UV Vertex Map 

	VMAP { txuv-map-name[S0] } 

	For UV projection, which depends on texture coordinates at
	each vertex, this selects the name of the TXUV vertex map
	that contains those coordinates. 
*/
void LWSurfaceBlok::readTextureUV_VertexMap_S0(){
	texture_uv_vertex_map = f->read_S0();
}


/*!  LWO2::BLOK::IMAP Antialiasing Strength 

	AAST { flags[U2], antialising-strength[FP4] } 

	The low bit of the flags word is an enable flag for texture
	antialiasing. The antialiasing strength is proportional to
	the width of the sample filter, so larger values sample a
	larger area of the image.
*/
void LWSurfaceBlok::readTextureAntialiasingStrength_U2_FP4(){
	texture_antialiasing_type     = f->read_U2 ();
	texture_antialiasing_strength = f->read_FP4();
}


/*!  LWO2::BLOK::IMAP Pixel Blending 

	PIXB { flags[U2] } 

	Pixel blending enlarges the sample filter when it would
	otherwise be smaller than a single image map pixel. If
	the low-order flag bit is set, then pixel blending is
	enabled.
*/
void LWSurfaceBlok::readTexturePixelBlending_U2(){
	texture_pixel_blending = f->read_U2();
}


/*!  LWO2::BLOK::IMAP Stack

	STCK { value[FP4], envelope[VX] } 

	Reserved for future use. The default value is 0.0.
*/
void LWSurfaceBlok::readTextureStack_VX(){
	texture_stack = f->read_VX();  //  FIX envelope
}


/* !  LWO2::BLOK::IMAP Texture Amplitude 

	TAMP { amplitude[FP4], envelope[VX] } 

	Appears in image texture layers applied to the bump channel.
	Texture amplitude scales the bump height derived from the
	pixel values. The default is 1.0.
*/
void LWSurfaceBlok::readTextureAmplitude_FP4_VX(){
	texture_amplitude          = f->read_FP4();
	texture_amplitude_envelope = f->read_VX ();  //  FIX envelope
}


void LWSurfaceBlok::readTextureNegative_U2(){
	texture_negative = f->read_U2();
}


/*!  LWO2::BLOK::PROC Axis 

	AXIS { axis[U2] } 

	If the procedural has an axis, it may be defined with
	this chunk using a value of 0, 1 or 2. 
*/
void LWSurfaceBlok::readProceduralAxis_U2(){
	procedural_axis = f->read_U2();
}

/*!  LWO2::BLOK::PROC Basic Value 

	VALU { value[FP4] # (1, 3) } 

	Procedurals are often modulations between the current
	channel value and another value, given here. This may
	be a scalar or a vector. 
*/
void LWSurfaceBlok::readProceduralBasicValue_FP4_1_or_3(){
	lwo_debug_msg( "# (1, 3)" );
}


/*!  LWO2::BLOK::PROC Algorithm and Parameters 

	FUNC { algorithm-name[S0], data[...] } 

	The FUNC subchunk names the procedural and stores its
	parameters. The name will often map to a plug-in name.
	The variable-length data following the name belongs to
	the procedural.
*/
void LWSurfaceBlok::readProceduralAlgorithm_S0_data(){
	procedural_algorithm = f->read_S0();
	lwo_debug_msg( "data[...]" );
}


/*!  LWO2::BLOK::GRAD Parameter Name 

	PNAM { parameter[S0] } 

	The input parameter. Possible values include

	"Previous Layer"
	"Bump"
	"Slope"
	"Incidence Angle"
	"Light Incidence"
	"Distance to Camera"
	"Distance to Object"
	"X Distance to Object"
	"Y Distance to Object"
	"Z Distance to Object"
	"Weight Map"
*/
void LWSurfaceBlok::readGradientParameter_S0(){
	gradient_parameter = f->read_S0();
}


/*!  LWO2::BLOK::GRAD Item Name 

	INAM { item-name[S0] } 

	The name of a scene item. This is used when the input
	parameter is derived from a property of an item in the
	scene.
*/
void LWSurfaceBlok::readGradientItem_S0(){
	gradient_item = f->read_S0();
}


/*!  LWO2::BLOK::GRAD Gradient Range

	GRST, GREN { input-range[FP4] }

	The start and end of the input range. These values only
	affect the display of the gradient in the user interface.
	They don't affect rendering.
*/
void LWSurfaceBlok::readGradientRangeStart_FP4(){
	gradient_range_start = f->read_FP4();
}

void LWSurfaceBlok::readGradientRangeEnd_FP4(){
	gradient_range_end = f->read_FP4();
}


/*!  LWO2::BLOK::GRAD Repeat Mode 

	GRPT { repeat-mode[U2] } 

	The repeat mode. This is currently undefined.
*/
void LWSurfaceBlok::readGradientRepeat_U2(){
	gradient_repeat = f->read_U2();
}


/*!  LWO2::BLOK::GRAD Key Values 

	FKEY { ( input[FP4], output[FP4] # 4 )* } 

	The transfer function is defined by an array of keys,
	each with an input value and an RGBA output vector.
	Given an input value, the gradient can be evaluated
	by selecting the keys whose positions bracket the
	value and interpolating between their outputs. If the
	input value is lower than the first key or higher than
	the last key, the gradient value is the value of the
	closest key.
*/
void LWSurfaceBlok::readGradientKeys_FP4_data_FP4(){
	lwo_debug_msg( "FKEY { ( input[FP4], output[FP4] # 4 )* }" );
}


/*!  LWO2::BLOK::GRAD Key Parameters 

	IKEY { interpolation[U2] * } 

	An array of integers defining the interpolation for the
	span preceding each key. Possible values include

	0 - Linear
	1 - Spline
	2 - Step
*/
void LWSurfaceBlok::readGradientKeyParameters_data_U2(){
	lwo_debug_msg( "IKEY { interpolation[U2] * }" );
}


/*!  LWO2::BLOK::SHDR Shader Algorithm 

	FUNC { algorithm-name[S0], data[...] } 

	Just like a procedural texture layer, a shader
	is defined by an algorithm name (often a plug-in),
	followed by data owned by the shader.
*/
void LWSurfaceBlok::readShaderAlgorithm_S0_data(){
	shader_algorithm = f->read_S0();
	lwo_debug_msg( "FUNC { algorithm-name[S0], data[...] }" );
}


};  //  namespace Imports

