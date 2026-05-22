#ifndef _VBCCINLINE_QUERY_H
#define _VBCCINLINE_QUERY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void * __QueryCreatePathNode(void *, char * Path, char * Pattern, ULONG Flags) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryCreatePathNode(Path, Pattern, Flags) __QueryCreatePathNode(QueryBase, (Path), (Pattern), (Flags))

void * __QueryDeletePathNode(void *, void * PathNode) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryDeletePathNode(PathNode) __QueryDeletePathNode(QueryBase, (PathNode))

void * __QueryObtainTagList(void *, void * QueryInfo, struct TagItem * MyTags) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryObtainTagList(QueryInfo, MyTags) __QueryObtainTagList(QueryBase, (QueryInfo), (MyTags))

void * __QueryObtainTags(void *, void * QueryInfo, ...) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryObtainTags(...) __QueryObtainTags(QueryBase, __VA_ARGS__)

void __QueryRelease(void *, void * QueryInfo) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryRelease(QueryInfo) __QueryRelease(QueryBase, (QueryInfo))

ULONG __QueryGetAttr(void *, void * QueryInfo, APTR Data, ULONG Attr) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryGetAttr(QueryInfo, Data, Attr) __QueryGetAttr(QueryBase, (QueryInfo), (Data), (Attr))

ULONG __QueryGetLibraryAttr(void *, struct Library * library, APTR Data, ULONG Attr) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryGetLibraryAttr(library, Data, Attr) __QueryGetLibraryAttr(QueryBase, (library), (Data), (Attr))

ULONG __QueryGetDeviceAttr(void *, struct Device * device, APTR Data, ULONG Attr) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryGetDeviceAttr(device, Data, Attr) __QueryGetDeviceAttr(QueryBase, (device), (Data), (Attr))

ULONG __QueryGetResidentAttr(void *, struct Resident * resident, APTR Data, ULONG Attr) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define QueryGetResidentAttr(resident, Data, Attr) __QueryGetResidentAttr(QueryBase, (resident), (Data), (Attr))

#endif /*  _VBCCINLINE_QUERY_H  */
