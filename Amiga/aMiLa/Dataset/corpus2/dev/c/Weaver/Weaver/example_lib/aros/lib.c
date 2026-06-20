/* --- AROS library frame ---      :ts=4 */


/* Calling convention used:
 *
 * cd weaver/example_lib/aros
 * stack 128000
 * i686-pc-aros-gcc -D__AROS__ -O2 -g0 -c -o RAM:functions.o functions.c
 * i686-pc-aros-gcc -D__AROS__ -nostartfiles -nostdlib -O2 -g0 -o RAM:test.library lib.c RAM:functions.o
 */

/*
 * This file was automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


/*
**
**    Copyright (C) 2008/2009 Weaver Developers.
**
**    All rights reserved.
**
*/


/*
 * IMPORTANT: Don't allow to auto-open libs nor to declare as "extern"
 * the lib bases - we have to do everything by hand!
 */
#define __NOLIBBASE__

#include	<aros/system.h>

#include	<exec/libraries.h>
#include	<exec/execbase.h>
#include	<exec/resident.h>
#include	<dos/dos.h>
#include	<dos/dosextens.h>

#include	<proto/exec.h>
#include	<proto/dos.h>

#include	<aros/libcall.h>
#include	<aros/asmcall.h>

/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


/* Additional, entered by hand (containing the lib bases!) */
#include	<graphics/gfxbase.h>
#include	<intuition/intuitionbase.h>


#if !defined(USED)
#define USED	__attribute__((used))
#define USED_VAR	USED

#endif
/* Avoid an inadvertent start */
USED int _start()
{
	return RETURN_FAIL;
}

#define LibVersion  (2)
#define LibRevision (0)			/* Please fill in... */

const UBYTE LibVersionStr[] = "$VER: test.library 2.0 (15-Aug-09)";	/* Please change... */

const UBYTE LibName[] = "test.library";	/* We need it later... */


/* The structure of your library - you're allowed to extent it! */
struct TestLibrary
{
	struct Library   lb_LibFrame;	/* Self... */
	struct ExecBase *lb_SysBase;
	BPTR			 lb_SegList;
	struct DosLibrary *lb_DOSBase;	/* Set up for you! */
	/* Enter additional pointers/structures as required! */

	/* Of course, I do. :) Additional, locally defined bases */
	struct GfxBase *lb_GfxBase;
	struct IntuitionBase *lb_IntuitionBase;
};

struct ExecBase *SysBase = NULL;		/* SysBase initialised in LibInit()! */
struct TestLibrary *TestBase = NULL;	/* Enter additional globals here */
struct DosLibrary *DOSBase = NULL;		/* We do! */

/* Globally defined bases that can be used by "function.c" */
struct GfxBase *GfxBase = NULL;
struct IntuitionBase *IntuitionBase = NULL;


/*
 * Provide here that initialisation that your surrounding requires - e.g.
 * opening of other libraries.
 * Return 0 if your initialisation failed or any other value for success
 */

static int UserInit( struct TestLibrary *testBase)
{
	if ( (testBase->lb_DOSBase = DOSBase = (struct DosLibrary *) OpenLibrary( "dos.library", 41)) )
	{
		if ( (testBase->lb_GfxBase = GfxBase = (struct GfxBase *) OpenLibrary( "graphics.library", 41)) )
		{
			if ( (testBase->lb_IntuitionBase = IntuitionBase = (struct IntuitionBase *) OpenLibrary( "intuition.library", 41)) )
				return	1;
		}
	}

	return 0;
}

/*
 * Counterpart to the above...
 */

static void UserCleanup( struct TestLibrary *testBase)
{
	if (testBase->lb_IntuitionBase)
	{
		CloseLibrary( (struct Library *) testBase->lb_IntuitionBase);
		testBase->lb_IntuitionBase = IntuitionBase = NULL;
	}

	if (testBase->lb_GfxBase)
	{
		CloseLibrary( (struct Library *) testBase->lb_GfxBase);
		testBase->lb_GfxBase = GfxBase = NULL;
	}

	if (testBase->lb_DOSBase)
	{
		CloseLibrary( (struct Library *) testBase->lb_DOSBase);
		testBase->lb_DOSBase = DOSBase = NULL;
	}
}


/* Workaround - need declarations before they will be referenced... */
extern CONST ULONG LibInitTab[4];
extern const int TestLibrary_EndCode;

/* Main structure used by the system to setup the library!!! */
const USED_VAR struct Resident ROMTag =
{
	RTC_MATCHWORD,
	(struct Resident *) &ROMTag,
	(struct Resident *) &TestLibrary_EndCode,
	RTF_AUTOINIT,
	LibVersion,
	NT_LIBRARY,
	0,
	(STRPTR) LibName,
	(STRPTR) &LibVersionStr[6],
	(ULONG *) LibInitTab
};

