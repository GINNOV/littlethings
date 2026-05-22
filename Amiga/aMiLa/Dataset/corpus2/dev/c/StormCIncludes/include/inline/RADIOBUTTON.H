#ifndef _INLINE_RADIOBUTTON_H
#define _INLINE_RADIOBUTTON_H

#ifndef RADIOBUTTON_BASE_NAME
#define RADIOBUTTON_BASE_NAME RadioButtonBase
#endif

#define RADIOBUTTON_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) RADIOBUTTON_BASE_NAME) - 30))((struct Library *) RADIOBUTTON_BASE_NAME)

#define AllocRadioButtonNodeA(columns, tags) \
	((struct Node * (*)(UWORD __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RADIOBUTTON_BASE_NAME) - 36))(columns, tags, (struct Library *) RADIOBUTTON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocRadioButtonNode(columns, tags...) \
	({ULONG _tags[] = {tags}; AllocRadioButtonNodeA((columns), (Tag) _tags);})
#endif

#define FreeRadioButtonNode(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RADIOBUTTON_BASE_NAME) - 42))(node, (struct Library *) RADIOBUTTON_BASE_NAME)

#define SetRadioButtonNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RADIOBUTTON_BASE_NAME) - 48))(node, tags, (struct Library *) RADIOBUTTON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetRadioButtonNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; SetRadioButtonNodeAttrsA((node), (Tag) _tags);})
#endif

#define GetRadioButtonNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RADIOBUTTON_BASE_NAME) - 54))(node, tags, (struct Library *) RADIOBUTTON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetRadioButtonNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; GetRadioButtonNodeAttrsA((node), (Tag) _tags);})
#endif

#endif /*  _INLINE_RADIOBUTTON_H  */
