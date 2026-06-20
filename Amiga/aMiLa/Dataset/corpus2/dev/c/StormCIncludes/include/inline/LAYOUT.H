#ifndef _INLINE_LAYOUT_H
#define _INLINE_LAYOUT_H

#ifndef LAYOUT_BASE_NAME
#define LAYOUT_BASE_NAME LayoutBase
#endif

#define LAYOUT_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 30))((struct Library *) LAYOUT_BASE_NAME)

#define ActivateLayoutGadget(gadget, window, requester, object) \
	((BOOL (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 36))(gadget, window, requester, object, (struct Library *) LAYOUT_BASE_NAME)

#define FlushLayoutDomainCache(gadget) \
	((VOID (*)(struct Gadget * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 42))(gadget, (struct Library *) LAYOUT_BASE_NAME)

#define RethinkLayout(gadget, window, requester, refresh) \
	((BOOL (*)(struct Gadget * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 48))(gadget, window, requester, refresh, (struct Library *) LAYOUT_BASE_NAME)

#define LayoutLimits(gadget, limits, font, screen) \
	((VOID (*)(struct Gadget * __asm("a0"), struct LayoutLimits * __asm("a1"), struct TextFont * __asm("a2"), struct Screen * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 54))(gadget, limits, font, screen, (struct Library *) LAYOUT_BASE_NAME)

#define PAGE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 60))((struct Library *) LAYOUT_BASE_NAME)

#define SetPageGadgetAttrsA(gadget, object, window, requester, tags) \
	((ULONG (*)(struct Gadget * __asm("a0"), Object * __asm("a1"), struct Window * __asm("a2"), struct Requester * __asm("a3"), struct TagItem * __asm("a4"), struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 66))(gadget, object, window, requester, tags, (struct Library *) LAYOUT_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetPageGadgetAttrs(gadget, object, window, requester, tags...) \
	({ULONG _tags[] = {tags}; SetPageGadgetAttrsA((gadget), (object), (window), (requester), () _tags);})
#endif

#define RefreshPageGadget(gadget, object, window, requester) \
	((VOID (*)(struct Gadget * __asm("a0"), Object * __asm("a1"), struct Window * __asm("a2"), struct Requester * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) LAYOUT_BASE_NAME) - 72))(gadget, object, window, requester, (struct Library *) LAYOUT_BASE_NAME)

#endif /*  _INLINE_LAYOUT_H  */
