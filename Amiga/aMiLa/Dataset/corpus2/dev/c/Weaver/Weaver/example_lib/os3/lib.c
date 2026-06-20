/* --- SDI based universal library frame created by Weaver ---      :ts=4 */

/*
 * This  source  code  was  first  used in SDI_Headers (public domain) and this
 * file  and  all  related  were revised by me in order to make them compatible
 * with vbcc without losing the possibility to use them for gcc.
 *
 * You  may  use  no  makefile  to  compile  it  - but then you have to include
 * "functions.c" directly (see include statement below).
 *
 * For  all  targets  you'll  first  need  to create their prototypes and stubs
 * (Weaver  with  keyword  SDI)  and  for  OS4  also  the  68k vector table and
 * interface record (Weaver with keywords 68K and IFACE).
 *
 * NOTE:
 * The IFACE file (e.g. "test.h") will be referenced by the 68k vector
 * table file (e.g."test_68k.c"). Please locate the line:
 * #include <interfaces/test.h>
 * and change it to:
 * #include "test.h"
 * as long as you didn't store it lasting in your compiler's interface drawer!
 *
 * Example calls for building a shared library:
 *  vc +aos68k -c99 -cpu=68020 -sc -O1 -nostdlib lib.c -o RAM:test.library_m68k -lamiga
 *  vc +aosppc -I -D__USE_INLINE__ -O1 -nostdlib lib.c -o RAM:test.library_os4
 *  vc +morphos -O1 -nostdlib lib.c -o RAM:test.library_mos
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

#include	<exec/execbase.h>
#include	<exec/libraries.h>
#include	<exec/resident.h>
#include	<dos/dos.h>

#include	<proto/exec.h>
#include	<proto/dos.h>

#ifdef DEBUG
	#include <clib/debug_protos.h>
#endif

#if defined(__MORPHOS__)
	#include <emul/emulregs.h>
#endif

#if defined(__amigaos4__)
	#include <exec/emulation.h>
	#include <exec/interfaces.h>
	#include <interfaces/exec.h>
	#include <interfaces/dos.h>

	#if defined(__NEWLIB__)
		#include <interfaces/newlib.h>
	#endif
#endif

#include <SDI_lib.h>

/* Custom includes specified in SFD file */
#include	<intuition/screens.h>

/* Manually added: */
#include	<proto/graphics.h>
#include	<proto/intuition.h>

#if defined(__amigaos4__)
	#include <interfaces/graphics.h>
	#include <interfaces/intuition.h>
#endif

/****************************************************************************/


#if defined(__amigaos4__)
int _start( void)
#else
int Main( void)
#endif
{
	return RETURN_FAIL;
}


/****************************************************************************/


#if defined(__amigaos4__)
	struct Library *SysBase = NULL;
	struct ExecIFace *IExec = NULL;
	struct Library *DOSBase = NULL;
	struct DOSIFace *IDOS = NULL;
	#if defined(__NEWLIB__)
		struct Library *NewlibBase = NULL;
		struct NewlibIFace *INewlib = NULL;
	#endif
#else
	struct ExecBase *SysBase = NULL;
	struct Library *DOSBase = NULL;
#endif

/* Manually added: */
struct Library *GfxBase = NULL;
struct Library *IntuitionBase = NULL;
#if defined(__amigaos4__)
	struct GraphicsIFace *IGraphics;
	struct IntuitionIFace *IIntuition;
#endif

/****************************************************************************/

/* For the old, OS3 compatible include files, we need the old alignment -
   not really necessary here but for safety reasons... */
#if defined(__MORPHOS__)
#pragma pack(2)
#endif

/* Change the items below to fit your own library - and especially the revison
   number! */

/* This is your library base - in the old days, you would have made it public,
   today it shall remain private! */
struct TestLibrary
{
	struct Library lb_LibFrame;	/* Self... */
	/* Locally stored pointer to Exec library (SysBase) */
	struct Library *lb_SysBase;
	ULONG lb_SegList;			/* Our own segment list */
	struct Library *lb_DOSBase;	/* Already set up for you */
#if defined(__amigaos4__)
	struct DOSIFace *lb_IDOS;
#else
	ULONG _reserved1;			/* DOSIFace kludgefill */
#endif

/* Inserted locally... */
	struct Library *lb_GfxBase;	/* Manually set up */
#if defined(__amigaos4__)
	struct GraphicsIFace *lb_IGraphics;
#else
	ULONG _reserved2;			/* GraphicsIFace kludgefill */
#endif

