/* :ts=4
 *  $VER: init.c $Revision$ (07-Oct-2018)
 *
 *  This file is part of uuid.
 *
 *  Copyright (c) 2018 Hyperion Entertainment CVBA.
 *  All Rights Reserved.
 *
 * $Id$
 *
 * $Log$
 *
 *
 */


#include <exec/exec.h>
#include <proto/dos.h>
#include <proto/exec.h>
#include <proto/timer.h>
#include <proto/timezone.h>

#include <dos/dos.h>
#include <libraries/uuid.h>
#include <proto/uuid.h>
#include <stdarg.h>

#ifdef __amigaos4__
struct Library *NewlibBase;
struct Interface *INewlib;
struct ExecIFace *IExec;
#endif

struct UtilityBase *UtilityBase;
struct UtilityIFace *IUtility;

struct Library *DOSBase;
struct DOSIFace *IDOS;

struct Library *TimezoneBase;
struct TimezoneIFace *ITimezone;

struct TimerIFace *ITimer;

/* Version Tag */
#include "uuid.library_rev.h"
STATIC CONST UBYTE USED verstag[] = VERSTAG;

struct UuidBase
{
    struct Library libNode;
    BPTR segList;
    /* If you need more data fields, add them here */
    struct TimeRequest *TimerIO;
};

/*
 * The system (and compiler) rely on a symbol named _start which marks
 * the beginning of execution of an ELF file. To prevent others from 
 * executing this library, and to keep the compiler/linker happy, we
 * define an empty _start symbol here.
 *
 * On the classic system (pre-AmigaOS 4.x) this was usually done by
 * moveq #0,d0
 * rts
 *
 */
int32 _start(void);

int32 _start(void)
{
    /* If you feel like it, open DOS and print something to the user */
    return RETURN_FAIL;
}


/* Open the library */
STATIC struct Library *libOpen(struct LibraryManagerInterface *Self, ULONG version)
{
    struct UuidBase *libBase = (struct UuidBase *)Self->Data.LibBase; 

    if (version > VERSION)
    {
        return NULL;
    }

    /* Add any specific open code here 
       Return 0 before incrementing OpenCnt to fail opening */


    /* Add up the open count */
    libBase->libNode.lib_OpenCnt++;
    return (struct Library *)libBase;

}


/* Close the library */
STATIC APTR libClose(struct LibraryManagerInterface *Self)
{
    struct UuidBase *libBase = (struct UuidBase *)Self->Data.LibBase;
    /* Make sure to undo what open did */


    /* Make the close count */
    ((struct Library *)libBase)->lib_OpenCnt--;

    return 0;
}


/* Expunge the library */
STATIC APTR libExpunge(struct LibraryManagerInterface *Self)
{
    /* If your library cannot be expunged, return 0 */
    struct ExecIFace *IExec
        = (struct ExecIFace *)(*(struct ExecBase **)4)->MainInterface;
    APTR result = (APTR)0;
    struct UuidBase *libBase = (struct UuidBase *)Self->Data.LibBase;
    if (libBase->libNode.lib_OpenCnt == 0)
    {
	     result = (APTR)libBase->segList;
        /* Undo what the init code did */

if (!(IExec->CheckIO(libBase->TimerIO)))
{
    IExec->AbortIO(libBase->TimerIO);      /* Ask device to abort any pending requests */
}
 
IExec->WaitIO(libBase->TimerIO);          /* Clean up */

IExec->DropInterface(ITimer); 
IExec->CloseDevice((struct IORequest *)libBase->TimerIO);  /* Close Timer device */
IExec->FreeVec(libBase->TimerIO);

      IExec->DropInterface((struct Interface *)ITimezone);
       IExec->CloseLibrary((struct Library *)TimezoneBase);
       
      IExec->DropInterface((struct Interface *)IUtility);
       IExec->CloseLibrary((struct Library *)UtilityBase);
       
      IExec->DropInterface((struct Interface *)IDOS);
       IExec->CloseLibrary((struct Library *)DOSBase);
       
       IExec->DropInterface((struct Interface *)INewlib);
       IExec->CloseLibrary(NewlibBase);

        IExec->Remove((struct Node *)libBase);
        IExec->DeleteLibrary((struct Library *)libBase);
    }
    else
    {
        result = (APTR)0;
        libBase->libNode.lib_Flags |= LIBF_DELEXP;
    }
    return result;
}

