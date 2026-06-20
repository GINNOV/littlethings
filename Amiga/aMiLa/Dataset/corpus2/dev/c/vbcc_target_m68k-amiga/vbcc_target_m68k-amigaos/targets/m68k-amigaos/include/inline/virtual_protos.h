#ifndef _VBCCINLINE_VIRTUAL_H
#define _VBCCINLINE_VIRTUAL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

Class * __VIRTUAL_GetClass(__reg("a6") void *)="\tjsr\t-30(a6)";
#define VIRTUAL_GetClass() __VIRTUAL_GetClass(VirtualBase)

VOID __RefreshVirtualGadget(__reg("a6") void *, __reg("a0") struct Gadget * gadget, __reg("a1") Object * obj, __reg("a2") struct Window * window, __reg("a3") struct Requester * requester)="\tjsr\t-36(a6)";
#define RefreshVirtualGadget(gadget, obj, window, requester) __RefreshVirtualGadget(VirtualBase, (gadget), (obj), (window), (requester))

BOOL __RethinkVirtualSize(__reg("a6") void *, __reg("a0") Object * virt_obj, __reg("a1") Object * rootlayout, __reg("a2") struct TextFont * font, __reg("a3") struct Screen * screen, __reg("d0") struct LayoutLimits * layoutlimits)="\tjsr\t-42(a6)";
#define RethinkVirtualSize(virt_obj, rootlayout, font, screen, layoutlimits) __RethinkVirtualSize(VirtualBase, (virt_obj), (rootlayout), (font), (screen), (layoutlimits))

#endif /*  _VBCCINLINE_VIRTUAL_H  */
