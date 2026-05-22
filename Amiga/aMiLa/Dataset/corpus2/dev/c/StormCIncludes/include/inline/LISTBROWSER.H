#ifndef _INLINE_LISTBROWSER_H
#define _INLINE_LISTBROWSER_H

#ifndef LISTBROWSER_BASE_NAME
#define LISTBROWSER_BASE_NAME ListBrowserBase
#endif

#define LISTBROWSER_GetClass() \
	((Class * (*)(struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 30))((struct Library *) LISTBROWSER_BASE_NAME)

#define AllocListBrowserNodeA(columns, tags) \
	((struct Node * (*)(UWORD __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 36))(columns, tags, (struct Library *) LISTBROWSER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AllocListBrowserNode(columns, tags...) \
	({ULONG _tags[] = {tags}; AllocListBrowserNodeA((columns), (Tag) _tags);})
#endif

#define FreeListBrowserNode(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 42))(node, (struct Library *) LISTBROWSER_BASE_NAME)

#define SetListBrowserNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 48))(node, tags, (struct Library *) LISTBROWSER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetListBrowserNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; SetListBrowserNodeAttrsA((node), (Tag) _tags);})
#endif

#define GetListBrowserNodeAttrsA(node, tags) \
	((VOID (*)(struct Node * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 54))(node, tags, (struct Library *) LISTBROWSER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetListBrowserNodeAttrs(node, tags...) \
	({ULONG _tags[] = {tags}; GetListBrowserNodeAttrsA((node), (Tag) _tags);})
#endif

#define ListBrowserSelectAll(list) \
	((VOID (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 60))(list, (struct Library *) LISTBROWSER_BASE_NAME)

#define ShowListBrowserNodeChildren(node, depth) \
	((VOID (*)(struct Node * __asm("a0"), WORD __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 66))(node, depth, (struct Library *) LISTBROWSER_BASE_NAME)

#define HideListBrowserNodeChildren(node) \
	((VOID (*)(struct Node * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 72))(node, (struct Library *) LISTBROWSER_BASE_NAME)

#define ShowAllListBrowserChildren(list) \
	((VOID (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 78))(list, (struct Library *) LISTBROWSER_BASE_NAME)

#define HideAllListBrowserChildren(list) \
	((VOID (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 84))(list, (struct Library *) LISTBROWSER_BASE_NAME)

#define FreeListBrowserList(list) \
	((VOID (*)(struct List * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) LISTBROWSER_BASE_NAME) - 90))(list, (struct Library *) LISTBROWSER_BASE_NAME)

#endif /*  _INLINE_LISTBROWSER_H  */