/* The ROMTAG Init Function */
STATIC struct Library *libInit(struct Library *LibraryBase, APTR seglist, struct Interface *exec)
{
    struct UuidBase *libBase = (struct UuidBase *)LibraryBase;
    IExec = (struct ExecIFace *)exec;
    //    struct ExecIFace *IExec UNUSED = (struct ExecIFace *)exec;

    libBase->libNode.lib_Node.ln_Type = NT_LIBRARY;
    libBase->libNode.lib_Node.ln_Pri  = 0;
    libBase->libNode.lib_Node.ln_Name = "uuid.library";
    libBase->libNode.lib_Flags        = LIBF_SUMUSED|LIBF_CHANGED;
    libBase->libNode.lib_Version      = VERSION;
    libBase->libNode.lib_Revision     = REVISION;
    libBase->libNode.lib_IdString     = VSTRING;

    libBase->segList = (BPTR)seglist;

       NewlibBase = IExec->OpenLibrary("newlib.library", 50L);
       if (NewlibBase)
       {
           INewlib = (struct NewlibIFace *)IExec->GetInterface(NewlibBase, 
              "main", 1, NULL);
           if (!INewlib)
               return NULL;
       } else return NULL; 
       
       UtilityBase = IExec->OpenLibrary("utility.library", 50L);
       if (UtilityBase)
       {
           IUtility = (struct UtilityIFace *)IExec->GetInterface(UtilityBase, 
              "main", 1, NULL);
           if (!IUtility)
               return NULL;
       } else return NULL; 

       DOSBase = IExec->OpenLibrary("dos.library", 50L);
       if (DOSBase)
       {
           IDOS = (struct DOSIFace *)IExec->GetInterface(DOSBase, 
              "main", 1, NULL);
           if (!IDOS)
               return NULL;
       } else return NULL; 

       TimezoneBase = IExec->OpenLibrary("timezone.library", 50L);
       if (TimezoneBase)
       {
           ITimezone = (struct TimezoneIFace *)IExec->GetInterface(TimezoneBase, 
              "main", 1, NULL);
           if (!ITimezone)
               return NULL;
       } else return NULL; 

	/* Allocate memory for TimeRequest and TimeVal structures */
	libBase->TimerIO = IExec->AllocVecTags(sizeof(struct TimeRequest),
    		AVT_ClearWithValue, 0,
    		TAG_END);
 
	if (libBase->TimerIO  == NULL) return NULL;

	if(IExec->OpenDevice(TIMERNAME, UNIT_MICROHZ, libBase->TimerIO, 0))
		return NULL;
 
	/* Set up pointers for timer functions */
	struct Library *TimerBase = (struct Library *)libBase->TimerIO->Request.io_Device;
	ITimer = IExec->GetInterface(TimerBase, "main", 1, NULL);
	if(!ITimer) return NULL;

       return (struct Library *)libBase;
}

/* ------------------- Manager Interface ------------------------ */
/* These are generic. Replace if you need more fancy stuff */
STATIC uint32 _manager_Obtain(struct LibraryManagerInterface *Self)
{
	uint32 res;
	__asm__ __volatile__(
	"1:	lwarx	%0,0,%1\n"
	"addic	%0,%0,1\n"
	"stwcx.	%0,0,%1\n"
	"bne-	1b"
	: "=&r" (res)
	: "r" (&Self->Data.RefCount)
	: "cc", "memory");

	return res;
}

STATIC uint32 _manager_Release(struct LibraryManagerInterface *Self)
{
	uint32 res;
	__asm__ __volatile__(
	"1:	lwarx	%0,0,%1\n"
	"addic	%0,%0,-1\n"
	"stwcx.	%0,0,%1\n"
	"bne-	1b"
	: "=&r" (res)
	: "r" (&Self->Data.RefCount)
	: "cc", "memory");

	return res;
}

/* Manager interface vectors */
STATIC CONST APTR lib_manager_vectors[] =
{
	_manager_Obtain,
	_manager_Release,
	NULL,
	NULL,
	libOpen,
	libClose,
	libExpunge,
	NULL,
	(APTR)-1
};

/* "__library" interface tag list */
STATIC CONST struct TagItem lib_managerTags[] =
{
	{ MIT_Name,			(Tag)"__library"		},
	{ MIT_VectorTable,	(Tag)lib_manager_vectors},
	{ MIT_Version,		1						},
	{ TAG_DONE,			0						}
};

/* ------------------- Library Interface(s) ------------------------ */

#include "uuid_vectors.c"

/* Uncomment this line (and see below) if your library has a 68k jump table */
/* extern APTR VecTable68K[]; */

STATIC CONST struct TagItem main_v1_Tags[] =
{
	{ MIT_Name,			(Tag)"main"			},
	{ MIT_VectorTable,	(Tag)main_v1_vectors	},
	{ MIT_Version,		1					},
	{ TAG_DONE,			0					}
};

STATIC CONST CONST_APTR libInterfaces[] =
{
	lib_managerTags,
	main_v1_Tags,
	NULL
};

STATIC CONST struct TagItem libCreateTags[] =
{
	{ CLT_DataSize,		sizeof(struct UuidBase)	},
	{ CLT_InitFunc,		(Tag)libInit			},
	{ CLT_Interfaces,	(Tag)libInterfaces		},
	/* Uncomment the following line if you have a 68k jump table */
	/* { CLT_Vector68K, (Tag)VecTable68K }, */
	{TAG_DONE,		 0 }
};


/* ------------------- ROM Tag ------------------------ */
STATIC CONST struct Resident lib_res USED =
{
	RTC_MATCHWORD,
	(struct Resident *)&lib_res,
	(APTR)(&lib_res + 1),
	RTF_NATIVE|RTF_AUTOINIT, /* Add RTF_COLDSTART if you want to be resident */
	VERSION,
	NT_LIBRARY, /* Make this NT_DEVICE if needed */
	0, /* PRI, usually not needed unless you're resident */
	"uuid.library",
	VSTRING,
	(APTR)libCreateTags
};

