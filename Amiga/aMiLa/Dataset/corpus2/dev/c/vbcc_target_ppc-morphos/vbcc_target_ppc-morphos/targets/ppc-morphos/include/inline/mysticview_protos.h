#ifndef _VBCCINLINE_MYSTICVIEW_H
#define _VBCCINLINE_MYSTICVIEW_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __MV_CreateA(void *, struct Screen * screen, struct RastPort * a1arg, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define MV_CreateA(screen, a1arg, tags) __MV_CreateA(MysticBase, (screen), (a1arg), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __MV_Create(void *, struct Screen * screen, struct RastPort * a1arg, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define MV_Create(screen, ...) __MV_Create(MysticBase, (screen), __VA_ARGS__)
#endif

void __MV_Delete(void *, APTR mview) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define MV_Delete(mview) __MV_Delete(MysticBase, (mview))

void __MV_SetAttrsA(void *, APTR mview, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define MV_SetAttrsA(mview, tags) __MV_SetAttrsA(MysticBase, (mview), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __MV_SetAttrs(void *, APTR mview, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define MV_SetAttrs(...) __MV_SetAttrs(MysticBase, __VA_ARGS__)
#endif

BOOL __MV_DrawOn(void *, APTR mview) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define MV_DrawOn(mview) __MV_DrawOn(MysticBase, (mview))

void __MV_DrawOff(void *, APTR mview) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define MV_DrawOff(mview) __MV_DrawOff(MysticBase, (mview))

void __MV_Refresh(void *, APTR mview) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define MV_Refresh(mview) __MV_Refresh(MysticBase, (mview))

void __MV_GetAttrsA(void *, APTR mview, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define MV_GetAttrsA(mview, tags) __MV_GetAttrsA(MysticBase, (mview), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
void __linearvarargs __MV_GetAttrs(void *, APTR mview, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define MV_GetAttrs(...) __MV_GetAttrs(MysticBase, __VA_ARGS__)
#endif

void __MV_SetViewStart(void *, APTR mview, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define MV_SetViewStart(mview, x, y) __MV_SetViewStart(MysticBase, (mview), (x), (y))

void __MV_SetViewRelative(void *, APTR mview, LONG x, LONG y) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define MV_SetViewRelative(mview, x, y) __MV_SetViewRelative(MysticBase, (mview), (x), (y))

#endif /*  _VBCCINLINE_MYSTICVIEW_H  */
