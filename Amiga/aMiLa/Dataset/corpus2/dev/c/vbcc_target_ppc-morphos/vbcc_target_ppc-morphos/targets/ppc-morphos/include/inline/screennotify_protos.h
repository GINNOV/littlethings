#ifndef _VBCCINLINE_SCREENNOTIFY_H
#define _VBCCINLINE_SCREENNOTIFY_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

APTR __AddCloseScreenClient(void *, struct Screen * screen, struct MsgPort * port, BYTE pri) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define AddCloseScreenClient(screen, port, pri) __AddCloseScreenClient(ScreenNotifyBase, (screen), (port), (pri))

BOOL __RemCloseScreenClient(void *, APTR handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define RemCloseScreenClient(handle) __RemCloseScreenClient(ScreenNotifyBase, (handle))

APTR __AddPubScreenClient(void *, struct MsgPort * port, BYTE pri) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define AddPubScreenClient(port, pri) __AddPubScreenClient(ScreenNotifyBase, (port), (pri))

BOOL __RemPubScreenClient(void *, APTR handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define RemPubScreenClient(handle) __RemPubScreenClient(ScreenNotifyBase, (handle))

APTR __AddWorkbenchClient(void *, struct MsgPort * port, BYTE pri) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define AddWorkbenchClient(port, pri) __AddWorkbenchClient(ScreenNotifyBase, (port), (pri))

BOOL __RemWorkbenchClient(void *, APTR handle) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define RemWorkbenchClient(handle) __RemWorkbenchClient(ScreenNotifyBase, (handle))

#endif /*  _VBCCINLINE_SCREENNOTIFY_H  */