	struct Library *lb_IntuitionBase;	/* Manually set up */
#if defined(__amigaos4__)
	struct IntuitionIFace *lb_IIntuition;
#else
	ULONG _reserved3;			/* IntuitionIFace kludgefill */
#endif
};

/* Use the natural alignment from now on */
#if defined(__MORPHOS__)
#pragma pack()
#endif

struct TestLibrary *TestBase = NULL;


static const char UserLibName[] = "test.library";


/* Please change the revision numbers because a revision number is not part of
   a SFD file */
#if defined(__amigaos4__)
	static const char UserLibID[] = "$VER: test.library 2.0 (01-Aug-09)"	
									" Amiga PPC (m68k & PPC Interface) Library";
#elif defined(__MORPHOS__)
	static const char UserLibID[] = "$VER: test.library 2.0 (01-Aug-09)"	
									" MorphOS PPC (m68k Interface but PPC code) Library";
#else
	static const char UserLibID[] = "$VER: test.library 2.0 (01-Aug-09)"	
									" m68k Library";
#endif


#define LIB_VERSION 2
#define LIB_REVISION 0


/****************************************************************************/


/*
 * Provide here that initialisation that your surrounding requires - e.g.
 * opening of other libraries.
 * Return 0 if your initialisation failed or any other value for success
 */

/* Simplify the different calls upon opening and closing libraries */
#include	"misc_lib.c"

static int UserInit( struct TestLibrary *testBase)
{
	if ( (OPEN_LIB( "dos.library",
					 MIN_SYS_LIB_VER,
					 &DOSBase,
					 NULL,
					 1,
					 &IDOS,
					 NULL)) )
	{
		DUPLICATE( DOSBase, testBase->lb_DOSBase,
				   IDOS, testBase->lb_IDOS);

		if ( (OPEN_LIB( "graphics.library",
						MIN_SYS_LIB_VER,
						&GfxBase,
						NULL,
						1,
						&IGraphics,
						NULL)) )
		{
			DUPLICATE( GfxBase, testBase->lb_GfxBase,
					   IGraphics, testBase->lb_IGraphics);

			if ( (OPEN_LIB( "intuition.library",
							MIN_SYS_LIB_VER,
							&IntuitionBase,
							NULL,
							1,
							&IIntuition,
							NULL)) )
			{
				DUPLICATE( IntuitionBase, testBase->lb_IntuitionBase,
						   IIntuition, testBase->lb_IIntuition);

				#if defined(__NEWLIB__)
				/* In contrast to DOSBase we set up NewlibBase only as global
				   variable */
				if ( (OPEN_LIB( "newlib.library",
								 3,
								 &NewlibBase,
								 NULL,
								 1,
								 &INewlib,
								 NULL)) )
					return 1;
				else
					return 0;
				#endif

				return 1;
			}
		}
	}

	return 0;
}

/*
 * Counterpart to the above...
 */

static void UserCleanup( struct TestLibrary *testBase)
{
	#if defined(__NEWLIB__)
	if (NewlibBase)
		CLOSE_LIB( &NewlibBase, &INewlib);
	#endif

	if (IntuitionBase)
		CLOSE_LIB( &IntuitionBase, &IIntuition);

	if (GfxBase)
		CLOSE_LIB( &GfxBase, &IGraphics);

	if (DOSBase)
		CLOSE_LIB( &DOSBase, &IDOS);
}


/****************************************************************************/

/*
 * Prototypes which contains also the stubs (glue code) - created by Weaver
 * by using keyword SDI.
 */

#include "test_protos.c"

/*
 * Now the real implementations for the library will follow:
 * This file must be written by you offering the library's functions.
 * You may, of course, include a list of source codes instead of this
 * lonely source code or, remove this source code in case your functions
 * already do exist as an object module.
 */

#include "functions.c"

/****************************************************************************/


/* Now the static part that does not require your assistance follows: */

#if defined(__amigaos4__)

