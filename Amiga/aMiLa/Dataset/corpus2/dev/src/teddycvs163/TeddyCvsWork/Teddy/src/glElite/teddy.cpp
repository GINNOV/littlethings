
/*	$Id: teddy.cpp,v 1.1 2001/11/21 13:37:38 tksuoran Exp $  */

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


int main_cpp( int argc, char **argv );

extern "C" {
	int SDL_main( int argc, char **argv ){
		main_cpp( argc, argv );
		return 0;
	}
}

#define WIN_CONSOLE 1
#define NOMINMAX


#ifdef WIN32						  //  This here and the other part
# ifdef WIN_CONSOLE
#  include <windows.h> 				 //  below are needed in Win32
#  include <io.h>						 //  environment to open a console
#  include <fcntl.h>					 //  for standard input and output.
# endif
#endif

#include "ui.h"
using namespace Application;


int main_cpp( int argc, char **argv ){

#if defined(WIN_CONSOLE) && defined(_MSC_VER)
	int hCrt;
	FILE *hf;

	AllocConsole();
	hCrt = _open_osfhandle(
		(long) GetStdHandle(STD_OUTPUT_HANDLE),
		_O_TEXT
	);
	hf = _fdopen( hCrt, "w" );
	*stdout = *hf;
	setvbuf( stdout, NULL, _IONBF, 0 );

//	printf( "Teddy debug console\n" );
#endif

	new UI( argc, argv );
	return 0 ;
}


