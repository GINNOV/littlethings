#ifndef _VBCCINLINE_MATHIEEEDOUBBAS_H
#define _VBCCINLINE_MATHIEEEDOUBBAS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

DOUBLE __IEEEDPFlt(void *, LONG integer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define IEEEDPFlt(integer) __IEEEDPFlt(MathIeeeDoubBasBase, (integer))

#endif /*  _VBCCINLINE_MATHIEEEDOUBBAS_H  */
