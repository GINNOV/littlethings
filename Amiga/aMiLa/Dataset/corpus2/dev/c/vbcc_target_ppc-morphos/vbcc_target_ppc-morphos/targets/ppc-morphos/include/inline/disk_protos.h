#ifndef _VBCCINLINE_DISK_H
#define _VBCCINLINE_DISK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

BOOL __AllocUnit(void *, LONG unitNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-6\n"
	"\tbctrl";
#define AllocUnit(unitNum) __AllocUnit(DiskBase, (unitNum))

VOID __FreeUnit(void *, LONG unitNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-12\n"
	"\tbctrl";
#define FreeUnit(unitNum) __FreeUnit(DiskBase, (unitNum))

struct DiscResourceUnit * __GetUnit(void *, struct DiscResourceUnit * unitPointer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,36(2)\n"
	"\tli\t3,-18\n"
	"\tbctrl";
#define GetUnit(unitPointer) __GetUnit(DiskBase, (unitPointer))

VOID __GiveUnit(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-24\n"
	"\tbctrl";
#define GiveUnit() __GiveUnit(DiskBase)

LONG __GetUnitID(void *, LONG unitNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define GetUnitID(unitNum) __GetUnitID(DiskBase, (unitNum))

LONG __ReadUnitID(void *, LONG unitNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define ReadUnitID(unitNum) __ReadUnitID(DiskBase, (unitNum))

#endif /*  _VBCCINLINE_DISK_H  */
