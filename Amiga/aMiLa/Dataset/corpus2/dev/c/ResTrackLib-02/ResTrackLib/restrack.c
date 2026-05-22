/******************************************************************************

    MODUL
	restrack.c

    DESCRIPTION

    NOTES

    BUGS

    TODO

    EXAMPLES

    SEE ALSO

    INDEX

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

/**************************************
		Includes
**************************************/
#include <stdio.h>
#include <exec/lists.h>
#include "lists.h"

#include <clib/exec_protos.h>
#include <clib/dos_protos.h>
#ifdef REGARGS
#   include <pragmas/exec_pragmas.h>
#   include <pragmas/dos_pragmas.h>

extern struct Library * DOSBase;
#endif

#include "restrack_intern.h"


/**************************************
	    Globale Variable
**************************************/


/**************************************
      Interne Defines & Strukturen
**************************************/


/**************************************
	   Interne Prototypes
**************************************/
void hFreeMem	    (ResourceNode *);
void hFreeVec	    (ResourceNode *);
void hClose	    (ResourceNode *);
void hUnLock	    (ResourceNode *);
void hCloseLibrary  (ResourceNode *);
void hDeallocate    (ResourceNode *);
void hFreeEntry     (ResourceNode *);
void hDeleteMsgPort (ResourceNode *);
void hCloseDevice   (ResourceNode *);


/**************************************
	    Interne Variable
**************************************/
LONG  ResourceTrackingLevel;
ULONG ResourcesToTrack;

static struct MinList ResourceList = InitMinList (ResourceList);

const ResourceHandler Handler[] =
{
    /* RLTRT_AllocMem */    hFreeMem,	    "AllocMem()",       "%d Bytes",
    /* RTLRT_AllocVec */    hFreeVec,	    "AllocVec()",       "%d Bytes",
    /* RTLRT_Open */	    hClose,	    "Open()",           "",
    /* RTLRT_Lock */	    hUnLock,	    "Lock()",           "",
    /* RTLRT_OpenLibrary */ hCloseLibrary,  "OpenLibrary()",    "%s",
    /* RTLRT_Allocate */    hDeallocate,    "Allocate()",       "%d Bytes",
    /* RTLRT_AllocEntry */  hFreeEntry,     "AllocEntry()",     "",
    /* RTLRT_MsgPort */     hDeleteMsgPort, "CreateMsgPort()",  "",
    /* RTLRT_IORequest */   hCloseDevice,   "OpenDevice()",     "Unit %d",
#if 0
    /* RTLRT_Pool */	    hDeletePool,    "Memory Pool",      "",
#endif
};


/*****************************************************************************

    NAME
	StartResourceTracking -- initialize resource tracking

    SYNOPSIS
	void StartResourceTracking (ULONG flags);

    FUNCTION
	Initializes resource tracking for the specified resources. You
	can allocate resources before this call, but they won't be tracked.
	You MUST NOT set the ResourceTrackingLevel, though.

    INPUTS
	flags - specifies the resources to be tracked. You can specify
		RTL_NOTRACK to track all BUT the specified resources, ie.
		RTL_NOTRACK|RTL_DOS will track every resource but those in
		DOS (eg. Open(), Close(), etc.).

		    RTL_TRACK	    Track the specified resources (just
				    for completeness, can be left out).
		    RTL_NOTRACK     Track all but the specified resources.
		    RTL_ALL	    Track all known resources

		    RTL_CLIB	    include/exclude c.lib
		    RTL_DOS	    dito for DOS.library
		    RTL_EXEC	    dito for exec.library

    RESULT
	none.

    NOTES
	It is legal to allocate resources before the call of this function.
	These resources won't show up in the list of tracked resources.

    EXAMPLE
	StartResourceTracking (RTL_EXEC);       // Track exec stuff

	AllocMem (6543,0);
	Open ("ram:tmp", MODE_OLDFILE);

	PrintTrackedResources ();               // shows only the allocmem
	EndResourceTracking ();     // prints an error for the allocmem and
				    // frees the memory. The file is ignored.

    BUGS
	You system may crash if you set the ResourceTrackingLevel > 0
	before you call this function.

	The library uses several global variables. You programs can be
	made resident with DICE and SAS/C but you loose a couple of bytes
	in the data segment.

	The names for the functions in this library are too long.

    SEE ALSO
	PrintTrackedResources(), EndResourceTracking().

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void StartResourceTracking (ULONG flags)
{
    /* get the resources to track */
    if (flags & RTL_NOTRACK)
	flags = ~flags;

    ResourcesToTrack	  = flags;
    ResourceTrackingLevel = 1;
} /* StartResourceTracking */


