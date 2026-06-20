#ifndef _VBCCINLINE_REQUESTER_H
#define _VBCCINLINE_REQUESTER_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __REQUESTER_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define REQUESTER_GetClass() __REQUESTER_GetClass(RequesterBase)

#endif /*  _VBCCINLINE_REQUESTER_H  */
