#ifndef _VBCCINLINE_PPCDISS_H
#define _VBCCINLINE_PPCDISS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __PPCDissCreateObjectTagList(void *, struct  TagItem * TagList) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define PPCDissCreateObjectTagList(TagList) __PPCDissCreateObjectTagList(PPCDissBase, (TagList))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __PPCDissCreateObjectTags(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define PPCDissCreateObjectTags(...) __PPCDissCreateObjectTags(PPCDissBase, __VA_ARGS__)
#endif

void __PPCDissDeleteObject(void *, APTR Object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define PPCDissDeleteObject(Object) __PPCDissDeleteObject(PPCDissBase, (Object))

#endif /*  _VBCCINLINE_PPCDISS_H  */
