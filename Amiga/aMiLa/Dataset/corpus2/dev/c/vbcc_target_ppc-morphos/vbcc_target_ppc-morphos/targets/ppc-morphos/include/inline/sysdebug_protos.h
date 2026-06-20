#ifndef _VBCCINLINE_SYSDEBUG_H
#define _VBCCINLINE_SYSDEBUG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

STRPTR __SysDebugFindSeg(void *, ULONG Address, ULONG * SegNum, ULONG * Offset) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SysDebugFindSeg(Address, SegNum, Offset) __SysDebugFindSeg(SysDebugBase, (Address), (SegNum), (Offset))

#endif /*  _VBCCINLINE_SYSDEBUG_H  */
