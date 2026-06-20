#ifndef _VBCCINLINE_MATHIEEESINGBAS_H
#define _VBCCINLINE_MATHIEEESINGBAS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __IEEESPFix(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define IEEESPFix(parm) __IEEESPFix(MathIeeeSingBasBase, (parm))

FLOAT __IEEESPFlt(void *, LONG integer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define IEEESPFlt(integer) __IEEESPFlt(MathIeeeSingBasBase, (integer))

LONG __IEEESPCmp(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define IEEESPCmp(leftParm, rightParm) __IEEESPCmp(MathIeeeSingBasBase, (leftParm), (rightParm))

LONG __IEEESPTst(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define IEEESPTst(parm) __IEEESPTst(MathIeeeSingBasBase, (parm))

FLOAT __IEEESPAbs(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define IEEESPAbs(parm) __IEEESPAbs(MathIeeeSingBasBase, (parm))

FLOAT __IEEESPNeg(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define IEEESPNeg(parm) __IEEESPNeg(MathIeeeSingBasBase, (parm))

FLOAT __IEEESPAdd(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define IEEESPAdd(leftParm, rightParm) __IEEESPAdd(MathIeeeSingBasBase, (leftParm), (rightParm))

FLOAT __IEEESPSub(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define IEEESPSub(leftParm, rightParm) __IEEESPSub(MathIeeeSingBasBase, (leftParm), (rightParm))

FLOAT __IEEESPMul(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define IEEESPMul(leftParm, rightParm) __IEEESPMul(MathIeeeSingBasBase, (leftParm), (rightParm))

FLOAT __IEEESPDiv(void *, FLOAT dividend, FLOAT divisor) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define IEEESPDiv(dividend, divisor) __IEEESPDiv(MathIeeeSingBasBase, (dividend), (divisor))

FLOAT __IEEESPFloor(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define IEEESPFloor(parm) __IEEESPFloor(MathIeeeSingBasBase, (parm))

FLOAT __IEEESPCeil(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define IEEESPCeil(parm) __IEEESPCeil(MathIeeeSingBasBase, (parm))

#endif /*  _VBCCINLINE_MATHIEEESINGBAS_H  */
