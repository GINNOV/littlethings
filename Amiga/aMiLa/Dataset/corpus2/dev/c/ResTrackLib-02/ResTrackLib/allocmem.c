/* allocmem.c */

#include <stdio.h>
#include <exec/memory.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"


/*****************************************************************************

    NAME
	__rtl_AllocMem -- allocate memory

    SYNOPSIS
	APTR __rtl_AllocMem (ULONG, ULONG, const char *, int);

    FUNCTION
	Stub for AllocMem().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

APTR __rtl_AllocMem (ULONG size, ULONG flags, const char * file, int line)
{
    APTR mem;

    if ( (mem = AllocMem (size, flags)) )
	CHECK_ADD_RN(RTL_EXEC,RTLRT_AllocMem,mem,size)

    return (mem);
} /* __rtl_AllocMem */


/*****************************************************************************

    NAME
	__rlt_FreeMem

    SYNOPSIS
	void __rtl_FreeMem (APTR mem, ULONG size, const char * file, int line);

    FUNCTION
	Stub for FreeMem(). Frees a block of memory allocated by
	__rlt_AllocMem().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_FreeMem (APTR mem, ULONG size, const char * file, int line)
{
    ResourceNode * node;

    if ((node = FindResourceNode1 (mem)) )
    {
	if (node->Resource != RTLRT_AllocMem)
	{
	    fprintf (stderr, "ERROR: FreeMem at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    if (node->Long != size)
	    {
		fprintf (stderr, "ERROR: FreeMem at %s:%d called with wrong size\n",
			    file, line);
	    }

	    FreeMem (mem, node->Long);
	    RemoveResourceNode (node);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL2(RTL_EXEC,FreeMem,"(%p, %ld)",mem,size,FreeMem (mem, size))

} /* __rlt_FreeMem */


NRT_RET(APTR,AllocMem,(ULONG size, ULONG flags),(size, flags))
NRT(FreeMem,(APTR block, ULONG size),(block,size))


/******************************************************************************
*****  ENDE allocmem.c
******************************************************************************/
