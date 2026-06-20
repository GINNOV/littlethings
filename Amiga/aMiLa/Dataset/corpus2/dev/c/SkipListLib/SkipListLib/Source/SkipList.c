/******************************************************************************
 * SkipList.library - an Amiga shared library for fast random and sequential
 * access sorted lists.  Needs Random250.library for random numbers, needs
 * AmigaDOS 2.04 or later for assorted system libraries.
 *
 * $Header: Big:Programming/C/SkipLists/RCS/SkipList.c,v 1.6 1996/08/19 15:08:15 AGMS Exp $
 *
 * Implemented by Alexander G. M. Smith, Ottawa Canada, agmsmith@achilles.net,
 * agmsmith@bix.com, 71330.3173@compuserve.com, and various other places
 * including the Ottawa Freenet.
 *
 * This code is put into the public domain by AGMS, so you can copy it,
 * hack it up, sell it, and do whatever you want to it.
 *
 * Compile with the GNU C compiler, gcc version 2.7.0, use the command line:
 *    gcc -v -O2 -Wall -nostdlib SkipList.c
 * then rename the a.out file to "skiplist.library".
 *
 * The algorithm was created by, I believe, William Pugh at the University
 * of Maryland USA.  You can read about the algorithm and an analysis of its
 * performance in: William Pugh, Skip Lists: A Probabilistic Alternative to
 * Balanced Trees, Volume 382 of Lecture Notes in Computer Science
 * (proceedings of the Workshop on Algorithms and Data Structures (WADS '89 -
 * I was there as a student volunteer)), pages 437-449, 1989, published by
 * Springer-Verlag, ISBN 3-540-51542-9 or ISBN 0-387-51542-9.
 *
 * He has also published some tech reports at the University of Maryland
 * describing skip lists and there is a note in the bibliography saying he is
 * working on a book called A Skip List Cookbook.
 *
 * $Log: SkipList.c,v $
 * Revision 1.6  1996/08/19  15:08:15  AGMS
 * Added functions for finding and deleting.
 *
 * Revision 1.5  1996/08/17  13:00:24  AGMS
 * Insert is working, but not fully tested.
 *
 * Revision 1.4  1996/08/14  14:35:50  AGMS
 * Init and allocation functions in, ready to start with the guts
 * of the algorithm.  Also added an error display function.
 *
 * Revision 1.3  1996/08/11  13:15:17  AGMS
 * Added prototypes for newly defined library functions, open
 * utility.library as part of initialisation.
 *
 * Revision 1.2  1996/07/30  14:40:08  AGMS
 * Library framework now seems to work.
 *
 * Revision 1.1  1996/07/30  13:27:48  AGMS
 * Initial revision
 */

#define __NOLIBBASE__
#define COMPILE_FOR_SKIPLIST_LIBRARY
#define LIBCALL_DECLARATION extern __inline
#define VERBOSE_CODE 1 /* True for run time error messages. */
#define DEBUGMODE 1 /* True to turn on sanity checking code. */

#ifndef EXEC_LIBRARIES_H
#include "exec/libraries.h"
#endif /* EXEC_LIBRARIES_H */

#ifndef EXEC_RESIDENT_H
#include <exec/resident.h>
#endif /* EXEC_RESIDENT_H */

#include "SkipList.h"


#define VERSION 1     /* Feature set / API version, also library version. */
#define VERSIONQ "1"
#define REVISION 0    /* Bug fix version. */
#define REVISIONQ "0"



/******************************************************************************
 * Special dummy function at the start of the code segment that just returns
 * -1 so that this program doesn't do anything when run, the -1 Makes the CLI
 * return a not-a-program error if you try.  This must come before all the
 * other code and constant data in this file!
 */

LONG DummyStartup (void)
{
  return -1L;
}



/******************************************************************************
 * This is our library base record.  The system will allocate a jump table
 * just before it in memory as well as allocating this record and initialising
 * it to zero.  However, the library pointer still points to the start of this
 * record, meaning that the jump table is accessed with negative offsets.
 */

struct SkipListBaseStruct
{
  struct Library  standardLibrary;  /* The usual standard library fields. */
  APTR            segmentList;      /* So we can unload our code when done. */
  APTR            execBase;         /* For memory allocations etc. */
  APTR            intuitionBase;    /* For error messages etc. */
  APTR            random250Base;    /* For random numbers. */
  APTR            utilityBase;      /* For international string comparisons. */
  BOOL            displayErrors;    /* TRUE if errors are being shown. */
};

typedef struct SkipListBaseStruct SkipListBaseRecord, *SkipListBasePointer;



/******************************************************************************
 * Some structure declataions, copied here and simplified rather than using
 * include files, for extra compile speed (GNU on an A2000 isn't speedy).
 */

struct IntuiText
{
    UBYTE FrontPen, BackPen;    /* the pen numbers for the rendering */
    UBYTE DrawMode;             /* the mode for rendering the text */
    WORD LeftEdge;              /* relative start location for the text */
    WORD TopEdge;               /* relative start location for the text */
    APTR ITextFont;             /* if NULL, you accept the default */
    const UBYTE *IText;         /* pointer to null-terminated text */
    struct IntuiText *NextText; /* pointer to another IntuiText to render */
};

/* drawing modes */
#define JAM1        0         /* jam 1 color into raster */
#define JAM2        1         /* jam 2 colors into raster */
#define COMPLEMENT  2         /* XOR bits into raster */
#define INVERSVID   4         /* inverse video for drawing modes */

/* When you're defining IntuiText for the Positive and Negative Gadgets
 * created by a call to AutoRequest(), these defines will get you
 * reasonable-looking text.  The only field without a define is the IText
 * field; you decide what text goes with the Gadget
 */

#define AUTOFRONTPEN    0
#define AUTOBACKPEN     1
#define AUTODRAWMODE    JAM2
#define AUTOLEFTEDGE    6
#define AUTOTOPEDGE     3
#define AUTOITEXTFONT   NULL
#define AUTONEXTTEXT    NULL

/* Similar values for the body text. */

#define BODYLEFTEDGE    6
#define BODYTOPEDGE     5



/******************************************************************************
 * Here are some library call declarations that have explicit library base
 * pointers, since this program doesn't have normal global variables where the
 * library base pointer would normally go.  You can make these extern if you
 * always compile with the O2 optimise option, then it won't actually have a
 * copy of these stubs in the code since they would be used only inline.
 */

LIBCALL_DECLARATION APTR
AllocMemA6 (unsigned long byteSize, unsigned long requirements, APTR ExecAddr)
{
  register APTR  _res  __asm("d0");
  register APTR a6 __asm("a6") = ExecAddr;
  register unsigned long d0 __asm("d0") = byteSize;
  register unsigned long d1 __asm("d1") = requirements;
  __asm __volatile ("jsr a6@(-0xc6)"
  : "=r" (_res)
  : "r" (a6), "r" (d0), "r" (d1)
  : "a0","a1","d0","d1", "memory");
  return _res;
}

LIBCALL_DECLARATION BOOL
AutoRequestA6 (APTR window, const struct IntuiText *body,
const struct IntuiText *posText, const struct IntuiText *negText,
unsigned long pFlag, unsigned long nFlag, unsigned long width,
unsigned long height, APTR ExecAddr)
{
  register BOOL  _res  __asm("d0");
  register APTR a6 __asm("a6") = ExecAddr;
  register APTR a0 __asm("a0") = window;
  register const struct IntuiText *a1 __asm("a1") = body;
  register const struct IntuiText *a2 __asm("a2") = posText;
  register const struct IntuiText *a3 __asm("a3") = negText;
  register unsigned long d0 __asm("d0") = pFlag;
  register unsigned long d1 __asm("d1") = nFlag;
  register unsigned long d2 __asm("d2") = width;
  register unsigned long d3 __asm("d3") = height;
  __asm __volatile ("jsr a6@(-0x15c)"
  : "=r" (_res)
  : "r" (a6), "r" (a0), "r" (a1), "r" (a2), "r" (a3), "r" (d0), "r" (d1), "r" (d2), "r" (d3)
  : "a0","a1","a2","a3","d0","d1","d2","d3", "memory");
  return _res;
}

