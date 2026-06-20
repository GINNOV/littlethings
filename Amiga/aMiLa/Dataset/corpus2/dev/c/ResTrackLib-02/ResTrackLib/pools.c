/* opendevice.c */

#include <stdio.h>
#include <exec/ports.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"


APTR CreatePool( unsigned long requirements, unsigned long puddleSize,
	unsigned long threshSize );
void DeletePool( APTR poolHeader );
APTR AllocPooled( APTR poolHeader, unsigned long memSize );
void FreePooled( APTR poolHeader, APTR memory, unsigned long memSize );

/*****************************************************************************

    NAME
	__rtl_CreateMsgPort -- allocate memory

    SYNOPSIS
	struct MsgPort * __rtl_CreateMsgPort (const char * file, int line);

    FUNCTION
	Stub for CreateMsgPort().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

struct MsgPort * __rtl_CreateMsgPort (const char * file, int line)
{
    struct MsgPort * mp;

    if ( (mp = CreateMsgPort ()) )
	CHECK_ADD_RN(RTL_EXEC,RTLRT_MsgPort,mp,0)

    return (mp);
} /* __rtl_CreateMsgPort */


/*****************************************************************************

    NAME
	__rtl_DeleteMsgPort

    SYNOPSIS
	void __rtl_DeleteMsgPort( struct MemHeader *freeList, APTR memoryBlock,
			ULONG byteSize, const char * file, int line );

    FUNCTION
	Stub for FreeMem(). Frees a block of memory allocated by
	__rlt_AllocMem().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_DeleteMsgPort (struct MsgPort * mp, const char * file, int line)
{
    ResourceNode * node;

    if ((node = FindResourceNode1 (mp)) )
    {
	if (node->Resource != RTLRT_MsgPort)
	{
	    fprintf (stderr, "ERROR: DeleteMsgPort() at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    DeleteMsgPort (mp);
	    RemoveResourceNode (node);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL(RTL_EXEC,DeleteMsgPort,"(%p)",mp, DeleteMsgPort(mp))

} /* __rlt_DeleteMsgPort */


NRT_RET(struct MsgPort *,CreateMsgPort,(void),())
NRT(DeleteMsgPort,(struct MsgPort * mp),(mp))


/******************************************************************************
*****  ENDE opendevice.c
******************************************************************************/
