/* opendevice.c */

#include <stdio.h>
#include <exec/ports.h>
#include <clib/exec_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#endif

#include "restrack_intern.h"


/*****************************************************************************

    NAME
	__rtl_OpenDevice -- allocate memory

    SYNOPSIS
	BYTE __rtl_OpenDevice ( UBYTE *devName, ULONG unit,
			struct IORequest *ioRequest, ULONG flags,
			const char * file, int line);

    FUNCTION
	Stub for OpenDevice().

    HISTORY
	28. Jul 1994	Optimizer   created

******************************************************************************/

BYTE __rtl_OpenDevice ( UBYTE *devName, ULONG unit,
		struct IORequest *ioRequest, ULONG flags,
		const char * file, int line)
{
    BYTE ret;

    if (!(ret = OpenDevice (devName,unit,ioRequest,flags)) )
	CHECK_ADD_RN3(RTL_EXEC,RTLRT_IORequest,ioRequest,unit,devName)

    return (ret);
} /* __rtl_OpenDevice */


/*****************************************************************************

    NAME
	__rtl_CloseDevice

    SYNOPSIS
	void __rtl_CloseDevice ( struct IORequest *ioRequest, const char * file,
				int line);

    FUNCTION
	Stub for CloseDevice().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_CloseDevice ( struct IORequest *ioRequest, const char * file,
			int line)
{
    ResourceNode * node;

    if ((node = FindResourceNode1 (ioRequest)) )
    {
	if (node->Resource != RTLRT_IORequest)
	{
	    fprintf (stderr, "ERROR: CloseDevice() at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    CloseDevice (ioRequest);
	    RemoveResourceNode (node);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL(RTL_EXEC,CloseDevice,"(%p)",ioRequest,
		    CloseDevice(ioRequest))

} /* __rtl_CloseDevice */


NRT_RET(BYTE,OpenDevice,(UBYTE *devName, ULONG unit,struct IORequest *ioRequest, ULONG flags),
	(devName,unit,ioRequest,flags))
NRT(CloseDevice,(struct IORequest * ioRequest),(ioRequest))

#define RET_FUNC(type,ret,name)                                             \
type __rtl_ ## name (struct IORequest *ioRequest, const char * file,        \
			int line)					    \
{									    \
    ResourceNode * node;						    \
    type ret;								    \
									    \
    if ((node = FindResourceNode1 (ioRequest)) )                            \
    {									    \
	if (node->Resource != RTLRT_IORequest)                              \
	{								    \
	    fprintf (stderr, "ERROR: " # name "() at %s:%d called for\n",   \
		    file, line);					    \
	    PrintResourceNode (node);                                       \
	}								    \
	else								    \
	    ret = name (ioRequest);                                         \
    }									    \
    else								    \
	CHECK_RT_ERROR_OR_CALL(RTL_EXEC,name,"(%p)",ioRequest,              \
		    ret = name(ioRequest))                                  \
									    \
    return (ret);                                                           \
}

#define FUNC(name)                                                          \
void __rtl_ ## name (struct IORequest *ioRequest, const char * file,        \
			int line)					    \
{									    \
    ResourceNode * node;						    \
									    \
    if ((node = FindResourceNode1 (ioRequest)) )                            \
    {									    \
	if (node->Resource != RTLRT_IORequest)                              \
	{								    \
	    fprintf (stderr, "ERROR: " # name "() at %s:%d called for\n",   \
		    file, line);					    \
	    PrintResourceNode (node);                                       \
	}								    \
	else								    \
	    name (ioRequest);                                               \
    }									    \
    else								    \
	CHECK_RT_ERROR_OR_CALL(RTL_EXEC,name,"(%p)",ioRequest,              \
		    name(ioRequest))                                        \
}

RET_FUNC(BYTE,ret,DoIO)
FUNC(SendIO)
RET_FUNC(struct IORequest *,req,CheckIO)
RET_FUNC(BYTE,ret,WaitIO)
FUNC(AbortIO)


/*****************************************************************************

    NAME
	__rtl_CreateIORequest -- allocate memory

    SYNOPSIS
	APTR __rtl_CreateIORequest( struct MsgPort *port, ULONG size,
			    const char * file, int line);

    FUNCTION
	Stub for CreateIORequest().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

APTR __rtl_CreateIORequest( struct MsgPort *port, ULONG size,
		    const char * file, int line)
{
    ResourceNode * node;
    APTR ioreq;

    if ((node = FindResourceNode1 (port)) )
    {
	if (node->Resource != RTLRT_MsgPort)
	{
	    fprintf (stderr, "ERROR: CreateIORequest() at %s:%d expected a port but was called with\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    if ( (ioreq = CreateIORequest (port,size)) )
		CHECK_ADD_RN(RTL_EXEC,RTLRT_IORequest,ioreq,size)
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL2(RTL_EXEC,CreateIORequest,"(%p, %ld)",port,size,
			    ioreq=CreateIORequest(port,size))

    return (ioreq);
} /* __rtl_CreateIORequest */


/*****************************************************************************

    NAME
	__rtl_DeleteIORequest

    SYNOPSIS
	void __rtl_DeleteIORequest( APTR iorequest, const char * file, int line );

    FUNCTION
	Stub for __rtl_DeleteIORequest().

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void __rtl_DeleteIORequest (struct IORequest * mp, const char * file, int line)
{
    ResourceNode * node;

    if ((node = FindResourceNode1 (mp)) )
    {
	if (node->Resource != RTLRT_IORequest)
	{
	    fprintf (stderr, "ERROR: DeleteIORequest() at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    DeleteIORequest (mp);
	    RemoveResourceNode (node);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL(RTL_EXEC,DeleteIORequest,"(%p)",mp, DeleteIORequest(mp))

} /* __rlt_DeleteIORequest */


NRT_RET(APTR,CreateIORequest,(struct MsgPort * port, ULONG size),(port,size))
NRT(DeleteIORequest,(struct MsgPort * mp),(mp))


/******************************************************************************
*****  ENDE opendevice.c
******************************************************************************/
