#ifndef _VBCCINLINE_BEVEL_H
#define _VBCCINLINE_BEVEL_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __BEVEL_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define BEVEL_GetClass() __BEVEL_GetClass(BevelBase)

#endif /*  _VBCCINLINE_BEVEL_H  */
