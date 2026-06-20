#ifndef _VBCCINLINE_MATHIEEESINGTRANS_H
#define _VBCCINLINE_MATHIEEESINGTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

FLOAT __IEEESPAtan(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define IEEESPAtan(parm) __IEEESPAtan(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPSin(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define IEEESPSin(parm) __IEEESPSin(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPCos(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define IEEESPCos(parm) __IEEESPCos(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPTan(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define IEEESPTan(parm) __IEEESPTan(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPSincos(void *, FLOAT * cosptr, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define IEEESPSincos(cosptr, parm) __IEEESPSincos(MathIeeeSingTransBase, (cosptr), (parm))

FLOAT __IEEESPSinh(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define IEEESPSinh(parm) __IEEESPSinh(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPCosh(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define IEEESPCosh(parm) __IEEESPCosh(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPTanh(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define IEEESPTanh(parm) __IEEESPTanh(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPExp(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define IEEESPExp(parm) __IEEESPExp(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPLog(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define IEEESPLog(parm) __IEEESPLog(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPPow(void *, FLOAT exp, FLOAT arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define IEEESPPow(exp, arg) __IEEESPPow(MathIeeeSingTransBase, (exp), (arg))

FLOAT __IEEESPSqrt(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define IEEESPSqrt(parm) __IEEESPSqrt(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPTieee(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define IEEESPTieee(parm) __IEEESPTieee(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPFieee(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define IEEESPFieee(parm) __IEEESPFieee(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPAsin(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define IEEESPAsin(parm) __IEEESPAsin(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPAcos(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define IEEESPAcos(parm) __IEEESPAcos(MathIeeeSingTransBase, (parm))

FLOAT __IEEESPLog10(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define IEEESPLog10(parm) __IEEESPLog10(MathIeeeSingTransBase, (parm))

#endif /*  _VBCCINLINE_MATHIEEESINGTRANS_H  */
