#ifndef _VBCCINLINE_MATHIEEEDOUBTRANS_H
#define _VBCCINLINE_MATHIEEEDOUBTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

DOUBLE __IEEEDPFieee(void *, FLOAT single) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define IEEEDPFieee(single) __IEEEDPFieee(MathIeeeDoubTransBase, (single))

#endif /*  _VBCCINLINE_MATHIEEEDOUBTRANS_H  */