LIBCALL_DECLARATION void
CloseLibraryA6 (struct Library *library, APTR ExecAddr)
{
  register APTR a6 __asm("a6") = ExecAddr;
  register struct Library *a1 __asm("a1") = library;
  __asm __volatile ("jsr a6@(-0x19e)"
  : /* no output */
  : "r" (a6), "r" (a1)
  : "a0","a1","d0","d1", "memory");
}

LIBCALL_DECLARATION void DeallocateSkipNodeA6 (SkipListPointer TheList,
SkipNodePointer TheNode, APTR SkipBase)
{
  register SkipListPointer a0 __asm("a0") = TheList;
  register SkipNodePointer a1 __asm("a1") = TheNode;
  register APTR a6 __asm("a6") = SkipBase;
  __asm __volatile ("jsr a6@(-42)"
  :                                 /* Outputs. */
  : "r" (a6), "r" (a0), "r" (a1)    /* Inputs. */
  : "a0","a1","d0","d1", "memory"); /* Changed. */
}

LIBCALL_DECLARATION void
FreeMemA6 (APTR memoryBlock, unsigned long byteSize, APTR ExecAddr)
{
  register APTR a6 __asm("a6") = ExecAddr;
  register APTR a1 __asm("a1") = memoryBlock;
  register unsigned long d0 __asm("d0") = byteSize;
  __asm __volatile ("jsr a6@(-0xd2)"
  : /* no output */
  : "r" (a6), "r" (a1), "r" (d0)
  : "a0","a1","d0","d1", "memory");
}

LIBCALL_DECLARATION ULONG
GenerateRandomLevelNumberA6 (SkipListPointer TheList, APTR SkipBase)
{
  register ULONG _res __asm("d0");
  register SkipListPointer a0 __asm("a0") = TheList;
  register APTR a6 __asm("a6") = SkipBase;
  __asm __volatile ("jsr a6@(-90)"
  : "=r" (_res)                     /* Outputs. */
  : "r" (a6), "r" (a0)              /* Inputs. */
  : "a0","a1","d0","d1", "memory"); /* Changed. */
  return _res;
}

LIBCALL_DECLARATION void InitSkipListA6 (SkipListPointer TheList, APTR SkipBase)
{
  register SkipListPointer a0 __asm("a0") = TheList;
  register APTR a6 __asm("a6") = SkipBase;
  __asm __volatile ("jsr a6@(-30)"
  :                                 /* Outputs. */
  : "r" (a6), "r" (a0)              /* Inputs. */
  : "a0","a1","d0","d1", "memory"   /* Changed things. */);
}

LIBCALL_DECLARATION struct Library *
OpenLibraryA6 (UBYTE *libName, unsigned long version, APTR ExecAddr)
{
  register struct Library * _res  __asm("d0");
  register APTR a6 __asm("a6") = ExecAddr;
  register UBYTE *a1 __asm("a1") = libName;
  register unsigned long d0 __asm("d0") = version;
  __asm __volatile ("jsr a6@(-0x228)"
  : "=r" (_res)
  : "r" (a6), "r" (a1), "r" (d0)
  : "a0","a1","d0","d1", "memory");
  return _res;
}

LIBCALL_DECLARATION void
Random250ArrayA6 (unsigned long ArrayLongWordSize,
unsigned long *ArrayPointer, APTR R250Base)
{
  register APTR a6 __asm("a6") = R250Base;
  register unsigned long d0 __asm("d0") = ArrayLongWordSize;
  register unsigned long *a0 __asm("a0") = ArrayPointer;
  __asm __volatile ("jsr a6@(-36)"
  : /* no output */
  : "r" (a6), "r" (a0), "r" (d0)
  : "a0","a1","d0","d1","memory");
}

LIBCALL_DECLARATION unsigned long
Random250LongA6 (APTR R250Base)
{
  register LONG _res __asm("d0");
  register APTR a6 __asm("a6") = R250Base;
  __asm __volatile ("jsr a6@(-30)"
  : "=r" (_res)
  : "r" (a6)
  : "a0","a1","d0","d1", "memory");
  return _res;
}

LIBCALL_DECLARATION void
RemoveA6 (struct Node *node, APTR ExecAddr)
{
  register APTR a6 __asm("a6") = ExecAddr;
  register struct Node *a1 __asm("a1") = node;
  __asm __volatile ("jsr a6@(-0xfc)"
  : /* no output */
  : "r" (a6), "r" (a1)
  : "a0","a1","d0","d1", "memory");
}

LIBCALL_DECLARATION SkipNodePointer RemoveSkipNodeA6 (SkipListPointer TheList,
SkipNodePointer TheNode, APTR SkipBase)
{
  register SkipNodePointer _res __asm("d0");
  register SkipListPointer a0 __asm("a0") = TheList;
  register SkipNodePointer a1 __asm("a1") = TheNode;
  register APTR a6 __asm("a6") = SkipBase;
  __asm __volatile ("jsr a6@(-54)"
  : "=r" (_res)                     /* Outputs. */
  : "r" (a6), "r" (a0), "r" (a1)    /* Inputs. */
  : "a0","a1","d0","d1", "memory"); /* Changed. */
  return _res;
}

LIBCALL_DECLARATION LONG
StrnicmpA6 (STRPTR string1, STRPTR string2, long length, APTR UtilityAddr)
{
  register LONG  _res  __asm("d0");
  register APTR a6 __asm("a6") = UtilityAddr;
  register STRPTR a0 __asm("a0") = string1;
  register STRPTR a1 __asm("a1") = string2;
  register long d0 __asm("d0") = length;
  __asm __volatile ("jsr a6@(-0xa8)"
  : "=r" (_res)
  : "r" (a6), "r" (a0), "r" (a1), "r" (d0)
  : "a0","a1","d0","d1", "memory");
  return _res;
}



/******************************************************************************
 * Forward declarations.
 */

static SkipListBasePointer InitialiseSkipListLibrary (void);
static SkipListBasePointer OpenSkipListLibrary (void);
static APTR CloseSkipListLibrary (void);
static APTR ExpungeSkipListLibrary (void);
static LONG ReservedFunction (void);
static void InitSkipList (void);
static SkipNodePointer AllocateSkipNode (void);
static void DeallocateSkipNode (void);
static SkipNodePointer InsertSkipNode (void);
static SkipNodePointer RemoveSkipNode (void);
static ULONG DeleteSkipNode (void);
static void DeleteAllSkipNodes (void);
static SkipNodePointer FindSkipNode (void);
static SkipNodePointer FindBelowSkipNode (void);
static SkipNodePointer FindAboveOrEqualSkipNode (void);
static ULONG GenerateRandomLevelNumber (void);
static ULONG GetRANDOMCACHESIZE (void);
static ULONG GetSKIPLISTLEVELCAP (void);
static void EndOfCode (void);



/******************************************************************************
 * Version strings, here since they need to be before the ROMTag.
 */

static const char LibraryName [] = "skiplist.library";

static const char LibraryID [] = "skiplist " VERSIONQ "." REVISIONQ " ("
__DATE__ ") "
#if DEBUGMODE
  "(Debug) "
#else
  "(Fast) "
#endif
#if VERBOSE_CODE
"(Verbose) "
#else
"(Silent) "
#endif
"(By AGMSmith)\r\n";

#if VERBOSE_CODE
static const char AuthorString [] =
"\n\n$Id: SkipList.c,v 1.6 1996/08/19 15:08:15 AGMS Exp $\n"
"Public domain 1996 by Alexander G. M. Smith, all rights unreserved.\n"
"Algorithm by William Pugh at the University of Maryland USA.\n"
"Send questions to agmsmith@achilles.net, agmsmith@bix.com,\n"
"au829@freenet.carleton.ca and 71330.3173@CompuServe.com\n\n";
#endif



/******************************************************************************
 * Various error messages.
 */

static const char MissingR250String [] =
"Sorry, skiplist.library can't open random250.library";

