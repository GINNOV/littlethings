#ifndef _VBCCINLINE_TIMER_H
#define _VBCCINLINE_TIMER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

VOID __AddTime(void *, struct timeval * dest, CONST struct timeval * src) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AddTime(dest, src) __AddTime(TimerBase, (dest), (src))

VOID __SubTime(void *, struct timeval * dest, CONST struct timeval * src) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SubTime(dest, src) __SubTime(TimerBase, (dest), (src))

LONG __CmpTime(void *, CONST struct timeval * dest, CONST struct timeval * src) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define CmpTime(dest, src) __CmpTime(TimerBase, (dest), (src))

ULONG __ReadEClock(void *, struct EClockVal * dest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define ReadEClock(dest) __ReadEClock(TimerBase, (dest))

VOID __GetSysTime(void *, struct timeval * dest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define GetSysTime(dest) __GetSysTime(TimerBase, (dest))

ULONG __ReadCPUClock(void *, UQUAD * dest) =
	"\tlwz\t0,-70(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define ReadCPUClock(dest) __ReadCPUClock(TimerBase, (dest))

VOID __GetUpTime(void *, struct timeval * dest) =
	"\tlwz\t0,-76(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define GetUpTime(dest) __GetUpTime(TimerBase, (dest))

#endif /*  _VBCCINLINE_TIMER_H  */
