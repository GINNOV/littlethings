/* open.c */

#include <stdio.h>
#include <dos/dos.h>
#include <clib/dos_protos.h>
#ifdef REGARGS
#   include <pragmas/dos_pragmas.h>

extern struct Library * DOSBase;
#endif

#include "restrack_intern.h"


/*****************************************************************************

    NAME
	__rtl_Open

    SYNOPSIS
	BPTR __rtl_Open (STRPTR name, long mode, const char * file, int line);

    FUNCTION
	Stub for Open()

******************************************************************************/

BPTR __rtl_Open (STRPTR name, long mode, const char * file, int line)
{
    BPTR fh;

    if ( (fh = Open (name, mode)) )
	CHECK_ADD_RN(RTL_DOS,RTLRT_Open,fh,0);

    return (fh);
} /* __rtl_Open */


/*****************************************************************************

    NAME
	__rtl_Close

    SYNOPSIS
	LONG __rtl_Close (BPTR fh);

    FUNCTION
	Stub for Close().

******************************************************************************/

LONG __rtl_Close (BPTR fh, const char * file, int line)
{
    LONG success = FALSE;
    ResourceNode * node;

    CHECK_REM_RN(fh,RTLRT_Open,Close,success=Close(fh),RTL_DOS,"(%p)",fh)

    return (success);
} /* __rtl_Close */


NRT_RET(LONG,Close,(BPTR fh),(fh))
NRT_RET(BPTR,Lock,(STRPTR name, long type),(name,type))


/* END open.c */
