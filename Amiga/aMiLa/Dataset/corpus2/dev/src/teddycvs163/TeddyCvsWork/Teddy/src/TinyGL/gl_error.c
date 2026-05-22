
/*!
	\file
	\ingroup
	\author
	\date    2001
*/


#include "TinyGL/gl_zgl.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>


void gl_fatal_error( char *format, ... ){
	va_list ap;

	va_start( ap, format );
	fprintf ( stderr, "TinyGL: fatal error: " );
	vfprintf( stderr, format, ap );
	fprintf ( stderr, "\n" );
	exit    ( 1 );
	va_end  ( ap );
}

