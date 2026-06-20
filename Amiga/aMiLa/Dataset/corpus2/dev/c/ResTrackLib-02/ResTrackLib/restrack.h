/******************************************************************************

    MODUL
	restrack.h

    DESCRIPTION
	Resource tracking for developing programs in C. The resource
	trackering library contains stubs for common library and Amiga OS
	calls and tracks the allocated resources. The process is
	initialized like this:

	    StartResourceTracking (flags);

	Where <flags> is a series of Resources that should be tracked. If
	you allocate a resource after this call, it is tracked and the tags
	are removed if you free the resource again. If you don't and call

	    EndResourceTracking ();

	any still allocated resources are displayed and freed. The output of
	this function looks like this:

	    Function	    Where	    Resource
	    AllocMem()      test.c:156      500 Bytes
	    Open()          text.c:24       File "RAM:RTL"

	"Function" is the name of the function that allocated the resource.
	"Where" gives the file and line where the resource was allocated
	and "Resource" gives more information about the specifc type of the
	resource itself.

	    There may be cases where you DON'T want resource tracking to
	happen. The ResTrackLib has four means to avoid resource tracking.

	    1. You can switch it off alltogether by specifiying

		    #define RESOURCE_TRACKING	    0

	       anwhere before you include this file.
	    2. You can use the NRT_xxx version of a function (like
	       NRT_AllocMem()). This uses a version of the function
	       which doesn't use resource tracking.
	    3. You can set a flag in the library that turns off
	       resource tracking temporarily with SetResTrackLevel(),
	       IncResTrackLevel() and DecResTrackLevel(). If the
	       level is < 0, no resource tracking will happen.
	    4. You can specifiy all resources that should or
	       should not be tracked with StartResourceTracking().

	And there is another goodie: PrintTrackedResources (); which
	prints a full list of all tracked resources. And last but not
	least, all calls to free a resource check their arguments for
	validity. If you free a non-allocated resource (eg. with a
	wrong pointer), an extensive error message is printed. See below
	for a list of all currently tracker resources.

******************************************************************************/

/* check if the user actually wants resource tracking */
#if !defined(RESOURCE_TRACKING) || RESOURCE_TRACKING

# ifndef RESTRACK_H
# define RESTRACK_H


/**************************************
		Includes
**************************************/
#ifndef EXEC_TYPES_H
#   include <exec/types.h>
#endif
#ifndef DOS_DOS_H
#   include <dos/dos.h>
#endif


/**************************************
	Defines und Strukturen
**************************************/
#ifndef RTL_INTERN	/* make sure we don't get the macros :-) */

/* here comes the magic: We just overwrite the normal functions with macros */

/* c.lib */

/* DOS */
#define Open(file,mode)         __rtl_Open(file,mode,__FILE__,__LINE__)
#define Close(fh)               __rtl_Close(fh,__FILE__,__LINE__)
#define Lock(name,type)         __rtl_Lock(name,type,__FILE__,__LINE__)
#define UnLock(lock)            __rtl_UnLock(lock,__FILE__,__LINE__)
#define DupLock(lock)           __rtl_DupLock(lock,__FILE__,__LINE__)
#define CreateDir(name)         __rtl_CreateDir(name,__FILE__,__LINE__)
#define CurrentDir(lock)        __rtl_CurrentDir(lock,__FILE__,__LINE__)

/* Exec */
#define RTL_DEF0(name)          __rtl_ ## name (__FILE__,__LINE__)
#define RTL_DEF1(name,p1)       __rtl_ ## name (p1,__FILE__,__LINE__)
#define RTL_DEF2(name,p1,p2)    __rtl_ ## name (p1,p2,__FILE__,__LINE__)
#define RTL_DEF3(name,p1,p2,p3) __rtl_ ## name (p1,p2,p3,__FILE__,__LINE__)
#define RTL_DEF4(name,p1,p2,p3,p4) __rtl_ ## name (p1,p2,p3,p4,__FILE__,__LINE__)