LIBFUNC static struct TestLibrary *LibInit( struct TestLibrary *testBase,
											BPTR librarySegment,
											struct ExecIFace *pIExec);
LIBFUNC static BPTR   LibExpunge( struct LibraryManagerInterface *self);
LIBFUNC static struct TestLibrary *LibOpen( struct LibraryManagerInterface *self,
											ULONG version);
LIBFUNC static BPTR   LibClose( struct LibraryManagerInterface *self);
LIBFUNC static LONG   LibNull( void);

#elif defined(__MORPHOS__)

LIBFUNC static struct TestLibrary *LibInit( struct TestLibrary *testBase,
											BPTR librarySegment,
											struct ExecBase *sysBase);
LIBFUNC static BPTR   LibExpunge( void);
LIBFUNC static struct TestLibrary *LibOpen( void);
LIBFUNC static BPTR   LibClose( void);
LIBFUNC static LONG   LibNull( void);

#else

LIBFUNC static struct TestLibrary *LibInit( REG(a0, BPTR librarySegment),
											REG(d0, struct TestLibrary *testBase),
											REG(a6, struct ExecBase *sysBase));
LIBFUNC static BPTR   LibExpunge( REG(a6, struct TestLibrary *testBase));
LIBFUNC static struct TestLibrary *LibOpen( REG(a6, struct TestLibrary *testBase));
LIBFUNC static BPTR   LibClose( REG(a6, struct TestLibrary *testBase));
LIBFUNC static LONG   LibNull( void);

#endif

/****************************************************************************/

/*
 * Workaround - need a fallback in case we have to deal with empty slots -
 * see prototypes file, due to an insufficiency in the SDI-Headers macros.
 */
LONG libstub_LibNull()
{
	return 0;
}

/* The reserved function (LVO -24) */
LIBFUNC static LONG LibNull()
{
	return 0;
}

/****************************************************************************/

#if defined(__amigaos4__)
/* ------------------- OS4 Manager Interface ------------------------ */
STATIC ULONG LibObtain( struct LibraryManagerInterface *self)
{
	return (self->Data.RefCount ++);
}

STATIC ULONG LibRelease( struct LibraryManagerInterface *self)
{
	return (self->Data.RefCount --);
}

STATIC CONST APTR LibManagerVectors[] =
{
	(APTR) LibObtain,
	(APTR) LibRelease,
	(APTR) NULL,
	(APTR) NULL,
	(APTR) LibOpen,
	(APTR) LibClose,
	(APTR) LibExpunge,
	(APTR) NULL,
	(APTR) -1
};

STATIC CONST struct TagItem LibManagerTags[] =
{
	{MIT_Name, (ULONG) "__library"},
	{MIT_VectorTable, (ULONG) LibManagerVectors},
	{MIT_Version, 1},
	{TAG_DONE, 0}
};

/* ------------------- Library Interface(s) ------------------------ */

STATIC CONST APTR LibVectors[] =
{
	(APTR) LibObtain,
	(APTR) LibRelease,
	(APTR) NULL,
	(APTR) NULL,
	(APTR) libvector,
	(APTR) -1
};

STATIC CONST struct TagItem MainTags[] =
{
	{MIT_Name, (ULONG) "main"},
	{MIT_VectorTable, (ULONG) LibVectors},
	{MIT_Version, 1},
	{TAG_DONE, 0}
};

STATIC CONST ULONG LibInterfaces[] =
{
	(ULONG) LibManagerTags,
	(ULONG) MainTags,
	(ULONG) 0
};

/* OS4 libraries always have to carry a 68k jump table with it, so */
/* let's define it here: */
#ifndef NO_VECTABLE68K
#include "test_68k.c"			/* Created by Weaver (keyword 68K)*/
/* extern const APTR VecTable68K[]; */
#endif

STATIC CONST struct TagItem LibCreateTags[] =
{
	{CLT_DataSize, (ULONG) (sizeof (struct TestLibrary))},
	{CLT_InitFunc, (ULONG) LibInit},
	{CLT_Interfaces, (ULONG) LibInterfaces},
#ifndef NO_VECTABLE68K
	{CLT_Vector68K, (ULONG) VecTable68K},
#endif
	{TAG_DONE, 0}
};
		/* Ending AMIGA OS 4... */
#else	/* AMIGA OS 3 and MORPHOS start */

