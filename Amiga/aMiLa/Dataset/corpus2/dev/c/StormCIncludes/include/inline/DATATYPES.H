#ifndef _INLINE_DATATYPES_H
#define _INLINE_DATATYPES_H

#ifndef DATATYPES_BASE_NAME
#define DATATYPES_BASE_NAME DataTypesBase
#endif

#define ObtainDataTypeA(type, handle, attrs) \
	((struct DataType * (*)(ULONG __asm("d0"), APTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 36))(type, handle, attrs, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ObtainDataType(type, handle, tags...) \
	({ULONG _tags[] = {tags}; ObtainDataTypeA((type), (handle), (Tag) _tags);})
#endif

#define ReleaseDataType(dt) \
	((VOID (*)(struct DataType * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 42))(dt, (struct Library *) DATATYPES_BASE_NAME)

#define NewDTObjectA(name, attrs) \
	((Object * (*)(APTR __asm("d0"), struct TagItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 48))(name, attrs, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define NewDTObject(name, tags...) \
	({ULONG _tags[] = {tags}; NewDTObjectA((name), (Tag) _tags);})
#endif

#define DisposeDTObject(o) \
	((VOID (*)(Object * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 54))(o, (struct Library *) DATATYPES_BASE_NAME)

#define SetDTAttrsA(o, win, req, attrs) \
	((ULONG (*)(Object * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 60))(o, win, req, attrs, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetDTAttrs(o, win, req, tags...) \
	({ULONG _tags[] = {tags}; SetDTAttrsA((o), (win), (req), (Tag) _tags);})
#endif

#define GetDTAttrsA(o, attrs) \
	((ULONG (*)(Object * __asm("a0"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 66))(o, attrs, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetDTAttrs(o, tags...) \
	({ULONG _tags[] = {tags}; GetDTAttrsA((o), (Tag) _tags);})
#endif

#define AddDTObject(win, req, o, pos) \
	((LONG (*)(struct Window * __asm("a0"), struct Requester * __asm("a1"), Object * __asm("a2"), LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 72))(win, req, o, pos, (struct Library *) DATATYPES_BASE_NAME)

#define RefreshDTObjectA(o, win, req, attrs) \
	((VOID (*)(Object * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 78))(o, win, req, attrs, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RefreshDTObject(o, win, req, tags...) \
	({ULONG _tags[] = {tags}; RefreshDTObjectA((o), (win), (req), (Tag) _tags);})
#endif

#ifndef NO_INLINE_STDARG
#define RefreshDTObjects RefreshDTObject
#endif

#define DoAsyncLayout(o, gpl) \
	((ULONG (*)(Object * __asm("a0"), struct gpLayout * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 84))(o, gpl, (struct Library *) DATATYPES_BASE_NAME)

#define DoDTMethodA(o, win, req, msg) \
	((ULONG (*)(Object * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), Msg __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 90))(o, win, req, msg, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DoDTMethod(o, win, req, tags...) \
	({ULONG _tags[] = {tags}; DoDTMethodA((o), (win), (req), (ULONG) _tags);})
#endif

#define RemoveDTObject(win, o) \
	((LONG (*)(struct Window * __asm("a0"), Object * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 96))(win, o, (struct Library *) DATATYPES_BASE_NAME)

#define GetDTMethods(object) \
	((ULONG * (*)(Object * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 102))(object, (struct Library *) DATATYPES_BASE_NAME)

#define GetDTTriggerMethods(object) \
	((struct DTMethods * (*)(Object * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 108))(object, (struct Library *) DATATYPES_BASE_NAME)

#define PrintDTObjectA(o, w, r, msg) \
	((ULONG (*)(Object * __asm("a0"), struct Window * __asm("a1"), struct Requester * __asm("a2"), struct dtPrint * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 114))(o, w, r, msg, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define PrintDTObject(o, w, r, tags...) \
	({ULONG _tags[] = {tags}; PrintDTObjectA((o), (w), (r), (ULONG) _tags);})
#endif

#define ObtainDTDrawInfoA(o, taglist) \
	((APTR (*)(Object * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 120))(o, taglist, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ObtainDTDrawInfo(o, tags...) \
	({ULONG _tags[] = {tags}; ObtainDTDrawInfoA((o), (Tag) _tags);})
#endif

#define DrawDTObjectA(rp, o, x, y, w, h, th, tv, taglist) \
	((LONG (*)(struct RastPort * __asm("a0"), Object * __asm("a1"), LONG __asm("d0"), LONG __asm("d1"), LONG __asm("d2"), LONG __asm("d3"), LONG __asm("d4"), LONG __asm("d5"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 126))(rp, o, x, y, w, h, th, tv, taglist, (struct Library *) DATATYPES_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DrawDTObject(rp, o, x, y, w, h, th, tv, tags...) \
	({ULONG _tags[] = {tags}; DrawDTObjectA((rp), (o), (x), (y), (w), (h), (th), (tv), (Tag) _tags);})
#endif

#define ReleaseDTDrawInfo(o, handle) \
	((VOID (*)(Object * __asm("a0"), APTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 132))(o, handle, (struct Library *) DATATYPES_BASE_NAME)

#define GetDTString(id) \
	((STRPTR (*)(ULONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) DATATYPES_BASE_NAME) - 138))(id, (struct Library *) DATATYPES_BASE_NAME)

#endif /*  _INLINE_DATATYPES_H  */
