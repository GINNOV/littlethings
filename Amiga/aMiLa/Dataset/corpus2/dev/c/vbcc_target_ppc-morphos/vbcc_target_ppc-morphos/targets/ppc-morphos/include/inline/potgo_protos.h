#ifndef _VBCCINLINE_POTGO_H
#define _VBCCINLINE_POTGO_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

UWORD __AllocPotBits(void *, ULONG bits) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-6\n"
	"\tbctrl";
#define AllocPotBits(bits) __AllocPotBits(PotgoBase, (bits))

VOID __FreePotBits(void *, ULONG bits) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-12\n"
	"\tbctrl";
#define FreePotBits(bits) __FreePotBits(PotgoBase, (bits))

VOID __WritePotgo(void *, ULONG word, ULONG mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-18\n"
	"\tbctrl";
#define WritePotgo(word, mask) __WritePotgo(PotgoBase, (word), (mask))

#endif /*  _VBCCINLINE_POTGO_H  */
