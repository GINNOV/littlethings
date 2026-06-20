
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


#include "SysSupport/Timer.h"


Timer  sync;
float  sys_time 		 = 0.0f;


#if defined(WIN32)

#include <windows.h>

static LARGE_INTEGER now;   //!<  WIN32
static LARGE_INTEGER temp;  //!<  WIN32
static double        res;   //!<  WIN32


//!  Update WIN32
void Timer::Update(){
	QueryPerformanceCounter( &now );
}


//!  Return milliseconds passed since last call - WIN32
double Timer::Passed(){
	QueryPerformanceCounter( &temp );

	return( temp.QuadPart - now.QuadPart) * res;
}


//!  Constructor WIN32
Timer::Timer(){
	LARGE_INTEGER freq;

	QueryPerformanceFrequency( &freq );
	QueryPerformanceCounter  ( &now );
	res = (double)( 1000.0 / (double) freq.QuadPart );
}


// FIXME: add a check for POSIX systems...
#elif 1


#include <sys/time.h>
#include <cstdio>


static timeval last;  //!< POSIX



//!  Constructor POSIX
Timer::Timer(){
}


//!  Update POSIX
void Timer::Update(){
	gettimeofday( &last, NULL );
//    printf( "Timer update %ld.%6ld\n", last.tv_sec, last.tv_usec );
}


//!  Return milliseconds passed since last call - POSIX
double Timer::Passed(){
	timeval now;
	timeval diff;

	gettimeofday( &now, NULL );
	/*timersub( &now, &last, &diff );
	 */
	diff.tv_sec  = now.tv_sec  - last.tv_sec;
	diff.tv_usec = now.tv_usec - last.tv_usec;
	if( diff.tv_usec < 0 ){
		diff.tv_usec += 1000000;
        diff.tv_sec  -= 1;
	}
	if( diff.tv_usec < 0 ||
		diff.tv_sec  < 0    )
	{
        printf( "Shit happens\n" );
	}
	double result = 1000.0 * diff.tv_sec + ((double)diff.tv_usec/1000.0);
	return result;
}


#else


#error "Target has no implementation for Timer class"


#endif //  WIN32


