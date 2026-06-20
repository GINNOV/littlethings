/*
 * OS4 INLINE4 synonym file automatically created by Weaver
 * "Weaver" was written using "vbcc"
 */


#ifndef		INLINE4_TEST_H
#define		INLINE4_TEST_H

/*
**
**    Copyright (C) 2008/2009 Weaver Developers.
**
**    All rights reserved.
**
*/


#include <exec/interfaces.h>


/* Custom includes specified in SFD file */
#include	<intuition/screens.h>


#include	<interfaces/test.h>

/* These inline macros do only support the "main" interface (due to limits of SFD files, sorry). */

#define Add( a, b) ITest->Add( (a), (b))
#define Sub( a, b) ITest->Sub( (a), (b))
#define CloneWBScr() ITest->CloneWBScr()
#define CloseClonedWBScr( scr) ITest->CloseClonedWBScr( (scr))
#define GetClonedWBScrAttrA( scr, tags) ITest->GetClonedWBScrAttrA( (scr), (tags))
/* Just a VARARG stub for the real thing - that is using a tag-list! */
#if (defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L) || (__GNUC__ >= 3)
	#define GetClonedWBScrAttr( ...) ITest->GetClonedWBScrAttr( __VA_ARGS__)
#elif (__GNUC__ == 2 && __GNUC_MINOR__ >= 95)
	#define GetClonedWBScrAttr( vargs...) ITest->GetClonedWBScrAttr( ## vargs)
#endif

#endif		/* INLINE4_TEST_H */
