#ifndef _VBCCINLINE_MATHTRANS_H
#define _VBCCINLINE_MATHTRANS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

FLOAT __SPAtan(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define SPAtan(parm) __SPAtan(MathTransBase, (parm))

FLOAT __SPSin(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define SPSin(parm) __SPSin(MathTransBase, (parm))

FLOAT __SPCos(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define SPCos(parm) __SPCos(MathTransBase, (parm))

FLOAT __SPTan(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SPTan(parm) __SPTan(MathTransBase, (parm))

FLOAT __SPSincos(void *, FLOAT * cosResult, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define SPSincos(cosResult, parm) __SPSincos(MathTransBase, (cosResult), (parm))

FLOAT __SPSinh(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define SPSinh(parm) __SPSinh(MathTransBase, (parm))

FLOAT __SPCosh(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SPCosh(parm) __SPCosh(MathTransBase, (parm))

FLOAT __SPTanh(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define SPTanh(parm) __SPTanh(MathTransBase, (parm))

FLOAT __SPExp(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define SPExp(parm) __SPExp(MathTransBase, (parm))

FLOAT __SPLog(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define SPLog(parm) __SPLog(MathTransBase, (parm))

FLOAT __SPPow(void *, FLOAT power, FLOAT arg) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define SPPow(power, arg) __SPPow(MathTransBase, (power), (arg))

FLOAT __SPSqrt(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SPSqrt(parm) __SPSqrt(MathTransBase, (parm))

FLOAT __SPTieee(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define SPTieee(parm) __SPTieee(MathTransBase, (parm))

FLOAT __SPFieee(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define SPFieee(parm) __SPFieee(MathTransBase, (parm))

FLOAT __SPAsin(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define SPAsin(parm) __SPAsin(MathTransBase, (parm))

FLOAT __SPAcos(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define SPAcos(parm) __SPAcos(MathTransBase, (parm))

FLOAT __SPLog10(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define SPLog10(parm) __SPLog10(MathTransBase, (parm))

#endif /*  _VBCCINLINE_MATHTRANS_H  */
