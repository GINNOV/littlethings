
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

/*!
	\class	 LWEnvelope
	\ingroup g_imports
	\author  Timo Suoranta
	\brief	 Parser for LightWave object file envelope subchunks
	\warning Envelopes are not actually used at all yet.
	\date	 2000

	Only for Lighwave files from version 6.0 and up
*/


#ifndef TEDDY_IMPORTS_LW_ENVELOPE_H
#define TEDDY_IMPORTS_LW_ENVELOPE_H


#include "Imports/lwdef.h"
#include "SysSupport/StdList.h"


namespace Imports {


class LWFile;
class LWEnvelopeKey;


class LWEnvelope {
public:
	LWEnvelope( LWFile *f );

	void processEnvelope();

protected:
	void readPreBehaviour_U2	();
	void readPostBehaviour_U2	();
	void readKeyframe_F4_F4 	();
	void readInterpolation_ID4_d();
	void readChannel_S0_U2_d	();
	void readName_S0			();

	char                 *name;
	U2					  pre_behaviour;
	U2					  post_behaviour;
	list<LWEnvelopeKey*>  keys;
	LWEnvelopeKey		 *last_key;

	LWFile *f;
	ID4 	envelope_type;
	U4		envelope_length;
};


};	//	namespace Imports


#endif	//	TEDDY_IMPORTS_LW_ENVELOPE_H

