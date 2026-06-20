#ifndef _VBCCINLINE_RAMDRIVE_H
#define _VBCCINLINE_RAMDRIVE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

STRPTR __KillRAD0(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define KillRAD0() __KillRAD0(RamdriveDevice)

STRPTR __KillRAD(void *, ULONG unit) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define KillRAD(unit) __KillRAD(RamdriveDevice, (unit))

#endif /*  _VBCCINLINE_RAMDRIVE_H  */