/*****************************************************************************

    NAME
	SetResourceTracking -- initialize resource tracking

    SYNOPSIS
	void SetResourceTracking (ULONG flags);

    FUNCTION
	Changes resource tracking for the specified resources. All previously
	allocated and tracked resources are still tracked after this, but
	no resource not in <flags> will be tracked after this call.
	You didn't understand ? No wonder :-) Look:

	    // Track DOS-stuff
	    StartResourceTracking (RTL_DOS);

	    // lock a file. The AllocMem below is not tracked
	    lock = Lock (file);
	    mem = AllocMem (500,0);

	    // Now we stop DOS-tracking and start EXEC-tracking
	    SetResourceTracking (RTL_EXEC);

	    // The AllocMem before is still not in the list, but the
	    // lock is now removed from the list of tracked resources
	    UnLock (lock);
	    lock = Lock (file);     // this new lock is NOT tracked

	    mem = AllocMem (500,0); // this IS tracked

	    SetResourceTracking (RTL_DOS);

	    // The list of tracked resources does only contain the
	    // AllocMem now. The lock is lost.

	    EndResourceTracking ();

    INPUTS
	flags - specifies the resources to be tracked. You can specify
		RTL_NOTRACK to track all BUT the specified resources, ie.
		RTL_NOTRACK|RTL_DOS will track every resource but those in
		DOS (eg. Open(), Close(), etc.).

		    RTL_TRACK	    Track the specified resources (just
				    for completeness, can be left out).
		    RTL_NOTRACK     Track all but the specified resources.
		    RTL_ALL	    Track all known resources

		    RTL_CLIB	    include/exclude c.lib
		    RTL_DOS	    dito for DOS.library
		    RTL_EXEC	    dito for exec.library

    RESULT
	none.

    NOTES
	It is legal to allocate resources before the call of this function.
	These resources won't show up in the list of tracked resources.

    EXAMPLE
	SetResourceTracking (RTL_EXEC);       // Track exec stuff

	AllocMem (6543,0);
	Open ("ram:tmp", MODE_OLDFILE);

	PrintTrackedResources ();               // shows only the allocmem
	EndResourceTracking ();     // prints an error for the allocmem and
				    // frees the memory. The file is ignored.

    BUGS

    SEE ALSO
	StartResourceTracking(), PrintTrackedResources(),
	EndResourceTracking().

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void SetResourceTracking (ULONG flags)
{
    /* get the resources to track */
    if (flags & RTL_NOTRACK)
	flags = ~flags;

    ResourcesToTrack = flags;

} /* SetResourceTracking */


/*****************************************************************************

    NAME
	PrintTrackedResources

    SYNOPSIS
	void PrintTrackedResources (void);

    FUNCTION
	Terminates the resource tracking. All resources that are allocated
	at this time are printed out and freed. You may start resource
	tracking again after this call by calling StartResourceTracking()
	again.

    INPUTS
	none.

    RESULT
	none.

    NOTES

    EXAMPLE
	StartResourceTracking (RTL_EXEC);       // Track exec stuff

	AllocMem (6543,0);
	Open ("ram:tmp", MODE_OLDFILE);

	PrintTrackedResources ();               // shows only the allocmem
	EndResourceTracking ();     // prints an error for the allocmem and
				    // frees the memory. The file is ignored.

    BUGS

    SEE ALSO
	PrintTrackedResources(), StartResourceTracking().

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

#define PRINTLISTHEADER fprintf (stderr, "%-20s %20s \t %s\n", "Resource", "Where", "Comment")

void PrintTrackedResources (void)
{
    ResourceNode * node;

    fprintf (stderr, "These resources are currently tracked:\n");
    PRINTLISTHEADER;

    if (node=GetHead(&ResourceList))
    {
	for ( ; node; node=GetSucc(node))
	    PrintResourceNode (node);
    }
    else
	fprintf (stderr, "--- none ---\n");

} /* PrintTrackedResources */


