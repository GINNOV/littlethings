#ifndef _INLINE_WIZARD_H
#define _INLINE_WIZARD_H

#ifndef WIZARD_BASE_NAME
#define WIZARD_BASE_NAME WizardBase
#endif

#define WZ_OpenSurfaceA(name, memaddr, tagList) \
	((APTR (*)(STRPTR __asm("a0"), APTR __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 30))(name, memaddr, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_OpenSurface(name, memaddr, tags...) \
	({ULONG _tags[] = {tags}; WZ_OpenSurfaceA((name), (memaddr), (Tag) _tags);})
#endif

#define WZ_CloseSurface(surface) \
	((void (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 36))(surface, (struct Library *) WIZARD_BASE_NAME)

#define WZ_AllocWindowHandleA(screen, user_sizeof, surface, tagList) \
	((struct WizardWindowHandle * (*)(struct Screen * __asm("d0"), ULONG __asm("d1"), APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 42))(screen, user_sizeof, surface, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_AllocWindowHandle(screen, user_sizeof, surface, tags...) \
	({ULONG _tags[] = {tags}; WZ_AllocWindowHandleA((screen), (user_sizeof), (surface), (Tag) _tags);})
#endif

#define WZ_CreateWindowObjA(winhandle, id, tagList) \
	((struct NewWindow * (*)(struct WizardWindowHandle * __asm("a0"), ULONG __asm("d0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 48))(winhandle, id, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_CreateWindowObj(winhandle, id, tags...) \
	({ULONG _tags[] = {tags}; WZ_CreateWindowObjA((winhandle), (id), (Tag) _tags);})
#endif

#define WZ_OpenWindowA(winhandle, newwin, tagList) \
	((struct Window * (*)(struct WizardWindowHandle * __asm("a0"), struct NewWindow * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 54))(winhandle, newwin, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_OpenWindow(winhandle, newwin, tags...) \
	({ULONG _tags[] = {tags}; WZ_OpenWindowA((winhandle), (newwin), (Tag) _tags);})
#endif

#define WZ_CloseWindow(winhandle) \
	((void (*)(struct WizardWindowHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 60))(winhandle, (struct Library *) WIZARD_BASE_NAME)

#define WZ_FreeWindowHandle(winhandle) \
	((void (*)(struct WizardWindowHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 66))(winhandle, (struct Library *) WIZARD_BASE_NAME)

#define WZ_LockWindow(winhandle) \
	((void (*)(struct WizardWindowHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 72))(winhandle, (struct Library *) WIZARD_BASE_NAME)

#define WZ_UnlockWindow(winhandle) \
	((ULONG (*)(struct WizardWindowHandle * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 78))(winhandle, (struct Library *) WIZARD_BASE_NAME)

#define WZ_LockWindows(surface) \
	((void (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 84))(surface, (struct Library *) WIZARD_BASE_NAME)

#define WZ_UnlockWindows(surface) \
	((void (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 90))(surface, (struct Library *) WIZARD_BASE_NAME)

#define WZ_GadgetHelp(windowhandle, sfgadget) \
	((STRPTR (*)(struct WizardWindowHandle * __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 96))(windowhandle, sfgadget, (struct Library *) WIZARD_BASE_NAME)

#define WZ_GadgetConfig(windowhandle, sfgadget) \
	((STRPTR (*)(struct WizardWindowHandle * __asm("a0"), struct Gadget * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 102))(windowhandle, sfgadget, (struct Library *) WIZARD_BASE_NAME)

#define WZ_MenuHelp(windowhandle, menucode) \
	((STRPTR (*)(struct WizardWindowHandle * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 108))(windowhandle, menucode, (struct Library *) WIZARD_BASE_NAME)

#define WZ_MenuConfig(windowhandle, menucode) \
	((STRPTR (*)(struct WizardWindowHandle * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 114))(windowhandle, menucode, (struct Library *) WIZARD_BASE_NAME)

#define WZ_InitEasyStruct(surface, easystruct, id, size) \
	((struct EasyStruct * (*)(APTR __asm("a0"), struct EasyStruct * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 120))(surface, easystruct, id, size, (struct Library *) WIZARD_BASE_NAME)

#define WZ_SnapShotA(surface, tagList) \
	((BOOL (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 126))(surface, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_SnapShot(surface, tags...) \
	({ULONG _tags[] = {tags}; WZ_SnapShotA((surface), (Tag) _tags);})
#endif

#define WZ_GadgetKeyA(windowhandle, code, qualifier, tagList) \
	((BOOL (*)(struct WizardWindowHandle * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 132))(windowhandle, code, qualifier, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_GadgetKey(windowhandle, code, qualifier, tags...) \
	({ULONG _tags[] = {tags}; WZ_GadgetKeyA((windowhandle), (code), (qualifier), (Tag) _tags);})
#endif

#define WZ_DrawVImageA(vimage, x, y, w, h, type, rp, drinfo, tagList) \
	((BOOL (*)(struct WizardVImage * __asm("a0"), WORD __asm("d0"), WORD __asm("d1"), WORD __asm("d2"), WORD __asm("d3"), WORD __asm("d4"), struct RastPort * __asm("d5"), struct DrawInfo * __asm("d6"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 138))(vimage, x, y, w, h, type, rp, drinfo, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_DrawVImage(vimage, x, y, w, h, type, rp, drinfo, tags...) \
	({ULONG _tags[] = {tags}; WZ_DrawVImageA((vimage), (x), (y), (w), (h), (type), (rp), (drinfo), (Tag) _tags);})
#endif

#define WZ_EasyRequestArgs(surface, window, id, args) \
	((LONG (*)(APTR __asm("a0"), struct Window * __asm("a1"), ULONG __asm("d0"), void * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 144))(surface, window, id, args, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_EasyRequest(surface, window, id, tags...) \
	({ULONG _tags[] = {tags}; WZ_EasyRequestArgs((surface), (window), (id), () _tags);})
#endif

#define WZ_GetNode(minlist, nr) \
	((struct WizardNode * (*)(struct MinList * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 150))(minlist, nr, (struct Library *) WIZARD_BASE_NAME)

#define WZ_ListCount(list) \
	((ULONG (*)(struct MinList * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 156))(list, (struct Library *) WIZARD_BASE_NAME)

#define WZ_NewObjectA(surface, class, tagList) \
	((struct Gadget * (*)(APTR __asm("a1"), ULONG Class __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 162))(surface, class, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_NewObject(surface, class, tags...) \
	({ULONG _tags[] = {tags}; WZ_NewObjectA((surface), (class), (Tag) _tags);})
#endif

#define WZ_GadgetHelpMsg(winhandle, winhaddress, iaddress, mousex, mousey, flags) \
	((BOOL (*)(struct WizardWindowHandle * __asm("a0"), struct WizardWindowHandle ** __asm("a1"), APTR * __asm("a2"), WORD __asm("d0"), WORD __asm("d1"), UWORD __asm("d2"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 168))(winhandle, winhaddress, iaddress, mousex, mousey, flags, (struct Library *) WIZARD_BASE_NAME)

#define WZ_ObjectID(surface, id, objectname) \
	((BOOL (*)(APTR __asm("a0"), ULONG * __asm("a2"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 174))(surface, id, objectname, (struct Library *) WIZARD_BASE_NAME)

#define WZ_InitNodeA(wizardnode, entrys, tagList) \
	((void (*)(struct WizardNode * __asm("a0"), ULONG __asm("d0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 180))(wizardnode, entrys, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_InitNode(wizardnode, entrys, tags...) \
	({ULONG _tags[] = {tags}; WZ_InitNodeA((wizardnode), (entrys), (Tag) _tags);})
#endif

#define WZ_InitNodeEntryA(wizardnode, entry, tagList) \
	((void (*)(struct WizardNode * __asm("a0"), ULONG __asm("d0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 186))(wizardnode, entry, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_InitNodeEntry(wizardnode, entry, tags...) \
	({ULONG _tags[] = {tags}; WZ_InitNodeEntryA((wizardnode), (entry), (Tag) _tags);})
#endif

#define WZ_CreateImageBitMap(transpen, drinfo, newimage, screen, reg) \
	((struct BitMap * (*)(UWORD __asm("d0"), struct DrawInfo * __asm("a0"), struct WizardNewImage * __asm("a1"), struct Screen * __asm("a2"), UBYTE * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 192))(transpen, drinfo, newimage, screen, reg, (struct Library *) WIZARD_BASE_NAME)

#define WZ_DeleteImageBitMap(bm, newimage, screen, reg) \
	((void (*)(struct BitMap * __asm("a0"), struct WizardNewImage * __asm("a1"), struct Screen * __asm("a2"), UBYTE * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 198))(bm, newimage, screen, reg, (struct Library *) WIZARD_BASE_NAME)

#define WZ_GetDataAddress(surface, type, id) \
	((APTR (*)(APTR __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 204))(surface, type, id, (struct Library *) WIZARD_BASE_NAME)

#define WZ_GadgetObjectname(windowhandle, sfgadget) \
	((STRPTR (*)(struct WizardWindowHandle * __asm("a0"), struct Gadget * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 210))(windowhandle, sfgadget, (struct Library *) WIZARD_BASE_NAME)

#define WZ_MenuObjectname(windowhandle, menucode) \
	((STRPTR (*)(struct WizardWindowHandle * __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 216))(windowhandle, menucode, (struct Library *) WIZARD_BASE_NAME)

#define WZ_WindowGadgets(surface, id) \
	((ULONG (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 222))(surface, id, (struct Library *) WIZARD_BASE_NAME)

#define WZ_HandleIMessage(winhandle, imsg) \
	((BOOL (*)(struct WizardWindowHandle * __asm("a0"), struct IntuiMessage * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 228))(winhandle, imsg, (struct Library *) WIZARD_BASE_NAME)

#define WZ_ControlBubbleHelpA(surface, tagList) \
	((VOID (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 234))(surface, tagList, (struct Library *) WIZARD_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WZ_ControlBubbleHelp(surface, tags...) \
	({ULONG _tags[] = {tags}; WZ_ControlBubbleHelpA((surface), (Tag) _tags);})
#endif

#define WZ_WindowObjectname(surface, id) \
	((STRPTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 240))(surface, id, (struct Library *) WIZARD_BASE_NAME)

#define WZ_RequestObjectname(surface, id) \
	((STRPTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 246))(surface, id, (struct Library *) WIZARD_BASE_NAME)

#define WZ_FontObjectname(surface, id) \
	((STRPTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 252))(surface, id, (struct Library *) WIZARD_BASE_NAME)

#define WZ_LibraryObjectname(surface, id) \
	((STRPTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 258))(surface, id, (struct Library *) WIZARD_BASE_NAME)

#define WZ_ImageObjectname(surface, id) \
	((STRPTR (*)(APTR __asm("a0"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) WIZARD_BASE_NAME) - 264))(surface, id, (struct Library *) WIZARD_BASE_NAME)

#endif /*  _INLINE_WIZARD_H  */