static const struct IntuiText MissingR250IText =
{
  AUTOFRONTPEN,
  AUTOBACKPEN,
  AUTODRAWMODE,
  BODYLEFTEDGE,
  BODYTOPEDGE,
  AUTOITEXTFONT,
  MissingR250String, /* Message string */
  AUTONEXTTEXT
};


static const char MissingUtilityString [] =
"Sorry, skiplist.library can't open utility.library V37";

static const struct IntuiText MissingUtilityIText =
{
  AUTOFRONTPEN,
  AUTOBACKPEN,
  AUTODRAWMODE,
  BODYLEFTEDGE,
  BODYTOPEDGE,
  AUTOITEXTFONT,
  MissingUtilityString, /* Message string */
  AUTONEXTTEXT
};


static const char CancelString [] = "Cancel";

static const struct IntuiText CancelIText =
{
  AUTOFRONTPEN,
  AUTOBACKPEN,
  AUTODRAWMODE,
  AUTOLEFTEDGE,
  AUTOTOPEDGE,
  AUTOITEXTFONT,
  CancelString, /* Message string */
  AUTONEXTTEXT
};


static const char OKString [] = "OK";

static const struct IntuiText OKIText =
{
  AUTOFRONTPEN,
  AUTOBACKPEN,
  AUTODRAWMODE,
  AUTOLEFTEDGE,
  AUTOTOPEDGE,
  AUTOITEXTFONT,
  OKString, /* Message string */
  AUTONEXTTEXT
};



/******************************************************************************
 * List of the functions that the OS will place into the jump table.
 */

static void * const LibraryFunctionsList [] =
{                               /* Library offset decimal value */
  OpenSkipListLibrary,
  CloseSkipListLibrary,
  ExpungeSkipListLibrary,
  ReservedFunction,
  InitSkipList,                 /*  -30 */
  AllocateSkipNode,             /*  -36 */
  DeallocateSkipNode,           /*  -42 */
  InsertSkipNode,               /*  -48 */
  RemoveSkipNode,               /*  -54 */
  DeleteSkipNode,               /*  -60 */
  DeleteAllSkipNodes,           /*  -66 */
  FindSkipNode,                 /*  -72 */
  FindBelowSkipNode,            /*  -78 */
  FindAboveOrEqualSkipNode,     /*  -84 */
  GenerateRandomLevelNumber,    /*  -90 */
  GetRANDOMCACHESIZE,           /*  -96 */
  GetSKIPLISTLEVELCAP,          /* -102 */
  (void *) -1  /* Marks end of list. */
};



/******************************************************************************
 * Library initialisation table, used by the OS to build the library base
 * record.
 */

static void * const LibraryInitTable [4] =
{
  (void *) sizeof (SkipListBaseRecord), /* Library base structure size. */
  (void *) LibraryFunctionsList,/* Function list for making jump table from. */
  NULL,                         /* No special InitStruct data, */
  InitialiseSkipListLibrary     /* instead our init function does it all. */
};



/******************************************************************************
 * Here we have the famous ROMTag structure that the library loader will
 * search through the code segment to find and will use to initialise the
 * library.
 */

static const struct Resident SkipListROMTag =
{
  RTC_MATCHWORD,        /* Magic number identifying a ROMTag. */
  (struct Resident *) &SkipListROMTag, /* Pointer to self, magic ID stuff. */
  EndOfCode,            /* Pointer to end of this ROM section.  For CRC? */
  RTF_AUTOINIT,         /* Various flags. */
  VERSION,              /* Main version number.  API version in essence. */
  NT_LIBRARY,           /* This is a library kind of thing. */
  0,                    /* Priority in system library list? */
  (char *) LibraryName, /* Points to name string. */
  (char *) LibraryID,   /* Points to ID (readable version) string. */
  (APTR) LibraryInitTable /* Table of pointers to init code and data sizes. */
};



/******************************************************************************
 * Deallocate the stuff allocated by this library and close sublibraries.
 * Assumes that the library base record isn't linked into any system lists,
 * since it is freed here.
 */

static void DeallocateStuff (SkipListBasePointer OurBase)
{
  register APTR TempExecBase __asm("a6");

  TempExecBase = *((void **) 4); /* Get standard execbase address. */

  if (OurBase->intuitionBase != NULL)
  {
    CloseLibraryA6 (OurBase->intuitionBase, TempExecBase);
    OurBase->intuitionBase = NULL;
  }

  if (OurBase->random250Base != NULL)
  {
    CloseLibraryA6 (OurBase->random250Base, TempExecBase);
    OurBase->random250Base = NULL;
  }

  if (OurBase->utilityBase != NULL)
  {
    CloseLibraryA6 (OurBase->utilityBase, TempExecBase);
    OurBase->utilityBase = NULL;
  }

  if (OurBase->execBase != NULL)
  {
    CloseLibraryA6 (OurBase->execBase, TempExecBase);
    OurBase->execBase = NULL;
  }

  /* Finally free our library base record. */

  FreeMemA6 (((UBYTE *) OurBase) - OurBase->standardLibrary.lib_NegSize,
  OurBase->standardLibrary.lib_NegSize + OurBase->standardLibrary.lib_PosSize,
  TempExecBase);
}



/******************************************************************************
 * Library has just been allocated, library base pointer in D0, segment list
 * pointer in A0, execbase in A6.  System is in a Forbid (non-multitasking)
 * state.  Returns zero in D0 on failure, returns library base address if
 * successful (will make system add the library to the loaded libraries list).
 */

static SkipListBasePointer InitialiseSkipListLibrary (void)
{
  register ULONG  d0 __asm("d0");
  register APTR   a0 __asm("a0");
  register APTR   a6 __asm("a6");

  APTR SegmentList = a0;
  SkipListBasePointer NewBase = (void *) d0;

  NewBase->segmentList = SegmentList;
  NewBase->standardLibrary.lib_Node.ln_Type = NT_LIBRARY;
  NewBase->standardLibrary.lib_Node.ln_Name = (char *) LibraryName;
  NewBase->standardLibrary.lib_Flags = LIBF_SUMUSED | LIBF_CHANGED;
  NewBase->standardLibrary.lib_Version = VERSION;
  NewBase->standardLibrary.lib_Revision = REVISION;
  NewBase->standardLibrary.lib_IdString = (APTR) LibraryID;
  NewBase->displayErrors = TRUE;

  while (TRUE)
  {
    /* Open intuition.library (any version, so it works under AmigaDOS 1.3
       too), just in case we need to display error messages. */

    NewBase->intuitionBase = OpenLibraryA6 ("intuition.library", 0, a6);
    if (NewBase->intuitionBase == NULL)
      break;

    /* We need the utility library for string comparisons.  Version 37 is the
       earliest one that has them. */

    NewBase->utilityBase = OpenLibraryA6 ("utility.library", 37, a6);
    if (NewBase->utilityBase == NULL)
    {
      /* Display an error message. */

      AutoRequestA6 (NULL, &MissingUtilityIText, NULL,
      &CancelIText, 0, 0, 512 /* width */, 60 /* height */,
      NewBase->intuitionBase);

      break;
    }

    /* We need the random number library. */

    NewBase->random250Base = OpenLibraryA6 ("random250.library", 0, a6);
    if (NewBase->random250Base == NULL)
    {
      /* Display an error message. */

      AutoRequestA6 (NULL, &MissingR250IText, NULL,
      &CancelIText, 0, 0, 512 /* width */, 60 /* height */,
      NewBase->intuitionBase);

      break;
    }

    /* And our copy of Execbase. */

    NewBase->execBase = OpenLibraryA6 ("exec.library", 0, a6);
    if (NewBase->execBase == NULL)
      break;

    return NewBase;  /* Success! */
  }

  DeallocateStuff (NewBase);
  return 0;  /* Failure. */
}



/******************************************************************************
 * Our library base is in A6.  Return 0 if we can't handle another instance of
 * this library being opened, else return the library base if successful.  The
 * system is in a forbid state.  Turns off the delayed expunge state.
 */

static SkipListBasePointer OpenSkipListLibrary (void)
{
  register APTR a6 __asm("a6");

  SkipListBasePointer OurBase = a6;

  OurBase->standardLibrary.lib_OpenCnt++;
  OurBase->standardLibrary.lib_Flags &= ~LIBF_DELEXP;

  return OurBase;
}