STATIC CONST APTR LibVectors[] =
{
#ifdef __MORPHOS__
	(APTR) FUNCARRAY_32BIT_NATIVE,
#endif
	(APTR) LibOpen,
	(APTR) LibClose,
	(APTR) LibExpunge,
	(APTR) LibNull,
	(APTR) libvector,
	(APTR) -1
};

STATIC CONST ULONG LibInitTab[] =
{
	sizeof (struct TestLibrary),
	(ULONG) LibVectors,
	(ULONG) NULL,
	(ULONG) LibInit
};

#endif	/* AMIGA OS 3 and MORPHOS */

/****************************************************************************/

/* For the old, OS3 compatible include files, we need the old alignment */
#if defined(__MORPHOS__)
#pragma pack(2)
#endif

static const USED_VAR struct Resident ROMTag =
{
	RTC_MATCHWORD,
	(struct Resident *) &ROMTag,
	(struct Resident *) &ROMTag + 1,
#if defined(__amigaos4__)
	/* The Library should be set up according to the given table */
	RTF_AUTOINIT | RTF_NATIVE,
#elif defined(__MORPHOS__)
	RTF_AUTOINIT | RTF_PPC,
#else
	RTF_AUTOINIT,
#endif
	LIB_VERSION,
	NT_LIBRARY,
	0,
	(char *) UserLibName,
	(char *) UserLibID + 6,
#if defined(__amigaos4__)
	/* This table is for initialising the library */
	(APTR) LibCreateTags
#else
	(APTR) LibInitTab,
#endif
#if defined(__MORPHOS__)
	LIB_REVISION,
	0
#endif
};

/* Do it normal aligned from now on */
#if defined(__MORPHOS__)
#pragma pack()
#endif


#if defined(__MORPHOS__)
/*
 * To tell the loader that this is a new emulppc elf and not
 * one for the ppc.library.
 * ** IMPORTANT **
 */
const USED_VAR ULONG __amigappc__ = 1;
const USED_VAR ULONG __abox__ = 1;

#endif /* MORPHOS */

/****************************************************************************/

