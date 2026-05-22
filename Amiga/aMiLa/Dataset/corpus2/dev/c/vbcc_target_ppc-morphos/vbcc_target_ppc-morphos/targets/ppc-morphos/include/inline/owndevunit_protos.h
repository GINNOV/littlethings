#ifndef _VBCCINLINE_OWNDEVUNIT_H
#define _VBCCINLINE_OWNDEVUNIT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

UBYTE * __LockDevUnit(void *, UBYTE * device, ULONG unit, UBYTE * OwnerName, UBYTE NotifyBit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define LockDevUnit(device, unit, OwnerName, NotifyBit) __LockDevUnit(OwnDevUnitBase, (device), (unit), (OwnerName), (NotifyBit))

UBYTE * __AttemptDevUnit(void *, UBYTE * device, ULONG unit, UBYTE * OwnerName, UBYTE NotifyBit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tstw\t7,4(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define AttemptDevUnit(device, unit, OwnerName, NotifyBit) __AttemptDevUnit(OwnDevUnitBase, (device), (unit), (OwnerName), (NotifyBit))

void __FreeDevUnit(void *, UBYTE * device, ULONG unit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define FreeDevUnit(device, unit) __FreeDevUnit(OwnDevUnitBase, (device), (unit))

void __NameDevUnit(void *, UBYTE * device, ULONG unit, UBYTE * OwnerName) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define NameDevUnit(device, unit, OwnerName) __NameDevUnit(OwnDevUnitBase, (device), (unit), (OwnerName))

BOOL __AvailDevUnit(void *, UBYTE * device, ULONG unit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define AvailDevUnit(device, unit) __AvailDevUnit(OwnDevUnitBase, (device), (unit))

#endif /*  _VBCCINLINE_OWNDEVUNIT_H  */
