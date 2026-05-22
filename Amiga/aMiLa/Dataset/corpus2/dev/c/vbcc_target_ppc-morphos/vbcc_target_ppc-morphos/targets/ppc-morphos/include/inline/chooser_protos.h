#ifndef _VBCCINLINE_CHOOSER_H
#define _VBCCINLINE_CHOOSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __CHOOSER_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CHOOSER_GetClass() __CHOOSER_GetClass(ChooserBase)

struct Node * __AllocChooserNodeA(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocChooserNodeA(tags) __AllocChooserNodeA(ChooserBase, (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Node * __linearvarargs __AllocChooserNode(void *, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocChooserNode(...) __AllocChooserNode(ChooserBase, __VA_ARGS__)
#endif

VOID __FreeChooserNode(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreeChooserNode(node) __FreeChooserNode(ChooserBase, (node))

VOID __SetChooserNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetChooserNodeAttrsA(node, tags) __SetChooserNodeAttrsA(ChooserBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetChooserNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetChooserNodeAttrs(...) __SetChooserNodeAttrs(ChooserBase, __VA_ARGS__)
#endif

VOID __GetChooserNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetChooserNodeAttrsA(node, tags) __GetChooserNodeAttrsA(ChooserBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GetChooserNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetChooserNodeAttrs(...) __GetChooserNodeAttrs(ChooserBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_CHOOSER_H  */
