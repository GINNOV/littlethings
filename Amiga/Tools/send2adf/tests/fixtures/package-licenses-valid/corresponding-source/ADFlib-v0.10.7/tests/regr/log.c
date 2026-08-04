
#include "log.h"

#include <stdarg.h>

static const char
    * const prefix_error   = "Error:   ",
    * const prefix_warning = "Warning: ",
    * const prefix_info    = "Info:    ";

static loglevel_t loglevel;
FILE *            logfile;


void log_init( FILE * const      file,
               const loglevel_t  level )
{
    log_set_file( file );
    log_set_level( level );
}

void log_set_level( const loglevel_t level )
{
    loglevel = level;
}

void log_set_file( FILE * const file )
{
    logfile = file;
}

void log_error( const char * const  format, ... )
{
    //flog_error( logfile, ... );

    if ( loglevel < 1 )
        return;

    va_list ap;
    va_start( ap, format );
    fprintf( logfile, "%s", prefix_error );
    vfprintf( logfile, format, ap );
    fprintf( logfile, "\n" );
    va_end( ap );
}

void log_warning( const char * const  format, ... )
{
    //flog_warning( logfile, ... );

    if ( loglevel < 2 )
        return;

    va_list ap;
    va_start( ap, format );
    fprintf( logfile, "%s", prefix_warning );
    vfprintf( logfile, format, ap );
    fprintf( logfile, "\n" );
    va_end( ap );
}

void log_info( const char * const format, ... )
{
    //flog_warning( logfile, ... );

    if ( loglevel < 3 )
        return;

    va_list ap;
    va_start( ap, format );
    fprintf( logfile, "%s", prefix_info );
    vfprintf( logfile, format, ap );
    fprintf( logfile, "\n" );
    va_end( ap );
}


void flog_error( FILE * const        file,
                 const char * const  format, ... )
{
    if ( loglevel < 1 )
        return;

    va_list ap;
    va_start( ap, format );
    fprintf( file, "%s", prefix_error );
    vfprintf( file, format, ap );
    fprintf( logfile, "\n" );
    va_end( ap );
}


void flog_warning( FILE * const        file,
                   const char * const  format, ... )
{
    if ( loglevel < 2 )
        return;

    va_list ap;
    va_start( ap, format );
    fprintf( file, "%s", prefix_warning );
    vfprintf( file, format, ap );
    fprintf( logfile, "\n" );
    va_end( ap );
}


void flog_info( FILE * const       file,
                const char * const format, ... )
{
    if ( loglevel < 3 )
        return;

    va_list ap;
    va_start( ap, format );
    fprintf( file, "%s", prefix_info );
    vfprintf( file, format, ap );
    fprintf( logfile, "\n" );
    va_end( ap );
}