/******************************************************************************
 * Close the library.  Decrement the open count, but never let it go below
 * zero (unsigned int).  Returns the segment list if the library is expunged
 * as a side effect of the close, otherwise just returns zero.
 */

static APTR CloseSkipListLibrary (void)
{
  register APTR a6 __asm("a6");

  SkipListBasePointer OurBase = a6;

  if (OurBase->standardLibrary.lib_OpenCnt > 0)
    OurBase->standardLibrary.lib_OpenCnt -= 1;

  if (OurBase->standardLibrary.lib_OpenCnt == 0 &&
  (OurBase->standardLibrary.lib_Flags & LIBF_DELEXP))
  {
    /* A delayed expunge has been requested. */

    a6 = OurBase;
    return ExpungeSkipListLibrary ();
  }

  return NULL;
}



/******************************************************************************
 * Deallocate this library's data if nobody is using it.  If it is in use, do
 * a delayed expunge later when nobody is using the library.  Returns the
 * segment list if the library was deallocated, zero if still in use.  The
 * usual Forbid is in progress, and this can also be called by the OS memory
 * routines so don't do Wait or other things.  This can also be called by
 * RemLibrary so that call can't be used.
 */

static APTR ExpungeSkipListLibrary (void)
{
  register APTR a6 __asm("a6");

  APTR                ExecBase;
  SkipListBasePointer OurBase = a6;
  APTR                SegmentList;

  if (OurBase->standardLibrary.lib_OpenCnt > 0)
  {
    /* If can't do an expunge now, do it later when the last user
       has exited from the library. */

    OurBase->standardLibrary.lib_Flags |= LIBF_DELEXP;
    return NULL;
  }

  SegmentList = OurBase->segmentList;

  /* Remove this library's node from the system library list. */

  ExecBase = OurBase->execBase;
  RemoveA6 (&OurBase->standardLibrary.lib_Node, ExecBase);

  DeallocateStuff (OurBase);

  return SegmentList;
}



/******************************************************************************
 * A special function that just returns zero.  Used for a reserved-for-future-
 * use function entry in the library jump table.
 */

static LONG ReservedFunction (void)
{
  return 0;
}



#if VERBOSE_CODE
/******************************************************************************
 * Our runtime error message display function.  If the user hits Cancel, no
 * more messages will be displayed until the library is flushed from memory.
 */

static void DisplayErrorMessage (const char *ErrorMessage,
SkipListBasePointer OurBase)
{
  struct IntuiText ErrorIText;
  struct IntuiText ExplainingIText;
  BOOL OKHit;

  if (OurBase->displayErrors)
  {
    ErrorIText.FrontPen = AUTOFRONTPEN;
    ErrorIText.BackPen = AUTOBACKPEN;
    ErrorIText.DrawMode = AUTODRAWMODE;
    ErrorIText.LeftEdge = BODYLEFTEDGE;
    ErrorIText.TopEdge = BODYTOPEDGE;
    ErrorIText.ITextFont = AUTOITEXTFONT;
    ErrorIText.IText = ErrorMessage;
    ErrorIText.NextText = &ExplainingIText;

    ExplainingIText.FrontPen = AUTOFRONTPEN;
    ExplainingIText.BackPen = AUTOBACKPEN;
    ExplainingIText.DrawMode = AUTODRAWMODE;
    ExplainingIText.LeftEdge = BODYLEFTEDGE;
    ExplainingIText.TopEdge = BODYTOPEDGE + 12;
    ExplainingIText.ITextFont = AUTOITEXTFONT;
    ExplainingIText.IText = "Continue showing skiplist.library error messages?";
    ExplainingIText.NextText = NULL;

    OKHit = AutoRequestA6 (NULL, &ErrorIText, &OKIText, &CancelIText, 0, 0,
    512 /* width */, 80 /* height */, OurBase->intuitionBase);

    if (!OKHit) /* Cancel selected.  Stop showing errors. */
      OurBase->displayErrors = FALSE;
  }
}
#endif



/******************************************************************************
 * This function initialises a skip list record (you provide a pointer to an
 * allocated SkipListRecord) to an empty list state.  It is always successful.
 * Don't do it to an already initialised skip list, otherwise you'll lose the
 * memory that was allocated for its nodes.  You must call this function
 * before using the other skip list functions on that list.  Remember to set
 * the function pointer fields (usually compareUserData and maybe
 * destroyUserData) immediately after calling this function.
 */

static void InitSkipList (void)
{
  register SkipListPointer a0 __asm("a0");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipListBasePointer OurBase = a6;

  int i;

#if DEBUGMODE
  if (TheList == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("TheList is NULL in InitSkipList.", OurBase);
    #endif
    return;
  }
#endif

  for (i = SKIPLISTLEVELCAP - 1; i >= 0; i--)
    TheList->levelPointers [i] = NULL;

  TheList->activeLevels = 1;
  TheList->filler = 0;
  TheList->size = 0;
  TheList->nextSizeUp = 4;
  TheList->nextSizeDown = 0;
  TheList->destroyUserData = NULL;
  TheList->compareUserData = NULL;
  TheList->randomIndex = RANDOMCACHESIZE-1;
  Random250ArrayA6 (RANDOMCACHESIZE, TheList->randomCache,
  OurBase->random250Base);
}



/******************************************************************************
 * Allocate a new SkipNode record, returns a pointer to the record or NULL if
 * it fails.  The UserRecordSize is the size of your record (structure in C
 * talk), which includes a SkipNodeRecord at the very front.  Maximum size is
 * almost 16 megabytes.  The actual memory allocated is a bit larger, for a
 * randomly sized hidden array of pointers before your record in memory.
 * TheList is an existing list which is only used for its cache of random
 * numbers (so it doesn't have to be the same as the list the new SkipNode
 * will be eventually added to).  TheList can also be NULL, which makes it
 * slightly slower.  MemoryFlags specify which kind of memory to allocate, see
 * exec/memory.h for the various types (or just use MEMF_ANY or 0 if you don't
 * care). Your new record will have its SkipNode fields initialised.  If you
 * include the MEMF_CLEAR flag then the user data area will be cleared to
 * zero.
 */

static SkipNodePointer AllocateSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register ULONG d0 __asm("d0");
  register ULONG d1 __asm("d1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  ULONG UserRecordSize = d0;
  ULONG MemoryFlags = d1;
  SkipListBasePointer OurBase = a6;

  int i;
  int Levels;
  UBYTE *MemoryBytePointer;
  SkipNodePointer NewNode;
  SkipNodePointerPointer NewPointerArray;

#if DEBUGMODE
  /* The user's record size has to contain at least a SkipNodeRecord and fit
     within 24 bits.  Note that we don't care if TheList is NULL, it will just
     be slower without the random number cache from it. */

  if (UserRecordSize < sizeof (SkipNodeRecord) || UserRecordSize >= 0x1000000)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("UserRecordSize is bad in AllocateSkipNode.",
    OurBase);
    #endif
    return NULL;
  }
#endif

  /* Generate the number of level pointers this node will have. */

  Levels = GenerateRandomLevelNumberA6 (TheList, OurBase);

  /* Allocate memory for the hidden array combined with the user's record. */

  MemoryBytePointer = AllocMemA6 (UserRecordSize + (Levels - 1) * sizeof
  (SkipNodePointer), MemoryFlags, OurBase->execBase);

  if (MemoryBytePointer == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Ran out of memory in AllocateSkipNode.", OurBase);
    #endif
    return NULL;
  }

  NewNode = (SkipNodePointer) (MemoryBytePointer +
  (Levels - 1) * sizeof (SkipNodePointer));

  /* Zero out the variable sized pointer array. */

  NewPointerArray = &NewNode->next;
  for (i = 0; i < Levels; i++)
    *NewPointerArray-- = NULL;

  /* Set composite size field.  Assumes this is running on a big endian
     processor so that the high byte comes first and falls into the nodeLevel
     field. */

  NewNode->size.asLong = (Levels << 24) | UserRecordSize;

  return NewNode;
}