/*****************************************************************************

    NAME
	SetResourceTrackingLevel

    SYNOPSIS
	LONG oldlevel = SetResourceTrackingLevel (LONG newlevel);

    FUNCTION
	This sets the ResourceTrackingLevel to the specified value.
	If <newlevel> is < 0, then no resource tracking will happen
	until the value is raised above 0. Use this function to
	temporarily disable resource tracking.

    INPUTS
	newlevel - the new level. If this is < 0, no resource tracking
		takes place.

    RESULT
	The old value of ResourceTrackingLevel. Just in case you
	want to restore it later.

    NOTES
	All resources allocated while ResourceTrackingLevel < 0 are not
	tracked, but resources freed during this time are still removed
	from the list of tracked resources.

    EXAMPLE
	// Ask for the current value if ResourceTrackingLevel ... *ahem*
	SetResourceTrackingLevel (val = SetResourceTrackingLevel (0));

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

LONG SetResourceTrackingLevel (LONG newlevel)
{
    LONG old;

    old = ResourceTrackingLevel;
    ResourceTrackingLevel = newlevel;

    return (old);
} /* SetResourceTrackingLevel */


/*****************************************************************************

    NAME
	IncResourceTrackingLevel

    SYNOPSIS
	LONG oldlevel = IncResourceTrackingLevel (void);

    FUNCTION
	This increments the ResourceTrackingLevel by one. If <oldlevel> is
	< 0, then no resource tracking will happen until the value is
	raised above 0. Use this function to temporarily disable resource
	tracking and when you need nesting.

    INPUTS
	none.

    RESULT
	The old value of ResourceTrackingLevel. If it is >= 0, then
	resource tracking takes place now.

    NOTES
	All resources allocated while ResourceTrackingLevel < 0 are not
	tracked, but resources freed during this time are still removed
	from the list of tracked resources.

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

LONG IncResourceTrackingLevel (void)
{
    return (ResourceTrackingLevel ++);

} /* IncResourceTrackingLevel */


/*****************************************************************************

    NAME
	DecResourceTrackingLevel

    SYNOPSIS
	LONG oldlevel = DecResourceTrackingLevel (void);

    FUNCTION
	This decrements the ResourceTrackingLevel by one. If <oldlevel> is
	<= 1, then no resource tracking will happen until the value is
	raised above 0. Use this function to temporarily disable resource
	tracking and when you need nesting.

    INPUTS
	none.

    RESULT
	The old value of ResourceTrackingLevel. If it is <= 1, then
	resource tracking is now disabled.

    NOTES
	All resources allocated while ResourceTrackingLevel < 0 are not
	tracked, but resources freed during this time are still removed
	from the list of tracked resources.

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

LONG DecResourceTrackingLevel (void)
{
    return (ResourceTrackingLevel --);

} /* DecResourceTrackingLevel */


/*****************************************************************************

    NAME
	EndResourceTracking

    SYNOPSIS
	void EndResourceTracking (void);

    FUNCTION
	Terminates the resource tracking. All resources that are allocated
	at this time are printed out and freed. You may start resource
	tracking again after this call by calling StartResourceTracking()
	again.

    INPUTS
	none.

    RESULT
	none.

    NOTES

    EXAMPLE
	StartResourceTracking (RTL_EXEC);       // Track exec stuff

	AllocMem (6543,0);
	Open ("ram:tmp", MODE_OLDFILE);

	PrintTrackedResources ();               // shows only the allocmem
	EndResourceTracking ();     // prints an error for the allocmem and
				    // frees the memory. The file is ignored.

    BUGS

    SEE ALSO
	PrintTrackedResources(), StartResourceTracking().

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void EndResourceTracking (void)
{
    ResourceNode * node, * next;

    if (node=GetHead(&ResourceList))
    {
	fprintf (stderr, "These resources were still allocted when "
			 "EndResourceTracking was called:\n");
	PRINTLISTHEADER;

	for ( ; node; node=next)
	{
	    next = GetSucc (node);

	    PrintResourceNode (node);
	    (*(Handler[node->Resource].FreeResource)) (node);
	    RemoveResourceNode (node);
	}
    }

    ResourceTrackingLevel = 0;	   /* Stop resource tracking */

} /* EndResourceTracking */


