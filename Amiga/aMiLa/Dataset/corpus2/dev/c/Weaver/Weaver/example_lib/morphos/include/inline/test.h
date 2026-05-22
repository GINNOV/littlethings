#ifndef _PPCINLINE_TEST_H
#define _PPCINLINE_TEST_H

#ifndef CLIB_TEST_PROTOS_H
#define CLIB_TEST_PROTOS_H
#endif

#ifndef __PPCINLINE_MACROS_H
#include <ppcinline/macros.h>
#endif

#ifndef  INTUITION_SCREENS_H
#include <intuition/screens.h>
#endif

#ifndef TEST_BASE_NAME
#define TEST_BASE_NAME TestBase
#endif

#define Add(a, b) \
	LP2(0x24, LONG, Add, LONG, a, d0, LONG, b, d1, \
	, TEST_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define Sub(a, b) \
	LP2(0x2a, LONG, Sub, LONG, a, d0, LONG, b, d1, \
	, TEST_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define CloneWBScr() \
	LP0(0x36, struct Screen *, CloneWBScr, \
	, TEST_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define CloseClonedWBScr(scr) \
	LP1NR(0x3c, CloseClonedWBScr, struct Screen *, scr, a0, \
	, TEST_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#define GetClonedWBScrAttrA(scr, tags) \
	LP2NR(0x42, GetClonedWBScrAttrA, struct Screen *, scr, a0, struct TagItem *, tags, a1, \
	, TEST_BASE_NAME, IF_CACHEFLUSHALL, NULL, 0, IF_CACHEFLUSHALL, NULL, 0)

#ifndef NO_PPCINLINE_STDARG
#define GetClonedWBScrAttr(scr, tags...) \
	({ULONG _tags[] = {tags}; GetClonedWBScrAttrA((scr), (struct TagItem *) _tags);})
#endif

#endif /*  _PPCINLINE_TEST_H  */
