#ifndef _INLINE_CLICKTAB_H
#define _INLINE_CLICKTAB_H

#ifndef CLICKTAB_BASE_NAME
#define CLICKTAB_BASE_NAME ClickTabBase
#endif

#define CLICKTAB_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) CLICKTAB_BASE_NAME) - 30))((struct Library *) CLICKTAB_BASE_NAME)

#define AllocClickTabNodeA(tags) \
	((struct Node * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CLICKTAB_BASE_NAME) - 36))(tags, (struct Library *) CLICKTAB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocClickTabNode(tags...) \
	({ULONG _tags[] = {tags}; AllocClickTabNodeA((Tag) _tags);})
#endif

#define FreeClickTabNode(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CLICKTAB_BASE_NAME) - 42))(node, (struct Library *) CLICKTAB_BASE_NAME)

#define SetClickTabNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CLICKTAB_BASE_NAME) - 48))(node, tags, (struct Library *) CLICKTAB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetClickTabNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; SetClickTabNodeAttrsA((node), (Tag) _tags);})
#endif

#define GetClickTabNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CLICKTAB_BASE_NAME) - 54))(node, tags, (struct Library *) CLICKTAB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetClickTabNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; GetClickTabNodeAttrsA((node), (Tag) _tags);})
#endif

#endif /*  _INLINE_CLICKTAB_H  */