/* Workaround - need declarations before they will be referenced... */
struct Library * AROS_SLIB_ENTRY( LibInit, Test)();
extern CONST APTR LibVectors[];

/* AROS...? */
const ULONG LibDataTable = 0;	/* Why can't we use NULL in LibInitTab??? */

/* Library description */
CONST ULONG LibInitTab[] =
{
	sizeof (struct TestLibrary),
	(ULONG) LibVectors,
	(ULONG) &LibDataTable,	/* Pointing to an empty ULONG... */
	(ULONG) &(AROS_SLIB_ENTRY( LibInit, Test))
};


/*
 * Init routine called by MakeLibrary():
 * AROS_SLIB_ENTRY macro concatenates two labels: "LibInit" and "Test"
 * as one unique label name. (I really don't know what this is good for...)
 */
AROS_UFH3( struct Library *, AROS_SLIB_ENTRY( LibInit, Test),
	AROS_UFHA( struct TestLibrary *, testBase, D0),
	AROS_UFHA( BPTR,			    segList, A0),
	AROS_UFHA( struct ExecBase *, sysBase, A6) )
{
	AROS_USERFUNC_INIT

	if (testBase->lb_SysBase != sysBase)		/* Indicator whether lib was already initialised */
	{
		testBase->lb_LibFrame.lib_Node.ln_Type = NT_LIBRARY;
		testBase->lb_LibFrame.lib_Node.ln_Pri = 0;
		(const UBYTE *) testBase->lb_LibFrame.lib_Node.ln_Name = LibName;
		testBase->lb_LibFrame.lib_Flags = LIBF_SUMUSED | LIBF_CHANGED;
		testBase->lb_LibFrame.lib_Version = LibVersion;
		testBase->lb_LibFrame.lib_Revision = LibRevision;
		(const UBYTE *) testBase->lb_LibFrame.lib_IdString = &LibVersionStr[6];	/* Skip $VER: */

		testBase->lb_SysBase = sysBase;
		SysBase = sysBase;
		testBase->lb_SegList = segList;

		/*
		 * You may add a function, called UserInit(), that opens/allocates your private data.
		 * Return a value unequal zero for success and 0 if your initialisation failed.
		 */
		if ( (UserInit( testBase)) )
		{
			TestBase = testBase;	/* Establish global base pointer */
		}
		else
		{
			UserCleanup( testBase);
			TestBase = NULL;		/* User init failed, thus library isn't available */
		}
	}

	return (struct Library *) TestBase;		/* Base pointer or NULL */

	AROS_USERFUNC_EXIT
}


/*
 * First slot reserved to open library by caller.
 */
AROS_LH1( struct TestLibrary *, LibOpen,
	AROS_LHA( ULONG, version, D0),
	struct TestLibrary *, testBase, 1, Test)
{
	AROS_LIBFUNC_INIT

	testBase->lb_LibFrame.lib_Flags &= ~LIBF_DELEXP;	/* Delete the late expunge flag */
	testBase->lb_LibFrame.lib_OpenCnt ++;				/* Increase the open counter */

	/* Return library's base pointer (success) or NULL for error initialising */
	return testBase;

	AROS_LIBFUNC_EXIT
}

/*
 * Third slot (yep, it's the third) used to remove this library out of RAM.
 */
AROS_LH0( BPTR, LibExpunge,
  struct TestLibrary *, testBase, 3, Test)
{
	AROS_LIBFUNC_INIT

	BPTR rc = 0;

	/* In case our open counter is still > 0, we have
	   to set the late expunge flag and return immediately */
	if (testBase->lb_LibFrame.lib_OpenCnt > 0)
	{
		/* Can't expunge, we are still in use... */
		testBase->lb_LibFrame.lib_Flags |= LIBF_DELEXP;
	}
	else
	{
		Remove( &(testBase->lb_LibFrame.lib_Node) );
		rc = testBase->lb_SegList;

		FreeMem( (UBYTE *) testBase - testBase->lb_LibFrame.lib_NegSize,
		testBase->lb_LibFrame.lib_PosSize + testBase->lb_LibFrame.lib_NegSize);
	}

	return rc;

	AROS_LIBFUNC_EXIT
}

/*
 * Second slot reserved for trying to close library.
 */
AROS_LH0( BPTR, LibClose,
  struct TestLibrary *, testBase, 2, Test)
{
	AROS_LIBFUNC_INIT

	BPTR rc = 0;

	/* Decrease the open counter */
	testBase->lb_LibFrame.lib_OpenCnt --;

	if (testBase->lb_LibFrame.lib_OpenCnt <= 0)
	{
		/* In case the late expunge flag is set we go and
		   expunge the library base right now */
		if (testBase->lb_LibFrame.lib_Flags & LIBF_DELEXP)
		{
			rc = AROS_LC0( BPTR, LibExpunge, struct TestLibrary *, testBase, 3, Test);
		}
	}

