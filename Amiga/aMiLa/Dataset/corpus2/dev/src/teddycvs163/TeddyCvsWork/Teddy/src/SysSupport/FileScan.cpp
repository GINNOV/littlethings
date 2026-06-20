
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


#include "SysSupport/FileScan.h"


char *fix_file_name( char *file_name ){
	char *walker = file_name;

	//  Scan for end of string
	while( *walker != 0 ){
		walker++;
	}

	//  Scan to last /, if any
	while( *walker != '/' && *walker != '\\' ){
		walker--;
		if( walker == file_name ){
			break;
		}
	}
	return walker+1;
}


#if defined( WIN32 )  //  PLATFORM SELECTION - WIN32


#include <windows.h>


FileScan::FileScan( const char *mask ){
	WIN32_FIND_DATA fData;
	HANDLE          search;

	search = FindFirstFile( mask, &fData );

	if( search == INVALID_HANDLE_VALUE ){
		return;
	}

	do{
		char *fnam = new char[ strlen(fData.cFileName)+2 ];
		strcpy(fnam, fData.cFileName );
		files.push_back(fnam);
	}while( FindNextFile( search, &fData ) );
}


#elif 1  // PLATFORM SELECTION - ASSUME POSIX

#include <cstdio>
#include <sys/types.h>
#include <errno.h>
#include <glob.h>


// FIXME: this could use some better error handling...

FileScan::FileScan( const char *pattern ) : files() {
	glob_t g;

#	ifdef GLOB_TILDE
	int r = glob( pattern, GLOB_MARK|GLOB_TILDE, NULL, &g );
#	else
	int r = glob( pattern, GLOB_MARK, NULL, &g );
#	endif

	if( r==GLOB_NOMATCH ){
		return;
	}

	if( r!=0 ){
		fprintf(  stderr, "glob(3) failed for \"%s\": %s\n", pattern, strerror(errno)  );
		exit( EXIT_FAILURE );
	}

	for( int i=0; (long)(i)<(long)(g.gl_pathc); i++ ){
		char *fnam = new char[ strlen(g.gl_pathv[i]) + 2 ];
		strcpy(fnam, g.gl_pathv[i] );
		files.push_back(fnam);
	}
	globfree( &g );
}


#else


#error "Target has no implementation for FileScan class"


#endif  // PLATFORM_SELECTION