/******************************************************************************
 * This function deallocates the memory used by a SkipNode.  If the
 * destroyUserData function in TheList is NULL or it returns non-zero
 * (preferably 1) when called, then the memory is deallocated (including the
 * hidden array before the SkipNode).  If destroyUserData returns zero, no
 * deallocation is done (useful for situations where you are allocating memory
 * in a nonstandard way).
 */

static void DeallocateSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  int Levels;
  UBYTE *MemoryBytePointer;
  int UserRecordSize;

#if DEBUGMODE
  if (TheList == NULL || TheNode == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList or TheNode in DeallocateSkipNode.",
    OurBase);
    #endif
    return;
  }
#endif

  /* Assume big endian byte ordering here. */

  UserRecordSize = TheNode->size.asLong & 0xFFFFFF;

  Levels = TheNode->size.asBytes.nodeLevel;

#if DEBUGMODE
  if (Levels < 1 || Levels > SKIPLISTLEVELCAP ||
  UserRecordSize < sizeof (SkipNodeRecord))
  {
    #if VERBOSE_CODE
    DisplayErrorMessage (
    "TheNode is corrupt (already deallocated?) in DeallocateSkipNode.",
    OurBase);
    #endif
    return; /* This isn't a valid node. */
  }
#endif

  /* Do the user provided cleanup function. */

  if (TheList->destroyUserData != NULL &&
  TheList->destroyUserData (TheNode) == 0)
    return;  /* The user doesn't want this node deallocated by us. */

#if DEBUGMODE
  /* Mark node as invalid so that future attempts to deallocate it are
     detected and reported as a corrupt node.  Well, actually FreeMem writes
    over this with something that looks like the size of the freed block,
    which is also detected as invalid if it is <16M.  Well, at least for level
    1 nodes.  It also puts a pointer in the next field of level 1 blocks.  See
    the MemChunk structure in exec/memory.h for a clue. */

  TheNode->size.asLong = 0;
#endif

  /* Finally, deallocate the memory used by the node. */

  MemoryBytePointer = (void *) TheNode;
  MemoryBytePointer -= (Levels - 1) * sizeof (SkipNodePointer);

  FreeMemA6 (MemoryBytePointer, UserRecordSize +
  (Levels - 1) * sizeof (SkipNodePointer), OurBase->execBase);
}



/******************************************************************************
 * A little internal function for comparing two SkipNodes as strings.  Uses
 * the utility.library string comparison function to handle international
 * character sets.  Returns <0 if A<B, returns 0 if A==B, returns >0 if A>B.
 */

static LONG CompareNodesAsStrings (SkipNodePointer A, SkipNodePointer B,
SkipListBasePointer OurBase)
{
  LONG ComparisonResult;
  int ShortestLength;
  int TempLength;
  ULONG TwentyFourBitMask = 0xFFFFFF;

  ShortestLength = A->size.asLong & TwentyFourBitMask;
  TempLength = B->size.asLong & TwentyFourBitMask;
  if (TempLength < ShortestLength)
    ShortestLength = TempLength;

  if (ShortestLength <= 0)
    ComparisonResult = 0;
  else /* Compare the data immediately after the SkipNodeRecord core. */
    ComparisonResult = StrnicmpA6 (
    ((char *) A) + sizeof (SkipNodeRecord),
    ((char *) B) + sizeof (SkipNodeRecord),
    ShortestLength, OurBase->utilityBase);

  return ComparisonResult;
}



/******************************************************************************
 * An internal function that bumps up or down the number of active levels in a
 * list.  It also has to rethread the nodes that use a newly activated level.
 */

static void UpdateListActiveLevels (SkipListPointer TheList,
SkipListBasePointer OurBase)
{
  SkipNodePointer CurrentNode;
  int NewLevel;
  int PreviousLevel;
  SkipNodePointerPointer PointerToUpdate;
  ULONG TempULong;

  PreviousLevel = TheList->activeLevels;

#if DEBUGMODE
  if (PreviousLevel <= 0 || PreviousLevel > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Corrupt list header in UpdateListActiveLevels.",
    OurBase);
    #endif
    return;
  }
#endif

  /* Compute the desired level based on the current list size.  Essentially do
     logarithm base 4 of the size, but not quite. */

  NewLevel = 0;
  TempULong = TheList->size;
  while (TempULong != 0)
  {
    ++NewLevel;
    TempULong >>= 2;
  }
  if (NewLevel <= 0)
    NewLevel = 1; /* Special case for size zero lists. */

  if (NewLevel > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Maximum level reached "
    "(list will be inefficient) in UpdateListActiveLevels.", OurBase);
    #endif
    NewLevel = SKIPLISTLEVELCAP;
  }

#if DEBUGMODE
  /* Can only go up one level at a time. */

  if (NewLevel > PreviousLevel + 1)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Bug?  Want to go up more than one level "
    "in UpdateListActiveLevels.", OurBase);
    #endif
    NewLevel = PreviousLevel + 1;
  }
#endif

  if (NewLevel == PreviousLevel + 1)  /* If actually going up. */
  {
    /* Do the rethreading on the new level, iterating through the previous
       level the old highest level) of pointers to find nodes that protude
       into the new level (about 1 in 4 should). */

    PointerToUpdate =
    &TheList->levelPointers [SKIPLISTLEVELCAP - NewLevel];

    CurrentNode = TheList->levelPointers [SKIPLISTLEVELCAP - PreviousLevel];

    while (CurrentNode != NULL)
    {
      if (CurrentNode->size.asBytes.nodeLevel >= NewLevel)
      {
        *PointerToUpdate = CurrentNode;
        PointerToUpdate = (&CurrentNode->next) + 1 - NewLevel;
      }
      CurrentNode = ((&CurrentNode->next) + 1) [-PreviousLevel];
    }
    *PointerToUpdate = NULL;
  }

  TheList->activeLevels = NewLevel;

  TempULong = 1 << (NewLevel * 2);
  if (TempULong == 0) /* Did it overflow? */
    TempULong = ~0L; /* Peg at largest ULONG. */
  TheList->nextSizeUp = TempULong;

  TempULong = 1 << ((NewLevel - 1) * 2);
  if (TempULong == 1)
    TempULong = 0; /* Special range extension for empty lists. */
  TheList->nextSizeDown = TempULong;
}



/******************************************************************************
 * Adds the given node to the given list.  If there is an existing node with
 * an equal value then it will be deleted (removed and deallocated) before
 * this one is added.  Presumably TheNode has been allocated by
 * AllocateSkipNode or an equivalent user function that has set the nodeLevel
 * and allocated a hidden array.  Returns the node prior to the inserted node
 * in the list, or NULL if the inserted one is the first in the list (useful
 * for implementing previous node pointers).  Always succeeds (you've already
 * allocated the memory for the node so there isn't anything that normally can
 * go wrong).  Don't insert a node that is already in some other list, that
 * would corrupt the other list badly.
 *
 * If you have to have data simultaneously in several lists, you need to have
 * a SkipNodeRecord for each list.  An easy way is to create a bunch of
 * SkipNodeRecords with the user data portion just containing a pointer to
 * your actual data.  If you want to get tricky and do everything in one
 * record, you can create a variable sized user data record that contains
 * custom allocated SkipNodeRecords and their associated hidden pointer arrays
 * following it in memory.  You would also need a custom destroyUserData
 * function to avoid incorrect deallocations.  As well, you would need to use
 * GenerateRandomLevelNumber to generate random sized SkipNodeRecords within
 * your variable data record.  Alternatively you can waste memory and have a
 * fixed size record by using SKIPLISTLEVELCAP for the hidden array size (but
 * remember to still specify a proper random level number in the nodeLevel
 * fields).
 */

static SkipNodePointer InsertSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  short AddressOffset;
  LONG ComparisonResult;
  SkipNodePointer CurrentNode;
  UBYTE MinimumLevel;
  SkipNodePointer NextNode;
  SkipNodePointer NodesToUpdate [SKIPLISTLEVELCAP];
  SkipNodePointer PreviousNode;

