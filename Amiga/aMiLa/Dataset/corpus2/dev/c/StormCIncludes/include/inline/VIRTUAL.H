#ifndef _INLINE_VIRTUAL_H
#define _INLINE_VIRTUAL_H

#ifndef VIRTUAL_BASE_NAME
#define VIRTUAL_BASE_NAME VirtualBase
#endif

#define VIRTUAL_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) VIRTUAL_BASE_NAME) - 30))((struct Library *) VIRTUAL_BASE_NAME)

#define RefreshVirtualGadget(gadget, virtual, window, requester) \
        ((VOID (*)(struct Gadget * __asm("a0"), Object * __asm("a1"), struct Window * __asm("a2"), struct Requester * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) VIRTUAL_BASE_NAME) - 36))(gadget, virtual, window, requester, (struct Library *) VIRTUAL_BASE_NAME)

#define RethinkVirtualSize(virtual, rootlayout, font, screen, layoutlimits) \
        ((BOOL (*)(Object * __asm("a0"), Object * __asm("a1"), struct TextFont * __asm("a2"), struct Screen * __asm("a3"), struct LayoutLimits * __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) VIRTUAL_BASE_NAME) - 42))(virtual, rootlayout, font, screen, layoutlimits, (struct Library *) VIRTUAL_BASE_NAME)

#endif /*  _INLINE_VIRTUAL_H  */
