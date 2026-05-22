#ifndef _VBCCINLINE_REXXSYSLIB_H
#define _VBCCINLINE_REXXSYSLIB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

UBYTE * __CreateArgstring(void *, CONST_STRPTR string, ULONG length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define CreateArgstring(string, length) __CreateArgstring(RexxSysBase, (string), (length))

VOID __DeleteArgstring(void *, STRPTR argstring) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define DeleteArgstring(argstring) __DeleteArgstring(RexxSysBase, (argstring))

ULONG __LengthArgstring(void *, CONST_STRPTR argstring) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define LengthArgstring(argstring) __LengthArgstring(RexxSysBase, (argstring))

struct RexxMsg * __CreateRexxMsg(void *, CONST struct MsgPort * port, CONST_STRPTR extension, CONST_STRPTR host) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define CreateRexxMsg(port, extension, host) __CreateRexxMsg(RexxSysBase, (port), (extension), (host))

VOID __DeleteRexxMsg(void *, struct RexxMsg * packet) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define DeleteRexxMsg(packet) __DeleteRexxMsg(RexxSysBase, (packet))

VOID __ClearRexxMsg(void *, struct RexxMsg * msgptr, ULONG count) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define ClearRexxMsg(msgptr, count) __ClearRexxMsg(RexxSysBase, (msgptr), (count))

BOOL __FillRexxMsg(void *, struct RexxMsg * msgptr, ULONG count, ULONG mask) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define FillRexxMsg(msgptr, count, mask) __FillRexxMsg(RexxSysBase, (msgptr), (count), (mask))

BOOL __IsRexxMsg(void *, CONST struct RexxMsg * msgptr) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define IsRexxMsg(msgptr) __IsRexxMsg(RexxSysBase, (msgptr))

VOID __LockRexxBase(void *, ULONG resource) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-450\n"
	"\tbctrl";
#define LockRexxBase(resource) __LockRexxBase(RexxSysBase, (resource))

VOID __UnlockRexxBase(void *, ULONG resource) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tli\t3,-456\n"
	"\tbctrl";
#define UnlockRexxBase(resource) __UnlockRexxBase(RexxSysBase, (resource))

#endif /*  _VBCCINLINE_REXXSYSLIB_H  */
