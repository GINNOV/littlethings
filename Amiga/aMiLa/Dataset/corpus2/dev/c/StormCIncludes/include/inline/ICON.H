#ifndef _INLINE_ICON_H
#define _INLINE_ICON_H

#ifndef ICON_BASE_NAME
#define ICON_BASE_NAME IconBase
#endif

#define FreeFreeList(freelist) \
	((VOID (*)(struct FreeList * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 54))(freelist, (struct Library *) ICON_BASE_NAME)

#define AddFreeList(freelist, mem, size) \
	((BOOL (*)(struct FreeList * __asm("a0"), CONST APTR __asm("a1"), ULONG __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 72))(freelist, mem, size, (struct Library *) ICON_BASE_NAME)

#define GetDiskObject(name) \
	((struct DiskObject * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 78))(name, (struct Library *) ICON_BASE_NAME)

#define PutDiskObject(name, diskobj) \
	((BOOL (*)(CONST_STRPTR __asm("a0"), CONST struct DiskObject * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 84))(name, diskobj, (struct Library *) ICON_BASE_NAME)

#define FreeDiskObject(diskobj) \
	((VOID (*)(struct DiskObject * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 90))(diskobj, (struct Library *) ICON_BASE_NAME)

#define FindToolType(toolTypeArray, typeName) \
	((STRPTR (*)(STRPTR * __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 96))(toolTypeArray, typeName, (struct Library *) ICON_BASE_NAME)

#define MatchToolValue(typeString, value) \
	((BOOL (*)(CONST_STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 102))(typeString, value, (struct Library *) ICON_BASE_NAME)

#define BumpRevision(newname, oldname) \
	((STRPTR (*)(STRPTR __asm("a0"), CONST_STRPTR __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 108))(newname, oldname, (struct Library *) ICON_BASE_NAME)

#define GetDefDiskObject(type) \
	((struct DiskObject * (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 120))(type, (struct Library *) ICON_BASE_NAME)

#define PutDefDiskObject(diskObject) \
	((BOOL (*)(CONST struct DiskObject * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 126))(diskObject, (struct Library *) ICON_BASE_NAME)

#define GetDiskObjectNew(name) \
	((struct DiskObject * (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 132))(name, (struct Library *) ICON_BASE_NAME)

#define DeleteDiskObject(name) \
	((BOOL (*)(CONST_STRPTR __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 138))(name, (struct Library *) ICON_BASE_NAME)

#define DupDiskObjectA(diskObject, tags) \
	((struct DiskObject * (*)(CONST struct DiskObject * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 150))(diskObject, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DupDiskObject(diskObject, tags...) \
	({ULONG _tags[] = {tags}; DupDiskObjectA((diskObject), () _tags);})
#endif

#define IconControlA(icon, tags) \
	((ULONG (*)(struct DiskObject * __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 156))(icon, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define IconControl(icon, tags...) \
	({ULONG _tags[] = {tags}; IconControlA((icon), () _tags);})
#endif

#define DrawIconStateA(rp, icon, label, leftOffset, topOffset, state, tags) \
	((VOID (*)(struct RastPort * __asm("a0"), CONST struct DiskObject * __asm("a1"), CONST_STRPTR __asm("a2"), LONG __asm("d0"), LONG __asm("d1"), ULONG __asm("d2"), CONST struct TagItem * __asm("a3"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 162))(rp, icon, label, leftOffset, topOffset, state, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define DrawIconState(rp, icon, label, leftOffset, topOffset, state, tags...) \
	({ULONG _tags[] = {tags}; DrawIconStateA((rp), (icon), (label), (leftOffset), (topOffset), (state), () _tags);})
#endif

#define GetIconRectangleA(rp, icon, label, rect, tags) \
	((BOOL (*)(struct RastPort * __asm("a0"), CONST struct DiskObject * __asm("a1"), CONST_STRPTR __asm("a2"), struct Rectangle * __asm("a3"), CONST struct TagItem * __asm("a4"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 168))(rp, icon, label, rect, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetIconRectangle(rp, icon, label, rect, tags...) \
	({ULONG _tags[] = {tags}; GetIconRectangleA((rp), (icon), (label), (rect), () _tags);})
#endif

#define NewDiskObject(type) \
	((struct DiskObject * (*)(LONG __asm("d0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 174))(type, (struct Library *) ICON_BASE_NAME)

#define GetIconTagList(name, tags) \
	((struct DiskObject * (*)(CONST_STRPTR __asm("a0"), CONST struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 180))(name, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define GetIconTags(name, tags...) \
	({ULONG _tags[] = {tags}; GetIconTagList((name), () _tags);})
#endif

#define PutIconTagList(name, icon, tags) \
	((BOOL (*)(CONST_STRPTR __asm("a0"), CONST struct DiskObject * __asm("a1"), CONST struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 186))(name, icon, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define PutIconTags(name, icon, tags...) \
	({ULONG _tags[] = {tags}; PutIconTagList((name), (icon), () _tags);})
#endif

#define LayoutIconA(icon, screen, tags) \
	((BOOL (*)(struct DiskObject * __asm("a0"), struct Screen * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 192))(icon, screen, tags, (struct Library *) ICON_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define LayoutIcon(icon, screen, tags...) \
	({ULONG _tags[] = {tags}; LayoutIconA((icon), (screen), () _tags);})
#endif

#define ChangeToSelectedIconColor(cr) \
	((VOID (*)(struct ColorRegister * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) ICON_BASE_NAME) - 198))(cr, (struct Library *) ICON_BASE_NAME)

#endif /*  _INLINE_ICON_H  */
