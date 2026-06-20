
/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000  Timo Suoranta

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Timo Suoranta
    tksuoran@cc.helsinki.fi
*/


#ifndef TEDDY_FIX_endian_io_h
#define TEDDY_FIX_endian_io_h


#include <fstream>
using namespace std;


/*!
	\class   EndianIO
	\ingroup g_syssupport
	\author  Timo Suoranta
	\brief   Baseclass for endian sensitive file reading and writing
	\date    1999, 2000

	A very very poor implementation for endian independent access
	to endian sensitive data,
*/
class EndianIO {
	enum { MSBfirst, LSBfirst } byte_order;

public:
	EndianIO();

	void set_bigendian   ();
	void set_littlendian ();
	bool q_MSBfirst      () const;
};


/*!
	\class   EndianIn
	\ingroup g_syssupport
	\author  Timo Suoranta
	\brief   Endian sensitive byte, short and float reading
	\date    1999, 2000

	A very very poor implementation for endian independent access
	to endian sensitive data,
*/
class EndianIn : public EndianIO {
	ifstream *ifs;

public:
	EndianIn ();
	EndianIn ( const char * file_name );
	~EndianIn();

	void           open ( const char *file_name );
	void           close();
	int            len();
	unsigned char  read_byte();
	unsigned short read_short();
	unsigned long  read_long();
	float          read_float();
};


/*!
	\class   EndianOut
	\ingroup g_syssupport
	\author  Timo Suoranta
	\brief   Endian sensitive byte, short and float writing
	\date    1999, 2000

	A very very poor implementation for endian independent access
	to endian sensitive data,
*/
class EndianOut : public EndianIO {
	ofstream *ofs;

public:
	EndianOut ();
	EndianOut ( const char *file_name );
	~EndianOut();

	void open        ( const char *name );
	void close       ();
	void write_byte  ( const int            item );
	void write_short ( const unsigned short item );
	void write_long  ( const unsigned long  item );
	void write_float ( const float          item );
};


#endif  //  TEDDY_FIX_endian_io_h

