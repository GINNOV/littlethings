#ifndef _INLINE_XADMASTER_H
#define _INLINE_XADMASTER_H

#ifndef XADMASTER_BASE_NAME
#define XADMASTER_BASE_NAME xadMasterBase
#endif

#define xadAllocObjectA(type, tags) \
	((APTR (*)(LONG __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 30))(type, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadAllocObject(type, tags...) \
	({ULONG _tags[] = {tags}; xadAllocObjectA((type), (Tag) _tags);})
#endif

#define xadFreeObjectA(object, tags) \
	((void (*)(APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 36))(object, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadFreeObject(object, tags...) \
	({ULONG _tags[] = {tags}; xadFreeObjectA((object), (Tag) _tags);})
#endif

#define xadRecogFileA(size, memory, tags) \
	((struct xadClient * (*)(ULONG __asm("d0"), APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 42))(size, memory, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadRecogFile(size, memory, tags...) \
	({ULONG _tags[] = {tags}; xadRecogFileA((size), (memory), (Tag) _tags);})
#endif

#define xadGetInfoA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 48))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadGetInfo(ai, tags...) \
	({ULONG _tags[] = {tags}; xadGetInfoA((ai), (Tag) _tags);})
#endif

#define xadFreeInfo(ai) \
	((void (*)(struct xadArchiveInfo * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 54))(ai, (struct Library *) XADMASTER_BASE_NAME)

#define xadFileUnArcA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 60))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadFileUnArc(ai, tags...) \
	({ULONG _tags[] = {tags}; xadFileUnArcA((ai), (Tag) _tags);})
#endif

#define xadDiskUnArcA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 66))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadDiskUnArc(ai, tags...) \
	({ULONG _tags[] = {tags}; xadDiskUnArcA((ai), (Tag) _tags);})
#endif

#define xadGetErrorText(errnum) \
	((STRPTR (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 72))(errnum, (struct Library *) XADMASTER_BASE_NAME)

#define xadGetClientInfo() \
	((struct xadClient * (*)(struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 78))((struct Library *) XADMASTER_BASE_NAME)

#define xadHookAccess(command, data, buffer, ai) \
	((LONG (*)(ULONG __asm("d0"), LONG __asm("d1"), APTR __asm("a0"), struct xadArchiveInfo * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 84))(command, data, buffer, ai, (struct Library *) XADMASTER_BASE_NAME)

#define xadConvertDatesA(tags) \
	((LONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 90))(tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadConvertDates(tags...) \
	({ULONG _tags[] = {tags}; xadConvertDatesA((Tag) _tags);})
#endif

#define xadCalcCRC16(id, init, size, buffer) \
	((UWORD (*)(UWORD __asm("d0"), UWORD __asm("d1"), ULONG __asm("d2"), STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 96))(id, init, size, buffer, (struct Library *) XADMASTER_BASE_NAME)

#define xadCalcCRC32(id, init, size, buffer) \
	((ULONG (*)(ULONG __asm("d0"), ULONG __asm("d1"), ULONG __asm("d2"), STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 102))(id, init, size, buffer, (struct Library *) XADMASTER_BASE_NAME)

#define xadAllocVec(size, flags) \
	((APTR (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 108))(size, flags, (struct Library *) XADMASTER_BASE_NAME)

#define xadCopyMem(src, dest, size) \
	((void (*)(APTR __asm("a0"), APTR __asm("a1"), ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 114))(src, dest, size, (struct Library *) XADMASTER_BASE_NAME)

#define xadHookTagAccessA(command, data, buffer, ai, tags) \
	((LONG (*)(ULONG __asm("d0"), LONG __asm("d1"), APTR __asm("a0"), struct xadArchiveInfo * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 120))(command, data, buffer, ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadHookTagAccess(command, data, buffer, ai, tags...) \
	({ULONG _tags[] = {tags}; xadHookTagAccessA((command), (data), (buffer), (ai), (Tag) _tags);})
#endif

#define xadConvertProtectionA(tags) \
	((LONG (*)(struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 126))(tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadConvertProtection(tags...) \
	({ULONG _tags[] = {tags}; xadConvertProtectionA((Tag) _tags);})
#endif

#define xadGetDiskInfoA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 132))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadGetDiskInfo(ai, tags...) \
	({ULONG _tags[] = {tags}; xadGetDiskInfoA((ai), (Tag) _tags);})
#endif

#define xadDiskFileUnArcA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 138))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadDiskFileUnArc(ai, tags...) \
	({ULONG _tags[] = {tags}; xadDiskFileUnArcA((ai), (Tag) _tags);})
#endif

#define xadGetHookAccessA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 144))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadGetHookAccess(ai, tags...) \
	({ULONG _tags[] = {tags}; xadGetHookAccessA((ai), (Tag) _tags);})
#endif

#define xadFreeHookAccessA(ai, tags) \
	((LONG (*)(struct xadArchiveInfo * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) XADMASTER_BASE_NAME) - 150))(ai, tags, (struct Library *) XADMASTER_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define xadFreeHookAccess(ai, tags...) \
	({ULONG _tags[] = {tags}; xadFreeHookAccessA((ai), (Tag) _tags);})
#endif

#endif /*  _INLINE_XADMASTER_H  */
