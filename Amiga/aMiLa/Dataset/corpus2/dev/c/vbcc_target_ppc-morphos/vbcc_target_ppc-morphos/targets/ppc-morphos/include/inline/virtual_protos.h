#ifndef _VBCCINLINE_VIRTUAL_H
#define _VBCCINLINE_VIRTUAL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct IClass * __VIRTUAL_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define VIRTUAL_GetClass() __VIRTUAL_GetClass(VirtualBase)

VOID __RefreshVirtualGadget(void *, struct Gadget * gadget, ULONG obj, struct Window * window, struct Requester * requester) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define RefreshVirtualGadget(gadget, obj, window, requester) __RefreshVirtualGadget(VirtualBase, (gadget), (obj), (window), (requester))

BOOL __RethinkVirtualSize(void *, ULONG virt_obj, ULONG rootlayout, struct TextFont * font, struct Screen * screen, struct LayoutLimits * layoutlimits) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define RethinkVirtualSize(virt_obj, rootlayout, font, screen, layoutlimits) __RethinkVirtualSize(VirtualBase, (virt_obj), (rootlayout), (font), (screen), (layoutlimits))

#endif /*  _VBCCINLINE_VIRTUAL_H  */
