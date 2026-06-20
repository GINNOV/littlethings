#ifndef _VBCCINLINE_DATEBROWSER_H
#define _VBCCINLINE_DATEBROWSER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __DATEBROWSER_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define DATEBROWSER_GetClass() __DATEBROWSER_GetClass(DateBrowserBase)

UWORD __JulianWeekDay(void *, ULONG day, ULONG month, LONG year) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,8(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define JulianWeekDay(day, month, year) __JulianWeekDay(DateBrowserBase, (day), (month), (year))

UWORD __JulianMonthDays(void *, ULONG month, LONG year) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define JulianMonthDays(month, year) __JulianMonthDays(DateBrowserBase, (month), (year))

BOOL __JulianLeapYear(void *, LONG year) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define JulianLeapYear(year) __JulianLeapYear(DateBrowserBase, (year))

#endif /*  _VBCCINLINE_DATEBROWSER_H  */
