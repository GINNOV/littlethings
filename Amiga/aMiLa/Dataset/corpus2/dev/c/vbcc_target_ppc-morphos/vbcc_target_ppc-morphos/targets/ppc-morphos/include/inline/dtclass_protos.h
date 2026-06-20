#ifndef _VBCCINLINE_DTCLASS_H
#define _VBCCINLINE_DTCLASS_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __ObtainEngine(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define ObtainEngine() __ObtainEngine(DTClassBase)

#endif /*  _VBCCINLINE_DTCLASS_H  */
