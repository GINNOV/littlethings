#ifndef _VBCCINLINE_LAYOUT_H
#define _VBCCINLINE_LAYOUT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __LAYOUT_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define LAYOUT_GetClass() __LAYOUT_GetClass(LayoutBase)

BOOL __ActivateLayoutGadget(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester, ULONG object) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ActivateLayoutGadget(gadget, window, requester, object) __ActivateLayoutGadget(LayoutBase, (gadget), (window), (requester), (object))

VOID __FlushLayoutDomainCache(void *, struct Gadget * gadget) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FlushLayoutDomainCache(gadget) __FlushLayoutDomainCache(LayoutBase, (gadget))

BOOL __RethinkLayout(void *, struct Gadget * gadget, struct Window * window, struct Requester * requester, LONG refresh) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define RethinkLayout(gadget, window, requester, refresh) __RethinkLayout(LayoutBase, (gadget), (window), (requester), (refresh))

VOID __LayoutLimits(void *, struct Gadget * gadget, struct LayoutLimits * limits, struct TextFont * font, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define LayoutLimits(gadget, limits, font, screen) __LayoutLimits(LayoutBase, (gadget), (limits), (font), (screen))

Class * __PAGE_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define PAGE_GetClass() __PAGE_GetClass(LayoutBase)

ULONG __SetPageGadgetAttrsA(void *, struct Gadget * gadget, Object * object, struct Window * window, struct Requester * requester, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,48(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SetPageGadgetAttrsA(gadget, object, window, requester, tags) __SetPageGadgetAttrsA(LayoutBase, (gadget), (object), (window), (requester), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __SetPageGadgetAttrs(void *, struct Gadget * gadget, Object * object, struct Window * window, struct Requester * requester, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SetPageGadgetAttrs(gadget, object, window, ...) __SetPageGadgetAttrs(LayoutBase, (gadget), (object), (window), __VA_ARGS__)
#endif

VOID __RefreshPageGadget(void *, struct Gadget * gadget, Object * object, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define RefreshPageGadget(gadget, object, window, requester) __RefreshPageGadget(LayoutBase, (gadget), (object), (window), (requester))

#endif /*  _VBCCINLINE_LAYOUT_H  */
