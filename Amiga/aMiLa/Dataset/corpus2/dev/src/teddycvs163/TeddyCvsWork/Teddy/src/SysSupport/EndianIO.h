
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
	\class   EndianIO
	\ingroup g_sys_support
	\author  Timo Suoranta
	\brief   Baseclass for endian sensitive file reading and writing
	\date    1999, 2000, 2001

	A very very poor implementation for endian independent access
	to endian sensitive data,
*/


#ifndef TEDDY_SYS_SUPPORT_ENDIAN_IO_H
#define TEDDY_SYS_SUPPORT_ENDIAN_IO_H


#include <fstream>
using namespace std;


namespace SysSupport {


class EndianIO {
	enum { MSBfirst, LSBfirst } byte_order;

public:
	EndianIO();

	void set_bigendian   ();
	void set_littlendian ();
	bool q_MSBfirst      () const;
};


};  //  namespace SysSupport


#endif  //  TEDDY_SYS_SUPPORT_ENDIAN_IO_H

