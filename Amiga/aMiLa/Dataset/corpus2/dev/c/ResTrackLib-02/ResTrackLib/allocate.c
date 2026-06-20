/* allocate.c */

#include <stdio.h>
#include <exec/memory.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"


/*****************************************************************************

    NAME
	__rtl_Allocate -- allocate memory

    SYNOPSIS
	APTR __rtl_Allocate( struct MemHeader *freeList, ULONG byteSize,
			    const char * file, int line);

    FUNCTION
	Stub for Allocate().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

APTR __rtl_Allocate( struct MemHeader *freeList, ULONG byteSize,
		    const char * file, int line )
{
    APTR mem;

    if ( (mem = Allocate (freeList, byteSize)) )
	CHECK_ADD_RN3(RTL_EXEC,RTLRT_Allocate,mem,byteSize,freeList)

    return (mem);
} /* __rtl_Allocate */


/*****************************************************************************

    NAME
	__rtl_Deallocate

    SYNOPSIS
	void __rtl_Deallocate( struct MemHeader *freeList, APTR memoryBlock,
			ULONG byteSize, const char * file, int line );

    FUNCTION
	Stub for FreeMem(). Frees a block of memory allocated by
	__rlt_AllocMem().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_Deallocate( struct MemHeader *freeList, APTR memoryBlock,
			ULONG byteSize, const char * file, int line )
{
    ResourceNode * node;

    if ((node = FindResourceNode1 (memoryBlock)) )
    {
	if (node->Resource != RTLRT_Allocate)
	{
	    fprintf (stderr, "ERROR: Deallocate() at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    if (node->Long != byteSize)
	    {
		fprintf (stderr, "WARNING: Deallocate() at %s:%d called with wrong size\n",
			    file, line);
	    }

	    if (node->Ptr2 == (APTR)freeList)
	    {
		Deallocate (freeList, memoryBlock, node->Long);
		RemoveResourceNode (node);
	    }
	    else
		fprintf (stderr, "ERROR: Deallocate() called for different MemHeader (%s:%d)\n",
			    file, line);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL2(RTL_EXEC,Deallocate,"(%p, %ld)",memoryBlock,
		byteSize, Deallocate(freeList, memoryBlock, byteSize))

} /* __rlt_Deallocate */


NRT_RET(APTR,Allocate,(struct MemHeader *freeList, ULONG byteSize),(freeList, byteSize))
NRT(Deallocate,(struct MemHeader *freeList, APTR memoryBlock, ULONG byteSize),(freeList,memoryBlock,byteSize))


/******************************************************************************
*****  ENDE allocate.c
******************************************************************************/
