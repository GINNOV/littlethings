#ifndef _VBCCINLINE_NONVOLATILE_H
#define _VBCCINLINE_NONVOLATILE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __GetCopyNV(void *, CONST_STRPTR appName, CONST_STRPTR itemName, LONG killRequesters) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define GetCopyNV(appName, itemName, killRequesters) __GetCopyNV(NVBase, (appName), (itemName), (killRequesters))

VOID __FreeNVData(void *, APTR data) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define FreeNVData(data) __FreeNVData(NVBase, (data))

UWORD __StoreNV(void *, CONST_STRPTR appName, CONST_STRPTR itemName, CONST APTR data, ULONG length, LONG killRequesters) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,40(2)\n"
	"\tstw\t7,0(2)\n"
	"\tstw\t8,4(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define StoreNV(appName, itemName, data, length, killRequesters) __StoreNV(NVBase, (appName), (itemName), (data), (length), (killRequesters))

BOOL __DeleteNV(void *, CONST_STRPTR appName, CONST_STRPTR itemName, LONG killRequesters) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define DeleteNV(appName, itemName, killRequesters) __DeleteNV(NVBase, (appName), (itemName), (killRequesters))

struct NVInfo * __GetNVInfo(void *, LONG killRequesters) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define GetNVInfo(killRequesters) __GetNVInfo(NVBase, (killRequesters))

struct MinList * __GetNVList(void *, CONST_STRPTR appName, LONG killRequesters) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define GetNVList(appName, killRequesters) __GetNVList(NVBase, (appName), (killRequesters))

BOOL __SetNVProtection(void *, CONST_STRPTR appName, CONST_STRPTR itemName, LONG mask, LONG killRequesters) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,8(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SetNVProtection(appName, itemName, mask, killRequesters) __SetNVProtection(NVBase, (appName), (itemName), (mask), (killRequesters))

#endif /*  _VBCCINLINE_NONVOLATILE_H  */
