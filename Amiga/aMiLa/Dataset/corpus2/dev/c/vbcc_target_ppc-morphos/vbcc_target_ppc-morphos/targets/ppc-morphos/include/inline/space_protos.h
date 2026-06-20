#ifndef _VBCCINLINE_SPACE_H
#define _VBCCINLINE_SPACE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

Class * __SPACE_GetClass(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define SPACE_GetClass() __SPACE_GetClass(SpaceBase)

#endif /*  _VBCCINLINE_SPACE_H  */
