
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
	\class   LWFile
	\ingroup g_application
	\author  Timo Suoranta
	\brief   Parses lightwave types from file
	\date    2000, 2001

	Parses lightwave types from file stream.
	Chunks have length guardian, such that attempting
	to read past chunk should not mess up.
*/


#ifndef TEDDY_APPLICATION_FRONTIER_FILE_H
#define TEDDY_APPLICATION_FRONTIER_FILE_H


#include "SysSupport/Types.h"
	

namespace Application {


#define FF_UNKNOWN   0
#define FF_LABEL_DEF 1
#define FF_LABEL_REF 2
#define FF_BYTE	     3
#define FF_STRING    4


class FrontierFile {
public:
	FrontierFile( const char *fname, Uint32 options );

	void    seek         ( const char *label_index );
	void    seek         ( const Sint32 bytes );
	void    reset        ();
	void    skip_white   ();
	int     get_type     ();
	Uint8   get_byte     ();
	Uint8   get_byte_low ( bool gt = true );
	char   *get_label_def();
	char   *get_label_ref();
	char   *get_string   ();
	Sint8   read_Sint8   ();
	Sint16  read_Sint16  ();
	Sint32  read_Sint32  ();
	Uint8   read_Uint8   ();
	Uint16  read_Uint16  ();
	Uint32  read_Uint32  ();
	float   read_float   ();
	char   *read_string  ();

protected:
	char *buf;  //!<  Buffer
	char *pos;  //!<  Current pointer
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_FRONTIER_FILE_H

