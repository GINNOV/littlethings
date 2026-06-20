/*
 * CLIB file automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


#ifndef CLIB_TEST_PROTOS_H
#define CLIB_TEST_PROTOS_H

/*
**
**    Copyright (C) 2008/2009 Weaver Developers.
**
**    All rights reserved.
**
*/


#include	<aros/libcall.h>
#include	<aros/preprocessor/variadic/cast2iptr.hpp>
#include	<exec/types.h>


/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


AROS_LP2( LONG, Add,
	AROS_LPA( LONG, a, D0),
	AROS_LPA( LONG, b, D1),
	LIBBASETYPEPTR, TestBase, 6, Test);

AROS_LP2( LONG, Sub,
	AROS_LPA( LONG, a, D0),
	AROS_LPA( LONG, b, D1),
	LIBBASETYPEPTR, TestBase, 7, Test);

AROS_LP0( struct Screen *, CloneWBScr,
	LIBBASETYPEPTR, TestBase, 9, Test);

AROS_LP1( void, CloseClonedWBScr,
	AROS_LPA( struct Screen *, scr, A0),
	LIBBASETYPEPTR, TestBase, 10, Test);

AROS_LP2( void, GetClonedWBScrAttrA,
	AROS_LPA( struct Screen *, scr, A0),
	AROS_LPA( struct TagItem *, tags, A1),
	LIBBASETYPEPTR, TestBase, 11, Test);

/* Just a VARARG stub for the real thing */
/* First, the prototype: */
void GetClonedWBScrAttr( struct Screen *scr, Tag tag1, ...);
/* Now, the created AROS VARARG (macro) function: */
#if !defined(NO_INLINE_STDARG) && !defined(TEST_NO_INLINE_STDARG)
#define GetClonedWBScrAttr( scr, ...)	\
({	\
	IPTR __args[] = { AROS_PP_VARIADIC_CAST2IPTR(__VA_ARGS__) };	\
	GetClonedWBScrAttrA( (scr), ((struct TagItem *) __args) );	\
})
#endif
#endif		/* CLIB_TEST_PROTOS_H */