/*****************************************************************************

    NAME
	AddResourceNode -- add a new resource to the list

    SYNOPSIS
	void AddResourceNode (const char * file, WORD line, WORD resource,
			APTR ptr, LONG l);

    FUNCTION
	Creates a new node in the resource list. If there is not enough
	memory for this operation, the call will do nothing.

    INPUTS
	file - name of the file in which the resouce was allocated
		(__FILE__).
	line - the line in the file (__LINE__).
	Data0, Data1 - int or ptr describing the resource

    RESULT
	none.

    NOTES

    EXAMPLE
	AddResourceNode ("test.c", 24, RES_AllocMem, ptr, 500);

    BUGS

    SEE ALSO
	FindResourceNode1(), FindResourceNode2(), RemoveResourceNode()

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void AddResourceNode (const char * file, WORD line, WORD resource, APTR ptr,
		      LONG l)
{
    ResourceNode * node;

    if ( (node = AllocMem (sizeof (ResourceNode), 0)) )
    {
	node->File     = file;
	node->Line     = line;
	node->Resource = resource;
	node->Ptr      = ptr;
	node->Long     = l;

	/* Add node to the head. This ensures that we clean up in the
	   opposite direction as we got the resources */
	AddHead ((struct List *)&ResourceList, (struct Node *)node);
    }
} /* AddResourceNode */


/*****************************************************************************

    NAME
	AddResourceNode3 -- add a new resource to the list

    SYNOPSIS
	void AddResourceNode2 (const char * file, WORD line, WORD resource,
			APTR ptr, LONG l, APTR ptr2);

    FUNCTION
	Creates a new node in the resource list. If there is not enough
	memory for this operation, the call will do nothing.

    INPUTS
	file - name of the file in which the resouce was allocated
		(__FILE__).
	line - the line in the file (__LINE__).
	Data0, Data1 - int or ptr describing the resource

    RESULT
	none.

    NOTES

    EXAMPLE
	AddResourceNode3 ("test.c", 24, RES_Allocate, ptr, 500, memlist);

    BUGS

    SEE ALSO
	AddResourceNode(), FindResourceNode1(), FindResourceNode2(),
	RemoveResourceNode()

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void AddResourceNode3 (const char * file, WORD line, WORD resource, APTR ptr,
		      LONG l, APTR ptr2)
{
    ResourceNode * node;

    if ( (node = AllocMem (sizeof (ResourceNode), 0)) )
    {
	node->File     = file;
	node->Line     = line;
	node->Resource = resource;
	node->Ptr      = ptr;
	node->Long     = l;
	node->Ptr2     = ptr2;

	/* Add node to the head. This ensures that we clean up in the
	   opposite direction as we got the resources */
	AddHead ((struct List *)&ResourceList, (struct Node *)node);
    }
} /* AddResourceNode3 */


/*****************************************************************************

    NAME
	PrintResourceNode

    SYNOPSIS
	void PrintResourceNode (ResourceNode * node);

    FUNCTION
	Prints a formatted version of the node to stderr.

    INPUTS
	node - The node is nicely formatted and printed.

    RESULT

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void PrintResourceNode (ResourceNode * node)
{
    fprintf (stderr, "%-20s %20s:%d\t",
	    Handler[node->Resource].ResourceName, node->File, node->Line);
    fprintf (stderr, Handler[node->Resource].ResourcePrintFmt, node->Long);
    fputc ('\n', stderr);

} /* PrintResourceNode */


