#ifndef _VBCCINLINE_BATTCLOCK_H
#define _VBCCINLINE_BATTCLOCK_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __ResetBattClock(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-6\n"
	"\tbctrl";
#define ResetBattClock() __ResetBattClock(BattClockBase)

ULONG __ReadBattClock(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-12\n"
	"\tbctrl";
#define ReadBattClock() __ReadBattClock(BattClockBase)

VOID __WriteBattClock(void *, ULONG time) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-18\n"
	"\tbctrl";
#define WriteBattClock(time) __WriteBattClock(BattClockBase, (time))

#endif /*  _VBCCINLINE_BATTCLOCK_H  */