#if DEBUGMODE
  if (TheList == NULL || TheNode == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList or TheNode in InsertSkipNode.",
    OurBase);
    #endif
    return NULL;
  }
#endif

#if DEBUGMODE
  if (TheList->activeLevels <= 0 || TheList->activeLevels > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Corrupt TheList header in InsertSkipNode.", OurBase);
    #endif
    return NULL;
  }
#endif

  /* Start off at the list header, treating it like a fake node. */

  CurrentNode = (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];

  /* This outer loop scans down the levels of pointers (starting at the
     sparsest list) until we get to the bottom (the list with all nodes).  The
     AddressOffset hack is used to get the node's LevelPointers[] entry
     quickly for several nodes with the same level index value (yup, negative
     indices for a backwards array).  The general idea is to fill up
     NodesToUpdate with the node at each level that is just before the new
     node in sort order. */

  AddressOffset = -(TheList->activeLevels * sizeof (SkipNodePointer));
  while (AddressOffset < 0)
  {
    AddressOffset += sizeof (SkipNodePointer);

    /* Scan right along this pointer level until we hit the largest node less
       than (as defined by the user's comparison function) the one we want to
       insert. */

    while (TRUE)
    {
      /* Get the pointer to the next node at the current level.  This mess
         boils down to one M68000 instruction, vs having extra shifts and
         other operations if we used PointerArray[-i]. */

      NextNode = * (SkipNodePointerPointer)
      (((char *) &CurrentNode->next) + AddressOffset);

      if (NextNode == NULL)
        break; /* Hit end of this level.  Go to next level. */

      /* Compare the node being searched for and the next node.  Use the user's
         comparison function or if none, use a string comparison. */

      if (TheList->compareUserData == NULL)
        ComparisonResult = CompareNodesAsStrings (NextNode, TheNode, OurBase);
      else
        ComparisonResult = TheList->compareUserData (NextNode, TheNode);

      if (ComparisonResult >= 0)
        break; /* Reached a node greater or equal to the new one. */

      CurrentNode = NextNode; /* Scan along the same level some more. */
    }

    /* Store away the node we stopped at on this level in the NodesToUpdate
       array, again in backwards array order.  This node is the one which will
       be just before the new one on this level.  Of course, the new one may
       or may not be tall enough to actually be on this level. */

    *(SkipNodePointerPointer)
    (((char *) (&NodesToUpdate[SKIPLISTLEVELCAP-1])) + AddressOffset) =
    CurrentNode;
  }

  /* Ok, move CurrentNode forwards one, to the node which is greater than or
     equal to the new node's sort key.  Or NULL if at the end of the list. */

  CurrentNode = CurrentNode->next;

  /* See if this equal or larger node is equal to the new one.  If it is,
     it has to be deleted before the new one is inserted. */

  if (CurrentNode != NULL)
  {
    if (TheList->compareUserData == NULL)
      ComparisonResult = CompareNodesAsStrings (CurrentNode, TheNode, OurBase);
    else
      ComparisonResult = TheList->compareUserData (CurrentNode, TheNode);

    if (ComparisonResult == 0)
    {
      /* Oh, oh.  Have to delete the current node.  Patch up the pointers that
         used to point to this old node to point around it to the appropriate
         next ones.  We have several levels of pointers to fix up (the loop
         goes from the top level used by the dead node to the bottom level). */

      MinimumLevel = CurrentNode->size.asBytes.nodeLevel;
      if (TheList->activeLevels < MinimumLevel)
        MinimumLevel = TheList->activeLevels;

      AddressOffset = -(MinimumLevel * sizeof (SkipNodePointer));
      while (AddressOffset < 0)
      {
        AddressOffset += sizeof (SkipNodePointer);

        /* Get the address of the node to fix up.  It's the one just before
           the current node, in the level of pointers being fixed. */

        PreviousNode = *(SkipNodePointerPointer)
        (((char *) (&NodesToUpdate[SKIPLISTLEVELCAP-1])) + AddressOffset);

        /* Replace the next pointer at the current level in the previous node
           with the next pointer at the same level in the dead node. */

        *(SkipNodePointerPointer)
        (((char *) &PreviousNode->next) + AddressOffset) =
        *(SkipNodePointerPointer)
        (((char *) &CurrentNode->next) + AddressOffset);
      }

      /* Dispose of the dead node.  Don't need to update the list size related
         values here since the list will end up with the same size as it had
         before (this removal and the insert cancel out). */

      --TheList->size;
      CurrentNode->next = NULL; /* So user doesn't use it accidentally. */
      DeallocateSkipNodeA6 (TheList, CurrentNode, OurBase);
    }
  }

  /* Duplicates have been removed, now insert the node.  Wheeee!  The level
     pointers for the previous nodes that are in levels above the new node
     just go over its top level, so they don't change.  The ones on the same
     levels have to be patched, in traditional linked list fashion. */

  MinimumLevel = TheNode->size.asBytes.nodeLevel;
  if (TheList->activeLevels < MinimumLevel)
    MinimumLevel = TheList->activeLevels;

  AddressOffset = -(MinimumLevel * sizeof (SkipNodePointer));
  while (AddressOffset < 0)
  {
    AddressOffset += sizeof (SkipNodePointer);

    /* Get the address of the node to fix up.  It's the one just before
       the new node, in the level of pointers being fixed. */

    PreviousNode = *(SkipNodePointerPointer)
    (((char *) (&NodesToUpdate[SKIPLISTLEVELCAP-1])) + AddressOffset);

    /* Replace the next pointer at the current level in the previous node
       with a pointer to the new node.  The new node's next pointer takes over
       the previous node's value. */

    *(SkipNodePointerPointer)
    (((char *) &TheNode->next) + AddressOffset) =
    *(SkipNodePointerPointer)
    (((char *) &PreviousNode->next) + AddressOffset);

    *(SkipNodePointerPointer)
    (((char *) &PreviousNode->next) + AddressOffset) = TheNode;
  }
  ++TheList->size; /* One more node in the list. */

  /* Check for the size getting large enough to make it worth while to
     activate a new level of pointers. */

  if (TheList->size >= TheList->nextSizeUp)
    UpdateListActiveLevels (TheList, OurBase);

  /* Return the node just before the new one.  Or if there is none, return
     NULL.  Just use the previous node on the bottom level of pointers (that's
     the level where all nodes are listed) to find the node before the newly
     inserted one. */

  PreviousNode = NodesToUpdate [SKIPLISTLEVELCAP-1];
  if (PreviousNode ==
  (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1])
    return NULL; /* This is the list header pretending to be a node. */

  return PreviousNode;
}



/******************************************************************************
 * Removes a node with a value equal to TheNode's value from the list.  Returns
 * the node it removed, or NULL if it couldn't find one matching TheNode in
 * value (equality as decided by your compareUserData function).  Doesn't
 * deallocate the node it removed.  TheNode doesn't have to be a fully
 * initialised node if your compareUserData function doesn't use the
 * SkipNodeRecord fields (the default comparison function uses the size field,
 * doesn't need the nodeLevel field or use the hidden array before the record
 * (thus you don't need to use AllocateSkipNode to create a full SkipNode for
 * comparison purposes).
 */

static SkipNodePointer RemoveSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  short AddressOffset;
  LONG ComparisonResult;
  SkipNodePointer CurrentNode;
  SkipNodePointer RemovedNode;
  UBYTE MinimumLevel;
  SkipNodePointer NextNode;
  SkipNodePointer NodesToUpdate [SKIPLISTLEVELCAP];
  SkipNodePointer PreviousNode;

#if DEBUGMODE
  if (TheList == NULL || TheNode == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList or TheNode in RemoveSkipNode.",
    OurBase);
    #endif
    return NULL;
  }
#endif

#if DEBUGMODE
  if (TheList->activeLevels <= 0 || TheList->activeLevels > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Corrupt TheList header in RemoveSkipNode.", OurBase);
    #endif
    return NULL;
  }
