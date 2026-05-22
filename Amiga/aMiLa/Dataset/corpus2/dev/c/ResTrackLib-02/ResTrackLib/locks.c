/* lock.c */

#include <stdio.h>
#include <dos/dos.h>
#include <clib/dos_protos.h>
#ifdef REGARGS
#   include <pragmas/dos_pragmas.h>

extern struct Library * DOSBase;
#endif

#include "restrack_intern.h"


BPTR __rtl_Lock (STRPTR name, long type, const char * file, int line)
{
    BPTR lock;

    if ( (lock = Lock (name, type)) )
	CHECK_ADD_RN(RTL_DOS,RTLRT_Lock,lock,0);

    return (lock);
} /* __rtl_Lock */


BPTR __rtl_CreateDir (STRPTR name, const char * file, int line)
{
    BPTR dir;

    if ( (dir = CreateDir (name)) )
	CHECK_ADD_RN(RTL_DOS,RTLRT_Lock,dir,0);

    return (dir);
} /* __rtl_CreateDir */


BPTR __rtl_CurrentDir (BPTR new, const char * file, int line)
{
    BPTR old;

    if ( (old = CurrentDir (new)) )
    {
	ResourceNode * node;

	if ((node = FindResourceNode1 ((APTR)new)) )
	{
	    if (node->Resource != RTLRT_Lock)
	    {
		fprintf (stderr, "ERROR: Using this at %s:%d as a lock:\n",
			file, line);
		PrintResourceNode (node);
	    }
	    else
	    {
		/* this is not our responsibility anymore, so we can
		    simply change the node */
		if (ResourceTrackingLevel > 0 && (ResourcesToTrack & RTL_DOS))
		    node->Ptr = (APTR)old;
		else
		    RemoveResourceNode (node);  /* otherwise free the node */
	    }
	}
	else if (DO_RT(RTL_DOS))
	    AddResourceNode (file, line, RTLRT_Lock, (APTR)old, 0);
    }

    return (old);
} /* __rtl_CurrentDir */


BPTR __rtl_DupLock (BPTR lock, const char * file, int line)
{
    BPTR new;
    ResourceNode * node;

    if ((node = FindResourceNode1 ((APTR)lock)) )
    {
	if (node->Resource != RTLRT_Lock)
	{
	    fprintf (stderr, "ERROR: DupLock at %s:%d called for\n",
		    file, line);
	    PrintResourceNode (node);
	}
	else
	{
	    if ( (new = DupLock (lock)) && DO_RT(RTL_DOS))
		AddResourceNode (file, line, RTLRT_Lock, (APTR)new, 0);
	}
    }
    else
	CHECK_RT_ERROR_OR_CALL(RTL_DOS,DupLock,"(%p)",lock,new = DupLock (lock))

    return (new);
} /* __rtl_DupLock */


void __rtl_UnLock (BPTR lock, const char * file, int line)
{
    ResourceNode * node;

    CHECK_REM_RN(lock,RTLRT_Lock,UnLock,UnLock(lock),RTL_DOS,"(%p)",lock)

} /* __rtl_UnLock */


NRT(UnLock,(BPTR lock),(lock))
NRT_RET(BPTR,DupLock,(BPTR lock),(lock))
NRT_RET(BPTR,CurrentDir,(BPTR lock),(lock))
NRT_RET(BPTR,CreateDir,(STRPTR name),(name))


/* END lock.c */
