
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
	\file
	\class   EndianOut
	\ingroup g_sys_support
	\author  Timo Suoranta
	\brief   Endian sensitive byte, short and float writing
	\date    1999, 2000, 2001

	A very very poor implementation for endian independent access
	to endian sensitive data,
*/


#ifndef TEDDY_SYS_SUPPORT_ENDIAN_OUT_H
#define TEDDY_SYS_SUPPORT_ENDIAN_OUT_H


#include "SysSupport/EndianIO.h"
#include "SysSupport/Exception.h"


namespace SysSupport {


class EndianOut : public EndianIO {
	ofstream *ofs;

public:
	EndianOut ( const char *file_name );
	~EndianOut();

	void open        ( const char *name );
	void close       ();
	void write_byte  ( const int            item );
	void write_short ( const unsigned short item );
	void write_long  ( const unsigned long  item );
	void write_float ( const float          item );
};


};  //  namespace SysSupport


#endif  //  TEDDY_SYS_SUPPORT_ENDIAN_OUT_H

