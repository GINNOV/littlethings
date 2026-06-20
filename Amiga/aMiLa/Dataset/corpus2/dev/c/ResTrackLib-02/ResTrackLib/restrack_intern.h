/******************************************************************************

    MODUL
	restrack_intern.h

    DESCRIPTION
	Internal defines and types for the resource tracking library.

******************************************************************************/

#ifndef RESTRACK_INTERN_H
#define RESTRACK_INTERN_H

/**************************************
		Includes
**************************************/
#ifndef EXEC_TYPES_H
#   include <exec/types.h>
#endif
#ifndef EXEC_LISTS_H
#   include <exec/lists.h>
#endif
#define RTL_INTERN
#include "restrack.h"


/**************************************
	Defines und Strukturen
**************************************/
/* Types of resources */
#define RTLRT_AllocMem	    0x0000	/* AllocMem(), FreeMem() */
#define RTLRT_AllocVec	    0x0001	/* AllocVec(), FreeVec() */
#define RTLRT_Open	    0x0002	/* Open(), Close() */
#define RTLRT_Lock	    0x0003	/* Lock(), UnLock(), DupLock(),
					   CreateDir(), CurrentDir() */
#define RTLRT_OpenLibrary   0x0004	/* OpenLibrary(), CloseLibrary() */
#define RTLRT_Allocate	    0x0005	/* Allocate(), Deallocate() */
#define RTLRT_AllocEntry    0x0006	/* AllocEntry(), FreeEntry() */
#define RTLRT_MsgPort	    0x0007	/* CreateMsgPort(), DeleteMsgPort() */
#define RTLRT_IORequest     0x0008	/* OpenDevice(), CloseDevice() */
#define RTLRT_Pool	    0x0009	/* CreatePool(), DeletePool(),
					   AllocPooled(), FreePooled() */

/* Check if we should do resource tracking for this resource */
#define DO_RT(flag)  (ResourceTrackingLevel > 0 && (ResourcesToTrack & (flag)))

/* Add the resource to the list if resource tracking is enabled and we track
   this resource. */
#define CHECK_ADD_RN(flag,rt,ptr,lng)                                       \
	if (DO_RT(flag))                                                    \
	    AddResourceNode (file, line, (rt), (APTR)ptr, (LONG)lng);

#define CHECK_ADD_RN3(flag,rt,ptr,lng,ptr2)                                 \
	if (DO_RT(flag))                                                    \
	    AddResourceNode3 (file, line, (rt), (APTR)ptr, (LONG)lng,       \
				(APTR)ptr2);

/* if resource tracking is enabled, print the error "Illegal cmd" else
   just call the command */
#define CHECK_RT_ERROR_OR_CALL(flag,name,fmt,arg,cmd)                       \
	if (DO_RT(flag))                                                    \
	{								    \
	    fprintf (stderr, "ERROR: Illegal " #name " " fmt " at %s:%d\n", \
		    arg, file, line);					    \
	}								    \
	else								    \
	    cmd;

#define CHECK_RT_ERROR_OR_CALL2(flag,name,fmt,arg1,arg2,cmd)                \
	if (DO_RT(flag))                                                    \
	{								    \
	    fprintf (stderr, "ERROR: Illegal " #name " " fmt " at %s:%d\n", \
		    arg1, arg2, file, line);				    \
	}								    \
	else								    \
	    cmd;

/* check the resource and if the type is ok, free it else print an error */
#define CHECK_RES_ERROR_OR_FREE(res,name,cmd)                               \
	if (node->Resource != res)                                          \
	{								    \
	    fprintf (stderr, "ERROR: " #name " at %s:%d called for\n",      \
		    file, line);					    \
	    PrintResourceNode (node);                                       \
	}								    \
	else								    \
	{								    \
	    cmd;							    \
	    RemoveResourceNode (node);                                      \
	}

/* Look for the resource. If we can't find it, print an error if resource
   tracking is enabled and we track this resource. If we don't track this
   resource or resource tracking is disabled, just call the command.
    If we found the resource, check the type. If the type is ok, call the
   command and remove the resource node. If the type is wrong, print an
   error. */
#define CHECK_REM_RN(par,res,name,cmd,flag,fmt,arg)                         \
    if ((node = FindResourceNode1 ((APTR)par)) )                            \
	CHECK_RES_ERROR_OR_FREE(res,name,cmd)                               \
    else								    \
	CHECK_RT_ERROR_OR_CALL(flag,name,fmt,arg,cmd)

#define NRT(name,param,args)            \
	void NRT_ ## name param 	\
	{				\
	    name args;			\
	}

#define NRT_RET(ret,name,param,args)    \
	ret NRT_ ## name param		\
	{				\
	    return (name args);         \
	}

typedef struct
{
    struct MinNode Node;
    const char *   File;
    WORD	   Line;
    WORD	   Resource;
    APTR	   Ptr;
    LONG	   Long;
    APTR	   Ptr2;
} ResourceNode;

typedef struct
{
    void (*FreeResource)(ResourceNode *);
    const char * ResourceName;
    const char * ResourcePrintFmt;
} ResourceHandler;


/**************************************
	    Globale Variable
**************************************/
extern LONG  ResourceTrackingLevel;
extern ULONG ResourcesToTrack;

extern const ResourceHandler Handler[];


/**************************************
	       Prototypes
**************************************/
void AddResourceNode (const char * file, WORD line, WORD resource, APTR ptr, LONG l);
void AddResourceNode3 (const char * file, WORD line, WORD resource, APTR ptr, LONG l, APTR ptr2);
void PrintResourceNode (ResourceNode * node);
ResourceNode * FindResourceNode1 (APTR ptr);
ResourceNode * FindResourceNode2 (APTR ptr, LONG l);
void RemoveResourceNode (ResourceNode * node);


#endif /* RESTRACK_INTERN_H */

/******************************************************************************
*****  ENDE restrack_intern.h
******************************************************************************/
