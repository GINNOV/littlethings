#ifndef _disasm_h_included
#define _disasm_h_included

//

#include <stdarg.h>
#include "tlcs900d.h"

//
// Return codes..
//

#define DPARSE_EXIT         -1
#define DPARSE_OK           0
#define DPARSE_SYNTAX_ERR   1
#define DPARSE_UNKNOWN_ERR  2
#define DPARSE_BOUNDS_ERR   3

//

int parse_command( char *, struct tlcs900d * );

//

static int memdump( struct tlcs900d *, char * );
static int disassem( struct tlcs900d *, char * );
static int disassemD( struct tlcs900d *, char * );
static int dexit( struct tlcs900d *, char * );
static int rominfo( struct tlcs900d *, char * );
static int help( struct tlcs900d *, char * );
static int poke( struct tlcs900d *, char * );
static int save( struct tlcs900d *, char * );

static int compare( const void *, const void * );
static uint32_t getptr( const char * );

//
//
//



#endif