#if defined(__amigaos4__)
static struct TestLibrary *LibInit( struct TestLibrary *testBase,
									BPTR librarySegment,
									struct ExecIFace *pIExec)
{
	struct ExecBase *sysBase = (struct ExecBase *)
								pIExec->Data.LibBase;
	IExec = pIExec;
#elif defined(__MORPHOS__)
static struct TestLibrary *LibInit( struct TestLibrary *testBase,
									BPTR librarySegment,
									struct ExecBase *sysBase)
{
#else
LIBFUNC static struct TestLibrary *LibInit( REG(a0, BPTR librarySegment),
											REG(d0, struct TestLibrary *testBase),
											REG(a6, struct ExecBase *sysBase))
{
#endif

	/* Indicator whether lib was already initialised */
	if (testBase->lb_SysBase != (struct Library *) sysBase)
	{
		/*
		 * Cleanup the library header structure beginning with the
		 * library base.
		 */
		testBase->lb_LibFrame.lib_Node.ln_Type = NT_LIBRARY;
		testBase->lb_LibFrame.lib_Node.ln_Pri = 0;
		testBase->lb_LibFrame.lib_Node.ln_Name = (char *) UserLibName;
		testBase->lb_LibFrame.lib_Flags = LIBF_CHANGED | LIBF_SUMUSED;
		testBase->lb_LibFrame.lib_Version = LIB_VERSION;
		testBase->lb_LibFrame.lib_Revision = LIB_REVISION;
		testBase->lb_LibFrame.lib_IdString = (char *) (UserLibID + 6);

		testBase->lb_SysBase = (APTR) sysBase;
		SysBase = (APTR) sysBase;
		testBase->lb_SegList = librarySegment;

		/*
		 * You may add a function, called UserInit(), that opens/allocates
		 * your private data.
		 * Return a value unequal zero for success and 0 if your
		 * initialisation failed.
		 */
		if ( (UserInit( testBase)) )
		{
			TestBase = testBase;		/* Establish global base pointer */
		}
		else
		{
			UserCleanup( testBase);
			/* User init failed, thus library isn't available */
			TestBase = NULL;
		}
	}

	return TestBase;		/* Base pointer or NULL */
}

/****************************************************************************/
#if defined(__amigaos4__)
static struct TestLibrary *LibOpen( struct LibraryManagerInterface *self,
									ULONG version UNUSED)
{
	struct TestLibrary *testBase = (struct TestLibrary *) self->Data.LibBase;
#elif defined(__MORPHOS__)
static struct TestLibrary *LibOpen( void)
{
	struct TestLibrary *testBase = (struct TestLibrary *) REG_A6;
#else
LIBFUNC static struct TestLibrary *LibOpen( REG(a6, struct TestLibrary *testBase))
{
#endif
	struct TestLibrary *res;

	/* Delete the late expunge flag */
	testBase->lb_LibFrame.lib_Flags &= ~LIBF_DELEXP;
	/* Increase the open counter */
	testBase->lb_LibFrame.lib_OpenCnt ++;

	/* return the base address on success. */
	res = testBase;

	return res;
}
/****************************************************************************/

#ifndef __amigaos4__
	#define DeleteLibrary(LIB) \
	FreeMem( (STRPTR)(LIB)-(LIB)->lib_NegSize, \
			 (ULONG)((LIB)->lib_NegSize+(LIB)->lib_PosSize))
#endif

#if defined(__amigaos4__)
static BPTR LibExpunge( struct LibraryManagerInterface *self)
{
	struct TestLibrary *testBase = (struct TestLibrary *) self->Data.LibBase;
#elif defined(__MORPHOS__)
static BPTR LibExpunge( void)
{
	struct TestLibrary *testBase = (struct TestLibrary *) REG_A6;
#else
LIBFUNC static BPTR LibExpunge( REG(a6, struct TestLibrary *testBase))
{
#endif

	BPTR rc = 0;

	/* In case our open counter is still > 0, we have */
	/* to set the late expunge flag and return immediately */
	if (testBase->lb_LibFrame.lib_OpenCnt > 0)
	{
		testBase->lb_LibFrame.lib_Flags |= LIBF_DELEXP;
	}
	else
	{
		/* In case the open counter is zero we can go */
		/* and remove/expunge the library. */
		/* SysBase = (APTR) testBase->lb_SysBase; */
		rc = testBase->lb_SegList;

		/* We expunge all our private data now. We haven't done */
		/* that in LibClose() already because we want to keep */
		/* our stuff kinda cached so that we don't have to */
		/* initialise our library all the time when a user */
		/* opens/closes the only app using this library. */

		/* Provide here your cleanup (counter part of UserInit() */
		UserCleanup( testBase);

		Remove( (struct Node *) testBase);
		DeleteLibrary( &testBase->lb_LibFrame);
	}

	return rc;
}

/****************************************************************************/

#if defined(__amigaos4__)
static BPTR LibClose( struct LibraryManagerInterface *self)
{
	struct TestLibrary *testBase = (struct TestLibrary *) self->Data.LibBase;
#elif defined(__MORPHOS__)
static BPTR LibClose( void)
{
	struct TestLibrary *testBase = (struct TestLibrary *) REG_A6;
#else
LIBFUNC static BPTR LibClose( REG(a6, struct TestLibrary *testBase))
{
#endif
	BPTR rc = 0;

	/* Decrease the open counter */
	testBase->lb_LibFrame.lib_OpenCnt --;

	/* In case the open counter is <= 0 we can */
	/* make sure that we free everything */
	if (testBase->lb_LibFrame.lib_OpenCnt <= 0)
	{
		/* In case the late expunge flag is set we go and */
		/* expunge the library base right now */
		if (testBase->lb_LibFrame.lib_Flags & LIBF_DELEXP)
		{
		#if defined(__amigaos4__)
			rc = LibExpunge( self);
		#elif defined(__MORPHOS__)
			rc = LibExpunge();
		#else
			rc = LibExpunge( testBase);
		#endif
		}
	}

	return rc;
}

/****************************************************************************/

/*
 * Thanks flow from my side to Jens Langner and Dirk Stoecker for creating
 * SDI-Headers. Without their incredible SDI-Headers it would have been
 * much harder for me to output with Weaver the source code for an
 * Amiga/MorphOS library.
 *
 * If you can, credit them for their work. It would be a nice move of yours.
 */