#endif

  /* Start off at the list header, treating it like a fake node. */

  CurrentNode = (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];

  /* This outer loop scans down the levels of pointers (starting at the
     sparsest list) until we get to the bottom (the list with all nodes).  The
     AddressOffset hack is used to get the node's LevelPointers[] entry
     quickly for several nodes with the same level index value (yup, negative
     indices for a backwards array).  The general idea is to fill up
     NodesToUpdate with the node at each level that is just before the
     searched for node in sort order. */

  AddressOffset = -(TheList->activeLevels * sizeof (SkipNodePointer));
  while (AddressOffset < 0)
  {
    AddressOffset += sizeof (SkipNodePointer);

    /* Scan right along this pointer level until we hit the largest node less
       than (as defined by the user's comparison function) the one we want to
       delete. */

    while (TRUE)
    {
      /* Get the pointer to the next node at the current level.  This mess
         boils down to one M68000 instruction, vs having extra shifts and
         other operations if we used PointerArray[-i]. */

      NextNode = * (SkipNodePointerPointer)
      (((char *) &CurrentNode->next) + AddressOffset);

      if (NextNode == NULL)
        break; /* Hit end of this level.  Go to next level. */

      /* Compare the next node and the node being searched for.  Use the
         user's comparison function or if none, use a string comparison. */

      if (TheList->compareUserData == NULL)
        ComparisonResult = CompareNodesAsStrings (NextNode, TheNode, OurBase);
      else
        ComparisonResult = TheList->compareUserData (NextNode, TheNode);

      if (ComparisonResult >= 0)
        break; /* Reached a node greater or equal to the searched one. */

      CurrentNode = NextNode; /* Scan along the same level some more. */
    }

    /* Store away the node we stopped at on this level in the NodesToUpdate
       array, again in backwards array order.  This node is the one which will
       be just before the deleted one on this level.  Of course, the deleted
       one may or may not be tall enough to actually be on this level. */

    *(SkipNodePointerPointer)
    (((char *) (&NodesToUpdate[SKIPLISTLEVELCAP-1])) + AddressOffset) =
    CurrentNode;
  }

  /* Ok, the node to be removed is just after CurrentNode; the node which is
     greater than or equal to the searched for node's sort key.  Or NULL if at
     the end of the list. */

  RemovedNode = CurrentNode->next;

  /* See if this equal or larger node is equal to the one being deleted.  If
     it is, delete it. */

  if (RemovedNode != NULL)
  {
    if (TheList->compareUserData == NULL)
      ComparisonResult = CompareNodesAsStrings (RemovedNode, TheNode, OurBase);
    else
      ComparisonResult = TheList->compareUserData (RemovedNode, TheNode);

    if (ComparisonResult == 0)
    {
      /* Delete the current node.  Patch up the pointers that used to point to
         this old node to point around it to the appropriate next ones.  We
         have several levels of pointers to fix up (the loop goes from the top
         level used by the dead node to the bottom level). */

      MinimumLevel = RemovedNode->size.asBytes.nodeLevel;
      if (TheList->activeLevels < MinimumLevel)
        MinimumLevel = TheList->activeLevels;

      AddressOffset = -(MinimumLevel * sizeof (SkipNodePointer));
      while (AddressOffset < 0)
      {
        AddressOffset += sizeof (SkipNodePointer);

        /* Get the address of the node to fix up.  It's the one just before
           the removed node, in the level of pointers being fixed. */

        PreviousNode = *(SkipNodePointerPointer)
        (((char *) (&NodesToUpdate[SKIPLISTLEVELCAP-1])) + AddressOffset);

        /* Replace the next pointer at the current level in the previous node
           with the next pointer at the same level in the dead node. */

        *(SkipNodePointerPointer)
        (((char *) &PreviousNode->next) + AddressOffset) =
        *(SkipNodePointerPointer)
        (((char *) &RemovedNode->next) + AddressOffset);
      }

      /* Dispose of the dead node.  Don't deallocate it.  Also adjust the list
         size and number of active levels. */

      if (--TheList->size < TheList->nextSizeDown)
        UpdateListActiveLevels (TheList, OurBase);

      RemovedNode->next = NULL; /* So user doesn't use it accidentally. */
    }
    else /* Not an equal node. */
      RemovedNode = NULL; /* Nope, didn't find it after all. */
  }
  return RemovedNode;
}



/******************************************************************************
 * This removes a node matching TheNode's value and then deallocates it.
 * Returns non-zero if it actually removed anything, zero if it couldn't find
 * your node.  Does a RemoveSkipNode followed by DeallocateSkipNode, so see
 * those functions for details.
 */

static ULONG DeleteSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  SkipNodePointer DeletedNode;

  DeletedNode = RemoveSkipNodeA6 (TheList, TheNode, OurBase);
  if (DeletedNode != NULL)
    DeallocateSkipNodeA6 (TheList, DeletedNode, OurBase);

  return (DeletedNode != NULL);
}



/******************************************************************************
 * This function clears the list back to an empty list state, more efficiently
 * than using Delete on individual nodes.  All SkipNodes are deallocated (see
 * DeallocateSkipNode) and the list header is reset to an empty list state.
 */

static void DeleteAllSkipNodes (void)
{
  register SkipListPointer a0 __asm("a0");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipListBasePointer OurBase = a6;

  ULONG DeleteCount;
  int i;
  SkipNodePointer NextNode;
  SkipNodePointer NodeToDelete;

#if DEBUGMODE
  if (TheList == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList in DeleteAllSkipNodes.", OurBase);
    #endif
    return;
  }
#endif

#if DEBUGMODE
  if (TheList->activeLevels <= 0 || TheList->activeLevels > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Corrupt TheList header in DeleteAllSkipNodes.",
    OurBase);
    #endif
    return;
  }
#endif

  /* Deallocate all the nodes, and count how many there were. */

  NextNode = TheList->levelPointers [SKIPLISTLEVELCAP-1];
#if DEBUGMODE
  DeleteCount = 0;
#endif
  while (NextNode != NULL)
  {
    NodeToDelete = NextNode;
    NextNode = NextNode->next;
#if DEBUGMODE
    ++DeleteCount;
    NodeToDelete->next = NULL; /* So user doesn't use it. */
#endif
    DeallocateSkipNodeA6 (TheList, NodeToDelete, OurBase);
  }

#if DEBUGMODE && VERBOSE_CODE
  if (DeleteCount != TheList->size)
    DisplayErrorMessage (
    "TheList->size doesn't match node count in DeleteAllSkipNodes.", OurBase);
#endif

  /* Clear the skip list header to an empty list state. */

  for (i = SKIPLISTLEVELCAP - 1; i >= 0; i--)
    TheList->levelPointers [i] = NULL;

  TheList->activeLevels = 1;
  TheList->size = 0;
  TheList->nextSizeUp = 4;
  TheList->nextSizeDown = 0;
}



/******************************************************************************
 * Finds a node with a value equal to TheNode's value from the list.  Returns
 * the node it found, or NULL if it couldn't find it.  TheNode doesn't have to
 * be a fully initialised node (see RemoveSkipNode for details).
 */

static SkipNodePointer FindSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  short AddressOffset;
  LONG ComparisonResult;
  SkipNodePointer CurrentNode;
  SkipNodePointer NextNode;

#if DEBUGMODE
  if (TheList == NULL || TheNode == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList or TheNode in FindSkipNode.",
    OurBase);
    #endif
    return NULL;
  }
#endif

#if DEBUGMODE
  if (TheList->activeLevels <= 0 || TheList->activeLevels > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("Corrupt TheList header in FindSkipNode.", OurBase);
    #endif
    return NULL;
  }
