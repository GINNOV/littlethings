#ifndef _VBCCINLINE_RANDOM_H
#define _VBCCINLINE_RANDOM_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

ULONG __Random(void *) =
	"\tlwz\t0,-28(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define Random() __Random(RandomBase)

UBYTE __RandomByte(void *) =
	"\tlwz\t0,-34(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define RandomByte() __RandomByte(RandomBase)

void __RandomStir(void *) =
	"\tlwz\t0,-40(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define RandomStir() __RandomStir(RandomBase)

void __RandomBytes(void *, APTR buf, LONG buflen) =
	"\tlwz\t0,-46(3)\n"
	"\tmtctr\t0\n"
	"\tbctrl";
#define RandomBytes(buf, buflen) __RandomBytes(RandomBase, (buf), (buflen))

#endif /*  _VBCCINLINE_RANDOM_H  */
