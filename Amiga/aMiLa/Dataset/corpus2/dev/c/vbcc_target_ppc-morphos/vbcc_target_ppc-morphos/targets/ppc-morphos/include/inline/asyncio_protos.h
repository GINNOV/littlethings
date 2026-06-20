#ifndef _VBCCINLINE_ASYNCIO_H
#define _VBCCINLINE_ASYNCIO_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

LONG __CloseAsync(void *, AsyncFile * file) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define CloseAsync(file) __CloseAsync(AsyncIOBase, (file))

LONG __SeekAsync(void *, AsyncFile * file, LONG position, SeekModes mode) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tstw\t6,4(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define SeekAsync(file, position, mode) __SeekAsync(AsyncIOBase, (file), (position), (mode))

LONG __ReadAsync(void *, AsyncFile * file, APTR buffer, LONG bytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define ReadAsync(file, buffer, bytes) __ReadAsync(AsyncIOBase, (file), (buffer), (bytes))

LONG __WriteAsync(void *, AsyncFile * file, APTR buffer, LONG bytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define WriteAsync(file, buffer, bytes) __WriteAsync(AsyncIOBase, (file), (buffer), (bytes))

LONG __ReadCharAsync(void *, AsyncFile * file) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define ReadCharAsync(file) __ReadCharAsync(AsyncIOBase, (file))

LONG __WriteCharAsync(void *, AsyncFile * file, UBYTE ch) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define WriteCharAsync(file, ch) __WriteCharAsync(AsyncIOBase, (file), (ch))

LONG __ReadLineAsync(void *, AsyncFile * file, APTR buf, LONG bytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define ReadLineAsync(file, buf, bytes) __ReadLineAsync(AsyncIOBase, (file), (buf), (bytes))

LONG __WriteLineAsync(void *, AsyncFile * file, STRPTR buf) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define WriteLineAsync(file, buf) __WriteLineAsync(AsyncIOBase, (file), (buf))

APTR __FGetsAsync(void *, AsyncFile * file, APTR buf, LONG bytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define FGetsAsync(file, buf, bytes) __FGetsAsync(AsyncIOBase, (file), (buf), (bytes))

APTR __FGetsLenAsync(void *, AsyncFile * file, APTR buf, LONG bytes, LONG * length) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tstw\t7,40(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define FGetsLenAsync(file, buf, bytes, length) __FGetsLenAsync(AsyncIOBase, (file), (buf), (bytes), (length))

LONG __PeekAsync(void *, AsyncFile * file, APTR buffer, LONG bytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define PeekAsync(file, buffer, bytes) __PeekAsync(AsyncIOBase, (file), (buffer), (bytes))

LONG __ReadAsyncPkt(void *, AsyncFile * file, struct Hook * hook, LONG bytes) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-198\n"
	"\tbctrl";
#define ReadAsyncPkt(file, hook, bytes) __ReadAsyncPkt(AsyncIOBase, (file), (hook), (bytes))

QUAD __SeekAsync64(void *, AsyncFile * file, QUAD position, SeekModes mode) =
	"\tlwz\t0,-202(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define SeekAsync64(file, position, mode) __SeekAsync64(AsyncIOBase, (file), (position), (mode))

#endif /*  _VBCCINLINE_ASYNCIO_H  */