#endif

  /* Start off at the list header, treating it like a fake node. */

  CurrentNode = (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];

  /* This outer loop scans down the levels of pointers (starting at the
     sparsest list) until we get to the bottom (the list with all nodes).  The
     AddressOffset hack is used to get the node's LevelPointers[] entry
     quickly for several nodes with the same level index value (yup, negative
     indices for a backwards array).  The general idea is to go along each
     level and drop down to a more detailed level just before passing the
     searched for node in sort order. */

  AddressOffset = -(TheList->activeLevels * sizeof (SkipNodePointer));
  while (AddressOffset < 0)
  {
    AddressOffset += sizeof (SkipNodePointer);

    /* Scan right along this pointer level until we hit the largest node less
       than (as defined by the user's comparison function) the one we want to
       insert. */

    while (TRUE)
    {
      /* Get the pointer to the next node at the current level.  This mess
         boils down to one M68000 instruction, vs having extra shifts and
         other operations if we used PointerArray[-i]. */

      NextNode = * (SkipNodePointerPointer)
      (((char *) &CurrentNode->next) + AddressOffset);

      if (NextNode == NULL)
        break; /* Hit end of this level.  Go to next level. */

      /* Compare the node being searched for and the next node.  Use the user's
         comparison function or if none, use a string comparison. */

      if (TheList->compareUserData == NULL)
        ComparisonResult = CompareNodesAsStrings (NextNode, TheNode, OurBase);
      else
        ComparisonResult = TheList->compareUserData (NextNode, TheNode);

      if (ComparisonResult >= 0)
        break; /* Reached a node greater or equal to the new one. */

      CurrentNode = NextNode; /* Scan along the same level some more. */
    }
  }

  /* Got the node just before the desired one in value.  Does the desired node
     follow right after? */

  CurrentNode = CurrentNode->next;

  if (CurrentNode == NULL)
    return NULL; /* Nothing follows right after the lower node. */

  /* Is that following node equal to our desired one? */

  if (TheList->compareUserData == NULL)
    ComparisonResult = CompareNodesAsStrings (CurrentNode, TheNode, OurBase);
  else
    ComparisonResult = TheList->compareUserData (CurrentNode, TheNode);

  if (ComparisonResult == 0)
    return CurrentNode; /* Yes, we found it! */

  return NULL; /* No, this node will be larger.  Didn't find it. */
}



/******************************************************************************
 * Finds a node with the largest value less than TheNode's value in TheList.
 * If it can't be found (no nodes less than TheNode) then it returns NULL.
 * TheNode doesn't have to be a fully initialised node (see RemoveSkipNode for
 * details).
 */

static SkipNodePointer FindBelowSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  short AddressOffset;
  LONG ComparisonResult;
  SkipNodePointer CurrentNode;
  SkipNodePointer NextNode;

#if DEBUGMODE
  if (TheList == NULL || TheNode == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList or TheNode in FindBelowSkipNode.",
    OurBase);
    #endif
    return NULL;
  }
#endif

#if DEBUGMODE
  if (TheList->activeLevels <= 0 || TheList->activeLevels > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage (
    "Corrupt TheList header in FindBelowSkipNode.", OurBase);
    #endif
    return NULL;
  }
#endif

  /* See the FindSkipNode function for comments.  This code is mostly copied
     from there. */

  CurrentNode = (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];
  AddressOffset = -(TheList->activeLevels * sizeof (SkipNodePointer));
  while (AddressOffset < 0)
  {
    AddressOffset += sizeof (SkipNodePointer);
    while (TRUE)
    {
      NextNode = * (SkipNodePointerPointer)
      (((char *) &CurrentNode->next) + AddressOffset);

      if (NextNode == NULL)
        break;

      if (TheList->compareUserData == NULL)
        ComparisonResult = CompareNodesAsStrings (NextNode, TheNode, OurBase);
      else
        ComparisonResult = TheList->compareUserData (NextNode, TheNode);

      if (ComparisonResult >= 0)
        break;

      CurrentNode = NextNode;
    }
  }

  if (CurrentNode ==
  (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1])
    return NULL; /* At the list header fake node, nothing before TheNode. */

  return CurrentNode; /* Yup, this is the one before TheNode. */
}



/******************************************************************************
 * Finds a node with the smallest value equal or greater than TheNode's value
 * in TheList.  If it can't be found (no nodes greater than or equal to
 * TheNode) then it returns NULL.  TheNode doesn't have to be a fully
 * initialised node (see RemoveSkipNode for details).
 */

static SkipNodePointer FindAboveOrEqualSkipNode (void)
{
  register SkipListPointer a0 __asm("a0");
  register SkipNodePointer a1 __asm("a1");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipNodePointer TheNode = a1;
  SkipListBasePointer OurBase = a6;

  short AddressOffset;
  LONG ComparisonResult;
  SkipNodePointer CurrentNode;
  SkipNodePointer NextNode;

#if DEBUGMODE
  if (TheList == NULL || TheNode == NULL)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage ("NULL TheList or TheNode in FindAboveOrEqualSkipNode.",
    OurBase);
    #endif
    return NULL;
  }
#endif

#if DEBUGMODE
  if (TheList->activeLevels <= 0 || TheList->activeLevels > SKIPLISTLEVELCAP)
  {
    #if VERBOSE_CODE
    DisplayErrorMessage (
    "Corrupt TheList header in FindAboveOrEqualSkipNode.", OurBase);
    #endif
    return NULL;
  }
#endif

  /* See the FindSkipNode function for comments.  This code is mostly copied
     from there. */

  CurrentNode = (SkipNodePointer) &TheList->levelPointers [SKIPLISTLEVELCAP-1];
  AddressOffset = -(TheList->activeLevels * sizeof (SkipNodePointer));
  while (AddressOffset < 0)
  {
    AddressOffset += sizeof (SkipNodePointer);
    while (TRUE)
    {
      NextNode = * (SkipNodePointerPointer)
      (((char *) &CurrentNode->next) + AddressOffset);

      if (NextNode == NULL)
        break;

      if (TheList->compareUserData == NULL)
        ComparisonResult = CompareNodesAsStrings (NextNode, TheNode, OurBase);
      else
        ComparisonResult = TheList->compareUserData (NextNode, TheNode);

      if (ComparisonResult >= 0)
        break;

      CurrentNode = NextNode;
    }
  }

  return CurrentNode->next;  /* That was easy. */
}



/******************************************************************************
 * Returns a random number from 1 to SKIPLISTLEVELCAP.  There's a 3/4 chance
 * of getting 1 returned, 3/16 of getting 2, and in general 3/(4^n) of getting
 * n.  Uses the cached random numbers in the list.  If TheList is NULL then it
 * will call the random number generator directly.
 */

static ULONG GenerateRandomLevelNumber (void)
{
  register SkipListPointer a0 __asm("a0");
  register APTR a6 __asm("a6");
  SkipListPointer TheList = a0;
  SkipListBasePointer OurBase = a6;

  int LevelNumber;
  int RandomIndex;
  ULONG RandomNumber;

  /* First get a 32 bit random number. */

  if (TheList == NULL)
    RandomNumber = Random250LongA6 (OurBase->random250Base);
  else /* Can use the cached numbers in the list. */
  {
    RandomIndex = TheList->randomIndex;
    RandomNumber = TheList->randomCache [RandomIndex];
    if (--RandomIndex < 0)
    {
      /* Just ran out of cached random numbers.  Refill the cache. */

      Random250ArrayA6 (RANDOMCACHESIZE, TheList->randomCache,
      OurBase->random250Base);
      RandomIndex = RANDOMCACHESIZE - 1;
    }
    TheList->randomIndex = RandomIndex;
  }

  /* Convert it to our special probability distribution.
     3/4 of the time you get 1, 3/16 you get 2, etc. */

  LevelNumber = 1;
  while (LevelNumber < SKIPLISTLEVELCAP)
  {
    if (RandomNumber & 3) /* If lower 2 bits are non-zero; 3/4 of the time. */
      break;

    RandomNumber >>= 2;
    LevelNumber++;
  }

  return LevelNumber;
}



/******************************************************************************
 * Returns the value of RANDOMCACHESIZE used by the library.
 */

static ULONG GetRANDOMCACHESIZE (void)
{
  return RANDOMCACHESIZE;
}



/******************************************************************************
 * Returns the value of SKIPLISTLEVELCAP used by the library.
 */

static ULONG GetSKIPLISTLEVELCAP (void)
{
  return SKIPLISTLEVELCAP;
}



/******************************************************************************
 * Dummy function used for finding the end of the code segment.  Must
 * be at the end of this file!
 */

static void EndOfCode (void)
{
}
