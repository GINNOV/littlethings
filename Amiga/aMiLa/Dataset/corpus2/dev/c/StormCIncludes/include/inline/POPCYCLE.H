#ifndef _INLINE_POPCYCLE_H
#define _INLINE_POPCYCLE_H

#ifndef POPCYCLE_BASE_NAME
#define POPCYCLE_BASE_NAME PopCycleBase
#endif

#define POPCYCLE_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) POPCYCLE_BASE_NAME) - 30))((struct Library *) POPCYCLE_BASE_NAME)

#define AllocPopCycleNodeA(tags) \
	((struct Node * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POPCYCLE_BASE_NAME) - 36))(tags, (struct Library *) POPCYCLE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocPopCycleNode(tags...) \
	({ULONG _tags[] = {tags}; AllocPopCycleNodeA((Tag) _tags);})
#endif

#define FreePopCycleNode(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) POPCYCLE_BASE_NAME) - 42))(node, (struct Library *) POPCYCLE_BASE_NAME)

#define SetPopCycleNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) POPCYCLE_BASE_NAME) - 48))(node, tags, (struct Library *) POPCYCLE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetPopCycleNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; SetPopCycleNodeAttrsA((node), () _tags);})
#endif

#define GetPopCycleNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) POPCYCLE_BASE_NAME) - 54))(node, tags, (struct Library *) POPCYCLE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetPopCycleNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; GetPopCycleNodeAttrsA((node), () _tags);})
#endif

#endif /*  _INLINE_POPCYCLE_H  */
