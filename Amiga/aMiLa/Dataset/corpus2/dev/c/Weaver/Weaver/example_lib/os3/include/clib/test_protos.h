#ifndef CLIB_TEST_PROTOS_H
#define CLIB_TEST_PROTOS_H


/*
**	$VER: test_protos.h 1.3 (21.08.2009)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright (C) 2008/2009 Weaver Developers.
**  All rights reserved.
*/

#ifndef  INTUITION_SCREENS_H
#include <intuition/screens.h>
#endif

LONG Add(LONG a, LONG b);
LONG Sub(LONG a, LONG b);
struct Screen * CloneWBScr(void);
void CloseClonedWBScr(struct Screen * scr);
void GetClonedWBScrAttrA(struct Screen * scr, struct TagItem * tags);
void GetClonedWBScrAttr(struct Screen * scr, Tag tags, ...);

#endif	/*  CLIB_TEST_PROTOS_H  */
