#ifndef _VBCCINLINE_ICON_H
#define _VBCCINLINE_ICON_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __FreeFreeList(void *, struct FreeList * freelist) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define FreeFreeList(freelist) __FreeFreeList(IconBase, (freelist))

BOOL __AddFreeList(void *, struct FreeList * freelist, CONST APTR mem, ULONG size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define AddFreeList(freelist, mem, size) __AddFreeList(IconBase, (freelist), (mem), (size))

struct DiskObject * __GetDiskObject(void *, CONST STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define GetDiskObject(name) __GetDiskObject(IconBase, (name))

BOOL __PutDiskObject(void *, CONST STRPTR name, CONST struct DiskObject * diskobj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define PutDiskObject(name, diskobj) __PutDiskObject(IconBase, (name), (diskobj))

VOID __FreeDiskObject(void *, struct DiskObject * diskobj) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define FreeDiskObject(diskobj) __FreeDiskObject(IconBase, (diskobj))

UBYTE * __FindToolType(void *, CONST STRPTR * toolTypeArray, CONST STRPTR typeName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define FindToolType(toolTypeArray, typeName) __FindToolType(IconBase, (toolTypeArray), (typeName))

BOOL __MatchToolValue(void *, CONST STRPTR typeString, CONST STRPTR value) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define MatchToolValue(typeString, value) __MatchToolValue(IconBase, (typeString), (value))

STRPTR __BumpRevision(void *, STRPTR newname, CONST STRPTR oldname) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define BumpRevision(newname, oldname) __BumpRevision(IconBase, (newname), (oldname))

struct DiskObject * __GetDefDiskObject(void *, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define GetDefDiskObject(type) __GetDefDiskObject(IconBase, (type))

BOOL __PutDefDiskObject(void *, CONST struct DiskObject * diskObject) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define PutDefDiskObject(diskObject) __PutDefDiskObject(IconBase, (diskObject))

struct DiskObject * __GetDiskObjectNew(void *, CONST STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define GetDiskObjectNew(name) __GetDiskObjectNew(IconBase, (name))

BOOL __DeleteDiskObject(void *, CONST STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define DeleteDiskObject(name) __DeleteDiskObject(IconBase, (name))

struct DiskObject * __DupDiskObjectA(void *, CONST struct DiskObject * diskObject, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define DupDiskObjectA(diskObject, tags) __DupDiskObjectA(IconBase, (diskObject), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct DiskObject * __linearvarargs __DupDiskObject(void *, CONST struct DiskObject * diskObject, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define DupDiskObject(...) __DupDiskObject(IconBase, __VA_ARGS__)
#endif

ULONG __IconControlA(void *, struct DiskObject * icon, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define IconControlA(icon, tags) __IconControlA(IconBase, (icon), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
ULONG __linearvarargs __IconControl(void *, struct DiskObject * icon, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define IconControl(...) __IconControl(IconBase, __VA_ARGS__)
#endif

VOID __DrawIconStateA(void *, struct RastPort * rp, CONST struct DiskObject * icon, CONST STRPTR label, LONG leftOffset, LONG topOffset, ULONG state, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,8(2)\n"
	"\tstw\t10,44(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define DrawIconStateA(rp, icon, label, leftOffset, topOffset, state, tags) __DrawIconStateA(IconBase, (rp), (icon), (label), (leftOffset), (topOffset), (state), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
VOID __linearvarargs __DrawIconState(void *, struct RastPort * rp, CONST struct DiskObject * icon, CONST STRPTR label, LONG leftOffset, LONG topOffset, ULONG state, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tstw\t9,8(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,44(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define DrawIconState(rp, icon, label, leftOffset, topOffset, ...) __DrawIconState(IconBase, (rp), (icon), (label), (leftOffset), (topOffset), __VA_ARGS__)
#endif

BOOL __GetIconRectangleA(void *, struct RastPort * rp, CONST struct DiskObject * icon, CONST STRPTR label, struct Rectangle * rect, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\tstw\t8,48(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define GetIconRectangleA(rp, icon, label, rect, tags) __GetIconRectangleA(IconBase, (rp), (icon), (label), (rect), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __GetIconRectangle(void *, struct RastPort * rp, CONST struct DiskObject * icon, CONST STRPTR label, struct Rectangle * rect, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,44(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,48(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define GetIconRectangle(rp, icon, label, ...) __GetIconRectangle(IconBase, (rp), (icon), (label), __VA_ARGS__)
#endif

struct DiskObject * __NewDiskObject(void *, LONG type) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define NewDiskObject(type) __NewDiskObject(IconBase, (type))

struct DiskObject * __GetIconTagList(void *, CONST STRPTR name, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define GetIconTagList(name, tags) __GetIconTagList(IconBase, (name), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
struct DiskObject * __linearvarargs __GetIconTags(void *, CONST STRPTR name, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,36(2)\n"
	"\tli\t3,-180\n"
	"\tbctrl";
#define GetIconTags(...) __GetIconTags(IconBase, __VA_ARGS__)
#endif

BOOL __PutIconTagList(void *, CONST STRPTR name, CONST struct DiskObject * icon, CONST struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define PutIconTagList(name, icon, tags) __PutIconTagList(IconBase, (name), (icon), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __PutIconTags(void *, CONST STRPTR name, CONST struct DiskObject * icon, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-186\n"
	"\tbctrl";
#define PutIconTags(name, ...) __PutIconTags(IconBase, (name), __VA_ARGS__)
#endif

BOOL __LayoutIconA(void *, struct DiskObject * icon, struct Screen * screen, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define LayoutIconA(icon, screen, tags) __LayoutIconA(IconBase, (icon), (screen), (tags))

#if !defined(NO_INLINE_STDARG) && (__STDC__ == 1L) && (__STDC_VERSION__ >= 199901L)
BOOL __linearvarargs __LayoutIcon(void *, struct DiskObject * icon, struct Screen * screen, ...) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\taddi\t12,1,8\n"
	"\tstw\t12,40(2)\n"
	"\tli\t3,-192\n"
	"\tbctrl";
#define LayoutIcon(icon, ...) __LayoutIcon(IconBase, (icon), __VA_ARGS__)
#endif

VOID __ChangeToSelectedIconColor(void *, struct ColorRegister * cr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define ChangeToSelectedIconColor(cr) __ChangeToSelectedIconColor(IconBase, (cr))

#endif /*  _VBCCINLINE_ICON_H  */
