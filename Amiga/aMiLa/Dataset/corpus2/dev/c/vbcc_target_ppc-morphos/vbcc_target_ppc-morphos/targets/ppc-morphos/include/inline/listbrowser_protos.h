#ifndef _VBCCINLINE_LISTBROWSER_H
#define _VBCCINLINE_LISTBROWSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct IClass * __LISTBROWSER_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define LISTBROWSER_GetClass() __LISTBROWSER_GetClass(ListBrowserBase)

struct Node * __AllocListBrowserNodeA(void *, ULONG columns, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocListBrowserNodeA(columns, tags) __AllocListBrowserNodeA(ListBrowserBase, (columns), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Node * __linearvarargs __AllocListBrowserNode(void *, ULONG columns, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AllocListBrowserNode(...) __AllocListBrowserNode(ListBrowserBase, __VA_ARGS__)
#endif

VOID __FreeListBrowserNode(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreeListBrowserNode(node) __FreeListBrowserNode(ListBrowserBase, (node))

VOID __SetListBrowserNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetListBrowserNodeAttrsA(node, tags) __SetListBrowserNodeAttrsA(ListBrowserBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __SetListBrowserNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SetListBrowserNodeAttrs(...) __SetListBrowserNodeAttrs(ListBrowserBase, __VA_ARGS__)
#endif

VOID __GetListBrowserNodeAttrsA(void *, struct Node * node, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetListBrowserNodeAttrsA(node, tags) __GetListBrowserNodeAttrsA(ListBrowserBase, (node), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GetListBrowserNodeAttrs(void *, struct Node * node, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetListBrowserNodeAttrs(...) __GetListBrowserNodeAttrs(ListBrowserBase, __VA_ARGS__)
#endif

VOID __ListBrowserSelectAll(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define ListBrowserSelectAll(list) __ListBrowserSelectAll(ListBrowserBase, (list))

VOID __ShowListBrowserNodeChildren(void *, struct Node * node, LONG depth) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define ShowListBrowserNodeChildren(node, depth) __ShowListBrowserNodeChildren(ListBrowserBase, (node), (depth))

VOID __HideListBrowserNodeChildren(void *, struct Node * node) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define HideListBrowserNodeChildren(node) __HideListBrowserNodeChildren(ListBrowserBase, (node))

VOID __ShowAllListBrowserChildren(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define ShowAllListBrowserChildren(list) __ShowAllListBrowserChildren(ListBrowserBase, (list))

VOID __HideAllListBrowserChildren(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define HideAllListBrowserChildren(list) __HideAllListBrowserChildren(ListBrowserBase, (list))

VOID __FreeListBrowserList(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define FreeListBrowserList(list) __FreeListBrowserList(ListBrowserBase, (list))

struct ColumnInfo * __AllocLBColumnInfoA(void *, ULONG columns, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AllocLBColumnInfoA(columns, tags) __AllocLBColumnInfoA(ListBrowserBase, (columns), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct ColumnInfo * __linearvarargs __AllocLBColumnInfo(void *, ULONG columns, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define AllocLBColumnInfo(...) __AllocLBColumnInfo(ListBrowserBase, __VA_ARGS__)
#endif

LONG __SetLBColumnInfoAttrsA(void *, struct ColumnInfo * columninfo, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define SetLBColumnInfoAttrsA(columninfo, tags) __SetLBColumnInfoAttrsA(ListBrowserBase, (columninfo), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __SetLBColumnInfoAttrs(void *, struct ColumnInfo * columninfo, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define SetLBColumnInfoAttrs(...) __SetLBColumnInfoAttrs(ListBrowserBase, __VA_ARGS__)
#endif

LONG __GetLBColumnInfoAttrsA(void *, struct ColumnInfo * columninfo, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define GetLBColumnInfoAttrsA(columninfo, tags) __GetLBColumnInfoAttrsA(ListBrowserBase, (columninfo), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __GetLBColumnInfoAttrs(void *, struct ColumnInfo * columninfo, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define GetLBColumnInfoAttrs(...) __GetLBColumnInfoAttrs(ListBrowserBase, __VA_ARGS__)
#endif

VOID __FreeLBColumnInfo(void *, struct ColumnInfo * columninfo) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define FreeLBColumnInfo(columninfo) __FreeLBColumnInfo(ListBrowserBase, (columninfo))

VOID __ListBrowserClearAll(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define ListBrowserClearAll(list) __ListBrowserClearAll(ListBrowserBase, (list))

#endif /*  _VBCCINLINE_LISTBROWSER_H  */
