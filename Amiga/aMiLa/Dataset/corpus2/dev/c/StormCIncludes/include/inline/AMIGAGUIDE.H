#ifndef _INLINE_AMIGAGUIDE_H
#define _INLINE_AMIGAGUIDE_H

#ifndef AMIGAGUIDE_BASE_NAME
#define AMIGAGUIDE_BASE_NAME AmigaGuideBase
#endif

#define LockAmigaGuideBase(handle) \
	((LONG (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 36))(handle, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define UnlockAmigaGuideBase(key) \
	((VOID (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 42))(key, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define OpenAmigaGuideA(nag, attrs) \
	((APTR (*)(struct NewAmigaGuide * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 54))(nag, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenAmigaGuide(nag, tags...) \
	({ULONG _tags[] = {tags}; OpenAmigaGuideA((nag), (Tag) _tags);})
#endif

#define OpenAmigaGuideAsyncA(nag, attrs) \
	((APTR (*)(struct NewAmigaGuide * __asm("a0"), struct TagItem * __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 60))(nag, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenAmigaGuideAsync(nag, tags...) \
	({ULONG _tags[] = {tags}; OpenAmigaGuideAsyncA((nag), (Tag) _tags);})
#endif

#define CloseAmigaGuide(cl) \
	((VOID (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 66))(cl, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define AmigaGuideSignal(cl) \
	((ULONG (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 72))(cl, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define GetAmigaGuideMsg(cl) \
	((struct AmigaGuideMsg * (*)(APTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 78))(cl, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define ReplyAmigaGuideMsg(amsg) \
	((VOID (*)(struct AmigaGuideMsg * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 84))(amsg, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define SetAmigaGuideContextA(cl, id, attrs) \
	((LONG (*)(APTR __asm("a0"), ULONG __asm("d0"), struct TagItem * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 90))(cl, id, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetAmigaGuideContext(cl, id, tags...) \
	({ULONG _tags[] = {tags}; SetAmigaGuideContextA((cl), (id), (Tag) _tags);})
#endif

#define SendAmigaGuideContextA(cl, attrs) \
	((LONG (*)(APTR __asm("a0"), struct TagItem * __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 96))(cl, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SendAmigaGuideContext(cl, tags...) \
	({ULONG _tags[] = {tags}; SendAmigaGuideContextA((cl), (Tag) _tags);})
#endif

#define SendAmigaGuideCmdA(cl, cmd, attrs) \
	((LONG (*)(APTR __asm("a0"), STRPTR __asm("d0"), struct TagItem * __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 102))(cl, cmd, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SendAmigaGuideCmd(cl, cmd, tags...) \
	({ULONG _tags[] = {tags}; SendAmigaGuideCmdA((cl), (cmd), (Tag) _tags);})
#endif

#define SetAmigaGuideAttrsA(cl, attrs) \
	((LONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 108))(cl, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetAmigaGuideAttrs(cl, tags...) \
	({ULONG _tags[] = {tags}; SetAmigaGuideAttrsA((cl), (Tag) _tags);})
#endif

#define GetAmigaGuideAttr(tag, cl, storage) \
	((LONG (*)(Tag __asm("d0"), APTR __asm("a0"), ULONG * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 114))(tag, cl, storage, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define LoadXRef(lock, name) \
	((LONG (*)(BPTR __asm("a0"), STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 126))(lock, name, (struct Library *) AMIGAGUIDE_BASE_NAME)

#define ExpungeXRef() \
	((VOID (*)(struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 132))((struct Library *) AMIGAGUIDE_BASE_NAME)

#define AddAmigaGuideHostA(h, name, attrs) \
	((APTR (*)(struct Hook * __asm("a0"), STRPTR __asm("d0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 138))(h, name, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AddAmigaGuideHost(h, name, tags...) \
	({ULONG _tags[] = {tags}; AddAmigaGuideHostA((h), (name), (Tag) _tags);})
#endif

#define RemoveAmigaGuideHostA(hh, attrs) \
	((LONG (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 144))(hh, attrs, (struct Library *) AMIGAGUIDE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RemoveAmigaGuideHost(hh, tags...) \
	({ULONG _tags[] = {tags}; RemoveAmigaGuideHostA((hh), (Tag) _tags);})
#endif

#define GetAmigaGuideString(id) \
	((STRPTR (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) AMIGAGUIDE_BASE_NAME) - 210))(id, (struct Library *) AMIGAGUIDE_BASE_NAME)

#endif /*  _INLINE_AMIGAGUIDE_H  */
