#ifndef _VBCCINLINE_TRANCE_H
#define _VBCCINLINE_TRANCE_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __Trance_Statistics(void *, struct TagItem * tags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define Trance_Statistics(tags) __Trance_Statistics(TranceBase, (tags))

#endif /*  _VBCCINLINE_TRANCE_H  */
