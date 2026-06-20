#ifndef _VBCCINLINE_GETFILE_H
#define _VBCCINLINE_GETFILE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __GETFILE_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define GETFILE_GetClass() __GETFILE_GetClass(GetFileBase)

#endif /*  _VBCCINLINE_GETFILE_H  */
