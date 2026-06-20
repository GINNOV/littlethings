#ifndef _INLINE_CHOOSER_H
#define _INLINE_CHOOSER_H

#ifndef CHOOSER_BASE_NAME
#define CHOOSER_BASE_NAME ChooserBase
#endif

#define CHOOSER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 30))((struct Library *) CHOOSER_BASE_NAME)

#define AllocChooserNodeA(tags) \
	((struct Node * (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 36))(tags, (struct Library *) CHOOSER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocChooserNode(tags...) \
	({ULONG _tags[] = {tags}; AllocChooserNodeA((Tag) _tags);})
#endif

#define FreeChooserNode(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 42))(node, (struct Library *) CHOOSER_BASE_NAME)

#define SetChooserNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 48))(node, tags, (struct Library *) CHOOSER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetChooserNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; SetChooserNodeAttrsA((node), (Tag) _tags);})
#endif

#define GetChooserNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 54))(node, tags, (struct Library *) CHOOSER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetChooserNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; GetChooserNodeAttrsA((node), (Tag) _tags);})
#endif

#define ShowChooser(obj, win, xpos, ypos) \
	((ULONG (*)(Object * __asm("a0"), struct Window * __asm("a1"), ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 60))(obj, win, xpos, ypos, (struct Library *) CHOOSER_BASE_NAME)

#define HideChooser(obj, win) \
	((VOID (*)(Object * __asm("a0"), struct Window * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) CHOOSER_BASE_NAME) - 66))(obj, win, (struct Library *) CHOOSER_BASE_NAME)

#endif /*  _INLINE_CHOOSER_H  */
