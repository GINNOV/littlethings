
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
	\class   DebugStream
	\ingroup g_application
	\author  Timo Suoranta
	\date    2001

	This module builds upon two existing facilities, C++ streams and the 
	Windows EDIT class. The point is not to come up with the most efficient 
	implementation but to show how far one can get while being as lazy as 
	possible. 

	The DebugStream class is derived from ostream and hence gives the user the 
	same << facilities of regular streams, including manipulators such as setw, 
	endl, and, yes, setformat. It constructs a buffer of type DebugStreamBuffer 
	whose address is passed to the ostream constructor.
*/


#ifndef TEDDY_APPLICATION_CONSOLE_STREAM_H
#define TEDDY_APPLICATION_CONSOLE_STREAM_H


#include "glElite/ConsoleStreamBuffer.h"
#include "glElite/Console.h"

#if defined(_MSC_VER)
# include <ostream>
#else  //  gcc
# include <ostream.h>
#endif

using namespace std;


namespace Application {


class ConsoleStream : public ostream {
public:
	ConsoleStream() : ostream( csb = new ConsoleStreamBuffer() ), ios( 0 ){}

	void setCon( Console *con ){
        csb->setCon( con );
	}
protected:
    ConsoleStreamBuffer *csb;
};


};  //  namespace Application


#endif  //  TEDDY_APPLICATION_CONSOLE_STREAM_H


