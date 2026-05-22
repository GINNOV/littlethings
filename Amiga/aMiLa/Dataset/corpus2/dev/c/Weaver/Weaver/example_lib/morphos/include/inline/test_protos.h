#ifndef _VBCCINLINE_TEST_H
#define _VBCCINLINE_TEST_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __Add(struct Library *, LONG a, LONG b) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-36\n"
	"\tblrl";
#define Add(a, b) __Add(TestBase, (a), (b))

LONG __Sub(struct Library *, LONG a, LONG b) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-42\n"
	"\tblrl";
#define Sub(a, b) __Sub(TestBase, (a), (b))

struct Screen * __CloneWBScr(struct Library *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tli\t3,-54\n"
	"\tblrl";
#define CloneWBScr() __CloneWBScr(TestBase)

void __CloseClonedWBScr(struct Library *, struct Screen * scr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tblrl";
#define CloseClonedWBScr(scr) __CloseClonedWBScr(TestBase, (scr))

void __GetClonedWBScrAttrA(struct Library *, struct Screen * scr, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-66\n"
	"\tblrl";
#define GetClonedWBScrAttrA(scr, tags) __GetClonedWBScrAttrA(TestBase, (scr), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __GetClonedWBScrAttr(struct Library *, long, long, long, long, long, long, struct Screen * scr, Tag tags, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtlr\t11\n"
	"\tstw\t10,32(2)\n"
	"\taddi\t4,1,8\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-66\n"
	"\tblrl";
#define GetClonedWBScrAttr(scr, ...) __GetClonedWBScrAttr(TestBase, 0, 0, 0, 0, 0, 0, (scr), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_TEST_H  */
