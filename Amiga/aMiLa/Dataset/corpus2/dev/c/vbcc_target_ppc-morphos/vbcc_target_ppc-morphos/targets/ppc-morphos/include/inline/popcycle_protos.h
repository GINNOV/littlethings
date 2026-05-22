#ifndef _VBCCINLINE_POPCYCLE_H
#define _VBCCINLINE_POPCYCLE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __POPCYCLE_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define POPCYCLE_GetClass() __POPCYCLE_GetClass(PopCycleBase)

struct Node * __AllocPopCycleNodeA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocPopCycleNodeA(tags) __AllocPopCycleNodeA(PopCycleBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Node * __linearvarargs __AllocPopCycleNode(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocPopCycleNode(...) __AllocPopCycleNode(PopCycleBase, __VA_ARGS__)
#endif

VOID __FreePopCycleNode(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreePopCycleNode(node) __FreePopCycleNode(PopCycleBase, (node))

VOID __SetPopCycleNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetPopCycleNodeAttrsA(node, tags) __SetPopCycleNodeAttrsA(PopCycleBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetPopCycleNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetPopCycleNodeAttrs(...) __SetPopCycleNodeAttrs(PopCycleBase, __VA_ARGS__)
#endif

VOID __GetPopCycleNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetPopCycleNodeAttrsA(node, tags) __GetPopCycleNodeAttrsA(PopCycleBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GetPopCycleNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetPopCycleNodeAttrs(...) __GetPopCycleNodeAttrs(PopCycleBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_POPCYCLE_H  */
