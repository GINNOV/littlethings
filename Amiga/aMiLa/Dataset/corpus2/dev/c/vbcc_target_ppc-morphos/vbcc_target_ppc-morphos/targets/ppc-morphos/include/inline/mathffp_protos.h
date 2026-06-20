#ifndef _VBCCINLINE_MATHFFP_H
#define _VBCCINLINE_MATHFFP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __SPFix(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define SPFix(parm) __SPFix(MathBase, (parm))

FLOAT __SPFlt(void *, LONG integer) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define SPFlt(integer) __SPFlt(MathBase, (integer))

LONG __SPCmp(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define SPCmp(leftParm, rightParm) __SPCmp(MathBase, (leftParm), (rightParm))

LONG __SPTst(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SPTst(parm) __SPTst(MathBase, (parm))

FLOAT __SPAbs(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define SPAbs(parm) __SPAbs(MathBase, (parm))

FLOAT __SPNeg(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define SPNeg(parm) __SPNeg(MathBase, (parm))

FLOAT __SPAdd(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define SPAdd(leftParm, rightParm) __SPAdd(MathBase, (leftParm), (rightParm))

FLOAT __SPSub(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define SPSub(leftParm, rightParm) __SPSub(MathBase, (leftParm), (rightParm))

FLOAT __SPMul(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define SPMul(leftParm, rightParm) __SPMul(MathBase, (leftParm), (rightParm))

FLOAT __SPDiv(void *, FLOAT leftParm, FLOAT rightParm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,4(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define SPDiv(leftParm, rightParm) __SPDiv(MathBase, (leftParm), (rightParm))

FLOAT __SPFloor(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define SPFloor(parm) __SPFloor(MathBase, (parm))

FLOAT __SPCeil(void *, FLOAT parm) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define SPCeil(parm) __SPCeil(MathBase, (parm))

#endif /*  _VBCCINLINE_MATHFFP_H  */
