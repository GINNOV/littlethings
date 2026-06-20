
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


#include "Imports/LWEnvelope.h"
#include "Imports/LWEnvelopeKey.h"
#include "Imports/LWFile.h"
#include <cstdio>


namespace Imports {


LWEnvelope::LWEnvelope( LWFile *f ){
	this->f  = f;
	last_key = NULL;
}


void LWEnvelope::processEnvelope(){
	envelope_type	= f->read_ID4();
	envelope_length = f->read_U2();
	f->pushDomain( envelope_length );
	switch( envelope_type ){
		case ID_PRE:  readPreBehaviour_U2(); break;
		case ID_POST: readPostBehaviour_U2(); break;
		case ID_KEY:  readKeyframe_F4_F4(); break;
		case ID_SPAN: readInterpolation_ID4_d(); break;
		case ID_CHAN: readChannel_S0_U2_d(); break;
		case ID_NAME: readName_S0(); break;
		default: break;
	}
	f->popDomain( true );
}


/*!
	Pre-Behavior 

	PRE { type[U2] } 

	The pre-behavior for an envelope defines the signal value for times before
	the first key. The integer code selects one of several predefined behaviors,
	starting from zero: Reset, Constant, Repeat, Ocsillate, Offset Repeat, Linear. 
*/
void LWEnvelope::readPreBehaviour_U2(){
	pre_behaviour = f->read_U2();
}


/*!
	Post-Behavior 

	POST { type[U2] } 

	The post-behavior determines the signal value for times after the last key.
	The type codes are the same as for pre-behaviors. 
*/
void LWEnvelope::readPostBehaviour_U2(){
	post_behaviour = f->read_U2();
}


void LWEnvelope::readKeyframe_F4_F4(){
	F4 keyframe_time  = f->read_F4();
	F4 keyframe_value = f->read_F4();
	LWEnvelopeKey *key = last_key = new LWEnvelopeKey( keyframe_time, keyframe_value );
	keys.push_back( key );
}


/*!
	Interval Interpolation 

	SPAN { type[ID4], value[F4] * } 

	This sub-chunk defines the interpolation between the most recently
	specified KEY chunk and the keyframe immediately before it in time.
	The type ID code defines the interpolation algorithm and can be
	STEP, LINE, TCB, HERM or BEZI. The variable number of parameters
		values that follow define the particulars of the interpolation. 
*/
void LWEnvelope::readInterpolation_ID4_d(){
	if( last_key == NULL ){
		printf( "Envelope key missing for interval interpolation\n" );
		return;
	}
	//	FIX
}


/*!
	Plug-in Channel Operators 

	CHAN { server-name[S0], flags[U2], data[...] } 

	Channel filters can be layered on top of a basic keyframed envelope to provide
	some more elaborate effects. Each channel chunk contains the name of the plug-in
	server and some flags bits. Only the first flag bit is defined, which if set
	indicates that the filter is disabled. The plug-in data follows as raw bytes. 
*/
void LWEnvelope::readChannel_S0_U2_d(){
	char *server_name = f->read_S0();
	U2    flags       = f->read_U2();

	if( (flags & 1) == 1 ){
		//	Channel filter plugin disabled
		return;
	}

	while( f->domainLeft() > 0 ){
		//	FIX send bytes to plugin server
	}
}


/*!
	Channel Name 

	NAME { channel-name[S0] } 

	This is an optional envelope sub-chunk which is not used by LightWave
	in any way. It is only provided to allow external programs to browse
	through the envelopes available in an object fille.
*/
void LWEnvelope::readName_S0(){
	name = f->read_S0();
}


};	//	namespace Imports

