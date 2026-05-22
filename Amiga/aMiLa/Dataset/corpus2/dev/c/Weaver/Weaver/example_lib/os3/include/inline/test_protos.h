#ifndef _VBCCINLINE_TEST_H
#define _VBCCINLINE_TEST_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

LONG __Add(__reg("a6") struct Library *, __reg("d0") LONG a, __reg("d1") LONG b)="\tjsr\t-36(a6)";
#define Add(a, b) __Add(TestBase, (a), (b))

LONG __Sub(__reg("a6") struct Library *, __reg("d0") LONG a, __reg("d1") LONG b)="\tjsr\t-42(a6)";
#define Sub(a, b) __Sub(TestBase, (a), (b))

struct Screen * __CloneWBScr(__reg("a6") struct Library *)="\tjsr\t-54(a6)";
#define CloneWBScr() __CloneWBScr(TestBase)

void __CloseClonedWBScr(__reg("a6") struct Library *, __reg("a0") struct Screen * scr)="\tjsr\t-60(a6)";
#define CloseClonedWBScr(scr) __CloseClonedWBScr(TestBase, (scr))

void __GetClonedWBScrAttrA(__reg("a6") struct Library *, __reg("a0") struct Screen * scr, __reg("a1") struct TagItem * tags)="\tjsr\t-66(a6)";
#define GetClonedWBScrAttrA(scr, tags) __GetClonedWBScrAttrA(TestBase, (scr), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __GetClonedWBScrAttr(__reg("a6") struct Library *, __reg("a0") struct Screen * scr, Tag tags, ...)="\tmove.l\ta1,-(a7)\n\tlea\t4(a7),a1\n\tjsr\t-66(a6)\n\tmovea.l\t(a7)+,a1";
#define GetClonedWBScrAttr(scr, ...) __GetClonedWBScrAttr(TestBase, (scr), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_TEST_H  */
