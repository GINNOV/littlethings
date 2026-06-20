
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
	\file   main.cpp
	\author Timo Suoranta
	\brief  TestManipulate main
	\date   2001

	This example program is not yet finished.

	Eventually it will let user edit and view
	LSystem objects.

	The syntax for LSystem is similar to one
	used by Larens Lapre's "LParser" program. 
*/


#include "TestManipulate.h"
#include "Graphics/View.h"        //  init_graphics_device()
#include "Materials/Render.h"     //  init_materials      ()
#include "SysSupport/Messages.h"  //  fatal_msg           ()
#include "SDL.h"

/*  Enable to get win32 debug console

#  include <windows.h>
#  include <io.h>
#  include <fcntl.h>
*/


/*!
	This is the program entry point. It initializes Teddy
	and creates the test scene by calling TestObjects constructor.
*/
int main_cpp( int argc, char **argv );


extern "C" {
	int SDL_main( int argc, char **argv ){
		main_cpp( argc, argv );
		return 0;
	}
}


int main_cpp( int argc, char **argv ){

/*  Enable to get win32 debug console

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
*/

	int   screen_x = 640;
	int   screen_y = 480;
	int   flags    = SDL_OPENGL;
	int   x_count  = 10;
	int   z_count  = 10;
	float x_space  = 100.0f;
	float z_space  = 100.0f;

	if( SDL_Init(SDL_INIT_VIDEO|SDL_INIT_TIMER|SDL_INIT_NOPARACHUTE|SDL_INIT_AUDIO) < 0 ){
		fatal_msg( MSG_HEAD "Unable to initialize SDL: %s\n", SDL_GetError() );
	}else{
		atexit( SDL_Quit );
	}

	init_materials      ();
	init_graphics_device();

	TestManipulate *tester = new TestManipulate();

	return 0 ;
}

