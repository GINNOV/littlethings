#ifndef _VBCCINLINE_CLICKTAB_H
#define _VBCCINLINE_CLICKTAB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __CLICKTAB_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CLICKTAB_GetClass() __CLICKTAB_GetClass(ClickTabBase)

struct Node * __AllocClickTabNodeA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocClickTabNodeA(tags) __AllocClickTabNodeA(ClickTabBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Node * __linearvarargs __AllocClickTabNode(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocClickTabNode(...) __AllocClickTabNode(ClickTabBase, __VA_ARGS__)
#endif

VOID __FreeClickTabNode(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreeClickTabNode(node) __FreeClickTabNode(ClickTabBase, (node))

VOID __SetClickTabNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetClickTabNodeAttrsA(node, tags) __SetClickTabNodeAttrsA(ClickTabBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetClickTabNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetClickTabNodeAttrs(...) __SetClickTabNodeAttrs(ClickTabBase, __VA_ARGS__)
#endif

VOID __GetClickTabNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetClickTabNodeAttrsA(node, tags) __GetClickTabNodeAttrsA(ClickTabBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GetClickTabNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetClickTabNodeAttrs(...) __GetClickTabNodeAttrs(ClickTabBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_CLICKTAB_H  */
