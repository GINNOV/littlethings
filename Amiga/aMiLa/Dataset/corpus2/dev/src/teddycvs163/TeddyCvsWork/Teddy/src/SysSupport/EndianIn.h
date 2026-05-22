
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
	\class   EndianIn
	\ingroup g_sys_support
	\author  Timo Suoranta
	\brief   Endian sensitive byte, short and float reading
	\date    1999, 2000, 2001

	A very very poor implementation for endian independent access
	to endian sensitive data,
*/


#ifndef TEDDY_SYS_SUPPORT_ENDIAN_IN_H
#define TEDDY_SYS_SUPPORT_ENDIAN_IN_H


#include "SysSupport/EndianIO.h"


namespace SysSupport {


class EndianIn : public EndianIO {
	ifstream *ifs;

public:
	EndianIn ( const char *file_name = NULL );
	~EndianIn();

	void            open      ( const char *file_name );
	void            close     ();
	unsigned long   len       ();
	unsigned char   read_byte ();
	unsigned short  read_short();
	unsigned long   read_long ();
	float           read_float();
	void            read_all  ( char *buf );  //!< NOT ENDIAN INDEPENDEN
};


};  //  namespace SysSupport


#endif  //  TEDDY_SYS_SUPPORT_ENDIAN_IN_H

