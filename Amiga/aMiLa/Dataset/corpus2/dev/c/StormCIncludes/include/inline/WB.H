#ifndef _INLINE_WB_H
#define _INLINE_WB_H

#ifndef WB_BASE_NAME
#define WB_BASE_NAME WorkbenchBase
#endif

#define AddAppWindowA(id, userdata, window, msgport, taglist) \
	((struct AppWindow * (*)(ULONG __asm("d0"), ULONG __asm("d1"), struct Window * __asm("a0"), struct MsgPort * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 48))(id, userdata, window, msgport, taglist, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AddAppWindow(id, userdata, window, msgport, tags...) \
	({ULONG _tags[] = {tags}; AddAppWindowA((id), (userdata), (window), (msgport), (Tag) _tags);})
#endif

#define RemoveAppWindow(appWindow) \
	((BOOL (*)(struct AppWindow * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 54))(appWindow, (struct Library *) WB_BASE_NAME)

#define AddAppIconA(id, userdata, text, msgport, lock, diskobj, taglist) \
	((struct AppIcon * (*)(ULONG __asm("d0"), ULONG __asm("d1"), STRPTR __asm("a0"), struct MsgPort * __asm("a1"), BPTR __asm("a2"), struct DiskObject * __asm("a3"), struct TagItem * __asm("a4"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 60))(id, userdata, text, msgport, lock, diskobj, taglist, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AddAppIcon(id, userdata, text, msgport, lock, diskobj, tags...) \
	({ULONG _tags[] = {tags}; AddAppIconA((id), (userdata), (text), (msgport), (lock), (diskobj), (Tag) _tags);})
#endif

#define RemoveAppIcon(appIcon) \
	((BOOL (*)(struct AppIcon * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 66))(appIcon, (struct Library *) WB_BASE_NAME)

#define AddAppMenuItemA(id, userdata, text, msgport, taglist) \
	((struct AppMenuItem * (*)(ULONG __asm("d0"), ULONG __asm("d1"), STRPTR __asm("a0"), struct MsgPort * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 72))(id, userdata, text, msgport, taglist, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AddAppMenuItem(id, userdata, text, msgport, tags...) \
	({ULONG _tags[] = {tags}; AddAppMenuItemA((id), (userdata), (text), (msgport), (Tag) _tags);})
#endif

#define RemoveAppMenuItem(appMenuItem) \
	((BOOL (*)(struct AppMenuItem * __asm("a0"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 78))(appMenuItem, (struct Library *) WB_BASE_NAME)

#define WBInfo(lock, name, screen) \
	((VOID (*)(BPTR __asm("a0"), STRPTR __asm("a1"), struct Screen * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 90))(lock, name, screen, (struct Library *) WB_BASE_NAME)

#define OpenWorkbenchObjectA(name, tags) \
	((BOOL (*)(STRPTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 96))(name, tags, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define OpenWorkbenchObject(name, tags...) \
	({ULONG _tags[] = {tags}; OpenWorkbenchObjectA((name), () _tags);})
#endif

#define CloseWorkbenchObjectA(name, tags) \
	((BOOL (*)(STRPTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 102))(name, tags, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define CloseWorkbenchObject(name, tags...) \
	({ULONG _tags[] = {tags}; CloseWorkbenchObjectA((name), () _tags);})
#endif

#define WorkbenchControlA(name, tags) \
	((BOOL (*)(STRPTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 108))(name, tags, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define WorkbenchControl(name, tags...) \
	({ULONG _tags[] = {tags}; WorkbenchControlA((name), () _tags);})
#endif

#define AddAppWindowDropZoneA(aw, id, userdata, tags) \
	((struct AppWindowDropZone * (*)(struct AppWindow * __asm("a0"), ULONG __asm("d0"), ULONG __asm("d1"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 114))(aw, id, userdata, tags, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define AddAppWindowDropZone(aw, id, userdata, tags...) \
	({ULONG _tags[] = {tags}; AddAppWindowDropZoneA((aw), (id), (userdata), () _tags);})
#endif

#define RemoveAppWindowDropZone(aw, dropZone) \
	((BOOL (*)(struct AppWindow * __asm("a0"), struct AppWindowDropZone * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 120))(aw, dropZone, (struct Library *) WB_BASE_NAME)

#define ChangeWorkbenchSelectionA(name, hook, tags) \
	((BOOL (*)(STRPTR __asm("a0"), struct Hook * __asm("a1"), struct TagItem * __asm("a2"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 126))(name, hook, tags, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define ChangeWorkbenchSelection(name, hook, tags...) \
	({ULONG _tags[] = {tags}; ChangeWorkbenchSelectionA((name), (hook), () _tags);})
#endif

#define MakeWorkbenchObjectVisibleA(name, tags) \
	((BOOL (*)(STRPTR __asm("a0"), struct TagItem * __asm("a1"), struct Library * __asm("a6"))) \
  (((char *) WB_BASE_NAME) - 132))(name, tags, (struct Library *) WB_BASE_NAME)

#ifndef NO_INLINE_STDARG
#define MakeWorkbenchObjectVisible(name, tags...) \
	({ULONG _tags[] = {tags}; MakeWorkbenchObjectVisibleA((name), () _tags);})
#endif

#endif /*  _INLINE_WB_H  */
