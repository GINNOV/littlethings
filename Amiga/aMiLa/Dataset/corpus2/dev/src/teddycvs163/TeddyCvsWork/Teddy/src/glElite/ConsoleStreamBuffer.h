
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
	\class   DebugStreamBuffer
	\ingroup g_application
	\author  Timo Suoranta
	\date    2001

	The DebugStreamBuffer class is derived from filebuf to achieve file logging 
	for free. It turns out that only the virtual sync() function needs to
	be overloaded to copy the buffered text before it is sent to the file.
	(Alternatively, if no file logging was desired, one could turn off 
	buffering and override the virtual overflow() function.) 
*/


#ifndef TEDDY_APPLICATION_CONSOLE_STREAM_BUFFER_H
#define TEDDY_APPLICATION_CONSOLE_STREAM_BUFFER_H


#include "glElite/Console.h"
#if defined(_MSC_VER)
# include <ostream>
#else  //  gcc
# include <ostream.h>
#endif
using namespace std;


namespace Application {


class ConsoleStreamBuffer : public streambuf {
public:
	ConsoleStreamBuffer(){
		this->_con = NULL;
	}

	void        setCon  ( Console *con ){
        this->_con = con;
	}
	virtual int overflow( int c );

private:
	Console *_con;
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_CONSOLE_STREAM_BUFFER_H

