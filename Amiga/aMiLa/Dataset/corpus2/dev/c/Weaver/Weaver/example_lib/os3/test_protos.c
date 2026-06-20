#ifndef		TEST_PROTOS_DEV_H
#define		TEST_PROTOS_DEV_H

#ifndef		__AROS__		/* This header is useless for AROS */

/* We need for MorphOS some PPC instructions dealing with 68k code */
#if defined(__MORPHOS__)
#include	<emul/emulregs.h>
#endif

#include <SDI_stdarg.h>

/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


/* This library prototypes for all Operating Systems (OS3, MorphOS, OS4) except AROS */

LIBPROTO( Add, LONG, REG(d0, LONG a), REG(d1, LONG b));
LIBPROTO( Sub, LONG, REG(d0, LONG a), REG(d1, LONG b));
/* Workaround necessary because SDI-Headers macros don't deal with empty argument lists */
#if defined(__MORPHOS__) || defined(__amigaos4__)
struct Screen * libstub_CloneWBScr();
struct Screen * CloneWBScr();
#else
SAVEDS ASM struct Screen * libstub_CloneWBScr();
SAVEDS ASM struct Screen * CloneWBScr();
#endif
LIBPROTO( CloseClonedWBScr, void, REG(a0, struct Screen * scr));
LIBPROTO( GetClonedWBScrAttrA, void, REG(a0, struct Screen * scr), REG(a1, struct TagItem * tags));
#if defined(__amigaos4__)		/* Just a VARARG stub for the real thing */
LIBPROTOVA( GetClonedWBScrAttr, void, REG(a0, struct Screen * scr), ...);
#endif							/* AMIGA OS4 VARARG */


/* Workaround for reserved functions - using library's reserved function */
#if defined(__MORPHOS__) || defined(__amigaos4__)
static LONG LibNull();
#else
SAVEDS ASM static LONG LibNull();
#endif


/* Define the library vector offsets */
#if !defined(__amigaos4__)
#define libvector	LFUNC_FAS(LibNull)		\
					LFUNC_FA_(Add)		\
					LFUNC_FA_(Sub)		\
					LFUNC_FA_(LibNull)		\
					LFUNC_FA_(CloneWBScr)		\
					LFUNC_FA_(CloseClonedWBScr)		\
					LFUNC_FA_(GetClonedWBScrAttrA)
#endif

/* Same as above but specifically targetting towards AmigaOS4 */
#if defined(__amigaos4__)
#define libvector	LFUNC_FAS(LibNull)		\
					LFUNC_FA_(Add)		\
					LFUNC_FA_(Sub)		\
					LFUNC_FA_(LibNull)		\
					LFUNC_FA_(CloneWBScr)		\
					LFUNC_FA_(CloseClonedWBScr)		\
					LFUNC_FA_(GetClonedWBScrAttrA)		\
					/* Just a VARARG stub for the real thing */		\
					LFUNC_VA_(GetClonedWBScrAttr)
#endif


/* OS4 and MorphOS need stub-functions which call the real thing - in contrast to OS3 */

#if defined(__MORPHOS__) || defined(__amigaos4__)

LIBPROTO( Add, LONG, REG(d0, LONG a), REG(d1, LONG b))
{
	#if defined(__MORPHOS__)
	return Add( (LONG) REG_D0, (LONG) REG_D1);
	#else
	return Add( a, b);
	#endif
}

LIBPROTO( Sub, LONG, REG(d0, LONG a), REG(d1, LONG b))
{
	#if defined(__MORPHOS__)
	return Sub( (LONG) REG_D0, (LONG) REG_D1);
	#else
	return Sub( a, b);
	#endif
}

/* Workaround for SDI-Header macros, which don't deal with empty argument lists */
struct Screen * libstub_CloneWBScr()
{
	#if defined(__MORPHOS__)
	return CloneWBScr();
	#else
	return CloneWBScr();
	#endif
}

LIBPROTO( CloseClonedWBScr, void, REG(a0, struct Screen * scr))
{
	#if defined(__MORPHOS__)
	CloseClonedWBScr( (struct Screen *) REG_A0);
	#else
	CloseClonedWBScr( scr);
	#endif
}

LIBPROTO( GetClonedWBScrAttrA, void, REG(a0, struct Screen * scr), REG(a1, struct TagItem * tags))
{
	#if defined(__MORPHOS__)
	GetClonedWBScrAttrA( (struct Screen *) REG_A0, (struct TagItem *) REG_A1);
	#else
	GetClonedWBScrAttrA( scr, tags);
	#endif
}

#if defined(__amigaos4__)		/* Just a VARARG stub for the real thing */
LIBPROTOVA( GetClonedWBScrAttr, void, REG( a0, struct Screen * scr), ...)
{
	VA_LIST _var_args;

	VA_START( _var_args, scr);

	GetClonedWBScrAttrA( scr, VA_ARG( _var_args, struct TagItem *) );

	VA_END( _var_args);

}
#endif	/* AMIGA OS4 VARARG */

#endif		/* OS4 and MorphOS */

#endif		/* AROS */

#endif		/* TEST_PROTOS_DEV_H */
