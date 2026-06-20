#ifndef _VBCCINLINE_MOUNT_H
#define _VBCCINLINE_MOUNT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void * __MountCreateNotifyUnitTagList(void *, struct TagItem * MyTags) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountCreateNotifyUnitTagList(MyTags) __MountCreateNotifyUnitTagList(MountBase, (MyTags))

void * __MountCreateNotifyUnitTags(void *, ...) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountCreateNotifyUnitTags(...) __MountCreateNotifyUnitTags(MountBase, __VA_ARGS__)

void __MountDeleteNotifyUnit(void *, void * NotifyUnit) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountDeleteNotifyUnit(NotifyUnit) __MountDeleteNotifyUnit(MountBase, (NotifyUnit))

ULONG __MountGetNotifyUnitAttr(void *, void * NotifyUnit, APTR Data, ULONG Attr) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountGetNotifyUnitAttr(NotifyUnit, Data, Attr) __MountGetNotifyUnitAttr(MountBase, (NotifyUnit), (Data), (Attr))

void * __MountCreateNotifyNodeTagList(void *, void * NotifyUnit, struct TagItem * MyTags) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountCreateNotifyNodeTagList(NotifyUnit, MyTags) __MountCreateNotifyNodeTagList(MountBase, (NotifyUnit), (MyTags))

void * __MountCreateNotifyNodeTags(void *, void * NotifyUnit, ...) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountCreateNotifyNodeTags(...) __MountCreateNotifyNodeTags(MountBase, __VA_ARGS__)

void __MountDeleteNotifyNode(void *, void * NotifyNode) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountDeleteNotifyNode(NotifyNode) __MountDeleteNotifyNode(MountBase, (NotifyNode))

void * __MountFindNotifyNodeTagList(void *, void  * NotifyUnit, struct TagItem * MyTags) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountFindNotifyNodeTagList(NotifyUnit, MyTags) __MountFindNotifyNodeTagList(MountBase, (NotifyUnit), (MyTags))

void * __MountFindNotifyNodeTags(void *, void  * NotifyUnit, ...) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountFindNotifyNodeTags(...) __MountFindNotifyNodeTags(MountBase, __VA_ARGS__)

ULONG __MountMountTagList(void *, void   * NotifyUnit, struct TagItem * MyTags) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountMountTagList(NotifyUnit, MyTags) __MountMountTagList(MountBase, (NotifyUnit), (MyTags))

ULONG __MountMountTags(void *, void * NotifyUnit, ...) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountMountTags(...) __MountMountTags(MountBase, __VA_ARGS__)

ULONG __MountDisMountTagList(void *, void  * NotifyUnit, struct TagItem * MyTags) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountDisMountTagList(NotifyUnit, MyTags) __MountDisMountTagList(MountBase, (NotifyUnit), (MyTags))

ULONG __MountDisMountTags(void *, void * NotifyUnit, ...) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountDisMountTags(...) __MountDisMountTags(MountBase, __VA_ARGS__)

void __MountNotifyAll(void *, void * NotifyUnit, ULONG ChangeState) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountNotifyAll(NotifyUnit, ChangeState) __MountNotifyAll(MountBase, (NotifyUnit), (ChangeState))

void __MountNotifySet(void *, void * NotifyUnit, ULONG ChangeState) =
	"\tlwz\t0,-82(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountNotifySet(NotifyUnit, ChangeState) __MountNotifySet(MountBase, (NotifyUnit), (ChangeState))

void __MountNotifyTask(void *, void  * NotifyUnit, struct Task * task, ULONG ChangeState) =
	"\tlwz\t0,-88(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountNotifyTask(NotifyUnit, task, ChangeState) __MountNotifyTask(MountBase, (NotifyUnit), (task), (ChangeState))

ULONG __MountUpdateNotifyUnitConfigTagList(void *, void   * NotifyUnit, struct TagItem * MyTags) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountUpdateNotifyUnitConfigTagList(NotifyUnit, MyTags) __MountUpdateNotifyUnitConfigTagList(MountBase, (NotifyUnit), (MyTags))

ULONG __MountUpdateNotifyUnitConfigTags(void *, void  * NotifyUnit, ...) =
	"\tlwz\t0,-94(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountUpdateNotifyUnitConfigTags(...) __MountUpdateNotifyUnitConfigTags(MountBase, __VA_ARGS__)

ULONG __MountMountDiskHandlersTagList(void *, struct TagItem * MyTags) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountMountDiskHandlersTagList(MyTags) __MountMountDiskHandlersTagList(MountBase, (MyTags))

ULONG __MountMountDiskHandlersTags(void *, ...) =
	"\tlwz\t0,-100(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define MountMountDiskHandlersTags(...) __MountMountDiskHandlersTags(MountBase, __VA_ARGS__)

#endif /*  _VBCCINLINE_MOUNT_H  */
