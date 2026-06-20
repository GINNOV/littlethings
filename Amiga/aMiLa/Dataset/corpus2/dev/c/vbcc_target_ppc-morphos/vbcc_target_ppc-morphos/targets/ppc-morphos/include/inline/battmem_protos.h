#ifndef _VBCCINLINE_BATTMEM_H
#define _VBCCINLINE_BATTMEM_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __ObtainBattSemaphore(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-6\n"
	"\tbctrl";
#define ObtainBattSemaphore() __ObtainBattSemaphore(BattMemBase)

VOID __ReleaseBattSemaphore(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-12\n"
	"\tbctrl";
#define ReleaseBattSemaphore() __ReleaseBattSemaphore(BattMemBase)

ULONG __ReadBattMem(void *, APTR buffer, ULONG offset, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-18\n"
	"\tbctrl";
#define ReadBattMem(buffer, offset, length) __ReadBattMem(BattMemBase, (buffer), (offset), (length))

ULONG __WriteBattMem(void *, CONST APTR buffer, ULONG offset, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-24\n"
	"\tbctrl";
#define WriteBattMem(buffer, offset, length) __WriteBattMem(BattMemBase, (buffer), (offset), (length))

#endif /*  _VBCCINLINE_BATTMEM_H  */
