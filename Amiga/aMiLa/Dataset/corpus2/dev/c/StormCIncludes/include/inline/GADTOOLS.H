#ifndef _INLINE_GADTOOLS_H
#define _INLINE_GADTOOLS_H

#ifndef GADTOOLS_BASE_NAME
#define GADTOOLS_BASE_NAME GadToolsBase
#endif

#define CreateGadgetA(kind, gad, ng, taglist) \
	((struct Gadget * (*)(ULONG __asm("d0"), struct Gadget * __asm("a0"), CONST struct NewGadget * __asm("a1"), CONST struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 30))(kind, gad, ng, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateGadget(kind, gad, ng, tags...) \
	({ULONG _tags[] = {tags}; CreateGadgetA((kind), (gad), (ng), (Tag) _tags);})
#endif

#define FreeGadgets(gad) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 36))(gad, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_SetGadgetAttrsA(gad, win, req, taglist) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), CONST struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 42))(gad, win, req, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GT_SetGadgetAttrs(gad, win, req, tags...) \
	({ULONG _tags[] = {tags}; GT_SetGadgetAttrsA((gad), (win), (req), (Tag) _tags);})
#endif

#define CreateMenusA(newmenu, taglist) \
	((struct Menu * (*)(CONST struct NewMenu * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 48))(newmenu, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CreateMenus(newmenu, tags...) \
	({ULONG _tags[] = {tags}; CreateMenusA((newmenu), (Tag) _tags);})
#endif

#define FreeMenus(menu) \
	((VOID (*)(struct Menu * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 54))(menu, (struct Library *) GADTOOLS_BASE_NAME)

#define LayoutMenuItemsA(firstitem, vi, taglist) \
	((BOOL (*)(struct MenuItem * __asm("a0"), APTR __asm("a1"), CONST struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 60))(firstitem, vi, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define LayoutMenuItems(firstitem, vi, tags...) \
	({ULONG _tags[] = {tags}; LayoutMenuItemsA((firstitem), (vi), (Tag) _tags);})
#endif

#define LayoutMenusA(firstmenu, vi, taglist) \
	((BOOL (*)(struct Menu * __asm("a0"), APTR __asm("a1"), CONST struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 66))(firstmenu, vi, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define LayoutMenus(firstmenu, vi, tags...) \
	({ULONG _tags[] = {tags}; LayoutMenusA((firstmenu), (vi), (Tag) _tags);})
#endif

#define GT_GetIMsg(iport) \
	((struct IntuiMessage * (*)(struct MsgPort * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 72))(iport, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_ReplyIMsg(imsg) \
	((VOID (*)(struct IntuiMessage * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 78))(imsg, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_RefreshWindow(win, req) \
	((VOID (*)(struct Window * __asm("a0"), struct Requester * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 84))(win, req, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_BeginRefresh(win) \
	((VOID (*)(struct Window * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 90))(win, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_EndRefresh(win, complete) \
	((VOID (*)(struct Window * __asm("a0"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 96))(win, complete, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_FilterIMsg(imsg) \
	((struct IntuiMessage * (*)(CONST struct IntuiMessage * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 102))(imsg, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_PostFilterIMsg(imsg) \
	((struct IntuiMessage * (*)(struct IntuiMessage * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 108))(imsg, (struct Library *) GADTOOLS_BASE_NAME)

#define CreateContext(glistptr) \
	((struct Gadget * (*)(struct Gadget ** __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 114))(glistptr, (struct Library *) GADTOOLS_BASE_NAME)

#define DrawBevelBoxA(rport, left, top, width, height, taglist) \
	((VOID (*)(struct RastPort * __asm("a0"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 120))(rport, left, top, width, height, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DrawBevelBox(rport, left, top, width, height, tags...) \
	({ULONG _tags[] = {tags}; DrawBevelBoxA((rport), (left), (top), (width), (height), (Tag) _tags);})
#endif

#define GetVisualInfoA(screen, taglist) \
	((APTR (*)(struct Screen * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 126))(screen, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetVisualInfo(screen, tags...) \
	({ULONG _tags[] = {tags}; GetVisualInfoA((screen), (Tag) _tags);})
#endif

#define FreeVisualInfo(vi) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 132))(vi, (struct Library *) GADTOOLS_BASE_NAME)

#define GT_GetGadgetAttrsA(gad, win, req, taglist) \
	((LONG (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), CONST struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) GADTOOLS_BASE_NAME) - 174))(gad, win, req, taglist, (struct Library *) GADTOOLS_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GT_GetGadgetAttrs(gad, win, req, tags...) \
	({ULONG _tags[] = {tags}; GT_GetGadgetAttrsA((gad), (win), (req), (Tag) _tags);})
#endif

#endif /*  _INLINE_GADTOOLS_H  */
