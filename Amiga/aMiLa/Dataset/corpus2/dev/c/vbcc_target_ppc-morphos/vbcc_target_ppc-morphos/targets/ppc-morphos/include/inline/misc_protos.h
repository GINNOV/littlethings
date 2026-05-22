#ifndef _VBCCINLINE_MISC_H
#define _VBCCINLINE_MISC_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

UBYTE * __AllocMiscResource(void *, ULONG unitNum, CONST_STRPTR name) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-6\n"
	"\tbctrl";
#define AllocMiscResource(unitNum, name) __AllocMiscResource(MiscBase, (unitNum), (name))

VOID __FreeMiscResource(void *, ULONG unitNum) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-12\n"
	"\tbctrl";
#define FreeMiscResource(unitNum) __FreeMiscResource(MiscBase, (unitNum))

#endif /*  _VBCCINLINE_MISC_H  */
