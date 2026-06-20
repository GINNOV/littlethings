#ifndef _VBCCINLINE_WB_H
#define _VBCCINLINE_WB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct AppWindow * __AddAppWindowA(void *, ULONG id, ULONG userdata, struct Window * window, struct MsgPort * msgport, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AddAppWindowA(id, userdata, window, msgport, taglist) __AddAppWindowA(WorkbenchBase, (id), (userdata), (window), (msgport), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct AppWindow * __linearvarargs __AddAppWindow(void *, ULONG id, ULONG userdata, struct Window * window, struct MsgPort * msgport, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define AddAppWindow(id, userdata, window, msgport, ...) __AddAppWindow(WorkbenchBase, (id), (userdata), (window), (msgport), __VA_ARGS__)
#endif

BOOL __RemoveAppWindow(void *, struct AppWindow * appWindow) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define RemoveAppWindow(appWindow) __RemoveAppWindow(WorkbenchBase, (appWindow))

struct AppIcon * __AddAppIconA(void *, ULONG id, ULONG userdata, UBYTE * text, struct MsgPort * msgport, BPTR lock, struct DiskObject * diskobj, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\tstw\t10,48(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AddAppIconA(id, userdata, text, msgport, lock, diskobj, taglist) __AddAppIconA(WorkbenchBase, (id), (userdata), (text), (msgport), (lock), (diskobj), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct AppIcon * __linearvarargs __AddAppIcon(void *, ULONG id, ULONG userdata, UBYTE * text, struct MsgPort * msgport, BPTR lock, struct DiskObject * diskobj, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tstw\t9,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define AddAppIcon(id, userdata, text, msgport, lock, diskobj, ...) __AddAppIcon(WorkbenchBase, (id), (userdata), (text), (msgport), (lock), (diskobj), __VA_ARGS__)
#endif

BOOL __RemoveAppIcon(void *, struct AppIcon * appIcon) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define RemoveAppIcon(appIcon) __RemoveAppIcon(WorkbenchBase, (appIcon))

struct AppMenuItem * __AddAppMenuItemA(void *, ULONG id, ULONG userdata, UBYTE * text, struct MsgPort * msgport, struct TagItem * taglist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\tstw\t8,40(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AddAppMenuItemA(id, userdata, text, msgport, taglist) __AddAppMenuItemA(WorkbenchBase, (id), (userdata), (text), (msgport), (taglist))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct AppMenuItem * __linearvarargs __AddAppMenuItem(void *, ULONG id, ULONG userdata, UBYTE * text, struct MsgPort * msgport, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tstw\t7,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AddAppMenuItem(id, userdata, text, msgport, ...) __AddAppMenuItem(WorkbenchBase, (id), (userdata), (text), (msgport), __VA_ARGS__)
#endif

BOOL __RemoveAppMenuItem(void *, struct AppMenuItem * appMenuItem) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define RemoveAppMenuItem(appMenuItem) __RemoveAppMenuItem(WorkbenchBase, (appMenuItem))

VOID __WBInfo(void *, BPTR lock, STRPTR name, struct Screen * screen) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define WBInfo(lock, name, screen) __WBInfo(WorkbenchBase, (lock), (name), (screen))

BOOL __OpenWorkbenchObjectA(void *, STRPTR name, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define OpenWorkbenchObjectA(name, tags) __OpenWorkbenchObjectA(WorkbenchBase, (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __OpenWorkbenchObject(void *, STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define OpenWorkbenchObject(...) __OpenWorkbenchObject(WorkbenchBase, __VA_ARGS__)
#endif

BOOL __CloseWorkbenchObjectA(void *, STRPTR name, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define CloseWorkbenchObjectA(name, tags) __CloseWorkbenchObjectA(WorkbenchBase, (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __CloseWorkbenchObject(void *, STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define CloseWorkbenchObject(...) __CloseWorkbenchObject(WorkbenchBase, __VA_ARGS__)
#endif

BOOL __WorkbenchControlA(void *, STRPTR name, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define WorkbenchControlA(name, tags) __WorkbenchControlA(WorkbenchBase, (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __WorkbenchControl(void *, STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define WorkbenchControl(...) __WorkbenchControl(WorkbenchBase, __VA_ARGS__)
#endif

struct AppWindowDropZone * __AddAppWindowDropZoneA(void *, struct AppWindow * aw, ULONG id, ULONG userdata, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tstw\t7,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define AddAppWindowDropZoneA(aw, id, userdata, tags) __AddAppWindowDropZoneA(WorkbenchBase, (aw), (id), (userdata), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct AppWindowDropZone * __linearvarargs __AddAppWindowDropZone(void *, struct AppWindow * aw, ULONG id, ULONG userdata, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define AddAppWindowDropZone(aw, id, ...) __AddAppWindowDropZone(WorkbenchBase, (aw), (id), __VA_ARGS__)
#endif

BOOL __RemoveAppWindowDropZone(void *, struct AppWindow * aw, struct AppWindowDropZone * dropZone) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define RemoveAppWindowDropZone(aw, dropZone) __RemoveAppWindowDropZone(WorkbenchBase, (aw), (dropZone))

BOOL __ChangeWorkbenchSelectionA(void *, STRPTR name, struct Hook * hook, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define ChangeWorkbenchSelectionA(name, hook, tags) __ChangeWorkbenchSelectionA(WorkbenchBase, (name), (hook), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __ChangeWorkbenchSelection(void *, STRPTR name, struct Hook * hook, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define ChangeWorkbenchSelection(name, ...) __ChangeWorkbenchSelection(WorkbenchBase, (name), __VA_ARGS__)
#endif

BOOL __MakeWorkbenchObjectVisibleA(void *, STRPTR name, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define MakeWorkbenchObjectVisibleA(name, tags) __MakeWorkbenchObjectVisibleA(WorkbenchBase, (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __MakeWorkbenchObjectVisible(void *, STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define MakeWorkbenchObjectVisible(...) __MakeWorkbenchObjectVisible(WorkbenchBase, __VA_ARGS__)
#endif

#endif /*  _VBCCINLINE_WB_H  */
