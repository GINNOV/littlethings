#ifndef _VBCCINLINE_SPEEDBAR_H
#define _VBCCINLINE_SPEEDBAR_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __SPEEDBAR_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define SPEEDBAR_GetClass() __SPEEDBAR_GetClass(SpeedBarBase)

struct Node * __AllocSpeedButtonNodeA(void *, ULONG number, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocSpeedButtonNodeA(number, tags) __AllocSpeedButtonNodeA(SpeedBarBase, (number), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Node * __linearvarargs __AllocSpeedButtonNode(void *, ULONG number, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocSpeedButtonNode(number, ...) __AllocSpeedButtonNode(SpeedBarBase, (number), __VA_ARGS__)
#endif

VOID __FreeSpeedButtonNode(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreeSpeedButtonNode(node) __FreeSpeedButtonNode(SpeedBarBase, (node))

VOID __SetSpeedButtonNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetSpeedButtonNodeAttrsA(node, tags) __SetSpeedButtonNodeAttrsA(SpeedBarBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetSpeedButtonNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetSpeedButtonNodeAttrs(...) __SetSpeedButtonNodeAttrs(SpeedBarBase, __VA_ARGS__)
#endif

VOID __GetSpeedButtonNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetSpeedButtonNodeAttrsA(node, tags) __GetSpeedButtonNodeAttrsA(SpeedBarBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GetSpeedButtonNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetSpeedButtonNodeAttrs(...) __GetSpeedButtonNodeAttrs(SpeedBarBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_SPEEDBAR_H  */
