#ifndef _INLINE_BULLET_H
#define _INLINE_BULLET_H

#ifndef BULLET_BASE_NAME
#define BULLET_BASE_NAME BulletBase
#endif

#define OpenEngine() \
	((struct GlyphEngine * (*)(struct Library * __asm("a6"))) \
  (((char *) BULLET_BASE_NAME) - 30))((struct Library *) BULLET_BASE_NAME)

#define CloseEngine(glyphEngine) \
	((VOID (*)(struct GlyphEngine * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) BULLET_BASE_NAME) - 36))(glyphEngine, (struct Library *) BULLET_BASE_NAME)

#define SetInfoA(glyphEngine, tagList) \
	((ULONG (*)(struct GlyphEngine * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) BULLET_BASE_NAME) - 42))(glyphEngine, tagList, (struct Library *) BULLET_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define SetInfo(glyphEngine, tags...) \
	({ULONG _tags[] = {tags}; SetInfoA((glyphEngine), (Tag) _tags);})
#endif

#define ObtainInfoA(glyphEngine, tagList) \
	((ULONG (*)(struct GlyphEngine * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) BULLET_BASE_NAME) - 48))(glyphEngine, tagList, (struct Library *) BULLET_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ObtainInfo(glyphEngine, tags...) \
	({ULONG _tags[] = {tags}; ObtainInfoA((glyphEngine), (Tag) _tags);})
#endif

#define ReleaseInfoA(glyphEngine, tagList) \
	((ULONG (*)(struct GlyphEngine * __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) BULLET_BASE_NAME) - 54))(glyphEngine, tagList, (struct Library *) BULLET_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ReleaseInfo(glyphEngine, tags...) \
	({ULONG _tags[] = {tags}; ReleaseInfoA((glyphEngine), (Tag) _tags);})
#endif

#endif /*  _INLINE_BULLET_H  */