	return rc;

	AROS_LIBFUNC_EXIT
}

/*
 * Fourth slot reserved by default.
 */
AROS_LH0I( int, LibNull,
  struct  TestLibrary *, testBase, 4, Test)
{
	AROS_LIBFUNC_INIT

	return 0;

	AROS_LIBFUNC_EXIT
}


/* Proto types for the real functions */

/* *** LVO 30 (entry 5) reserved - you have to define it manually! *** */
LONG Add( LONG a, LONG b);
LONG Sub( LONG a, LONG b);
/* *** LVO 48 (entry 8) reserved - you have to define it manually! *** */
struct Screen * CloneWBScr();
void CloseClonedWBScr( struct Screen *scr);
void GetClonedWBScrAttrA( struct Screen *scr, struct TagItem *tags);


/* AROS stubs which will call the real functions (see prototypes above) */

/* *** LVO 30 (entry 5) reserved - you have to define it manually! *** */
AROS_LH0I( void, Undefined_5_Func, struct TestLibrary *, testBase, 5, Test)
{
	AROS_LIBFUNC_INIT

	return;

	AROS_LIBFUNC_EXIT
}

/* AROS stub for LVO 36 (lib's entry 6) */
AROS_LH2( LONG, Add,
	AROS_LHA( LONG, a, D0),
	AROS_LHA( LONG, b, D1),
	struct TestLibrary *, testBase, 6, Test)
{
	AROS_LIBFUNC_INIT

	return Add( a, b);

	AROS_LIBFUNC_EXIT
}

/* AROS stub for LVO 42 (lib's entry 7) */
AROS_LH2( LONG, Sub,
	AROS_LHA( LONG, a, D0),
	AROS_LHA( LONG, b, D1),
	struct TestLibrary *, testBase, 7, Test)
{
	AROS_LIBFUNC_INIT

	return Sub( a, b);

	AROS_LIBFUNC_EXIT
}

/* *** LVO 48 (entry 8) reserved - you have to define it manually! *** */
AROS_LH0I( void, Undefined_8_Func, struct TestLibrary *, testBase, 8, Test)
{
	AROS_LIBFUNC_INIT

	return;

	AROS_LIBFUNC_EXIT
}

/* AROS stub for LVO 54 (lib's entry 9) */
AROS_LH0( struct Screen *, CloneWBScr,
	struct TestLibrary *, testBase, 9, Test)
{
	AROS_LIBFUNC_INIT

	return CloneWBScr();

	AROS_LIBFUNC_EXIT
}

/* AROS stub for LVO 60 (lib's entry 10) */
AROS_LH1( void, CloseClonedWBScr,
	AROS_LHA( struct Screen *, scr, A0),
	struct TestLibrary *, testBase, 10, Test)
{
	AROS_LIBFUNC_INIT

	CloseClonedWBScr( scr);
	return;

	AROS_LIBFUNC_EXIT
}

/* AROS stub for LVO 66 (lib's entry 11) */
AROS_LH2( void, GetClonedWBScrAttrA,
	AROS_LHA( struct Screen *, scr, A0),
	AROS_LHA( struct TagItem *, tags, A1),
	struct TestLibrary *, testBase, 11, Test)
{
	AROS_LIBFUNC_INIT

	GetClonedWBScrAttrA( scr, tags);
	return;

	AROS_LIBFUNC_EXIT
}


/*
 * Library vectors (slots) (it's the jump table!)
 */
CONST APTR LibVectors[] =
{
	/* Basic functions that must be existent in all libraries! */
	&(AROS_SLIB_ENTRY( LibOpen, Test)),
	&(AROS_SLIB_ENTRY( LibClose, Test)),
	&(AROS_SLIB_ENTRY( LibExpunge, Test)),
	&(AROS_SLIB_ENTRY( LibNull, Test)),
	/* Custom functions */
	/* *** LVO 30 (entry 5) reserved - you have to change it manually! *** */
	&(AROS_SLIB_ENTRY( Undefined_5_Func, Test)),
	&(AROS_SLIB_ENTRY( Add, Test)),
	&(AROS_SLIB_ENTRY( Sub, Test)),
	/* *** LVO 48 (entry 8) reserved - you have to change it manually! *** */
	&(AROS_SLIB_ENTRY( Undefined_8_Func, Test)),
	&(AROS_SLIB_ENTRY( CloneWBScr, Test)),
	&(AROS_SLIB_ENTRY( CloseClonedWBScr, Test)),
	&(AROS_SLIB_ENTRY( GetClonedWBScrAttrA, Test)),
	(APTR) (-1)
};

const int TestLibrary_EndCode = 1;

	/* Bye bye says Weaver :-) */
