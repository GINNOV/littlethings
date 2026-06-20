/*
 * DEFINE file automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


#ifndef DEFINES_TEST_PROTOS_H
#define DEFINES_TEST_PROTOS_H

/*
**
**    Copyright (C) 2008/2009 Weaver Developers.
**
**    All rights reserved.
**
*/


#include	<aros/libcall.h>
#include	<exec/types.h>


/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


#define __Add_WB(__TestBase, __arg1, __arg2) \
	AROS_LC2( LONG, Add, \
		AROS_LCA( LONG, (__arg1), D0),	\
		AROS_LCA( LONG, (__arg2), D1),	\
	struct Library *, (__TestBase), 6, Test)

#define Add( arg1, arg2) \
	__Add_WB( TestBase, (arg1), (arg2))


#define __Sub_WB(__TestBase, __arg1, __arg2) \
	AROS_LC2( LONG, Sub, \
		AROS_LCA( LONG, (__arg1), D0),	\
		AROS_LCA( LONG, (__arg2), D1),	\
	struct Library *, (__TestBase), 7, Test)

#define Sub( arg1, arg2) \
	__Sub_WB( TestBase, (arg1), (arg2))


#define __CloneWBScr_WB(__TestBase) \
	AROS_LC0( struct Screen *, CloneWBScr, \
	struct Library *, (__TestBase), 9, Test)

#define CloneWBScr() \
	__CloneWBScr_WB( TestBase)


#define __CloseClonedWBScr_WB(__TestBase, __arg1) \
	AROS_LC1( void, CloseClonedWBScr, \
		AROS_LCA( struct Screen *, (__arg1), A0),	\
	struct Library *, (__TestBase), 10, Test)

#define CloseClonedWBScr( arg1) \
	__CloseClonedWBScr_WB( TestBase, (arg1))


#define __GetClonedWBScrAttrA_WB(__TestBase, __arg1, __arg2) \
	AROS_LC2( void, GetClonedWBScrAttrA, \
		AROS_LCA( struct Screen *, (__arg1), A0),	\
		AROS_LCA( struct TagItem *, (__arg2), A1),	\
	struct Library *, (__TestBase), 11, Test)

#define GetClonedWBScrAttrA( arg1, arg2) \
	__GetClonedWBScrAttrA_WB( TestBase, (arg1), (arg2))


#endif		/* DEFINES_TEST_PROTOS_H */
