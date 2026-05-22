#ifndef _VBCCINLINE_LOG_H
#define _VBCCINLINE_LOG_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

void __LogVPrintf(void *, char * Category, char * Format, va_list args) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LogVPrintf(Category, Format, args) __LogVPrintf(LogBase, (Category), (Format), (args))

void __LogPrintf(void *, char * Category, char * Format, ...) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LogPrintf(Category, ...) __LogPrintf(LogBase, (Category), __VA_ARGS__)

void __LogShowWindow(void *) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LogShowWindow() __LogShowWindow(LogBase)

void __LogHideWindow(void *) =
	"\tlwz\t0,-52(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LogHideWindow() __LogHideWindow(LogBase)

ULONG __LogAddNotify(void *, struct MsgPort * NotifyMsgPort) =
	"\tlwz\t0,-58(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LogAddNotify(NotifyMsgPort) __LogAddNotify(LogBase, (NotifyMsgPort))

ULONG __LogRemNotify(void *, struct MsgPort * NotifyMsgPort) =
	"\tlwz\t0,-64(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define LogRemNotify(NotifyMsgPort) __LogRemNotify(LogBase, (NotifyMsgPort))

#endif /*  _VBCCINLINE_LOG_H  */
