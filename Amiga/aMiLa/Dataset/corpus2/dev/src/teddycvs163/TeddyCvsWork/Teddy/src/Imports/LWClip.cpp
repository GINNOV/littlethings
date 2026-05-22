
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


#include "Imports/LWClip.h"
#include "Imports/LWFile.h"


namespace Imports {


LWClip::LWClip( LWFile *f ){
	this->f = f;
	still_image                     = NULL;
	image_sequence_num_digits       = 0;
	image_sequence_flags            = 0;
	image_sequence_offset           = 0;
	image_sequence_loop_length      = 0;
	image_sequence_prefix           = NULL;
	image_sequence_suffix           = NULL;
	plugin_animation_filename       = NULL;
	plugin_animation_server_name    = NULL;
	plugin_animation_flags          = 0;
	color_cycling_still_image_lo    = 0;
	color_cycling_still_image_hi    = 0;
	color_cycling_still_image_name  = NULL;
	contrast_modifier               = 0;
	contrast_modifier_envelope      = 0;
	brightness_modifier             = 0;
	brightness_modifier_envelope    = 0;
	saturation_modifier             = 0;
	saturation_modifier_envelope    = 0;
	hue_modifier                    = 0;
	hue_modifier_envelope           = 0;
	gamma_modifier                  = 0;
	gamma_modifier_envelope         = 0;
	negative_modifier               = 0;
	plugin_image_filter_server_name = NULL;
	plugin_image_filter_flags       = 0;
	plugin_pixel_filter_server_name = NULL;
	plugin_pixel_filter_flags       = 0;
}


void LWClip::processClip(){
	clip_type   = f->read_ID4();
	clip_length = f->read_U2();
	f->pushDomain( clip_length );

	lwo_debug_msg(
		"%s::CLIP::%s (%d bytes)",
		did( f->getType() ),
		did( clip_type ),
		clip_length
	);

	switch( clip_type ){					 
		case ID_STIL: readStillImage_FNAM0                  (); break;
		case ID_ISEQ: readImageSequence_U1_U1_I2_I2_FNAM0_S0(); break;
		case ID_ANIM: readAnimation_FNAM0_S0_U2_d           (); break;
		case ID_STCC: readStillColorCycle_I2_I2_FNAM0       (); break;
		case ID_CONT: readContrast_FP4_VX                   (); break;
		case ID_BRIT: readBrightness_FP4_VX                 (); break;
		case ID_SATR: readSaturation_FP4_VX                 (); break;
		case ID_HUE:  readHue_FP4_VX                        (); break;
		case ID_GAMM: readGamma_F4_VX                       (); break;
		case ID_NEGA: readNegative_U2                       (); break;
		case ID_IFLT: readImageFilter_S0_U2_d               (); break;
		case ID_PFLT: readPixelFilter_S0_U2_d               (); break;
	}
	f->popDomain( true );
}


/*!
	Still Image 

	STIL { name[FNAM0] } 

	This source chunk describes a single still image. The image is
	referenced by a filename in neutral path format. 
*/
void LWClip::readStillImage_FNAM0(){
	still_image = f->read_FNAM0();
}


/*!  LWO2::CLIP  Image Sequence 

	ISEQ { num-digits[U1],  flags[U1],     offset[I2],
	       loop-length[I2], prefix[FNAM0], suffix[S0] } 

	This source chuck describes an image sequence, which is basically a filename
	with a number in the middle. The number of digits is the number of zeros used
	to encode the sequence number in the filename. The flags has bits for looping
	and interlace. Offset and loop-length define the frames in the sequence. The
	prefix and suffix are stuck before and after the frame number to make the
	filename for each frame, which is in neutral path format. 
*/
void LWClip::readImageSequence_U1_U1_I2_I2_FNAM0_S0(){
	image_sequence_num_digits  = f->read_U1();
	image_sequence_flags       = f->read_U1();
	image_sequence_offset      = f->read_I2();
	image_sequence_loop_length = f->read_I2();
	image_sequence_prefix      = f->read_FNAM0();
	image_sequence_suffix      = f->read_S0();
}


/*!  LWO2::CLIP  Plug-in Animation 

	ANIM { filename[FNAM0], server-name[S0], flags[U2], data[...] } 

	This chunk indicates that the source imagery comes from a plug-in animation
	loader. The loader is defined by the server name and its data which just
	follows as binary bytes.
*/
void LWClip::readAnimation_FNAM0_S0_U2_d(){
	plugin_animation_filename    = f->read_FNAM0();
	plugin_animation_server_name = f->read_S0();
	plugin_animation_flags       = f->read_U2();

	while( f->domainLeft() > 0 ){
		U1 data = f->read_U1();
		//  FIX send data to plugin
	}
}


/*!  LWO2::CLIP	Color-cycling Still 

	STCC { lo[I2], hi[I2], name[FNAM0] } 

	A still image with color-cycling is a source defined by a neutral-format
	name and cycling parameters. If lo is less than hi, the colors cycle
	forward, and if hi is less than lo, they go backwards. 
*/
void LWClip::readStillColorCycle_I2_I2_FNAM0(){
	color_cycling_still_image_lo   = f->read_I2();
	color_cycling_still_image_hi   = f->read_I2();
	color_cycling_still_image_name = f->read_FNAM0();
}


/*!  LWO2::CLIP Contrast 

	CONT { contrast-delta[FP4], envelope[VX] } 

	This modifier alters the contrast of the image up or down
	by the given percentage. 
*/
void LWClip::readContrast_FP4_VX(){
	contrast_modifier          = f->read_FP4();
	contrast_modifier_envelope = f->read_VX();
}


/*!  LWO2::CLIP Brightness 

	BRIT { brightness-delta[FP4], envelope[VX] } 

	This modifier alters the brightness of the image up or down
	by the given percentage. 
*/
void LWClip::readBrightness_FP4_VX(){
	brightness_modifier          = f->read_FP4();
	brightness_modifier_envelope = f->read_VX();
}


/*!  LWO2::CLIP Saturation 

	SATR { saturation-delta[FP4], envelope[VX] } 

	This modifier alters the saturation of the image up or down
	by the given percentage. 
*/
void LWClip::readSaturation_FP4_VX(){
	saturation_modifier          = f->read_FP4();
	saturation_modifier_envelope = f->read_VX();
}


/*!  LWO2::CLIP Hue 

	HUE { hue-rotation[FP4], envelope[VX] } 

	This modifier rotates the hue of the image
	360 degrees for 100% of hue rotation. 
*/
void LWClip::readHue_FP4_VX(){
	FP4 hue_modifier          = f->read_FP4();
	VX  hue_modifier_envelope = f->read_VX();
}


/*!  LWO2::CLIP Gamma Correction 

	GAMM { gamma[F4], envelope[VX] } 

	This modifier applies the given gamma to the image,
	where a value of 1.0 is no change. 
*/
void LWClip::readGamma_F4_VX(){
	gamma_modifier          = f->read_F4();
	gamma_modifier_envelope = f->read_VX();
}


/*!  LWO2::CLIP	Negative 

	NEGA { enable[U2] } 

	If the value is true, this modifier performs a negation of the image.
*/
void LWClip::readNegative_U2(){
	U2 negative_modifier = f->read_U2();
}


/*!  LWO2::CLIP Plug-in Image Filters 

	IFLT { server-name[S0], flags[U2], data[...] } 

	Plug-in image filters can be used to pre-filter an image
	before rendering. The filter has to be able to exist outside
	of the special environment of rendering in order to work here.
	Filters are given by a server name, an enable flag, and plug-in
	server data as raw bytes. 
*/
void LWClip::readImageFilter_S0_U2_d(){
	plugin_image_filter_server_name = f->read_S0();
	plugin_image_filter_flags       = f->read_U2();

	if( (plugin_image_filter_flags & 1 ) == 1 ){  //  enable flag set?
		while( f->domainLeft() > 0 ){
			U1 data = f->read_U1();
			//  FIX send data to plugin
		}
	}
}


/*!  LWO2::CLIP Plug-in Pixel Filters 

	PFLT { server-name[S0], flags[U2], data[...] } 

	Pixel filters may also be used as clip modifiers, and they are
	stored and used in a way that is exactly like image filters above.
*/
void LWClip::readPixelFilter_S0_U2_d(){
	S0 plugin_pixel_filter_server_name = f->read_S0();
	U2 plugin_pixel_filter_flags       = f->read_U2();

	if( (plugin_pixel_filter_flags & 1 ) == 1 ){  //  enable flag set?
		while( f->domainLeft() > 0 ){
			U1 data = f->read_U1();
			//  FIX send data to plugin
		}
	}
}


};  //  namespace Imports

