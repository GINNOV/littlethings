/* allocvec.c */

#include <stdio.h>
#include <exec/memory.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"


/*****************************************************************************

    NAME
	__rtl_AllocVec -- allocate memory

    SYNOPSIS
	APTR __rtl_AllocVec (ULONG, ULONG, const char *, int);

    FUNCTION
	Stub for AllocVec().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

APTR __rtl_AllocVec (ULONG size, ULONG flags, const char * file, int line)
{
    APTR mem;

    if ( (mem = AllocVec (size, flags)) )
	CHECK_ADD_RN(RTL_EXEC,RTLRT_AllocVec,mem,size)

    return (mem);
} /* __rtl_AllocVec */


/*****************************************************************************

    NAME
	__rlt_FreeVec

    SYNOPSIS
	void __rtl_FreeVec (APTR mem, ULONG size, const char * file, int line);

    FUNCTION
	Stub for FreeVec(). Frees a block of memory allocated by
	__rlt_AllocVec().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_FreeVec (APTR mem, const char * file, int line)
{
    ResourceNode * node;

    CHECK_REM_RN(mem,RTLRT_AllocVec,FreeVec,FreeVec(mem),RTL_EXEC,"(%p)",mem)

} /* __rlt_FreeVec */


NRT_RET(APTR,AllocVec,(ULONG size, ULONG flags),(size,flags))
NRT(FreeVec,(APTR block),(block))


/******************************************************************************
*****  ENDE allocvec.c
******************************************************************************/
