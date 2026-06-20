#ifndef _INLINE_RESOURCE_H
#define _INLINE_RESOURCE_H

#ifndef RESOURCE_BASE_NAME
#define RESOURCE_BASE_NAME ResourceBase
#endif

#define RL_OpenResource(resource, screen, catalog) \
	((RESOURCEFILE (*)(void * __asm("a0"), struct Screen * __asm("a1"), struct Catalog * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 30))(resource, screen, catalog, (struct Library *) RESOURCE_BASE_NAME)

#define RL_CloseResource(resfile) \
	((void (*)(RESOURCEFILE __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 36))(resfile, (struct Library *) RESOURCE_BASE_NAME)

#define RL_NewObjectA(resfile, resourceid, taglist) \
	((Object * (*)(RESOURCEFILE __asm("a0"), RESOURCEID __asm("d0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 42))(resfile, resourceid, taglist, (struct Library *) RESOURCE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RL_NewObject(resfile, resourceid, tags...) \
	({ULONG _tags[] = {tags}; RL_NewObjectA((resfile), (resourceid), (Tag) _tags);})
#endif

#define RL_DisposeObject(resfile, object) \
	((void (*)(RESOURCEFILE __asm("a0"), Object * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 48))(resfile, object, (struct Library *) RESOURCE_BASE_NAME)

#define RL_NewGroupA(resfile, resourceid, taglist) \
	((Object ** (*)(RESOURCEFILE __asm("a0"), RESOURCEID __asm("d0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 54))(resfile, resourceid, taglist, (struct Library *) RESOURCE_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define RL_NewGroup(resfile, resourceid, tags...) \
	({ULONG _tags[] = {tags}; RL_NewGroupA((resfile), (resourceid), (Tag) _tags);})
#endif

#define RL_DisposeGroup(resfile, objects) \
	((void (*)(RESOURCEFILE __asm("a0"), Object ** __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 60))(resfile, objects, (struct Library *) RESOURCE_BASE_NAME)

#define RL_GetObjectArray(resfile, object, resourceid) \
	((Object ** (*)(RESOURCEFILE __asm("a0"), Object * __asm("a1"), RESOURCEID __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 66))(resfile, object, resourceid, (struct Library *) RESOURCE_BASE_NAME)

#define RL_SetResourceScreen(resfile, screen) \
	((BOOL (*)(RESOURCEFILE __asm("a0"), struct Screen * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) RESOURCE_BASE_NAME) - 72))(resfile, screen, (struct Library *) RESOURCE_BASE_NAME)

#endif /*  _INLINE_RESOURCE_H  */
