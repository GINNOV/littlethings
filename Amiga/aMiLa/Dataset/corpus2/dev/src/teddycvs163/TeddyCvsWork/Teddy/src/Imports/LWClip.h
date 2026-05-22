
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
	\class   LWClip
	\ingroup g_imports
	\author  Timo Suoranta
	\brief   Parser for LightWave object file envelope subchunks
	\date    2000, 2001

	Only for Lighwave files from version 6.0 and up
*/


#ifndef TEDDY_IMPORTS_LW_CLIP_H
#define TEDDY_IMPORTS_LW_CLIP_H


//#include "Imports/LWFile.h"
#include "Imports/lwdef.h"


namespace Imports {


class LWFile;


class LWClip {
public:
	LWClip( LWFile *f );

	void processClip();

protected:
	void readStillImage_FNAM0                  ();
	void readImageSequence_U1_U1_I2_I2_FNAM0_S0();
	void readAnimation_FNAM0_S0_U2_d           ();
	void readStillColorCycle_I2_I2_FNAM0       ();
	void readContrast_FP4_VX                   ();
	void readBrightness_FP4_VX                 ();
	void readSaturation_FP4_VX                 ();
	void readHue_FP4_VX                        ();
	void readGamma_F4_VX                       ();
	void readNegative_U2                       ();
	void readImageFilter_S0_U2_d               ();
	void readPixelFilter_S0_U2_d               ();

	LWFile *f;
	ID4     clip_type;
	U4      clip_length;

//  These are public for easy access from LWSurfaceBlok
public:
	FNAM0   still_image;                      //!<  STIL
	U1      image_sequence_num_digits;        //!<  ISEQ
	U1      image_sequence_flags;             //!<  ISEQ
	I2      image_sequence_offset;            //!<  ISEQ
	I2      image_sequence_loop_length;       //!<  ISEQ
	FNAM0   image_sequence_prefix;            //!<  ISEQ
	S0      image_sequence_suffix;            //!<  ISEQ
	FNAM0   plugin_animation_filename;        //!<  ANIM
	S0      plugin_animation_server_name;     //!<  ANIM
	U2      plugin_animation_flags;           //!<  ANIM
	I2      color_cycling_still_image_lo;     //!<  STCC
	I2      color_cycling_still_image_hi;     //!<  STCC
	FNAM0   color_cycling_still_image_name;   //!<  STCC
	FP4     contrast_modifier;                //!<  CONT
	VX      contrast_modifier_envelope;       //!<  CONT
	FP4     brightness_modifier;              //!<  BRIT
	VX      brightness_modifier_envelope;     //!<  BRIT
	FP4     saturation_modifier;              //!<  SATR
	VX      saturation_modifier_envelope;     //!<  SATR
	FP4     hue_modifier;                     //!<  HUE
	VX      hue_modifier_envelope;            //!<  HUE
	F4      gamma_modifier;                   //!<  GAMM
	VX      gamma_modifier_envelope;          //!<  GAMM
	U2      negative_modifier;                //!<  NEGA
	S0      plugin_image_filter_server_name;  //!<  IFLT
	U2      plugin_image_filter_flags;        //!<  IFLT
	S0      plugin_pixel_filter_server_name;  //!<  PFLT
	U2      plugin_pixel_filter_flags;        //!<  PFLT

};


};  //  namespace Imports


#endif  //  TEDDY_IMPORTS_LW_CLIP_H

