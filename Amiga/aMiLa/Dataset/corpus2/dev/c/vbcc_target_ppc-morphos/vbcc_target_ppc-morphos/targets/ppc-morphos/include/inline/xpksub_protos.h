#ifndef _VBCCINLINE_XPKSUB_H
#define _VBCCINLINE_XPKSUB_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

struct XpkInfo * __XpksPackerInfo(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define XpksPackerInfo() __XpksPackerInfo(XpkSubBase)

LONG __XpksPackChunk(void *, struct XpkSubParams * xpar) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define XpksPackChunk(xpar) __XpksPackChunk(XpkSubBase, (xpar))

void __XpksPackFree(void *, struct XpkSubParams * xpar) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define XpksPackFree(xpar) __XpksPackFree(XpkSubBase, (xpar))

LONG __XpksPackReset(void *, struct XpkSubParams * xpar) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define XpksPackReset(xpar) __XpksPackReset(XpkSubBase, (xpar))

LONG __XpksUnpackChunk(void *, struct XpkSubParams * xpar) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define XpksUnpackChunk(xpar) __XpksUnpackChunk(XpkSubBase, (xpar))

void __XpksUnpackFree(void *, struct XpkSubParams * xpar) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define XpksUnpackFree(xpar) __XpksUnpackFree(XpkSubBase, (xpar))

#endif /*  _VBCCINLINE_XPKSUB_H  */
