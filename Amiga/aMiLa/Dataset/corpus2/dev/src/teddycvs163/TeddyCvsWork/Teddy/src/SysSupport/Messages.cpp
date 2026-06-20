
#include "SysSupport/Messages.h"
#include <cstdio>
#include <cstdlib>
#include <cstdarg>


//#if defined( _DEBUG )
//# define PRINT_INIT_MESSAGES       1
//# define PRINT_WARNING_MESSAGES    1
//# define PRINT_DEBUG_MESSAGES      1
//# define PRINT_MAT_DEBUG_MESSAGES  1
//# define PRINT_LWO_DEBUG_MESSAGES  1
//# define PRINT_FFE_DEBUG_MESSAGES  1
//# define PRINT_NET_DEBUG_MESSAGES  1
//# define PRINT_TMAP_DEBUG_MESSAGES  1
//# define PRINT_VERT_DEBUG_MESSAGES  1
//define PRINT_WM_DEBUG_MESSAGES  1
//#endif
#define PRINT_ERROR_MESSAGES       1


void fatal_msg( char *format, ... ){
	va_list ap;

	va_start( ap, format );
	printf ( "Fatal: " );
	vprintf( format, ap );
	printf ( "\n" );
	exit   ( 1 );
	va_end ( ap );
}

void init_msg( char *format, ... ){
#	if defined( PRINT_INIT_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Init: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void warn_msg ( char *format, ... ){
#	if defined( PRINT_WARNING_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Warning: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void error_msg( char *format, ... ){
#	if defined( PRINT_ERROR_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Error: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void debug_msg( char *format, ... ){
#	if defined( PRINT_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Debug: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void mat_debug_msg( char *format, ... ){
#	if defined( PRINT_MAT_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Mat: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void lwo_debug_msg( char *format, ... ){
#	if defined( PRINT_LWO_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "LWO: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void ffe_debug_msg( char *format, ... ){
#	if defined( PRINT_FFE_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "FFE: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void net_debug_msg( char *format, ... ){
#	if defined( PRINT_NET_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Net: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void tmap_debug_msg( char *format, ... ){
#	if defined( PRINT_TMAP_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "TMap: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void vert_debug_msg( char *format, ... ){
#	if defined( PRINT_VERT_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "Vert: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}

void wm_debug_msg( char *format, ... ){
#	if defined( PRINT_WM_DEBUG_MESSAGES )
	va_list ap;

	va_start( ap, format );
	fprintf ( stdout, "WM: " );
	vfprintf( stdout, format, ap );
	fprintf ( stdout, "\n" );
	va_end  ( ap );
#	endif
}