#define AllocMem(size,flags)    __rtl_AllocMem(size,flags,__FILE__,__LINE__)
#define FreeMem(adr,size)       __rtl_FreeMem(adr,size,__FILE__,__LINE__)
#define AllocVec(size,flags)    __rtl_AllocVec(size,flags,__FILE__,__LINE__)
#define FreeVec(adr)            __rtl_FreeVec(adr,__FILE__,__LINE__)
#define OpenLibrary(name,ver)   __rtl_OpenLibrary(name,ver,__FILE__,__LINE__)
#define CloseLibrary(lib)       __rtl_CloseLibrary(lib,__FILE__,__LINE__)
#define Allocate(fl,size)       __rtl_Allocate(fl,size,__FILE__,__LINE__)
#define Deallocate(fl,mem,size) __rtl_Deallocate(fl,mem,size,__FILE__,__LINE__)
#define AllocEntry(list)        RTL_DEF1(AllocEntry,list)
#define FreeEntry(list)         RTL_DEF1(FreeEntry,list)
#define CreateMsgPort()         RTL_DEF0(CreateMsgPort)
#define DeleteMsgPort(port)     RTL_DEF1(DeleteMsgPort,port)
#define OpenDevice(dev,unit,ior,flags) RTL_DEF4(OpenDevice,dev,unit,ior,flags)
#define CloseDevice(ior)        RTL_DEF1(CloseDevice,ior)
#define DoIO(ior)               RTL_DEF1(DoIO,ior)
#define SendIO(ior)             RTL_DEF1(SendIO,ior)
#define CheckIO(ior)            RTL_DEF1(CheckIO,ior)
#define WaitIO(ior)             RTL_DEF1(WaitIO,ior)
#define AbortIO(ior)            RTL_DEF1(AbortIO,ior)

/* Graphics */
#define RectFill(rp,x1,y1,x2,y2)    __rtl_RectFill(rp,x1,y1,x2,y2,__FILE__,__LINE__)

#endif /* RTL_INTERN */

/* Flags for StartResourceTracking() */
#define RTL_TRACK	0x00000000	/* track specified resources */
#define RTL_NOTRACK	0x80000000	/* track all but the spec. res. */
#define RTL_CLIB	0x00000001	/* track c.lib */
#define RTL_DOS 	0x00000002	/* track dos calls */
#define RTL_EXEC	0x00000004	/* track exec stuff */

#define RTL_ALL 	0x7FFFFFFF	/* track everything we have */

/* Defines for Prototypes */
#define RTL_PROTO0(ret,name)                                            \
    ret __rtl_ ## name (const char *, int);                             \
    ret NRT_ ## name (void);
#define RTL_PROTO1(ret,name,arg)                                        \
    ret __rtl_ ## name (arg, const char *, int);                        \
    ret NRT_ ## name (arg);
#define RTL_PROTO2(ret,name,arg1,arg2)                                  \
    ret __rtl_ ## name (arg1, arg2, const char *, int);                 \
    ret NRT_ ## name (arg1, arg2);
#define RTL_PROTO3(ret,name,a1,a2,a3)                                   \
    ret __rtl_ ## name (a1,a2,a3, const char *, int);                   \
    ret NRT_ ## name (a1,a2,a3);
#define RTL_PROTO4(ret,name,a1,a2,a3,a4)                                \
    ret __rtl_ ## name (a1,a2,a3,a4, const char *, int);                \
    ret NRT_ ## name (a1,a2,a3,a4);
#define RTL_PROTO5(ret,name,a1,a2,a3,a4,a5)                             \
    ret __rtl_ ## name (a1,a2,a3,a4,a5, const char *, int);             \
    ret NRT_ ## name (a1,a2,a3,a4,a5);


/**************************************
	    Globale Variable
**************************************/


/**************************************
	       Prototypes
**************************************/
extern void StartResourceTracking	(ULONG);
extern void SetResourceTracking 	(ULONG);
extern void PrintTrackedResources	(void);
extern LONG SetResourceTrackingLevel	(LONG);
extern LONG IncResourceTrackingLevel	(void);
extern LONG DecResourceTrackingLevel	(void);
extern void EndResourceTracking 	(void);

/* Prototypes for resource tracking calls */
/* c.lib */

