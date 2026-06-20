#ifndef _VBCCINLINE_GADTOOLS_H
#define _VBCCINLINE_GADTOOLS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct Gadget * __CreateGadgetA(void *, ULONG kind, struct Gadget * gad, CONST struct NewGadget * ng, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CreateGadgetA(kind, gad, ng, taglist) __CreateGadgetA(GadToolsBase, (kind), (gad), (ng), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Gadget * __linearvarargs __CreateGadget(void *, ULONG kind, struct Gadget * gad, CONST struct NewGadget * ng, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define CreateGadget(kind, gad, ng, ...) __CreateGadget(GadToolsBase, (kind), (gad), (ng), __VA_ARGS__)
#endif

VOID __FreeGadgets(void *, struct Gadget * gad) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define FreeGadgets(gad) __FreeGadgets(GadToolsBase, (gad))

VOID __GT_SetGadgetAttrsA(void *, struct Gadget * gad, struct Window * win, struct Requester * req, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define GT_SetGadgetAttrsA(gad, win, req, taglist) __GT_SetGadgetAttrsA(GadToolsBase, (gad), (win), (req), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __GT_SetGadgetAttrs(void *, struct Gadget * gad, struct Window * win, struct Requester * req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define GT_SetGadgetAttrs(gad, win, req, ...) __GT_SetGadgetAttrs(GadToolsBase, (gad), (win), (req), __VA_ARGS__)
#endif

struct Menu * __CreateMenusA(void *, CONST struct NewMenu * newmenu, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define CreateMenusA(newmenu, taglist) __CreateMenusA(GadToolsBase, (newmenu), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct Menu * __linearvarargs __CreateMenus(void *, CONST struct NewMenu * newmenu, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define CreateMenus(newmenu, ...) __CreateMenus(GadToolsBase, (newmenu), __VA_ARGS__)
#endif

VOID __FreeMenus(void *, struct Menu * menu) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define FreeMenus(menu) __FreeMenus(GadToolsBase, (menu))

BOOL __LayoutMenuItemsA(void *, struct MenuItem * firstitem, APTR vi, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define LayoutMenuItemsA(firstitem, vi, taglist) __LayoutMenuItemsA(GadToolsBase, (firstitem), (vi), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __LayoutMenuItems(void *, struct MenuItem * firstitem, APTR vi, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define LayoutMenuItems(firstitem, vi, ...) __LayoutMenuItems(GadToolsBase, (firstitem), (vi), __VA_ARGS__)
#endif

BOOL __LayoutMenusA(void *, struct Menu * firstmenu, APTR vi, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define LayoutMenusA(firstmenu, vi, taglist) __LayoutMenusA(GadToolsBase, (firstmenu), (vi), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __LayoutMenus(void *, struct Menu * firstmenu, APTR vi, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define LayoutMenus(firstmenu, vi, ...) __LayoutMenus(GadToolsBase, (firstmenu), (vi), __VA_ARGS__)
#endif

struct IntuiMessage * __GT_GetIMsg(void *, struct MsgPort * iport) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define GT_GetIMsg(iport) __GT_GetIMsg(GadToolsBase, (iport))

VOID __GT_ReplyIMsg(void *, struct IntuiMessage * imsg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define GT_ReplyIMsg(imsg) __GT_ReplyIMsg(GadToolsBase, (imsg))

VOID __GT_RefreshWindow(void *, struct Window * win, struct Requester * req) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define GT_RefreshWindow(win, req) __GT_RefreshWindow(GadToolsBase, (win), (req))

VOID __GT_BeginRefresh(void *, struct Window * win) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define GT_BeginRefresh(win) __GT_BeginRefresh(GadToolsBase, (win))

VOID __GT_EndRefresh(void *, struct Window * win, LONG complete) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define GT_EndRefresh(win, complete) __GT_EndRefresh(GadToolsBase, (win), (complete))

struct IntuiMessage * __GT_FilterIMsg(void *, CONST struct IntuiMessage * imsg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define GT_FilterIMsg(imsg) __GT_FilterIMsg(GadToolsBase, (imsg))

struct IntuiMessage * __GT_PostFilterIMsg(void *, struct IntuiMessage * imsg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define GT_PostFilterIMsg(imsg) __GT_PostFilterIMsg(GadToolsBase, (imsg))

struct Gadget * __CreateContext(void *, struct Gadget ** glistptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define CreateContext(glistptr) __CreateContext(GadToolsBase, (glistptr))

VOID __DrawBevelBoxA(void *, struct RastPort * rport, LONG left, LONG top, LONG width, LONG height, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\tstw\t9,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define DrawBevelBoxA(rport, left, top, width, height, taglist) __DrawBevelBoxA(GadToolsBase, (rport), (left), (top), (width), (height), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __DrawBevelBox(void *, struct RastPort * rport, LONG left, LONG top, LONG width, LONG height, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,8(2)\n"
	"\tstw\t8,12(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define DrawBevelBox(rport, left, top, width, height, ...) __DrawBevelBox(GadToolsBase, (rport), (left), (top), (width), (height), __VA_ARGS__)
#endif

APTR __GetVisualInfoA(void *, struct Screen * screen, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define GetVisualInfoA(screen, taglist) __GetVisualInfoA(GadToolsBase, (screen), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
APTR __linearvarargs __GetVisualInfo(void *, struct Screen * screen, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define GetVisualInfo(screen, ...) __GetVisualInfo(GadToolsBase, (screen), __VA_ARGS__)
#endif

VOID __FreeVisualInfo(void *, APTR vi) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define FreeVisualInfo(vi) __FreeVisualInfo(GadToolsBase, (vi))

LONG __GT_GetGadgetAttrsA(void *, struct Gadget * gad, struct Window * win, struct Requester * req, CONST struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define GT_GetGadgetAttrsA(gad, win, req, taglist) __GT_GetGadgetAttrsA(GadToolsBase, (gad), (win), (req), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
LONG __linearvarargs __GT_GetGadgetAttrs(void *, struct Gadget * gad, struct Window * win, struct Requester * req, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define GT_GetGadgetAttrs(gad, win, req, ...) __GT_GetGadgetAttrs(GadToolsBase, (gad), (win), (req), __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_GADTOOLS_H  */
