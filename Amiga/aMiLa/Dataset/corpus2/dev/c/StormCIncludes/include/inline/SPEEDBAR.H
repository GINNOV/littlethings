#ifndef _INLINE_SPEEDBAR_H
#define _INLINE_SPEEDBAR_H

#ifndef SPEEDBAR_BASE_NAME
#define SPEEDBAR_BASE_NAME SpeedBarBase
#endif

#define SPEEDBAR_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) SPEEDBAR_BASE_NAME) - 30))((struct Library *) SPEEDBAR_BASE_NAME)

#define AllocSpeedButtonNodeA(number, tags) \
	((struct Node * (*)(UWORD __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SPEEDBAR_BASE_NAME) - 36))(number, tags, (struct Library *) SPEEDBAR_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocSpeedButtonNode(number, tags...) \
	({ULONG _tags[] = {tags}; AllocSpeedButtonNodeA((number), (Tag) _tags);})
#endif

#define FreeSpeedButtonNode(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) SPEEDBAR_BASE_NAME) - 42))(node, (struct Library *) SPEEDBAR_BASE_NAME)

#define SetSpeedButtonNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SPEEDBAR_BASE_NAME) - 48))(node, tags, (struct Library *) SPEEDBAR_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetSpeedButtonNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; SetSpeedButtonNodeAttrsA((node), (Tag) _tags);})
#endif

#define GetSpeedButtonNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) SPEEDBAR_BASE_NAME) - 54))(node, tags, (struct Library *) SPEEDBAR_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetSpeedButtonNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; GetSpeedButtonNodeAttrsA((node), (Tag) _tags);})
#endif

#endif /*  _INLINE_SPEEDBAR_H  */
