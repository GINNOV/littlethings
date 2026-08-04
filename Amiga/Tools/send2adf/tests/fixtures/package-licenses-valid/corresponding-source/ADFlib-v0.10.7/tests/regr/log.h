
#pragma once

#include <stdio.h>

typedef int loglevel_t;


void log_init( FILE * const      file,
               const loglevel_t  level );

void log_set_file( FILE * const file );
void log_set_level( const loglevel_t level );

void log_error( const char * const  format, ... );
void log_warning( const char * const  format, ... );
void log_info( const char * const  format, ... );

void flog_error( FILE * const        file,
                 const char * const  format, ... );

void flog_warning( FILE * const        file,
                   const char * const  format, ... );

void flog_info( FILE * const        file,
                const char * const  format, ... );
