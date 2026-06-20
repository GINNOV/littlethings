#ifndef _VBCCINLINE_IFCONFIG_H
#define _VBCCINLINE_IFCONFIG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __IfConfigFind(void *, const char * ifname, struct ifconfig ** ifcp) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define IfConfigFind(ifname, ifcp) __IfConfigFind(IfConfigBase, (ifname), (ifcp))

void __IfConfigFree(void *, struct ifconfig * config) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define IfConfigFree(config) __IfConfigFree(IfConfigBase, (config))

LONG __IfConfigFindAll(void *, struct List ** ifclist, struct TagItem * filter) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define IfConfigFindAll(ifclist, filter) __IfConfigFindAll(IfConfigBase, (ifclist), (filter))

void __IfConfigFreeList(void *, struct List * list) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define IfConfigFreeList(list) __IfConfigFreeList(IfConfigBase, (list))

const UBYTE * __IfConfigStrError(void *, ULONG ioerr, char * buf, ULONG bufsiz) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define IfConfigStrError(ioerr, buf, bufsiz) __IfConfigStrError(IfConfigBase, (ioerr), (buf), (bufsiz))

const struct ifc_confitem * __IfConfigGetTagInfo(void *, ULONG tagcode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define IfConfigGetTagInfo(tagcode) __IfConfigGetTagInfo(IfConfigBase, (tagcode))

struct ifconfig * __IfConfigCreate(void *, char * buf, ULONG bufsize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define IfConfigCreate(buf, bufsize) __IfConfigCreate(IfConfigBase, (buf), (bufsize))

ULONG __IfConfigGetData(void *, ULONG tagcode, ULONG d1arg, struct ifconfig * config) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define IfConfigGetData(tagcode, d1arg, config) __IfConfigGetData(IfConfigBase, (tagcode), (d1arg), (config))

#endif /*  _VBCCINLINE_IFCONFIG_H  */