/*****************************************************************************

    NAME
	FindResourceNode1 -- find a resource with Ptr

    SYNOPSIS
	ResourceNode * FindResourceNode1 (APTR ptr);

    FUNCTION
	Go through the list of tracked resources and return the first
	node that matches Ptr.

    INPUTS
	data0 - Look for this entry

    RESULT
	A pointer to the node with node->Ptr == ptr or NULL if no such
	node is found.

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO
	AddResourceNode(), FindResourceNode2(), RemoveResourceNode()

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

ResourceNode * FindResourceNode1 (APTR ptr)
{
    ResourceNode * node;

    for (node=GetHead(&ResourceList); node; node=GetSucc(node))
	if (node->Ptr == ptr)
	    break;

    return (node);
} /* FindResourceNode1 */


/*****************************************************************************

    NAME
	FindResourceNode2 -- find a resource with Data[0] and Data[1]

    SYNOPSIS
	ResourceNode * FindResourceNode2 (APTR ptr, LONG l);

    FUNCTION
	Go through the list of tracked resources and return the first
	node that matches ptr and l.

    INPUTS
	ptr, l - Look for this entry

    RESULT
	A pointer to the node with node->Ptr == ptr and node->Long == l or
	NULL if no such node is found.

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO
	AddResourceNode(), FindResourceNode1(), RemoveResourceNode()

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

ResourceNode * FindResourceNode2 (APTR ptr, LONG l)
{
    ResourceNode * node;

    for (node=GetHead(&ResourceList); node; node=GetSucc(node))
	if (node->Ptr == ptr && node->Long == l)
	    break;

    return (node);
} /* FindResourceNode2 */


/*****************************************************************************

    NAME
	RemoveResourceNode

    SYNOPSIS
	void RemoveResourceNode (ResourceNode * node);

    FUNCTION
	Remove a ResourceNode for the list and free it. The resource that
	is contained in the node is untouched. You are responsible to free
	it yourself.

    INPUTS
	node - Remove this node from the list and free it. Must not be NULL.

    RESULT
	none.

    NOTES
	The node must have been created with AddResourceNode().

    EXAMPLE

    BUGS

    SEE ALSO
	AddResourceNode(), FindResourceNode1(), FindResourceNode2()

    INTERNALS

    HISTORY
	23. Jul 1994	Optimizer   created

******************************************************************************/

void RemoveResourceNode (ResourceNode * node)
{
    Remove ((struct Node *)node);
    FreeMem (node, sizeof (ResourceNode));

} /* RemoveResourceNode */


/******************************************************************************
		    Functions to free ResourceNodes
******************************************************************************/

void hFreeMem (ResourceNode * node)
{
    FreeMem (node->Ptr, node->Long);
} /* hFreeMem */


void hFreeVec (ResourceNode * node)
{
    FreeVec (node->Ptr);
} /* hFreeVec */


void hCloseLibrary (ResourceNode * node)
{
    CloseLibrary ((struct Library *)node->Ptr);
} /* hCloseLibrary */


void hDeallocate (ResourceNode * node)
{
    Deallocate ((struct MemHeader *)node->Ptr2, node->Ptr, node->Long);
} /* hDeallocate */


void hFreeEntry (ResourceNode * node)
{
     FreeEntry ((struct MemList *)node->Ptr);
} /* hFreeEntry */


void hDeleteMsgPort (ResourceNode * node)
{
     DeleteMsgPort ((struct MsgPort *)node->Ptr);
} /* hDeleteMsgPort */


void hCloseDevice (ResourceNode * node)
{
     CloseDevice ((struct IORequest *)node->Ptr);
} /* h */


void hClose (ResourceNode * node)
{
    Close ((BPTR)node->Ptr);
} /* hClose */


void hUnLock (ResourceNode * node)
{
    UnLock ((BPTR)node->Ptr);
} /* hUnLock */


/******************************************************************************
*****  ENDE restrack.c
******************************************************************************/
