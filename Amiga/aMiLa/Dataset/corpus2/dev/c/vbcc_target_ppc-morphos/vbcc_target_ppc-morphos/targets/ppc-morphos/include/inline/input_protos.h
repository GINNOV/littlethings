#ifndef _VBCCINLINE_INPUT_H
#define _VBCCINLINE_INPUT_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

UWORD __PeekQualifier(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define PeekQualifier() __PeekQualifier(InputBase)

#endif /*  _VBCCINLINE_INPUT_H  */
