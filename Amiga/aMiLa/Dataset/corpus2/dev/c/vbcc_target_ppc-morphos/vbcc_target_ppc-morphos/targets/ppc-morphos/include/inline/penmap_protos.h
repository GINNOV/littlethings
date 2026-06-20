#ifndef _VBCCINLINE_PENMAP_H
#define _VBCCINLINE_PENMAP_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __PENMAP_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define PENMAP_GetClass() __PENMAP_GetClass(PenMapBase)

#endif /*  _VBCCINLINE_PENMAP_H  */
