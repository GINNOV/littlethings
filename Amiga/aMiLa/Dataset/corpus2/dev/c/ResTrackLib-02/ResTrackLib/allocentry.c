/* allocentry.c */

#include <stdio.h>
#include <exec/memory.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"


/*****************************************************************************

    NAME
	__rtl_AllocEntry -- allocate memory

    SYNOPSIS
	struct MemList * __rtl_AllocEntry( struct MemList *entry
					    const char * file, int line )

    FUNCTION
	Stub for AllocEntry().

    HISTORY
	28. Jul 1994	Optimizer   created

******************************************************************************/

#define ALLOCERROR	(0x80000000L)

struct MemList * __rtl_AllocEntry( struct MemList *entry,
			    const char * file, int line )
{
    struct MemList * mem;

    mem = AllocEntry (entry);

    if (!((ULONG)mem & ALLOCERROR) )
	CHECK_ADD_RN(RTL_EXEC,RTLRT_AllocEntry,mem,0)

    return (mem);
} /* __rtl_AllocEntry */


/*****************************************************************************

    NAME
	__rtl_FreeEntry

    SYNOPSIS
	void __rtl_FreeEntry( struct MemList *entry, const char * file, int line );

    FUNCTION
	Stub for FreeMem(). Frees a block of memory allocated by
	__rlt_AllocMem().

    HISTORY
	28. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_FreeEntry( struct MemList *entry, const char * file, int line )
{
    ResourceNode * node;

    if ((node = FindResourceNode1 (entry)) )
    {
	if (node->Resource != RTLRT_AllocEntry)
	{
	    fprintf (stderr, "ERROR: FreeEntry() at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    FreeEntry (entry);
	    RemoveResourceNode (node);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL(RTL_EXEC,FreeEntry,"(%p)",entry,FreeEntry (entry))

} /* __rlt_FreeEntry */


NRT_RET(struct MemList *,AllocEntry,(struct MemList * list),(list))
NRT(FreeEntry,(struct MemList * list),(list))


/******************************************************************************
*****  ENDE allocentry.c
******************************************************************************/
