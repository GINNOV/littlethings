#ifndef _VBCCINLINE_AMIGAGUIDECLASS_H
#define _VBCCINLINE_AMIGAGUIDECLASS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif

Class * __ObtainEngine(__reg("a6") void *)="\tjsr\t-30(a6)";
#define ObtainEngine() __ObtainEngine(AmigaGuideClassBase)

LONG __LoadXRef(__reg("a6") void *, __reg("a0") void * lock, __reg("a1") CONST_STRPTR name)="\tjsr\t-36(a6)";
#define LoadXRef(lock, name) __LoadXRef(AmigaGuideClassBase, (void *)(lock), (name))

VOID __ExpungeXRef(__reg("a6") void *)="\tjsr\t-42(a6)";
#define ExpungeXRef() __ExpungeXRef(AmigaGuideClassBase)

BPTR __AddPathEntries(__reg("a6") void *, __reg("a0") void * path, __reg("d0") STRPTR * argptr)="\tjsr\t-48(a6)";
#define AddPathEntries(path, argptr) __AddPathEntries(AmigaGuideClassBase, (void *)(path), (argptr))

BPTR __CopyPathList(__reg("a6") void *, __reg("a0") void * p)="\tjsr\t-54(a6)";
#define CopyPathList(p) __CopyPathList(AmigaGuideClassBase, (void *)(p))

VOID __FreePathList(__reg("a6") void *, __reg("a0") void * p)="\tjsr\t-60(a6)";
#define FreePathList(p) __FreePathList(AmigaGuideClassBase, (void *)(p))

ULONG __ParsePathString(__reg("a6") void *, __reg("d0") STRPTR line, __reg("a0") STRPTR * argv, __reg("d1") ULONG max)="\tjsr\t-66(a6)";
#define ParsePathString(line, argv, max) __ParsePathString(AmigaGuideClassBase, (line), (argv), (max))

BPTR __LockE(__reg("a6") void *, __reg("a0") void * p, __reg("d1") CONST_STRPTR name, __reg("d2") LONG mode)="\tjsr\t-72(a6)";
#define LockE(p, name, mode) __LockE(AmigaGuideClassBase, (void *)(p), (name), (mode))

BPTR __OpenE(__reg("a6") void *, __reg("a0") void * p, __reg("d1") CONST_STRPTR name, __reg("d2") LONG mode)="\tjsr\t-78(a6)";
#define OpenE(p, name, mode) __OpenE(AmigaGuideClassBase, (void *)(p), (name), (mode))

BPTR __SetCurrentDirE(__reg("a6") void *, __reg("a0") void * p, __reg("d1") CONST_STRPTR name)="\tjsr\t-84(a6)";
#define SetCurrentDirE(p, name) __SetCurrentDirE(AmigaGuideClassBase, (void *)(p), (name))

STRPTR __GetAGString(__reg("a6") void *, __reg("d0") LONG id)="\tjsr\t-90(a6)";
#define GetAGString(id) __GetAGString(AmigaGuideClassBase, (id))

ULONG __AddAGHostA(__reg("a6") void *, __reg("a0") struct Hook * h, __reg("d0") CONST_STRPTR name, __reg("a1") struct TagItem * attrs)="\tjsr\t-96(a6)";
#define AddAGHostA(h, name, attrs) __AddAGHostA(AmigaGuideClassBase, (h), (name), (attrs))

LONG __RemoveAGHostA(__reg("a6") void *, __reg("a0") APTR handle, __reg("a1") struct TagItem * attrs)="\tjsr\t-102(a6)";
#define RemoveAGHostA(handle, attrs) __RemoveAGHostA(AmigaGuideClassBase, (handle), (attrs))

LONG __AddXRef(__reg("a6") void *, __reg("a0") CONST_STRPTR name, __reg("a1") CONST_STRPTR file, __reg("d0") LONG line, __reg("d1") LONG type)="\tjsr\t-108(a6)";
#define AddXRef(name, file, line, type) __AddXRef(AmigaGuideClassBase, (name), (file), (line), (type))

struct XRef * __GetXRef(__reg("a6") void *, __reg("a0") CONST_STRPTR name)="\tjsr\t-114(a6)";
#define GetXRef(name) __GetXRef(AmigaGuideClassBase, (name))

#endif /*  _VBCCINLINE_AMIGAGUIDECLASS_H  */
