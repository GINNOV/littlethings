#ifndef _VBCCINLINE_NOTIFYINTUITION_H
#define _VBCCINLINE_NOTIFYINTUITION_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct IntNotifyRequest * __NotIStartNotify(void *, struct IntNotifyRequest * notirequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define NotIStartNotify(notirequest) __NotIStartNotify(NotIBase, (notirequest))

struct IntNotifyRequest * __NotIEndNotify(void *, struct IntNotifyRequest * notirequest) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define NotIEndNotify(notirequest) __NotIEndNotify(NotIBase, (notirequest))

struct Task * __NotIFindUniqueTask(void *, ULONG uniqueid) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define NotIFindUniqueTask(uniqueid) __NotIFindUniqueTask(NotIBase, (uniqueid))

#endif /*  _VBCCINLINE_NOTIFYINTUITION_H  */