/* DOS */
RTL_PROTO2(BPTR,Open,STRPTR name, long accessMode)
RTL_PROTO1(LONG,Close,BPTR file)
RTL_PROTO2(BPTR,Lock,STRPTR name, long type)
RTL_PROTO1(void,UnLock,BPTR lock)
RTL_PROTO1(BPTR,DupLock,BPTR lock)
RTL_PROTO1(BPTR,CurrentDir,BPTR lock)
RTL_PROTO1(BPTR,CreateDir,STRPTR name)

/* Exec */
RTL_PROTO2(APTR,AllocMem,ULONG size, ULONG flags)
RTL_PROTO2(void,FreeMem,APTR mem, ULONG size)
RTL_PROTO2(APTR,AllocVec,ULONG, ULONG)
RTL_PROTO1(void,FreeVec,APTR)
RTL_PROTO2(struct Library *,OpenLibrary,UBYTE * name, ULONG version)
RTL_PROTO1(void,CloseLibrary,struct Library * library)
RTL_PROTO2(APTR,Allocate,struct MemHeader * freeList, ULONG size)
RTL_PROTO3(void,Deallocate,struct MemHeader * freeList, APTR mem,ULONG size)
RTL_PROTO1(struct MemList *,AllocEntry,struct MemList * list)
RTL_PROTO1(void,FreeEntry,struct MemList * list)
RTL_PROTO0(struct MsgPort *,CreateMsgPort)
RTL_PROTO1(void,DeleteMsgPort,struct MsgPort * mp)
RTL_PROTO4(BYTE,OpenDevice,UBYTE * devName,ULONG unit,struct IORequest *ioRequest, ULONG flags)
RTL_PROTO1(void,CloseDevice,struct IORequest * ioRequest)
RTL_PROTO1(BYTE,DoIO,struct IORequest * ioRequest)
RTL_PROTO1(void,SendIO,struct IORequest * ioRequest)
RTL_PROTO1(struct IORequest *,CheckIO,struct IORequest * ioRequest)
RTL_PROTO1(BYTE,WaitIO,struct IORequest * ioRequest)
RTL_PROTO1(void,AbortIO,struct IORequest * ioRequest)

/* Graphics */
RTL_PROTO5(void,RectFill,struct RastPort * rp, WORD, WORD, WORD, WORD)

# endif /* RESTRACK_H */
#else /* No resource tracking */
#   define NRT_Open	    Open
#   define NRT_Close	    Close
#   define NRT_Lock	    Lock
#   define NRT_UnLock	    UnLock
#   define NRT_DupLock	    DupLock
#   define NRT_CreateDir    CreateDir
#   define NRT_CurrentDir   CurrentDir

#   define NRT_AllocMem     AllocMem
#   define NRT_FreeMem	    FreeMem
#   define NRT_AllocVec     AllocVec
#   define NRT_FreeVec	    FreeVec
#   define NRT_OpenLibrary  OpenLibrary
#   define NRT_CloseLibrary CloseLibrary
#   define NRT_Allocate     Allocate
#   define NRT_Deallocate   Deallocate
#   define NRT_AllocEntry   AllocEntry
#   define NRT_FreeEntry    FreeEntry
#   define NRT_CreateMsgPort CreateMsgPort
#   define NRT_DeleteMsgPort DeleteMsgPort
#   define NRT_OpenDevice   OpenDevice
#   define NRT_CloseDevice  CloseDevice
#   define NRT_DoIO	    DoIO
#   define NRT_SendIO	    SendIO
#   define NRT_CheckIO	    CheckIO
#   define NRT_WaitIO	    WaitIO
#   define NRT_AbortIO	    AbortIO

#   define NRT_RectFill     RectFill

#   define StartResourceTracking(fl)    ;
#   define SetResourceTracking(fl)      ;
#   define PrintTrackedResources	;
#   define EndResourceTracking		;

extern LONG SetResourceTrackingLevel	(LONG);
extern LONG IncResourceTrackingLevel	(void);
extern LONG DecResourceTrackingLevel	(void);

#endif /* RESOURCE_TRACKING */

/******************************************************************************
*****  ENDE restrack.h
******************************************************************************/
