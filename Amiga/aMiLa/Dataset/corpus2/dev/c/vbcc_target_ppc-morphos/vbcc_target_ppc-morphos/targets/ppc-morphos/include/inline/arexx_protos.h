#ifndef _VBCCINLINE_AREXX_H
#define _VBCCINLINE_AREXX_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __AREXX_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define AREXX_GetClass() __AREXX_GetClass(ARexxBase)

#endif /*  _VBCCINLINE_AREXX_H  */
